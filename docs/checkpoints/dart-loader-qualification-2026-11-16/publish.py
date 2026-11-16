"""Publish the bounded static loader result, leaving the larger inventory open."""
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.0'
NEXT = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1'
result = json.loads((BASE / 'review-stdout.json').read_bytes())
assert result['result'] == 'PASS' and (BASE / 'review-stderr.txt').read_bytes() == b''
assert len(result['controls']) == 8 and all(row['result'] == 'RED' for row in result['controls'].values())
summary = ('Six named Dart consumers have ten fixture-input edges, six explicit/default grammar edges, '
           'one support import and one optional output readback; the older five-consumer ledger agrees '
           'and eight distinguishing controls reject. All26 retained current inputs match bytes/modes. '
           'This is static source interpretation, with no SDK execution, observed default resolution or canonical admission.')
next_action = ('Complete remaining role/loader/discovery qualification under ' + NEXT +
               ', then freeze registration input for4.1.2; all independent before-push owners remain.')
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n')
end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node += '\n  Outcome: ' + summary + '\n  Evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review.py reconstructs all named read expressions and compares the older input ledger. Current identity is pre-landing only; cache/search shadowing, actual per-read/native/source-origin closure remain4.2/SESSION5.\n  Next: ' + next_action + '\n'
path.write_text(text[:start] + node + text[end:])
for name in ['docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/TASK_TREE.md', 'ROADMAP.md', 'ROADMAP_V2.md']:
    path = Path(name)
    text = path.read_text()
    if name.endswith('TYPE-REFERENCE-BOOK.md'):
        text = text.replace('| 1 | `TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1` | `pending` | Qualify proposed consumer/support roles and actual loaders after source preparation0; then freeze registration4.1.2 input. All separate before-push owners remain. |',
                            '| 1 | `' + NEXT + '` | `pending` | Complete remaining roles/loaders after bounded Dart constructed-input qualification0; freeze registration4.1.2 input. All separate before-push owners remain. |')
    elif name == 'docs/TASK_TREE.md':
        text = re.sub(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$',
                      lambda match: match[1] + 'PNT: bounded Dart constructed-input qualification4.1.1.1.0 is focused-checked; complete remaining roles/loaders, exact registration4.1.2 and early publication30.2 after all separate prerequisites.' + match[2], text)
    else:
        text = re.sub(r'(?m)^November16 current PNT frontier:.*$', 'November16 current PNT frontier: Bounded Dart loader qualification ' + OWNER + ' is focused-checked. Remaining consumer/loader qualification4.1.1.1.1 precedes exact registration/source admission/canonical4.1.2 and publication30.2 after all independent prerequisites. No SDK execution or full inventory/admission is claimed.', text, count=1)
    path.write_text(text)
for name, heading, body in [
    ('CHANGES.md', '2026-11-16 — qualify constructed Dart loader inputs', summary),
    ('DEVELOPMENT_NOTES.md', '2026-11-16 — distinguish Dart input and capture roles',
     'Literal paths alone miss the with fixture extension substitution and the default grammar dependency. Four selected normals pass grammar explicitly; constructor/with use the cached cwd-then-script upward lookup. Callable-transform imports its observer and optionally reads back its own just-written capture. These are distinct roles; no current lookup/cache/SDK result is inferred. The prior five-consumer fixture ledger is an independent dated comparison; callable inputs are additionally source-bound. Three supplied portable-policy digests match the previous review; known guide changes remain policy20.')]:
    path = Path(name)
    text = path.read_text()
    offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## ' + heading + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`. Remaining population, canonical registration and native/source-origin closure retain their existing owners.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
text = path.read_text()
for heading, body in {'Current Activity': 'PNT: bounded Dart constructed-input qualification is complete; remaining roles/loaders precede exact canonical registration.', 'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': next_action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda match: match[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — six Dart consumers/ten fixture/six grammar/one support/one output-readback/eight controls; static only, no SDK/admission.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('''# MEMORY

- activation_commit: `c9de2f335a2be2d518bcdb79773d16964d7f8109` — clean Dart loader-qualification activation; derive current HEAD from Git.
- latest_completed_leaf: `''' + OWNER + '''` — constructed Dart fixture/grammar/support/output roles.
- active_work_unit: `''' + OWNER + '''` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.
- run_state: PNT; continue after each clean leaf.
- next_action: ''' + next_action + '''
- in_flight_uncommitted: none; no required background job.
- evidence: ''' + str(BASE / 'REVIEW.md') + '''; readonly review.py, optional --current compares bytes/modes. Six named consumers/ten fixture edges/six grammar edges/one support import/one optional output readback; prior five-consumer ledger agrees and eight controls reject.
- limits: Static source interpretation only; no SDK execution, observed default/cache resolution or canonical inclusion. Parent inventory4.1.1 stays active. Current per-read/native/source-origin/physical closure remains4.2/SESSION5; all prior declared5.4/formatter/context/shadowing/launcher/literal/excluded owners remain open.
- preparation: Source preparation952/proposals221/candidate Perl omissions131 stays qualified only as preparation. Original planning archive/producer and actual command records stay exact; portable qualified archive and relative replay mappings grant no retroactive first-use/native credit.
- publication: Director1.5GB trigger governs; remeasure committed HEAD before growth. Last diagnostic .linkedspec-data/push-monitor/20261116T122344.625889Z stays dated/protected, not current. Final30.2 requires all independent prerequisites and exact canonical proof.
- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GiB/current90-percent rising-trend policy; no recover/purge while denied liveness remains unresolved. Cleanup: docs/ARTIFACT_CLEANUP.md.
''')
book = Path('docs/linkedspec-book/src/development/documentation-workflow.md')
text = book.read_text()
marker = '\nArchive member names must be derived relative to the repository'
assert text.count(marker) == 1
paragraph = ('\nA bounded Dart loader review covers six named consumers: ten fixture inputs, six grammar dependencies, one support import and one optional capture readback. The `with` fixture expands its extension to separate spec and JSON inputs. Four normals read grammar explicitly; constructor/`with` rely on the cached default parser, which searches upward from the current directory before the script directory. The callable-transform capture writes serialized input before reading it back when its capture environment variable is set. Source interpretation and the earlier fixture ledger agree, with eight omission/role/path controls. These facts describe source routes; actual runtime lookup, cache state, package resolution, complete loader coverage and canonical execution remain separately verified work.\n')
book.write_text(text.replace(marker, paragraph + marker, 1))
Path(BASE / 'REVIEW.md').write_text('''# Constructed Dart loader qualification

Owner: ''' + OWNER + '''. Activation: c9de2f335a2be2d518bcdb79773d16964d7f8109.

''' + summary + '''

`qualification.json` names the six consumers and their existing feature owners;
`loaders.json` retains each interpreted expression, target, role and condition.
`inputs.tar.gz` retains all26 source/fixture/instrument bodies and modes. Git's
actual listing/full channels bind pre-existing inputs to the activation, and
`identities.json` checks every archive member. No submodule or other repository
implementation was consulted. Existing preparation and historical observations
are unchanged.

The earlier4.20 input ledger independently supplies the five-consumer comparison.
The new callable consumer supplies its two literal fixture reads, source-relative
observer import and optional write-before-readback. Literal source matching is
deliberately narrow: it rejects unclassified direct reads in these six files;
it is not a general Dart parser, package graph or complete transitive loader audit.
The default parser's first existing upward candidate and process cache remain
runtime-dependent; the retained source does not prove current resolved routing.

Eight controls reject missing fixture/default grammar/support, wrong constructed
path, output promoted to fixture, duplicate read, reversed default anchor order
and omitted consumer. These validate the source ledger and earlier input boundary,
not Dart execution. Readonly recovery:

```sh
bash tools/run_python_project_data.sh ''' + str(BASE / 'review.py') + '''
```

Add `--current` only to compare today's26 retained input bodies/modes; this never
recaptures or refreshes the dated proof. The source capture is one-shot. Actual
capture/review command channels are retained; outer launchers necessarily start
before their self-images, with no first-use/native origin claim. Python/Git/
libraries/OS and actual per-read/native/source-origin closure remain4.2/SESSION5.
Parent role/loader qualification and canonical registration remain open.
''')
Path('docs/knowledge/dart-constructed-loader-roles.md').write_text('''---
id: dart-constructed-loader-roles
title: Dart fixture, grammar, support and optional capture reads have separate roles
answers:
  - "which constructed Dart paths need canonical loader qualification"
  - "is callable transform Dart capture readback a frozen fixture"
  - "does the Dart default grammar source route prove current resolved input"
date: 2026-11-16
status: bounded six-consumer static qualification; runtime routing and full inventory open
tags: [dart, loaders, fixtures, grammar, ci]
evidence: "''' + OWNER + '''; six consumers/ten fixture edges/six grammar edges/one support/one output readback; older five-consumer ledger agrees and eight controls reject."
reverify: "bash tools/run_python_project_data.sh ''' + str(BASE / 'review.py') + '''"
---

The source-bound ledger and exact expression locations live in
`''' + str(BASE / 'loaders.json') + '''`.
The `with` fixture call expands spec/json extensions. Array-transform,
callable-transform, Hash-value and Hash-view read grammar explicitly. Constructor
and `with` request the default parser: on cache miss it checks upward cwd
candidates before the script anchor, then caches the parsed grammar. Source
inspection establishes that route, not a later process's selected input.

Callable-transform imports its observer as support. Its optional phase/id capture
is written before the same invocation reads it; it is not a frozen fixture.
All named source/input/mode records survive without changing old packets.
This slice runs no Dart code and establishes no complete test/loader population,
package resolution or canonical inclusion. Parent4.1.1 and registration4.1.2 stay
open; actual per-read/native/source-origin closure and shadowing remain4.2/SESSION5.
''')
claim = dict(version=1, owner=OWNER, claims=[dict(name='six-consumer-static-loader-roles',
    statement=summary, scope=result['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + str(BASE / 'review.py'),
        granularity='Each named consumer, constructed direct read target and source expression; prior five-consumer input ledger; explicit/default grammar/support/output roles, archived bytes/modes and actual Git listing.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='A missing fixture/default grammar/support, wrong path, output misclassification, duplicate read, reversed default anchor precedence or omitted consumer could pass.',
        oracle='Retained activation source/read expressions and an independent earlier five-consumer input ledger. Callable literals and default source contract are statically interpreted, not a runtime oracle.',
        red_control='All eight named controls in actual review-stdout.json reject; healthy reconstruction and prior-ledger comparison pass.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2',
        reason='All26 named project source/fixture/instrument bodies and modes, Git listing channels, actual capture/review stdout/stderr and reconstructing instruments are retained and source-gated. Complete native Python/Git/library/OS, outer-launcher first-use and runtime per-read/source-origin/physical closure remain4.2/SESSION5. No SDK invocation or retrospective custody claim.'))])
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(claim, indent=2) + '\n')
print(summary)
