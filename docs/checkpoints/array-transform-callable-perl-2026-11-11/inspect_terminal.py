"""Recover separate terminal results; report evidence before adjudicating arities."""
import gzip
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
cases = json.loads((HERE / 'terminal-cases.json').read_bytes())
rows, inputs = {}, {}
for line in gzip.decompress((HERE / 'terminal/observer-stdout.log.gz').read_bytes()).decode().splitlines():
    if line.startswith('ARRAY_TRANSFORM_CALLABLE_PERL_PERL '):
        _, key, value = line.split(' ', 2)
        assert key not in rows
        rows[key] = json.loads(value)
    elif line.startswith('ARRAY_TRANSFORM_CALLABLE_PERL_INPUT '):
        _, key, value = line.split(' ', 2)
        assert key not in inputs
        inputs[key] = json.loads(value)
assert set(rows) == set(inputs) == {case['id'] for case in cases}
needed, arity, pairs = {}, {}, 0
for case in cases:
    key, row = case['id'], rows[case['id']]
    assert inputs[key]['source'] == case['source']
    for field, source_field in (('module_input', 'emitted'), ('handler_input', 'handler')):
        artifact, source = row[field], inputs[key][source_field]
        if source is None:
            assert artifact is None
        else:
            raw = source.encode()
            assert gzip.decompress(Path(artifact['path']).read_bytes()) == raw
            assert len(raw) == artifact['bytes'] and hashlib.sha256(raw).hexdigest() == artifact['sha256']
    pairs += row['module_input'] is not None and row['handler_input'] is not None
    if case['question'].startswith('needed-'):
        needed[key] = dict(paired_with=case['paired_with'],
            native_binding_error='binding_kind_mismatch' in json.dumps(row.get('native_error')),
            fresh_binding_error='binding_kind_mismatch' in json.dumps(row.get('fresh_error')),
            ready=row['metadata']['language_agnostic_action_ir_ready'], loaded=row['loaded'])
    else:
        arity[key] = dict(paired_with=case['paired_with'],
            metadata=row['metadata'], native=row.get('native'), native_error=row.get('native_error'),
            loaded=row['loaded'], fresh_present='fresh' in row,
            fresh=row.get('fresh'), fresh_error=row.get('fresh_error'), load_error=row['load_error'])
assert not (HERE / 'terminal-analysis.json').exists()
(HERE / 'terminal-observations.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
(HERE / 'terminal-input-records.json').write_text(json.dumps(inputs, indent=2, sort_keys=True) + '\n')
(HERE / 'terminal-analysis.json').write_text(json.dumps(dict(needed=needed, arity=arity, pairs=pairs), indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(result='PASS', acquisition_only=True, questions=len(cases), actual_source_pairs=pairs,
    needed_questions=len(needed), needed_both_errors=sum(row['native_binding_error'] and row['fresh_binding_error'] for row in needed.values()),
    arity_questions=len(arity), arity_ready=[key for key,row in arity.items() if row['metadata']['language_agnostic_action_ir_ready']==1]), sort_keys=True))
