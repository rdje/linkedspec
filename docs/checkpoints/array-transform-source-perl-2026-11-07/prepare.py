"""Activate the bounded source repair and author its public regression normal."""
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ACTIVATION = 'df9dc784e368a66f16238caaa41142a649dde4dd'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
task = Path('docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md')
text = task.read_text()
start = text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.78.0`\n')
end = text.index('- ID:', start + 7)
node = text[start:end].replace('Status: `pending`', 'Status: `in_progress`', 1)
node += '''  Activation: Cleandf9dc784e368a66f16238caaa41142a649dde4dd after preflight all10/post-pointer/brief0/clean Git. Existing Knowledge/preflight own37/123/48 and exact eight MethodLowering.pm shortcuts/first source policies govern this repair. Historical source artifacts stay unchanged. Cleanup November7 05:37UTC remains within24h; host memory headroom is ample for serial Perl checks.
  Verification tier: `focused`
  Focused checks: New public host/source normal with own123 profiles and eighteen healthy direct producer controls; original/current private source-image inverse, readonly artifact/source recovery and targeted corruption controls, syntax/book/Knowledge/history/task/memory/diff and mandatory hooks. No broad suite.
  Canonical trigger: Full23.4/final clean push after feature coverage; no global extractor/public authority change.
  Claim verification: none: Finite authored source-isolation and direct preservation controls, no population/performance/full-domain admission measurement.

'''
task.write_text(text[:start] + node + text[end:])

preflight = Path('docs/checkpoints/array-transform-result-perl-2026-11-07')
cases = []
for case in json.loads((preflight / 'host_cases.json').read_text()):
    case = dict(case)
    case.pop('profile_only', None)
    case['expected'] = ['extra'] if 'concat_arrays' in case['id'] else []
    cases.append(case)
excluded = {'take_later_with', 'reverse_copy_later_with', 'sort_logical_later_with'}
for case in json.loads(Path('tests/fixtures/array_transform_result_guard_cases.json').read_text()):
    if not case['id'].endswith('_hash_guard') and case['id'] not in excluded:
        cases.append(case)
assert len(cases) == 66
fixture = Path('tests/fixtures/array_transform_source_isolation_perl_cases.json')
assert not fixture.exists()
fixture.write_text(json.dumps(cases, indent=2) + '\n')

text = Path('t/array_transform_result_guard_composition.t').read_text()
text = text.replace('LINKEDSPEC_ARRAY_TRANSFORM_COMPOSITION_CAPTURE', 'LINKEDSPEC_ARRAY_TRANSFORM_SOURCE_CAPTURE')
text = text.replace('ARRAY_TRANSFORM_COMPOSITION', 'ARRAY_TRANSFORM_SOURCE')
text = text.replace('array-transform-result-perl-2026-11-07', 'array-transform-source-perl-2026-11-07')
text = text.replace('tests/fixtures/array_transform_result_guard_cases.json', str(fixture))
package = "    (my $public_identifier = $identifier) =~ s/^(?:target_|policy_)//;\n    my $package = 'LinkedSpec::ArrayTransformSelectionProbe::' . $public_identifier;\n"
assert text.count(package) == 1
text = text.replace(package, '')
text = text.replace('    if ($result{native_callable}) {', package + '''    no strict 'refs';
    local @{'main::3'} = ($case->{seed} // '') eq 'main' ? ('MAIN', 'TAIL', 'END') : ();
    local @{$package . '::3'} = ($case->{seed} // '') eq 'outer' ? ('OUTER', 'TAIL', 'END') : ();
    $result{host_before} = { main => [@{'main::3'}], outer => [@{$package . '::3'}] };
    if ($result{native_callable}) {''')
text = text.replace('    $result{warnings} = \\@warnings;', "    $result{host_after} = { main => [@{'main::3'}], outer => [@{$package . '::3'}] };\n    $result{warnings} = \\@warnings;")
text = text.replace("        ok(!$actual->{descriptor_error}, 'descriptor resolves');", "        ok(!$actual->{descriptor_error}, 'descriptor resolves');\n        is_deeply($actual->{host_after}, $actual->{host_before}, 'localized host Arrays remain unchanged');")
Path('t/array_transform_source_isolation.t').write_text(text)
print('Source repair activated; authored48 host+18 healthy targets and own123 policy normal')
