"""Prepare nine own public trace contrasts using the qualified tagged carrier."""
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
source = (ROOT / 'docs/checkpoints/array-pipeline-callable-lua-2026-11-11/trace_qualified.lua').read_text()
source = (source.replace('2026%-11%-11/traceq/', '2026%-11%-12/trace/')
    .replace('pipeline', 'transform').replace('PIPELINE', 'TRANSFORM').replace('Pipeline', 'Transform'))
assert 'local payloads = json.array({})' in source
assert not (BASE / 'trace.lua').exists()
(BASE / 'trace.lua').write_text(source)
ids = {'take_receiver_hash_guard', 'take_later_with', 'reverse_copy_later_with', 'drop_logical_later_with',
    'source_effect_before_rejection', 'positive_slice_receiver_composed', 'initial_number_composed',
    'own_scalar_bool_receiver_with', 'own_needed_source_take_receiver'}
cases = [row for row in json.loads((BASE / 'cases.json').read_bytes()) if row['id'] in ids]
assert len(cases) == len(ids) == 9
(BASE / 'trace-sources.json').write_text(json.dumps(cases, indent=2) + '\n')
print('Prepared nine source-only Lua public traces with tagged compiled payload projections; no production edit')
