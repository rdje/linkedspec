"""Freeze current producer policies and independently authored result targets."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
PRIOR = Path('docs/checkpoints/array-pipeline-source-perl-2026-11-10')
helpers = ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match')
targets = {h + suffix for h in helpers for suffix in ('_free_hash_guard', '_receiver_hash_guard')}
targets |= {'trim_later_with', 'uniq_copy_later_with', 'lower_logical_later_with'}


def records(path):
    rows = {}
    for line in gzip.decompress(path.read_bytes()).decode().splitlines():
        if line.startswith('ARRAY_PIPELINE_PERL '):
            _, key, value = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(value)
    return rows


cases = json.loads((PRIOR / 'cases.json').read_bytes())
rows = records(PRIOR / 'preservation/stdout.log.gz')
prefix = json.loads((BASE / 'prefix-cases.json').read_bytes())
later = records(BASE / 'prefix_intake/stdout.log.gz')
assert len(cases) == 184 and len(prefix) == 60
assert set(rows).isdisjoint(later)
cases += prefix
rows.update(later)
assert len(rows) == len(cases) == 244
oracle = rows['receiver_needed_delimiter_terminal']
profiles = []
for case in cases:
    key = case['id']
    expected = {k: v for k, v in rows[key].items() if k not in ('substitution', 'module_input', 'handler_input')}
    role = 'result-target' if key in targets else 'preservation'
    if key == 'needed_split_delimiter_receiver':
        role = 'needed-error-target'
        expected = {k: v for k, v in oracle.items() if k not in ('substitution', 'module_input', 'handler_input')}
    profiles.append(dict(case=case, role=role, expected_observation=expected))
fixture = Path('tests/fixtures/array_pipeline_result_guard_perl_cases.json')
assert not fixture.exists()
fixture.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
(BASE / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')

source = Path('t/array_pipeline_source_isolation.t')
raw = source.read_bytes()
(BASE / 'normal-template.gz').write_bytes(gzip.compress(raw, mtime=0))
(BASE / 'normal-template-identity.json').write_text(json.dumps(dict(path=str(source), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest()), indent=2) + '\n')
normal = raw.decode().replace('LINKEDSPEC_ARRAY_PIPELINE_SOURCE_CAPTURE', 'LINKEDSPEC_ARRAY_PIPELINE_COMPOSITION_CAPTURE')
normal = normal.replace('array-pipeline-source-perl-2026-11-10', 'array-pipeline-composition-perl-2026-11-10')
normal = normal.replace('ARRAY_PIPELINE_SOURCE_', 'ARRAY_PIPELINE_COMPOSITION_')
normal = normal.replace('array_pipeline_source_isolation_perl_cases.json', 'array_pipeline_result_guard_perl_cases.json')
old = '''  is($json->encode(projection($row)), $json->encode(normalize_serials($profile->{expected_observation})),
     $profile->{role} eq 'source-repair' ? 'Number source ignores unrelated host Array' : 'acquired source policy preserved');'''
new = '''  if ($profile->{role} eq 'result-target') {
   ok($row->{native_callable} && !$row->{build_error}, 'native result parser builds');
   ok($row->{loaded} && !$row->{load_error}, 'fresh result module loads');
   is($row->{native_error}, undef, 'native result has no handler error');
   is($row->{fresh_error}, undef, 'fresh result has no execution error');
   is($json->encode($row->{native}), $json->encode($case->{expected}), 'native result values and skipped effects');
   is($json->encode($row->{fresh}), $json->encode($case->{expected}), 'fresh result values and skipped effects');
   is_deeply($row->{host_after}, $row->{host_before}, 'host Arrays remain unchanged');
   is_deeply($row->{warnings}, [], 'result build and execution remain warning-free');
   is_deeply($row->{metadata}, {language_agnostic_action_ir_ready=>1, raw_perl_dependency_count=>0,
    canonical_action_ir_fallback_count=>0, unresolved_helper_count=>0, unresolved_helpers=>[]}, 'canonical result eligibility');
  } else {
   my $actual = projection($row);
   my $expected = normalize_serials($profile->{expected_observation});
   if ($case->{id} eq 'invalid_range_receiver_composed') {
    my $ready = {language_agnostic_action_ir_ready=>1, raw_perl_dependency_count=>0,
     canonical_action_ir_fallback_count=>0, unresolved_helper_count=>0, unresolved_helpers=>[]};
    ok($json->encode($actual->{metadata}) eq $json->encode($expected->{metadata})
       || $json->encode($actual->{metadata}) eq $json->encode($ready), 'range-error descriptor retains its acquired or canonical result state');
    $actual->{metadata} = $expected->{metadata};
   }
   is($json->encode($actual), $json->encode($expected),
      $profile->{role} eq 'needed-error-target' ? 'needed delimiter error matches its terminal producer oracle' : 'acquired source and error policy preserved');
  }'''
assert normal.count(old) == 1
normal = normal.replace(old, new)
Path('t/array_pipeline_result_guard_composition.t').write_text(normal)
print('Frozen244 groups:17 value targets,one needed-error target and226 preservation controls')
