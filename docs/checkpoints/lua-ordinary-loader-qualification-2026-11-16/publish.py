"""Publish source-only ordinary Lua loader qualification without refreshing history."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PLAN = json.loads((BASE / 'plan.json').read_bytes())
OWNER, ACTIVATION = PLAN['owner'], PLAN['activation']
PARENT = OWNER.rsplit('.', 1)[0]; NEXT = PARENT + '.1'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'publication-bindings.json').exists(), 'one-shot publication'
result = json.loads(gzip.decompress((BASE / 'review-stdout.gz').read_bytes()))
assert result['result'] == 'PASS' and len(result['controls']) == 14 and len(result['historical']['matching']) == 29
documents = [BOOK, 'MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md']
bindings = []
for path in sorted(Path('docs/claims').glob('*.json')):
    for claim in json.loads(path.read_bytes())['claims']:
        leg = claim['durability']
        for item in leg.get('inputs', []):
            if item['path'] in documents:
                assert leg['mode'] == 'historical', 'live binding requires qualified preservation'
                bindings.append(dict(record=str(path), claim=claim['name'], input=item, mode=leg['mode'], revision=leg['revision']))
(BASE / 'publication-bindings.json').write_text(json.dumps(bindings, indent=2, sort_keys=True) + '\n')
log = Path('.linkedspec-data/dart-ordinary-loader-commit.log'); raw = log.read_bytes()
assert b'doctrines: ALL 10 enforced doctrines PASS.' in raw and b'[memory-pointer] ok: post-commit' in raw
(BASE / 'preceding-normal.log.gz').write_bytes(gzip.compress(raw, mtime=0))
(BASE / 'preceding-normal.json').write_text(json.dumps(dict(source=str(log), commit=ACTIVATION,
    bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=log.stat().st_mode & 0o777,
    recording='after-use copy of the preceding completed commit'), indent=2) + '\n')
telemetry = Path('.linkedspec-data/push-monitor/20261116T213608.629171Z'); (BASE / 'telemetry').mkdir()
copies = []
for path in sorted(telemetry.iterdir()):
    if path.suffix in ('.pack', '.idx', '.log') or path.name.startswith(('objects-', 'object-metadata-')): continue
    target = BASE / 'telemetry' / path.name; shutil.copy2(path, target)
    assert target.read_bytes() == path.read_bytes() and target.stat().st_mode == path.stat().st_mode
    copies.append(dict(source=str(path), target=str(target), bytes=path.stat().st_size,
        sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=path.stat().st_mode & 0o777))
(BASE / 'telemetry-copies.json').write_text(json.dumps(copies, indent=2) + '\n')
summary = ('Sixteen ordinary Lua sources account for all43 io.open sites,87 file/grammar/syntax/support bindings to43 targets,30 syntax-only loads,three support loads and16 opaque package requests. '
    'Twelve optional capture conditions, named runtime exclusions,29 historical identities,14 controls/current165 and the inert-header/toy inverse pass. No package/regression body execution or admission.')
next_action = ('Remeasure committed outgoing size; continue remaining Perl/Rust/Julia loaders/support/dormancy/transitive qualification under ' + NEXT +
    '; generated Dart package/corpus2 and frozen-input3 remain separate before registration4.1.2, alongside every other push prerequisite.')
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md'); text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n'); end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node += '\n  Outcome: ' + summary + '\n  Remaining: Sibling1 owns remaining Perl/Rust/Julia and population/selection; generated Dart source2/frozen-input3/native4.2 and all other prerequisites stay open.39.8.1 exclusions are unchanged.\n'
path.write_text(text[:start] + node + text[end:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(PARENT) + r'`.*$',
    '| 1 | `' + NEXT + '` | `pending` | Ordinary Lua loader graphs focused-checked; remaining Perl/Rust/Julia qualification, generated-source2 and frozen-input3 precede registration4.1.2. Separate push owners remain. |', path.read_text())
assert count == 1; path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name); text, count = re.subn(r'(?m)^November16 current PNT frontier:.*$',
        'November16 current PNT frontier: Sixteen ordinary Lua loader graphs ' + OWNER + ' are focused-checked with source exclusions preserved. Remaining Perl/native qualification, generated Dart package/corpus2 and frozen-input3 precede registration4.1.2/publication30.2; no SDK/admission claim.', path.read_text(), count=1)
    assert count == 1; path.write_text(text)
path = Path('docs/TASK_TREE.md'); text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Ordinary Lua loader/exclusion qualification is focused-checked; remaining Perl/native/generated-source/population work precedes registration4.1.2/publication30.2.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — sixteen ordinary Lua loader roles; no SDK or admission.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$',
    lambda m: m[1] + 'PNT: ordinary Lua loaders focused-checked; remaining Perl/native/population/generated-source work then registration4.1.2. Publication30.2 retains all prerequisites.' + m[2], text)
assert count == 1; path.write_text(text)
for name, heading, body in [('CHANGES.md', '2026-11-16 — qualify ordinary Lua loader roles', summary),
    ('DEVELOPMENT_NOTES.md', '2026-11-16 — separate Lua syntax loads, package requests and capture readbacks',
     'Remaining native Lua27 minus the earlier11 gives16 consumers. Source interpretation separates syntax compilation from chunk invocation, input-root-prefixed file reads from opaque require requests, three equal-byte write/readback families from eight write-only captures and a stdout-only flag. A representative retained header compiles two actual repository chunks with an inert package and never calls them; a toy-only inverse calls exactly one. The earlier root ledger corroborates29 source/input identities and lacks30 current selected targets; neither membership nor absence establishes old test/read execution. Native/source-origin and complete semantic/transitive qualification remain open; all original SDK bytes/claims remain unchanged.')]:
    path = Path(name); text = path.read_text(); offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## ' + heading + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md'); text = path.read_text()
for heading, body in {'Current Activity': 'PNT: ordinary Lua loader graphs complete; remaining Perl/native qualification precedes registration.',
    'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': next_action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda m: m[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — Lua16/io-sites43/bindings87/targets43/syntax30/support3/current165/fourteen controls and header inverse; no SDK body.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean ordinary Lua-loader activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — sixteen ordinary Lua loader roles.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + next_action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review.py/optional --current. Lua16/io43/bindings87/targets43/syntax30/support3/modules16/captures12/historical29/fourteen controls/current165; native113 reused,52 additional inputs. Inert header only.\n' +
    '- findings: Syntax loads do not invoke the shared driver; input-root prefix leaves require(linkedspec) unchanged. Optional readbacks3/write-only8/stdout1 retain distinct timing and conditions. Existing48.2.2.1 and39.8.1 runtime exclusions remain explicit. No SDK behavior change.\n' +
    '- limits: Remaining Perl/Rust/Julia loader/population/support/dormancy/transitive review, including eleven unresolved Lua local routes, stays sibling1; generated Dart2/frozen-input3 remain separate. Default literal/repeated ActionIR reconciliation remains4.1.2. Native/per-read/source-origin/physical4.2/SESSION5 and other prerequisites stay open.\n' +
    '- publication: Director1.5GB trigger governs. Activation/cached4683555e estimate1,478,422,172 bytes/119 ahead/21,577,828-byte margin is dated and excludes this slice. Selected telemetry retained; raw pack/full logical tables ignored, independent size falsification30/native4.2 gaps. Remeasure after landing;30.2 needs all prerequisites/exact canonical proof.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising-trend policy. Daily cleanup current; nothing removed. Normal hooks are the mandatory global integrity boundary.\n')
path = Path(BOOK); text = path.read_text(); marker = '\nClosed-task commentary can use the existing explicit epoch interface'
assert text.count(marker) == 1
paragraph = ('\nLua `assert(loadfile(path))` compiles a chunk and returns it; calling that chunk requires a separate invocation. A syntax check of the shared runner therefore supplies no test-selection evidence. Keep an input-root-prefixed fixture or syntax path separate from `require("linkedspec")`, whose actual package/cache resolution needs its own origin proof. Likewise, distinguish write-only captures from bytes that are read back and then supplied to restoration or emitted-code loading, and record which earlier SDK operations already happened. An optional environment condition may accept an empty string in Lua; preserve the actual branch condition.\n')
path.write_text(text.replace(marker, paragraph + marker, 1))
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Reused113/additional52 logical bodies/modes, Git activation bindings, capture/review/probe instruments and actual channels are retained. Later outer probe recorder/publication/book/preceding-hook copies have their stated logical/after-use boundary. Complete Python/Lua/Git/toolchain/library/OS, first-use, per-read/source-origin and physical custody remains4.2/SESSION5. No SDK or admission.')
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review.py') + ' --current'
probe_command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'probe.py') + ' --review'
probe = json.loads(gzip.decompress((BASE / 'probe-review-stdout.gz').read_bytes()))
assert probe['result'] == 'PASS' and probe['experiments']['toy-invocation-inverse']['result'] == 'RED'
claims = [dict(name='ordinary-lua-loader-source-graphs', statement=summary, scope=result['limits'],
    rederive=dict(status='checked', command=command, granularity='Every16 consumer, all43 io.open sites,87 finite bindings, source conditions/roles/exclusions and165 retained logical bodies/modes.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='gap', repair_owner=NEXT, reason='Eleven ledger corruptions reject; historical29 and a separate actual-host header inverse corroborate bounded aspects. Full independent semantic/transitive classification remains with remaining qualification; no actual SDK/module/cache origin or complete graph follows.'), durability=gap),
    dict(name='lua-syntax-chunk-vs-invocation-host-distinction', statement='The exact retained representative header with an inert package compiles two chunks and calls zero; only a toy-prefixed added invocation calls exactly one.',
    scope=probe['limits'], rederive=dict(status='checked', command=probe_command,
        granularity='Each of three original retained stdin/argv/stdout/stderr/exit specimens, reconstructed without host replay.', result=json.dumps(probe, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='Asserting the loadfile return itself executes the shared driver, or the input-root prefix changes the package request.',
        oracle='Actual isolated Lua host counts returned-chunk invocation separately from compilation and records literal module requests with an inert require. Toy body has an independent call sentinel.',
        red_control='Repository and prefix specimens: compiles2/calls0/sentinel0 and unchanged linkedspec request; added toy-only invocation: compiles2/calls1/sentinel1, observed RED for compile-only expectation.'), durability=gap),
    dict(name='historical-ordinary-lua-overlap-identities', statement='Twenty-nine selected source/input identities match the independent older concat root ledger; thirty current targets are explicitly absent. Three changed-body/mode/record controls reject.',
    scope='Only older metadata overlap versus current retained logical file bodies/modes. Neither matching nor absent membership proves old test selection or per-file reads; no inferred historical custody defect.',
    rederive=dict(status='checked', command=command, granularity='Each selected consumer/direct target classified as29 matching identities or30 absent older records.', result=json.dumps(result['historical'], sort_keys=True)),
    falsify=dict(status='checked', hypothesis='Changed grammar body/mode or a falsified older grammar digest could pass.',
        oracle='Independent dated direct/input-identities.json compared with archived current bodies and modes, separately from source expression interpretation.',
        red_control='Grammar body addition, mode change and zeroed older digest each reject; healthy29 identities agree.'), durability=gap)]
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
claims.append(dict(name='activation-outgoing-estimate', statement='Committed activation estimates1,478,422,172 non-thin serialized bytes against cached4683555e;21,577,828 bytes below the director1.5GB trigger.', scope=size['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py',
        granularity='Actual committed activation/cached-origin range; selected original producer/ref/config/command channels copied without replay.', result=json.dumps(size, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Producer stream/stat/footer agree; independent actual-file size falsification remains30, not inferred from metadata.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Selected producer/ref/config/command channels retained; raw pack/full logical tables remain ignored. Full native/physical/input custody remains4.2/SESSION5. No remote freshness/wire claim.')))
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
