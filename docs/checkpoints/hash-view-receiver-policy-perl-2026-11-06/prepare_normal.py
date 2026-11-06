"""Freeze own Perl policy targets and prepare a public receiver/source normal."""
import gzip
import json
from pathlib import Path
import re

BASE = Path('docs/checkpoints/hash-view-receiver-policy-perl-2026-11-06')
normal = Path('t/hash_view_receiver_source_policy.t')
assert not normal.exists(), 'one-shot maintained normal preparation'
rows = {}
for line in gzip.decompress((BASE / 'historical/stdout.log.gz').read_bytes()).decode().splitlines():
    match = re.match(r'^HASH_VIEW_POLICY_PERL ([a-z0-9_]+) (.*)$', line)
    if match:
        assert match[1] not in rows
        rows[match[1]] = json.loads(match[2])
cases = json.loads((BASE / 'cases.json').read_bytes())
assert list(rows) == [case['id'] for case in cases]
for case in cases:
    row = rows[case['id']]
    assert row['native_callable'] == row['loaded'] == 1 and not row['warnings']
    case['cursors'] = {route: row[route + '_cursor'] for route in ('native', 'fresh')}
    if row['native_error']:
        assert all('Not a HASH reference' in row[route + '_error']['detail'] for route in ('native', 'fresh'))
        case['expected_error'] = 'Not a HASH reference'
        case['expected_error_meta'] = {route: {key: value for key, value in row[route + '_error'].items() if key != 'detail'} for route in ('native', 'fresh')}
    else:
        assert row['native'] == row['fresh'] and row['fresh_error'] is None
        case['expected'] = row['native']
Path('tests/fixtures/hash_view_receiver_policy_perl_cases.json').write_text(json.dumps(cases, indent=2) + '\n')
seeds = json.loads((BASE / 'seed-cases.json').read_bytes())
for case in seeds:
    case['expected'] = ['a', 'b'] if case['id'] == 'valid_named_hash' else []
Path('tests/fixtures/hash_view_numeric_source_perl_cases.json').write_text(json.dumps(seeds, indent=2) + '\n')
source = Path('t/hash_view_result_guard_composition.t').read_text()
source = source[:source.index('my @cases =')]
source = source.replace('HASH_VIEW_RESULT', 'VIEW_RECEIVER_SOURCE')
source = source.replace('HashViewResultGuardComposition', 'HashViewReceiverSourcePolicy')
source = source.replace('hash-view-result-guard-composition.spec', 'hash-view-receiver-source-policy.spec')
package = "    my $package = 'LinkedSpec::HashViewReceiverSourcePolicy::' . $identifier;\n"
assert source.count(package) == 1
source = source.replace(package, '')
needle = '    if ($result{native_callable}) {'
assert source.count(needle) == 1
setup = r'''    my $package = 'LinkedSpec::HashViewReceiverSourcePolicy::' . $identifier;
    my $state = $case->{seed} // 'empty';
    no strict 'refs';
    local %{'main::3'} = $state eq 'main' ? (host_main => 'MAIN') : ();
    local %{$package . '::3'} = $state eq 'outer' ? (host_outer => 'OUTER') : ();
    $result{host_before} = { main => { %{'main::3'} }, outer => { %{$package . '::3'} } };
'''
source = source.replace(needle, setup + needle)
source = source.replace('    $result{warnings} = \\@warnings;', r'''    $result{host_after} = { main => { %{'main::3'} }, outer => { %{$package . '::3'} } };
    $result{warnings} = \@warnings;''')
source += r'''
sub common {
    my ($actual) = @_;
    ok($actual->{native_callable} && !$actual->{build_error}, 'native parser builds');
    ok($actual->{loaded} && !$actual->{emission_error} && !$actual->{load_error}, 'fresh module loads');
    ok(!$actual->{descriptor_error} && !$actual->{substitution_error}, 'public descriptor/substitution resolve');
    is_deeply($actual->{warnings}, [], 'build/load/execute stay warning-free');
    is_deeply($actual->{metadata}, {
        language_agnostic_action_ir_ready => 1, raw_perl_dependency_count => 0,
        canonical_action_ir_fallback_count => 0, unresolved_helper_count => 0, unresolved_helpers => [],
    }, 'canonical ready without fallback/raw/unresolved');
    is_deeply($actual->{host_after}, $actual->{host_before}, 'localized host values unchanged');
}

for my $case (@{read_json('tests/fixtures/hash_view_receiver_policy_perl_cases.json')}) {
    subtest $case->{id} => sub {
        my $actual = observe($case);
        diag('VIEW_RECEIVER_SOURCE_PERL ' . $case->{id} . ' ' . $json->encode($actual));
        common($actual);
        for my $route (qw(native fresh)) {
            is($actual->{$route . '_cursor'}, $case->{cursors}{$route}, "$route cursor preserved");
            if ($case->{expected_error}) {
                my $error = $actual->{$route . '_error'};
                ok(ref($error) eq 'HASH', "$route needed initial-source error survives");
                if (ref($error) eq 'HASH') {
                    like($error->{detail}, qr/\A\Q$case->{expected_error}\E at /, "$route original error reason");
                    my %metadata = %$error;
                    delete $metadata{detail};
                    is_deeply(\%metadata, $case->{expected_error_meta}{$route}, "$route original error type/stage/code");
                }
            } else {
                is($actual->{$route . '_error'}, undef, "$route no execution error");
                is($json->encode($actual->{$route}), $json->encode($case->{expected}), "$route own original source/result policy");
            }
        }
    };
}
for my $case (@{read_json('tests/fixtures/hash_view_numeric_source_perl_cases.json')}) {
    subtest 'seed_' . $case->{id} => sub {
        for my $state (qw(empty outer main)) {
            my %seeded = (%$case, id => 'seed_' . $case->{id} . '_' . $state, seed => $state);
            my $actual = observe(\%seeded);
            diag('VIEW_RECEIVER_SOURCE_PERL ' . $seeded{id} . ' ' . $json->encode($actual));
            common($actual);
            my $expected_host = {
                main => $state eq 'main' ? { host_main => 'MAIN' } : {},
                outer => $state eq 'outer' ? { host_outer => 'OUTER' } : {},
            };
            is_deeply($actual->{host_before}, $expected_host, "$state actual distinguishing host input");
            for my $route (qw(native fresh)) {
                is($actual->{$route . '_error'}, undef, "$route $state no execution error");
                is($json->encode($actual->{$route}), $json->encode($case->{expected}), "$route $state uses only DSL numeric/Hash source");
                is($actual->{$route . '_cursor'}, 0, "$route $state cursor preserved");
            }
        }
    };
}
done_testing();
'''
normal.write_text(source)
source = Path('docs/checkpoints/hash-view-result-guard-perl-2026-11-06/capture.py').read_text()
source = source.replace("assert phase in ('before', 'after', 'direct', 'profile-before', 'profile-after')", "assert phase in ('before', 'after', 'direct')")
source = source.replace('t/hash_view_result_guard_composition.t', 't/hash_view_receiver_source_policy.t')
source = source.replace("tests += ['t/sorted_values_scalar_isolation.t', 't/copy_result_guard_composition.t',\n              't/constructor_result_composition.t']",
    "tests += ['t/hash_view_result_guard_composition.t', 't/sorted_values_scalar_isolation.t',\n              't/copy_result_guard_composition.t']")
source = source.replace("('capture.py', 'prepare.py', 'observe_profiles.pl', 'profiles.json')",
    "('capture_test.py', 'prepare_normal.py', 'cases.json', 'seed-cases.json')")
needle = "paths += [Path(p) for p in tests]"
assert source.count(needle) == 1
source = source.replace(needle, needle + "\npaths += [Path('tests/fixtures') / name for name in ('hash_view_receiver_policy_perl_cases.json', 'hash_view_numeric_source_perl_cases.json')]")
source = source.replace('LINKEDSPEC_HASH_VIEW_RESULT_CAPTURE', 'LINKEDSPEC_VIEW_RECEIVER_SOURCE_CAPTURE')
(BASE / 'capture_test.py').write_text(source)
print('Own13 policies plus four numeric/valid-Hash seed groups prepared as seventeen maintained tests')
