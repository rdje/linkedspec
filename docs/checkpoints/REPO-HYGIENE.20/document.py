"""Publish bounded maintenance guidance after the actual metadata proof succeeds."""
import datetime
import json
import re
import common as c
import context
import metadata_review

BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
ARTIFACT_CARD = 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md'
HELPER_CARD = 'docs/knowledge/terse-type-method-surface-inventory.md'
MARKER = 'Complete fresh comparisons before printing a report whose own log belongs to the census.'


def main():
    result = metadata_review.validate(c.load('metadata.json.gz'))
    assert (result['parent_files'],result['parent_bytes']) == (22234,21703659874)
    assert result['rust']['rust/target/debug/incremental'] == dict(files=483,bytes=2390835179,exists=True)
    observed = c.load('metadata-controls.json.gz')
    assert observed['healthy']['returncode'] == observed['restored']['returncode'] == 0
    assert len(observed['faults']) == 4 and all(run['returncode'] != 0 for run in observed['faults'].values())
    paths = [BOOK, ARTIFACT_CARD, HELPER_CARD, 'docs/ARTIFACT_CLEANUP.md',
        'MEMORY.md', 'LIVE_ACHIEVEMENT_STATUS.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md',
        'docs/tasks/REPO-HYGIENE.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md']
    before = {path:c.read(path) for path in paths}
    values = {path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    book = values[BOOK]
    anchor = 'A successful review may remove zero files.\n'
    assert book.count(anchor) == 1
    values[BOOK] = book.replace(anchor, anchor + MARKER + '\nKeep the raw channels; later log growth belongs to a new dated observation.\n', 1)
    card = values[ARTIFACT_CARD]
    end = card.index('\n---\n', 4) + 5
    header, body = card[:end], card[end:]
    header = re.sub(r'^date:.*$', 'date: 2026-10-22', header, count=1, flags=re.M)
    header = re.sub(r'^evidence:.*$',
        'evidence: "Hygiene3-.5 established the historical rebuildable-output boundary. SSD-rooting2.0-.2.6 retains reusable caches and runtime-derived scratch on the 4TB repository filesystem; off-volume project output rejects. tools/test_tool_project_data_storage.sh proves scoped output boundaries."',
        header, count=1, flags=re.M)
    header = re.sub(r'^reverify:.*$',
        'reverify: "bash tools/run_python_project_data.sh docs/checkpoints/REPO-HYGIENE.20/review.py"',
        header, count=1, flags=re.M)
    addition = ('evidence_update_2026_10_22: "Hygiene20 retains dated22234 parent/483 Rust rows, zero removals; fresh/lstat/traversal proof and four reader denials pass. Whole accepted10 custody precedes shared writes; metadata grants no deletion or purge authority."\n')
    assert '\nevidence_update_2026_10_22:' not in header
    header = header[:-4] + addition + '---\n'
    values[ARTIFACT_CARD] = header + body
    helper = values[HELPER_CARD]
    old = 'reverify: "bash tools/run_python_project_data.sh docs/checkpoints/type-array-count-first/publish.py"'
    assert helper.count(old) == 1
    values[HELPER_CARD] = helper.replace(old,
        'reverify: "bash tools/project_data_run.sh prove -Iperl t/scalar_numeric_contract.t"', 1)
    # Only headers change; all historical cleanup bodies and every question remain exact.
    assert values[ARTIFACT_CARD][len(header):] == body
    old_bytes = sum(len(c.decode(before[path]['base64'])) for path in (ARTIFACT_CARD, HELPER_CARD))
    new_bytes = sum(len(values[path].encode()) for path in (ARTIFACT_CARD, HELPER_CARD))
    assert new_bytes <= old_bytes + 2, (old_bytes,new_bytes)
    now = datetime.datetime.now(datetime.timezone.utc).isoformat()
    values['docs/ARTIFACT_CLEANUP.md'] = ('# Latest artifact cleanup\n\n- Date: '+now+'\n'
        '- Summary: REPO-HYGIENE.20 completed a non-following dated parent/Rust review; zero removals. All verification inputs, logs, reusable caches, package data and other repositories remain untouched. Full actual channels, independent metadata checks and falsifiers are retained under docs/checkpoints/REPO-HYGIENE.20/.\n')
    values['MEMORY.md'] = f'''# MEMORY

- activation_commit: `{c.BASE}` — clean maintenance20 base; Git owns current identity.
- latest_completed_leaf: `REPO-HYGIENE.20` — subject `REPO-HYGIENE.20 - review retained project artifacts`.
- active_work_unit: `REPO-HYGIENE.20` (completed); task_owner: docs/tasks/REPO-HYGIENE.md.
- next_action: From clean committed Git, activate TYPE-REFERENCE-BOOK.1.2.11; reproduce registered sorted receiver pipelines and ordinary length continuation through public tools before repairing the bounded contract.
- in_flight_uncommitted: none — intended clean post-landing state; focused checks and normal hooks govern admission.
- maintenance: docs/checkpoints/REPO-HYGIENE.20/review.py; dated22234 parent rows/21703659874 bytes, six Rust locations including483 incremental rows/2390835179 bytes; zero removals. Fresh/lstat/traversal proof and four reason-sensitive reader denials pass. No ownership/disposability, liveness/recovery/purge or adversarial guarantee.
- custody: Accepted10 whole publication4,11129 physical inputs/11132 independently Git-verified full-mode images, older logical aliases and actual clean readonly0 remain preserved at79c68715. Claim10 is historical only there; runtime and all original proof bytes are unchanged.
- runtime: Count/first10 accepted79c68715 after232 cases/eight faults/private91-32246/Phase01035/book89-5/history680/canonical and all10 normal hooks; no complete inventory/backend admission.
- owners:11 registered sorted/ordinary length ->12 deferred indexed writes ->14 deferred last ->inventory/mapping/layout/legacy/private QA. Other numeric/Boolean/Unicode owners remain separate.
- limits: Other repositories/RGX/PGEN stay read-only black boxes. Project data stays on the repository filesystem. Reusable caches and proof remain retained. No push until PNT is exhausted.
- cleanup: Latest{now}; zero removals; the latest-only record is docs/ARTIFACT_CLEANUP.md.
'''
    tree = values['docs/tasks/REPO-HYGIENE.md']
    tree = tree.replace('- Status: `active` / due retained review .20', '- Status: `completed` / retained review .20 verified', 1)
    tree = tree.replace('  Status: `active`\n  Goal: `Repository hygiene', '  Status: `done`\n  Goal: `Repository hygiene', 1)
    tree = tree.replace('Status: `active` / accepted10 custody preserved', 'Status: `done` / focused proof; normal landing required', 1)
    start, end = tree.index('- ID: `REPO-HYGIENE.20`'), tree.index('## Current Frontier')
    leaf = tree[start:end]
    leaf = leaf.replace('- [ ] **', '- [x] **')
    leaf += ('  Verified disposition: dated22234 parent candidates/21703659874 bytes;483 Rust incremental candidates/2390835179 bytes, with the other five explicit root/crate locations empty or absent. Retain every artifact/cache: zero removals. Actual two-census/fresh/per-file OS and six traversal controls pass; aggregate, coherent balanced-file, producer-channel and source-identity faults reject for their named reasons. Whole accepted10 and actual clean readonly0 remain bound to real79c68715. Complete book/core/Knowledge/history/doctrines and normal focused landing govern admission; no new runtime feature or dependency classification.\n\n')
    tree = tree[:start] + leaf + tree[end:]
    tree = tree.replace('| `REPO-HYGIENE.20` | `active` |', '| `REPO-HYGIENE.20` | `done` |', 1)
    values['docs/tasks/REPO-HYGIENE.md'] = tree
    live = values['LIVE_ACHIEVEMENT_STATUS.md']
    start,end = live.index('## Current Activity\n\n'),live.index('\n## Latest Completed Slice')
    live = live[:start] + '## Current Activity\n\nTYPE-REFERENCE-BOOK.1.2.11 is next after clean maintenance20 landing: registered sorted receiver pipelines and ordinary length continuation. Count/first10 is accepted at79c68715; no full inventory/reference admission.\n' + live[end:]
    start,end = live.index('## Latest Completed Slice\n\n'),live.index('\n## Next Action')
    live = live[:start] + '## Latest Completed Slice\n\nREPO-HYGIENE.20 retains dated22234 parent rows and483 Rust incremental rows, zero removals, full actual/fresh/lstat/traversal proof and four named reader denials. Whole accepted10/actual clean readonly0 precedes shared writes; runtime, proof and reusable caches remain unchanged. Focused proof and normal hooks govern landing.\n' + live[end:]
    start,end = live.index('## Next Action\n\n'),live.index('\n## Recent Completions')
    live = live[:start] + '## Next Action\n\nActivate TYPE-REFERENCE-BOOK.1.2.11 from clean committed Git and reproduce its two registered-pipeline/length defects through public tools; commit every bounded slice before moving on.\n' + live[end:]
    start,end = live.index('## Recent Completions\n\n'),live.index('\n## History')
    rows = live[start+len('## Recent Completions\n\n'):end].strip().splitlines()
    rows = ['- `REPO-HYGIENE.20` — dated22234 parent/483 Rust incremental; zero removals; four reader denials and accepted10 custody; pipeline11 next.'] + rows
    live = live[:start] + '## Recent Completions\n\n' + '\n'.join(rows[:16]) + '\n' + live[end:]
    values['LIVE_ACHIEVEMENT_STATUS.md'] = live
    roadmap = values['ROADMAP_V2.md'].splitlines()
    roadmap[2] = 'October22 current PNT boundary: REPO-HYGIENE.20 completes the due dated artifact review at accepted count/first10 commit79c68715:22234 parent/483 Rust incremental candidates, zero removals; fresh/lstat/traversal proof and four named reader denials. Whole accepted10 and actual clean readonly0 remain preserved. Next TYPE-REFERENCE-BOOK.1.2.11 registered sorted/ordinary length, then12/14 before complete inventory/reference work. Focused normal landing governs this maintenance; no new runtime/backend admission.'
    values['ROADMAP_V2.md'] = '\n'.join(roadmap)+'\n'
    index = values['docs/TASK_TREE.md'].splitlines()
    for number,line in enumerate(index):
        if line.startswith('| `REPO-HYGIENE` |'):
            index[number] = '| `REPO-HYGIENE` | `completed` / retained review .20 verified | `Overall roadmap / repository maintenance` | Dated22234 parent/483 Rust incremental, zero removals; full channels/fresh/lstat/traversal and four reader denials; accepted10 whole custody. Focused normal landing before TYPE-REFERENCE-BOOK.1.2.11. | [docs/tasks/REPO-HYGIENE.md](docs/tasks/REPO-HYGIENE.md) |'
    values['docs/TASK_TREE.md'] = '\n'.join(index)+'\n'
    record = ('\n## 2026-10-22 - REPO-HYGIENE.20: retain dated project artifacts\n\n'
        'Retain all artifacts and reusable caches after the due non-following review:22234 parent candidates/21703659874 bytes and483 Rust incremental candidates/2390835179 bytes. All six root/crate Rust locations and default Dart/Julia/Lua conventions are explicit. Two actual censuses, independent per-file metadata and traversal proof pass; four named reader faults reject. Whole accepted count/first10 and actual clean readonly0 survive at79c68715 before shared writes. Source-bound proof is under docs/checkpoints/REPO-HYGIENE.20/. No runtime, dependency, storage/gate policy or budget change; pipeline11 follows clean focused landing.\n')
    for path in ('CHANGES.md','DEVELOPMENT_NOTES.md'):
        source = values[path]
        at = source.index('\n## ')
        values[path] = source[:at] + record + source[at:]
    c.write_new('documentation-inputs.json.gz',dict(context=context.snapshot(),before=before,
        producer=c.read(c.PREFIX+'document.py')))
    for path,text in values.items():
        c.source(path).write_text(text)
        c.source(path).chmod(before[path]['mode'])
    c.write_new('documentation.json.gz',dict(before=before,after={path:c.read(path) for path in paths},
        knowledge_byte_delta=new_bytes-old_bytes,metadata=result,record_date=now,
        scope='Only current maintenance guidance/headers/continuity change; original cleanup body/questions stay exact. Source/claim10 historical preservation precedes all shared writes; budgets and runtime stay unchanged.'))
    print('Maintenance documentation aligned; Knowledge byte delta',new_bytes-old_bytes,'; zero removals')


if __name__ == '__main__':
    main()
