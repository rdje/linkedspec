"""Publish only after focused runtime, inverse and readonly evidence passes."""
import gzip
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
LEAF = 'TYPE-REFERENCE-BOOK.1.2.23.3.78.2'
NEXT = 'TYPE-REFERENCE-BOOK.1.2.23.3.78.3'
assert (BASE / 'readonly-review/exit.txt').read_text() == '0\n'
assert gzip.decompress((BASE / 'readonly-review/stderr.log.gz').read_bytes()) == b''
assert json.loads((BASE / 'baseline.json').read_bytes())['healthy'] == 174
summary = ('Independent Rust Array-transform78.2 acquires unchanged37 plus148 own policy controls and10 optional-result targets. '
           'The unchanged195 normal has21RED/174 healthy before repair and195PASS afterward on native/restored/generated-plan/fresh routes. '
           'Private exact old/current images reproduce21RED/195PASS; direct Array/Hash/copy normals pass290. '
           'All174 healthy projections,152 profiles and195 compiled/module pairs stay exact; scoped format and first readonly0/empty stderr/eight corruption controls pass.')
limits = ('Original producer source/arity/error policies remain separate from result guards. Needed errors, compatible bridges, nested kinds, snapshots and valid empty with stay intact. '
          'First ordinary before has a retained untracked optional include-input gap; separate qualified-before and all later acquisitions explicitly capture that actual fixture before build. '
          'Original writer failed before writes and the non-fail-fast shell started an old-source after epoch; both are retained without GREEN credit. A separate anchored writer passes construction rehearsal and produces repaired-after. '
          'No retroactive original-normal custody credit, peer policy import, variadic/deferred/function-receiver promotion or full domain/context/native-custody/admission claim. Rebuild Rust runtime/applications.')


def replace(path, old, new):
    p = Path(path)
    s = p.read_text()
    assert s.count(old) == 1, (path, old[:100], s.count(old))
    p.write_text(s.replace(old, new))


p = Path('docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md')
s = p.read_text()
start = s.index('- ID: `' + LEAF + '`')
end = s.find('\n- ID:', start + 1)
if end < 0:
    end = len(s)
node = s[start:end].replace('Status: `active`', 'Status: `completed` / bounded Rust result guards focused-checked', 1)
node = node.replace('Verification tier: focused', 'Verification tier: `focused`')
node += '\n  Independent outcome: ' + summary + '\n  Diagnosis: Public serialized compiled actions retain canonical Array producers and typed Hash-consumer operands. engine.rs direct FluentChain and eval_fluent_with_trailing_block source-role lists omit Array results before persistent kind guards. Free take.set_key returns original Array with KV; later copy/with executes KVW. Add only eight canonical source/prefix roles before Hash-helper first-source permission; preserve initial producer policy only without prior result ownership.\n'
node += '  Source/arity preservation: Initial take/drop/slice/sorted/reversed Number/null/Hash controls yield empty Arrays; concat retains these named kinds as scalar elements. Initial with bodies run W/count0 for empty fallback. Optional four counts default1 and slice omitted count retains the tail. Missing/excess-arity profiles retain own outputs/effects; prior count/key_count/length/Hash/copy guards stay, while Array-valued views validly enter take. All four needed source/count errors already propagate. No Perl source defaults inferred.\n'
node += '  Input-capture defect and resolution: Original before root archive omits new untracked include_str optional fixture because git ls-files does not enumerate it. Actual195 frames/21 failures and intake source bytes survive, but no complete original-normal first-use custody credit. Preserve capture.py/before unchanged. Separate capture_qualified.py includes explicit fixture path/mode before qualified-before and every later build; identical normal/targets/profiles and old owner reproduce21RED. The finite repair is owned by this leaf; full native/cache/transitive/toolchain custody remains4.2/SESSION5.\n'
node += '  Evidence: docs/checkpoints/array-transform-result-guard-rust-2026-11-07/REVIEW.md and readonly review.py. ' + limits + '\n'
node += '  Next: Land this focused leaf through normal hooks/post-pointer/brief0/clean Git, then independently assess Dart78.3 before any peer production; full23.4/final push after feature coverage.\n'
node += '  Commit: ' + LEAF + ' — guard Rust ordinary Array transform results.\n\n  Acceptance Checklist\n'
for label, detail in (
    ('REPRODUCE / ISSUE', 'Public parse_spec_with_user_functions/validate/compile, Engine::execute_value/restored/generated-plan/emit_rust_source_v2 fresh195 and qualified unchanged normal174PASS/21FAIL establish own RED before production.'),
    ('ROOT CAUSE (WHY + WHERE)', 'Actual compiled action and engine.rs direct/trailing-with source-role lists show missing canonical Array result roles before existing persistent guards; original-normal archive separately omits its new untracked include fixture.'),
    ('FIX', 'Add bounded canonical source/prefix roles before Hash-helper source permission, preserving original first producer and earlier guards; separate prospective capture explicitly includes optional fixture before build.'),
    ('ADDRESSED (verified)', 'Unchanged195/four routes PASS, exact private old21RED/current195PASS, direct290/scoped format and first readonly/eight effective controls PASS.'),
    ('NO REGRESSION', 'All174 healthy projections/152 own profiles/195 serialized-module pairs exact; source/optional/excluded arity/needed errors/snapshots/nested kinds/earlier guards and direct Hash89/copy6 remain.'),
    ('LOCKSTEP', 'Public book/catalog, Knowledge, task/current frontier, roadmap and change/engineering/live/MEMORY updated; full admission and independent Dart78.3 remain separate.'),
):
    node += f'  - [x] **{label}** — {detail}\n'
s = s[:start] + node + s[end:]
s = s.replace('Status: `active` / bounded Perl complete; independent peers remain',
              'Status: `active` / bounded Perl and Rust complete; independent peers remain', 1)
s = s.replace('Frontier: Bounded Perl source78.0/result78.1.1 are repaired/focused-checked. Independent Rust78.2 is next under unchanged37 and own source/arity/error acquisition; full23.4 remains separate.',
              'Frontier: Bounded Perl source78.0/result78.1.1 and independent Rust78.2 are repaired/focused-checked. Independent Dart78.3 is next under unchanged37 and own source/arity/error acquisition; full23.4 remains separate.', 1)
p.write_text(s)

p = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
s = p.read_text()
s = re.sub(r'^\| 1 \| .*$', '| 1 | `' + LEAF + '` | `completed` | Rust195PASS/direct290/private21RED-restored195PASS/readonly/eight controls; policies and source permission preserved. |', s, count=1, flags=re.M)
s = re.sub(r'^\| 2 \| .*$', '| 2 | `' + NEXT + '` | `pending` | Independently assess Dart unchanged37/own source/arity/errors before edits; full23.4 remains separate. |', s, count=1, flags=re.M)
s = s.replace('Independent Rust78.2 is next', 'Independent Dart78.3 is next after focused-checked Rust78.2')
p.write_text(s)
current = ('Current Array frontier: bounded Perl78.1.1 and independent Rust78.2 are focused-checked. '
           'Rust195PASS/direct290/private21RED-restored195PASS/readonly/eight controls preserve own policies. '
           'Independent Dart78.3 next; peers/full23.4 remain separate.')
for name in ('docs/TASK_TREE.md', 'ROADMAP_V2.md'):
    p = Path(name)
    s = re.sub(r'^Current Array frontier:.*$', current, p.read_text(), count=1, flags=re.M)
    if name == 'docs/TASK_TREE.md':
        s = re.sub(r'^Latest PNT slice:.*$', 'Latest PNT slice: ' + LEAF + ' — Rust195PASS/direct290/private21RED-restored195PASS/readonly/eight controls; next independent Dart78.3.', s, count=1, flags=re.M)
        s = re.sub(r'^\| `TYPE-REFERENCE-BOOK`.*$', '| `TYPE-REFERENCE-BOOK` | `active` / fluent methods .1.2.23 | `.spec documentation / complete type and fluent reference` | Bounded Perl78.1.1 and Rust78.2 are focused-checked with own source policies preserved. Independent Dart78.3 next under unchanged37/own source/arity/error acquisition. Full domain/context/native custody/registration/declared Lua5.4/full23.4 remain separate. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |', s, count=1, flags=re.M)
    p.write_text(s)
p = Path('docs/checkpoints/type-operation-inventory/helpers.md')
s = re.sub(r'^Current finite frontier:.*$', 'Current finite frontier: ' + summary + ' Independent Dart78.3 next; full source/context/native custody/registration/declared Lua5.4/full23.4 remain separate. Evidence: docs/checkpoints/array-transform-result-guard-rust-2026-11-07/REVIEW.md.', p.read_text(), count=1, flags=re.M)
p.write_text(s)

for name in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
    p = Path(name)
    s = p.read_text()
    offset = s.index('\n## ') + 1
    record = '## 2026-11-07 — ' + LEAF + ' — Guard Rust ordinary Array transform results\n\n' + summary + '\n\n' + limits + ' Evidence: docs/checkpoints/array-transform-result-guard-rust-2026-11-07/REVIEW.md.\n\n'
    p.write_text(s[:offset] + record + s[offset:])
p = Path('LIVE_ACHIEVEMENT_STATUS.md')
s = p.read_text()
history = s[s.index('## History'):]
old = s[s.index('## Recent Completions'):s.index('## History')]
rows = [line for line in old.splitlines() if line.startswith('- ')][:15]
p.write_text('# LIVE ACHIEVEMENT STATUS\n\n## Current Activity\n\nPNT proceeds to independent Dart Array-transform78.3 after bounded Rust78.2; peers and full23.4 remain separately owned.\n\n## Latest Completed Slice\n\n' + LEAF + '. ' + summary + '\n\n## Next Action\n\nFrom clean Rust78.2 landing activate ' + NEXT + '. Acquire own unchanged37 on native/restored/generated-plan/full emitted-fresh routes and own source/optional/excluded-arity/needed-error/prior-owner policies before production. Preserve first producer permission separately from result guards; no imported Rust or Perl defaults. Smallest focused/inverse/recovery/book/Knowledge/commit, full verification after feature coverage.\n\n## Recent Completions\n\n- ' + LEAF + ' —195PASS/direct290/private21RED-restored195PASS/eight controls;152 profiles/174 healthy exact; capture qualification explicit.\n' + '\n'.join(rows) + '\n\n' + history)
Path('MEMORY.md').write_text('''# MEMORY

- activation_commit: `b0376420ba6258420b146981b848d4646fb3ff55` — clean Rust78.2 activation; derive current HEAD from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.23.3.78.2` — guard Rust ordinary Array transform results.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.23.3.78.2` (completed through landing); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md.
- next_action: From clean Rust78.2 landing independently activate TYPE-REFERENCE-BOOK.1.2.23.3.78.3. Acquire own unchanged37 on native/restored/generated-plan/full emitted-fresh routes plus own initial Number/null/Hash, optional/excluded-arity/needed-error and prior-owner fences before production. Retain actual first SDK/grammar/instrument/artifact inputs/full channels, including new untracked includes. Preserve first producer policy separately from result guards; smallest new/direct/inverse/recovery/book/Knowledge/live/commit. No peer fallback import.
- in_flight_uncommitted: none.
- blockers: none requiring director input. Bounded Perl78.0/78.1.1 and Rust78.2 focused-checked; independent Dart/Julia/Lua remain. Generic task boundary/query4.17 is P2 after feature coverage, earlier on capacity block. Full native/cache/transitive custody4.2/SESSION5, RAM fallback/card4.14, registration4.1 and declared Lua5.4 remain separately owned.
- evidence: docs/checkpoints/array-transform-result-guard-rust-2026-11-07/REVIEW.md and readonly review.py. Unchanged37/own148/optional10 gives21RED/174 healthy to195PASS; direct290, exact private old21RED/current195PASS, first readonly0/empty stderr/eight controls. All174 healthy/152 profiles/195 artifact pairs exact. Original before normal omitted actual new untracked optional include path; semantic195 frames survive, no complete original-normal custody credit. Separate qualified-before and later actual captures include that input before build. No full-domain/context/native-custody/admission credit.
- publication: Exact canonical4683555e is the last published checkpoint. Later local focused commits require fresh final proof; full23.4/final clean push follows feature coverage.
- verification_policy: Smallest focused checks per slice, mandatory hooks. Same-volume data; other repositories/submodules read-only. Host24GiB; one intensive own job at a time. Cleanup2026-11-07T05:37:20.574917+00:00; recheck24h at next clean boundary. Director RAM policy overrides stale card until4.14.
''')
print('live/task/roadmap records describe completed bounded Rust78.2 and independent next Dart78.3')
