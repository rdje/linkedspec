"""Seal the completed original selection, unchanged fixture and first scoped contract."""
import hashlib,json
from pathlib import Path
ROOT=Path.cwd().resolve();BASE=Path(__file__).resolve().parent
out=BASE/'sealed-identities.json';assert not out.exists()
paths=[p for p in BASE.rglob('*') if p.is_file() and p.suffix!='.md']
paths += [ROOT/'tests/fixtures/array_transform_result_guard_cases.json',ROOT/'docs/checkpoints/type-operation-inventory/array-transform-result-guard-composition.md']
rows={}
for path in sorted(set(paths)):
    assert not path.is_symlink() and path.stat().st_dev==ROOT.stat().st_dev
    body=path.read_bytes();rows[path.relative_to(ROOT).as_posix()]=dict(bytes=len(body),sha256=hashlib.sha256(body).hexdigest())
out.write_text(json.dumps(rows,indent=2,sort_keys=True)+'\n')
print('actual original selection inputs/artifacts/instruments/targets/contract sealed')
