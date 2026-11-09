"""Exercise the PHP leaderboard against an isolated SQLite fixture."""
import base64
import json
import shutil
import sqlite3
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


class LeaderboardTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        executable = shutil.which('php')
        if not executable:
            raise unittest.SkipTest('PHP not installed')
        cls.php = [executable]
        probe = 'echo json_encode(PDO::getAvailableDrivers());'
        if 'sqlite' not in subprocess.check_output(cls.php + ['-r', probe], text=True):
            cls.php += ['-d', 'extension=php_pdo_sqlite']
            result = subprocess.run(cls.php + ['-r', probe], capture_output=True, text=True)
            if result.returncode or 'sqlite' not in result.stdout:
                raise unittest.SkipTest('PDO SQLite not installed')

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.db = self.root/'scores.sqlite'
        for name in ('lib.php', 'index.php'):
            shutil.copyfile(ROOT/'modes/surf/leaderboard'/name, self.root/name)
        self.config = {'database': self.db.as_posix(), 'server_keys': [], 'site_title': 'Test leaderboard'}
        (self.root/'config.php').write_text("<?php return json_decode('" + json.dumps(self.config) + "', true);")
        self.run_php('surf_db();')
        rows = [
            ('map_a', '1', 'Alice', 10, 'Server A', 300),
            ('map_a', '1', 'Alice slower', 20, 'Server B', 100),
            ('map_a', '2', 'Bob', 15, 'Server B', 200),
            ('map_a', '2', 'Bob later tie', 15, 'Server C', 250),
            ('map_a', '3', 'Carol', 15, 'Server C', 300),
            ('map_a', '4', 'Eve%_literal', 25, 'Server A', 400),
            ('map_a', '5', '<img src=x onerror=alert(1)>', 30, 'Server A', 400),
            ('map_b', '1', 'Alice', 100, 'Server B', 500),
            ('map_a__no_double_jump', '2', 'Bob', 50, 'Server B', 500),
        ] + [('map_a', str(i), f'Pilot{i:03d}', 30 + i, 'Server A', 600 + i) for i in range(6, 126)]
        with sqlite3.connect(self.db) as db:
            db.executemany('INSERT INTO runs(map,uid,name,time,server,created) VALUES(?,?,?,?,?,?)', rows)

    def run_php(self, code):
        prefix = 'require ' + json.dumps((self.root/'lib.php').as_posix()) + ';'
        return subprocess.check_output(self.php + ['-r', prefix + code], text=True)

    def query(self, map_name='', search='', limit=50, offset=0):
        args = ','.join(json.dumps(v) for v in (map_name, search, limit, offset))
        return json.loads(self.run_php('echo json_encode(surf_leaderboard(' + args + '));'))

    def render(self, params):
        encoded = base64.b64encode(json.dumps(params).encode()).decode()
        code = '$_GET=json_decode(base64_decode("' + encoded + '"),true);require ' + json.dumps((self.root/'index.php').as_posix()) + ';'
        return subprocess.check_output(self.php + ['-r', code], text=True)

    def test_search_keeps_rank_and_uses_matching_best_run_metadata(self):
        result = self.query('map_a', 'bOB')
        self.assertEqual(result['total'], 1)
        self.assertEqual(result['scores'][0]['rank'], 2)
        self.assertEqual(result['scores'][0]['server'], 'Server B')
        self.assertEqual(result['scores'][0]['name'], 'Bob')
        self.assertIn('1970-01-01T00:03:20', result['scores'][0]['date'])

    def test_ties_and_map_rule_categories_rank_independently(self):
        self.assertEqual(self.query('map_a', 'Carol')['scores'][0]['rank'], 2)
        self.assertEqual(self.query('map_a', 'Eve')['scores'][0]['rank'], 4)
        self.assertEqual(self.query('map_b', 'Alice')['scores'][0]['rank'], 1)
        self.assertEqual(self.query('map_a__no_double_jump', 'Bob')['scores'][0]['rank'], 1)
        self.assertEqual(self.query('', 'Alice')['total'], 2)

    def test_search_reaches_past_top_100_and_treats_wildcards_as_text(self):
        self.assertEqual(self.query('map_a', 'Pilot125')['scores'][0]['rank'], 125)
        self.assertEqual(self.query('map_a', '%_')['total'], 1)
        self.assertEqual(self.query('map_a', "' OR 1=1 --")['total'], 0)

    def test_pagination_keeps_filters_and_rank_and_escapes_names(self):
        html = self.render({'map': 'map_a', 'q': 'Pilot', 'page': '2'})
        self.assertIn('Page 2 of 3', html)
        self.assertIn('q=Pilot&amp;map=map_a&amp;page=3', html)
        self.assertIn('value="map_a" selected', html)
        self.assertIn('Global rank', html)
        html = self.render({'q': '<img'})
        self.assertNotIn('<img src=x', html)
        self.assertIn('&lt;img src=x', html)

    def test_legacy_top_api_fields_and_invalid_filter_inputs(self):
        rows = json.loads(self.run_php('echo json_encode(surf_top("map_a", 2));'))
        self.assertEqual(len(rows), 2)
        self.assertTrue({'name','uid','time','date','server'} <= rows[0].keys())
        html = self.render({'q': ['bad'], 'map': ['bad'], 'page': ['bad']})
        self.assertIn('All maps', html)
        self.assertNotIn('Warning:', html)


if __name__ == '__main__':
    unittest.main()
