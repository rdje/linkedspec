"""Teach the exact historical guard admission without rewriting earlier evidence."""
import json
import re
import common as c
import context


def main():
    card = 'docs/knowledge/three-objective-language-readiness.md'
    book = 'docs/linkedspec-book/src/development/documentation-workflow.md'
    before = {path:c.read(path) for path in (card,book)}
    c.write_new('inverse-teaching-inputs.json.gz',context.snapshot())
    values = {path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    text = values[card]
    text = re.sub(r'^evidence:.*$', 'evidence: "Historical probes retain evidence, authoring costs and open defects; no completeness claim follows."',text,count=1,flags=re.M)
    text = text.replace('date: 2026-10-06','date: 2026-10-21',1)
    marker = 'date: 2026-10-21'
    text = text.replace(marker,'  - "how does count first preserve historical Phase0 evidence"\n'+marker,1)
    text += '\nCount/first10 reverses ten guard literals through its separately hash-gated table\nbefore older inverses. Prior controls retain their source stages. The table is an\nexplicit audit input; type-array-count-first/ retains the proof. No runtime replay.\n'
    values[card] = text
    cards = list((c.ROOT/'docs/knowledge').glob('*.md'))
    total = sum(len(values.get(path.relative_to(c.ROOT).as_posix(),path.read_text()).encode()) for path in cards)
    surface = next(json.loads(line) for line in c.source('doctrine/readme_stability/routes.jsonl').read_text().splitlines()
        if json.loads(line).get('id') == 'knowledge_cards')
    assert total <= surface['limits']['max_total_bytes'],total
    marker = 'and their channels separately from behavioral RED evidence.\n'
    assert values[book].count(marker) == 1
    values[book] = values[book].replace(marker,marker+'''For count/first, a separate table reverses ten generated guard expectations before
the older inverses run. Earlier falsifiers keep their original source stages;
the ten new hunks add omission, duplication and corruption controls. Table bytes
are explicit audit inputs, with actual inverse and hash-check faults retained.
''',1)
    for path,text in values.items():
        c.source(path).write_text(text)
        c.source(path).chmod(before[path]['mode'])
    generated = c.run(['bash','knowledge-map/scripts/gen_knowledge_map.sh'])
    c.write_new('inverse-teaching.json.gz',dict(before=before,after={path:c.read(path) for path in values},
        knowledge=generated,card_bytes=total))
    assert generated['returncode'] == 0
    history = c.load('history-result.json.gz')
    addendum = {}
    for surface,item in history['rollovers'].items():
        path = item['entry']['current_path']
        original = c.read(path)
        assert original == item['current']
        record = c.load(surface+'-pressure.json.gz')['record']
        assert record.endswith('\n')
        new_record = record.rstrip('\n')+' Ten Phase0 guard goldens and a separate exact inverse preserve650 prior controls and add30; actual inverse/hash faults reject and restore.\n'
        raw = c.decode(original['base64'])
        assert raw.count(record.encode()) == 1
        updated = raw.replace(record.encode(),new_record.encode(),1)
        assert len(updated) < 32768
        c.source(path).write_bytes(updated)
        c.source(path).chmod(original['mode'])
        addendum[surface] = dict(path=path,before=original,after=c.read(path),
            old_record=record,new_record=new_record)
    c.write_new('history-doc-addendum.json.gz',dict(surfaces=addendum,producer=c.read(c.PREFIX+'teach_inverse.py'),
        scope='Only the current uncommitted owning records expand; original rollover proof and every earlier record remain exact.'))
    source = c.source(c.PREFIX+'doc_proof2.py').read_text()
    assert source.count("else 'doc2'") == 1
    (c.ROOT/c.PREFIX/'doc_proof3.py').write_text(source.replace("else 'doc2'","else 'doc3'",1))
    print('Historical inverse teaching aligned; knowledge bytes',total)


if __name__ == '__main__':
    main()
