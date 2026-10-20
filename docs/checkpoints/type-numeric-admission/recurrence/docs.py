"""Keep the current historical-audit fact and handoff docs bounded and source-aligned."""
import gzip
import json
import sys
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[2]/'type-numeric-codeblocks'))
import common as c
PREFIX='docs/checkpoints/type-numeric-admission/recurrence/'
CARD='docs/knowledge/phase0-compiler-scanner-mock-historical-inverse.md'


def main():
    result=json.loads(gzip.decompress((c.ROOT/(PREFIX+'historical-final-review.json.gz')).read_bytes()))
    assert result['result']=='PASS' and result['original_controls']['governance_mutations_rejected']==578
    assert result['current_controls']['governance_mutations_rejected']==644
    faults=json.loads(gzip.decompress((c.ROOT/(PREFIX+'source-fault-review.json.gz')).read_bytes()))
    assert faults['result']=='PASS' and faults['source_restored']
    paths=(CARD,'MEMORY.md','CHANGES.md','DEVELOPMENT_NOTES.md','LIVE_ACHIEVEMENT_STATUS.md',
           'ROADMAP_V2.md','docs/TASK_TREE.md','docs/tasks/TYPE-REFERENCE-BOOK.md',c.PREFIX+'README.md',PREFIX+'README.md')
    before={path:c.read(path) for path in paths}
    changes={}
    old=c.decode(before[CARD]['base64']).decode()
    front=old.split('---\n',2)[1]
    front=front.replace('date: 2026-10-19','date: 2026-10-20',1)
    front=front.replace('date: 2026-10-20','  - "how are numeric Phase0 value regressions reconciled with historical evidence"\ndate: 2026-10-20',1)
    start=front.index('evidence: ');end=front.index('\nreverify:',start)
    front=front[:start]+('evidence: "Dated scanner admission .0.2.2 rejects committed .0.2.1; original auditor reproduces. Exact Git mock inverse,5 source controls, isolated134 inputs/84613241 bytes/22 recovery controls/60 evolution denials and zero healthy original-log/tracked writes. Numeric5 preserves578 controls and adds66; two actual auditor faults restore."')+front[end:]
    front=front.replace('docs/checkpoints/type-evaluated-values/publish.py','docs/checkpoints/type-numeric-codeblocks/publish_recurrence.py',1)
    body='''
`af5d19971a1682f6895901fb769ff41b69842672` changes one Phase0 mock from
`scan_contract_ir_events` to `_scan_executable_contract_ir_events`; its parent is
`31395e440a38acec7a6712d470a90a90a6567863`. The missing inverse stopped canonical
acceptance before runtime CI.

The compiler inverse proves the entire Git blobs differ by that entry, requires
one registration, reverses it, then older inverses must recover the original
file/hash. Missing, duplicated, disabled, foreign and unrelated edits reject.
Historical hashes, milestones, logs, claims and Perl tests are never refreshed.
The acceptance owner retains failed CI/candidate, original auditor and corrected
proof; `.0.4` owns later ledger work. [[historical-objective-audit-input-recovery]]
defines the unchanged archive/guard contract. This checks evidence, not old runtime.

Evaluated-value owner3 inverses70 reviewed fragments from real c053 source.
All368 prior controls,210 added fragment denials and a valid-JSON whitespace
identity fault remain effective. Its first KeyError/two-reference correction
stays in docs/checkpoints/type-values-signature/.

Numeric owner5 inverses21 value assertions plus their shared frame before old70,
whose hunk3 overlaps. Reconstruction uses real accepted203cde315 before bytes;
all22 current fragments must occur once. Preserve578 older controls on their
pre-numeric stage; add66 current numeric denials. Missing-inverse/blind-restore
producer faults reject and restore, as does semantically identical JSON with
changed whitespace. The isolated producer explicitly closes the new table.
Archive134/84613241 bytes,22 recovery controls and zero healthy original-log or
tracked-write attempts remain exact. The separate numeric KeyError and correction
retain full source/channels. Both reverify routes are readonly.
'''
    card='---\n'+front+'---\n'+body
    assert len(card.encode())<=len(old.encode()),(len(old.encode()),len(card.encode()))
    changes[CARD]=card.encode()
    for path in ('MEMORY.md','CHANGES.md',c.PREFIX+'README.md'):
        text=c.decode(before[path]['base64']).decode().replace('type-numeric-codeblocks/publish_final.py','type-numeric-codeblocks/publish_recurrence.py')
        if path=='MEMORY.md':
            text+='- historical_admission: Canonical2 historical overlap is reconciled by exact22-fragment inverse before old70. All578 controls survive;66 new denials,134 recovered inputs/22 controls/zero read-write guard and two actual auditor faults pass. Whole second10162-input draft/readonly0 and10175 staged source images remain in the recurrence checkpoint.\n'
        if path=='CHANGES.md':
            at=text.index('\n## ',text.index('\n## ')+1)
            text=text[:at]+'\nCanonical2 reaches historical evidence recovery, exposing one overlapping Phase0 registration. Exact22-fragment numeric inversion precedes old70; all578 existing controls remain effective and66 new denials pass. Archive134/84613241 bytes,22 recovery controls and read/write guards stay exact. Two actual auditor faults restore. Whole second10162-input draft/readonly0 and10175 Git-verified staged source images survive. Runtime/book and historical observations are unchanged by this prerequisite.\n'+text[at:]
        if path==c.PREFIX+'README.md':
            text+='\n## Historical recurrence admission\n\nCanonical2 passes all10 doctrines and syntax, then rejects prior inverse hunk3\nof70 after the numeric Phase0 migration. The exact22-fragment numeric inverse\nnow precedes old70. All578 earlier reason-sensitive controls remain;66 new\ndenials pass. The isolated archive remains134 inputs/84613241 bytes with22\nrecovery controls and zero healthy original-log/tracked-write attempts. Two\nactual auditor faults reject and restore. The first added loop KeyError is kept\nas preparation failure. Whole second10162-input draft/actual readonly0 and10175\nGit-verified staged source images, full before packets and every producer/result\nremain in type-numeric-admission/recurrence/. This source-image representation\nreuses immutable primary bytes rather than duplicating existing archive streams.\nCurrent reader successors admit only exact reviewed auditor/proof changes and\nrecover old owner/input bytes explicitly; all older producers stay unchanged.\nNo historical hash, milestone, log or runtime observation is refreshed.\n'
        changes[path]=text.encode()
    path='DEVELOPMENT_NOTES.md';text=c.decode(before[path]['base64']).decode();at=text.index('\n## ',text.index('\n## ')+1)
    note='\nThe historical auditor must unwind the latest numeric22-fragment source evolution before its older70-fragment inverse. Normalize the baseline of old reason-sensitive falsifiers to their original stage, then test current numeric fragments separately; this preserves578 controls and adds66 instead of masking old errors. The current isolated proof closes the new table explicitly and retains134/84613241/22 with zero healthy original-log/tracked writes. Two actual skipped/blind inverse faults reject and restore. The initial loop row-shadowing KeyError remains a failed preparation epoch. Whole second draft/actual readonly0 and10175 exact staged source images use retained primary bytes plus full changed before-images; no fictional draft Git revision or duplicated archive stream is required.\n'
    changes[path]=(text[:at]+note+text[at:]).encode()
    path='LIVE_ACHIEVEMENT_STATUS.md';text=c.decode(before[path]['base64']).decode()
    text=text.replace('Exact staged canonical receipt governs landing.', 'Historical numeric inverse22 preserves578 controls and adds66; archive134/22 and two auditor faults pass. Whole second draft/readonly0 and exact source images survive. Exact staged canonical receipt governs landing.',1)
    changes[path]=text.encode()
    path='ROADMAP_V2.md';text=c.decode(before[path]['base64']).decode();text=text.replace('Exact canonical receipt governs landing.', 'Historical inverse22 preserves578 controls and adds66; source faults/archive guards pass. Exact canonical receipt governs landing.',1);changes[path]=text.encode()
    path='docs/TASK_TREE.md';text=c.decode(before[path]['base64']).decode();oldrow='Prior4 scope qualified; fresh accepted replay14/1924.';assert text.count(oldrow)==1;text=text.replace(oldrow,'Prior4 qualified/replayed; historical inverse22/66 preserves578 controls.',1);changes[path]=text.encode()
    path='docs/tasks/TYPE-REFERENCE-BOOK.md';text=c.decode(before[path]['base64']).decode()
    old='Prior4 qualified/replayed; canonical1 dual-owner correction in type-numeric-admission/.'
    assert text.count(old)==1
    text=text.replace(old,'Prior4 qualified; admission/inverse22/66: type-numeric-admission/.',1)
    assert len(text.encode())<=65536
    changes[path]=text.encode()
    path=PREFIX+'README.md';text=c.decode(before[path]['base64']).decode()
    text+='\nCompleted: numeric inverse22 precedes old70; unchanged original578 and current644\ncontrols pass. Archive134/84613241/22 and healthy read/write guards0 remain exact.\nTwo actual auditor faults reject and restore. The valid-JSON whitespace table\ncontrol rejects. Initial row-shadowing KeyError/source are retained separately.\nThe exact source-image inventory recovers every old staged byte from immutable\nprimary files or its full before packet; the extra proof before image is in\nimplementation.json.gz. New reader successors require the exact audited source\nversions and keep every prior producer/result. Current publication is the\nnumeric publish_recurrence.py entry point. No runtime or old observation refresh.\n'
    changes[path]=text.encode()
    value=dict(before=before,after={path:c.encode(raw) for path,raw in changes.items()},producer=c.read(PREFIX+'docs.py'),
        card_bytes=dict(before=len(c.decode(before[CARD]['base64'])),after=len(changes[CARD])),
        scope='Preserve all older fact claims in a shorter current card; add the verified numeric inverse and '
              'source-image custody. Live docs point to the distinct current reader; no public behavior change.')
    with (c.ROOT/(PREFIX+'docs-proposals.json.gz')).open('xb') as out:out.write(gzip.compress((json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0))
    for path,raw in changes.items():(c.ROOT/path).write_bytes(raw)
    print('Historical Knowledge/live docs aligned; card bytes:',value['card_bytes'])


if __name__=='__main__':
    main()
