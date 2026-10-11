"""Preserve an intersecting dated claim at accepted Git; default readonly final review."""
import base64, copy, hashlib, json, subprocess, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
DIR='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6/'
BASE='d8418423e7461235280e9a34b9d90f4571fc9490'
CLAIM='docs/claims/REPO-HYGIENE.15.json'
CARD='docs/knowledge/repo-generated-artifact-cleanup-boundary.md'
BOOK='docs/linkedspec-book/src/development/documentation-workflow.md'
read=lambda p:(ROOT/p).read_bytes()
sha=lambda raw:hashlib.sha256(raw).hexdigest()
def old(p): return subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)
def save(name,data): (ROOT/(DIR+name)).write_text(json.dumps(data,indent=2)+'\n')
def channel(raw): return {'base64':base64.b64encode(raw).decode(),'bytes':len(raw),'sha256':sha(raw)}
def card():
    raw=old(CARD)
    extra=b'  - "which live claims must be preserved before changing a shared book chapter"\n  - "why was the October10 hygiene claim preserved during ADR0133"\n  - "do historical checked claims need a tracked producer input"\n'
    raw=raw.replace(b'date: 2026-10-10',extra+b'date: 2026-10-11',1)
    marker=b'reverify: '
    start=raw.index(marker); end=raw.index(b'\n',start)
    raw=raw[:start]+b'reverify: "Current ADR0133 closure: bash tools/run_python_project_data.sh '+DIR.encode()+b'publish.py (readonly). Original REPO-HYGIENE.15 commands below require accepted d8418423e inputs, including the original live claim/book/card. No cleanup or runtime observation is refreshed."'+raw[end:]
    marker=b'\n# Repo Generated Artifact Cleanup Boundary'
    extra=b'\n# Shared publication inputs and historical provenance\n\nBefore changing a shared book chapter, enumerate intersections across every live claim; the immediate predecessor is insufficient. ADR0133 changed the documentation-workflow chapter before noticing REPO-HYGIENE.15 also bound it. All19 original hashes and claim fields were subsequently verified against clean d8418423e and preserved with only mode/revision changes. The late timing is disclosed; original dated observations are unchanged.\n\nEvery checked durability record, including a historical one, needs a tracked producer input. The actual claim validator rejects the two original producer-free historical entries and accepts exact provenance repairs without refreshing hashes. The original362-input draft, publisher and actual failed CI report remain retained. Logs needed after command exit belong outside automatically cleaned managed scratch, or require explicit failed-run retention.\n\nThe original hygiene body below is dated evidence. Its readonly publication commands require its accepted Git input state; current closure and exact preservation review are named above. No recovery, purge or artifact removal is authorized here.\n'
    assert raw.count(marker)==1
    return raw.replace(marker,extra+marker,1)
def expected():
    data=json.loads(old(CLAIM)); original=copy.deepcopy(data)
    entries=data['claims'][0]['durability']['inputs']; assert len(entries)==19
    for e in entries: assert sha(old(e['path']))==e['sha256'],'original hygiene binding: '+e['path']
    assert len(data['claims'])==1 and data['claims'][0]['durability']['mode']=='live'
    data['claims'][0]['durability'].update(mode='historical',revision=BASE)
    return original,data,entries

def review():
    original,after,entries=expected()
    assert read(DIR+'before-hygiene.json')==old(CLAIM),'exact original hygiene claim'
    assert json.loads(read(CLAIM))==after,'hygiene mode/revision-only preservation'
    assert read(CARD)==card(),'exact related hygiene card update'
    plan=json.loads(read('docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6-plan.json'))
    assert sha(read(BOOK))==plan['resulting_inputs'][BOOK],'owned new book input'
    for e in entries:
        if e['path'] not in (BOOK,CARD): assert read(e['path'])==old(e['path']),'unchanged hygiene input: '+e['path']
    assert json.loads(read(DIR+'hygiene-freeze.json'))=={'revision':BASE,'claim':CLAIM,'original_sha256':sha(old(CLAIM)),'after_sha256':sha(read(CLAIM)),'verified_bindings':19,'late_preservation':True,'book_was_already_edited':True,'producer_sha256':sha(Path(__file__).read_bytes()),'scope':'All19 accepted Git input hashes and original claim fields preserved; only live mode/revision changes. Shared book was already edited when intersection was discovered; the exact original remains recoverable at accepted Git. No original observation or hash is refreshed.'}
    print('Hygiene19 preservation PASS: accepted Git inputs/exact claim/mode-only conversion; late shared-book timing disclosed')

def run():
    args=['python3',DIR+'hygiene.py','review']; p=subprocess.run(args,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    return {'args':args,'exit_code':p.returncode,'stdout':channel(p.stdout),'stderr':channel(p.stderr)}
mode=sys.argv[1] if len(sys.argv)==2 else 'final'
assert mode in ('apply','review','capture','final')
if mode=='apply':
    assert not (ROOT/(DIR+'hygiene-freeze.json')).exists()
    original,after,entries=expected(); assert read(CLAIM)==old(CLAIM)
    assert read(BOOK)!=old(BOOK),'actual existing intersection drift'
    for e in entries:
        if e['path']!=BOOK: assert read(e['path'])==old(e['path']),'late original input: '+e['path']
    (ROOT/(DIR+'before-hygiene.json')).write_bytes(old(CLAIM))
    (ROOT/CLAIM).write_text(json.dumps(after,indent=2)+'\n'); (ROOT/CARD).write_bytes(card())
    save('hygiene-freeze.json',{'revision':BASE,'claim':CLAIM,'original_sha256':sha(old(CLAIM)),'after_sha256':sha(read(CLAIM)),'verified_bindings':19,'late_preservation':True,'book_was_already_edited':True,'producer_sha256':sha(Path(__file__).read_bytes()),'scope':'All19 accepted Git input hashes and original claim fields preserved; only live mode/revision changes. Shared book was already edited when intersection was discovered; the exact original remains recoverable at accepted Git. No original observation or hash is refreshed.'})
    review()
elif mode=='review': review()
else:
    review()
    names=[DIR+'before-hygiene.json',DIR+'hygiene-freeze.json']; originals={p:read(p) for p in names}
    changed={p:json.loads(raw) for p,raw in originals.items()}; changed[names[0]]['claims'][0]['durability']['inputs'][0]['sha256']='0'*64
    mutant=(json.dumps(changed[names[0]],indent=2)+'\n').encode(); changed[names[1]]['original_sha256']=sha(mutant)
    mutants={names[0]:mutant,names[1]:(json.dumps(changed[names[1]],indent=2)+'\n').encode()}
    if mode=='capture':
        assert not (ROOT/(DIR+'hygiene-evidence.json')).exists()
        data={'producer_sha256':sha(Path(__file__).read_bytes()),'healthy':run(),'inputs':{p:channel(raw) for p,raw in mutants.items()}}
        save('hygiene-reached.json',data); assert data['healthy']['exit_code']==0
        try:
            for p,raw in mutants.items(): (ROOT/p).write_bytes(raw)
            data['observed']=run(); save('hygiene-reached.json',data)
            assert data['observed']['exit_code']!=0 and b'exact original hygiene claim' in base64.b64decode(data['observed']['stderr']['base64'])
        finally:
            for p,raw in originals.items(): (ROOT/p).write_bytes(raw)
        data['restored']=run(); save('hygiene-reached.json',data); assert data['restored']==data['healthy']; save('hygiene-evidence.json',data)
    data=json.loads(read(DIR+'hygiene-evidence.json')); assert json.loads(read(DIR+'hygiene-reached.json'))==data
    assert data['producer_sha256']==sha(Path(__file__).read_bytes()) and data['inputs']=={p:channel(raw) for p,raw in mutants.items()}
    assert data['healthy']==data['restored']==run()
    assert data['observed']['exit_code']!=0 and b'exact original hygiene claim' in base64.b64decode(data['observed']['stderr']['base64'])
    for result in (data['healthy'],data['observed'],data['restored']):
        for part in ('stdout','stderr'): assert channel(base64.b64decode(result[part]['base64']))==result[part]
    print('Hygiene19 evidence PASS: beyond-immediate-SHA original binding RED/exact restoration')
