"""Select the measured prove-context oracle without changing any prior observation."""
import base64
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'native-oracle-finalization.json')
assert not target.exists()
context = json.loads((ROOT / (PREFIX + 'native-prove-context-before.json')).read_bytes())
assert context['returncode'] == 0 and len(context['include_observations']) == 2
assertions = (ROOT / (PREFIX + 'pipeline-assertions-accepted.pl')).read_bytes()
old = b"'native-context-before.json'"
new = b"'native-prove-context-before.json'"
assert assertions.count(old) == 1
current = assertions.replace(old, new)
fixture = ROOT / 't/actionir_factory_capture.t'
fixture_before = fixture.read_bytes()
old_fixture = b'/pipeline-assertions-accepted.pl"'
new_fixture = b'/pipeline-assertions-current.pl"'
assert fixture_before.count(old_fixture) == 1
fixture_after = fixture_before.replace(old_fixture, new_fixture)
writer_before = (ROOT / (PREFIX + 'capture-red-accepted.py')).read_bytes()
writer_after = writer_before
for old_text, new_text in [
    (b"'red-accepted.json'", b"'red-semantic.json'"),
    (b"'red-accepted-inputs.json.gz'", b"'red-semantic-inputs.json.gz'"),
    (b"'native-context-before.json'", b"'native-prove-context-before.json'"),
    (b"'pipeline-assertions-accepted.pl'", b"'pipeline-assertions-current.pl'"),
    (b"'capture-red-accepted.py'", b"'capture-red-semantic.py'"),
]:
    assert old_text in writer_after
    writer_after = writer_after.replace(old_text, new_text)
record = dict(result='actual prove-context oracle selected; prior native/failure epochs unchanged',
              producer_sha256=sha(Path(__file__).read_bytes()),
              previous_assertion_sha256=sha(assertions), current_assertion_sha256=sha(current),
              original_fixture_base64=encode(fixture_before), current_fixture_sha256=sha(fixture_after),
              previous_writer_sha256=sha(writer_before), current_writer_sha256=sha(writer_after))
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
for name, value in [('pipeline-assertions-current.pl', current), ('capture-red-semantic.py', writer_after)]:
    with (ROOT / (PREFIX + name)).open('xb') as output:
        output.write(value)
fixture.write_bytes(fixture_after)
print('Measured prove-context oracle selected; original captures unchanged')
