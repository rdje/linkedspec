"""Retain exact private-input classification and distinguish path/byte additions."""
import base64
import gzip
import hashlib
import importlib.util
import json
import os
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical03/'
SOURCE = 'tools/check_executable_aggregate_selector_sources.py'
target = ROOT / (PREFIX + 'scanner.json')
assert not target.exists(), 'one-shot scanner registration observation'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = (ROOT / (PREFIX + 'scanner-before.py')).read_bytes()
current = (ROOT / SOURCE).read_bytes()
addition = (ROOT / (PREFIX + 'scanner-addition.txt')).read_bytes()
needle = b'HISTORICAL_DIAGNOSTIC_INPUTS = {\n'
assert old.replace(needle, needle + addition, 1) == current, 'exact registration-only source change'
packed = (ROOT / (PREFIX + 'scanner-inputs.json.gz')).read_bytes()
files = {p: base64.b64decode(raw, validate=True) for p, raw in json.loads(gzip.decompress(packed)).items()}
assert len(files) == 8 and all((ROOT / p).read_bytes() == raw for p, raw in files.items())
def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module
before = load(ROOT / (PREFIX + 'scanner-before.py'), 'old_scanner')
after = load(ROOT / SOURCE, 'current_scanner')
rows = []
with tempfile.TemporaryDirectory(prefix='scanner-registration-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(raw)
    before.ROOT = after.ROOT = supplied
    positive, classified = before.scan_files(sorted(files))
    assert len(positive) == 14
    original = {'positive': positive, 'classified': classified}
    positive, classified = after.scan_files(sorted(files))
    assert positive == [] and classified == original['classified'] + 14
    repaired = {'positive': positive, 'classified': classified}
    for path, raw in sorted(files.items()):
        destination = supplied / path
        for name in ('copied-path', 'changed-byte', 'added-selector'):
            copy = supplied / ('copy-' + Path(path).name)
            try:
                if name == 'copied-path':
                    copy.write_bytes(raw)
                    selected = copy.relative_to(supplied).as_posix()
                else:
                    selected = path
                    destination.write_bytes(raw + (b'\n' if name == 'changed-byte' else b'\n' + b'array' + b'(new_probe);\n'))
                positives, classified = after.scan_files([selected])
                assert positives, (path, name)
                rows.append({'path': path, 'name': name, 'positive': positives, 'classified': classified})
            finally:
                destination.write_bytes(raw)
                copy.unlink(missing_ok=True)
        assert after.scan_files([path])[0] == []
    assert after.scan_files(sorted(files)) == ([], repaired['classified'])
inputs = {path: sha(raw) for path, raw in files.items()}
for path in (SOURCE, PREFIX + 'scanner-before.py', PREFIX + 'scanner.py', PREFIX + 'scanner-addition.txt', PREFIX + 'scanner-inputs.json.gz'):
    inputs[path] = sha((ROOT / path).read_bytes())
target.write_text(json.dumps({'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'inputs': inputs, 'old': original, 'current': repaired, 'rows': rows,
    'scope': 'Existing immutable diagnostic mechanism only, eight exact private/negative source paths/full bytes.14 original positive lines become classified;24 path/byte/new-selector mutations still reject and each restoration passes. Whole scanner source differs only by the retained exact dictionary addition. Full repository scan remains a separate focused/canonical gate.'}, indent=2) + '\n')
print('Scanner registration PASS: eight exact inputs;14 original REDs;24 denials; exact restoration')
