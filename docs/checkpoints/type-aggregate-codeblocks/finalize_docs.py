"""Prepare the intended clean aggregate handoff only after composed focused proof passes."""
import re
import common as c
import review


def replace_section(text,title,body):
    start=text.index('## '+title+'\n')+len('## '+title+'\n')
    end=text.find('\n## ',start)
    if end<0:end=len(text)
    return text[:start]+'\n'+body.strip()+'\n'+text[end:]


def main():
    result=review.check(False)
    assert result['direct_suites']==14 and len(result['producer_faults'])==7
    paths=['CHANGES.md','DEVELOPMENT_NOTES.md','MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md',
        'docs/tasks/TYPE-REFERENCE-BOOK.md','docs/TASK_TREE.md',c.PREFIX+'README.md']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    subject=c.OWNER+' - execute deferred array reducers'
    summary=f'''Perl callable bodies execute sum/avg/median/range and array min/max through canonical/word calls and terminal receivers. Complete invalid receiver shapes avoid host fallthrough; malformed serialized calls preserve the typed invocation error. The corrected214 population passes212 values/two diagnostics against106 accepted-source failures/108 controls. Six retained aggregate faults plus a final guard-removal fault restore; final14 suites/{result['direct_tap']} TAP,201 added permanent cases/3 advanced expectations/15 malformed assertions, book{result['book_inputs']}/3/observed anchor RED and Knowledge pass. Historical650/134/84613241/22 and zero read/write escapes stay unchanged; ordinary Phase0 test source is unchanged. Whole accepted drop10334/full modes/clean readonly0 remains recoverable. Exact staged canonical receipt is required for landing.'''
    change='## 2026-10-21 — '+c.OWNER+' — Execute deferred array reducers\n\n'+summary+'''\n\nLegacy Perl aggregate decimal/empty/Boolean/selected-term behavior remains separate from scalar ADR0029. Actual internal-kind95 failures are not hidden by numeric JSON: three selected results reject array-write indexes, while scalar controls succeed. Original quoted JSON stays historical; actual192-input old-library replay checks65 loaded owners. Rejected shadow/oracle/quietness preparations remain intact. The catalogue rounding wording now matches the existing halves-away contract. Pipeline9 is owned next; no full inventory or cross-backend aggregate admission. Checkpoint/claim: docs/checkpoints/type-aggregate-codeblocks/ and docs/claims/TYPE-REFERENCE-BOOK.1.2.7.json.\n\n'''
    text=after['CHANGES.md'];pos=text.index('\n## ')+1
    after['CHANGES.md']=text[:pos]+change+text[pos:]
    notes='## 2026-10-21 — '+c.OWNER+' — Aggregate dispatch, scalar kinds and source identity\n\n'+'''Keep array reducers distinct from the scalar numeric adapter: all Perl terms pass the legacy decimal check, empty sum is0 and other empty reductions are null. Min/max with explicit scalar operands evaluate them before kind rejection; zero-argument array receiver forms terminate the chain. Static invalid shapes produce complete undef before effects. A new preflight initially dereferenced malformed serialized members before the existing typed guard; one skip preserves the accepted error, caller values and record shape.\n\nA JSON number need not have internal numeric kind. Selected min/max/odd-median terms retain POK alongside numeric flags; BindingRuntime prioritizes string kind and real index writes reject.95 owns repair/authority audit, including Boolean admission versus result kind. Historical quoted JSON is not refreshed: current raw JSON differs even with verified old owned bytes under current tools. A shadow path did not select the intended module; loaded-byte checks and exact installation/restoration govern the corrected192/65 replay. Existing receiver-copy stderr is one deliberate complete JSON diagnostic, parsed strictly. Whole source epochs and rejected preparations stay recoverable; no pipeline9 or broad family admission.\n\n'''
    text=after['DEVELOPMENT_NOTES.md'];pos=text.index('\n## ')+1
    after['DEVELOPMENT_NOTES.md']=text[:pos]+notes+text[pos:]
    live=after['LIVE_ACHIEVEMENT_STATUS.md']
    live=replace_section(live,'Current Activity',c.OWNER+' completes bounded Perl aggregate availability; deferred sorted/take pipeline .1.2.9 is next from clean Git.')
    live=replace_section(live,'Latest Completed Slice',summary+'\n\nKind95 remains owned: JSON can mask selected string flags; three real index failures/two controls are retained. Six aggregate faults stay at their exact pre-guard source epoch; final guard fault/current214/current14 suites cover the final producer. Invalid shadows and other preparation failures are explicit. Pipeline9 precedes complete inventory1/book mapping2; no push yet.')
    live=replace_section(live,'Next Action','From clean Git, run the aggregate readonly publication and preserve its complete claim/publication/input manifest/full modes and actual baseline before activating TYPE-REFERENCE-BOOK.1.2.9. Repair the owned deferred sorted/take pipeline, then continue inventory/book mapping in full PNT. No push yet.')
    start=live.index('## Recent Completions\n')+len('## Recent Completions\n');end=live.index('\n## History',start)
    rows=[line for line in live[start:end].splitlines() if line.startswith('- ')]
    new=f'- `{c.OWNER}` —214/106 RED;7 faults;14/{result["direct_tap"]};201+3 permanent/15 malformed;book{result["book_inputs"]}/3;kind95/next9 owned.'
    live=live[:start]+'\n'+'\n'.join(([new]+rows)[:16])+'\n'+live[end:]
    after['LIVE_ACHIEVEMENT_STATUS.md']=live
    task='docs/tasks/TYPE-REFERENCE-BOOK.md';text=after[task]
    start=text.index('- ID: `'+c.OWNER+'`\n');end=text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.9`\n',start)
    node=text[start:end].replace('Status: `in_progress` / activationefad62ba7','Status: `done` / bounded Perl availability')
    node=node.replace('  - [ ] **','  - [x] **')
    node+=f'  Verification:214/106 RED/108 controls;7 actual faults/restorations;14/{result["direct_tap"]};201+3 permanent/15 malformed;book{result["book_inputs"]}/3/heading RED;650 history controls unchanged. Claim publication and exact canonical receipt govern landing. Source epochs/rejected preparation remain explicit;95/9 stay owned.\n  Commit subject: `{subject}`.\n\n'
    text=text[:start]+node+text[end:]
    text=text.replace('| 5 | `'+c.OWNER+'` | `in_progress` | Deferred aggregate availability before enumeration. |',
        '| 5 | `'+c.OWNER+'` | `done` | Bounded aggregate availability; owned pipeline9 next. |',1)
    assert len(text.encode())<=65536
    after[task]=text
    index=after['docs/TASK_TREE.md']
    old=next(line for line in index.splitlines(keepends=True) if line.startswith('| `TYPE-REFERENCE-BOOK` |'))
    new=f'| `TYPE-REFERENCE-BOOK` | `active` / aggregate .1.2.7 done; pipeline .1.2.9 next | `.spec documentation / per-type reference` | Aggregate214/106 RED/7 faults; final14/{result["direct_tap"]},201+3 permanent/15 malformed,book{result["book_inputs"]}/3; whole drop10334 retained. Internal-kind95 stays owned despite numeric JSON. Canonical receipt governs landing; clean activation9 precedes inventory1/mapping2/layout3/legacy8. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |\n'
    after['docs/TASK_TREE.md']=index.replace(old,new,1)
    after['MEMORY.md']=f'''# MEMORY

- activation_commit: `{c.BASE}` — derive current commit from Git; normal post-commit requires HEAD^1.
- latest_completed_leaf: `{c.OWNER}` — subject `{subject}`.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.9` (pending clean activation).
- task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: Run the current aggregate readonly publication; preserve its complete record/publication/input manifest/full modes and actual clean baseline before activating the owned deferred sorted/take pipeline9. Continue PNT after its normal commit.
- in_flight_uncommitted: none; intended clean post-landing handoff. No mutant or verification job belongs to the committed state.
- current_proof: Corrected214/212 values/two diagnostics;106 accepted RED/108 controls; seven actual faults/restorations; final14 suites/{result['direct_tap']} TAP;201 added cases/three advanced expectations/15 malformed assertions; book{result['book_inputs']}/3/anchor RED; Knowledge and unchanged650 historical controls. Exact staged canonical receipt is mandatory for landing.
- checkpoint: {c.PREFIX}README.md; publish.py is the current readonly rederive; claim docs/claims/{c.OWNER}.json.
- source_epochs: Six aggregate faults retain pre-guard bytes; final guard delta has its own actual removal RED/restoration and final214/dependent proof. Malformed API callers/records stay intact. Initial shadow/oracle/quietness preparations remain rejected, never refreshed.
- kind95: JSON can show numbers while min/max/odd-median results retain string kind; three real index failures/two scalar controls and B flags remain. Actual old192-input library/65 loaded owners is byte-verified with exact restoration. Original95 instrument/environment is unretained;95 stays after94 before51 and includes Boolean authority audit.
- custody: Whole drop10334/full modes/actual clean readonly0 at real efad survives in prior.json.gz; earlier source/cache images remain intact.
- containment: Whole before packets preserve task/fact compaction; no budgets raised. Source/card details live in their owners, not this pointer.
- cleanup: Latest2026-10-20T19:45:58.736082+00:00; docs/ARTIFACT_CLEANUP.md. Less than24h at this handoff; do not remove frozen historical cache inputs.
- deferred:9 -> inventory1 -> book mapping2 -> layout3 -> legacy8 -> metadata QA13 -> references/closeout. Startup20/32/35/87.4 and constructor94 remain separately owned.
- verification_environment: Use established host profile and repository-local data wrappers; no weakened gate. Full CI before final clean push. No push yet; full PNT continues.
- standing_limit: Other repositories and RGX/PGEN remain read-only black boxes; project data stays on this volume.
'''
    after[c.PREFIX+'README.md']+=f'''\nAccepted bounded result:214 cases/212 values/two diagnostics;106 real accepted-source RED/108 controls. Final14 suites/{result['direct_tap']} TAP, seven actual faults,201+3 permanent cases and15 malformed assertions; book{result['book_inputs']}/3 and displaced-heading rejection. Ordinary Phase0 test source/history650 stays unchanged. Canonical staged receipt is required for landing. Default publish.py is readonly; --capture and every writer are one-shot. Next clean activation is pipeline9, not inventory admission.\n'''
    c.write_new('final-docs.json.gz',dict(before=before,after={path:c.encode(raw.encode()) for path,raw in after.items()},
        result=result,producer=c.read(c.PREFIX+'finalize_docs.py'),
        scope='Intended clean post-landing metadata; exact canonical receipt/normal hooks still required. '
              'No own commit hash is invented. Chronology pressure checks/rollover follow before staging.'))
    for path,raw in after.items():(c.ROOT/path).write_text(raw)
    print('Intended clean handoff prepared; next9; normal canonical workflow required')


if __name__=='__main__':main()
