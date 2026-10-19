"""Apply the bounded pipeline seams, preserving existing native dispatch line numbers."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
SOURCE = 'perl/LinkedSpec/ActionIR/RewritePipeline.pm'
BASE = '64b66167c2277533c2393899e3754e14a74f0b31'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'implementation.json')
assert not target.exists()
path = ROOT / SOURCE
before = path.read_bytes()
assert before == subprocess.check_output(['git', 'show', BASE + ':' + SOURCE], cwd=ROOT)
red = json.loads((ROOT / (PREFIX + 'red-semantic.json')).read_bytes())
assert red['returncode'] != 0
replacements = [
    (b'use LinkedSpec::ActionIR::SourceOrigins ();\n\n',
     b'use LinkedSpec::ActionIR::SourceOrigins ();\nuse LinkedSpec::ActionIR::SourceEmissions ();\n'),
    (b'  my $lowered_stmt = $rewrite_by_id{$contract_id}{apply}->($source_stmt, $lower_ctx);',
     b'  my $lowered_stmt = do { my $apply = $rewrite_by_id{$contract_id}{apply}; _capture_canonical_apply($apply, sub { $apply->(@_) }, $source_stmt, $lower_ctx) };'),
    (b' my $contracts = $build_action_lowering_contracts->($label);',
     b' my $contracts = LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency($build_action_lowering_contracts, $label);'),
    (b' return LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($code, sub {',
     b' return LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($code, sub { return _with_pipeline_emission_scopes(sub {'),
    (b'  my $ir_diag = $collect_action_helper_ir_nodes->($code, $rewrite_rules);',
     b'  my $ir_diag = LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency($collect_action_helper_ir_nodes, $code, $rewrite_rules);'),
    (b'  my $canonical_ir_diag = $build_canonical_action_ir_events->($label, $code, $ir_diag->{helper_action_ir_events});',
     b'  my $canonical_ir_diag = LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency($build_canonical_action_ir_events, $label, $code, $ir_diag->{helper_action_ir_events});'),
    (b'  my $diag = $find_unresolved_action_helpers->($rewritten, $rewrite_rules);',
     b'  my $diag = LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency($find_unresolved_action_helpers, $rewritten, $rewrite_rules);'),
    (b'  return ($rewritten, $result_diag)\n })\n}',
     b'  return ($rewritten, $result_diag)\n }) })\n}'),
]
after = before
for old, new in replacements:
    assert after.count(old) == 1
    assert old.count(b'\n') == new.count(b'\n')
    after = after.replace(old, new)
helpers = b'''# These helpers follow the original implementation so native callback errors
# retain their existing source lines. The apply call's lexical block fetches
# once and releases an opaque selected callable before the next pipeline phase.
sub _with_pipeline_emission_scopes {
 my ($work) = @_;
 return LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers([], sub {
  return LinkedSpec::ActionIR::SourceEmissions::_with_source_inputs($work)
 })
}

sub _capture_canonical_apply {
 my $callback = shift;
 my $opaque = shift;
 return LinkedSpec::ActionIR::SourceEmissions::_capture_emission(
  ref($callback) eq 'CODE' ? $callback : $opaque, @_)->{value}
}

'''
assert after.endswith(b'1;\n')
after = after[:-3] + helpers + b'1;\n'
assert b'$apply->(@_)' in after.splitlines()[488]
record = dict(result='bounded pipeline implementation', base=BASE, path=SOURCE,
              producer_sha256=sha(Path(__file__).read_bytes()), before_sha256=sha(before),
              after_sha256=sha(after), mode=path.stat().st_mode & 0o7777,
              replacements=[dict(before_base64=encode(old), after_base64=encode(new)) for old, new in replacements],
              helpers_base64=encode(helpers),
              scope='SourceOrigins remains outermost; fresh producer/input scopes precede factories. '
                    'Four actual dependency callbacks and actual canonical apply have separate scalar '
                    'captures. Non-CODE dispatch remains opaque at original line489 with one lookup '
                    'and call-local lifetime. No public map/reference/algorithm/order or mapping changes.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
path.write_bytes(after)
print('Bounded pipeline seams applied; original dispatch line489 retained')
