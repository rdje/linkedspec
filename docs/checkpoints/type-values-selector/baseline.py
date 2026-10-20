"""Measure the actual default readonly publisher before the selector admission repair."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-selector/'
saved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
assert c.read(c.CLAIM) == saved['original_claim'] and c.unchanged(saved['before'])
assert all(all(c.read(path)[key] == item[key] for key in ('sha256', 'mode'))
           for path, item in saved['inputs'].items())
run = c.run(['bash', 'tools/run_python_project_data.sh', c.PREFIX + 'publish.py'])
unchanged = c.read(c.CLAIM) == saved['original_claim'] and all(
    all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')) for path, item in saved['inputs'].items())
c.write_new(P + 'baseline.json', dict(run=run, claim=saved['original_claim'],
    inputs=saved['inputs'], inputs_bytes_modes_unchanged=unchanged, producer=c.read(P + 'baseline.py')))
assert run['returncode'] == 0 and unchanged
print('Actual default readonly837 baseline PASS; complete bytes/modes unchanged')
