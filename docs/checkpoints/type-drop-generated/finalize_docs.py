"""Prepare the bounded, reviewable per-leaf commit handoff after focused proof."""
import common as c
import review

TASK='docs/tasks/TYPE-REFERENCE-BOOK.md'
INDEX='docs/TASK_TREE.md'
SUBJECT='TYPE-REFERENCE-BOOK.1.2.6 - materialize generated drop keys'


def main():
    result=review.check(fresh=False)
    paths=['MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md','CHANGES.md','DEVELOPMENT_NOTES.md',TASK,INDEX,c.PREFIX+'README.md']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    after['MEMORY.md']=f'''# MEMORY

- activation_commit: `{c.BASE}` — clean drop6 activation; derive latest identity from Git.
- latest_completed_leaf: `{c.OWNER}` — subject `{SUBJECT}`.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.7` (next; activate only from clean Git after the readonly drop baseline).
- task_owner: `{TASK}`.
- next_action: Run {c.PREFIX}publish.py readonly from clean Git to ignored baseline log/status; preserve its whole claim, publication, closed manifest/full modes and actual clean baseline before aggregate7 writes. Then reconcile and repair the deferred reducer family.
- in_flight_uncommitted: none in the intended clean post-landing handoff; Git is authoritative.
- blockers: no director input required; aggregates7 -> operation inventory1/book mapping2/layout3.
- current_proof: {c.PREFIX}README.md; claim docs/claims/{c.OWNER}.json. Fixed48 public cases:34 desired values/14 diagnostic controls;4 actual emitter faults restored. Normal/FATAL syntax profiles remain enforced. Exact staged canonical receipt and normal hooks govern landing.
- evidence: Direct9 suites/1322 TAP, five selected real Phase0 roots including18 permanent assertions; book89/three executed examples/heading RED; Knowledge in sync. Source/arity/null diagnostics survive; no portable reference-key coercion admission.
- historical_admission: Exact two-subtest drop inverse precedes numeric22/older70; all644 prior controls plus6 pass. Archive134/84613241 bytes,22 recovery controls and zero original-log/tracked writes remain exact; two auditor faults and semantic table-byte denial restore.
- custody: Whole numeric5/10202 inputs/full modes and actual clean readonly0 remain at real accepted9fc95b0bd. Failed shape/selector/oracle preparations, intentional receiver-copy TAP diagnostic and hash-gated missing README draft recovery are retained. No fictional draft Git revision or silently refreshed observation.
- known_defects: Deferred aggregates7, startup20 numeric grammar,32 caller shadowing,35 callback boolean-literal kinds and87.4 grouping remain owned. Drop6 repairs warnings, splices, key snapshots and typed key shapes. No full family/backend/private-parent admission.
- canonical_environment: Start CI/public quiet wrappers through approved host execution; never weaken or bypass the profile.
- cleanup: Latest2026-10-20T04:06:20.726688+00:00; docs/ARTIFACT_CLEANUP.md owns the latest record. Caches and other repositories retained.
- deferred: .1.2.7 -> operation inventory .1.2.1 -> book mapping .1.2.2 -> layout .1.3 -> legacy .8 -> metadata QA .13 -> remaining references/closeout.
- standing_limit: Other repositories and RGX/PGEN remain read-only black boxes. All project data stays on this volume; no internal procedures or pin changes.
- sequence: Full PNT continues, one normal commit per completed leaf. No push yet.
'''
    record='''## 2026-10-20 — TYPE-REFERENCE-BOOK.1.2.6 — Materialize generated drop keys

Perl drop_keys captures each key before the next operand runs, lowers explicit flat splices and typed shapes, and deletes a private key list from a copied harray. Scalar generated calls load without the old compiler advisory under normal/FATAL syntax profiles. The accepted48-case baseline retains10 native/28 normal/28 fatal desired-value failures; current34 desired values plus14 diagnostic controls pass, preserving source/arity/null behavior. Four actual emitter faults reject and restore;9 suites/1322 TAP, five focused Phase0 roots with18 permanent assertions and book89/3/heading control pass. Two exact subtest inverses precede numeric22/older70:644 old controls plus6, archive134/84613241 bytes/22 and zero healthy read/write escapes remain exact; two auditor faults/table-byte denial restore. Whole numeric publication/10202 inputs/actual clean readonly0 and all failed preparations remain retained; a missing untracked README before-image is recovered against its prior hash. Claim/checkpoint: docs/checkpoints/type-drop-generated/. Exact staged canonical receipt governs landing; aggregates7 remains next.

'''
    notes='''## 2026-10-20 — TYPE-REFERENCE-BOOK.1.2.6 — Drop key evaluation and historical stages

A named private key list avoids Perl's scalar hash-slice syntax advisory without changing warning policy. Materialize each operand independently: assigning the whole list only after evaluating its members retains Perl aliases and lets a later callback change an earlier key. Explicit flat splices need their list producer before scalar access lowering; typed hash shapes must not leak DSL colons to host Perl. Source copying still precedes key evaluation. Underlying invalid-source and uninitialized-key diagnostics remain separate from the repaired compiler advisory.

Historical source normalization unwinds the two exact drop-containing subtests before numeric22 and evaluated70. Old644 reason-sensitive controls use the original pre-drop stage; six new denials exercise the two complete registrations. The actual isolated producer closes the new table, preserving original hashes/archive/read-write guards. Retain failed preparations, including the incomplete first selector, diagnostic-oracle assumptions and first raw-shape candidate. An existing explicit receiver-copy TAP JSON diagnostic is parsed whole, rather than suppressed or treated as a compiler warning. A sole missing untracked README draft is reconstructed by reversing its exact wording edit and matching its independently retained pre-edit SHA-256/mode. Current proof is docs/checkpoints/type-drop-generated/publish.py; no aggregate, portable key-coercion or exhaustive family admission follows.

'''
    for path,new in [('CHANGES.md',record),('DEVELOPMENT_NOTES.md',notes)]:
        position=after[path].index('\n## ')+1
        after[path]=after[path][:position]+new+after[path][position:]
    live=after['LIVE_ACHIEVEMENT_STATUS.md']
    prefix=live.split('## Recent Completions\n',1)[0]
    current='''# LIVE ACHIEVEMENT STATUS

## Current Activity

TYPE-REFERENCE-BOOK.1.2.6 completes bounded generated-drop repair; deferred aggregates .1.2.7 is next from clean Git.

## Latest Completed Slice

Generated Perl drop_keys uses copied harrays and captured key lists, removing scalar syntax advisories and repairing explicit splices, callback key ordering and raw typed-key shapes. Fixed48 public cases retain the accepted failures; current34 desired values/14 diagnostic controls and four actual emitter faults/restorations pass. Direct9 suites/1322 TAP, five focused Phase0 roots with18 permanent assertions, book89/three executed examples/heading RED and Knowledge pass. Exact two-subtest historical inverse preserves644 old controls and adds6; archive134/84613241 bytes/22 controls/zero read-write escapes remain exact. Two auditor faults/table-byte denial restore. Whole numeric5/10202 publication and actual clean readonly0 survive. Rejected preparation epochs and hash-gated README draft recovery remain explicit. Exact staged canonical receipt governs landing. Aggregates7, startup20/32/35/87.4 and full reference admission remain owned.

## Next Action

From clean Git, run the current drop readonly publication; preserve its whole claim, publication, manifest/full modes and actual baseline before aggregate7 writes. Continue full PNT through the reducer family, operation inventory and book mapping. No push yet.

'''
    live=current+live[len(prefix):]
    recent,history=live.split('\n## History\n',1)
    header,rows=recent.split('## Recent Completions\n',1)
    entries=[line for line in rows.splitlines() if line.startswith('- ')]
    entries.insert(0,'- `TYPE-REFERENCE-BOOK.1.2.6` —34 value/14 diagnostic controls;4 faults;9/1322; five Phase0 roots/18 permanent;book89/3; historical644+6; aggregates7 next.')
    after['LIVE_ACHIEVEMENT_STATUS.md']=header+'## Recent Completions\n\n'+'\n'.join(entries[:16])+'\n\n## History\n'+history
    node=f'''- ID: `{c.OWNER}`
  Status: `done` / bounded Perl drop producer repair
  Goal: Quiet scalar-key generated loading with copied harrays and evaluated key lists.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.5`
  Evidence/custody: docs/checkpoints/type-drop-generated/README.md; accepted9fc95b0bd, whole prior10202/actual clean readonly0, exact draft bytes/full modes and rejected preparations retained. Same-producer splice/late-key/raw-shape defects are fixed; sole metadata before-image gap is hash-gated recovered.
  Verification tier: `canonical`
  Focused checks: Fixed48 descriptor/Get/lowering/fresh normal/FATAL routes;34 values/14 diagnostic controls;4 emitter faults;9 suites/1322 TAP; five real Phase0 roots with18 permanent assertions; book89/3/heading RED; exact historical644+6/134/22 and2 auditor faults/table denial; Knowledge.
  Canonical trigger: Observable generated compiler diagnostic; exact staged-candidate receipt required before normal landing.
  Claim verification: `docs/claims/{c.OWNER}.json`
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Accepted public warning/FATAL, splice and snapshot failures retained.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Toolbox output identifies MethodLowering drop list/scalar/shape producer.
  - [x] **FIX** — Materialized private key list, explicit splice/shape lowering; copied source preserved.
  - [x] **ADDRESSED (verified)** — Independent values, normal/FATAL syntax and four actual producer RED/restoration controls.
  - [x] **NO REGRESSION** — Direct/Phase0/history proof; canonical receipt enforced for landing.
  - [x] **LOCKSTEP** — Worked book examples/fact/live docs; source/arity/null diagnostics preserved. No portable key-coercion/family/backend admission.
  Commit subject: `{SUBJECT}`; next aggregate7 after clean readonly preservation.

'''
    start=after[TASK].index('- ID: `'+c.OWNER+'`\n');end=after[TASK].index('- ID: `TYPE-REFERENCE-BOOK.1.2.7`\n',start)
    after[TASK]=after[TASK][:start]+node+after[TASK][end:]
    old='| 4 | `TYPE-REFERENCE-BOOK.1.2.6` | `in_progress` | P2 generated scalar-drop warning/FATAL correction. |'
    assert after[TASK].count(old)==1
    after[TASK]=after[TASK].replace(old,'| 4 | `TYPE-REFERENCE-BOOK.1.2.6` | `done` | Quiet generated drop, splices/key snapshots;7 next. |',1)
    lines=after[INDEX].splitlines(keepends=True)
    old=next(line for line in lines if line.startswith('| `TYPE-REFERENCE-BOOK` |'))
    new='| `TYPE-REFERENCE-BOOK` | `active` / aggregates .1.2.7 next | `.spec documentation / per-type reference` | Generated-drop6:34 values/14 diagnostic controls,4 faults/restorations,9/1322,book89/3; exact historical644+6/134/22 preserved. Whole numeric10202/readonly0 retained; normal/FATAL policy unchanged. Exact canonical receipt governs landing. Aggregates7 precedes inventory1/book mapping2/layout3/legacy8; no exhaustive admission. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |\n'
    after[INDEX]=after[INDEX].replace(old,new,1)
    after[c.PREFIX+'README.md']='''# Generated drop key evaluation repair

Owner: TYPE-REFERENCE-BOOK.1.2.6; clean activation9fc95b0bd1167db110e91bf50a8939129485c960.
Readonly proof: `bash tools/run_python_project_data.sh docs/checkpoints/type-drop-generated/publish.py`.

MethodLowering materializes each key before its next sibling, lowers explicit
flat splices and typed shapes, and deletes a private key list from a copied harray.
Scalar-key normal/FATAL syntax loading is quiet. Existing source/arity/null
diagnostics remain; no portable reference-key coercion or whole-family admission.
Deferred aggregates7 and the complete inventory remain separate owners.

Fixed48 public cases retain accepted10 native/28 normal/28 fatal value failures.
Current34 desired values/14 diagnostic controls pass; four actual emitter faults
and restorations distinguish warning, alias, splice and shape mechanisms.
Nine direct suites/1322 TAP, five selected real Phase0 roots with18 permanent
assertions, three executed book examples/89 render inputs/heading RED and
Knowledge pass. Selected Phase0 is not full ordinary1035; the exact staged
canonical receipt and normal hooks govern landing.

The two exact drop-containing subtests unwind before numeric22/evaluated70.
All644 prior historical controls survive with6 additions. Original archive134,
84613241 bytes,22 recovery denials and zero healthy original-log/tracked writes
remain exact. Two actual auditor faults and semantic table-byte identity denial
reject and restore. The isolated producer explicitly closes the new table.

`prior.json.gz` preserves the whole accepted numeric claim/publication/10202-input
manifest/full modes, actual clean readonly0 and clean activation, independently
matched to real Git9fc95b0bd. No draft revision is invented. Red/candidate snapshots
retain complete regular main-repository contexts and whole changed draft bytes.
`custody.py` resolves every dated identity from full packets/current bytes/real Git.

Failed preparations remain separate: green1 passed the34 values but still leaked
hash-key DSL shapes; the first focused selector omitted its real lazy-initializing
consumer; diagnostic oracles initially rejected accepted null warnings/stdout
and trace timestamps. All raw runs and exact source successors remain retained.
The nine suites themselves passed; `focused_review.py` accepts only the existing
single receiver-copy TAP JSON diagnostic, preserving its whole18010-byte payload.
The custody census found one missing untracked README draft before-image;
`recover_readme.py` reverses that exact wording edit and requires its independently
retained prior SHA-256/full mode. The failed census is preserved and the gap fixed.

Public book: Values/Hash shaping/Removing keys in Perl and hash-helper reference.
Canonical fact: docs/knowledge/terse-type-method-surface-inventory.md.
Installed Perl/core tools are read-only prerequisites; RGX/PGEN remain excluded
black boxes. All project inputs, temporary render roots and artifacts stay local.
'''
    assert len(after[TASK].encode())<=65536,len(after[TASK].encode())
    c.write_new('closeout.json.gz',dict(before=before,after={path:c.encode(text.encode()) for path,text in after.items()},
        focused_result=result,producer=c.read(c.PREFIX+'finalize_docs.py'),
        scope='Intended clean per-leaf handoff; exact canonical receipt is enforced before landing. '
              'No own commit hash is embedded; all measured focused results precede these documentation writes.'))
    for path,text in after.items():(c.ROOT/path).write_text(text)
    print('Prepared per-leaf handoff; task bytes',len(after[TASK].encode()))


if __name__=='__main__':main()
