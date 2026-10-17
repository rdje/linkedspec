"""One-shot actual distinction between archive, Git and filesystem mode fields."""
import datetime
import gzip
import hashlib
import json
import subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
BASE='e2ec1e96bc47633599f0935ed6828c1a0b99e40a'
PREFIX='docs/checkpoints/REPO-HYGIENE.18-'
sha=lambda b:hashlib.sha256(b).hexdigest()
source=ROOT/(PREFIX+'knowledge-inputs.json.gz')
original=json.loads(gzip.decompress(source.read_bytes()))['original']
entries=subprocess.check_output(['git','ls-tree','-r',BASE,'--','docs/knowledge','docs/decisions'],cwd=ROOT,text=True).splitlines()
modes={p:int(meta.split()[0],8) for meta,p in (line.split('\t') for line in entries)}
rows=[]
for p,item in sorted(original.items()):
    actual=(ROOT/p).stat().st_mode&0o7777
    rows.append(dict(path=p,archive_mode=item['mode'],git_mode=modes[p],filesystem_mode=actual))
claims=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--','docs/claims'],cwd=ROOT,text=True).splitlines()
hits=[]
for p in claims:
    record=json.loads(subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT))
    for i,c in enumerate(record['claims']):
        d=c['durability']
        if d.get('mode')=='live' and any(x['path']=='docs/knowledge/project-root-evidence-filesystem-modes.md' for x in d['inputs']):
            hits.append(dict(path=p,claim_index=i))
report=dict(owner='REPO-HYGIENE.18',base=BASE,at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
            producer_sha256=sha(Path(__file__).read_bytes()),knowledge_capsule_sha256=sha(source.read_bytes()),
            rows=rows,additional_card_live_intersections=hits,
            scope='Dated full1486-row observation. Archive permissions, recorded Git mode and actual filesystem permissions are distinct fields; no chmod. Guard actual permissions against their own captured field, not archive/Git equality. Existing canonical mode card owns this rule.')
target=ROOT/(PREFIX+'mode-census.json.gz')
with target.open('xb') as f:f.write(gzip.compress(json.dumps(report,sort_keys=True).encode(),mtime=0))
assert len(rows)==1486 and not hits
assert all(r['archive_mode']==0o664 and r['git_mode']==0o100644 and r['filesystem_mode']==0o644 for r in rows)
print('Mode representation census PASS:1486 archive0664/Git100644/filesystem0644; no chmod; additional live intersections0')
