"""Prepare own public trace contrasts, without changing any used instrument."""
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
old = ROOT / 'docs/checkpoints/array-pipeline-callable-julia-2026-11-11'
def adapt(body):
    return (body.replace('array-pipeline-callable-julia-2026-11-11', 'array-transform-callable-julia-2026-11-12')
        .replace('580fe233a7d0299d177ecbd442ad8ba027bbe6da', '3767c87c7167bdcb29b0092be35bc139520e3509')
        .replace('pipeline', 'transform').replace('PIPELINE', 'TRANSFORM').replace('Pipeline', 'Transform'))
ids = {'take_receiver_hash_guard', 'take_later_with', 'reverse_copy_later_with', 'drop_logical_later_with',
    'source_effect_before_rejection', 'positive_slice_receiver_composed', 'initial_number_composed',
    'own_scalar_bool_receiver_with', 'own_needed_source_take_receiver'}
cases = [row for row in json.loads((BASE / 'cases.json').read_bytes()) if row['id'] in ids]
assert len(cases) == len(ids) == 9
(BASE / 'trace-sources.json').write_text(json.dumps(cases, indent=2) + '\n')
for name in ('trace.jl', 'capture_trace.py'):
    target = BASE / name
    assert not target.exists()
    target.write_text(adapt((old / name).read_text()))
print('Prepared nine source-only public Julia trace contrasts before production')
