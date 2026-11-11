"""Freeze finite preproduction observations; keep arity defects out of policy."""
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
META = dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0,
    canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])


def frames(phase):
    rows = {}
    for line in gzip.decompress((BASE / phase / 'observer-stdout.log.gz').read_bytes()).decode().splitlines():
        if line.startswith('ARRAY_PIPELINE_CALLABLE_PERL_PERL '):
            _, key, value = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(value)
    return rows


def binding_error(row):
    return row['loaded'] == 1 and all(isinstance(row.get(route + '_error'), dict)
        and 'binding_kind_mismatch' in row[route + '_error'].get('detail', '') for route in ('native', 'fresh'))


cases = json.loads((BASE / 'cases.json').read_bytes())
arity_cases = json.loads((BASE / 'arity-cases.json').read_bytes())
rows, arity = frames('intake'), frames('arity')
assert list(rows) == [case['id'] for case in cases] and len(cases) == 178
assert list(arity) == [case['id'] for case in arity_cases] and len(arity_cases) == 18
roles, valid_targets, first_with = {}, [], []
for index, case in enumerate(cases):
    key, row = case['id'], rows[case['id']]
    if index < 41:
        if case.get('expected_regex_error'):
            marker = case['expected_regex_error']
            valid = isinstance(row.get('native_error'), dict) and marker in row['native_error'].get('detail', '')
            valid = valid and (marker in (row.get('load_error') or '') or marker in (row.get('fresh_error') or {}).get('detail', ''))
        elif case.get('expected_error'):
            valid = binding_error(row)
        elif case.get('profile_only'):
            valid = row['loaded'] == 1 and row['native_error'] is None and row['fresh_error'] is None
            valid = valid and row['native'] == row['fresh'] == [[], []]
        else:
            valid = row['loaded'] == 1 and all(row.get(route + '_error') is None and row.get(route) == case['expected'] for route in ('native', 'fresh'))
        role = 'supported-target' if not valid or row['metadata'] != META else 'preservation'
    else:
        question = case['question']
        if question == 'excluded-helper-arity':
            role = 'arity-prerequisite-observation'
        elif question.startswith('function-arity-'):
            assert row['metadata']['language_agnostic_action_ir_ready'] == 0
            assert row['native'] == row['fresh'] == [None, '']
            role = 'function-signature-fence'
        elif question == 'initial-first-with':
            terminal = rows[key.removesuffix('_with')]
            assert terminal['loaded'] == 1 and terminal['native_error'] is None
            assert terminal['native'] == terminal['fresh'] == []
            assert row['metadata'] == META and row['native'] == row['fresh'] == [0, 'W']
            first_with.append(key)
            role = 'preservation'
        elif question in ('needed-source-error', 'needed-delimiter-error'):
            role = 'supported-target' if not binding_error(row) or row['metadata'] != META else 'preservation'
        elif question == 'source-before-rejection':
            role = 'supported-target'
            assert row['native'] == row['fresh'] == ['ran', 'W'] and row['metadata'] != META
        elif question == 'pattern-source-composed':
            terminal = rows[key.removesuffix('_composed') + '_terminal']
            assert terminal['metadata'] == META and terminal['native_error'] is None
            assert terminal['native'] == terminal['fresh'] and terminal['native'][1] == ''
            # Preserve producer normalization, never infer eager block/variable patterns.
            assert row['native'] == row['fresh'] == [None, ''] and row['metadata'] != META
            role = 'pattern-producer-boundary'
        else:
            role = 'preservation'
    roles[key] = role
    if role == 'supported-target':
        valid_targets.append(key)
assert len(first_with) == 42
leaks = {}
for phase, population in (('intake', rows), ('arity', arity)):
    found = []
    for key, row in population.items():
        errors = [str(row.get('native_error')), str(row.get('fresh_error')), str(row.get('load_error'))]
        if any('Undefined subroutine' in error and '__array_value_' in error for error in errors):
            found.append(key)
    leaks[phase] = found
assert leaks['intake'], 'retain and own the observed malformed-arity defect'
packet = dict(original_cases=cases, arity_cases=arity_cases, observations=rows,
    arity_observations=arity, roles=roles, supported_targets=valid_targets,
    first_with_preserved=first_with, undefined_private_helper_failures=leaks,
    limits='Arity prerequisite observations and nonliteral-pattern producer boundaries are not accepted producer policies or new pattern authority. No production changes; full native/cache/transitive/toolchain custody remains4.2/SESSION5.')
target = BASE / 'classification.json'
assert not target.exists()
target.write_text(json.dumps(packet, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(programs=178, arity_discriminators=18, first_with_preserved=len(first_with),
    supported_targets=valid_targets, role_counts={role: list(roles.values()).count(role) for role in sorted(set(roles.values()))},
    undefined_private_helper_failures=leaks, source='unchanged'), indent=2))
