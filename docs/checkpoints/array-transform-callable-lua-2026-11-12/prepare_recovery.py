"""Prepare unused readonly/retirement instruments; never replay completed SDK epochs."""
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
OLD = ROOT / 'docs/checkpoints/array-pipeline-callable-lua-2026-11-11'
for name in ('check_current.py', 'capture_current.py', 'seal.py'):
    target = BASE / name
    assert not target.exists()
    source = (OLD / name).read_text().replace('9a6b229ce3f944ef3822e71935b1c40c109f74b9', 'fff959ef7e8896b5b97f311a276cabc4f5034551').replace('traceq/', 'trace/')
    target.write_text(source)
launches = sorted(path.name for path in (BASE / 'launches').iterdir())
assert launches and all((BASE / 'launches' / name / 'exit.txt').read_text() == '0\n' for name in launches)
(BASE / 'completed-launches.json').write_text(json.dumps(launches, indent=2) + '\n')
print('Prepared independent current/seal inputs and finite completed-launch list')
