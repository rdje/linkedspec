"""Close the owned publication prerequisite without changing runtime/test oracles."""
import re
import common as c
import review4

def section(text,name,body):
    pattern=r'(?ms)(^## '+re.escape(name)+r'\n\n).*?(?=^## |\Z)'
    result,count=re.subn(pattern,lambda match:match[1]+body+'\n\n',text,count=1)
    assert count==1,name
    return result

def record(text,body):
    marker='\n## 2026-10-22 — '+c.OWNER+' — '
    start=text.index(marker)+1
    end=text.find('\n## ',start+1)
    return text[:start]+body+(text[end:] if end>=0 else '')

def main():
    proof=review4.check()
    summary=f"{proof['cases']} cases/{proof['accepted_red']} accepted RED/{proof['accepted_controls']} controls;compatibility4;{len(proof['faults'])} restored faults;{proof['direct_suites']}/{proof['direct_tap']} TAP;book89/2+inline2;artifact3;fixture omission/bypass/restoration"
    paths=['MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md','ROADMAP_V2.md','docs/TASK_TREE.md',
        'docs/tasks/TYPE-REFERENCE-BOOK.md','CHANGES.md','DEVELOPMENT_NOTES.md',c.PREFIX+'README.md']
    before={p:c.read(p) for p in paths}
    after={p:c.decode(packet['base64']).decode() for p,packet in before.items()}
    saved=c.load('publication2-preserved.json.gz')
    assert before[c.PREFIX+'README.md']==saved['original'][c.PREFIX+'README.md']
    task=after['docs/tasks/TYPE-REFERENCE-BOOK.md']
    start=task.index('- ID: `'+c.OWNER+'`\n')
    end=task.index('\n- ID: ',start+1)
    node=task[start:end]
    node=re.sub(r'^  Status:.*$', '  Status: `completed` / bounded behavior and conservative input closure verified',node,count=1,flags=re.M)
    node=re.sub(r'^  Durability:.*$', '  Durability: Current publish4.py conservatively gates every regular main-repository input, including continuity, with the complete measured epoch and independent required-fixture floor. Original unpublished publication2/714 inputs and actual readonly0 remain whole; README/claim before images preserve the only subsequently changed bound images. Gitlinks/symlinks and public tool/dependency outputs remain read-only prerequisites. No minimal I/O graph, fabricated accepted revision or wider historical-audit closure is inferred.',node,count=1,flags=re.M)
    node=re.sub(r'^  Publication prerequisite owned here:.*$', '  Publication prerequisite verified: Initial live714 omits four named inputs: nested-tree/scoped-with case JSON and two private before-native captures; their complete measured epoch and Git recovery were already retained. Whole unpublished publication2/714 physical inputs/full modes and actual readonly0 precede expansion. Actual input-enumerator omission rejects against the measured floor, admits under actual scope-validator bypass, rejects after validator restoration and restores exactly. Three current publisher missing/byte/mode controls also reject/bypass/restore. The first scope3 instrument calls absent common.paths and all states fail before validation; it receives no RED credit. Distinct publisher4 owns the explicit regular Git/untracked census. Existing canonical closure fact is updated with old body/questions retained and no byte increase.',node,count=1,flags=re.M)
    node=node.replace('Match the documented terminal/no-argument receiver contract','Matched the documented terminal/no-argument receiver contract',1)
    node+='\n  Final admission: '+summary+'. Current gateway publish4.py; exact staged canonical receipt and normal hooks remain mandatory before clean landing. Runtime and all fixture expectations remain unchanged by the closure repair. Next12 only from clean Git.\n'
    after['docs/tasks/TYPE-REFERENCE-BOOK.md']=task[:start]+node+task[end:]
    after['MEMORY.md']='# MEMORY\n\n'+f'''- activation_commit: `{c.BASE}` — clean pipeline11 base; Git owns current identity.
- latest_completed_leaf: `{c.OWNER}` — subject `{c.OWNER} - repair registered array pipelines and length`.
- active_work_unit: `{c.OWNER}` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: From clean committed Git activate TYPE-REFERENCE-BOOK.1.2.12; reproduce deferred indexed writes through public tools and repair the bounded typed-write contract before last14 and complete inventory/reference work.
- in_flight_uncommitted: none — intended clean post-landing state; exact canonical receipt and normal hooks govern admission.
- proof: {summary}; docs/checkpoints/type-registered-array-pipelines/publish4.py. Whole unpublished714/actual readonly0 and all intermediate source epochs remain retained; no historical writer is rerun.
- runtime: Existing bridge consumes emitted array-chain values; count/first/length receiver shapes reject before effects, length is terminal in compiled/deferred chains. No complete inventory/backend admission.
- closure: Conservative regular main-repository watchset covers the full measured epoch and four independently named omitted fixtures; no minimal I/O graph or wider historical-audit closeout. Old claim/README full-mode images remain archived.
- owners:12 indexed writes ->14 last ->inventory1/mapping2/layout3/legacy8/private QA. Numeric95, Boolean35, Unicode20/constructor94 stay separate.
- limits: Other repositories/RGX/PGEN remain read-only black boxes; project data stays on-volume; retain reusable caches/proof. No push until PNT is exhausted.
- cleanup: Latest2026-10-22T01:46:17.419099+00:00; maintenance20 removed nothing; docs/ARTIFACT_CLEANUP.md is latest-only.
'''
    lines=after['ROADMAP_V2.md'].splitlines(keepends=True)
    assert lines[2].startswith('October22 current PNT boundary:')
    lines[2]='October22 current PNT boundary: TYPE-REFERENCE-BOOK.1.2.11 repairs registered array pipelines and terminal length: '+summary+'. Complete measured-input closure and whole unpublished714 custody now govern the publication. Exact canonical receipt and normal hooks remain mandatory. Next12/14 before complete inventory/reference work; no other-backend or wider historical-audit admission.\n'
    after['ROADMAP_V2.md']=''.join(lines)
    rows=after['docs/TASK_TREE.md'].splitlines(keepends=True)
    for i,row in enumerate(rows):
        if row.startswith('| `TYPE-REFERENCE-BOOK` |'):
            rows[i]='| `TYPE-REFERENCE-BOOK` | `active` / next .1.2.12 | `.spec documentation / per-type reference` | Pipelines/length11: '+summary+'; whole714 preservation and conservative measured-input closure. Exact canonical admission required. Next12/14 before inventory/mapping/layout/legacy/private QA. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |\n'
    after['docs/TASK_TREE.md']=''.join(rows)
    live=after['LIVE_ACHIEVEMENT_STATUS.md']
    live=section(live,'Current Activity','TYPE-REFERENCE-BOOK.1.2.12 is next after clean11 landing: deferred typed indexed writes. Registered pipelines/length and the owned proof-input closure are bounded; complete inventory/reference admission remains pending.')
    live=section(live,'Latest Completed Slice',c.OWNER+': '+summary+'. Whole unpublished714/actual readonly0 remains preserved; conservative full measured-input closure replaces the too-narrow watchset. Exact canonical receipt and normal hooks govern admission.')
    live=re.sub(r'^- `'+re.escape(c.OWNER)+r'`.*$', '- `'+c.OWNER+'` —'+summary+'; conservative closure/whole714; indexed-write12 next.',live,count=1,flags=re.M)
    after['LIVE_ACHIEVEMENT_STATUS.md']=live
    common='\n\nValidation: '+summary+'. Original clean-source RED and all failed/intermediate epochs remain exact. The first complete direct15 run fails two old selectors while14 suites pass; actual bridge rollback/reapply attributes the regression and shared preflight preserves the untouched expectations. Four omitted fixture inputs were already retained in the complete measured epoch; the current conservative reader now watches them and falsifies actual enumeration omission. Whole unpublished714/full modes/actual readonly0 precedes changes. Exact staged canonical receipt and normal hooks govern landing. Readonly: docs/checkpoints/type-registered-array-pipelines/publish4.py. Other backends, indexed writes12, last14, reducers95, complete references and the wider historical audit stay separate.\n'
    change='## 2026-10-22 — '+c.OWNER+' — registered array pipelines and terminal length\n\nRegistered functions consume actual array values through sorted/take receiver pipelines, and ordinary pipelines can end in length. The existing compatibility bridge consumes emitted values; sorted/take/length plus existing count/first guards reject before effects. Deferred length follows the no-argument terminal contract. Runtime, permanent fixtures, worked book/reference, canonical facts and roadmap stay aligned.'+common
    notes='## 2026-10-22 — '+c.OWNER+' — array composition and complete measured inputs\n\nSynthetic array chains can contain emitted function/callback expressions; parsing that host text again as DSL loses typed values. The existing bridge consumes it directly. Rejected nested-array candidate1, redundant-edit ablation and the repaired old count/first guards remain explicit. A suite-file/perl/spec watchset also misses checkpoint/oracle JSON read by broader consumers. Reuse the already complete measured epoch as a conservative floor and independently require the actual named omitted inputs; actual enumerator omission and validator bypass distinguish this from two mutually agreeing incomplete sets. The canonical closure fact retains its original body/questions, with no increased allowance.'+common
    after['CHANGES.md']=record(after['CHANGES.md'],change)
    after['DEVELOPMENT_NOTES.md']=record(after['DEVELOPMENT_NOTES.md'],notes)
    readme=after[c.PREFIX+'README.md'].replace('publish2.py','publish4.py').replace('review.py/publish.py','review4.py/publish4.py')
    readme=readme.replace('Current publication dependencies are\nscoped to actual runtime/spec/test/producer/book inputs; mutable continuity is excluded.', 'Current publication conservatively watches every regular main-repository input,\nincluding continuity; the complete measured epoch and named fixtures form an independent\ncompleteness floor. This is a superset, not a minimal I/O graph.')
    readme+='\nPublication2/714 and its actual readonly0 remain whole and unpublished; no accepted\nrevision is invented. Four fixture omissions were retained in the full measured epoch\nbut missed by the initial watchset. Publisher4 closes that gap; actual enumeration\nomission rejects, scope bypass admits, validator restoration rejects, and exact\nsource restoration passes. The scope3 draft assumes absent common.paths; all states\nfail before validation and receive no RED credit. Current artifact4 controls prove\nactual missing/byte/mode rejection, bypass admission and exact restoration.\n'
    after[c.PREFIX+'README.md']=readme
    c.write_new('continuity3-before.json.gz',dict(before=before,after=after,proof=proof,producer=c.read(c.PREFIX+'finalize3.py')))
    for path,text in after.items():c.source(path).write_text(text)
    print('Final behavior/closure continuity synchronized:',summary)

if __name__=='__main__':main()
