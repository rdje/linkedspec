"""Additive seal for the qualified reader and original failed-reader acquisition."""
import hashlib,json
from pathlib import Path
root=Path.cwd().resolve();base=Path(__file__).resolve().parent
out=base/'observed-version-identities.json';assert not out.exists()
rows={}
for p in sorted(base.rglob('*')):
    if p.is_file() and p.suffix!='.md':
        assert not p.is_symlink() and p.stat().st_dev==root.stat().st_dev
        b=p.read_bytes();rows[p.relative_to(root).as_posix()]=dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
out.write_text(json.dumps(rows,indent=2,sort_keys=True)+'\n')
print('additive observed-version qualification seal written')
