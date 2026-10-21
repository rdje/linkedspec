"""Align bounded continuity with verified sort-kind behavior before exact admission."""
import re
import common as c
import context
import review


def main():
    result = review.check(fresh=False)
    paths = ['CHANGES.md','DEVELOPMENT_NOTES.md','MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md',
        'ROADMAP_V2.md','docs/TASK_TREE.md','docs/tasks/TYPE-REFERENCE-BOOK.md',
        'docs/knowledge/terse-type-method-surface-inventory.md',c.PREFIX+'README.md']
    before = {path:c.read(path) for path in paths}
    text = {path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    supplied = context.snapshot()
    c.write_new('final-docs-inputs.json.gz',supplied)
    change = f'''## 2026-10-21 - TYPE-REFERENCE-BOOK.1.2.13: preserve sorted scalar kinds

Compare scalar copies in both generated sort paths and BindingRuntime. Lexical order and numeric-looking strings survive callable/container copies and typed indexes; cloning/index policy is unchanged. Fixed{result['cases']}: accepted{result['accepted_red']} RED/{result['accepted_controls']} controls, six actual source faults/restoration,14/{result['direct_tap']} TAP,16 public flag routes and nine direct cases/72 assertions pass. Book89/5 and heading RED pass. Whole accepted9 custody, original rejected observer/test epochs and three artifact denials/actual validator fault remain retained at docs/checkpoints/type-sort-copy-kinds/. Exact canonical receipt/normal hooks govern landing; count/first10 is next. No complete inventory/backend admission.

'''
    marker = re.search(r'^## ',text['CHANGES.md'],re.M)
    assert marker
    text['CHANGES.md'] = text['CHANGES.md'][:marker.start()]+change+text['CHANGES.md'][marker.start():]
    note = '## 2026-10-21 - sort kinds13\n\nCompare scalar copies; measure flags before Storable caches. See docs/checkpoints/type-sort-copy-kinds/.\n\n'
    marker = re.search(r'^## ',text['DEVELOPMENT_NOTES.md'],re.M)
    assert marker
    text['DEVELOPMENT_NOTES.md'] = text['DEVELOPMENT_NOTES.md'][:marker.start()]+note+text['DEVELOPMENT_NOTES.md'][marker.start():]
    text['MEMORY.md'] = f'''# MEMORY

- activation_commit: `{c.BASE}` — clean leaf13 base; derive current identity from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.13` — subject `TYPE-REFERENCE-BOOK.1.2.13 - preserve sorted scalar kinds`.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.13` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: From the clean committed handoff, activate TYPE-REFERENCE-BOOK.1.2.10 and reproduce deferred count/first against the accepted public controls before its bounded repair.
- in_flight_uncommitted: none — intended clean post-landing state; canonical receipt and normal hooks are mandatory admission.
- proof: docs/checkpoints/type-sort-copy-kinds/publish.py;116 typed values/47 accepted RED/69 controls, six restored source faults,14/1950 TAP,16 public flag routes, nine direct cases/72 assertions, book89/5/heading RED and history650.
- custody: Whole accepted9 physical10743/logical3/images10746/full modes/actual clean readonly0 survives at real eff23e489. Original UTF8, decimal-cache oracle, broad TAP-count and unstable-input epochs stay exact; distinct corrected proofs pass.
- owners:10 deferred count/first ->11 registered sorted/ordinary length ->12 deferred indexed writes ->inventory1/mapping2/layout3/legacy8/private metadata QA/references. Reducer95 remains separate.
- limits: No complete type/operation inventory, whole pipeline or cross-backend admission. Other repositories and RGX/PGEN remain read-only black boxes. Project data stays on the repository volume. No push until PNT is exhausted.
- cleanup: Latest2026-10-20T19:45:58.736082+00:00; required frozen proof/chunks remain retained.
'''
    live = text['LIVE_ACHIEVEMENT_STATUS.md']
    current = 'TYPE-REFERENCE-BOOK.1.2.13 selected proof complete; canonical receipt and normal landing required. Next clean activation is deferred count/first10, then11/12 before complete inventory.\n'
    completed = f'''TYPE-REFERENCE-BOOK.1.2.13 preserves numeric/string kinds through lexical sorting, copies and typed indexes. Fixed116 has47 actual accepted RED/69 controls; all116 pass after three comparator fixes. Six actual source faults reject/restore. Direct14/{result['direct_tap']},16 public flag routes, nine kind cases/72 assertions, history650 and book89/5/heading RED pass. Three artifact denials and actual validator fault restore; whole accepted9 physical10743/logical3/images10746/full modes/actual clean readonly0 survives at real eff23e489.

Original UTF8 transport, decimal flags observed after Storable cache effects, broad TAP-plan counting and the unstable first flag-input epoch remain exact. Distinct corrected proofs pass without production changes for those observer issues. No inventory/backend or reducer95 admission.\n'''
    for heading,value in [('Current Activity',current),('Latest Completed Slice',completed),
            ('Next Action','Finish exact canonical/normal landing, then activate10 only from clean Git. Continue owned11/12 before inventory1/mapping2/layout3. No push yet.\n')]:
        live,count = re.subn(r'(## '+heading+r'\n\n).*?(?=\n## )',lambda match:match[1]+value,live,count=1,flags=re.S)
        assert count == 1
    start,end = live.index('## Recent Completions\n'),live.index('\n## History\n')
    rows = [line for line in live[start:end].splitlines() if line.startswith('- ')]
    rows.insert(0,'- `TYPE-REFERENCE-BOOK.1.2.13` —116/47 accepted RED; six faults;14/1950;16 flag routes;9/72 direct;book89/5; count/first10 next.')
    live = live[:start]+'## Recent Completions\n\n'+'\n'.join(rows[:16])+'\n'+live[end:]
    text['LIVE_ACHIEVEMENT_STATUS.md'] = live
    roadmap = text['ROADMAP_V2.md'].splitlines()
    roadmap[2] = 'October21 current PNT boundary: TYPE-REFERENCE-BOOK.1.2.13 preserves sorted/copy scalar kinds:116 values/47 accepted RED/69 controls, six faults,14/1950,16 flag routes and book89/5. Whole accepted9 custody survives at real eff23e489; exact canonical receipt and normal landing govern admission. Next clean activation10 fixes deferred count/first; then11/12 precede inventory. No complete pipeline/reference admission.'
    roadmap[4] = roadmap[4].replace('Continue kind13 and the owned10/11/12 repairs','After kind13 landing, continue the owned10/11/12 repairs')
    text['ROADMAP_V2.md'] = '\n'.join(roadmap)+'\n'
    lines = text['docs/TASK_TREE.md'].splitlines()
    for index,line in enumerate(lines):
        if line.startswith('| `TYPE-REFERENCE-BOOK` |'):
            lines[index] = '| `TYPE-REFERENCE-BOOK` | `active` / next .1.2.10 | `.spec documentation / per-type reference` | Kind13:116 values/47 accepted RED/six faults,14/1950,16 flag routes,book89/5; exact canonical receipt governs landing. Whole accepted9 custody retained. Next10/11/12 precede inventory1/mapping2/layout3/legacy8; full reference admission pending. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |'
    text['docs/TASK_TREE.md'] = '\n'.join(lines)+'\n'
    tree = text['docs/tasks/TYPE-REFERENCE-BOOK.md']
    tree = tree.replace('`active` / sorted-copy kind .1.2.13; before enumeration','`active` / next deferred count/first .1.2.10; before enumeration',1)
    start = tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.13`')
    end = tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.10`',start)
    leaf = tree[start:end].replace('Status: `active` / activationeff23e489','Status: `done` / selected proof; exact canonical admission required',1)
    leaf = leaf.replace('- [ ] **','- [x] **')
    leaf = leaf.replace('Direct-test intake owned here:', 'Direct-test intake owned/fixed here:')
    leaf = leaf.replace('Diagnose Perl assignment/cache behavior before admitting a kind oracle; do not equate numeric cache flags with public number/string kinds or discard the failing test epoch.', 'Actual assignment/sort preserve flags; dclone adds private iOK to floating-point sources. Capture sort flags before clone; all nine cases/72 assertions then pass. Failed test/diagnosis and broad-count writer rejection remain exact.')
    leaf += '  Verified:116 fixed values/47 accepted RED/69 controls; all GREEN. Three old comparator paths, numeric order/coercion and source mutation each reject and exactly restore. Mandatory14/1950/history650/scanner,16 public flag routes and book89/5/heading RED pass. First flag epoch changed a proof-source input and is rejected; flags2 is stable. Three artifact denials and actual validator fault restore.\n'
    leaf += '  Custody: Whole accepted9 and every supplied epoch recover; original transport/test/proof-writer failures stay retained. docs/checkpoints/type-sort-copy-kinds/publish.py is the readonly claim gateway; exact staged canonical receipt and normal hooks govern landing. Next10 only after clean handoff.\n'
    leaf += '  Commit subject: `TYPE-REFERENCE-BOOK.1.2.13 - preserve sorted scalar kinds`.\n\n'
    tree = tree[:start]+leaf+tree[end:]
    tree = tree.replace('| `TYPE-REFERENCE-BOOK.1.2.13` | `active` | P1 sorted/copy scalar-kind repair after accepted9; clean baseline retained. |','| `TYPE-REFERENCE-BOOK.1.2.13` | `done` |116 values/47 RED/six faults/14-1950/book89-5; canonical admission mandatory. |',1)
    old = 'No director input required. Pipeline9 selected proof is complete; exact canonical/normal landing is mandatory. P1 kind13 then10/11/12 precede complete inventory1. No dirty pivot.'
    assert old in tree
    tree = tree.replace(old,'No director input required. Kind13 selected proof is complete; exact canonical/normal landing is mandatory. Activate10 only after clean handoff; then11/12 before inventory1. No dirty pivot.',1)
    tree = tree.replace('## Verification Log\n','## Verification Log\n\n- `2026-10-21` — `.1.2.13`:116/47 RED/six faults;14/1950/history650;16 flag routes;9/72 direct;book89/5. Source-closed gateway and exact canonical receipt govern landing.\n',1)
    tree = tree.replace('## Commit Log\n','## Commit Log\n\nKind13 subject: `TYPE-REFERENCE-BOOK.1.2.13 - preserve sorted scalar kinds`; derive its accepted identity from Git.\n',1)
    text['docs/tasks/TYPE-REFERENCE-BOOK.md'] = tree
    fact = text['docs/knowledge/terse-type-method-surface-inventory.md']
    fact = fact.replace('status: bounded Perl helpers; kind13 active; inventory pending','status: bounded Perl helpers; kind13 fixed; inventory pending')
    fact = fact.replace('evidence: "Type3-.9 retain exact epochs;9 admits only callable sorted/take. kind13/10/11/12 remain owned."','evidence: "Type3-.13 retain exact epochs;13 verifies scalar kinds.10/11/12 remain owned."')
    fact = fact.replace('reverify: "At eff23e489: bash tools/run_python_project_data.sh docs/checkpoints/type-array-pipelines/publish.py"','reverify: "bash tools/run_python_project_data.sh docs/checkpoints/type-sort-copy-kinds/publish.py"')
    start = fact.index('Perl callable sorted/take')
    end = fact.index('\ndrop_keys',start)
    fact = fact[:start]+'''Perl callable sorted/take execute free/receiver forms. Sort is lexical;
comparing copied operands preserves numeric/string kinds through clones/indexes.
Storable may cache private iOK on floating-point sources; observe sort flags before
cloning. Numeric/string JSON kinds remain distinct.
take defaults1; integer spelling only, negative/invalid0, oversized counts clamp.
Non-arrays yield[] and skip count; source/results stay independent.10 owns deferred
count/first,11 registered sorted/ordinary length,12 deferred indexed writes.
Serialized fluent args require arrays before preflight. No family/backend admission.
'''+fact[end:]
    start = fact.index('Accepted7 builds')
    end = fact.index('\nContext hash-gates',start)
    fact = fact[:start]+'''Accepted7 HTML differs only by its search-index reference: decoded payload changes
are15 body-whitespace strings. Strict rejection remains; no general normalization.
'''+fact[end:]
    text['docs/knowledge/terse-type-method-surface-inventory.md'] = fact
    text[c.PREFIX+'README.md'] = '''# Sorted and copied numeric kinds — bounded Perl repair

Owner: TYPE-REFERENCE-BOOK.1.2.13. Clean activation: eff23e4894727205dc12b209baab7065180a08e5.
Run `bash tools/run_python_project_data.sh docs/checkpoints/type-sort-copy-kinds/publish.py`
to verify closed inputs and current behavior without tracked writes. Exact canonical
receipt and normal hooks govern landing; derive admission identity from Git.

The fixed116-case plan has47 actual accepted RED/69 controls, then all GREEN:
ordinary/deferred free/receiver, integer/decimal/string/mixed/null/boolean/Unicode,
copies/arguments/typed indexes/source independence and four implicit-accumulator specs.
Six actual source faults reject and exactly restore: both emitted paths, runtime
alias comparison, numeric ordering/coercion and source mutation. Independent mandatory
uniform tests cover nine cases/72 assertions; public flags/clone/index routes pass16.
Direct14/1950, history650 and scanner pass. The complete89-input book executes five
actual bodies; new anchor/link and deliberately displaced heading are checked.

prior.json.gz retains whole accepted9 claim/publication/10743 physical inputs, three
logical aliases,10746 full-mode independently Git-verified images and actual clean
source-readonly0. baseline.json.gz retains fresh16 flag/value routes and8 separate
descriptor/Get/dump/emitted cases before tracked writes. Changed plain sources survive
whole in supplied epochs; unchanged sources recover at accepted Git. Immutable gzip
and chunks are hash-gated without recursive embedding. Logical aliases recover from
the accepted chunk producer. Gitlinks remain black boxes; project data stays local.

Rejected epochs remain exact. The first116 observer exits0 with unchanged inputs but
prints unencoded Unicode; a distinct UTF8 producer repairs transport. Its comparison
permits only six valid timestamp substitutions in expected native diagnostics and
rejects typed-value/text/malformed-timestamp corruptions. The first direct test reads
flags after dclone: actual assignment/sort preserve flags, whereas Storable caches
private iOK on float sources. Capturing sort flags before clone restores all tests.
The correction writer then rejects an overly broad TAP count; admission_finish scopes
the same passing TAP to the new parent. The standalone proposal was never executed;
its whole bytes/mode survive before exact deletion. The first flag epoch is invalidated
by proof-source preparation; flags2 supplies unchanged-input GREEN. None is presented
as a successful original measurement or a new runtime defect.

The Python mutation/capture actors are one-shot historical producers; do not rerun
them on a changed tree. publish.py, review.py and custody.py are readonly reviewers.
Three missing/byte/mode declarations reject in the actual publisher; a return-only
actual validator admits all three, then exact restoration rejects them again.
No exhaustive operation inventory, general pipeline, backend or reducer95 admission.
Next: owned count/first10, registered sorted/ordinary length11, indexed writes12.
'''
    for path,value in text.items():
        c.source(path).write_text(value)
        c.source(path).chmod(before[path]['mode'])
    knowledge = c.run(['bash','knowledge-map/scripts/gen_knowledge_map.sh'])
    c.write_new('final-docs.json.gz',dict(before=before,after={path:c.read(path) for path in paths},
        knowledge=knowledge,result=result,scope='Selected proof is complete. Canonical receipt and normal hooks remain mandatory before landing. Memory is the intended clean post-landing handoff; Git owns actual admission identity.'))
    assert knowledge['returncode'] == 0
    print('Final continuity/book fact aligned; canonical admission remains mandatory')


if __name__ == '__main__':
    main()
