"""Apply only the twenty owned assertions and retain their exact inverse."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
PATH = 't/phase0_regression.t'
REVISION = '7289836f28e4873463ad1c50d354d8e66c77af8d'
TABLE = ROOT / 'tests/language-readiness/phase0-value-calibration.json.gz'
before = gzip.decompress((HERE / 'phase0-before.t.gz').read_bytes())
assert subprocess.check_output(['git', 'show', REVISION + ':' + PATH], cwd=ROOT) == before
assert (ROOT / PATH).read_bytes() == before and not TABLE.exists()
cases = json.loads((HERE / 'phase0-oracle-cases.json').read_bytes())
observed = json.loads(gzip.decompress((HERE / 'phase0-values-qualified.json.gz').read_bytes()))
frames = []
for stage, row in observed['commands'].items():
    assert row['exit'] == 0
    frame_raw = base64.b64decode(row['frame']['base64'], validate=True)
    frame = json.loads(frame_raw)
    assert hashlib.sha256(frame_raw).hexdigest() == row['frame']['sha256']
    assert frame['module_sha256'] == observed['methods'][stage]['sha256']
    assert len(frame['rows']) == len(cases) == 20
    for case, actual in zip(cases, frame['rows']):
        assert actual['line'] == case['line'] and actual['observed'] == case['expected']
        assert actual['wrong_value'] != case['expected'] and actual['warning'] != case['expected']
    frames.append(frame['rows'])
assert frames[0] == frames[1], 'callable repair changed a finite Phase0 lowering/value'
after = before.decode()
hunks = []
for case in cases:
    old, new = case['original_assertion'], case['replacement']
    assert after.count(old) == 1 and old != new
    after = after.replace(old, new, 1)
    hunks.append(dict(before=old, after=new))
restored = after
for hunk in hunks:
    assert restored.count(hunk['after']) == 1
    restored = restored.replace(hunk['after'], hunk['before'], 1)
assert restored.encode() == before
data = dict(schema_version=1, owner='TYPE-REFERENCE-BOOK.1.2.23.4.18.1', path=PATH,
            activation_commit=REVISION, before_sha256=hashlib.sha256(before).hexdigest(),
            after_sha256=hashlib.sha256(after.encode()).hexdigest(), hunks=hunks)
raw = gzip.compress(json.dumps(data, sort_keys=True, separators=(',', ':')).encode(), mtime=0)
assert len(raw) <= 32768
TABLE.write_bytes(raw)
(ROOT / PATH).write_text(after)
print(json.dumps(dict(result='calibrated', assertions=len(hunks), table_sha256=hashlib.sha256(raw).hexdigest(),
                      before_sha256=data['before_sha256'], after_sha256=data['after_sha256']), sort_keys=True))
