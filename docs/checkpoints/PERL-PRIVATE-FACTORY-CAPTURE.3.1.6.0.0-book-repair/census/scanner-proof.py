"""Register exact diagnostic bytes and prove old RED/current GREEN/strict denials."""
import base64
import gzip
import hashlib
import json
import os
import sys
import tempfile
import types
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
CHECKER = 'tools/check_executable_aggregate_selector_sources.py'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'], ['--apply'])
packet = json.loads(gzip.decompress((HERE / 'scanner-before.json.gz').read_bytes()))
assert packet['producer_sha256'] == digest((HERE / 'scanner-capture.py').read_bytes())
original = base64.b64decode(packet['scanner_base64'], validate=True)
insertion = b'    # Exact negative/private synthetic fixtures; any byte edit or copied path rejects.\n'
for path, row in sorted(packet['inputs'].items()):
    raw = base64.b64decode(row['data'], validate=True)
    assert digest(raw) == row['sha256'] and (ROOT / path).read_bytes() == raw
    insertion += ('    ' + repr(path) + ':\n        ' + repr(row['sha256']) + ',\n').encode()
anchor = b'}\nSELECTOR = re.compile('
assert original.count(anchor) == 1
expected = original.replace(anchor, insertion + anchor, 1)
if sys.argv[1:] == ['--apply']:
    assert (ROOT / CHECKER).read_bytes() == original, 'one-shot scanner registration'
    (ROOT / CHECKER).write_bytes(expected)
    print('Exact diagnostic registry extended:', len(packet['inputs']), 'paths; scanner logic unchanged')
    raise SystemExit(0)
assert (ROOT / CHECKER).read_bytes() == expected, 'foreign scanner change'
paths = sorted(packet['inputs'])
controls = []
with tempfile.TemporaryDirectory(prefix='scanner-registry-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path,row in packet['inputs'].items():
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(base64.b64decode(row['data']))
    def load(source, name):
        module = types.ModuleType(name)
        module.__file__ = str(supplied / CHECKER)
        exec(compile(source, module.__file__, 'exec'), module.__dict__)
        return module
    old = load(original, 'old_scanner')
    current = load(expected, 'current_scanner')
    assert old.scan_files(paths) == (packet['positive'], 0), 'original scanner refusal changed'
    assert current.scan_files(paths) == ([], 27), 'registered diagnostics not classified'
    for path in paths:
        body = (supplied / path).read_bytes()
        copied = 'copied/' + path
        target = supplied / copied
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(body)
        positive,classified = current.scan_files([copied])
        assert positive and classified == 0, 'copied diagnostic admitted'
        controls.append({'path': path, 'case': 'copied', 'positive': positive, 'classified': classified})
        target.unlink()
        for name,changed in (('edited', body + b'\n'),
                             ('added-selector', body + b"\nsource = '" + b'array' + b"(unclassified)'\n")):
            (supplied / path).write_bytes(changed)
            positive,classified = current.scan_files([path])
            assert positive and classified == 0, 'edited diagnostic admitted'
            if name == 'added-selector':
                assert any('unclassified' in line for line in positive)
            controls.append({'path': path, 'case': name, 'positive': positive, 'classified': classified})
        (supplied / path).write_bytes(body)
    assert current.scan_files(paths) == ([], 27)
    assert all((supplied / p).read_bytes() == base64.b64decode(r['data']) for p,r in packet['inputs'].items())
assert len(controls) == 51
report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
          'scanner_sha256': digest(expected), 'original_sha256': digest(original),
          'inputs': {p:r['sha256'] for p,r in packet['inputs'].items()},
          'original_positive': packet['positive'], 'current_positive': [], 'current_classified': 27,
          'controls': controls, 'restored': True,
          'scope': 'Exact existing scanner functions on all17 retained flagged fixtures. Original27 positives become27 classifications solely through exact path/full-byte registry entries. All17 copied,17 edited and17 added-selector variants reject; restoration passes. No broad filename/prefix/directory exclusion, scanner logic or discovery change.'}
target = HERE / 'scanner-proof.json'
if sys.argv[1:]:
    assert not target.exists(), 'one-shot scanner proof'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'scanner proof drift'
print('Exact diagnostic scanner proof PASS: original27 RED/current27 classified;17 paths;51 copied/edited/added-selector denials')
