"""Publish bounded continuity only after the final selected proofs complete."""
import json
import re
import subprocess
import common as c

def main():
    selected=c.load('candidate4.json.gz')
    assert selected['inputs_unchanged'] and not selected['failures']
    faults=c.load('faults3-result.json')
    assert faults['sources_restored']
    direct=c.load('focused2-run.json.gz')['run']
    assert direct['returncode']==0
    match=re.search(rb'Files=(\d+), Tests=(\d+),',c.decode(direct['stdout_base64']))
    assert match
    suites,tap=map(int,match.groups())
    cases=len(c.load('cases.json')['cases'])
    red=len(c.load('baseline-review.json')['failures'])
    import review2
    reviewed=review2.check()
    summary=f'{cases} cases/{red} accepted RED/{cases-red} controls;compatibility4;{len(faults["faults"])} restored source faults;{suites}/{tap} direct TAP;book89/2+inline2 and actual anchor RED;artifact3'
    files=['MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md','ROADMAP_V2.md','docs/TASK_TREE.md',
        'docs/tasks/TYPE-REFERENCE-BOOK.md','CHANGES.md','DEVELOPMENT_NOTES.md']
    before={p:c.read(p) for p in files}
    after={p:c.decode(packet['base64']).decode() for p,packet in before.items()}
    owner=after['docs/tasks/TYPE-REFERENCE-BOOK.md']
    start=owner.index('- ID: `'+c.OWNER+'`\n')
    end=owner.index('\n- ID: ',start+1)
    node=owner[start:end]
    node=node.replace('  Status: `active` / bounded registered-array and length repair','  Status: `completed` / bounded Perl registered-array and length contract')
    node=node.replace('  Reproduce/impact: Registered','  Reproduce/impact: Baseline registered',1)
    node=node.replace('  Schedule: After10, before12/inventory. Use public lowering to identify both bounded owners; split at clean activation if necessary.', '  Schedule: Completed after10/maintenance20; deferred indexed-write12 is next, then last14 before inventory1.')
    node=node.replace('  Planned tier: `canonical`','  Verification tier: `canonical`\n  Focused checks: Fixed public descriptor/Get/dump/native/fresh grid; registered parameter/local/rest/nested and free controls; lexical kind/copy/empty/nonarray/effects; permanent scalar consumer and direct dependents; actual source faults/restoration, full supplied book and artifact controls, Knowledge/history/doctrines.\n  Canonical trigger: Public Perl pipeline availability and terminal/invalid-shape contract; exact staged canonical receipt required before normal landing.')
    node=node.replace('  Claim verification: none: Pending repair; actual intake diagnosis is bound to claim9.','  Claim verification: `docs/claims/'+c.OWNER+'.json`')
    node=node.replace('  Compatibility repair owned here:', '  Compatibility repair verified:')
    node=node.replace('Preserve the failed complete source epoch/channels and exact old fixture; restore count/first into shared preflight before final source/fault/book/direct/canonical proof.', 'Complete failed channels/source epoch and the old fixture remain exact. Actual single-bridge rollback GREEN/reapply RED attributes the regression; shared preflight restores all four old controls. Final selected/fault/book/direct proof passes; exact canonical receipt governs admission.')
    old='  Next: Preserve actual input epochs, declare fixed value/effect/copy/shape controls, repair only these lowerings, synchronize book/roadmap/fact and run exact canonical admission before normal commit.'
    node=node.replace(old,'  Verified selected proof: '+summary+'. Exact canonical receipt and normal hooks govern admission; no full reference/backend claim.')
    node+='\n  Root cause/fix: MethodLowering::_lower_ast_fluent_chain_node reparsed synthetic expressions containing emitted function/callback values as DSL. Reuse its existing compatibility bridge; append length as an array terminal and reject sorted/take/length plus existing count/first shapes before effects. CodeblockRuntime adds length to the existing terminal preflight. No grammar, descriptor or dependency change.\n  Review: Candidate1 introduced nested parameter arrays and lost computed take inputs; complete source/channels remain frozen. Candidate2 passed the new plan, but actual ablation proved its name/constructor edits redundant. Minimal candidate3 passes that plan but fails two old selectors in the first complete direct run. Candidate4 restores their shared preflight and passes56 new/four unchanged controls. Eight final faults require the bridge, array length, compiled guards, registered sorted/take guards and deferred length arity/terminal guards.\n  Documentation: Both exact book bodies and two inline routes execute on final source; all89 supplied book inputs render, actual anchor removal rejects, reference/limits/fact align. The first fact proposal refuses before writes; distinct document2 plus precision correction preserve old questions and fit unchanged budgets. The unused faults.py draft has no observation credit; seven faults2 observations belong only to the intermediate source. A final-instrument exact-one marker refuses the actual three manifest literals before output creation; distinct counted producer succeeds.\n  Durability: publish2.py binds scoped runtime/spec/test inputs, all owned observations and complete supplied book inputs; mutable continuity is excluded from gratuitous live dependencies. Dated whole input epochs and changed/new plain sources recover at real afc58252 plus supplied overrides. Other repositories and Gitlinks remain read-only black boxes.\n'
    after['docs/tasks/TYPE-REFERENCE-BOOK.md']=owner[:start]+node+owner[end:]
    after['MEMORY.md']='# MEMORY\n\n'+f'''- activation_commit: `{c.BASE}` — clean pipeline11 base; Git owns current identity.
- latest_completed_leaf: `{c.OWNER}` — subject `{c.OWNER} - repair registered array pipelines and length`.
- active_work_unit: `{c.OWNER}` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: From clean committed Git, activate TYPE-REFERENCE-BOOK.1.2.12; reproduce deferred indexed writes through public tools and repair the bounded typed-write contract before last14 and complete inventory/reference work.
- in_flight_uncommitted: none — intended clean post-landing state; exact canonical receipt and normal hooks govern admission.
- proof: {summary}; docs/checkpoints/type-registered-array-pipelines/publish2.py. Whole dated epochs and all failed/intermediate sources remain retained; no historical writer is rerun.
- runtime: Existing bridge consumes emitted array-chain values; length is a no-arg terminal in compiled/deferred chains. Prior count/first10 remains accepted79c68715; no full inventory/backend admission.
- owners:12 indexed writes ->14 deferred last ->inventory1/mapping2/layout3/legacy8/private QA. Numeric95, Boolean35, Unicode20/constructor94 remain separate.
- limits: Other repositories/RGX/PGEN stay read-only black boxes. Project data stays on the repository filesystem. Retain reusable caches/proof. No push until PNT is exhausted.
- cleanup: Latest2026-10-22T01:46:17.419099+00:00; REPO-HYGIENE.20 removed nothing; latest-only record docs/ARTIFACT_CLEANUP.md.
'''
    lines=after['ROADMAP_V2.md'].splitlines(keepends=True)
    assert lines[2].startswith('October22 current PNT boundary:')
    lines[2]='October22 current PNT boundary: TYPE-REFERENCE-BOOK.1.2.11 repairs registered array receiver pipelines and ordinary terminal length, including deferred length shape/effect alignment: '+summary+'. Exact canonical receipt governs normal landing. Next12 deferred indexed writes, then14 last before complete inventory/reference work; no other-backend or complete reference admission.\n'
    after['ROADMAP_V2.md']=''.join(lines).replace('After10 landing, continue the owned11/12/14 repairs','After11 landing, continue the owned12/14 repairs',1)
    tree=after['docs/TASK_TREE.md'].splitlines(keepends=True)
    for i,line in enumerate(tree):
        if line.startswith('| `TYPE-REFERENCE-BOOK` |'):
            tree[i]='| `TYPE-REFERENCE-BOOK` | `active` / next .1.2.12 | `.spec documentation / per-type reference` | Registered pipelines/length11: '+summary+'. Exact canonical admission required. Next12/14 before inventory1/mapping2/layout3/legacy8/private QA. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |\n'
    after['docs/TASK_TREE.md']=''.join(tree)
    live=after['LIVE_ACHIEVEMENT_STATUS.md']
    recent=live.split('## Recent Completions\n\n',1)[1].split('\n## History\n',1)[0].strip().splitlines()
    history=live.split('## History\n',1)[1]
    recent=['- `'+c.OWNER+'` —'+summary+'; indexed-write12 next.']+recent[:15]
    after['LIVE_ACHIEVEMENT_STATUS.md']='# LIVE ACHIEVEMENT STATUS\n\n## Current Activity\n\nTYPE-REFERENCE-BOOK.1.2.12 is next after clean11 landing: deferred typed indexed writes. Registered array pipelines/length11 have bounded selected proof; no complete inventory/reference admission.\n\n## Latest Completed Slice\n\n'+c.OWNER+' repairs synthetic array-chain lowering and terminal length preflight: '+summary+'. Exact canonical receipt and normal hooks govern admission.\n\n## Next Action\n\nActivate TYPE-REFERENCE-BOOK.1.2.12 from clean committed Git; reproduce through public tools and follow existing typed-write/copy/key/effect contracts. Commit each bounded slice before moving on.\n\n## Recent Completions\n\n'+'\n'.join(recent)+'\n\n## History\n'+history
    change='## 2026-10-22 — '+c.OWNER+' — registered array pipelines and terminal length\n\nRegistered functions now consume their actual array values through sorted/take receiver pipelines, and ordinary pipelines can end in length. The compiler reuses its existing bridge for emitted values. Sorted/take/length and existing count/first shape checks precede effects; deferred length follows the no-argument terminal contract. Runtime, permanent regression plan, worked book/reference, canonical fact and roadmap stay aligned.\n\nValidation: '+summary+'. Clean-source RED, rejected candidates, redundant-edit ablation, exact restoration, complete rendered book inputs and validator bypass controls survive. The first direct15 run rejects two old selectors while14 suites pass; a single bridge rollback/reapply attributes the regression, and current shared preflight preserves their untouched expectations. Exact staged canonical receipt and normal hooks govern landing. Other backends, indexed writes12, last14, reducers95 and complete references remain separate. Readonly evidence: docs/checkpoints/type-registered-array-pipelines/publish2.py.\n\n'
    notes='## 2026-10-22 — '+c.OWNER+' — respect the array composition boundary\n\nThe fluent array lowerer can already hold emitted callback/function expressions. Parsing that synthetic host text as new DSL loses scalar-backed function values and computed take inputs. Its established compatibility bridge consumes the composition directly. A first attempted name/constructor repair creates nested arrays; the preserved fixed grid rejects it. Actual ablation then proves extra name handling redundant while both registered invalid-shape guards remain necessary. The final repair is bounded to the bridge, array length and preflight guards.\n\n'+summary+'. Book examples execute on final source; complete89-input render and a real missing-anchor denial remain supplied. Earlier invalid callable syntax and a fact-budget refusal are instrument/preparation errors, retained without product-proof credit. Knowledge compaction preserves old questions and integer-spelling/private-float-flag/hash-gating precision. Whole dated input epochs recover from real afc58252 plus explicit overrides; the live publication binds actual runtime/spec/test/book inputs rather than mutable continuity.\n\n'
    for path,record in [('CHANGES.md',change),('DEVELOPMENT_NOTES.md',notes)]:
        text=after[path]
        point=text.index('\n## ')+1
        after[path]=text[:point]+record+text[point:]
    c.write_new('continuity-before.json.gz',dict(before=before,after=after,producer=c.read(c.PREFIX+'finalize2.py'),summary=summary,review=reviewed))
    for path,text in after.items():c.source(path).write_text(text)
    readme='''# Registered array pipelines and length

Owner: TYPE-REFERENCE-BOOK.1.2.11. Clean activation: afc58252ca36d53076929cd51e3ad445e4953341.
Readonly: `bash tools/run_python_project_data.sh docs/checkpoints/type-registered-array-pipelines/publish2.py`.

The fixed public plan covers registered parameter/local/rest/nested calls, lexical
number/string kinds, empty/nonarray selection, source preservation, computed calls,
ordinary/deferred length, invalid arity, terminals and ordered effects. The original
clean source and all actual descriptor/native/fresh emitted channels remain supplied.
The permanent scalar contract consumes the exact same plan. No complete inventory,
other-backend, deferred indexed-write12, last14 or reducer95 admission follows.

The first intake used invalid codeblock() syntax; its value_not_callable observation
is an instrument error. Corrected intake and the declared plan reproduce the product.
Candidate1 has nested parameter arrays and lost computed take values; its source and
channels remain immutable. Candidate2 passes, but actual ablation removes unnecessary
name/constructor edits. Minimal candidate3 passes the new plan but the first full
direct run rejects two unchanged count/first extra-arity controls; fourteen suites pass.
Actual single-bridge rollback GREEN/reapply RED attributes the regression. Candidate4
restores shared preflight, preserving all old expectations. Final direct proof passes.
Eight necessary final source faults reject and restore exactly. The unused faults.py
draft has no observation credit. Three actual artifact faults reject, admit under the
actual validator bypass and reject after exact restoration.

Both current book examples execute on final runtime. All89 complete source/config/include
inputs and actual healthy/changed rendered pages survive; missing anchor rejects.
The first fact proposal refuses before writes at the existing byte budget. Distinct
document2 and a precision correction preserve old questions and fit unchanged limits.
An instrument preflight expects one publisher manifest literal where three actually
exist, refuses before output creation, and is corrected in a distinct counted producer.

Capture, mutation and documentation actors are historical one-shot writers; never
rerun them on a changed tree. review.py/publish.py are readonly by default. Whole dated
epochs recover unchanged data at real accepted Git plus supplied full-mode plain
overrides and immutable artifact identities. Current publication dependencies are
scoped to actual runtime/spec/test/producer/book inputs; mutable continuity is excluded.
Other repositories/Gitlinks stay read-only black boxes; project data stays on-volume.
Exact staged canonical receipt and normal hooks govern landing. Next: indexed writes12.
'''
    with (c.ROOT/(c.PREFIX+'README.md')).open('x') as stream:stream.write(readme)
    instruments={}
    for name in ['pipeline11-intake.py','pipeline11-intake2.py','pipeline11-claims.py',
        'pipeline11-inspect.py','pipeline11-contain-doc.py','pipeline11-inline.py',
        'pipeline11-focused-inspect.py','pipeline11-final-instruments.py']:
        path='.linkedspec-data/verification/'+name
        instruments[path]=c.read(path)
    c.write_new('preparation-instruments.json.gz',dict(instruments=instruments,
        scope='Recoverable exact original diagnostic/preparation sources, including the invalid callable fixture and no-write fact refusal correction.'))
    changed=set(subprocess.check_output(['git','diff','--name-only','-z'],cwd=c.ROOT).decode().split('\0'))
    changed.update(p for p in subprocess.check_output(['git','ls-files','--others','--exclude-standard','-z'],cwd=c.ROOT).decode().split('\0') if p)
    live=[]
    for path in sorted((c.ROOT/'docs/claims').glob('*.json')):
        record=json.loads(path.read_text())
        for claim in record['claims']:
            durability=claim['durability']
            if durability.get('status')=='checked' and durability.get('mode')=='live':
                hits=sorted({p['path'] for p in durability['inputs']} & changed)
                live.append(dict(path=path.relative_to(c.ROOT).as_posix(),name=claim['name'],hits=hits,record=record))
    c.write_new('live-claims-final.json.gz',dict(planned=sorted(changed),live=live,intersections=[r for r in live if r['hits']]))
    assert all(not r['hits'] for r in live)
    print('Continuity synchronized:',summary)

if __name__=='__main__':main()
