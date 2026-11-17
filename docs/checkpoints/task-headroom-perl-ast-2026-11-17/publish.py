"""Publish existing-epoch headroom with bounded task and historical claim routing."""
import gzip
import json
from pathlib import Path
import re
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.35'
ACTIVATION = '08c39a2dfb4be628af24a445a7fdbb98a82e962f'
TARGET = 'docs/tasks/PERL-ACTIONIR-AST-MIGRATION.md'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
RUST = json.loads(Path('docs/checkpoints/rust-loader-qualification-2026-11-16/plan.json').read_bytes())['owner']
NEXT = RUST.rsplit('.', 1)[0] + '.2'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'publication-bindings.json').exists(), 'one-shot publication'
result = json.loads(gzip.decompress((BASE / 'commands/review-stdout.gz').read_bytes()))
assert result['result'] == 'PASS' and result['saved_bytes'] == 13074 and result['public_queries'] == 29
documents = [TARGET, BOOK, 'MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md']
bindings = []
for path in sorted(Path('docs/claims').glob('*.json')):
    for claim in json.loads(path.read_bytes())['claims']:
        leg = claim['durability']
        for item in leg.get('inputs', []):
            if item['path'] in documents:
                assert leg['mode'] == 'historical', 'live binding needs source-bound qualification'
                bindings.append(dict(record=str(path), claim=claim['name'], input=item, mode=leg['mode'], revision=leg['revision']))
(BASE / 'publication-bindings.json').write_text(json.dumps(bindings, indent=2, sort_keys=True) + '\n')
summary = 'Existing epoch preserves28 IDs/all CORE/five unchanged bodies/full52263-byte tail;23 closed pointers reduce88302 to75228 current bytes. All29 public queries/ten controls/current target-manifest identity pass;13074 text bytes renewed. No SDK or physical-reclamation claim.'
action = 'Remeasure committed outgoing size; qualify generated Rust manifest/corpus/host roles under ' + NEXT + ', then remaining Perl-transitive3/generated Dart2/frozen-input3 before registration4.1.2 and every other publication prerequisite.'
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n')
end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node += '  Outcome: 23 closed pointers;28 IDs/CORE/five bodies/tail52263 exact;29 queries/ten controls/current identity;13074 text bytes renewed. Full proof/limits in Evidence.\n'
path.write_text(text[:start] + node + text[end:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(OWNER) + r'`.*$',
    '| 1 | `' + NEXT + '` | `pending` | Headroom renewed; generated Rust2/remaining Perl-transitive3/generated Dart2/frozen-input3 precede registration4.1.2; all other prerequisites remain. |', path.read_text())
assert count == 1
path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    text, count = re.subn(r'(?m)^November17 current PNT frontier:.*$',
        'November17 current PNT frontier: Existing-epoch task headroom35 renews13074 current bytes with full contract/frontier recovery. Generated Rust2/remaining Perl-transitive3/generated Dart2/frozen-input3 precede registration4.1.2/publication30.2; native/semantic/other prerequisites stay open.', path.read_text(), count=1)
    assert count == 1
    path.write_text(text)
path = Path('docs/TASK_TREE.md')
text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Existing-epoch headroom35 is focused-checked; generated Rust2, remaining Perl/transitive3 and generated Dart/frozen-input work precede registration4.1.2/publication30.2.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — Perl AST closed narrative epoch; exact preservation/13074 current bytes renewed, no SDK.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$',
    lambda hit: hit[1] + 'PNT: Existing-epoch headroom35 focused-checked; generated Rust/Perl-transitive/generated Dart/frozen-input work then registration4.1.2. All publication prerequisites remain.' + hit[2], text)
assert count == 1
path.write_text(text)
notes = 'Fresh immutable-source proposal and actual epoch output agree on23 closed commentary bodies. The independent field-state reader retains every CORE field, five unselected bodies, exact prefix/tail and source/mode identity; all28 ID queries plus whole-source recovery match. Ten effective corruptions reject. Before/after images and actual channels precede public readers, without retroactive internal-self-check or native/OS custody credit. The prior Rust pressure review uses its archived images and remains healthy after current task changes. No tool/schema/limit or SDK changes.'
for name, title, body in [('CHANGES.md', 'renew closed Perl AST task narrative headroom', summary),
                          ('DEVELOPMENT_NOTES.md', 'preserve complete source through an existing task epoch', notes)]:
    path = Path(name)
    text = path.read_text()
    offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## 2026-11-17 — ' + title + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
text = path.read_text()
for heading, body in {'Current Activity': 'PNT: task headroom renewed; generated Rust/Perl-transitive/generated Dart qualification resumes.',
    'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda hit: hit[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — existing Perl AST epoch:28 IDs/23 pointers/five unchanged bodies/29 queries/ten controls;13074 current bytes renewed.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean headroom-renewal activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — closed Perl AST task narrative epoch with full recovery.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review.py/optional --current and public epoch reader. All28 IDs/CORE/five unchanged bodies/full52263-byte tail/23 pointers/29 queries/ten controls;88302 to75228 bytes. Existing native tools/schema/limits unchanged.\n' +
    '- findings: 13074 current text bytes renewed; full original source remains queryable. The prior227-byte pressure remainder is dated, not a current allowance. Original SDK observations/claims stay historical. This is data-only preservation, not new Perl AST or runtime admission.\n' +
    '- limits: Generated Rust2/remaining Perl-transitive3 include eleven unresolved Lua routes. Generated Dart2/frozen-input3/default-literal/repeated ActionIR registration and all native/per-read/source-origin/physical4.2/SESSION5 or other prerequisites remain open. Classifier child-status repair remains SESSION77-owned.\n' +
    '- publication: Director1.5GB trigger governs. Activation/cached4683555e estimate1,479,524,364 bytes/122 ahead/20,475,636-byte margin excludes this slice. Selected telemetry retained; raw pack/full logical tables ignored; independent size falsification30/native4.2 gaps. Remeasure after landing;30.2 needs all prerequisites/exact canonical proof.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising-trend policy. Last cleanup November16 10:59UTC remains under24h; nothing removed. Normal hooks remain mandatory integrity.\n')
path = Path(BOOK)
text = path.read_text()
marker = '\nClosed-task commentary can use the existing explicit epoch interface'
assert text.count(marker) == 1
paragraph = ('\nA closed-tree epoch can renew current text capacity while preserving its full source. One Perl AST migration tree keeps all28 IDs and CORE fields, five complete unselected bodies and its52263-byte frontier/tail;23 closed commentary pointers reduce current text from88302 to75228 bytes. Whole-source and every ID query recover original bytes. That13074-byte reduction is text capacity under existing limits, with original SDK observations still historical.\n')
path.write_text(text.replace(marker, paragraph + marker, 1))
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Original/current task bodies/modes, full task/epoch inputs, actual native command channels, instruments and Git source identities are retained. The unchanged migrator internally verifies output before the separate after-image; earlier self-check/outer-launcher first-use and complete Python/Perl/Git/toolchain/OS/per-read/source-origin/physical custody remain4.2/SESSION5. No SDK or new runtime admission.')
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review.py')
claims = [dict(name='perl-ast-closed-task-narrative-preservation', statement=summary, scope=result['limits'],
    rederive=dict(status='checked', command=command, granularity='Every ordered ID/CORE field, complete unselected body, prefix/frontier/tail/mode, exact source proposal and all29 original public query outputs.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='An epoch could drop a contract, frontier byte, node, unselected body or exact source pointer while preservation still passed.',
        oracle='Independent line-state field parser/full original-current byte comparison plus actual public whole-source and all stable-ID outputs, separate from production rendering.',
        red_control='Prefix/tail/status/goal/omitted-node/unselected-body/pointer/source/selection/mode mutations each reject with its recorded reason; healthy finite preservation passes.'), durability=gap)]
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
claims.append(dict(name='activation-outgoing-estimate', statement='Committed activation estimates1,479,524,364 non-thin serialized bytes against cached4683555e;20,475,636 bytes below the director1.5GB trigger.', scope=size['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py', granularity='Actual committed activation/cached-origin range; selected original producer/ref/config/command metadata copied without replay.', result=json.dumps(size, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Producer stream/stat/footer agree; independent actual-file size falsification remains30.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Selected original producer/ref/config/command channels retained; raw pack/full object tables remain ignored. Full native/physical/input custody remains4.2/SESSION5; no remote freshness/wire promise.')))
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
