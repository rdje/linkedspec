"""Recover final prerequisite publication without reading future live documents."""
import copy
import hashlib
import json
from pathlib import Path
import tarfile

BASE=Path(__file__).resolve().parent
OWNER='TYPE-REFERENCE-BOOK.1.2.23.4.14'


def images(stage):
    rows=json.loads((BASE/'publication'/(stage+'.json')).read_bytes());result={}
    with tarfile.open(BASE/'publication'/(stage+'.tar.gz')) as archive:
        assert len(archive.getnames())==len(rows) and set(archive.getnames())==rows.keys()
        for member in archive:
            raw=archive.extractfile(member).read();row=rows[member.name]
            assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256'] and member.mode&0o777==row['mode']
            result[member.name]=raw
    return result


def validate(model):
    before=model['before'];after=model['after']
    record='docs/claims/'+OWNER+'.json'
    old=json.loads(before[record]);new=json.loads(after[record])
    assert new['version']==old['version'] and new['owner']==old['owner'] and len(new['claims'])==3,'claim population'
    assert json.dumps(new['claims'][:2],sort_keys=True)==json.dumps(old['claims'],sort_keys=True),'original two claim objects'
    assert new['claims'][2]['durability']['repair_owner']=='TYPE-REFERENCE-BOOK.1.2.23.4.2','native closure disclosure'
    book='docs/linkedspec-book/src/development/documentation-workflow.md'
    assert after[book].startswith(before[book]),'prior book bytes'
    extra=after[book][len(before[book]):]
    assert b'tools/test_historical_objective_images.py' in extra and b'1.3.3.0.4.2.1-proof.py' in extra and b'Neither reruns' in extra,'source-only book recipe'
    card='docs/knowledge/three-objective-language-readiness.md'
    assert after[card].split(b'---\n',2)[2].startswith(before[card].split(b'---\n',2)[2]),'prior canonical fact body'
    memory=after['MEMORY.md']
    assert b'focused raw-error4.28 before final current canonical discovery4.1' in memory and b'complete repaired staged candidate requires fresh canonical receipt' in memory,'handoff order and gate'
    part='docs/tasks/TYPE-REFERENCE-BOOK.overview.md';marker=('- ID: `'+OWNER+'`').encode()
    for side in (before,after):
        assert side[part].count(marker)==1
    def outside(raw):
        at=raw.index(marker);end=raw.find(b'\n- ID:',at+1)
        return raw[:at],raw[len(raw) if end<0 else end:]
    assert outside(before[part])==outside(after[part]),'unrelated task bytes'
    for name in ('CHANGES.md','DEVELOPMENT_NOTES.md'):
        assert after[name].count(('## 2026-11-12 — '+OWNER+':').encode())==1,'dated leaf record'
    live='LIVE_ACHIEVEMENT_STATUS.md'
    assert before[live].split(b'## History\n',1)[1]==after[live].split(b'## History\n',1)[1],'history authority'
    recent=after[live].split(b'## Recent Completions\n\n',1)[1].split(b'\n## History',1)[0]
    assert len([line for line in recent.splitlines() if line.startswith(b'- ')])==16,'bounded live rows'


model=dict(before=images('inputs-before-use'),after=images('outputs-after-use'))
validate(model)
rejected=[]
for label,reason,path,old,new in (
    ('changed-old-claim','original two claim objects','docs/claims/'+OWNER+'.json',b'operational-committed-head-outgoing-pack-estimate',b'altered-old-claim'),
    ('skipped-raw-field-owner','handoff order and gate','MEMORY.md',b'focused raw-error4.28 before final current canonical discovery4.1',b'skip raw fields'),
    ('removed-source-only-limit','source-only book recipe','docs/linkedspec-book/src/development/documentation-workflow.md',b'Neither reruns',b'Freshly reruns'),
    ('undated-history','dated leaf record','CHANGES.md',('## 2026-11-12 — '+OWNER).encode(),('## '+OWNER).encode()),
):
    changed=copy.deepcopy(model);assert old in changed['after'][path]
    changed['after'][path]=changed['after'][path].replace(old,new)
    try:validate(changed)
    except AssertionError as error:
        assert str(error)==reason
        rejected.append(label)
    else:raise AssertionError('ineffective publication control: '+label)
print(json.dumps(dict(result='PASS',original_two_claims_preserved=True,rejected_controls=rejected,
    scope='Captured final documents and exact old claim objects; not current-file freshness or canonical completion.')))
