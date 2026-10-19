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
BASE='858eba97c89239d187765c4af9ad18057d28a1b0'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
target=ROOT/(PREFIX+'knowledge.json');assert not target.exists()
prep=json.loads((ROOT/(PREFIX+'knowledge-preparation-final.json')).read_bytes())
assert prep['result']=='PASS' and prep['knowledge_bytes']==8388024
command=['bash','knowledge-map/scripts/gen_knowledge_map.sh']
generated=subprocess.run(command,cwd=ROOT,capture_output=True)
assert generated.returncode==0 and not generated.stdout
assert generated.stderr==b'knowledge-map: wrote KNOWLEDGE_MAP.md (1349 facts, 10442 question keys)\n'
archive=subprocess.check_output(['git','archive',BASE,'--','docs/knowledge','docs/decisions'],cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as stream:
    original={v.name:dict(bytes_base64=encode(stream.extractfile(v).read()),mode=v.mode) for v in stream if v.isfile() and v.name.endswith('.md')}
paths=sorted(p.relative_to(ROOT).as_posix() for directory in ('docs/knowledge','docs/decisions') for p in (ROOT/directory).rglob('*.md') if p.is_file())
assert set(paths)==set(original) and len(paths)==1487
extra=['KNOWLEDGE_MAP.md','.knowledge_map.conf','knowledge-map/scripts/knowledge_map.conf',
    'knowledge-map/scripts/gen_knowledge_map.sh','knowledge-map/scripts/check_knowledge_map.sh',
    'tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh']
extra += [PREFIX+n for n in ('knowledge.py','prepare-knowledge.py','knowledge-preflight.json',
    'finalize-knowledge.py','knowledge-source-repair.json','prepare-knowledge-final.py',
    'knowledge-preflight-final.json','knowledge-preparation-final.json','inventory.json','selection.json','audit-final.json')]
current={}
for p in paths+extra:
    source=ROOT/p;value=source.read_bytes()
    current[p]=dict(sha256=sha(value),mode=source.stat().st_mode&0o7777,bytes_base64=encode(value))
changed=sorted(p for p in paths if current[p]['bytes_base64']!=original[p]['bytes_base64'])
assert changed==sorted(prep['current']) and len(changed)==15
total=sum((ROOT/p).stat().st_size for p in paths if p.startswith('docs/knowledge/'))
assert total==8388024<=8388608
capsule_raw=gzip.compress(json.dumps(dict(original=original,current=current),sort_keys=True).encode(),mtime=0)
with (ROOT/(PREFIX+'knowledge-inputs.json.gz')).open('xb') as output:output.write(capsule_raw)
gate=['bash','knowledge-map/scripts/check_knowledge_map.sh']
checked=subprocess.run(gate,cwd=ROOT,capture_output=True)
report=dict(result='PASS' if checked.returncode==0 else 'FAIL',base=BASE,
    producer_sha256=sha(Path(__file__).read_bytes()),capsule_sha256=sha(capsule_raw),
    markdown=1487,facts=1349,question_keys=10442,changed_cards=changed,knowledge_bytes=total,
    inputs={p:dict(sha256=v['sha256'],mode=v['mode']) for p,v in current.items()},
    generation=dict(command=command,returncode=generated.returncode,stdout_base64=encode(generated.stdout),stderr_base64=encode(generated.stderr)),
    check=dict(command=gate,returncode=checked.returncode,stdout_base64=encode(checked.stdout),stderr_base64=encode(checked.stderr)),
    scope='All1487 original/current Markdown bytes and original archive/current actual modes remain distinct and retained. Fifteen existing routes/one condensed body retain all original cards; fourteen bodies stay exact. Pure8389286-byte dry run refuses before writes; distinct final writer gives8388024 under unchanged8MiB. No fact/card/decision/budget is added.')
with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
assert checked.returncode==0 and not checked.stdout and checked.stderr==b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
assert all(sha((ROOT/p).read_bytes())==v['sha256'] and (ROOT/p).stat().st_mode&0o7777==v['mode'] for p,v in current.items())
print('Complete fixture Knowledge PASS:1487 Markdown/1349 facts/10442 keys;15 routes/one body;8388024 bytes')
