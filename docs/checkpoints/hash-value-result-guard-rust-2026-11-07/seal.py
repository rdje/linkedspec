"""Seal completed epochs and instruments once; mutable SDK/test uses archive bytes."""
import hashlib
import json
from pathlib import Path
ROOT=Path.cwd().resolve()
BASE=Path(__file__).resolve().parent
assert not (BASE/'control-owner').exists()
output=BASE/'sealed-identities.json'
assert not output.exists()
paths=[p for p in BASE.rglob('*') if p.is_file() and p.suffix!='.md']
paths += [ROOT/'tests/fixtures'/name for name in ('hash_value_result_guard_cases.json','hash_value_result_guard_rust_profiles.json')]
rows={}
for path in sorted(set(paths)):
    assert path.stat().st_dev==ROOT.stat().st_dev and not path.is_symlink()
    body=path.read_bytes()
    rows[path.relative_to(ROOT).as_posix()]=dict(sha256=hashlib.sha256(body).hexdigest(),bytes=len(body))
output.write_text(json.dumps(rows,indent=2,sort_keys=True)+'\n')
print('sealed completed historical inputs/artifacts/channels/instruments')
