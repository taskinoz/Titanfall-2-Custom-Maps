"""Repackage hash-locked GitHub release ZIPs for Thunderstore; never compile maps in CI.

Adapted from taskinoz/apex-to-titanfall-2's publisher. The catalog in
thunderstore/packages.json pins each package to a release tag, asset name, size and
SHA-256. Runtime bytes are copied unchanged into the Thunderstore layout.
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import struct
import subprocess
import sys
import time
import urllib.error
import urllib.request
import zipfile
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parent.parent
REPO = 'taskinoz/Titanfall-2-Custom-Maps'
WEBSITE = 'https://github.com/' + REPO
USER_AGENT = 'CustomMapPublisher/1.0 (+https://github.com/taskinoz/Titanfall-2-Custom-Maps)'
# Top-level folders and files a player package may contain.
FOLDERS = ('mod', 'paks', 'vpk', 'source', 'keyvalues')
FILE = re.compile(r'(mod\.json|README\.md|COPYING|LICENSE[-\w]*\.txt|materials\.json|verification\.json)')


def digest(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def catalog():
    return json.loads((ROOT/'thunderstore/packages.json').read_text(encoding='utf-8'))


def select(packages, selector):
    """'current' selects everything; otherwise a runtime mod name or release tag."""
    if selector == 'current':
        return list(packages)
    return [p for p in packages if selector in (p['mod'], p['tag'])]


def fetch(package, directory):
    target = directory/package['asset']
    directory.mkdir(parents=True, exist_ok=True)
    if not target.exists():
        subprocess.run(['gh', 'release', 'download', package['tag'], '--repo', REPO,
                        '--pattern', package['asset'], '--dir', str(directory)], check=True)
    if target.stat().st_size != package['bytes'] or digest(target) != package['sha256']:
        raise ValueError('Source download size/hash mismatch: ' + target.name)
    return target


def entries(archive, mod):
    seen = set()
    result = []
    for item in archive.infolist():
        name = item.filename
        path = PurePosixPath(name)
        if ('\\' in name or path.is_absolute() or '..' in path.parts or
                not path.parts or path.parts[0] != mod or name.casefold() in seen or
                (item.external_attr >> 16) & 0o170000 == 0o120000):
            raise ValueError('Unsafe or duplicate ZIP member: ' + name)
        seen.add(name.casefold())
        if item.is_dir():
            continue
        relative = PurePosixPath(*path.parts[1:])
        if not (len(relative.parts) == 1 and FILE.fullmatch(relative.name) or
                len(relative.parts) > 1 and relative.parts[0] in FOLDERS):
            raise ValueError('Unexpected development file: ' + name)
        result.append((item, relative.as_posix()))
    return result


def readme(package, original):
    if package.get('kind') == 'mode':
        return (f'# {package["title"]}\n\n{package["description"]}\n\n'
                'This mode was written with AI; see '
                f'[the disclosure]({WEBSITE}/blob/main/AI.md).\n\n'
                'Everyone in the match needs the same version. Remove manually installed '
                'copies of MRVN.Surf before enabling the managed version.\n\n' + original)
    return (f'# {package["title"]}\n\n{package["description"]}\n\n'
            f'Original human-built map: [{package["original_title"]}]({package["original_url"]}). '
            'This conversion was produced with AI; see '
            f'[the disclosure]({WEBSITE}/blob/main/AI.md).\n\n'
            f'Start it from the console with `{package["command"]}`. Everyone in the match needs the '
            'same version. Remove any manually installed copy of this mod before enabling the '
            f'managed one.\n\n[Source, changelog and older versions]({WEBSITE}/tree/main/maps/{package["slug"]})\n\n'
            + original)


def build(package, source, out, namespace='taskinoz'):
    if not re.fullmatch(r'[A-Za-z0-9_]+', namespace):
        raise ValueError('Invalid Thunderstore namespace')
    if source.stat().st_size != package['bytes'] or digest(source) != package['sha256']:
        raise ValueError('Source ZIP does not match locked release')
    mod, name, version = package['mod'], package['name'], package['version']
    if not re.fullmatch(r'[A-Za-z0-9_]+', name) or not re.fullmatch(r'\d+\.\d+\.\d+', version):
        raise ValueError('Invalid package identity/version')
    if len(package['description']) > 250:
        raise ValueError('Description exceeds Thunderstore limit')
    folder = out/name
    folder.mkdir(parents=True, exist_ok=True)
    icon = ROOT/'thunderstore/icons'/f'{name}.png'
    raw = icon.read_bytes()
    if raw[:8] != b'\x89PNG\r\n\x1a\n' or struct.unpack('>II', raw[16:24]) != (256, 256):
        raise ValueError('Expected 256x256 PNG icon')
    manifest = dict(name=name, version_number=version, website_url=WEBSITE,
                    description=package['description'], dependencies=package.get('dependencies', []))
    hashes = {}
    with zipfile.ZipFile(source) as old:
        members = entries(old, mod)
        info = json.loads(old.read(mod+'/mod.json').decode('utf-8-sig'))
        if (info['Name'], info['Version']) != (mod, version):
            raise ValueError('Runtime mod identity/version disagrees with catalog')
        if package.get('kind') == 'mode':
            if not any(r.startswith('mod/scripts/') and r.endswith(('.nut', '.gnut')) for _, r in members):
                raise ValueError('Missing game mode scripts')
        elif not any(r.startswith('paks/') and r.endswith('.rpak') for _, r in members):
            raise ValueError('Missing native asset pack')
        if package.get('kind') != 'mode' and not any(r.startswith('mod/maps/') and r.endswith('.bsp') for _, r in members):
            raise ValueError('Missing map payload')
        text = readme(package, old.read(mod+'/README.md').decode('utf-8-sig'))
        (folder/'README.md').write_text(text, encoding='utf-8')
        shutil.copyfile(icon, folder/'icon.png')
        target = folder/f'{namespace}-{name}-{version}.zip'
        temporary = target.with_suffix('.packaging')
        with zipfile.ZipFile(temporary, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as new:
            def write(entry, data):
                zi = zipfile.ZipInfo(entry, (2026, 1, 1, 0, 0, 0))
                zi.compress_type = zipfile.ZIP_DEFLATED
                zi.external_attr = 0o100644 << 16
                new.writestr(zi, data)
            write('manifest.json', (json.dumps(manifest, indent=2)+'\n').encode())
            write('README.md', text.encode())
            write('icon.png', raw)
            for item, rel in sorted(members, key=lambda pair: pair[1]):
                data = old.read(item)
                destination = f'mods/{namespace}.{mod}/{rel}'
                write(destination, data)
                hashes[destination] = hashlib.sha256(data).hexdigest()
        with zipfile.ZipFile(temporary) as check:
            for entry, expected in hashes.items():
                if hashlib.sha256(check.read(entry)).hexdigest() != expected:
                    raise ValueError('Repack changed runtime bytes')
        temporary.replace(target)
    return dict(mod=mod, name=name, version=version, namespace=namespace,
                path=str(target.resolve()), sha256=digest(target),
                source_sha256=package['sha256'], runtime_sha256=hashes)


def publish(receipts):
    if not os.environ.get('TCLI_AUTH_TOKEN'):
        raise ValueError('Missing repository Actions secret TS_KEY (taskinoz Thunderstore service account)')
    for r in receipts:
        if digest(r['path']) != r['sha256']:
            raise ValueError('Prepared ZIP changed')
        # Thunderstore/CDN negative caching can briefly hide a newly published version.
        url = f'https://thunderstore.io/api/experimental/package/{r["namespace"]}/{r["name"]}/{r["version"]}/?ci={time.time_ns()}'
        try:
            request = urllib.request.Request(url, headers={'User-Agent': USER_AGENT, 'Cache-Control': 'no-cache'})
            with urllib.request.urlopen(request, timeout=60) as response:
                existing = json.load(response)
        except urllib.error.HTTPError as e:
            if e.code != 404:
                raise
        else:
            # A published version is immutable: verify its payload, never overwrite it.
            remote = Path(r['path']).with_suffix('.remote.zip')
            request = urllib.request.Request(existing['download_url'], headers={'User-Agent': USER_AGENT})
            with urllib.request.urlopen(request, timeout=120) as response, remote.open('wb') as f:
                shutil.copyfileobj(response, f)
            with zipfile.ZipFile(remote) as z, zipfile.ZipFile(r['path']) as local:
                if set(z.namelist()) != set(local.namelist()) or any(z.read(n) != local.read(n) for n in local.namelist()):
                    raise ValueError('Published version differs; bump version instead of overwriting')
            remote.unlink()
            print('Already published and verified:', r['name'], r['version'], flush=True)
            continue
        from thunderstore_upload import submit
        submit(r['path'], r['namespace'], os.environ['TCLI_AUTH_TOKEN'])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--select', default='current', help='current, runtime mod name, or release tag')
    p.add_argument('--namespace', default='taskinoz')
    p.add_argument('--output', type=Path, default=ROOT/'output/thunderstore')
    p.add_argument('--source-dir', type=Path, help='Use already-downloaded release ZIPs')
    p.add_argument('--publish', action='store_true', help='Publish previously prepared receipts in output')
    args = p.parse_args()
    receipt_path = args.output/'receipts.json'
    if args.publish:
        publish(json.loads(receipt_path.read_text()))
        return
    chosen = select(catalog(), args.select)
    if not chosen:
        # Releases of older versions and unreleased maps are not in the catalog.
        print(f'No catalogued package for {args.select!r}; nothing to publish.', flush=True)
    args.output.mkdir(parents=True, exist_ok=True)
    receipts = []
    for package in chosen:
        source = args.source_dir/package['asset'] if args.source_dir else fetch(package, args.output/'downloads')
        receipts.append(build(package, source, args.output, args.namespace))
        print('Prepared:', package['name'], package['version'], flush=True)
    receipt_path.write_text(json.dumps(receipts, indent=2)+'\n')
    if 'GITHUB_OUTPUT' in os.environ:
        with open(os.environ['GITHUB_OUTPUT'], 'a') as f:
            f.write(f'count={len(receipts)}\n')


if __name__ == '__main__':
    sys.exit(main())
