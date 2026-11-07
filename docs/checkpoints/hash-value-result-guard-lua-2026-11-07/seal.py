"""Seal completed Lua observations/instruments; mutable SDK/tests use historical archives."""
import hashlib,json
from pathlib import Path
root=Path.cwd().resolve();base=Path(__file__).resolve().parent
assert not (base/'control-owner').exists()
out=base/'sealed-identities.json';assert not out.exists()
paths=[p for p in base.rglob('*') if p.is_file() and p.suffix!='.md']
paths += [root/'tests/fixtures'/name for name in ('hash_value_result_guard_cases.json','hash_value_result_guard_lua_cases.json','hash_value_result_guard_lua_profiles.json')]
rows={}
for p in sorted(set(paths)):
    assert not p.is_symlink() and p.stat().st_dev==root.stat().st_dev
    b=p.read_bytes();rows[p.relative_to(root).as_posix()]=dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
out.write_text(json.dumps(rows,indent=2,sort_keys=True)+'\n')
print('actual Lua inputs/native products/artifacts/instruments/full channels sealed')
