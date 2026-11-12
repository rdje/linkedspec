"""Recover actual data-epoch publication without replaying its writer or SDK."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
OUT=BASE/'publication'
OWNER='TYPE-REFERENCE-BOOK.1.2.23.4.32'
SOURCE='docs/tasks/PROJECT-DATA-SSD-ROOTING.md'
MANIFEST='docs/history/task-narrative-epochs/'+OWNER+'.json'
BOOK='docs/linkedspec-book/src/development/documentation-workflow.md'
PART='docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
CARD='docs/knowledge/rooting-closed-task-narrative-headroom.md'
def recover(tag):
    rows=json.loads((OUT/(tag+'.json')).read_bytes());bodies={}
    with tarfile.open(OUT/(tag+'.tar.gz')) as archive:
        assert len(archive.getnames())==len(rows) and set(archive.getnames())==rows.keys()
        for member in archive:
            path=Path(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in bodies
            raw=archive.extractfile(member).read();row=rows[member.name]
            assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256'],'publication bytes'
            assert member.mode&0o777==row['mode'],'publication full modes'
            bodies[member.name]=raw
    return bodies

def validate(inputs,outputs):
    for tag in ('review','current','review-refusal','review-publication-query'):
        prefix=str(BASE/'launches'/tag)+'/'
        assert inputs[prefix+'exit.txt']==b'0\n' and gzip.decompress(inputs[prefix+'stderr.log.gz'])==b'','consumed report'
    proof=json.loads(inputs[str(BASE/'review-result.json')])
    current=json.loads(inputs[str(BASE/'candidate-result.json')])
    query=json.loads(gzip.decompress(inputs[str(BASE/'launches/review-publication-query/stdout.log.gz')]))
    refusal=json.loads(gzip.decompress(inputs[str(BASE/'launches/review-refusal/stdout.log.gz')]))
    assert proof['preservation']==current['candidate']==refusal['refusal_recovery']=='PASS','consumed verdicts'
    assert (proof['stable_ids'],proof['selected_closed'],proof['unchanged_short_bodies'],proof['current_text_bytes_renewed'],proof['current_tail_bytes'],proof['actual_public_queries'])==(22,17,5,40587,35225,23),'derived source counts'
    assert len(proof['effective_corruptions'])==10 and len(refusal['corruptions'])==3,'derived controls'
    assert query['claim_records']==211 and query['historical_intersections']==207 and query['live_intersections']==0 and len(query['rejected_live_binding_controls'])==8,'claim bindings'
    metadata=json.loads(inputs[str(BASE/'outputs-before-reader-identities.json')])
    for name in (SOURCE,MANIFEST):
        assert len(inputs[name])==metadata[name]['bytes'] and hashlib.sha256(inputs[name]).hexdigest()==metadata[name]['sha256'],'actual source-manifest identity'
    manifest=json.loads(inputs[MANIFEST]);assert manifest['tree']=='PROJECT-DATA-SSD-ROOTING' and manifest['epoch']==OWNER and len(manifest['selected'])==17,'actual epoch'
    for name in ('publish.py','review_publication.py','review.py','review_refusal.py'):
        assert inputs[str(BASE/name)]==(BASE/name).read_bytes(),'retained actual producer identity'
    heading=next(line for line in outputs['CHANGES.md'].decode().splitlines() if line.startswith('## '))
    assert heading.startswith('## 2026-11-12 — '+OWNER+':'),'dated new change'
    body=outputs[PART].decode();node=body[body.index('- ID: `'+OWNER+'`'):]
    assert node.count('  Status: `completed`')==1 and node.count('- [x]')==6,'completed task proof'
    memory=outputs['MEMORY.md'].decode()
    assert 'active_work_unit: `'+OWNER+'` (completed)' in memory and 'in_flight_uncommitted: none;' in memory,'handoff owner'
    assert 'resource23.4.14' in memory and '1,500,000,000' in memory,'next action and budget'
    book=outputs[BOOK].decode()
    assert '--tree PROJECT-DATA-SSD-ROOTING --epoch '+OWNER+' --all' in book,'book recipe'
    assert 'Original cleanup dates,' in book and 'current deletion, SDK and parity authority stays with its existing owners.' in book,'historical authority'
    card=outputs[CARD].decode()
    for pointer in ('review.py','review_refusal.py'):
        assert str(BASE/pointer) in card,'historical reader pointers'
    assert '22 ordered IDs/all CORE/five unchanged bodies/full35225-byte tail' in card,'derived card counts'
    for name in ('ROADMAP.md','ROADMAP_V2.md'):
        assert b'Headroom32 preserves22 rooting IDs' in outputs[name] and b'resource4.14' in outputs[name],'roadmap frontier'
    def rows(source):
        return source.decode().split('## Recent Completions\n\n',1)[1].split('\n## History',1)[0].strip().splitlines()
    before,after=rows(inputs['LIVE_ACHIEVEMENT_STATUS.md']),rows(outputs['LIVE_ACHIEVEMENT_STATUS.md'])
    assert len(before)==len(after)==16 and after[1:]==before[:15],'bounded recent rows'
    assert outputs[str(OUT/'rotated-live-row.txt')].decode()==before[-1]+'\n','rotated source row'
    assert inputs['LIVE_ACHIEVEMENT_STATUS.md'].split(b'## History',1)[1]==outputs['LIVE_ACHIEVEMENT_STATUS.md'].split(b'## History',1)[1],'history pointer'
    claim=json.loads(inputs['docs/claims/'+OWNER+'.json'])
    assert claim['owner']==OWNER and claim['claims'][0]['rederive']['status']=='checked','operational record'
    assert claim['claims'][0]['falsify']['status']==claim['claims'][0]['durability']['status']=='gap','explicit operational gaps'
inputs,outputs=recover('inputs-before-use'),recover('outputs-after-use')
validate(inputs,outputs)
controls=[]
for label,mutate,reason in (
    ('failed consumed report',lambda left,right:left.__setitem__(str(BASE/'launches/review/exit.txt'),b'1\n'),'consumed report'),
    ('missing heading date',lambda left,right:right.__setitem__('CHANGES.md',right['CHANGES.md'].replace(('## 2026-11-12 — '+OWNER).encode(),('## '+OWNER).encode(),1)),'dated new change'),
    ('unfinished handoff',lambda left,right:right.__setitem__('MEMORY.md',right['MEMORY.md'].replace(b'(completed)',b'(active)',1)),'handoff owner'),
    ('wrong epoch recipe',lambda left,right:right.__setitem__(BOOK,right[BOOK].replace(('--tree PROJECT-DATA-SSD-ROOTING --epoch '+OWNER).encode(),('--tree SPEC-FORMAT-TERSE --epoch '+OWNER).encode(),1)),'book recipe'),
):
    left,right=copy.deepcopy(inputs),copy.deepcopy(outputs);mutate(left,right)
    try:validate(left,right)
    except AssertionError as failure:assert reason in str(failure),'rejection reason:'+label
    else:raise AssertionError('publication corruption accepted:'+label)
    controls.append(label)
print(json.dumps(dict(publication_recovery='PASS',inputs=len(inputs),outputs=len(outputs),corruptions=controls,scope='Historical actual producer/report/document bytes and full modes; immutable producer identity only, no future current-document freshness, SDK replay or full native/OS closure.')))
