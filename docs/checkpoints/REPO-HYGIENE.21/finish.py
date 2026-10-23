"""One-shot continuity closeout after the complete focused proof succeeds."""
import json
import re
import common as c
import context
import review


def main():
    result = review.check()
    metadata = result['metadata']
    rust = metadata['rust']['rust/target/debug/incremental']
    summary = (f"Dated {metadata['at_utc']} parent {metadata['parent_files']} candidates/"
        f"{metadata['parent_bytes']} bytes; Rust incremental {rust['files']}/{rust['bytes']}, "
        'with all six locations recorded separately; zero removals. Fresh/lstat/traversal proof, '
        'four metadata/four custody/three input controls and actual book-marker RED pass. '
        'Whole accepted12 and actual clean readonly0 precede writes; complete book89 and '
        'unchanged scalar core pass. Normal focused doctrines/hooks govern landing; signed17 follows clean Git.')
    paths = ['MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md','CHANGES.md',
        'docs/tasks/REPO-HYGIENE.md','docs/TASK_TREE.md','ROADMAP_V2.md']
    before = {path:c.read(path) for path in paths}
    c.write_new('final-continuity-before.json.gz',dict(context=context.snapshot(),before=before,
        producer=c.read(c.PREFIX+'finish.py'),result=result))
    draft = {path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    tree = draft['docs/tasks/REPO-HYGIENE.md']
    start = tree.index('- ID: `REPO-HYGIENE.21`')
    stop = tree.index('## Current Frontier',start)
    node = tree[start:stop].replace('Status: `active`','Status: `done` / focused proof; normal landing required',1)
    node = node.replace('- [ ]','- [x]')
    node += '  Verified disposition: '+summary+'\n  Engineering notes: unchanged; this repeats the established dated metadata/retention procedure without a new structural or causal conclusion.\n  Commit subject: `REPO-HYGIENE.21 - review retained project artifacts`.\n\n'
    tree = tree[:start]+node+tree[stop:]
    tree = tree.replace('- Status: `active` / due retained review .21','- Status: `completed` / retained review .21 verified',1)
    tree = tree.replace('  Status: `active`\n  Goal: `Repository hygiene','  Status: `done`\n  Goal: `Repository hygiene',1)
    tree = tree.replace('| 0 | `REPO-HYGIENE.21` | `active` | Due daily review; resume signed17 from clean Git. |',
        '| 0 | `REPO-HYGIENE.21` | `done` | Due retained review verified; signed17 follows clean landing. |',1)
    tree = tree.replace('## Changelog\n','## Changelog\n\n- `2026-10-23`: .21 completes the due retained review, accepted12 custody and current book example; no removals. Resume director-priority signed17.\n',1)
    draft['docs/tasks/REPO-HYGIENE.md'] = tree
    draft['MEMORY.md'] = f'''# MEMORY

- activation_commit: `{c.BASE}` — clean hygiene21 base; Git owns current identity.
- latest_completed_leaf: `REPO-HYGIENE.21`; subject `REPO-HYGIENE.21 - review retained project artifacts`.
- active_work_unit: `REPO-HYGIENE.21` (completed); task_owner: docs/tasks/REPO-HYGIENE.md.
- next_action: From clean committed Git activate TYPE-REFERENCE-BOOK.1.2.17, recover the shared indexed-read/write contracts and public probes, then split bounded contract/backend/admission children before implementation.
- in_flight_uncommitted: none — intended clean post-landing handoff; normal focused hooks govern admission.
- proof: docs/checkpoints/REPO-HYGIENE.21/publish.py is readonly by default. Whole accepted deferred-write12 publication4 and actual clean readonly0 remain at1e6096435; historical writers must not be rerun.
- steering: [-n]=[size-n] only when size-n>=0; -1 is last and -size is first. Signed17 precedes last14, deferred with16, grouped19, raw-regex21, policy20 and complete inventory.
- limits: Zero artifact removals; retain proof and reusable caches. Other repositories/submodules remain read-only black boxes; all project data stays on-volume. No push until PNT exhausted.
- blockers: none established; signed-selector contract/backend admission is pending.
'''
    live = draft['LIVE_ACHIEVEMENT_STATUS.md']
    live = re.sub(r'(## Current Activity\n\n).*?(?=\n## Latest Completed Slice)',
        lambda match:match.group(1)+'Due artifact review21 is complete; director-priority signed selectors TYPE-REFERENCE-BOOK.1.2.17 is the next feature. Deferred-write12 is committed at1e6096435 with canonical proof. No signed-selector admission yet.\n',live,flags=re.S)
    live = re.sub(r'(## Latest Completed Slice\n\n).*?(?=\n## Next Action)',
        lambda match:match.group(1)+'REPO-HYGIENE.21: '+summary+'\n',live,flags=re.S)
    live = re.sub(r'(## Next Action\n\n).*?(?=\n## Recent Completions)',
        lambda match:match.group(1)+'From clean Git activate/split signed17 across shared contracts and owned backends; then14/16/19/raw-regex21/policy20 before complete inventory/reference work.\n',live,flags=re.S)
    start = live.index('## Recent Completions\n')+len('## Recent Completions\n')
    stop = live.index('## History',start)
    rows = [row for row in live[start:stop].splitlines() if row.startswith('- ')]
    rows.insert(0,'- `REPO-HYGIENE.21` — dated22830 parent/483 Rust incremental; zero removals; metadata4/custody4/input3/book89 marker RED/core PASS; whole accepted12 custody; signed17 next.')
    draft['LIVE_ACHIEVEMENT_STATUS.md'] = live[:start]+'\n'+'\n'.join(rows[:16])+'\n\n'+live[stop:]
    change = '## 2026-10-23 — REPO-HYGIENE.21 — retain due artifact review\n\n'+summary+'\n\nThe current book example and Knowledge reverify headers name the appropriate retained or historical boundary; questions and historical bodies remain exact. Reusable caches, package data, logs and all other repositories are untouched. No runtime, contract, storage policy or gate change.\n\n'
    match = re.search(r'^## ',draft['CHANGES.md'],flags=re.M)
    assert match
    draft['CHANGES.md'] = draft['CHANGES.md'][:match.start()]+change+draft['CHANGES.md'][match.start():]
    index = draft['docs/TASK_TREE.md']
    index,count = re.subn(r'^Latest PNT slice: .*$', 'Latest PNT slice: REPO-HYGIENE.21 completes the due retained-artifact review with zero removals, source-bound metadata/custody controls and current book example. Deferred-write12 is committed at1e6096435 after canonical CI/all10 hooks. Director-priority signed17 follows clean Git; full references remain pending.',index,count=1,flags=re.M)
    assert count == 1
    index,count = re.subn(r'^\| `REPO-HYGIENE` .*$', '| `REPO-HYGIENE` | `completed` / retained review .21 verified | `Overall roadmap / repository maintenance` | Dated22830 parent/483 Rust incremental, zero removals; metadata4/custody4/input3, book89 marker RED and unchanged core. Whole accepted12 custody; signed17 follows clean landing. | [docs/tasks/REPO-HYGIENE.md](docs/tasks/REPO-HYGIENE.md) |',index,count=1,flags=re.M)
    assert count == 1
    draft['docs/TASK_TREE.md'] = index
    roadmap = draft['ROADMAP_V2.md']
    roadmap,count = re.subn(r'^October23 current PNT boundary: .*$',
        'October23 current PNT boundary: REPO-HYGIENE.21 completes the due retained-artifact review with zero removals, full actual metadata/custody controls, current complete book89/marker RED and unchanged core consumer. Deferred-write12 is committed at1e6096435 with canonical CI/all10 hooks. Director-priority signed selectors17 follows clean Git;14/16/19/raw-regex21/policy20 and complete type references remain queued. No other-backend or wider historical-audit admission.',roadmap,count=1,flags=re.M)
    assert count == 1
    draft['ROADMAP_V2.md'] = roadmap.replace('After12 landing, implement director-priority signed selectors17','After due hygiene21 landing, implement director-priority signed selectors17',1)
    for path,text in draft.items():
        c.source(path).write_text(text)
    c.write_new('finalization.json.gz',dict(result=result,before=before,
        after={path:c.read(path) for path in paths},producer=c.read(c.PREFIX+'finish.py')))
    c.source('git_message_brief.txt').write_text('REPO-HYGIENE.21 - review retained project artifacts\n\nRetain dated parent/Rust metadata and all proof/cache data; zero removals.\nPreserve whole accepted deferred-write12 publication and actual clean baseline\nbefore shared writes; retire its claim at the real accepted Git boundary.\n\nVerify independent per-file metadata, named custody/input denials, complete\nbook render and unchanged scalar core. Resume signed selectors17 from clean Git.\n')
    print('Focused maintenance closeout prepared:',json.dumps(result,sort_keys=True))


if __name__ == '__main__':
    main()
