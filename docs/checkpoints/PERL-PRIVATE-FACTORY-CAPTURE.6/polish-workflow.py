"""Preserve the prepared workflow before tightening spacing and measured-number prose."""
import base64
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
PATH = 'docs/linkedspec-book/src/development/documentation-workflow.md'
sha = lambda value: hashlib.sha256(value).hexdigest()
target = ROOT / (PREFIX + 'workflow-polish.json')
assert not target.exists()
before = (ROOT / PATH).read_bytes()
preparation = json.loads((ROOT / (PREFIX + 'documentation-preparation.json')).read_bytes())
assert sha(before) == preparation['proposed'][PATH]['sha256']
replacements = [
    ('at64b66167c', 'at `64b66167c`'),
    ('remains91 suites and46 test helpers', 'remains 91 suites and 46 test helpers'),
    ('whole603-input/115985-byte publication', 'complete publication (603 inputs, 115,985 bytes)'),
    ('same2065-assertion plan', 'same plan of 2,065 assertions'),
    ('2065 assertions', '2,065 assertions'),
    ('426 byte/mode-retained files', '426 files with saved bytes and permissions'),
    ('91 suites,32235 assertions', '91 suites, 32,235 assertions'),
    ('passes 30394 assertions; the later', 'passes 30,394 assertions; the later'),
]
after = before
for old, new in replacements:
    assert old.encode() in after
    after = after.replace(old.encode(), new.encode())
record = dict(result='spacing and number prose only', producer_sha256=sha(Path(__file__).read_bytes()),
              path=PATH, before_sha256=sha(before), before_base64=base64.b64encode(before).decode(),
              after_sha256=sha(after), replacements=[dict(before=old, after=new) for old, new in replacements])
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
(ROOT / PATH).write_bytes(after)
print('Prepared workflow retained; spacing and measured-number prose polished')
