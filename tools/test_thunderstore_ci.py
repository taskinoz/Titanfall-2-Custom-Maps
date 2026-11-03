import json
import tempfile
import urllib.error
import unittest
import zipfile
from pathlib import Path
from unittest.mock import MagicMock, patch

import thunderstore_ci as ci
import thunderstore_upload as uploader


class CatalogTests(unittest.TestCase):
    def test_catalog_entries_are_complete_and_match_the_repository(self):
        for p in ci.catalog():
            with self.subTest(p['name']):
                self.assertLessEqual(len(p['description']), 250)
                self.assertEqual(p['tag'], f'{p["slug"]}-v{p["version"]}')
                self.assertEqual(p['asset'], f'{p["mod"]}-{p["version"]}.zip')
                self.assertTrue((ci.ROOT/'thunderstore/icons'/f'{p["name"]}.png').exists())
                info = json.loads((ci.ROOT/'maps'/p['slug']/'mod'/p['mod']/'mod.json').read_text(encoding='utf-8-sig'))
                self.assertEqual((info['Name'], info['Version']), (p['mod'], p['version']))

    def test_selection(self):
        self.assertEqual(len(ci.select(ci.catalog(), 'current')), len(ci.catalog()))
        self.assertEqual([p['mod'] for p in ci.select(ci.catalog(), 'minecraft-uma-v0.5.1')], ['MRVN.MinecraftUma'])
        self.assertEqual(ci.select(ci.catalog(), 'minecraft-uma-v0.1.0'), [])


class PackagingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.package = next(p.copy() for p in ci.catalog() if p['mod'] == 'MRVN.QuakeE1M1Test')

    def source(self, extra=None, version=None):
        p = self.root/'source.zip'
        mod = self.package['mod']
        with zipfile.ZipFile(p, 'w') as z:
            z.writestr(mod+'/mod.json', json.dumps({'Name': mod, 'Version': version or self.package['version']}))
            z.writestr(mod+'/README.md', 'Manual install notes')
            z.writestr(mod+'/COPYING', 'GPL')
            z.writestr(mod+'/mod/maps/mp_quake_e1m1.bsp', b'exact geometry bytes')
            z.writestr(mod+'/paks/quake_textures.rpak', b'exact texture bytes')
            z.writestr(mod+'/source/mp_quake_e1m1.map', b'map source')
            if extra:
                z.writestr(extra, b'not allowed')
        self.package.update(bytes=p.stat().st_size, sha256=ci.digest(p))
        return p

    def test_repackage_preserves_runtime_bytes_and_discloses_ai(self):
        receipt = ci.build(self.package, self.source(), self.root/'built')
        with zipfile.ZipFile(receipt['path']) as z:
            prefix = 'mods/taskinoz.MRVN.QuakeE1M1Test/'
            self.assertEqual(z.read(prefix+'mod/maps/mp_quake_e1m1.bsp'), b'exact geometry bytes')
            self.assertEqual(z.read(prefix+'COPYING'), b'GPL')
            manifest = json.loads(z.read('manifest.json'))
            self.assertEqual(manifest['dependencies'], [])
            readme = z.read('README.md').decode()
            self.assertIn('produced with AI', readme)
            self.assertIn(self.package['original_url'], readme)
        # Fixed archive timestamps make repeats identical on the same toolchain.
        self.assertEqual(receipt['sha256'], ci.build(self.package, self.source(), self.root/'again')['sha256'])

    def test_rejects_tampered_source(self):
        p = self.source()
        p.write_bytes(p.read_bytes()+b'tamper')
        with self.assertRaisesRegex(ValueError, 'locked release'):
            ci.build(self.package, p, self.root/'built')

    def test_rejects_unexpected_version(self):
        with self.assertRaisesRegex(ValueError, 'identity/version'):
            ci.build(self.package, self.source(version='9.9.9'), self.root/'built')

    def test_rejects_traversal_and_development_files(self):
        mod = self.package['mod']
        for name in (mod+'/../secret', mod+'/logs/session.json', mod+'/build.log',
                     mod+'\\mod.json', '/'+mod+'/mod.json', 'Other/mod.json'):
            with self.subTest(name=name), self.assertRaises(ValueError):
                ci.build(self.package, self.source(extra=name), self.root/'built')

    def test_publish_requires_secret_before_network(self):
        with patch.dict(ci.os.environ, {}, clear=True), self.assertRaisesRegex(ValueError, 'TS_KEY'):
            ci.publish([])

    def test_publish_uses_async_uploader_and_fresh_version_lookup(self):
        receipt = ci.build(self.package, self.source(), self.root/'built')
        missing = urllib.error.HTTPError('https://thunderstore.io', 404, 'not found', {}, None)
        with patch.dict(ci.os.environ, {'TCLI_AUTH_TOKEN': 'unit-test-placeholder'}), \
                patch.object(ci.urllib.request, 'urlopen', side_effect=missing) as get, \
                patch.object(uploader, 'submit') as submit:
            ci.publish([receipt])
        self.assertEqual(submit.call_args.args[:2], (receipt['path'], 'taskinoz'))
        self.assertIn('?ci=', get.call_args.args[0].full_url)


class UploadTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.file = Path(self.temp.name)/'tiny.zip'
        self.file.write_bytes(b'test')

    def test_async_protocol_uploads_then_polls_background_validation(self):
        initial = {'user_media': {'uuid': 'upload-test'}, 'upload_urls': [dict(offset=0, length=4, part_number=1)]}
        done = {'status': 'FINISHED', 'result': {'package_version': {'download_url': 'https://thunderstore.io/download/test'}}}
        with patch.object(uploader, 'api', side_effect=[initial, {}, {'id': 'submit-test', 'status': 'PENDING'}, done]) as api, \
                patch.object(uploader, 'upload_part', return_value={'ETag': 'part', 'PartNumber': 1}), \
                patch.object(uploader.time, 'sleep'):
            uploader.submit(self.file, 'taskinoz', 'unit-test-placeholder')
        calls = api.call_args_list
        self.assertEqual(calls[1].args[0], 'usermedia/upload-test/finish-upload/')
        self.assertEqual(calls[2].args[2]['communities'], ['northstar'])
        self.assertTrue(calls[3].args[0].startswith('submission/poll-async/submit-test/'))

    def test_invalid_part_ranges_abort_before_upload(self):
        initial = {'user_media': {'uuid': 'upload-test'}, 'upload_urls': [dict(offset=1, length=4, part_number=1)]}
        with patch.object(uploader, 'api', side_effect=[initial, {}]) as api, \
                patch.object(uploader, 'upload_part') as part, self.assertRaises(ValueError):
            uploader.submit(self.file, 'taskinoz', 'unit-test-placeholder')
        part.assert_not_called()
        self.assertEqual(api.call_args.args[0], 'usermedia/upload-test/abort-upload/')

    def test_storage_request_has_no_api_credential_and_hides_signed_url(self):
        response = MagicMock()
        response.__enter__.return_value.headers = {'ETag': 'test-etag'}
        with patch.object(uploader.urllib.request, 'urlopen', return_value=response) as put:
            uploader.upload_part(self.file, dict(url='https://storage.example/part', offset=0, length=4, part_number=1))
        self.assertIsNone(put.call_args.args[0].get_header('Authorization'))
        with patch.object(uploader.urllib.request, 'urlopen', side_effect=urllib.error.URLError('secret-signed-url')):
            with self.assertRaises(RuntimeError) as error:
                uploader.upload_part(self.file, dict(url='https://storage.example/?signature=private', offset=0, length=4, part_number=1))
        self.assertNotIn('signature', str(error.exception))


if __name__ == '__main__':
    unittest.main()
