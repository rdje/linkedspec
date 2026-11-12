"""Prepare activation-exact existing task-epoch and publication-binding instruments."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
ACTIVATION='9f11029e5af9d6168925f532d4c1911637421af3'
OWNER='TYPE-REFERENCE-BOOK.1.2.23.4.32'
OLD=Path('docs/checkpoints/task-headroom-hygiene-2026-11-12')
LUA=Path('docs/checkpoints/array-concat-open-arity-lua-2026-11-12')
assert subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()==ACTIVATION
identities={}
paths=[OLD/name for name in ('capture.py','check_candidate.py','review.py','seal.py','run_review.py')]
paths += [LUA/name for name in ('check_publication_inputs.py','review_publication_inputs.py')]
for path in paths:
    raw=path.read_bytes()
    assert raw==subprocess.check_output(['git','show',ACTIVATION+':'+str(path)])
    image=BASE/('template-'+path.name+'.gz')
    assert not image.exists()
    image.write_bytes(gzip.compress(raw,mtime=0))
    assert gzip.decompress(image.read_bytes())==raw
    text=raw.decode()
    if path.parent==OLD:
        for old,new in (('TYPE-REFERENCE-BOOK.1.2.23.4.29',OWNER),('REPO-HYGIENE','SPEC-FORMAT-TERSE'),('bf01d855bf913a5a839670669d9ad91e9c6314df',ACTIVATION),(str(OLD),str(BASE))):
            if old in text:
                assert text.count(old)==1,(path,old)
                text=text.replace(old,new)
    else:
        text=text.replace('fb613736f68f7d1f90df5ade3c0e73c98160ca3f',ACTIVATION)
        text=text.replace('new Lua operational record','new headroom operational record')
        if path.name=='check_publication_inputs.py':
            start=text.index('targets = [');end=text.index('\nclaims = ',start)
            targets=['docs/tasks/SPEC-FORMAT-TERSE.md','docs/tasks/TYPE-REFERENCE-BOOK.overview.md',
                'docs/linkedspec-book/src/development/documentation-workflow.md','ROADMAP.md','ROADMAP_V2.md',
                'docs/tasks/TYPE-REFERENCE-BOOK.md','CHANGES.md','DEVELOPMENT_NOTES.md','LIVE_ACHIEVEMENT_STATUS.md','MEMORY.md']
            text=text[:start]+'targets = '+repr(targets)+'\n'+text[end:]
    compile(text,path.name,'exec')
    output=BASE/path.name;assert not output.exists();output.write_text(text)
    identities[str(path)]=dict(image=str(image),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest(),mode=path.stat().st_mode&0o777,generated_sha256=hashlib.sha256(text.encode()).hexdigest())
(BASE/'template-identities.json').write_text(json.dumps(identities,indent=2,sort_keys=True)+'\n')
# This retains the already-completed operational result, not new first-use credit.
monitor=Path('.linkedspec-data/push-monitor/20261112T181656.678283Z')
result=json.loads((monitor/'result.json').read_bytes())
assert result['head']==ACTIVATION and result['ahead']==106 and result['estimated_non_thin_pack_bytes']==1352197517
out=BASE/'push-monitor-current';out.mkdir()
for path in sorted(monitor.iterdir()):
    if path.is_file() and path.suffix not in ('.pack','.idx'):
        (out/path.name).write_bytes(path.read_bytes())
print('Prepared existing unpartitioned terse-data epoch and prospective binding query; no migration or shared book edit yet')
