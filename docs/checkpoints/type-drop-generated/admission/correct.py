"""Refresh the affected fact routes without coupling history to a frozen publisher."""
import sys
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[1]))
import common as c

FACT='docs/knowledge/phase0-compiler-scanner-mock-historical-inverse.md'
TYPE='docs/knowledge/terse-type-method-surface-inventory.md'


def main():
    first=c.load('admission/first.json.gz')
    assert c.unchanged(first['inputs'])
    before=first['before']
    assert all(c.read(path)==packet for path,packet in before.items())
    fact='''---
id: phase0-compiler-scanner-mock-historical-inverse
title: "Historical Phase0 audits admit exact reviewed source inverses"
answers:
  - "why did canonical membership acceptance reject unreviewed signature-regression drift"
  - "which historical audit owner admits the Phase0 compiler scanner mock change"
  - "how is the compiler scanner mock delta reconciled without refreshing historical hashes"
  - "does historical Phase0 normalization allow unrelated source edits"
  - "how are numeric Phase0 value regressions reconciled with historical evidence"
  - "how are drop key Phase0 regressions reconciled with historical evidence"
date: 2026-10-20
status: current
tags: [historical-audit, phase0, source-evolution, compiler, claims]
evidence: "Scanner five source controls/60 dated denials; evaluated368+210, numeric578+66, drop644+6. Archive134/84613241/22 and zero log/write escapes; auditor faults/table identity restore."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py"
---

`af5d19971a1682f6895901fb769ff41b69842672` replaces the Phase0 mock
`scan_contract_ir_events` with `_scan_executable_contract_ir_events`; parent
`31395e440a38acec7a6712d470a90a90a6567863`. Its missing inverse stopped
canonical admission before runtime CI. Entire Git blobs must differ by that one
entry; require one registration, reverse it, then recover the original file/hash.
Missing, duplicated, disabled, foreign and unrelated edits reject. Original auditor/candidate/gate/correction stay retained; .0.4 owns ledger work.
[[historical-objective-audit-input-recovery]] fixes archive/guard invariants.
Historical hashes, milestones, logs and runtime results never refresh.

Evaluated owner3 inverses70 fragments from real c053 source:368 original controls
plus210 denials and a valid-JSON whitespace identity fault. Its KeyError and
two-reference correction remain under docs/checkpoints/type-values-signature/.

Numeric5 inverses21 value assertions/shared frame before old70 (hunk3 overlaps),
from accepted203cde315 bytes. Each22-fragment
registration occurs once. Keep578 controls on their pre-numeric stage; add66.
Missing/blind inverse faults and semantically identical changed JSON reject and
restore. The isolated producer closes the table; the numeric KeyError/correction
retain exact source/channels. Its publisher is historical at accepted9fc95b0bd:
restore its recorded Git inputs before invoking that older command.

Drop owner6 inverses two complete subtests before numeric22/evaluated70. Keep644
controls on their pre-drop stage; add six omission/duplication/corruption denials.
The actual producer closes the drop table; two auditor faults and semantic JSON
byte-identity denial restore. Archive134/84613241 bytes,22 recovery controls and
zero original-log/tracked writes stay exact. Reverify uses the composed producer,
not old runtime. The stale-route RED and whole first drop draft/readonly0 survive
under docs/checkpoints/type-drop-generated/admission/.
'''
    assert len(fact.encode())<=len(c.decode(before[FACT]['base64'])),(len(fact.encode()),len(c.decode(before[FACT]['base64'])))
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items() if path!='KNOWLEDGE_MAP.md'}
    after[FACT]=fact
    for path in (TYPE,'MEMORY.md',c.PREFIX+'README.md'):
        old=c.PREFIX+'publish.py'
        assert old in after[path],path
        after[path]=after[path].replace(old,c.PREFIX+'publish_final.py')
    after['docs/tasks/TYPE-REFERENCE-BOOK.md']=after['docs/tasks/TYPE-REFERENCE-BOOK.md'].replace(
        '  Commit subject: `TYPE-REFERENCE-BOOK.1.2.6 - materialize generated drop keys`;',
        '  Final admission: stale historical-fact route RED; drop inverse/current reader corrected. Whole first10304 draft/readonly0/source images and superseded canonical143 retained under admission/.\n'
        '  Commit subject: `TYPE-REFERENCE-BOOK.1.2.6 - materialize generated drop keys`;',1)
    after['MEMORY.md']+='- admission: Current historical-fact route uses its composed producer; first10304-input unpublished drop draft/actual readonly0 and exact staged images survive in admission/. Superseded canonical143 precedes bound edits; final publication/receipt govern landing.\n'
    for path in ('CHANGES.md','DEVELOPMENT_NOTES.md'):
        start=after[path].index('## 2026-10-20 — TYPE-REFERENCE-BOOK.1.2.6')
        end=after[path].index('\n## ',start+1)
        note=('\nFinal review corrected the historical card\'s unqualified frozen numeric reverify and recorded drop-before-numeric normalization. Whole first drop publication/10304 inputs/full modes/actual readonly0 and exact staged images remain in admission/; its canonical run was deliberately superseded143 before bound changes. Current history reverify uses the composed producer, avoiding coupling to a frozen whole-project publisher.\n')
        after[path]=after[path][:end]+note+after[path][end:]
    after['LIVE_ACHIEVEMENT_STATUS.md']=after['LIVE_ACHIEVEMENT_STATUS.md'].replace(
        'Exact staged canonical receipt governs landing. Aggregates7,',
        'Final historical-card route correction retains whole first10304 draft/readonly0 and superseded canonical143. Exact final staged receipt governs landing. Aggregates7,',1)
    after[c.PREFIX+'README.md']+='''
Final fact admission: the current historical card's unqualified numeric publisher
route fails against later inputs. Its actual RED is retained; current history
reverify uses the composed producer and documents drop2 before numeric22/old70.
The first unpublished drop claim/publication/10304 inputs/full modes/actual
readonly0 and exact staged images remain in admission/first.json.gz, with whole
before-images for every corrected file. Original publication.json and its input
manifest remain untouched draft evidence. Canonical143 was deliberately stopped
before bound edits; publish_final.py and its exact receipt govern current landing.
'''
    assert len(after['docs/tasks/TYPE-REFERENCE-BOOK.md'].encode())<=65536
    c.write_new('admission/correction.json.gz',dict(before=before,
        after={path:c.encode(text.encode()) for path,text in after.items()},
        producer=c.read(c.PREFIX+'admission/correct.py'),
        scope='Current composed-history reverify replaces the unqualified frozen numeric route; record '
              'drop2 before numeric22/evaluated70 without altering auditor/runtime/test bytes. Preserve '
              'all original fact bytes and first unpublished claim/actual readonly0. Current type/Memory '
              'point to the distinct final drop publication. No fictional draft revision.'))
    for path,text in after.items():(c.ROOT/path).write_text(text)
    print('Historical fact and current type/pointer corrected; historical card bytes',len(fact.encode()))


if __name__=='__main__':main()
