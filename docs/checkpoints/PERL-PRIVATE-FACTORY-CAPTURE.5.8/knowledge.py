"""Capture the complete original/current Knowledge populations and actual gate."""
import base64
import gzip
import hashlib
import io
import json
import subprocess
import tarfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE='54bb5eb65178a57ac6e61e53324c9291863e716d'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.8/'
sha=lambda v:hashlib.sha256(v).hexdigest()
target=ROOT/(PREFIX+'knowledge.json');assert not target.exists()
archive=subprocess.check_output(['git','archive',BASE,'--','docs/knowledge','docs/decisions'],cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as stream:
    original={v.name:dict(bytes_base64=base64.b64encode(stream.extractfile(v).read()).decode(),mode=v.mode) for v in stream if v.isfile() and v.name.endswith('.md')}
paths=sorted(p.relative_to(ROOT).as_posix() for directory in ('docs/knowledge','docs/decisions') for p in (ROOT/directory).rglob('*.md') if p.is_file())
assert len(original)==1486 and len(paths)==1487
assert set(paths)-set(original)=={'docs/decisions/0136-finite-continuity-capacity.md'} and not set(original)-set(paths)
current={}
extra=['KNOWLEDGE_MAP.md','.knowledge_map.conf','knowledge-map/scripts/knowledge_map.conf',
    'knowledge-map/scripts/gen_knowledge_map.sh','knowledge-map/scripts/check_knowledge_map.sh',
    'tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh',
    PREFIX+'knowledge.py',PREFIX+'prepare-knowledge.py',PREFIX+'knowledge-preparation.json']
for p in paths+extra:
    source=ROOT/p;value=source.read_bytes()
    current[p]=dict(sha256=sha(value),mode=source.stat().st_mode&0o7777,bytes_base64=base64.b64encode(value).decode())
changed=[p for p in paths if p.startswith('docs/knowledge/') and current[p]['bytes_base64']!=original[p]['bytes_base64']]
assert len(changed)==13
knowledge_bytes=sum((ROOT/p).stat().st_size for p in paths if p.startswith('docs/knowledge/'))
assert knowledge_bytes==8388337<=8388608
capsule=ROOT/(PREFIX+'knowledge-inputs.json.gz')
with capsule.open('xb') as output:output.write(gzip.compress(json.dumps(dict(original=original,current=current),sort_keys=True).encode(),mtime=0))
command=['bash','knowledge-map/scripts/check_knowledge_map.sh']
run=subprocess.run(command,cwd=ROOT,capture_output=True)
record=dict(base=BASE,producer_sha256=sha(Path(__file__).read_bytes()),capsule_sha256=sha(capsule.read_bytes()),
    markdown=len(paths),original_markdown=len(original),changed_cards=changed,knowledge_bytes=knowledge_bytes,
    inputs={p:dict(sha256=v['sha256'],mode=v['mode']) for p,v in current.items()},
    command=command,returncode=run.returncode,stdout_base64=base64.b64encode(run.stdout).decode(),stderr_base64=base64.b64encode(run.stderr).decode(),
    scope='Full original1486/current1487 Markdown populations and all actual gate inputs. Thirteen existing cards change routes; twelve bodies remain exact and one finite-history body condenses whole preserved accounts. One sole ADR is added; fact count/budget stay unchanged. Actual filesystem modes are distinct from accepted archive modes. No prior runtime observation is refreshed.')
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
assert run.returncode==0 and not run.stdout and run.stderr==b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
assert all(sha((ROOT/p).read_bytes())==v['sha256'] for p,v in current.items())
print('Complete Knowledge PASS:1486 original/1487 current Markdown;13 cards/one body;8388337 bytes')
