"""Capture complete original/current Knowledge and the actual synchronization commands."""
import base64
import gzip
import hashlib
import io
import json
import subprocess
import tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BASE='64b66167c2277533c2393899e3754e14a74f0b31'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
target=ROOT/(PREFIX+'knowledge.json');assert not target.exists()
prep=json.loads((ROOT/(PREFIX+'documentation-preparation.json')).read_bytes())
assert prep['result']=='PASS' and prep['knowledge_bytes']==8384111
command=['bash','knowledge-map/scripts/gen_knowledge_map.sh']
generated=subprocess.run(command,cwd=ROOT,capture_output=True)
assert generated.returncode==0 and not generated.stdout
assert generated.stderr==b'knowledge-map: wrote KNOWLEDGE_MAP.md (1349 facts, 10448 question keys)\n'
archive=subprocess.check_output(['git','archive',BASE,'--','docs/knowledge','docs/decisions'],cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as stream:
    original={v.name:dict(bytes_base64=encode(stream.extractfile(v).read()),mode=v.mode) for v in stream if v.isfile() and v.name.endswith('.md')}
paths=sorted(p.relative_to(ROOT).as_posix() for directory in ('docs/knowledge','docs/decisions') for p in (ROOT/directory).rglob('*.md') if p.is_file())
assert set(paths)==set(original) and len(paths)==1487
extra=['KNOWLEDGE_MAP.md','.knowledge_map.conf','knowledge-map/scripts/knowledge_map.conf',
    'knowledge-map/scripts/gen_knowledge_map.sh','knowledge-map/scripts/check_knowledge_map.sh',
    'tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh']
extra += [PREFIX+n for n in ('knowledge.py','prepare-docs.py','documentation-preflight.json',
    'documentation-preparation.json','polish-workflow.py','workflow-polish.json',
    'prepare-renderers.py','derived-instruments.json','runtime.json','runtime-review-final.json')]
current={}
for p in paths+extra:
    source=ROOT/p;value=source.read_bytes()
    current[p]=dict(sha256=sha(value),mode=source.stat().st_mode&0o7777,bytes_base64=encode(value))
changed=sorted(p for p in paths if current[p]['bytes_base64']!=original[p]['bytes_base64'])
assert changed==sorted(prep['changed_cards']) and len(changed)==15
total=sum((ROOT/p).stat().st_size for p in paths if p.startswith('docs/knowledge/'))
assert total==8384111<=8388608
capsule_raw=gzip.compress(json.dumps(dict(original=original,current=current),sort_keys=True).encode(),mtime=0)
with (ROOT/(PREFIX+'knowledge-inputs.json.gz')).open('xb') as output:output.write(capsule_raw)
gate=['bash','knowledge-map/scripts/check_knowledge_map.sh']
checked=subprocess.run(gate,cwd=ROOT,capture_output=True)
report=dict(result='PASS' if checked.returncode==0 else 'FAIL',base=BASE,
    producer_sha256=sha(Path(__file__).read_bytes()),capsule_sha256=sha(capsule_raw),
    markdown=1487,facts=1349,question_keys=10448,changed_cards=changed,changed_bodies=prep['changed_bodies'],knowledge_bytes=total,
    inputs={p:dict(sha256=v['sha256'],mode=v['mode']) for p,v in current.items()},
    generation=dict(command=command,returncode=generated.returncode,stdout_base64=encode(generated.stdout),stderr_base64=encode(generated.stderr)),
    check=dict(command=gate,returncode=checked.returncode,stdout_base64=encode(checked.stdout),stderr_base64=encode(checked.stderr)),
    scope='All1487 original/current Markdown bytes are retained; original archive modes and current actual filesystem modes stay separate. Fifteen current routes and two bodies preserve every whole original; thirteen bodies stay exact. Pure prewrite budget proof gives8384111 under unchanged8MiB. New pipeline/diagnostic conclusions use existing card IDs; no card file, decision or budget is added.')
with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
assert checked.returncode==0 and not checked.stdout and checked.stderr==b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
assert all(sha((ROOT/p).read_bytes())==v['sha256'] and (ROOT/p).stat().st_mode&0o7777==v['mode'] for p,v in current.items())
print('Complete fixture Knowledge PASS:1487 Markdown/1349 facts/10448 keys;15 routes/two bodies;8384111 bytes')
