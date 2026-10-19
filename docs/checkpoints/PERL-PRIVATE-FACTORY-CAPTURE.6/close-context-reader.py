"""Preserve the reader-context failure and close the oracle before native probes."""
import base64
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'reader-context-repair.json')
final = ROOT / (PREFIX + 'pipeline-assertions-portable-final.pl')
assert not target.exists() and not final.exists()
before = (ROOT / (PREFIX + 'pipeline-assertions-portable.pl')).read_bytes()
old = b'{ local $/; $context_record = JSON::PP->new->decode(<$context_input>) }'
new = old + b'\nclose $context_input or die $!;'
assert before.count(old) == 1
after = before.replace(old, new)
fixture = ROOT / 't/actionir_factory_capture.t'
fixture_before = fixture.read_bytes()
old_fixture = b'/pipeline-assertions-portable.pl"'
new_fixture = b'/pipeline-assertions-portable-final.pl"'
assert fixture_before.count(old_fixture) == 1
fixture_after = fixture_before.replace(old_fixture, new_fixture)
combined = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.6-portable-first-attempt1.log').read_bytes()
assert b'<$context_input> line 1' in combined and b'Failed 1/2065 subtests' in combined
record = dict(result='close only the oracle reader before native diagnostics',
              producer_sha256=sha(Path(__file__).read_bytes()), original_source_base64=encode(before),
              corrected_source_sha256=sha(after), original_fixture_base64=encode(fixture_before),
              corrected_fixture_sha256=sha(fixture_after), replacement_before_base64=encode(old),
              replacement_after_base64=encode(new), tool_observed_returncode=1,
              actual_combined_failure_base64=encode(combined),
              channel_limit='Original checking shell merged stdout/stderr; separate streams unavailable.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
with final.open('xb') as output:
    output.write(after)
fixture.write_bytes(fixture_after)
print('Reader-context failure retained; only explicit close added before native probes')
