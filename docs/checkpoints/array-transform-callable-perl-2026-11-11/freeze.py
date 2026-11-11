"""Freeze valid result intents separately from protected observed compatibility."""
import copy
import gzip
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
cases = json.loads((HERE / 'cases.json').read_bytes())
terminal = json.loads((HERE / 'terminal-cases.json').read_bytes())
observed = json.loads((HERE / 'observations.json').read_bytes())
observed.update(json.loads((HERE / 'terminal-observations.json').read_bytes()))
shared = json.loads((HERE / 'analysis.json').read_bytes())
assert len(cases) == 240 and len(terminal) == 48 and len(observed) == 288
assert not (HERE / 'policy-contract.json').exists()
targets = {}
healthy_intents = {}


def intent(case):
    if 'expected_error' in case:
        return dict(kind='needed-error', code=case['expected_error'], ready=True)
    return dict(kind='value', value=copy.deepcopy(case['expected']), ready=True)


for case in cases[:45]:
    if case['id'] in shared['summary']['target']:
        targets[case['id']] = intent(case)
    elif not case.get('profile_only'):
        healthy_intents[case['id']] = intent(case)
for case in cases[45:]:
    key, question = case['id'], case['question']
    if question in ('needed-source-error', 'needed-operand-error'):
        desired = dict(kind='needed-error', code='binding_kind_mismatch', identifier='items', ready=True)
        (targets if '_receiver' in key else healthy_intents)[key] = desired
    elif question == 'optional-default-composed':
        desired = dict(kind='value', value=[None, 'S'], ready=True)
        (targets if '_receiver_' in key else healthy_intents)[key] = desired
    elif question == 'signature-valid':
        if case['form'] == 'composed':
            targets[key] = dict(kind='value', value=[None, 'S' if 'multi' in key else ''], ready=True)
        else:
            healthy_intents[key] = dict(kind='value', value=[[' head '], 'S'] if 'multi' in key else [[], ''], ready=True)
    elif question == 'source-before-rejection':
        targets[key] = dict(kind='value', value=[None, 'S'], ready=True)
for case in terminal:
    if case['question'].startswith('needed-'):
        healthy_intents[case['id']] = dict(kind='needed-error', code='binding_kind_mismatch', identifier='items', ready=True)
assert len(targets) == 35 and not set(targets) & set(healthy_intents)


def matches(row, desired):
    m = row['metadata']
    if m['language_agnostic_action_ir_ready'] != 1 or any(m[name] != 0 for name in
        ('raw_perl_dependency_count', 'canonical_action_ir_fallback_count', 'unresolved_helper_count')) or m['unresolved_helpers']:
        return False
    for route, usable in (('native', 'native_callable'), ('fresh', 'loaded')):
        if row.get(usable) != 1 or route not in row:
            return False
        error = row.get(route + '_error')
        if desired['kind'] == 'value':
            if error or json.dumps(row[route], sort_keys=True) != json.dumps(desired['value'], sort_keys=True):
                return False
        else:
            text = json.dumps(error, sort_keys=True)
            if not error or desired['code'] not in text or (desired.get('identifier') and 'identifier=' + desired['identifier'] not in text):
                return False
    return True


assert all(not matches(observed[key], desired) for key, desired in targets.items()), 'target unexpectedly healthy: inspect before freezing'
assert all(matches(observed[key], desired) for key, desired in healthy_intents.items()), 'healthy intent fails: inspect before freezing'
protected = sorted(set(observed) - set(targets))
assert len(protected) == 253
record = dict(targets=targets, healthy_intents=healthy_intents, protected_records=protected,
    metadata_fields=sorted(next(iter(observed.values()))['metadata']),
    policy='Protected observed compatibility is not semantic PASS or a portable input/invalid-signature policy. Preserve complete raw records; later code-artifact identities may change under declared lowering fixes.',
    invalid_receiver_shapes='Excluded take/sorted ready-null folds remain protected; the unactivated strict-marker proposal is superseded by signature inventory1.2.1.4.3.',
    open_concat='Existing helper signature is [1,unbounded], but frozen78.6 result guards select free-two/receiver-one. Selection23.1.42 owns wider continuations; no extra-input-kind authority here.',
    next='Clean intake commit, then78.6.1.2 fresh acquisition/positive source-once/operand-order controls before any production edit; split a demonstrated producer prerequisite if needed.')
(HERE / 'policy-contract.json').write_text(json.dumps(record, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(result='PASS', result_targets=len(targets), healthy_intents=len(healthy_intents),
    protected_observations=len(protected), questions=len(observed), no_production_change=True), sort_keys=True))
