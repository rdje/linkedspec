"""Activate aggregate7 after whole accepted drop preservation; keep root bounded."""
import json
import re
import common as c

TASK='docs/tasks/TYPE-REFERENCE-BOOK.md'
CLAIM='docs/claims/TYPE-REFERENCE-BOOK.1.2.6.json'
OLD_README='docs/checkpoints/type-drop-generated/README.md'


def main():
    prior=c.load('prior.json.gz')
    assert c.read(CLAIM)==prior['claim'] and c.unchanged({path:{key:item[key] for key in ('sha256','mode')}
        for path,item in prior['inputs'].items()})
    paths=[CLAIM,OLD_README,TASK,'docs/TASK_TREE.md','MEMORY.md']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    record=json.loads(after[CLAIM])
    assert all(item['durability']['mode']=='live' for item in record['claims'])
    for item in record['claims']:item['durability'].update(mode='historical',revision=c.BASE)
    after[CLAIM]=json.dumps(record,separators=(',',':'))+'\n'
    after[OLD_README]+='\nHistorical at accepted'+c.BASE+' after aggregate7 activation. Restore its recorded Git inputs for readonly replay; current aggregate custody is docs/checkpoints/type-aggregate-codeblocks/.\n'
    tree=after[TASK]
    start=tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.6`\n')
    end=tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.7`\n',start)
    old_six=tree[start:end]
    six=old_six
    replacements={
        '  Evidence/custody:':'  Evidence/custody: docs/checkpoints/type-drop-generated/README.md; complete source epochs/10334-input publication at accepted'+c.BASE+'.',
        '  - [x] **REPRODUCE / ISSUE**':'  - [x] **REPRODUCE / ISSUE** — Accepted warning, splice and key-effect failures retained.',
        '  - [x] **ROOT CAUSE (WHY + WHERE)**':'  - [x] **ROOT CAUSE (WHY + WHERE)** — Toolbox identifies the drop scalar/list/shape emitter.',
        '  - [x] **FIX**':'  - [x] **FIX** — Copied source and materialized key list; explicit splice/shape lowering.',
        '  - [x] **ADDRESSED (verified)**':'  - [x] **ADDRESSED (verified)** —34 values/14 diagnostics; four actual faults/restorations.',
        '  - [x] **NO REGRESSION**':'  - [x] **NO REGRESSION** — Direct/history/book and canonical1035/CLI66x2; ten hooks/receipt.',
        '  - [x] **LOCKSTEP**':'  - [x] **LOCKSTEP** — Book/facts/handoff; no whole-family/backend admission.',
        '  Final admission:':'  Final admission: first10304 draft/readonly0/10308 stage images and canonical143 retained in admission/.',
        '  P3 cache cleanup:':'  P3 cache cleanup: exact preserved cache removed; checkpoint ignore/residue proof retained.',
        '  Commit subject:':'  Commit subject: `TYPE-REFERENCE-BOOK.1.2.6 - materialize generated drop keys`.',
    }
    lines=six.splitlines()
    for prefix,replacement in replacements.items():
        hits=[index for index,line in enumerate(lines) if line.startswith(prefix)]
        assert len(hits)==1,prefix
        lines[hits[0]]=replacement
    six='\n'.join(lines)+'\n\n'
    formal=lambda value:[line for line in value.splitlines() if re.match(r'  (Verification tier|Focused checks|Canonical trigger):',line)]
    assert formal(six)==formal(old_six)
    tree=tree[:start]+six+tree[end:]
    start=tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.7`\n')
    end=tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.1`\n',start)
    node='''- ID: `TYPE-REFERENCE-BOOK.1.2.7`
  Status: `in_progress` / activationefad62ba7
  Goal: Execute deferred aggregate numeric calls/overloads and terminal receivers.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.6`
  Scope/custody: docs/checkpoints/type-aggregate-codeblocks/; whole drop10334/clean readonly0 preserved. Aggregates are separate from scalar ADR0029;95/94/35 retain ownership.
  Verification tier: `focused`
  Focused checks: Public descriptor/Get/dump/fresh routes; six families/names/receivers, arity/kind/empty/effects; scalar5/drop6/direct tests; book/Knowledge/doctrines.
  Canonical trigger: Escalate for contract/infrastructure changes or cross-cutting uncertainty.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.7.json`
  Acceptance Checklist
  - [ ] **REPRODUCE / ISSUE** — Accepted missing dispatch and healthy ordinary controls.
  - [ ] **ROOT CAUSE (WHY + WHERE)** — Tool-identified runtime owner and separate aggregate authority.
  - [ ] **FIX** — Bounded dispatch/overloads with existing family consumption rules.
  - [ ] **ADDRESSED (verified)** — Values/diagnostics/effects and actual faults/restoration.
  - [ ] **NO REGRESSION** — Scalar/drop consumers, relevant permanent tests and selected gates.
  - [ ] **LOCKSTEP** — Worked book/facts/current pointer; known separate defects stay explicit.

'''
    tree=tree[:start]+node+tree[end:]
    old='| 5 | `TYPE-REFERENCE-BOOK.1.2.7` | `pending` | Deferred aggregates before enumeration. |'
    assert tree.count(old)==1
    tree=tree.replace(old,'| 5 | `TYPE-REFERENCE-BOOK.1.2.7` | `in_progress` | Deferred aggregate availability before enumeration. |',1)
    assert len(tree.encode())<=65536,len(tree.encode())
    after[TASK]=tree
    index=after['docs/TASK_TREE.md']
    old=next(line for line in index.splitlines(keepends=True) if line.startswith('| `TYPE-REFERENCE-BOOK` |'))
    new='| `TYPE-REFERENCE-BOOK` | `active` / aggregate .1.2.7 in progress | `.spec documentation / per-type reference` | Drop6 committed efad62ba7:34 values/14 diagnostics,4 faults,9/1322,book89/3 and canonical1035/CLI66x2. Whole10334-input drop publication/clean readonly0 preserved. Deferred aggregates7 precedes inventory1/book mapping2/layout3/legacy8; separate95/94/35 defects and full reference admission remain owned. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |\n'
    after['docs/TASK_TREE.md']=index.replace(old,new,1)
    after['MEMORY.md']=f'''# MEMORY

- activation_commit: `{c.BASE}` — clean aggregate7 activation; derive current identity from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.6` — subject `TYPE-REFERENCE-BOOK.1.2.6 - materialize generated drop keys`.
- active_work_unit: `{c.OWNER}` (in progress).
- task_owner: `{TASK}`.
- next_action: Bind the complete aggregate authority and fixed public accepted baseline through descriptor/Get/dump/fresh routes before inspecting the tool-identified runtime owner. Then implement only deferred availability/overloads with bounded effect/kind controls.
- in_flight_uncommitted: Aggregate7 preservation/activation metadata; no production change or mutant. Whole drop publication/10334 inputs/full modes/actual clean readonly0 are in {c.PREFIX}prior.json.gz.
- blockers: no director input required. Scalar ADR0029 excludes aggregates; do not assign new input policy or hide ordinary string-result defect95, constructor94 or boolean-literal35.
- current_proof: Drop6 committed with canonical0, all1035 Phase0 roots, CLI66x2, all10 hooks, promoted receipt, clean tree and empty brief at activation. Aggregate7 implementation/claim remain pending.
- historical_custody: Drop6 is historical only at real efad62ba7; its complete record/publication and actual clean baseline survive before bound writes. Existing numeric/first-drop source images and historical cache data remain intact; new checkpoint caches are ignored.
- containment: Completed6 narrative is compacted to its accepted checkpoint; its three formal verification declarations remain unchanged. Keep task root <=65536 and Knowledge source <=8388608; no budgets raised.
- known_defects: Deferred aggregates7; ordinary numeric-string min/max/odd-median95; constructor94; startup20/32/35/87.4 remain owned. No new cross-backend or complete inventory admission.
- canonical_environment: Use approved host execution for public quiet wrappers and canonical/normal commit workflows; never weaken the profile.
- cleanup: Latest2026-10-20T19:45:58.736082+00:00; docs/ARTIFACT_CLEANUP.md. Less than24h at activation; no cleanup due.
- deferred: aggregate7 -> inventory .1.2.1 -> book mapping .1.2.2 -> layout .1.3 -> legacy .8 -> metadata QA .13 -> references/closeout.
- standing_limit: Other repositories and RGX/PGEN remain read-only black boxes; project data stays on this volume. No internal dependency procedures or pin changes.
- sequence: Full PNT continues; one normal commit per completed leaf. No push yet.
'''
    c.write_new('activation.json.gz',dict(before=before,after={path:c.encode(text.encode()) for path,text in after.items()},
        producer=c.read(c.PREFIX+'activate.py'),
        scope='Activate only aggregate7 after whole clean accepted drop custody. Narrowly freeze claim6 at '
              'real efad62; retain complete6 tree before-image and accepted checkpoint while compacting '
              'non-formal narrative. Exactly one changed formal verification owner is7.'))
    for path,text in after.items():(c.ROOT/path).write_text(text)
    print('Aggregate7 activated; task bytes',len(tree.encode()),'; scalar and known separate defect boundaries retained')


if __name__=='__main__':main()
