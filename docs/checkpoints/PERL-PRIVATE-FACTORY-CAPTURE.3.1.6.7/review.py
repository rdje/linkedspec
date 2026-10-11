"""Readonly original-publication preservation and exact diagnostic encoding repair."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DIR = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7/'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7-'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()
for script in (DIR + 'retention.py',):
    result = subprocess.run(['python3', script], cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    assert result.returncode == 0 and not result.stderr, (script, result.returncode, result.stdout, result.stderr)
supplied = json.loads(read(DIR + 'original-inputs.json'))
original = lambda path: base64.b64decode(supplied[path]['base64'], validate=True)
path = PREFIX + 'book-correction.json'
expected = json.loads(original(path))
raw = expected['observed_tool_return'].pop('output').encode()
expected['observed_tool_return'].update(output_base64=base64.b64encode(raw).decode(),
                                      output_bytes=len(raw), output_sha256=sha(raw))
assert read(path) == (json.dumps(expected, indent=2) + '\n').encode(), 'sole encoded diagnostic repair'
path = PREFIX + 'review.py'
old = b"in correction['observed_tool_return']['output']"
new = b"in base64.b64decode(correction['observed_tool_return']['output_base64']).decode()"
assert original(path).count(old) == 1
assert read(path) == original(path).replace(old, new, 1), 'sole diagnostic reader repair'
path = 'docs/knowledge/guarded-ast-change-history-capacity.md'
old = b'; separately publish-claim.py under that wrapper.'
new = ('; separately ' + DIR + 'publish.py under that wrapper. The original369-input first publication '
       'is preserved under the leaf directory; old publish-claim.py requires its original logical inputs.').encode()
assert original(path).count(old) == 1
assert read(path) == original(path).replace(old, new, 1), 'sole current publisher pointer repair'
failure = json.loads(read(DIR + 'canonical-attempt01.json'))
assert failure['command'] == ['bash', 'tools/run_ci_local.sh'] and failure['observed_exit_code'] == 143
channel = failure['available_log']
log = base64.b64decode(channel['base64'], validate=True)
assert channel['bytes'] == len(log) and channel['sha256'] == sha(log)
assert b'repo-root-path-portability: tracked parent-repository text is not relocation-safe' in log
assert (PREFIX + 'book-correction.json').encode() in log
assert b'doctrines: ALL' not in log and b'[ci] all local checks passed' not in log
print('Portable diagnostic review PASS: exact original369 bindings/full claim, three bounded changes, actual failed canonical limit; no original observation refresh')
