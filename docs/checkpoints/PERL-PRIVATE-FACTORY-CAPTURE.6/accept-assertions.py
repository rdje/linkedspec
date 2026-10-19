"""Retain prior assertion epochs; use actual load context and unchanged event authority."""
import base64
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'assertion-acceptance.json')
final = ROOT / (PREFIX + 'pipeline-assertions-accepted.pl')
assert not target.exists() and not final.exists()
context = json.loads((ROOT / (PREFIX + 'native-context-before.json')).read_bytes())
assert context['returncode'] == 0 and not base64.b64decode(context['stderr_base64'])
before = (ROOT / (PREFIX + 'pipeline-assertions-final.pl')).read_bytes()
replacements = [
    (b"$apply_completed && !$ordinary->{supplied}",
     b"$apply_completed && !$ordinary->{supplied} && !$ordinary->{mutate}"),
    (b"$read_native->('native-extra-before.json')", b"$read_native->('native-context-before.json')"),
]
after = before
for old, new in replacements:
    assert after.count(old) == 1
    after = after.replace(old, new)
fixture = ROOT / 't/actionir_factory_capture.t'
fixture_before = fixture.read_bytes()
old = b'/pipeline-assertions-final.pl"'
new = b'/pipeline-assertions-accepted.pl"'
assert fixture_before.count(old) == 1
fixture_after = fixture_before.replace(old, new)
record = dict(result='native context and unchanged-authority predicate only',
              producer_sha256=sha(Path(__file__).read_bytes()), original_assertion_sha256=sha(before),
              accepted_assertion_sha256=sha(after), original_fixture_base64=encode(fixture_before),
              accepted_fixture_sha256=sha(fixture_after), replacements=[dict(
                  before_base64=encode(old), after_base64=encode(new)) for old, new in replacements])
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
with final.open('xb') as output:
    output.write(after)
fixture.write_bytes(fixture_after)
print('Accepted assertion source retained; both native originals and both valid RED epochs unchanged')
