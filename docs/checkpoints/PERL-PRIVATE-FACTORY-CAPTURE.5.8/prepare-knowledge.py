"""Route thirteen existing cards and condense only the preserved finite-history card."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE='54bb5eb65178a57ac6e61e53324c9291863e716d'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.8/'
CARD='docs/knowledge/finite-engineering-notes-member-0131.md'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
target=ROOT/(PREFIX+'knowledge-preparation.json');assert not target.exists()
preserved=json.loads((ROOT/(PREFIX+'preservation.json')).read_bytes())
cards=sorted(p for p in preserved['owned_bound_paths'] if p.startswith('docs/knowledge/'))
assert len(cards)==13
originals={p:subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT) for p in cards}
values={}
for p,value in originals.items():
    assert (ROOT/p).read_bytes()==value
    old=b'Readonly: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/publish.py. Prior inputs:ce9eaf32e.'
    new=b'Readonly: bash tools/run_python_project_data.sh '+PREFIX.encode()+b'publish.py. Prior inputs:54bb5eb65.'
    assert value.count(old)==1
    values[p]=value.replace(old,new,1)
body=values[CARD].decode()
body=body.replace('title: Finite engineering-history admissions preserve exact archives and prior proof',
    'title: Finite continuity admissions preserve exact archives and prior proof',1)
body=body.replace('date: 2026-10-17','date: 2026-10-19',1)
body=body.replace('status: ADR0135 finite engineering admission verified; prior accounts preserved',
    'status: ADR0136 finite continuity proof; exact canonical receipt governs landing',1)
body=body.replace('  - "where is the current finite engineering history review"',
    '  - "where is the current finite engineering history review"\n  - "which decision admits change history segment 4962"\n  - "why does engineering notes allow 30024 aggregate lines"',1)
start=body.index('evidence: ');end=body.index('\n',start)
body=body[:start]+'evidence: "ADR0136 admits one measured change-history member/manifest, one512-line note envelope and41 sole decision/index lines. Whole565/129686 proof and230 prior files are preserved. Actual old-cap RED and corrected60/31 production controls precede canonical admission."'+body[end:]
start=body.index('## Current finite admission: ADR0135')
end=body.index('# The next finite admission: ADR0133',start)
replacement='''## Current finite continuity: ADR0136

At clean54bb5eb65, required complete records cross change-history rollover and
the exhausted engineering aggregate. Segment4962 preserves source lines109–365:
257 lines/26898 bytes; the current root retains111 lines/32530 bytes. Unchanged
limits reject the actual new member/manifest and29516 note lines.

ADR0136 admits change-history files50→51, manifest49→50 lines/27983→28559 bytes,
engineering aggregate29512→30024 lines and decisions136→137 files/13285→13326
lines: one40-line ADR plus one index row. The512-line note envelope covers the
declared maintenance, due artifact review, fixture .7, pipeline .6 and metadata
continuation/bounded splits. Other limits remain exact; no archive reserve follows.

All230 prior history/decision files and whole565-input/129686-byte compiler
publication remain preserved with actual baseline at the real Git boundary.
Original-project1980/1981 input snapshots retain actual rollover/old-cap channels.
The first arithmetic/authority instrument used the wrong two census manifests;
its passing output is independently rejected. Exact two-line correction has actual
census equality,60 inclusive numeric observations/31 authority REDs and exact
readonly output recurrence. Complete Knowledge/book and staged canonical receipt
govern admission; no runtime, checker or dependency implementation changes.

## Earlier current accounts

ADR0135 preserves segment4960's272-line suffix,113-line/32492-byte root and228
prior files. Its member/manifest and35 decision/index lines grant no later reserve.
ADR0133's pointer repair preserves the accepted d95a25c8b account and actual
supplied publisher replay; old logical inputs remain required. Whole original
headers/bodies are recoverable at54bb5eb65 and in this leaf's preparation record.
The older dated bodies below remain exact.

'''
body=body[:start]+replacement+body[end:]
values[CARD]=body.encode()
paths=sorted(p for p in (ROOT/'docs/knowledge').glob('*.md') if p.is_file())
total=sum(len(values.get(p.relative_to(ROOT).as_posix(),p.read_bytes())) for p in paths)
assert total<=8388608,('prewrite Knowledge budget',total)
record=dict(result='PASS',base=BASE,producer_sha256=sha(Path(__file__).read_bytes()),knowledge_bytes=total,
    originals={p:dict(bytes_base64=encode(v),sha256=sha(v)) for p,v in originals.items()},
    current={p:sha(v) for p,v in values.items()},
    scope='All thirteen whole original cards are retained before route writes. Twelve bodies stay exact; only the finite-history card condenses preserved prior accounts and adds current ADR0136 facts. No fact card or budget is added; complete current scan and derived map follow separately.')
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
for p,value in values.items():(ROOT/p).write_bytes(value)
print('Knowledge preparation PASS:',total,'bytes;13 cards/one body;whole original cards retained')
