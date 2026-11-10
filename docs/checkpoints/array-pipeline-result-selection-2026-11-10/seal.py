"""Freeze unchanged authored targets and exact first selection inputs once."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
target = ROOT / 'tests/fixtures/array_pipeline_result_guard_cases.json'
assert not target.exists()
target.write_bytes((BASE / 'cases.json').read_bytes())
assert target.read_bytes() == (BASE / 'cases.json').read_bytes()
log = BASE / 'inspection-combined.log.gz'
assert not log.exists()
log.write_bytes(gzip.compress((ROOT / '.linkedspec-data/array-pipeline-selection-inspection.log').read_bytes(), mtime=0))
seal = BASE / 'sealed-identities.json'
assert not seal.exists()
rows = {}
for path in sorted([p for p in BASE.rglob('*') if p.is_file()] + [target]):
    assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    rows[str(path.relative_to(ROOT))] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body))
seal.write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
print('Original36 source/targets, complete acquisition and readonly reader inputs sealed')
