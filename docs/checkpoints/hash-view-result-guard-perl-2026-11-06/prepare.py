"""Author the finite normal and independent Perl profile acquisition inputs."""
import json
from pathlib import Path

BASE = Path('docs/checkpoints/hash-view-result-guard-perl-2026-11-06')
normal = Path('t/hash_view_result_guard_composition.t')
assert not normal.exists(), 'one-shot normal preparation'
source = Path('t/copy_result_guard_composition.t').read_text()
source = source.replace('COPY_RESULT', 'HASH_VIEW_RESULT').replace('CopyResult', 'HashViewResult')
source = source.replace('copy-result-guard-composition.spec', 'hash-view-result-guard-composition.spec')
source = source.replace('tests/fixtures/copy_result_guard_cases.json tests/fixtures/copy_result_guard_perl_preservation_cases.json',
                        'tests/fixtures/hash_view_result_guard_cases.json')
source = source.replace('    my $descriptor = eval {', '''    $result{substitution} = eval { LinkedSpec::call_spec_handler_subst($case->{rule}, $case->{body}) };
    $result{substitution_error} = error_value($@);
    my $descriptor = eval {''')
normal.write_text(source)
observer = (Path('docs/checkpoints/hash-view-selection-2026-11-06') / 'observer.pl').read_text()
observer = observer.replace('hash-view-selection.spec', 'hash-view-result-profiles.spec')
observer = observer.replace('HashViewSelectionProbe', 'HashViewResultProfile')
(BASE / 'observe_profiles.pl').write_text(observer)
original = json.loads(Path('docs/checkpoints/hash-view-selection-2026-11-06/cases.json').read_text())
rows = [next(row for row in original if row['id'] == 'arity_profile')]
for identifier, body in (
    ('values_scalar_null_profile', 'return([sorted_values(3),sorted_values("3"),sorted_values(undef),sorted_values(length("abc")).count()])'),
    ('keys_null_profile', 'return([sorted_keys(undef),sorted_keys(undef).count()])'),
    ('values_array_error_profile', 'return(sorted_values([1]))'),
    ('free_values_arity_profile', 'order="";out=sorted_values({"a":1},{order=cat(order,"A");0}).with(){order=cat(order,"W");return("ran")};return([out,order])'),
):
    rows.append(dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
                     input='x', rule='Value', profile_only=True))
(BASE / 'profiles.json').write_text(json.dumps(rows, indent=2) + '\n')
print('Shared15 normal and five independent Perl source/arity profiles prepared')
