"""One-shot documentation closeout after terminal cleanup/retained reviews."""
import datetime
import hashlib
import json
from pathlib import Path
import re
import runpy
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[4]
PREFIX = Path(__file__).parent
V = ROOT / '.linkedspec-data/verification'
WORK = V / 'project-data-cleanup46-2'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.3.46.2'
NEXT = 'TYPE-REFERENCE-BOOK.1.2.23.3.55.2'
BASE = '3332cf3be2695d3456a0c47a3215c44a78b14cf0'
assert sys.argv[1:] == ['--capture']
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
assert not (ROOT / 'git_message_brief.txt').read_bytes()
plan = json.loads((WORK / 'plan.json').read_text())
disposal = json.loads((WORK / 'disposal.json').read_text())
review = json.loads((V / 'project-data-cleanup46-2-review.log').read_text())
retained = json.loads((V / 'project-data-cleanup46-2-retained-review.log').read_text())
assert review['planned_objects_absent'] == disposal['deleted_objects'] == plan['totals']['selected_files']
assert review['retained_entries_exact'] == plan['totals']['retained_entries']
assert retained['totals'] == plan['totals']
n = plan['totals']['selected_files']
logical = plan['totals']['selected_logical_bytes']
allocated = plan['totals']['selected_allocated_bytes']
kept = plan['totals']['retained_entries']
subject = OWNER + ' - remove obsolete unshared Rust compiler objects safely'
proof = (f'Requested cleanup removes exactly {n} old single-link regular non-executable .rcgu.o files '
         f'from the saved pre-adoption target; captured metadata records {logical} logical/{allocated} allocated bytes, '
         f'not physical volume free-space causality. All {kept} other direct entries retain exact identities. '
         'Successful permitted liveness actually rejects the live inventory owner, then accepts the idle directory. '
         'Reversible quarantine excludes old deps while current public offline Rust rule-call6 passes; actual executable '
         'and source inputs are retained. Exact per-file identity guards precede unlink, full retained/absence/residue '
         'review passes, original deps name is restored and quarantine is absent. Historical executables, hardlinks, '
         'source/evidence/package stores/incremental/current target and adjacent retained RGX repository remain. '
         'Original disposable object bytes/exact old-build reproduction are not claimed. Complete metadata/producers/epochs '
         'are split into bounded retained parts; readonly retained review independently re-derives totals and verifies '
         'actual test executable/source custody. Seven actual guard controls pass; initial existing-sibling path guard '
         'admission is repaired before mutation. Ad-hoc top-level claim lookup is corrected to claims[].durability, '
         'distinguishing sentinel detects the old false negative, and accepted complete namespace preflight has no '
         'planned/reviewed recent-production live intersections. Initial empty discovery earns no proof credit; '
         'canonical validator was already correct. Partial redundant old-target du stopped143; complete scratch census0. '
         'Latest cleanup entry/book/knowledge/live/task/history/resume align. Independent Rust55.2 resumes immediately; '
         'no full suite/push/storage-policy/dependency implementation change.')
action = ('Activate ' + NEXT + ' from clean cleanup46.2; resume frozen gap/slot record55 feature implementation. '
          'Read gap-slot-record-selection.md/shared fixture, Rust existing detached gap/slot helper ABI, typed computed-read '
          'source classification/function/context error/deferred fences and nearest gap/computed tests. Independently '
          'reproduce finite native/restored/generated-plan target before production; preserve null direct-slot versus '
          'typed unavailable-gap errors, record fields/zero/missing/once/order/normalized skips and legacy first-consumer '
          'policies. Implement only a confirmed bounded source/guard gap; compile/quick new and nearest checks/docs/book/'
          'commit, then Dart55.3. No full CI/Phase0 per feature, dependency inspection or broad cleanup.')

tree_path = ROOT / 'docs/tasks/TYPE-REFERENCE-BOOK.md'
tree = tree_path.read_text()
start = tree.index('- ID: `' + OWNER + '`')
end = tree.index('\n- ID:', start + 1)
node = tree[start:end]
assert 'Status: `in_progress`' in node
node = node.replace('Status: `in_progress`', 'Status: `completed`', 1).replace('- [ ]', '- [x]')
node = re.sub(r'^  Planned (?:verification tier|focused checks|canonical trigger|claim verification):.*\n', '', node, flags=re.M)
node += '\n  Result: ' + proof + '\n  Commit: `' + subject + '`.\n'
tree = tree[:start] + node + tree[end:]
tree = tree.replace('Status: `in_progress` / daily46/46.1 completed; director-requested project-data cleanup46.2 pending',
                    'Status: `completed` / daily46/46.1 and requested object cleanup46.2 have separate retained outcomes', 1)
tree = tree.replace('requested safe cleanup46.2 precedes independent Rust55.2',
                    'requested object cleanup46.2 is verified; independent Rust55.2 resumes', 1)
tree = tree.replace('| 1 | `' + OWNER + '` | `in_progress` | Guarded disposal complete; collect full retained-entry review, retain/check/docs/commit, then resume independent Rust55.2. |',
                    '| 1 | `' + NEXT + '` | `pending` | Resume independent Rust gap/slot record55.2 after committed safe object cleanup46.2. |', 1)
tree_path.write_text(tree)

for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = ROOT / name
    value = path.read_text()
    old = 'requested safe cleanup46.2 precedes independent Rust55.2'
    assert value.count(old) == 1
    path.write_text(value.replace(old, 'requested obsolete-object cleanup46.2 is verified; independent Rust55.2 resumes', 1))
path = ROOT / 'docs/TASK_TREE.md'
value = path.read_text()
value = re.sub(r'^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — exact obsolete unshared Cargo objects removed; current Rust6 and retained/residue controls pass. Resume independent Rust55.2.', value, count=1, flags=re.M)
value = value.replace('director-requested safe project-data cleanup46.2 next, then independent Rust55.2',
                      'requested object cleanup46.2 verified; independent Rust55.2 resumes', 1)
path.write_text(value)

now = datetime.datetime.now(datetime.timezone.utc).isoformat()
(ROOT / 'docs/ARTIFACT_CLEANUP.md').write_text('# Latest artifact cleanup\n\n- Date: ' + now + '\n- Summary: ' + OWNER +
    f' removed {n} obsolete single-link non-executable Cargo .rcgu.o objects from the saved pre-adoption target '
    f'({logical} logical/{allocated} per-inode allocated bytes; no physical free-space claim), after exact metadata/liveness/quarantine/current Rust6 proof. '
    f'All {kept} other direct entries remain exact; sources/evidence/executables/hardlinks/package/current caches and protected repositories preserved. '
    'Full absence/residue and retained-input reviews pass; resume Rust55.2.\n')
path = ROOT / 'docs/knowledge/project-data-obsolete-rust-objects.md'
value = path.read_text().replace('status: cleanup46.2 in progress; source and disposal boundaries established', 'status: dated cleanup46.2 completed and verified')
value = value.replace('Final dated disposal receipt is required before closeout.', 'Final dated disposal/retained-entry review passes; exact producers, metadata and executable inputs are retained.')
value += f'\n## Dated completion\n\nExactly {n} selected objects are absent; all {kept} other direct entries retain their captured identities. '
value += f'The selected metadata sums to {logical} logical and {allocated} allocated bytes. '
value += 'The current offline rule-call target passes six tests with old deps quarantined. '
value += 'Original deps is restored with no quarantine residue. Complete metadata, actual producers, guard epochs and the actual successful test executable are retained in the owning checkpoint.\n'
path.write_text(value)
path = ROOT / 'docs/knowledge/rgx-bootstrap-published-remedy.md'
value = path.read_text()
value += '\n## October30 object-cache disposal\n\nThe target-preservation statement above describes the September adoption. '
value += 'Owned cleanup46.2 later removes only verified obsolete single-link non-executable compiler .rcgu.o files from its old debug/deps directory. '
value += 'Historical executables, hardlinked outputs and every other entry remain; the adjacent retained RGX checkout is untouched. '
value += 'Current supported builds continue through rust/target. See [[project-data-obsolete-rust-objects]] for exact dated proof and limits.\n'
path.write_text(value)
path = ROOT / 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md'
value = path.read_text()
anchor = '# Repo Generated Artifact Cleanup Boundary\n'
assert value.count(anchor) == 1
value = value.replace(anchor, anchor + '\nOctober30 explicitly requested cleanup46.2 prunes only old single-link non-executable compiler objects from the saved pre-adoption target, preserving every other entry and the adjacent Git repository. Current caches/source/evidence remain available. [[project-data-obsolete-rust-objects]] owns the exact dated metadata, quarantine/current-use proof and complete retained/residue review. This does not authorize routine cache purges or claim physical volume reclamation.\n', 1)
path.write_text(value)
path = ROOT / 'docs/linkedspec-book/src/development/local-ci-and-regression.md'
value = path.read_text()
anchor = 'Existing project-owned data outside the repository filesystem is migration input, not a supported cache location.'
assert value.count(anchor) == 1
value = value.replace(anchor, 'An explicitly requested October30 cleanup removes obsolete compiler object files from the old pre-adoption Cargo target. It selects only old, regular, non-executable, single-link `.rcgu.o` entries after permitted liveness checks and a reversible quarantine. The current offline Rust check passes with that old directory unavailable. Exact identity and residue checks preserve historical executables, hardlinked outputs, all other entries, source/evidence, package stores and current caches. The adjacent retained dependency repository is untouched. The dated claim records file metadata rather than physical free-space causality; this is not a recurring purge policy.\n\n' + anchor, 1)
path.write_text(value)

writers = runpy.run_path(str(V / 'type-slice-docs.py'))
writers['update'](OWNER, subject, BASE, NEXT, action, proof, 'Requested obsolete-object cleanup verified; current Rust6 and retained/residue controls pass. Rust55.2 next.')
for name in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
    path = ROOT / name
    value = path.read_text()
    value = value.replace('## 2026-10-27 — ' + subject.replace(' - ', ' — ', 1), '## 2026-10-30 — ' + subject.replace(' - ', ' — ', 1), 1)
    path.write_text(value)
path = ROOT / 'MEMORY.md'
value = path.read_text()
value = re.sub(r'^- in_flight_uncommitted:.*$', '- in_flight_uncommitted: none.', value, flags=re.M)
path.write_text(value)

inputs = []
for path in sorted(PREFIX.iterdir()):
    if path.is_file():
        inputs.append(dict(path=path.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                           role='producer' if path.suffix == '.py' else 'input'))
claim = dict(version=1, owner=OWNER, claims=[dict(name='dated-obsolete-object-disposal',
    statement=f'Exactly {n} selected obsolete single-link non-executable object files are removed; all {kept} other direct entries preserve their observed identities. Selected metadata sums to {logical} logical/{allocated} allocated bytes. Current public offline rule-call6 passes with old deps unavailable.',
    scope='Named old pre-adoption debug/deps snapshot and finite disposal/preservation controls only. Per-file metadata, not physical volume reclamation or old-build byte reproduction. Hardlinks/executables/source/evidence/package/current caches and protected repositories are preserved. Same-user successful liveness at the boundary, no concurrent-adversary/other-user guarantee. No full suite, cold package bootstrap, dependency implementation audit or all-history claim-check audit.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/type-operation-inventory/project-data-cleanup46-2/review.py', granularity='Every saved direct-entry metadata row and selected predicate/count/size/allocation; every retained part/input; actual successful current test executable/source inputs; actual full post-disposal entry/absence review.', result='Readonly retained re-derivation matches the actual plan/disposal/full source review; six current offline tests pass and actual executable bytes are recoverable.'),
    falsify=dict(status='checked', hypothesis='A filename-only deletion or incomplete liveness/retention check could discard executables/shared artifacts, miss a live owner, admit paths outside scope or report a proposal as completed cleanup.', oracle='Actual live inventory-owner refusal versus later successful idle inspection; real quarantine/current Rust6; actual fixture quarantine/dispose/review with executable/hardlink/symlink/recent/other-suffix preservation, retained-size/count/false-removal denials, nested/symbolic/outside-root controls, and distinguishing nested claim-schema sentinel.', red_control='Actual live-owner inspection exits1. Initial prototype admits an owned existing sibling through ..; final guard rejects it. Three metadata/disposal mutations and symbolic/nested/path denials reject. Initial ad-hoc top-level schema lookup misses the bound sentinel; corrected lookup detects it before deletion. Original epochs and producers retained.'),
    durability=dict(status='checked', mode='live', inputs=inputs))])
(ROOT / 'docs/claims' / (OWNER + '.json')).write_text(json.dumps(claim, indent=2, sort_keys=True) + '\n')
print('Cleanup documentation and exact measured-claim record prepared; Rust55.2 is the next clean owner.')
