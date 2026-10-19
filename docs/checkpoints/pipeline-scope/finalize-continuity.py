"""Finalize only unbound continuity after the complete current publication exists."""
import json
from pathlib import Path
from common_final import ROOT, PREFIX, CLAIM, sha, encode

target = ROOT / (PREFIX + 'continuity.json')
assert not target.exists()
claim_raw = (ROOT / CLAIM).read_bytes()
claim = json.loads(claim_raw)
count = len(claim['claims'][0]['durability']['inputs'])
assert len(claim_raw) <= 131072
assert json.loads((ROOT / (PREFIX + 'current-review.json')).read_bytes())['result'] == 'PASS'
assert json.loads((ROOT / (PREFIX + 'controls.json')).read_bytes())['result'] == 'PASS'
tree_path = 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md'
paths = [tree_path, 'MEMORY.md', 'docs/TASK_TREE.md', 'ROADMAP.md', 'ROADMAP_V2.md',
         'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md']
assert not (set(paths) & {item['path'] for item in claim['claims'][0]['durability']['inputs']})
originals = {path: (ROOT / path).read_bytes() for path in paths}
values = {path: value.decode() for path, value in originals.items()}
old_summary = values['LIVE_ACHIEVEMENT_STATUS.md'].split('## Latest Completed Slice\n\n', 1)[1].split('\n\n## Next Action', 1)[0]
assert old_summary.startswith('Pipeline .6 opens fresh producer/input scopes')
summary = (
    'Pipeline .6 opens fresh producer/input scopes inside SourceOrigins before factories and separates '
    'four actual dependencies plus canonical apply, preserving public references/aliases/errors/order '
    'and the replacement algorithm. Original native96/distinct9/public1 and426-input proof2065/13 '
    'exact source inverses/all91 suites/32235 remain frozen. Current2065 passes with426 guarded inputs '
    'and one lossless JSON transport change; decoded observations and exact original bytes stay '
    'recoverable. The first normal hook rejects plain captured include text. Restoring the original '
    'uncommitted625-binding/full123401 draft exposes161 undeclared fixed claim inputs; whole draft, '
    'actual namespace/baselines and failed/corrected readers remain distinct. Unchanged original '
    'readers now pass with786 overlays and whole claim/mode guarded. Three current artifact denials '
    'restore exact PASS; all8 original artifact controls retain their context. Current full supplied '
    'Knowledge1487/1349 facts/10453 keys/fifteen routes/one body from that draft/8386222 bytes and '
    'book89/four controls pass; every original rendered table stays exact. Wrapped public '
    'Phase01035/1035 and required syntax pass at unchanged production; unchanged path gate passes '
    'the current transport. Four bounded parts retain all127191037 packed bytes with unchanged669-reader use and exact recovery; current part controls reject corruption/omission/order. No oversized blob, gate, selector, dependency or budget changes. Current publication '
    f'binds{count} live inputs in{len(claim_raw)} bytes under unchanged131072. Metadata .12 precedes '
    'TYPE-REFERENCE-BOOK. Output construction/composition, mapping, quoted-first repair and complete '
    'private/parent/canonical admissions remain owned. Startup.7 wrapper/kernel restrictions stay open.'
)
for path in ('docs/TASK_TREE.md', 'ROADMAP.md', 'ROADMAP_V2.md', 'CHANGES.md',
             'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md', tree_path):
    assert old_summary in values[path], path
    values[path] = values[path].replace(old_summary, summary)
tree = values[tree_path]
tree = tree.replace('- Status: `active` / .6 transport and input-closure repair',
                    '- Status: `active` / metadata .3.2.1.12 next', 1)
tree = tree.replace('Status: `active` / final proof transport and input-closure repair',
                    'Status: `done` / focused signoff with complete supplied context', 1)
tree = tree.replace('| 1 | `PERL-PRIVATE-FACTORY-CAPTURE.6` | `active` | Finish transport/closure controls, publication and all normal commit hooks. |\n', '')
tree = tree.replace('| 2 | `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12` |', '| 1 | `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12` |')
tree = tree.replace('Preserve current625/full123401 and actual readonly baseline before later bound writes.',
                    f'Preserve current{count}/full{len(claim_raw)} and actual readonly baseline before later bound writes.')
start = tree.index('- ID: `PERL-PRIVATE-FACTORY-CAPTURE.6`')
end = tree.index('\n- ID:', start + 1)
node = tree[start:end]
node += ('\n  Final transport/closure result: ' + summary + '\n  Final readonly entrypoint: bash '
         'tools/run_python_project_data.sh ' + PREFIX + 'publish.py. Original .6 publishers/readers '
         'recur only on their restored exact supplied draft; no native/capture/preparation writer '
         'is replayed. Current generation/check runs on complete supplied Knowledge in managed '
         'scratch. First failed normal-hook/replay sources and channels, supplement161, all786 '
         'post-run byte/mode guards and three new whole-file denials remain retained. The previous '
         '625 figure is explicitly a declared binding count, not complete actual IO. No fictional '
         'Git boundary or gate exemption is used.\n')
tree = tree[:start] + node + tree[end:]
tree += ('\n## Knowledge routing acceptance — PERL-PRIVATE-FACTORY-CAPTURE.6\n\n'
         '- [x] Original complete625 declaration/whole123401, actual161 omitted namespace and both '
         'readonly baselines precede bound writes; failed625 replay and distinct corrections stay exact.\n'
         '- [x] Standard solidus JSON transport has decoded equality and exact byte inverse; current '
         '2065 fixture/426 guards pass with only that data encoding change.\n'
         '- [x] Unchanged original readers pass with all786 supplied overlays and whole claim/mode '
         'guarded; forged argument, unescaped transport and coherently omitted claim each actually '
         'reject and restore exact healthy state. Unchanged path gate passes.\n'
         '- [x] Full current supplied Knowledge re-derivation/check, whole book/four controls and '
         'every original table pass. Complete current bounded publication, continuity and normal '
         'focused doctrine/hook workflow govern landing; broader admissions stay owned.\n')
values[tree_path] = tree
for path in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
    marker = '\n\nEvidence and readonly entrypoint: docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/publish.py;'
    assert values[path].count(marker) == 1
    values[path] = values[path].replace(marker,
        '\n\nThe first hook exposes an evidence transport defect; complete original draft custody '
        'then exposes its undeclared fixed claim namespace. Both P1 repairs are source-bound, '
        'reversible and independently checked without native observation refresh or gate changes. '
        'Complete current proof and readonly entrypoint: ' + PREFIX + 'publish.py;')
live = values['LIVE_ACHIEVEMENT_STATUS.md']
live = live.replace('Private factory/dependency pipeline integration .6 is focused-signoff complete; metadata .12 is next before TYPE-REFERENCE-BOOK.',
                    'Pipeline .6 and its transport/input-closure repair have focused signoff; metadata .12 is next before TYPE-REFERENCE-BOOK.')
next_start = live.index('## Next Action\n\n') + len('## Next Action\n\n')
next_end = live.index('\n\n## Recent Completions', next_start)
live = live[:next_start] + (f'From clean Git, activate PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12; preserve '
    f'current{count}-input/{len(claim_raw)}-byte publication and actual readonly baseline through '
    + PREFIX + 'publish.py before bound metadata/Knowledge/book changes. Continue TYPE-REFERENCE-BOOK '
    'afterward. No push or dirty pivot.') + live[next_end:]
lines = live.splitlines()
for index, line in enumerate(lines):
    if line.startswith('- `PERL-PRIVATE-FACTORY-CAPTURE.6` —'):
        lines[index] = (f'- `PERL-PRIVATE-FACTORY-CAPTURE.6` — scopes/five captures; original2065/13/91/32235; '
            f'current2065/426;625 declaration+161 namespace/786 guarded; Knowledge8386222/book89/4; '
            f'new artifact3+original8; readonly{count}/{len(claim_raw)}; metadata .12 next.')
        break
else: raise AssertionError('current completion row')
values['LIVE_ACHIEVEMENT_STATUS.md'] = '\n'.join(lines) + '\n'
values['MEMORY.md'] = f'''# MEMORY

- activation_commit: `64b66167c2277533c2393899e3754e14a74f0b31` — clean .6 activation; Git owns current identity.
- latest_completed_leaf: `PERL-PRIVATE-FACTORY-CAPTURE.6` — subject `PERL-PRIVATE-FACTORY-CAPTURE.6 - isolate pipeline callbacks per invocation`.
- active_work_unit: `PERL-PRIVATE-FACTORY-CAPTURE.6` (done; focused pipeline/transport/closure signoff).
- task_owner: `{tree_path}`; frontier .3.2.1.12, then TYPE-REFERENCE-BOOK.
- next_action: From clean Git activate .3.2.1.12; preserve complete current{count}/full{len(claim_raw)} plus actual readonly baseline through {PREFIX}publish.py before bound writes.
- in_flight_uncommitted: none; intended clean post-landing state. No required background result remains after landing.
- blockers: none requiring user input. Output construction/composition, mapping, quoted-first repair and complete private/parent/canonical admissions remain separately owned.
- current_evidence: Readonly {PREFIX}publish.py checks unchanged original readers on the restored exact uncommitted625-binding/full123401 draft plus actual161 fixed claims. All786 overlays and whole claim/mode are guarded. First failed hook/replay, distinct corrections and both actual pre-write baselines remain retained;625 was a declaration, not complete actual IO. No draft Git revision is invented.
- verified_scope: Original native96/distinct9/public1 and426-input2065/13 exact inverses/all91/32235 remain frozen. Current2065/426 passes with one reversible JSON encoding change. Production/test sources, public references/maps/aliases/errors/order and replacement algorithm stay exact. Required syntax and wrapped public Phase01035/1035 pass.
- observation_custody: Whole original epochs/failed instruments stay exact; decoded native view and raw byte inverse are checked. Original8 artifact denials recur in their supplied context; new3 actual whole-file denials restore exact healthy bytes/modes. No retired native/capture/preparation writer is replayed. Current supplied Knowledge generation/check uses managed scratch only.
- documentation: Complete current Knowledge1487/1349 facts/10453 keys/fifteen routes/one body from saved draft/8386222 bytes and book89/four controls pass; all original rendered tables are exact. Current{count}/full{len(claim_raw)} stays below unchanged131072. Normal focused hooks/history/memory/whitespace/public surface govern landing.
- standing_limit: SESSION-STARTUP-READING.7 owns observed wrapper process-group/kernel gaps; no lifecycle/recovery/purge admission. Latest retained cleanup review2026-10-19T00:47:29.953626UTC removed0. RUST-DEPENDENCY-WARNING-ZERO.1/.2 retain fuller public census/upstream ownership. Other repositories/submodules stay read-only black boxes; no internal dependency/build/pin changes or warning suppression.
- sequence: Metadata .12, then TYPE-REFERENCE-BOOK. Full PNT continues; no push yet.
'''
for path, text in values.items(): (ROOT / path).write_text(text)
report = dict(result='PASS', originals={path: dict(base64=encode(value), sha256=sha(value)) for path, value in originals.items()},
              current={path: sha(text.encode()) for path, text in values.items()},
              claim_sha256=sha(claim_raw), input_count=count, claim_bytes=len(claim_raw),
              producer_sha256=sha(Path(__file__).read_bytes()),
              scope='Root continuity deliberately unbound from its measured publication; complete '
                    'before bytes retained, current counts derive from the actual bounded claim. '
                    'This report and publication-preflight are explicitly excluded from publisher '
                    'namespace to avoid self-reference; no native/proof observation is refreshed.')
with target.open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
print('Current pipeline continuity finalized:', count, 'inputs;', len(claim_raw), 'bytes;metadata .12 next')
