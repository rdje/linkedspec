"""Keep real-factory assertions fixed when a fault removes a capture or source token."""
import base64
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'fault-observer-preparation.json')
assert not target.exists()
original_probe = (ROOT / (PREFIX + 'native-factory-probe.pl')).read_bytes()
current_probe = original_probe
for name in ('producers', 'inputs'):
    old = f"ref(${name}) eq 'HASH' && ref($token)".encode()
    new = f"ref(${name}) eq 'HASH' && ref(${name}->{{source_token}}) && ref($token)".encode()
    assert current_probe.count(old) == 1
    current_probe = current_probe.replace(old, new)
original_assertions = (ROOT / (PREFIX + 'pipeline-composition-assertions.pl')).read_bytes()
current_assertions = original_assertions.replace(b'/native-factory-probe.pl"', b'/native-factory-current-probe.pl"')
old = b'''ok(@{$observed->{canonical_calls}} > 0, 'actual public facade executes canonical callbacks');
for my $call (@{$observed->{canonical_calls}}) {
 for my $key (qw(actual_public_apply registered_actual producer_token input_token actual_origin)) {
  is($call->{$key}, 1, "actual public native $call->{contract} $key");
 }
}'''
new = b'''is(scalar @{$observed->{canonical_calls}}, 1, 'actual public facade executes its one authored canonical callback');
my $actual_public_call = $observed->{canonical_calls}[0] || {};
for my $key (qw(actual_public_apply registered_actual producer_token input_token actual_origin)) {
 is($actual_public_call->{$key}, 1, "actual public native return_general $key");
}'''
assert current_assertions.count(old) == 1
current_assertions = current_assertions.replace(old, new)
fixture = ROOT / 't/actionir_factory_capture.t'
fixture_before = fixture.read_bytes()
old_fixture = b'/pipeline-composition-assertions.pl"'
new_fixture = b'/pipeline-composition-fixed.pl"'
assert fixture_before.count(old_fixture) == 1
fixture_after = fixture_before.replace(old_fixture, new_fixture)
record = dict(result='fixed public one-call/five-field oracle and guarded missing-token observations',
              producer_sha256=sha(Path(__file__).read_bytes()), original_probe_sha256=sha(original_probe),
              current_probe_sha256=sha(current_probe), original_assertions_sha256=sha(original_assertions),
              current_assertions_sha256=sha(current_assertions), original_fixture_base64=encode(fixture_before),
              current_fixture_sha256=sha(fixture_after), public_loop_before_base64=encode(old),
              public_loop_after_base64=encode(new),
              scope='Same2065 assertions on the positive and capture-removal faults. Original native '
                    'factory observation/probe and prior composition sources remain unchanged. '
                    'Actual missing scopes are reported false without uninitialized-token warnings.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
for name, value in [('native-factory-current-probe.pl', current_probe),
                    ('pipeline-composition-fixed.pl', current_assertions)]:
    with (ROOT / (PREFIX + name)).open('xb') as output:
        output.write(value)
fixture.write_bytes(fixture_after)
print('Fixed2065 semantic oracle prepared; original native/composition epochs unchanged')
