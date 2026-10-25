"""Additional shared homes checked before editing their current guidance."""
import json
import common as c

planned=['docs/knowledge/document-history-rollover-eof-separator.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md']
original=c.load('preflight.json.gz')
hits=[]
for name,packet in original['claims'].items():
    for claim in json.loads(c.decode(packet['base64']))['claims']:
        leg=claim['durability']
        if leg.get('status')=='checked' and leg.get('mode')=='live':
            overlap=sorted(set(planned)&{row['path'] for row in leg['inputs']})
            if overlap:hits.append(dict(record=name,claim=claim['name'],paths=overlap))
c.save('shared-home-preflight.json.gz',dict(planned=planned,live_intersections=hits,
    before={name:c.read(name) for name in planned},producer=c.read(c.PREFIX+'supplement.py')))
assert not hits,hits
print('Additional shared-home live intersections:',len(hits))
