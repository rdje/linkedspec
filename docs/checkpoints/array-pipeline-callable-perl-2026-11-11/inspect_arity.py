"""Inspect original own policies and terminal/with discriminators, read-only."""
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
cases = json.loads((BASE / 'arity-cases.json').read_bytes())
rows = {}
for line in gzip.decompress((BASE / 'arity/observer-stdout.log.gz').read_bytes()).decode().splitlines():
    if line.startswith('ARRAY_PIPELINE_CALLABLE_PERL_PERL '):
        _, key, value = line.split(' ', 2)
        assert key not in rows
        rows[key] = json.loads(value)
assert list(rows) == [case['id'] for case in cases]
for case in cases:
    key = case['id']
    row = rows[key]
    record = dict(id=key, question=case['question'], metadata=row['metadata'], native=row.get('native'),
        native_error=row.get('native_error'), loaded=row['loaded'], fresh=row.get('fresh'),
        fresh_error=row.get('fresh_error'), load_error=row['load_error'], warnings=row['warnings'],
        descriptor_error=row['descriptor_error'], emission_error=row['emission_error'],
        build_error=row['build_error'], substitution_error=row['substitution_error'])
    if case['question'] == 'initial-first-with':
        terminal = rows[key.removesuffix('_with')]
        record['terminal'] = terminal.get('native')
        if isinstance(terminal.get('native'), list) and terminal['native_error'] is None:
            record['terminal_with_oracle'] = [len(terminal['native']), 'W']
    print(json.dumps(record, sort_keys=True))
