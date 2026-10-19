"""One-shot final handoff from measured records; root continuity is deliberately unbound."""
import base64
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.6'
BASE = '64b66167c2277533c2393899e3754e14a74f0b31'
TREE = 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md'
sha = lambda value: hashlib.sha256(value).hexdigest()
target = ROOT / (PREFIX + 'continuity.json')
assert not target.exists()
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
claim_path = 'docs/claims/' + LEAF + '.json'
claim_raw = (ROOT / claim_path).read_bytes()
claim = json.loads(claim_raw)
count = len(claim['claims'][0]['durability']['inputs'])
assert len(claim_raw) <= 131072
assert json.loads((ROOT / (PREFIX + 'evidence-final.json')).read_bytes())['result'] == 'PASS'
review = json.loads((ROOT / (PREFIX + 'current-review.json')).read_bytes())
paths = [TREE, 'MEMORY.md', 'docs/TASK_TREE.md', 'ROADMAP.md', 'ROADMAP_V2.md',
         'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md']
assert not (set(paths) & set(review['inputs']))
original = {path: (ROOT / path).read_bytes() for path in paths}
values = {path: value.decode() for path, value in original.items()}
summary = (
    'Pipeline .6 opens fresh producer/input scopes inside SourceOrigins before factories and isolates four '
    'actual dependencies plus canonical apply. Native96 and distinct9-row callable/load-context epochs '
    'preserve observed contexts, aliases, values, references, order, errors and release. Actual public '
    'native return_general identity/origin/registries match. Complete426-input supplied proof passes2065 '
    'assertions,13 exact syntax-valid semantic inverses with the same2065 plan and91 suites/32235 assertions. '
    'Same-token opaque donation and nested success/fatal restoration are independently tested. All original '
    'native/RED/repair/early-GREEN epochs remain exact; expected-only diagnostic filename projection is '
    'owned-source guarded and its reader closes before calls. Eight artifact denials restore exact bytes/modes; '
    'first two actors stay original and the finisher executes only six. Whole603/full115985 and actual '
    'baseline stay historical at64b66167c. Knowledge1487 captured Markdown/1349 facts/10448 keys/fifteen '
    'routes/two bodies/8384111 bytes and book89/four controls pass; thirteen bodies and all old rendered '
    f'tables stay exact. Current readonly publication binds{count} inputs in{len(claim_raw)} bytes under '
    'unchanged131072. No selector, public DSL/map/reference/replacement/family-order, dependency or budget '
    'change. Metadata .12 precedes TYPE-REFERENCE-BOOK; output construction/composition, mapping, quoted-first '
    'repair and complete private/parent/canonical admissions remain owned. Startup.7 restrictions stay in force.'
)
live = values['LIVE_ACHIEVEMENT_STATUS.md']
old_summary = live.split('## Latest Completed Slice\n\n', 1)[1].split('\n\n## Next Action', 1)[0]
assert old_summary.startswith('Fixture admission .7 adds')
for path in ('docs/TASK_TREE.md', 'ROADMAP.md', 'ROADMAP_V2.md'):
    assert old_summary in values[path]
    values[path] = values[path].replace(old_summary, summary)
values['docs/TASK_TREE.md'] = values['docs/TASK_TREE.md'].replace(
    '| `PERL-PRIVATE-FACTORY-CAPTURE` | `active` / pipeline .6 next |',
    '| `PERL-PRIVATE-FACTORY-CAPTURE` | `active` / metadata .12 next |')
assert '| `REPO-HYGIENE` | `completed: due retained artifact review`' in values['docs/TASK_TREE.md']
tree = values[TREE]
tree = tree.replace('- Status: `active` / pipeline .6 preservation and characterization',
                    '- Status: `active` / metadata .3.2.1.12 next', 1)
start = tree.index('- ID: `' + LEAF + '`')
end = tree.index('\n- ID:', start + 1)
node = tree[start:end].replace('Status: `active` / preservation and native characterization',
                              'Status: `done` / focused signoff', 1)
node += ('\n  Verified result: ' + summary + '\n  Verification: Focused runtime/native/source/consumer '
         'and independent custody/documentation/eight-artifact proofs PASS; public aggregate surface guard '
         'PASS. Both histories, explicit memory and whitespace plus all10 normal doctrine hooks govern '
         'landing. No canonical selector change or broader admission is inferred.\n  Commit: `' + LEAF +
         ' - isolate pipeline callbacks per invocation`; Git owns accepted identity.\n  Handoff: From '
         f'clean committed state, preserve complete{count}/full{len(claim_raw)} and actual readonly '
         'baseline before metadata .3.2.1.12 bound writes, then TYPE-REFERENCE-BOOK.\n')
tree = tree[:start] + node + tree[end:]
tree = tree.replace('| 1 | `PERL-PRIVATE-FACTORY-CAPTURE.6` | `active` | Preserve admitted evidence, characterize native calls, then activate bounded pipeline scopes. |\n', '')
tree = tree.replace('| 2 | `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12` |', '| 1 | `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12` |')
handoff = tree.index('## Handoff\n\n')
after = tree.index('\n\nAfter `.6`', handoff)
tree = tree[:handoff] + '## Handoff\n\n' + summary + (
    f' Preserve current{count}/full{len(claim_raw)} and actual readonly baseline before later bound writes. '
    'All capture/preparation/repair writers remain retired; default publish/review endpoints are readonly.') + tree[after:]
tree += '''
## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.6

- [x] **REPRODUCE / CAUSE** — Original native96 and supplemental9 rows precede production/assertions. Calibrated fixed-plan1988/1128 RED locates absent invocation producer/input scopes and five unseparated callback seams in RewritePipeline. Actual before-import direct/prove observations distinguish diagnostic filenames; original failed hypotheses/readers remain retained.
- [x] **FIX** — Fresh scopes are inside SourceOrigins before factories. Four selected dependencies and actual canonical apply have separate scalar frames. One-fetch call-local apply selection preserves symbolic/blessed/overloaded dispatch and original native diagnostic line489. Public references/maps, arguments, family order and replacement algorithm stay unchanged.
- [x] **ADDRESSED (verified)** — Same2065 assertions pass and distinguish13 exact syntax-valid semantic inverses. Actual same-token opaque publication cannot donate; nested successful/fatal calls restore actual parent call/registries/source and builder authority. Actual public native factory/callback/origin/tokens match; complete426 supplied inputs and all91/32235 consumers pass with byte/mode/parent custody.
- [x] **CUSTODY / FALSIFY** — Whole603/full115985/baseline stay historical at64b66167c. Every original native/RED/repair and direct-GREEN boundary stays distinct; disclosed merged/post-run limits remain explicit. Eight coherent artifact interventions reject with named semantic/source reasons and exact restored PASS. Original first2 actors are preserved; remaining6 use a distinct finisher and actual retained restoration baseline.
- [x] **LOCKSTEP / LIMITS** — Full captured Knowledge1487/1349/10448, fifteen routes/two bodies/8384111 and book89/four controls pass; thirteen bodies and all older rendered tables stay exact. Existing canonical suite selection already runs the expanded framework fixture. Current root/task/roadmap/live/history/pointer handoff agrees; normal focused doctrines/history/memory/whitespace govern landing. Output/mapping/quoted-first/private/parent admissions remain separate.
'''
values[TREE] = tree
for path, title, lead in [
    ('CHANGES.md', 'Invocation scopes and actual pipeline callbacks',
     'Activate private invocation registries before contract construction, then isolate each selected dependency and canonical apply without changing public callback references or replacement behavior.'),
    ('DEVELOPMENT_NOTES.md', 'Scope identity and native diagnostic context',
     'Treat source invocation, producer registry, input grants and callback captures as separate actual identities. A same-token opaque child can publish equal text; a separate boundary prevents donation. Native diagnostics also depend on include and reader context: retain raw observations, project only expected owned filenames, and close oracle readers before probes.'),
]:
    heading = '## 2026-10-19 — ' + LEAF + ' — ' + title + '\n\n'
    assert heading not in values[path]
    position = values[path].index('\n## ')
    entry = '\n' + heading + lead + '\n\n' + summary + (
        '\n\nEvidence and readonly entrypoint: docs/checkpoints/' + LEAF +
        '/publish.py; claim: ' + claim_path + '. Focused tier; actual native/capture/generator '
        'writers stay retired. Ordinary focused checks and all normal hooks govern landing.\n')
    values[path] = values[path][:position] + entry + values[path][position:]
live = re.sub(r'(?s)(## Current Activity\n\n).*?(\n\n## Latest Completed Slice)',
              r'\1Private factory/dependency pipeline integration .6 is focused-signoff complete; metadata .12 is next before TYPE-REFERENCE-BOOK.\2', live, count=1)
live = re.sub(r'(?s)(## Latest Completed Slice\n\n).*?(\n\n## Next Action)', lambda match: match[1] + summary + match[2], live, count=1)
next_action = (f'From clean Git, activate PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12; preserve the complete '
               f'{count}-input/{len(claim_raw)}-byte publication and actual readonly baseline before bound '
               'metadata/Knowledge/book changes. Continue TYPE-REFERENCE-BOOK afterward. No push or dirty pivot.')
live = re.sub(r'(?s)(## Next Action\n\n).*?(\n\n## Recent Completions)', lambda match: match[1] + next_action + match[2], live, count=1)
begin = live.index('## Recent Completions\n\n') + len('## Recent Completions\n\n')
end = live.index('\n## History', begin)
recent = [line for line in live[begin:end].splitlines() if line.startswith('- `')]
recent.insert(0, f'- `{LEAF}` — invocation scopes/five actual frames;2065/13 semantic inverses;426 inputs/91 suites/32235; native96/9/public1; Knowledge8384111/book89/4; artifact8/original2+remaining6; readonly{count}/{len(claim_raw)}; metadata .12 next.')
live = live[:begin] + '\n'.join(recent[:16]) + '\n' + live[end:]
values['LIVE_ACHIEVEMENT_STATUS.md'] = live
values['MEMORY.md'] = f'''# MEMORY

- activation_commit: `{BASE}` — clean .6 activation; Git owns current identity.
- latest_completed_leaf: `{LEAF}` — subject `{LEAF} - isolate pipeline callbacks per invocation`.
- active_work_unit: `{LEAF}` (done; focused pipeline integration).
- task_owner: `{TREE}`; current frontier .3.2.1.12, then TYPE-REFERENCE-BOOK.
- next_action: From clean Git, activate .3.2.1.12; preserve complete{count}-input/{len(claim_raw)}-byte publication and actual readonly baseline before bound metadata/card/book writes.
- in_flight_uncommitted: none; intended clean post-landing state. No required background result remains after landing.
- blockers: none requiring user input. Output construction/composition, mapping, quoted-first repair and complete private/parent/canonical admissions remain separately owned.
- current_evidence: Readonly {PREFIX}publish.py gates complete original/current custody, exact runtime sources/coherent TAP, full captured Knowledge/current overlays and book semantics plus eight artifact denials. All capture/preparation/repair/finisher writers remain retired. Whole603/full115985 and actual baseline stay historical at64b66167c; older550/565 and175 compiler/maintenance lineages remain exact.
- verified_scope:2065 positive/13 exact syntax-valid semantic inverses with the same complete plan;426 supplied inputs/all91 suites/32235 assertions; native96 plus distinct9-row epochs and public native1/169; same-token opaque isolation and nested parent restoration/release. Apply retains one lookup, native callables/line489 and ordinary maps/references/aliases/errors/order. Existing replacement algorithm and selector stay unchanged.
- observation_custody: All original missing-plan, variable-plan, include-context, reader-context, schema and quoted-reason failures retain whole sources/inputs/channels and distinct corrections. Expected-only diagnostic filename projection is owned-source guarded; actual errors stay exact. Early direct GREENs disclose merged streams/post-run custody; final supplied proof has pre-run bytes/separate channels. First2 artifact actors stay original; finisher adds only6. Unserialized original initial baseline is disclosed; actual second restoration supplies the healthy baseline.
- documentation: Captured1487 Markdown/1349 facts/10448 keys/15 current routes/2 bodies/8384111 bytes and book89/four controls PASS. Thirteen bodies and all original rendered tables stay exact. Current source/evidence publication{count}/full{len(claim_raw)} remains under unchanged131072; normal focused hooks/history/memory/whitespace/public-surface guard govern landing.
- standing_limit: SESSION-STARTUP-READING.7 owns wrapper/kernel gaps; recovery/purge prohibited. Latest retained review2026-10-19T00:47:29.953626UTC removed0. RUST-DEPENDENCY-WARNING-ZERO.1/.2 retain fuller public census/upstream ownership; old/current warning counts are dated output only. Other repositories/submodules remain read-only black boxes; no dependency internals, separate PGEN procedure, cargo fix, source/pin change or suppression.
- sequence: Metadata .12, then TYPE-REFERENCE-BOOK. Full PNT continues; no push yet.
'''
record = dict(result='intended clean focused handoff', producer_sha256=sha(Path(__file__).read_bytes()),
              original={path: dict(bytes_base64=base64.b64encode(value).decode(), sha256=sha(value))
                        for path, value in original.items()},
              current={path: sha(value.encode()) for path, value in values.items()},
              publication_inputs=count, publication_bytes=len(claim_raw),
              scope='Only bounded current continuity projections and owning task change; historical '
                    'records remain intact. This unbound report follows claim capture and is not a '
                    'runtime/claim producer input. Git owns current accepted identity.')
with target.open('x') as output: output.write(json.dumps(record, indent=1) + '\n')
for path, value in values.items(): (ROOT / path).write_text(value)
print('Focused continuity finalized:', count, 'publication inputs;', len(claim_raw), 'bytes;metadata.12 next')
