"""Repair only published path representation after preserving the whole failed candidate."""
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
PREFIX = 'docs/checkpoints/type-array-count-first/'
sys.path.insert(0,str(ROOT/PREFIX))
import common as c
import context


def replace(text,old,new):
    assert text.count(old) == 1,old
    return text.replace(old,new,1)


def main():
    actor = Path(__file__).resolve().relative_to(ROOT).as_posix()
    draft = c.load('draft2.json.gz')
    assert draft['inputs_unchanged'] and draft['baseline']['returncode'] == 0
    assert c.unchanged(draft['context']['inputs'])
    before = {path:c.read(path) for path in ('MEMORY.md','docs/tasks/TYPE-REFERENCE-BOOK.md',
        PREFIX+'phase0.py',PREFIX+'review.py',PREFIX+'publish.py',
        'docs/linkedspec-book/src/development/documentation-workflow.md')}
    c.write_new('portability-repair-inputs.json.gz',context.snapshot(extras=(actor,)))
    normalized = {}
    for stem in ('phase0-accepted','phase0-candidate'):
        path = PREFIX+stem+'-result.json'
        original = c.read(path)
        assert original == draft['context']['overrides'][path]
        value = json.loads(c.decode(original['base64']))
        loaded = Path(value['summary']['loaded_method_lowering'])
        assert loaded.resolve() == ROOT/c.SOURCES[1]
        value['summary']['loaded_method_lowering'] = loaded.relative_to(ROOT).as_posix()
        c.source(path).write_text(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n')
        c.source(path).chmod(original['mode'])
        normalized[stem] = dict(path=path,before=original,after=c.read(path))
    phase0 = c.decode(before[PREFIX+'phase0.py']['base64']).decode()
    phase0 = replace(phase0,"    c.write_new(stem+'-result.json',dict(summary=result,failed=sorted(failed),",
        "    result['loaded_method_lowering'] = Path(result['loaded_method_lowering']).resolve().relative_to(c.ROOT).as_posix()\n    c.write_new(stem+'-result.json',dict(summary=result,failed=sorted(failed),")
    c.source(PREFIX+'phase0.py').write_text(phase0)
    c.write_new('phase0-path-normalization.json.gz',dict(summaries=normalized,
        producer_before=before[PREFIX+'phase0.py'],producer_after=c.read(PREFIX+'phase0.py'),
        scope='Two published summaries use repository-relative loader paths. Exact raw observations, loaded-source validation, all original counts and draft2 remain unchanged.'))
    review = c.decode(before[PREFIX+'review.py']['base64']).decode()
    start = review.index("        addendum = c.load('history-doc-addendum.json.gz')['surfaces'][surface]")
    end = review.index("        archived = ",start)
    review = review[:start]+'''        packet,record = item['current'],pressure['record']
        for name in ('history-doc-addendum.json.gz','history-doc-addendum2.json.gz'):
            addendum = c.load(name)['surfaces'][surface]
            assert addendum['before'] == packet and addendum['old_record'] == record
            raw = c.decode(packet['base64'])
            assert raw.count(record.encode()) == 1
            assert c.decode(addendum['after']['base64']) == raw.replace(record.encode(),addendum['new_record'].encode(),1)
            assert packet['mode'] == addendum['after']['mode']
            packet,record = addendum['after'],addendum['new_record']
        assert c.read(root) == packet
'''+review[end:]
    review = replace(review,"replace(addendum['new_record'].encode(),b'',1)","replace(record.encode(),b'',1)")
    review = replace(review,"    summaries = {}\n", "    summaries = {}\n    normalization = c.load('phase0-path-normalization.json.gz')\n    draft2 = c.load('draft2.json.gz')\n")
    review = replace(review,"        assert actual == result['summary'] and actual['complete_selection']",'''        changed = normalization['summaries'][stem]
        assert changed['before'] == draft2['context']['overrides'][changed['path']]
        assert changed['after'] == c.read(changed['path'])
        original = json.loads(c.decode(changed['before']['base64']))
        assert original['summary'] == actual
        original['summary']['loaded_method_lowering'] = c.SOURCES[1]
        assert original == result and actual['complete_selection']''')
    review = replace(review,"    return dict(result,selected=len(plan['selected'])",'''    assert draft2['baseline']['returncode'] == 0 and draft2['inputs_unchanged']
    assert not c.decode(draft2['baseline']['stderr_base64']) and draft2['portability']['returncode'] != 0
    for key,name in [('publication','publication2.json'),('manifest','publication2-inputs.json.gz')]:
        assert c.source(c.PREFIX+name).read_bytes() == c.decode(draft2['packets'][key]['base64'])
    assert normalization['producer_before'] == draft2['context']['overrides'][c.PREFIX+'phase0.py']
    assert normalization['producer_after'] == c.read(c.PREFIX+'phase0.py')
    return dict(result,selected=len(plan['selected'])''')
    review = review.replace('artifact2-','artifact3-').replace('doc3-','doc4-')
    review = replace(review,"    recovered = custody.verify()",'''    repair = c.load('portability-repair.json.gz')
    assert repair['checker'] == c.read('scripts/check_repo_root_path_portability.sh')
    assert repair['green']['returncode'] == 0 and not c.decode(repair['green']['stderr_base64'])
    recovered = custody.verify()''')
    review = replace(review,"    if fresh:\n",'''    if fresh:
        portable = c.run(['bash','scripts/check_repo_root_path_portability.sh'])
        assert portable['returncode'] == 0 and not c.decode(portable['stderr_base64'])
''')
    c.source(PREFIX+'review.py').write_text(review)
    publisher = c.decode(before[PREFIX+'publish.py']['base64']).decode()
    publisher = publisher.replace('publication2-inputs.json.gz','publication3-inputs.json.gz').replace('publication2.json','publication3.json')
    publisher = publisher.replace('artifact2-inputs.json.gz','artifact3-inputs.json.gz')
    publisher = replace(publisher,"c.load('draft1.json.gz')['packets']['claim']","c.load('draft2.json.gz')['packets']['claim']")
    publisher = replace(publisher,"'tools/roll_document_history.pl','scripts/check_readme_routing_pressure.pl'",
        "'tools/roll_document_history.pl','scripts/check_readme_routing_pressure.pl','scripts/check_repo_root_path_portability.sh'")
    publisher = replace(publisher,"'Whole unpublished draft1 and its actual readonly baseline survive before these bound edits.')",
        "'Whole unpublished draft1 and its actual readonly baseline survive before these bound edits. '\n        'Draft2 and the actual production portability failure remain whole; two published loader summaries use relative paths while exact raw observations survive. The restored production path checker passes.')")
    c.source(PREFIX+'publish.py').write_text(publisher)
    artifact = c.source(PREFIX+'artifacts2.py').read_text().replace('artifact2-','artifact3-')
    artifact = replace(artifact,"target = 'tests/language-readiness/count-first-regression-evolution.json'",
        "target = c.PREFIX+'phase0-candidate-result.json'")
    (ROOT/PREFIX/'artifacts3.py').write_text(artifact)
    doc = c.source(PREFIX+'doc_proof3.py').read_text()
    (ROOT/PREFIX/'doc_proof4.py').write_text(replace(doc,"else 'doc3'","else 'doc4'"))
    book = c.decode(before['docs/linkedspec-book/src/development/documentation-workflow.md']['base64']).decode()
    marker = 'are explicit audit inputs, with actual inverse and hash-check faults retained.\n'
    book = replace(book,marker,marker+'''Publish loader paths relative to the repository root. Preserve exact raw loader
observations separately before normalization, and run the production portability
check on the resulting summaries before canonical CI.
''')
    c.source('docs/linkedspec-book/src/development/documentation-workflow.md').write_text(book)
    addendum = {}
    for surface,item in c.load('history-doc-addendum.json.gz')['surfaces'].items():
        path = item['path']
        original = c.read(path)
        assert original == item['after']
        record = item['new_record']
        new_record = record.rstrip('\n')+' Published summaries use relative paths; exact raw observations and failed draft2 survive.\n\n'
        raw = c.decode(original['base64'])
        assert raw.count(record.encode()) == 1
        updated = raw.replace(record.encode(),new_record.encode(),1)
        assert len(updated) < 32768
        c.source(path).write_bytes(updated)
        addendum[surface] = dict(path=path,before=original,after=c.read(path),old_record=record,new_record=new_record)
    c.write_new('history-doc-addendum2.json.gz',dict(surfaces=addendum,producer=c.read(actor)))
    tree = c.decode(before['docs/tasks/TYPE-REFERENCE-BOOK.md']['base64']).decode()
    tree = replace(tree,'- Status: `active` / next registered pipeline .1.2.11; before enumeration',
        '- Status: `active` / count/first10 final portability repair; before enumeration')
    start,end = tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.10`'),tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.11`')
    leaf = tree[start:end].replace('Status: `done` / selected proof; exact canonical admission required',
        'Status: `active` / final published-summary portability repair',1)
    leaf = leaf.replace('- [x] **NO REGRESSION','- [ ] **NO REGRESSION',1).replace('- [x] **LOCKSTEP','- [ ] **LOCKSTEP',1)
    leaf += '  Defect owned: Canonical production path checker rejects two new Phase0 summaries because the observer copies an absolute loader path into plain JSON. Reproduce with scripts/check_repo_root_path_portability.sh. Runtime and raw loader verification pass. Preserve whole unpublished draft2 and actual readonly0/production RED, normalize only published paths, retain original raw/producer bytes, and require fresh book/artifact/path/canonical proof. Original failed gate was terminated143 after its reported denial; no successful canonical claim is made.\n\n'
    tree = tree[:start]+leaf+tree[end:]
    c.source('docs/tasks/TYPE-REFERENCE-BOOK.md').write_text(tree)
    memory = c.decode(before['MEMORY.md']['base64']).decode()
    memory = re.sub(r'^- latest_completed_leaf:.*$', '- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.13` at real a8bd8620a; count/first10 remains uncommitted.',memory,flags=re.M)
    memory = memory.replace('`TYPE-REFERENCE-BOOK.1.2.10` (completed)','`TYPE-REFERENCE-BOOK.1.2.10` (final portability repair active)',1)
    memory = re.sub(r'^- next_action:.*$', '- next_action: Finish the two published path-summary corrections, fresh current proof and canonical/normal landing before clean activation11.',memory,flags=re.M)
    memory = re.sub(r'^- in_flight_uncommitted:.*$', '- in_flight_uncommitted: Owned10 portability representation repair; whole draft2 and its actual readonly0/production path RED survive. Canonical attempt143 was stopped after its denial.',memory,flags=re.M)
    c.source('MEMORY.md').write_text(memory)
    for path,packet in before.items():
        c.source(path).chmod(packet['mode'])
    green = c.run(['bash','scripts/check_repo_root_path_portability.sh'])
    c.write_new('portability-repair.json.gz',dict(before=before,after={path:c.read(path) for path in before},
        checker=c.read('scripts/check_repo_root_path_portability.sh'),green=green,producer=c.read(actor),
        scope='Only published loader-path representation changes. Original raw observations, production sources, historical inverse tables and earlier proof epochs remain exact. Fresh distinct book/artifact and exact canonical admission remain required.'))
    assert green['returncode'] == 0 and not c.decode(green['stderr_base64'])
    with (ROOT/PREFIX/'repair_portability.py').open('xb') as output:
        output.write(c.source(actor).read_bytes())
    print('Portability repair GREEN: two relative summaries; exact raw observations and drafts retained')


if __name__ == '__main__':
    main()
