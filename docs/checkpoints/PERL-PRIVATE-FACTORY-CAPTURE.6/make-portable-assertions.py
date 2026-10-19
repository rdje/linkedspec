"""Preserve first2060 state; project only expected diagnostic module filenames at runtime."""
import base64
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'portable-assertions.json')
final = ROOT / (PREFIX + 'pipeline-assertions-portable.pl')
assert not target.exists() and not final.exists()
source = ROOT / (PREFIX + 'pipeline-assertions-current.pl')
before = source.read_bytes()
old = b"my $extra_rows = LinkedSpec::PipelineExtraProbe::observations();"
replacement = b'''# Raw historical errors remain immutable. Project only their one known owned
# module filename into the actual current load context; actual errors, source
# membership and original native line numbers must still compare exactly.
require Cwd;
require File::Spec;
my $loaded_pipeline = $INC{'LinkedSpec/ActionIR/RewritePipeline.pm'};
my $owned_pipeline = "$pipeline_proof_dir/../../../perl/LinkedSpec/ActionIR/RewritePipeline.pm";
is(Cwd::abs_path($loaded_pipeline), Cwd::abs_path($owned_pipeline),
 'native diagnostic module is the actual current owned source');
open my $context_input, '<:raw', "$pipeline_proof_dir/native-prove-context-before.json" or die $!;
my $context_record;
{ local $/; $context_record = JSON::PP->new->decode(<$context_input>) }
my $historical_pipeline = substr($context_record->{command}[1], 2).'/LinkedSpec/ActionIR/RewritePipeline.pm';
for my $case (@$native_extra_rows) {
 next unless defined $case->{error};
 my $count = $case->{error} =~ s/\\Q$historical_pipeline\\E/$loaded_pipeline/g;
 is($count, 1, "native expected filename projects exactly once $case->{kind}");
}
my $extra_rows = LinkedSpec::PipelineExtraProbe::observations();'''
assert before.count(old) == 1
after = before.replace(old, replacement)
fixture = ROOT / 't/actionir_factory_capture.t'
fixture_before = fixture.read_bytes()
old_fixture = b'/pipeline-assertions-current.pl"'
new_fixture = b'/pipeline-assertions-portable.pl"'
assert fixture_before.count(old_fixture) == 1
fixture_after = fixture_before.replace(old_fixture, new_fixture)
combined = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.6-composition-first-attempt1.log').read_bytes()
assert re.search(rb'^1\.\.2060\s*$', combined, re.M) and b'Result: PASS' in combined
record = dict(result='expected owned-source filename projection only; raw observations unchanged',
              producer_sha256=sha(Path(__file__).read_bytes()), before_source_base64=encode(before),
              after_source_sha256=sha(after), replacement_before_base64=encode(old),
              replacement_after_base64=encode(replacement), before_fixture_base64=encode(fixture_before),
              after_fixture_sha256=sha(fixture_after),
              composition_source_base64=encode((ROOT / (PREFIX + 'pipeline-composition-assertions.pl')).read_bytes()),
              first_composition_tool_observed_returncode=0, first_composition_combined_base64=encode(combined),
              custody_limit='Actual direct2060 command explicitly merged streams. This metadata retains '
                            'its unchanged immediate post-run helper/test state, not a claimed originally '
                            'serialized pre-run census. The later supplied pre-run proof owns admission.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
with final.open('xb') as output:
    output.write(after)
fixture.write_bytes(fixture_after)
print('First2060 state retained; expected-only module projection is derived and membership-guarded')
