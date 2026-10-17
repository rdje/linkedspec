"""One-shot final routes; retain the entire first Knowledge/book input epoch."""
import base64,gzip,hashlib,json,re,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/REPO-HYGIENE.18-'
BASE='e2ec1e96bc47633599f0935ed6828c1a0b99e40a'
CHAPTER='docs/linkedspec-book/src/development/documentation-workflow.md'
MODE_CARD='docs/knowledge/project-root-evidence-filesystem-modes.md'
sha=lambda b:hashlib.sha256(b).hexdigest()
decode=lambda b:base64.b64decode(b,validate=True)
target=ROOT/(PREFIX+'route-final.json')
assert not target.exists()
first_raw=(ROOT/(PREFIX+'knowledge-inputs.json.gz')).read_bytes()
first=json.loads(gzip.decompress(first_raw))
previous=json.loads((ROOT/(PREFIX+'route.json')).read_bytes())
assert sha(first_raw)==previous['capsule_sha256']
for p,item in first['current'].items():
    assert (ROOT/p).read_bytes()==decode(item['bytes_base64'])
    assert (ROOT/p).stat().st_mode&0o7777==item['mode']
mode_raw=(ROOT/(PREFIX+'mode-census.json.gz')).read_bytes()
modes=json.loads(gzip.decompress(mode_raw))
assert modes['base']==BASE and len(modes['rows'])==1486 and not modes['additional_card_live_intersections']
route='Readonly: bash tools/run_python_project_data.sh docs/checkpoints/REPO-HYGIENE.18-final-claim.py. Complete prior507/full117862 remain at e2ec1e96b; dated captures stay retired.'
updates={}
for p in previous['cards']:
    old=(ROOT/p).read_bytes();header,body=old.split(b'\n---\n',1)
    header,count=re.subn(rb'^reverify: .*$',('reverify: '+json.dumps(route)).encode(),header,flags=re.M)
    assert count==1
    updates[p]=header+b'\n---\n'+body
mode_old=(ROOT/MODE_CARD).read_bytes()
mode_new=mode_old.replace(b'date: 2026-10-06\n',b'  - "why can Git archive permissions differ from checkout permissions"\ndate: 2026-10-06\n',1)
old_reverify=b'''reverify:
  - "bash scripts/check_claim_verification.sh"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.3-review.py"
'''
assert mode_new.count(old_reverify)==1
mode_new=mode_new.replace(old_reverify,('reverify: '+json.dumps(route)+'\n').encode(),1)
addition=(b'\nThe REPO-HYGIENE.18 dated archive-mode census retains all1486 Knowledge rows: '
          b'tar permissions0664, recorded Git100644 and actual filesystem0644. These '
          b'are separate representations. Guard actual permissions against their own '
          b'captured field; do not equate full archive/Git permissions with the checkout. '
          b'The first reader/failure and complete census remain in docs/checkpoints/REPO-HYGIENE.18-mode-census.json.gz '
          b'and publication-failure.json. No chmod occurred.\n')
mode_new+=addition
updates[MODE_CARD]=mode_new
cards=set(p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/knowledge').rglob('*.md') if p.is_file())
assert sum(len(updates.get(p,(ROOT/p).read_bytes())) for p in cards)<=8388608
for p,b in updates.items():(ROOT/p).write_bytes(b)
old_paragraph=decode(previous['chapter_old_base64'])
new_paragraph=decode(previous['chapter_new_base64']).replace(b'REPO-HYGIENE.18-claim.py',b'REPO-HYGIENE.18-final-claim.py')
chapter=(ROOT/CHAPTER).read_bytes()
assert chapter.count(decode(previous['chapter_new_base64']))==1
(ROOT/CHAPTER).write_bytes(chapter.replace(decode(previous['chapter_new_base64']),new_paragraph,1))
commands=[]
for command in (['bash','knowledge-map/scripts/gen_knowledge_map.sh'],['bash','knowledge-map/scripts/check_knowledge_map.sh']):
    p=subprocess.run(command,cwd=ROOT,capture_output=True)
    commands.append(dict(command=command,returncode=p.returncode,stdout_base64=base64.b64encode(p.stdout).decode(),stderr_base64=base64.b64encode(p.stderr).decode()))
    assert p.returncode==0,commands[-1]
paths=sorted(p.relative_to(ROOT).as_posix() for d in ('docs/knowledge','docs/decisions') for p in (ROOT/d).rglob('*.md') if p.is_file())
assert set(paths)==set(first['original']) and len(paths)==1486
extra=set(first['current'])-set(paths)
extra.add(PREFIX+'route-final.py')
current={}
for p in paths+sorted(extra):
    source=ROOT/p;b=source.read_bytes()
    assert source.is_file() and not source.is_symlink()
    current[p]=dict(sha256=sha(b),mode=source.stat().st_mode&0o7777,bytes_base64=base64.b64encode(b).decode())
capsule=ROOT/(PREFIX+'knowledge-final-inputs.json.gz')
with capsule.open('xb') as f:f.write(gzip.compress(json.dumps(dict(original=first['original'],current=current),sort_keys=True).encode(),mtime=0))
report=dict(base=BASE,producer_sha256=sha(Path(__file__).read_bytes()),capsule_sha256=sha(capsule.read_bytes()),
            first_capsule_sha256=sha(first_raw),first_report_sha256=sha((ROOT/(PREFIX+'route.json')).read_bytes()),
            mode_census_sha256=sha(mode_raw),markdown=len(paths),cards=previous['cards'],mode_card=MODE_CARD,
            route=route,commands=commands,mode_card_old_base64=base64.b64encode(mode_old).decode(),mode_card_new_base64=base64.b64encode(mode_new).decode(),mode_addition_base64=base64.b64encode(addition).decode(),
            chapter_old_base64=base64.b64encode(old_paragraph).decode(),chapter_new_base64=base64.b64encode(new_paragraph).decode(),
            inputs={p:dict(sha256=i['sha256'],mode=i['mode']) for p,i in current.items()},
            scope='Full1486 original/current Knowledge bytes; archive mode fields retained separately from captured filesystem modes. Eleven route-only overlays retain bodies; one existing mode card adds the dated re-derived rule/question/current route. All other Markdown remains exact. Complete first header-only and book epoch remains retained. No permission, runtime, dependency or budget change.')
with target.open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print('Final Knowledge routes PASS:1486 Markdown inputs; eleven header-only overlays and one dated mode-card update')
