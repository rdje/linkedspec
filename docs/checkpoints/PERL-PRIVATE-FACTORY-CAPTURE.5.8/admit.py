"""Apply one measured archive member and a finite existing-hot-shard note envelope."""
import base64
import copy
import gzip
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE='54bb5eb65178a57ac6e61e53324c9291863e716d'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.8/'
LEAF='PERL-PRIVATE-FACTORY-CAPTURE.5.8'
REG='doctrine/readme_stability/routes.jsonl'
INDEX='docs/decisions/INDEX.md'
ADR='docs/decisions/0136-finite-continuity-capacity.md'
MANIFEST='docs/history/changes/manifest.jsonl'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
decode=lambda v:base64.b64decode(v,validate=True)
compact=lambda v:json.dumps(v,sort_keys=True,separators=(',',':'))
raw=lambda p:(ROOT/p).read_bytes()
old=lambda p:subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()==BASE
target=ROOT/(PREFIX+'plan.json');assert not target.exists() and not (ROOT/ADR).exists()
measured_raw=raw(PREFIX+'measurement.json');measured=json.loads(measured_raw)
assert measured['result']=='PASS' and measured['producer_sha256']==sha(raw(PREFIX+'measure.py'))
rolled_raw=raw(PREFIX+'rolled-inputs.json.gz')
assert sha(rolled_raw)==measured['captures']['rolled']['sha256']
rolled=json.loads(gzip.decompress(rolled_raw))
for p in ('CHANGES.md','DEVELOPMENT_NOTES.md',REG,INDEX,MANIFEST):assert raw(p)==decode(rolled[p]['bytes_base64'])
assert all(sha(raw(p))==identity for p,identity in measured['preserved'].items())
lines=old(REG).splitlines(True);rows=[json.loads(line) for line in lines]
newrows=copy.deepcopy(rows)
before={v['id']:v for v in rows if 'id' in v}
after={v['id']:v for v in newrows if 'id' in v}
def metrics(paths):
    values=[raw(p) for p in paths]
    return dict(files=len(values),lines=sum(v.count(b'\n') for v in values),bytes=sum(map(len,values)))
def history_paths(family,current):
    return [current,'docs/history/'+family+'/manifest.jsonl']+sorted(p.relative_to(ROOT).as_posix() for p in (ROOT/('docs/history/'+family)).glob('*.md'))
changes=metrics(history_paths('changes','CHANGES.md'))
engineering=metrics(history_paths('development-notes','DEVELOPMENT_NOTES.md'))
assert changes['files']==before['change_history']['limits']['max_files']+1
manifest=dict(lines=raw(MANIFEST).count(b'\n'),bytes=len(raw(MANIFEST)))
oldmember=before['change_history']['member_limits'][MANIFEST]
assert manifest['lines']==oldmember['max_lines']+1 and manifest['bytes']>oldmember['max_bytes']
after['change_history']['limits']['max_files']=changes['files']
after['change_history']['member_limits'][MANIFEST]=dict(max_lines=manifest['lines'],max_bytes=manifest['bytes'])
envelope=before['engineering_notes']['member_limits']['DEVELOPMENT_NOTES.md']['max_lines']
assert envelope==512
assert before['engineering_notes']['limits']['max_total_lines']<engineering['lines']<=before['engineering_notes']['limits']['max_total_lines']+envelope
assert engineering['files']==before['engineering_notes']['limits']['max_files']
after['engineering_notes']['limits']['max_total_lines']+=envelope
for name,census in (('change_history',changes),('engineering_notes',engineering)):
    assert census['bytes']<=before[name]['limits']['max_total_bytes']
    if name=='change_history':assert census['lines']<=before[name]['limits']['max_total_lines']
prior_paths=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--','docs/decisions'],cwd=ROOT,text=True).splitlines()
assert all(p.endswith('.md') for p in prior_paths)
assert max(int(Path(p).name[:4]) for p in prior_paths if Path(p).name[:4].isdigit())==135
assert len(prior_paths)==before['decisions']['limits']['max_files']
prior_lines=sum(old(p).count(b'\n') for p in prior_paths)
assert prior_lines==before['decisions']['limits']['max_total_lines']
index_row= ('| [0136](0136-finite-continuity-capacity.md) | One finite change-history member and note envelope | '
    '2026-10-19 | accepted engineering maintenance; canonical admission required | history, capacity, verification |\n').encode()
index_before=old(INDEX);last=re.findall(rb'^\| \[0135\].*\n',index_before,re.M)
assert len(last)==1 and index_row not in index_before
index_after=index_before.replace(last[0],last[0]+index_row,1)
assert index_after.index(index_row)<index_after.index(b'\n## How to add a record')
assert index_after.count(b'\n')-index_before.count(b'\n')==1
after['decisions']['limits']['max_files']+=1
def contract(row):
    names=('authority','control','lifecycle','member_limits','members','owner','route_targets','state','verifier')
    return {**{k:row.get(k) for k in names},'transition_owners':row.get('transition',{}).get('owners')}
def decision():
    text=('# ADR 0136: Finite continuity capacity\n\n- Date: 2026-10-19\n'
        f'- Status: accepted engineering maintenance under `{LEAF}`; exact canonical admission required\n'
        '- Tags: history, capacity, continuity, verification\n\n')
    for name in ('change_history','engineering_notes','decisions'):
        text+=(f'## Exact {name} authorization\n\n- Routed surface: `{name}`\n'
            f'- Previous routed limits: `{compact(before[name]["limits"])}`\n'
            f'- New routed limits: `{compact(after[name]["limits"])}`\n\n')
        if name=='change_history':
            text+=(f'- Previous routed contract: `{compact(contract(before[name]))}`\n'
                f'- New routed contract: `{compact(contract(after[name]))}`\n\n')
    text+=('## Context and decision\n\n'
        'The required complete records trigger one actual change-history rollover and exceed the exhausted '
        'engineering-note aggregate. Unchanged production limits reject the resulting member, exact manifest '
        'line/byte growth and note lines. Every accepted archive and original compiler proof remains recoverable; '
        'routing already reaches its canonical owners, and editing, deleting or repacking immutable history cannot supply capacity.\n\n'
        'Under full PNT and ADR0128/0129/0130/0131/0132/0133/0134/0135 engineering-maintenance precedent, '
        'admit only this measured change-history member/manifest increment and exactly one existing512-line '
        'hot-shard envelope of aggregate engineering-note lines. The concrete continuation is this maintenance, '
        'due metadata-only artifact review, private fixture admission .7, pipeline .6 and metadata .3.2.1.12, '
        'including bounded child splits within that finite envelope. This is no new or reused director grant.\n\n'
        'The decision collection admits only this sole file and its exact physical lines plus one index row. '
        'All root, byte, per-file, engineering membership/manifest and unrelated limits stay exact. '
        'Stable responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 under ADR0069. '
        'No future archive member or unlimited PNT reserve is granted; another exhausted allowance needs its own decision.\n\n'
        '## Verification and consequences\n\n'
        'Retain actual old-cap refusals with complete original-project data/helper/config/namespace and historical '
        'fixture inputs; reconstruct the exact complete clean-source suffix/root/manifest/blob/range/digest and '
        'all prior history/decision bytes independently. Preserve the whole565-input/129686-byte compiler publication '
        'and actual baseline at its real accepted Git boundary. Unchanged production functions distinguish '
        'inclusive numeric and accepted/indexed/exact-object authority alternatives; actual artifact corruptions '
        'must reject and restore. Full current Knowledge/book and exact staged canonical CI/receipt plus normal hooks govern admission.\n\n'
        'Runtime, test, checker and dependency implementations remain unchanged. Other repositories/submodules '
        'stay read-only black boxes; startup.7 recovery/purge restrictions remain. '
        f'Owner: docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md; readonly review: `{PREFIX}publish.py` '
        'through tools/run_python_project_data.sh. Due artifact review follows the clean capacity boundary.\n')
    return text.encode()
for _ in range(5):
    adr=decision();allowance=prior_lines+adr.count(b'\n')+1
    if after['decisions']['limits']['max_total_lines']==allowance:break
    after['decisions']['limits']['max_total_lines']=allowance
else:raise AssertionError('sole authority line fixed point')
adr=decision();assert adr.count(b'\n')+1==after['decisions']['limits']['max_total_lines']-prior_lines
assert {name for name in before if before[name]!=after[name]}=={'change_history','engineering_notes','decisions'}
registry_after=b''.join((compact(after[row['id']]).encode()+b'\n') if row.get('id') in ('change_history','engineering_notes','decisions') else line for line,row in zip(lines,rows))
values={REG:registry_after,INDEX:index_after,ADR:adr}
record=dict(result='prepared',base=BASE,producer_sha256=sha(Path(__file__).read_bytes()),measurement_sha256=sha(measured_raw),
    old_limits={n:before[n]['limits'] for n in ('change_history','engineering_notes','decisions')},
    new_limits={n:after[n]['limits'] for n in ('change_history','engineering_notes','decisions')},
    old_contract=contract(before['change_history']),new_contract=contract(after['change_history']),
    changed={p:dict(sha256=sha(v),bytes_base64=encode(v)) for p,v in values.items()},
    measured=dict(change_history=changes,engineering_notes=engineering,manifest=manifest),
    engineering_envelope=envelope,decision_physical_lines=adr.count(b'\n'),index_added_lines=1,
    scope='One actual change-history member, exact manifest growth, one finite512-line note aggregate envelope and sole ADR/index overhead. Every other registry scalar/contract and every prior immutable byte stay exact; no future archive reserve or runtime/checker change. Canonical staged admission remains separate.')
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
for p,value in values.items():(ROOT/p).write_bytes(value)
record['result']='PASS';record['measured']['decisions']=metrics(sorted(p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/decisions').glob('*.md')))
assert record['measured']['decisions']['files']==after['decisions']['limits']['max_files']
assert record['measured']['decisions']['lines']==after['decisions']['limits']['max_total_lines']
target.write_text(json.dumps(record,indent=2)+'\n')
print('Finite continuity proposal PASS: one measured member/manifest;512 aggregate note lines;',adr.count(b'\n')+1,'sole decision/index lines')
