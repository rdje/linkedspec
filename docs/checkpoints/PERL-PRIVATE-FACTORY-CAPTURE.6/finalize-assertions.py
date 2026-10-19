"""Retain the first valid RED; fix packet-check population independently of captures."""
import base64
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'assertion-finalization.json')
final = ROOT / (PREFIX + 'pipeline-assertions-final.pl')
writer = ROOT / (PREFIX + 'capture-red-fixed.py')
assert not target.exists() and not final.exists() and not writer.exists()
original = (ROOT / (PREFIX + 'pipeline-assertions.pl')).read_bytes()
start = original.index(b' for my $capture (@{$row->{captures}}) {')
end = original.index(b' my @expected_completed', start)
replacement = b''' my @completed_apply = grep { $_->{role} eq 'apply' } @{$row->{captures}};
 my $apply_completed = grep { $_->[0] eq 'apply' } @{$ordinary->{trace}};
 $apply_completed = 0 if $ordinary->{fail_at} eq 'apply';
 my $publishes = $apply_completed && !$ordinary->{supplied}
  && $ordinary->{outcome} !~ /\\A(?:undefined|empty|same|zero|reference)\\z/;
 is_deeply(@completed_apply ? $completed_apply[0]{packet} : undef, $publishes ? {
  text => 'LOWERED', fragments => [{kind => 'generated', output_span => {start => 0, end => 7}}],
  consumed => [],
 } : undef, "pipeline actual registered factory output versus opaque supplied apply $label");
'''
after = original[:start] + replacement + original[end:]
fixture = ROOT / 't/actionir_factory_capture.t'
fixture_before = fixture.read_bytes()
old = b'/pipeline-assertions.pl"'
new = b'/pipeline-assertions-final.pl"'
assert fixture_before.count(old) == 1
fixture_after = fixture_before.replace(old, new)
capture_before = (ROOT / (PREFIX + 'capture-red-final.py')).read_bytes()
capture_after = capture_before.replace(b"'red-final.json'", b"'red-fixed.json'").replace(
    b"'red-final-inputs.json.gz'", b"'red-fixed-inputs.json.gz'")
record = dict(result='fixed authored packet-check population; original valid RED unchanged',
              producer_sha256=sha(Path(__file__).read_bytes()), original_assertion_sha256=sha(original),
              final_assertion_sha256=sha(after), removed_base64=encode(original[start:end]),
              replacement_base64=encode(replacement), original_fixture_base64=encode(fixture_before),
              final_fixture_sha256=sha(fixture_after), original_capture_sha256=sha(capture_before),
              final_capture_sha256=sha(capture_after))
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
with final.open('xb') as output:
    output.write(after)
fixture.write_bytes(fixture_after)
with writer.open('xb') as output:
    output.write(capture_after)
print('Fixed96-case packet checks retained; original semantic RED and native epochs unchanged')
