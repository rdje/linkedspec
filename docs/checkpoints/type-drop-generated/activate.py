"""Activate the owned drop slice only after whole accepted numeric preservation."""
import json
import common as c


def main():
    prior=c.load('prior.json.gz')
    assert c.unchanged({path:{key:item[key] for key in ('sha256','mode')} for path,item in prior['inputs'].items()})
    paths=('docs/claims/TYPE-REFERENCE-BOOK.1.2.5.json','docs/checkpoints/type-numeric-codeblocks/README.md',
           'docs/tasks/TYPE-REFERENCE-BOOK.md','docs/TASK_TREE.md','MEMORY.md')
    before={path:c.read(path) for path in paths}
    assert before[paths[0]]==prior['claim']
    record=json.loads(c.decode(before[paths[0]]['base64']))
    for claim in record['claims']:
        assert claim['durability']['mode']=='live'
        claim['durability'].update(mode='historical',revision=c.BASE)
    after={paths[0]:(json.dumps(record,separators=(',',':'))+'\n').encode()}
    notice=('Historical numeric publication at accepted '+c.BASE+'. Its complete claim,\n'
            '10202 closed input identities/full modes and actual clean readonly0 are preserved\n'
            'by docs/checkpoints/type-drop-generated/. No original observation is refreshed.\n\n').encode()
    after[paths[1]]=notice+c.decode(before[paths[1]]['base64'])
    text=c.decode(before[paths[2]]['base64']).decode()
    start=text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.6`')
    end=text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.7`',start)
    node='''- ID: `TYPE-REFERENCE-BOOK.1.2.6`
  Status: `in_progress` / activation9fc95b0bd
  Goal: Emit warning-free generated scalar-key drop without changing hash-copy/list semantics.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.5`
  Scope/intake: docs/checkpoints/type-drop-generated/; original exact warning/FATAL evidence survives under the .1.2.3 warning-routes prefix and accepted9fc95b0bd task node. Own bounded MethodLowering drop producer, current hash/receiver consumers, two Phase0 warning goldens, their exact historical inverse, book/fact and whole prior custody.
  Verification tier: `canonical`
  Focused checks: Public descriptor/Get/lowering/fresh normal/FATAL profiles; literal/computed/spliced cardinality, copy/effect/kind controls, direct hash/receiver tests, exact Phase0/historical recurrence, book/Knowledge.
  Canonical trigger: Observable generated compiler diagnostic; exact staged candidate.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.6.json`
  Acceptance Checklist
  - [ ] **REPRODUCE / ISSUE** — Accepted public warning/FATAL failure and healthy controls.
  - [ ] **ROOT CAUSE (WHY + WHERE)** — Tool-dumped scalar/list deletion mechanism.
  - [ ] **FIX** — Known scalar deletion; preserve multi-key/splice semantics and diagnostics.
  - [ ] **ADDRESSED (verified)** — Independent values, quiet profiles and producer faults/restoration.
  - [ ] **NO REGRESSION** — Direct consumers, exact historical controls and canonical receipt.
  - [ ] **LOCKSTEP** — Book/fact/live docs; no blanket hash-family admission.

'''
    text=text[:start]+node+text[end:]
    text=text.replace('| `TYPE-REFERENCE-BOOK.1.2.6` | `pending` | P2 generated single-key drop diagnostic','| `TYPE-REFERENCE-BOOK.1.2.6` | `in_progress` | P2 generated single-key drop diagnostic',1)
    assert len(text.encode())<=65536
    after[paths[2]]=text.encode()
    text=c.decode(before[paths[3]]['base64']).decode().replace('`active` / generated-drop .1.2.6 next','`active` / generated-drop .1.2.6 in progress',1)
    after[paths[3]]=text.encode()
    after[paths[4]]=('''# MEMORY

- activation_commit: `'''+c.BASE+'''` — clean generated-drop6 activation; derive current identity from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.5` — subject `TYPE-REFERENCE-BOOK.1.2.5 - execute scalar numeric codeblocks`.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.6` (in progress).
- task_owner: `docs/tasks/TYPE-REFERENCE-BOOK.md`.
- next_action: Capture the exact accepted warning/FATAL baseline and scalar/list key controls through LinkedSpec's public tools; inspect only the tool-identified drop emitter, then implement the bounded fix with direct and historical recurrence proof.
- in_flight_uncommitted: Drop6 preservation/activation metadata; no production changes yet; no mutant. Whole numeric publication/10202 inputs/full modes and actual clean readonly0 are retained in docs/checkpoints/type-drop-generated/prior.json.gz.
- blockers: no director input required. Preserve hash-copy, explicit splices and current invalid diagnostics; ordinary warning policy is unchanged.
- current_proof: Numeric5 committed with canonical0, all10 hooks, empty brief and clean tree at activation. Drop6 claim and implementation proof remain pending.
- historical_dependency: Two Phase0 warning goldens must change only with the actual fix. Their reviewed inverse must precede numeric22/older70; preserve all644 existing historical controls and original archive/read-write boundary before canonical. Do not repeat the already documented inner-row shadowing mistake.
- known_defects: Generated-drop6, deferred aggregates7, startup20/32/35/87.4 remain owned. Numeric5 repairs scalar dispatch/snapshots and duplicate87.3; no complete inventory/backend/private-parent admission.
- canonical_environment: Start CI/public quiet wrappers through approved host execution; never weaken or bypass the profile.
- cleanup: Latest2026-10-20T04:06:20.726688+00:00; docs/ARTIFACT_CLEANUP.md owns the overwrite-only record. Caches/other repositories retained.
- deferred: .1.2.6 -> .1.2.7 -> inventory .1.2.1 -> book mapping .1.2.2 -> layout .1.3 -> legacy .8 -> metadata QA .13 -> remaining references/closeout.
- standing_limit: Other repositories and RGX/PGEN remain read-only black boxes. All project data stays on the repository volume; no internal dependency procedures or pin changes.
- sequence: Full PNT continues, one normal commit per completed leaf. No push yet.
''').encode()
    c.write_new('activation.json.gz',dict(before=before,after={path:c.encode(raw) for path,raw in after.items()},
        producer=c.read(c.PREFIX+'activate.py'),scope='Retire only prior mode/revision at its real accepted commit; '
        'every original claim/leg/input remains whole. Activate one canonical owner after complete preservation.'))
    for path,raw in after.items():(c.ROOT/path).write_bytes(raw)
    print('Generated-drop6 activated; prior5 historical at real9fc95b0bd; no production change')


if __name__=='__main__':
    main()
