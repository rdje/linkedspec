"""Before-write live-claim intersection and exact cleanup source intake."""
import json
import subprocess
import common as c

planned=['docs/ARTIFACT_CLEANUP.md','docs/knowledge/repo-generated-artifact-cleanup-boundary.md',
    'docs/linkedspec-book/src/development/local-ci-and-regression.md',
    'MEMORY.md','CHANGES.md','DEVELOPMENT_NOTES.md','LIVE_ACHIEVEMENT_STATUS.md',
    'ROADMAP.md','ROADMAP_V2.md','docs/TASK_TREE.md','docs/tasks/REPO-HYGIENE.md']
records={};hits=[]
for path in subprocess.check_output(['git','ls-files','docs/claims'],cwd=c.ROOT,text=True).splitlines():
    packet=c.read(path);records[path]=packet
    for claim in json.loads(c.decode(packet['base64']))['claims']:
        leg=claim['durability']
        if leg.get('status')=='checked' and leg.get('mode')=='live':
            overlap=sorted(set(planned)&{row['path'] for row in leg.get('inputs',[])})
            if overlap:hits.append(dict(record=path,claim=claim['name'],paths=overlap))
c.save('preflight.json.gz',dict(producer=c.read(c.PREFIX+'preflight.py'),
    helper=c.read(c.PREFIX+'common.py'),planned=planned,claims=records,live_intersections=hits,
    before={path:c.read(path) for path in planned},
    note_intake=c.read(c.PREFIX+'input-notes.json.gz'),
    scope='Complete current tracked claim namespace before shared book/card/cleanup-record edits. '
        'Task activation/Memory already record only this active owner; source/retention policy '
        'and cleanup record have not changed. Prior byte identities and sealed epochs remain fixed.'))
assert not hits,hits
print('Cleanup live-claim intersections:',len(hits),'; original claims retained:',len(records))
