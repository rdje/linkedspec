"""One-shot header-only current routes and complete Knowledge input custody."""
import base64
import gzip
import hashlib
import io
import json
import re
import subprocess
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'e2ec1e96bc47633599f0935ed6828c1a0b99e40a'
PREFIX = 'docs/checkpoints/REPO-HYGIENE.18-'
CHAPTER = 'docs/linkedspec-book/src/development/documentation-workflow.md'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
target = ROOT / (PREFIX+'route.json')
assert not target.exists()
archive = subprocess.check_output(['git','archive',BASE,'--','docs/knowledge','docs/decisions'],cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as source:
    original = {item.name: {'bytes_base64':base64.b64encode(source.extractfile(item).read()).decode(), 'mode':item.mode}
                for item in source if item.isfile() and item.name.endswith('.md')}
freeze = json.loads((ROOT/(PREFIX+'preservation.json')).read_bytes())
cards = sorted(path for path in freeze['selected'][0]['intersections'][0]['paths'] if path.startswith('docs/knowledge/'))
assert len(cards) == 11
route = ('Readonly current custody/retention review: bash tools/run_python_project_data.sh '
         'docs/checkpoints/REPO-HYGIENE.18-claim.py. Complete finite admission507/full117862 '
         'and earlier evidence remain at e2ec1e96b. Capture writers stay retired.')
for path in cards:
    p=ROOT/path
    old=base64.b64decode(original[path]['bytes_base64'],validate=True)
    assert p.read_bytes() == old
    header,body=old.split(b'\n---\n',1)
    updated,count=re.subn(rb'^reverify: .*$', ('reverify: '+json.dumps(route)).encode(), header, flags=re.M)
    assert count == 1
    p.write_bytes(updated+b'\n---\n'+body)
old_chapter = subprocess.check_output(['git','show',BASE+':'+CHAPTER],cwd=ROOT)
assert (ROOT/CHAPTER).read_bytes() == old_chapter
old = b'''The current verification entrypoint checks the finite engineering-history
admission in ADR0135, preserves the complete accepted single-statement callback
publication and its earlier evidence, and validates current Knowledge routing
and the complete book. It admits one measured archive member and exact manifest
and sole decision/index overhead. Existing root and aggregate budgets stay fixed;
no future archive reserve follows:

```bash
bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3/publish.py
```'''
new = b'''The current verification entrypoint checks the dated retained artifact review
and current Knowledge routing and book inputs. It preserves the complete finite
engineering-history publication at `e2ec1e96b`, including its accepted
single-statement callback evidence. ADR0135 admits one measured archive member
and exact manifest and sole decision/index overhead. Existing root and aggregate
budgets stay fixed; no future archive reserve follows:

```bash
bash tools/run_python_project_data.sh docs/checkpoints/REPO-HYGIENE.18-claim.py
```'''
assert old_chapter.count(old) == 1
(ROOT/CHAPTER).write_bytes(old_chapter.replace(old,new,1))
commands=[]
for command in (['bash','knowledge-map/scripts/gen_knowledge_map.sh'],['bash','knowledge-map/scripts/check_knowledge_map.sh']):
    p=subprocess.run(command,cwd=ROOT,capture_output=True)
    row=dict(command=command,returncode=p.returncode,stdout_base64=base64.b64encode(p.stdout).decode(),stderr_base64=base64.b64encode(p.stderr).decode())
    commands.append(row)
    assert p.returncode == 0, row
paths=sorted(p.relative_to(ROOT).as_posix() for d in ('docs/knowledge','docs/decisions') for p in (ROOT/d).rglob('*.md') if p.is_file())
assert set(paths) == set(original) and len(paths) == 1486
extra=['KNOWLEDGE_MAP.md','.knowledge_map.conf','knowledge-map/scripts/knowledge_map.conf',
       'knowledge-map/scripts/gen_knowledge_map.sh','knowledge-map/scripts/check_knowledge_map.sh',
       'tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh',PREFIX+'route.py',CHAPTER]
current={}
for path in paths+extra:
    p=ROOT/path
    assert p.is_file() and not p.is_symlink()
    raw=p.read_bytes()
    current[path]=dict(sha256=sha(raw),mode=p.stat().st_mode&0o7777,bytes_base64=base64.b64encode(raw).decode())
changed=[p for p in paths if current[p]['bytes_base64'] != original[p]['bytes_base64']]
assert sorted(changed) == cards
capsule=ROOT/(PREFIX+'knowledge-inputs.json.gz')
with capsule.open('xb') as f:f.write(gzip.compress(json.dumps(dict(original=original,current=current),sort_keys=True).encode(),mtime=0))
report=dict(base=BASE,producer_sha256=sha(Path(__file__).read_bytes()),capsule_sha256=sha(capsule.read_bytes()),
            markdown=len(paths),cards=cards,route=route,commands=commands,
            chapter_old_base64=base64.b64encode(old).decode(),chapter_new_base64=base64.b64encode(new).decode(),
            inputs={p:dict(sha256=i['sha256'],mode=i['mode']) for p,i in current.items()},
            scope='Complete original/current1486 Markdown bytes/modes; eleven reverify-header-only changes, exact original bodies and all other Markdown unchanged. Original full headers/bytes remain at accepted Git and in capsule. Derived map/gate actual channels retained. Book changes only its current entrypoint paragraph; no new structural fact or retention/runtime behavior.')
with target.open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print('Current Knowledge routes PASS:1486 Markdown inputs; eleven header-only overlays; complete custody')
