"""Publish the measured finite allowance and the intended canonical handoff."""
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
BASE = 'bece12874183477b6e601dd122cb1c39119b613e'
NEXT = LEAF[:-1] + '2'
fact = 'docs/knowledge/finite-engineering-notes-aggregate.md'
task_source = (ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md').read_text()
task_marker = '- ID: `' + LEAF + '`'
refusal = 'one-shot publisher requires an unpublished uniquely active leaf; use retained reviewers'
if task_source.count(task_marker) != 1:
    raise SystemExit(refusal)
task_start = task_source.index(task_marker)
task_end = task_source.index('\n- ID:', task_start + 1)
task_node = task_source[task_start:task_end]
if (re.findall(r'^  Status: `([^`]+)`$', task_node, re.MULTILINE) != ['active']
        or re.search(r'^  (?:Result|LinkedSpec-tool evidence):', task_node, re.MULTILINE)
        or (ROOT / fact).exists()
        or (ROOT / ('docs/claims/' + LEAF + '.json')).exists()
        or any(line.startswith('- `' + LEAF + '`')
               for line in (ROOT / 'LIVE_ACHIEVEMENT_STATUS.md').read_text().splitlines())):
    raise SystemExit(refusal)

plan = json.loads((ROOT / (PREFIX + 'plan.json')).read_bytes())
proof = json.loads((ROOT / (PREFIX + 'verification.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert proof['result'] == evidence['result'] == 'PASS'
assert len(proof['controls']['thresholds']) == 12 and len(proof['controls']['authority']) == 16
assert len(evidence['rows']) == 3 and all(r['observed'] == 'RED' for r in evidence['rows'])
assert proof['preserved_files'] == 220
statement = ('Exactly three registry scalars admit engineering_notes aggregate lines29000→29512 '
             'and the sole new indexed ADR0130 decision: files130→131 and aggregate lines13077→13109. '
             'Independent Git reconstruction preserves220 prior history/decision files and all prior '
             'current-root records; engineering notes use45 files/29004 lines/3238344 bytes, decisions '
             'use131 files/13109 lines/966986 bytes. Twelve actual production aggregate observations, '
             'sixteen actual accepted/indexed/exact-authority RED controls and three actual reviewer '
             'evidence REDs pass. Root, byte, per-file, manifest, membership and every other registry '
             'control stay exact. No new archive member is admitted.')
(ROOT / fact).write_text('''---
id: finite-engineering-notes-aggregate
title: Engineering notes have one finite hot-shard aggregate allowance
answers:
  - "why did engineering notes aggregate lines increase to 29512"
  - "which decision admits the October 9 engineering notes aggregate allowance"
  - "does ADR0130 admit another engineering notes archive member"
  - "what preserves history during the engineering notes aggregate admission"
date: 2026-10-09
status: finite focused proof verified; exact staged canonical receipt required before landing
tags: [documentation, history, capacity, verification]
evidence: "STATEMENT"
reverify: "At the frozen admission boundary, run bash tools/run_python_project_data.sh PREFIXcapacity.py review and PREFIXevidence.py. Preserve the original claim inputs at later root/registry publication; canonical receipt governs landing."
---

# A finite aggregate allowance preserves existing storage rules

ADR0130 admits exactly512 aggregate engineering-note lines, one existing bounded
hot-shard line allowance, under the current full-PNT engineering instruction and
the ADR0128/0129 maintenance precedent. It makes no new explicit director-grant
claim and does not reuse an earlier finite grant. The decision store accounts for
only this new file and its exact32 additional aggregate lines, including the
index row. Stable responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3.

The actual resulting collection contains45 files/29,004 lines/3,238,344 bytes.
Its hard aggregate-line limit is29,512. The mutable root remains512 lines/65,536
bytes; every engineering-note byte, per-file, manifest and file-count control is
unchanged. No archive reserve is granted. A later rollover or exhausted allowance
requires another separately owned, indexed finite decision.

The retained producer independently reconstructs all220 prior history/decision
file identities from clean BASE and preserves both current roots by exact
record insertion. The unchanged production functions execute twelve aggregate
observations and sixteen accepted/indexed/exact-marker authority denials. Three
actual reviewer subprocesses reject a missing immutable member, a forged original
hash and a forged resulting registry hash. Only mutable plan evidence is changed
and restored during those controls; successful outputs remain byte-identical.

The first producer draft misindexed the registry header and is retained beside
its explicitly limited failure transcript. Verified literal current-root additions
were restored before corrected one-shot publication; no immutable history, registry
or decision was changed by that failed draft. Existing book authority teaching
already covers this data-only admission. Parser/runtime, tests, dependencies,
checker implementations and other repositories remain unchanged. Exact staged
canonical CI, its receipt, normal hooks and a clean per-leaf commit govern landing.
'''.replace('STATEMENT', statement).replace('PREFIX', PREFIX).replace('BASE', BASE))

p = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
s = p.read_text()
start = s.index('- ID: `' + LEAF + '`')
end = s.index('\n- ID:', start + 1)
part = s[start:end].replace('  Status: `active`', '  Status: `done`', 1)
part = part.replace('  Verification: `pending`',
                    '  Verification: ' + statement + ' Exact staged canonical CI and receipt are required before landing.', 1)
part = part.replace('  Commit: `pending`', '  Commit: `' + LEAF + ' - admit finite engineering notes aggregate` (Git records identity).', 1)
part += ('  Result: Finite three-scalar data-only admission, accepted indexed ADR0130 and original '
         'history/current-record preservation independently verified. Initial header/retainer '
         'draft failures are retained with channel limitations. Existing book authority teaching '
         'already covers these unchanged rules. No parser/runtime/test/checker/dependency change.\n'
         '  LinkedSpec-tool evidence: Actual unchanged routing threshold and accepted/indexed authority '
         'functions, exact Git history recovery and actual reviewer subprocess REDs; complete '
         'control channels/mutant plans retained under this leaf prefix.\n')
s = s[:start] + part + s[end:]
s = s.replace('| `' + LEAF + '` | `active` | Finite canonical engineering-notes capacity admission before event joining. |',
              '| `' + LEAF + '` | `done` | Three scalars;220 preserved files; production12/16 and evidence3; canonical receipt governs landing. |')
p.write_text(s)
(ROOT / 'MEMORY.md').write_text('''# MEMORY

- activation_commit: `BASE` — clean finite capacity base.
- latest_completed_leaf: `LEAF - admit finite engineering notes aggregate`.
- active_work_unit: `LEAF` (done).
- next_action: Activate NEXT and join actual parser/MethodExpr captures to selected original-event copy/consume authority.
- in_flight_uncommitted: none after this canonical leaf commit.
- blockers: none; original-event/factory integration and full Phase0/mapped/canonical replacement admission remain open.
- standing_limit: Wrapper liveness repair SESSION-STARTUP-READING.7 remains open; artifact recovery/purge prohibited.
- task_owner: `docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md`.
- authority: docs/decisions/0130-finite-engineering-notes-aggregate.md; docs/knowledge/finite-engineering-notes-aggregate.md.
'''.replace('BASE', BASE).replace('LEAF', LEAF).replace('NEXT', NEXT))
p = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'
s = p.read_text()
for heading, content in [('Current Activity', 'Full PNT: finite engineering-notes aggregate admission verified; original-event joining next.'),
                         ('Latest Completed Slice', '`' + LEAF + '` — ' + statement + ' Exact canonical receipt governs landing.'),
                         ('Next Action', 'Activate `' + NEXT + '` for original-event input joining and copy/consume authority, then input acceptance .3. Factory/composition, full private Phase0 .2.5, mapping .1.1.2 and independent canonical .0.3.2 remain open.')]:
    marker = '## ' + heading + '\n\n'
    start = s.index(marker) + len(marker)
    end = s.index('\n## ', start)
    s = s[:start] + content + '\n' + s[end:]
start = s.index('## Recent Completions\n\n') + len('## Recent Completions\n\n')
end = s.index('\n## History', start)
old = [line for line in s[start:end].splitlines() if line.startswith('- ')]
rows = ['- `' + LEAF + '` — finite aggregate512, sole exact decision;220 preserved files; production12/16/evidence3.'] + old[:15]
s = s[:start] + '\n'.join(rows) + '\n' + s[end:]
p.write_text(s)
p = ROOT / 'docs/TASK_TREE.md'
s = p.read_text().replace('finite canonical engineering-notes capacity .2.1.2.6 is next before original-event joining .2.1.2.2;',
                        'finite engineering-notes aggregate .2.1.2.6 verifies three scalars/220 preserved files with canonical admission required; original-event joining .2.1.2.2 is next;', 1)
p.write_text(s)

sources = set(plan['preserved'])
sources.update((
    'DEVELOPMENT_NOTES.md', 'CHANGES.md', 'doctrine/readme_stability/routes.jsonl',
    'docs/decisions/INDEX.md', 'docs/decisions/0130-finite-engineering-notes-aggregate.md', fact,
    'README_POLICY.md', 'scripts/check_readme_routing_pressure.pl', 'scripts/check_readme_stability.sh',
    'tools/run_python_project_data.sh', 'tools/project_data_env.sh', 'tools/project_data_run.sh'))
sources.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*'))
record = {'version': 1, 'owner': LEAF, 'claims': [{
    'name': 'finite-three-scalar-engineering-notes-aggregate-admission', 'statement': statement,
    'scope': 'Exactly the clean ' + BASE + ' routing and preserved history/decision boundary plus this finite admission. Counts use LF bytes as the actual checker does. Production threshold/authority functions run with actual file census and in-memory exact decision controls; complete resulting-tree and staged canonical CI remain mandatory and are not replaced by these controls. No new archive reserve, public parser behavior, original-event integration, full Phase0/private producer admission or broader historical audit closeout. Read-only Git/Perl/Python core tools and same-volume managed scratch are reused. Initial producer/retainer failure transcripts explicitly disclose their original channel limitations.',
    'rederive': {'status': 'checked', 'command': 'At the original clean activation, bash tools/run_python_project_data.sh ' + PREFIX + 'capacity.py apply; at the frozen admission boundary, bash tools/run_python_project_data.sh ' + PREFIX + 'capacity.py review and ' + PREFIX + 'evidence.py.',
                 'granularity': 'Every prior history/decision file and current root record; exact registry scalar/collection/file/line/byte population; each actual production threshold/accepted authority observation and reason-sensitive reviewer RED.', 'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'A matching aggregate alone could hide rewritten history, extra control changes, unaccepted or unindexed capacity authority, a threshold waiver or forged proof inputs.',
                'oracle': 'Exact independent clean-Git file and record recovery, independent LF census versus actual production functions, exact three-scalar reconstruction, accepted/indexed ADR0130 and reason-sensitive actual reviewer subprocesses.',
                'red_control': 'The actual new note rejects under the old aggregate limit; new-limit+1 rejects under the new ceiling. Sixteen actual authority controls reject missing/new/index/status/old/new markers and unreviewed increases. Three actual reviewer runs reject missing original membership, forged original hashes and forged resulting registry hashes; all successful evidence and original mutable plan bytes restore exactly.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': [
        {'path': path, 'sha256': hashlib.sha256((ROOT / path).read_bytes()).hexdigest(),
         'role': 'producer' if path.endswith(('.py', '.pl', '.sh')) else 'input'} for path in sorted(sources)]}
}]}
(ROOT / ('docs/claims/' + LEAF + '.json')).write_text(json.dumps(record, indent=2) + '\n')
(ROOT / 'git_message_brief.txt').write_text(LEAF + ' - admit finite engineering notes aggregate\n\n'
    'Admit one bounded hot-shard aggregate allowance and only the exact new indexed decision overhead.\n'
    'Preserve all existing history and other controls; retain independent reconstruction, actual production authority/threshold controls and reviewer evidence REDs.\n'
    'Focused proof is complete; exact staged canonical CI and normal hooks govern this infrastructure commit.\n')
print('Finite capacity claim published:', len(sources), 'exact producer/artifact inputs; canonical staging next.')
