"""Retain the complete second draft, then merge its new fact under the existing cap."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c


def first_record(text,paragraph):
    start=text.index('\n## ')+1;end=text.find('\n## ',start+1)
    if end<0:end=len(text)
    return text[:end].rstrip()+'\n\n'+paragraph+'\n\n'+text[end:].lstrip('\n')


def main():
    raw=(ROOT/'.linkedspec-data/verification/type-aggregate-second-epoch.json.gz').read_bytes()
    second=json.loads(gzip.decompress(raw))
    assert c.unchanged(second['inputs']) and len(second['inputs'])==10522
    producer='.linkedspec-data/verification/type-aggregate-count-preserve.py'
    assert c.read(producer)==second['producer']
    for name,data in [('second.json.gz',raw),('preserve.py',c.decode(second['producer']['base64']))]:
        with (ROOT/(c.PREFIX+'admission/collection/'+name)).open('xb') as output:output.write(data)
    (ROOT/(c.PREFIX+'admission/collection/preserve.py')).chmod(second['producer']['mode'])
    fact='docs/knowledge/terse-type-method-surface-inventory.md'
    removed='docs/knowledge/mdbook-search-index-reflow.md'
    paths=[fact,removed,'MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md','CHANGES.md',
        'DEVELOPMENT_NOTES.md','docs/tasks/TYPE-REFERENCE-BOOK.md',c.PREFIX+'README.md']
    before={path:c.read(path) for path in paths}
    assert before[removed]==second['before'][removed]
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items() if path!=removed}
    answers=('  - "why did prose reflow change otherwise identical rendered book HTML"\n'
             '  - "how is the generated mdBook search-index reference compared"\n')
    assert after[fact].count('date: 2026-10-21\n')==1
    after[fact]=after[fact].replace('date: 2026-10-21\n',answers+'date: 2026-10-21\n',1)
    body=c.decode(before[removed]['base64']).decode().split('\n---\n',1)[1].strip()
    after[fact]+='\n'+body+'\n'
    for path in (fact,'MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md','CHANGES.md'):
        after[path]=after[path].replace('publish_final.py','publish_admitted.py')
    after['MEMORY.md']+='- collection_admission: New search fact exceeded1350 files; merged whole into the existing type-method card. Complete second10522-input claim/publication/full modes/actual readonly0 and10525 staged images survive; canonical1 failed1351/1350 and was deliberately joined143. Current publisher is publish_admitted.py; exact corrected receipt remains required.\n'
    after['CHANGES.md']=first_record(after['CHANGES.md'],
        'Collection admission preserves the second10522-input draft/actual readonly0 and10525 '
        'Git-verified staged images before repair. Canonical1 exposed knowledge_cards1351/1350 and '
        'was deliberately joined143. Merge the complete search-index finding and both retrieval '
        'questions into the existing type-method fact card; remove only the redundant new card. '
        'No file/byte budget changes. Current rederive is publish_admitted.py; exact corrected '
        'canonical admission remains required.')
    after['DEVELOPMENT_NOTES.md']=first_record(after['DEVELOPMENT_NOTES.md'],
        'Knowledge containment includes a hard file-count cap as well as bytes. The newly added '
        'search-index card exceeded1350 files even after byte compaction. Its entire finding and '
        'two questions now live in the existing type-method card; retain its removed source in '
        'the whole second-draft packet. The failed canonical result is retained, not reported as '
        'a completed gate. Original, second and admitted publications remain distinct.')
    task='docs/tasks/TYPE-REFERENCE-BOOK.md'
    needle='  Commit subject: `'+c.OWNER+' - execute deferred array reducers`.'
    assert after[task].count(needle)==1
    after[task]=after[task].replace(needle,
        '  Collection-pressure defect owned/fixed: canonical1 observed knowledge_cards1351/1350. '
        'Whole second10522/10525 images/actual readonly0 and joined143 failure survive before '
        'merging the complete new search finding/questions into the existing fact owner. No '
        'budget increase. publish_admitted.py and corrected exact canonical receipt govern landing.\n'+needle,1)
    after[c.PREFIX+'README.md']=after[c.PREFIX+'README.md'].replace(
        'Owner: TYPE-REFERENCE-BOOK.1.2.7;',
        'Current readonly rederive: publish_admitted.py. Earlier publisher descriptions below are '
        'unpublished source epochs. If HEAD is still activationefad and Git is dirty, finish7 '
        'before activating9.\n\nOwner: TYPE-REFERENCE-BOOK.1.2.7;',1)
    after[c.PREFIX+'README.md']+='''
Collection admission: canonical1 observed knowledge_cards1351/1350 and was
deliberately joined143. collection/second.json.gz retains the complete10522-input
second claim/publication/full modes, actual readonly0 and10525 Git-verified staged
images before any correction. The redundant new fact card is retained whole
there and merged into the existing type-method owner with both retrieval
questions. No file/byte budget changes. Original and second publication outputs
stay frozen. Current publish_admitted.py binds the final collection epoch;
targeted pressure and exact corrected canonical admission govern landing.
'''
    c.write_new('admission/collection/merge.json.gz',dict(before=before,
        after={path:c.encode(text.encode()) for path,text in after.items()},removed=removed,
        producer=c.read(c.PREFIX+'admission/collection/merge.py'),
        scope='Only fact ownership/current handoff metadata change. Whole removed card survives; '
              'book/runtime/tests stay exact. Intended clean handoff still requires corrected canonical.'))
    for path,text in after.items():(ROOT/path).write_text(text)
    (ROOT/removed).unlink()
    print('Complete second draft adopted; complete fact/questions merged; no budget change; corrected gate required')


if __name__=='__main__':main()
