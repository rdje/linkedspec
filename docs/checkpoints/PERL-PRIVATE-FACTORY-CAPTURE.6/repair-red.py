"""Preserve the first harness failure; repair only its runtime root anchor."""
import base64
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'red-repair.json')
final = ROOT / (PREFIX + 'capture-red-final.py')
assert not target.exists() and not final.exists()
fixture = ROOT / 't/actionir_factory_capture.t'
before = fixture.read_bytes()
old = b" my $root = File::Basename::dirname(__FILE__).'/..';"
new = b" require File::Spec;\n my $root = File::Spec->rel2abs(File::Basename::dirname(__FILE__).'/..');"
assert before.count(old) == 1
after = before.replace(old, new)
capture = (ROOT / (PREFIX + 'capture-red.py')).read_bytes()
corrected = capture.replace(b"'red.json'", b"'red-final.json'").replace(
    b"'red-inputs.json.gz'", b"'red-final-inputs.json.gz'")
assert corrected != capture
outer = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.6-red-attempt1.log').read_bytes()
record = dict(result='exact instrument repair; no production change',
              producer_sha256=sha(Path(__file__).read_bytes()), original_fixture_base64=encode(before),
              original_capture_sha256=sha(capture), corrected_capture_sha256=sha(corrected),
              original_fixture_sha256=sha(before), corrected_fixture_sha256=sha(after),
              replacement_before_base64=encode(old), replacement_after_base64=encode(new),
              tool_observed_outer_returncode=1, outer_combined_log_base64=encode(outer),
              outer_channel_limit='The shell explicitly merged stdout/stderr into the retained log; '
                                  'separate outer streams are unavailable. Actual child channels are '
                                  'separate and complete in red.json. No tool envelope is invented.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
fixture.write_bytes(after)
with final.open('xb') as output:
    output.write(corrected)
print('Exact RED harness anchor repair retained; original observations unchanged')
