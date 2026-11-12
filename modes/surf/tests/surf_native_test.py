#!/usr/bin/env python3
"""Run the Surf mode's rule checks natively in Titanfall 2 on one or more surf maps.

Copies modes/surf/MRVN.Surf to a scratch folder, appends surf_native_test.nut and
starts it from _Surf_Init, then loads each map in Surf mode with the ARES
Northstar harness (https://github.com/taskinoz/ARES) in its isolated
R2AresHarness profile, one fresh game per map. The released mod folder is
never modified. Score saving is off; that profile has no leaderboard key.

  python modes/surf/tests/surf_native_test.py --ares PATH/TO/ARES --game C:/Games/Titanfall2 \\
      --map mp_source_surf_utopia=PATH/TO/MRVN.SourceSurfUtopia \\
      --map mp_source_surf_me=PATH/TO/MRVN.SourceSurfMe --output reports/surf

Each --map is <map name>=<installed map mod folder>. Exit code 0 means every map
printed "[SurfTest] PASSED" with no script errors. report.json lists each
check; each map's game log is in <output>/<map>/nslog.txt.
"""
import argparse
import json
import shutil
import sys
import tempfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
SURF_MOD = HERE.parent / 'MRVN.Surf'
GAMEMODE = Path('mod/scripts/vscripts/gamemodes/_gamemode_surf.nut')
HOOK = '\tthread Surf_Tick()\n'


def instrumented_copy(destination):
    target = destination / SURF_MOD.name
    shutil.copytree(SURF_MOD, target)
    script = target / GAMEMODE
    code = script.read_text(encoding='utf-8')
    if code.count(HOOK) != 1:
        raise SystemExit(f'cannot find the single "{HOOK.strip()}" hook in {GAMEMODE}')
    code = code.replace(HOOK, HOOK + '\tthread SurfTest_Run()\n')
    code += '\n' + (HERE / 'surf_native_test.nut').read_text(encoding='utf-8')
    script.write_text(code, encoding='utf-8')
    return target


def wait_for_result(session, map_name, timeout):
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        if not session.healthy():
            raise RuntimeError('game exited during the surf checks')
        text = session.log_text()
        if f'[SurfTest] PASSED {map_name}' in text:
            return
        time.sleep(1)
    raise TimeoutError(f'{map_name}: surf checks did not finish within {timeout}s')


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('--ares', type=Path, required=True, help='ARES checkout (for harnesses/adapters)')
    p.add_argument('--game', type=Path, required=True)
    p.add_argument('--map', action='append', required=True, metavar='MAP=MODDIR')
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--timeout', type=int, default=180, help='Seconds per map for the checks')
    args = p.parse_args()
    sys.path.insert(0, str(args.ares / 'harnesses' / 'adapters'))
    from northstar_harness import Session

    maps = []
    for item in args.map:
        name, _, folder = item.partition('=')
        if not name or not folder or not Path(folder).is_dir():
            p.error(f'--map needs MAP=MODDIR with an existing folder: {item}')
        maps.append((name, Path(folder)))
    args.output.mkdir(parents=True, exist_ok=True)
    report = {'maps': {}}
    with tempfile.TemporaryDirectory() as scratch:
        surf = instrumented_copy(Path(scratch))
        # One fresh game per map: switching maps in a running client can stall,
        # and a script error must not affect the next map.
        for name, folder in maps:
            output = args.output / name
            session = Session(args.game, output, mods=[surf, folder], extra_args=['+surf_save_scores', '0'])
            result = {'passed': False, 'checks': [], 'errors': []}
            text = ''
            try:
                with session:
                    session.load(name, 'surf')
                    wait_for_result(session, name, args.timeout)
                    text = session.log_text()
                    result['passed'] = True
            except Exception as error:
                result['errors'].append(f'{type(error).__name__}: {error}')
            if not text and (output / 'nslog.txt').exists():
                text = (output / 'nslog.txt').read_text('utf-8', 'replace')
            result['checks'] = [l.split('[SurfTest] ', 1)[1] for l in text.splitlines() if '[SurfTest] ' in l]
            result['errors'] += session.script_errors(text)
            result['passed'] = result['passed'] and not result['errors']
            report['maps'][name] = result
    ok = len(report['maps']) == len(maps) and all(m['passed'] for m in report['maps'].values())
    report['passed'] = ok
    (args.output / 'report.json').write_text(json.dumps(report, indent=2))
    print(json.dumps(report, indent=2))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
