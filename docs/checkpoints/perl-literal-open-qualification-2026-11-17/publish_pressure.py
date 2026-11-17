"""Append bounded task-representation evidence; preserve the four original claims."""
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
plan = json.loads((BASE / 'plan.json').read_bytes())
path = Path('docs/claims/' + plan['owner'] + '.json')
record = json.loads(path.read_bytes())
assert len(record['claims']) == 4
with tarfile.open(BASE / 'pressure-disclosure-before.tar.gz', 'x:gz') as archive:
    for item in (path, BASE / 'publish_pressure.py', BASE / 'pressure-repair.json'):
        archive.add(item, arcname=str(item), recursive=False)
record['claims'].append(dict(name='task-representation-pressure-repair',
    statement='The preserved before/after task representations have identical task ID populations, status/tier/claim bindings and existing parent Goal/Acceptance. Full original new detail remains recoverable; only new summaries and a redundant child list are condensed.',
    scope='Only the retained affected task part/frontier and identity/ownership fields. No complete semantic-equivalence, resulting-budget admission, runtime, tool or limit-change claim. A fresh complete normal-hook pass is still required.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + str(BASE / 'review_pressure.py'),
        granularity='Each retained before/after stable ID and status/tier/claim field, original parent contract, source archive body/mode identities and actual partial failed-normal log.',
        result='Readonly current review PASS; original detail retained; missing ID and changed status both RED. The failed own hook tree was stopped at observed commit exit143 after the conclusive task-text pressure failure; no complete PASS is claimed from it.'),
    falsify=dict(status='checked', hypothesis='An omitted task or changed task status could preserve the identity/ownership comparison.',
        oracle='Complete retained pre-repair task source and explicit field comparison; original parent Goal/Acceptance remain exact.',
        red_control='Removing the actual owner ID fails task ID population; changing its status to pending fails task status/tier/claim binding.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2',
        reason='Complete local before/after affected source images, actual repair/reviewer sources, original detailed new task bodies and actual failed-hook output retained. Partial original hook/instrument/native/Git/OS/outer-first-use/per-read/source-origin/physical closure remains4.2/SESSION5. Actual retry supplies admission; no previous failed result is overwritten.')))
path.write_text(json.dumps(record, indent=2) + chr(10))
print('Preserved original four claims; appended only bounded task-identity evidence')
