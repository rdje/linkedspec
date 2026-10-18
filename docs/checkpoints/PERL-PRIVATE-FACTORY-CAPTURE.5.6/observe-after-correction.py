"""Retain the exact failed reader, then execute a separately named correction."""
import base64
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/'
FAILED = PREFIX + 'observe-after.py'
CORRECTED = PREFIX + 'observe-after-corrected.py'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'observe-after-correction.json')
assert not target.exists(), 'one-shot failed/corrected reader capture'
assert not (ROOT / (PREFIX + 'after-native.json')).exists()
original = (ROOT / FAILED).read_bytes()
assert original.count(b"PREFIX+'after.json'") == 1
native = json.loads(gzip.decompress((ROOT / (PREFIX + 'before-complete-native-inputs.json.gz')).read_bytes()))
paths = set(native) | {FAILED, PREFIX + 'complete-after.json', PREFIX + 'before-complete-native.json',
    PREFIX + 'before-complete-native-data.json.gz', PREFIX + 'before-complete-native-inputs.json.gz',
    PREFIX + 'observe-after-correction.py'}
capsule = {}
for path in sorted(paths):
    source = ROOT / path
    raw = source.read_bytes()
    capsule[path] = {'sha256': sha(raw), 'mode': source.stat().st_mode & 0o7777,
                     'bytes_base64': encode(raw)}
capsule_path = ROOT / (PREFIX + 'observe-after-failure-inputs.json.gz')
with capsule_path.open('xb') as output:
    output.write(gzip.compress(json.dumps(capsule, sort_keys=True).encode(), mtime=0))


def invoke(path):
    command = [sys.executable, path]
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    return {'command': command, 'returncode': result.returncode,
            'stdout_base64': encode(result.stdout), 'stderr_base64': encode(result.stderr)}


failed = invoke(FAILED)
report = {'result': 'failed-reader-retained', 'producer_sha256': sha(Path(__file__).read_bytes()),
          'original_source_sha256': sha(original), 'original_source_base64': encode(original),
          'capsule_sha256': sha(capsule_path.read_bytes()),
          'missing_input': PREFIX + 'after.json', 'failed': failed}
target.write_text(json.dumps(report, indent=2) + '\n')
assert failed['returncode'] != 0 and not base64.b64decode(failed['stdout_base64'])
assert b"regular parent-owned input" in base64.b64decode(failed['stderr_base64'])
assert b"after.json" in base64.b64decode(failed['stderr_base64'])
assert not (ROOT / (PREFIX + 'after-native.json')).exists(), 'failed preflight performs no native capture'
corrected = original.replace(b"PREFIX+'after.json'", b"PREFIX+'complete-after.json'", 1)
corrected = corrected.replace(b"PREFIX + 'observe-after.py'", b"PREFIX + 'observe-after-corrected.py'", 1)
with (ROOT / CORRECTED).open('xb') as output:
    output.write(corrected)
positive = invoke(CORRECTED)
report.update(result='PASS', corrected_source_sha256=sha(corrected), corrected=positive,
              scope='Original failed reader source/complete available inputs and exact failure channels remain frozen. The first original failure was observed directly; this retained rerun reproduces its same missing-path preflight before native execution. The corrected producer has its own source identity and executes the unchanged native probe. Neither runtime nor fixture changes for this correction.')
target.write_text(json.dumps(report, indent=2) + '\n')
assert positive['returncode'] == 0 and not base64.b64decode(positive['stderr_base64'])
print('After-reader correction PASS: original missing-path failure retained; distinct native capture succeeds')
