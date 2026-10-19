"""Capture complete accepted/current Knowledge inputs and actual synchronization gate."""
import base64
import gzip
import hashlib
import io
import json
import subprocess
import tarfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE='e953f69a9934c4ab48e643e69c9efaba0cb1d534'
PREFIX='docs/checkpoints/REPO-HYGIENE.19/'
sha=lambda v:hashlib.sha256(v).hexdigest()
target=ROOT/(PREFIX+'knowledge.json');assert not target.exists()
archive=subprocess.check_output(['git','archive',BASE,'--','docs/knowledge','docs/decisions'],cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as stream:
    original={v.name:dict(bytes_base64=base64.b64encode(stream.extractfile(v).read()).decode(),mode=v.mode) for v in stream if v.isfile() and v.name.endswith('.md')}
paths=sorted(p.relative_to(ROOT).as_posix() for d in ('docs/knowledge','docs/decisions') for p in (ROOT/d).rglob('*.md') if p.is_file())
assert set(paths)==set(original) and len(paths)==1487
extra=['KNOWLEDGE_MAP.md','.knowledge_map.conf','knowledge-map/scripts/knowledge_map.conf',
    'knowledge-map/scripts/gen_knowledge_map.sh','knowledge-map/scripts/check_knowledge_map.sh',
    'tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh']
extra+=[PREFIX+n for n in ('knowledge.py','prepare-knowledge.py','prepare-knowledge-final.py',
    'knowledge-preflight.py','knowledge-preflight.json','knowledge-preparation-final.json','warning-review.json')]
current={}
for p in paths+extra:
    source=ROOT/p;value=source.read_bytes()
    current[p]=dict(sha256=sha(value),mode=source.stat().st_mode&0o7777,bytes_base64=base64.b64encode(value).decode())
changed=sorted(p for p in paths if current[p]['bytes_base64']!=original[p]['bytes_base64'])
assert len(changed)==14 and all(p.startswith('docs/knowledge/') for p in changed)
total=sum((ROOT/p).stat().st_size for p in paths if p.startswith('docs/knowledge/'))
assert total==8388524<=8388608
capsule=ROOT/(PREFIX+'knowledge-inputs.json.gz')
with capsule.open('xb') as output:output.write(gzip.compress(json.dumps(dict(original=original,current=current),sort_keys=True).encode(),mtime=0))
command=['bash','knowledge-map/scripts/check_knowledge_map.sh']
run=subprocess.run(command,cwd=ROOT,capture_output=True)
report=dict(base=BASE,producer_sha256=sha(Path(__file__).read_bytes()),capsule_sha256=sha(capsule.read_bytes()),
    markdown=len(paths),changed_cards=changed,knowledge_bytes=total,
    inputs={p:dict(sha256=v['sha256'],mode=v['mode']) for p,v in current.items()},
    command=command,returncode=run.returncode,stdout_base64=base64.b64encode(run.stdout).decode(),stderr_base64=base64.b64encode(run.stderr).decode(),
    scope='Every original/current1487 Markdown byte and original archive/current actual mode is retained separately. Fourteen existing cards change routes; thirteen bodies stay exact and one warning body condenses preserved history/policy with current reported-summary scope and open owner schedule. No card, decision or budget is added. The first oversized header is refused before writes and its original source/actual channels remain retained.')
with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
assert run.returncode==0 and not run.stdout and run.stderr==b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
assert all(sha((ROOT/p).read_bytes())==v['sha256'] for p,v in current.items())
print('Complete retained-review Knowledge PASS:1487 original/current Markdown;14 cards/one body;8388524 bytes')
