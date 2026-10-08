"""Publish bounded rejected-candidate diagnosis with explicit partial Phase0 gap."""
from pathlib import Path
import hashlib, json, subprocess

ROOT = Path(__file__).resolve().parents[2]
PARENT = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1'
LEAF = PARENT + '.0'
PREFIX = 'docs/checkpoints/' + PARENT + '-'
CLAIM = 'docs/claims/' + LEAF + '.json'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()
proof = json.loads(read(PREFIX + 'verification.json'))
regression = json.loads(read(PREFIX + 'regression-verification.json'))
recovery = json.loads(read(PREFIX + 'recovery.json'))
book = json.loads(read(PREFIX + 'current-book-verification.json'))
assert proof['complete'] and regression['complete'] and recovery['complete']
assert proof['original_regular_inputs'] == 5216 and proof['corrected_public_pairs'] == 54
assert proof['source_inverse_controls'] == len(proof['evidence_controls']) == 12
assert proof['candidate_consumer_pass_groups'] == 153 and proof['original_consumer_pass_groups'] == 154
assert regression['discarded_nested_intervals'] == 2 and len(regression['controls']) == 5
assert recovery['supplied_inputs'] == 5219 and book['book_inputs'] == 58
assert book['exact_examples'] == 8 and len(book['controls']) == 13
assert read('perl/LinkedSpec/ActionIR/RewritePipeline.pm') == subprocess.check_output(
    ['git', 'show', '6feff5d40a7e0554425314c120d7ce2b73586a49:perl/LinkedSpec/ActionIR/RewritePipeline.pm'], cwd=ROOT)
assert not (ROOT / CLAIM).exists() and not (ROOT / (PREFIX + 'publication.json')).exists(), 'one-shot publication'
paths = {p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(PARENT + '-*') if p.is_file()}
paths.update([
    'COMMIT.md', 'DOCTRINE_ENFORCEMENT.md', 'tools/project_data_env.sh', 'tools/project_data_run.sh',
    'tools/run_python_project_data.sh', 'scripts/check_claim_verification.sh', 'tools/check_claim_verification.py',
    'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'MEMORY.md', 'LIVE_ACHIEVEMENT_STATUS.md', 'ROADMAP.md',
    'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md',
    'docs/knowledge/perl-mapped-replacement-nested-continuation.md',
    'docs/knowledge/perl-residual-replacement-source-frames.md',
    'docs/knowledge/perl-private-original-occurrence-handoff.md',
    'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0.json',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-fresh.pl',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0-origin-fixture.t',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0-cases.json',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0-corrected-cases.json',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0-corrected-prepare.py',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0-book.py',
    'perl/LinkedSpec.pm', 'perl/LinkedSpec/OwnerDispatch.pm', 'perl/LinkedSpec/RuleIR/EmitContext.pm',
    'perl/LinkedSpec/ActionIR/SourceOrigins.pm', 'perl/LinkedSpec/ActionIR/SourceMembership.pm',
    'perl/LinkedSpec/ActionIR/ScannerCore.pm', 'perl/LinkedSpec/ActionIR/Scanner.pm',
    'perl/LinkedSpec/ActionIR/Diagnostics.pm', 'perl/LinkedSpec/ActionIR/CanonicalEvents.pm',
    'perl/LinkedSpec/ActionIR/CanonicalEvents/Core.pm', 'perl/LinkedSpec/ActionIR/RewritePipeline.pm',
    'perl/LinkedSpec/ActionIR/MethodLowering.pm', 'perl/LinkedSpec/ActionIR/Contracts.pm',
    'perl/LinkedSpec/ActionIR/StatementSplit/Core.pm', 't/phase0_regression.t',
])
paths.update('t/' + name + '.t' for name in ('actionir_ast_parser', 'canonical_event_occurrence_order',
    'actionir_nested_block_source_spans', 'actionir_compiler_source_membership',
    'actionir_executable_source_membership', 'trace_emit_context_bridge'))
paths.update(subprocess.check_output(['git', 'ls-files', 'docs/linkedspec-book'], cwd=ROOT).decode().splitlines())
guard = {path: sha(read(path)) for path in sorted(paths)}
publication = dict(complete=True, producer_sha256=sha(Path(__file__).read_bytes()), guarded_inputs=guard,
    scope='One-shot diagnosis-only claim publication. Complete guarded before/candidate graphs and channels, original/corrected instruments, actual character-label/ref/value oracles, current book and proof sources are bound. Actual rejected source is a tracked input; installed production is byte-exact6fe. Supplemental root Phase0 retains combined output and explicitly discloses missing exact full-input identity; it is neither full-suite nor canonical acceptance. No historical capture/hash refresh.')
(ROOT / (PREFIX + 'publication.json')).write_text(json.dumps(publication, indent=2) + '\n')
paths.add(PREFIX + 'publication.json')
inputs = [dict(path=path, sha256=sha(read(path)), role='producer' if path.endswith(('.py', '.pl', '.sh', '.t', '.pm')) else 'input') for path in sorted(paths)]
statement = ('The retained original-interval candidate is rejected, not installed. Four complete regular supplied graphs independently recover5216 original Git inputs and three authored overlays per epoch; candidate after replaces only RewritePipeline. Corrected54 source/seed pairs produce108 expected native/fresh values, with33 formerly failing and21 unchanged healthy pairs. Actual AST/source/ref/argument/family/raw packets stay exact; healthy complete output/value/error/effect packets stay exact. Independent original-character labels validate mapped intervals and actual substr edits. Original interval fixture RED9/GREEN10 and twelve effective candidate source inverses distinguish literals, edits, consumed duplicates, boundaries, closure/newline anchors and opaque callbacks. Twelve evidence controls reject. Nevertheless one of154 unchanged consumer groups rejects lost raw nested capture lowering. Two guarded full-input nested Toolbox epochs preserve actual original references/AST/arguments yet distinguish original native/fresh [["a"]] values from candidate host-call failures: IF/PUSH/ENDIF edits discard selected intervals20–35/57–72 while retaining two executable capture_slice calls. Five mechanism controls reject. Actual candidate graph recovery from reachable Git objects and tracked overlays verifies5219 inputs; inverse proof reruns from that reconstruction. All127 prior private-handoff inputs recover at6fe with mode/revision-only qualification. Current58-input book renders eight exact examples and thirteen effective controls. Production is restored byte-exact6fe; P1 producer-bound continuation, integrated mapping and independent canonical admission remain open.')
scope = ('Bounded rejected Perl candidate diagnosis. Initial wrong-facade deferred guard and invalid one-argument cat population remain complete and distinct; corrected same-facade and accepted two-argument sources include the LF variant, preserving sixteen other source/value/interval oracles. Initial independent reviewer incorrectly assumes an empty deferred invocation; sole correction requires the exact original cb invocation/effects, with all healthy packet fields still equal. Initial render negative needle expects encoded quotes; sole correction matches actual literal quotes. All initial sources/errors/renders remain retained. Candidate teaching capsule is an unshipped draft; current book truthfully retains the quoted-first failure and explains nested continuation. Character-label oracle derives surviving scalar identity independently of production offset arithmetic; actual lowerer/edit history remains in execution order. Supplied Git graphs are complete conservative regular-file supersets, not minimal observed IO. Submodule/nonregular payloads are excluded without inspection. No replacement repair, complete Phase0, readiness/diagnostic-origin closure, arbitrary grammar, other backend, recurring registration, canonical receipt or push is claimed. Root Phase0 limits are a separate disclosed-gap claim. All project data is repository-local/same-volume; OS/Git/Perl/Python/mdBook standard/tool dependencies are necessary read-only inputs.')
record = dict(version=1, owner=LEAF, claims=[dict(name='rejected-mapped-interval-candidate', statement=statement, scope=scope,
    rederive=dict(status='checked', command='At this owning diagnosis boundary run bash tools/run_python_project_data.sh ' + PREFIX + 'review.py, regression-review.py, recover.py and inverse.py; current-book.py --review recurs retained current render. Never replay original capture against changed production or execute one-shot activation/preparation/publication writers. Recovery and inverses use retained candidate source, not installed production.',
        granularity='Each authored scalar interval and source/seed packet, original character identity, actual edit, selected/copy/argument relationship, complete graph/command/channel, nested continuation and current rendered example.18 sources times3 seeds; ten interval groups;154 direct groups; two guarded regression epochs.', result=statement),
    falsify=dict(status='checked', hypothesis='Original interval consumption plus quote-only success establishes a safe replacement repair, or generated equal raw text can supply nested occurrence authority.',
        oracle='Independent authored literal/value/source intervals, surviving original character labels, exact original healthy public packets and actual event/reference topology. Guarded original/candidate nested Toolbox execution and unchanged AST raw-fallback test distinguish lost accepted continuation despite quote success. Reachable original Git objects and exact historical claim bind inputs.',
        red_control='Actual original interval RED9/10; twelve effective isolated candidate source inverses fail their named assertion with passing baseline. Twelve input/channel/value/ref/mapping/history evidence controls and five nested mechanism controls reject. Candidate loses one direct consumer group and both guarded nested execution routes, so it is rejected and production restored. Current rendered book has thirteen effective semantic/input/channel controls.'),
    durability=dict(status='checked', mode='live', inputs=inputs)),
    dict(name='partial-root-phase0-diagnostic-gap',
        statement='Actual rejected-candidate root Phase0 process fails:98 of926 observed top-level groups fail, test process exits255, no final TAP plan, outer prove exits1. This is a partial diagnostic and not complete1035-suite or exact guarded-input acceptance.',
        scope='Supplemental combined stdout/stderr is retained completely and decoded by regression-review.py. Root documentation changed during execution and production was restored after its loaded candidate exposed regressions. The full original root input graph was not guarded; separate stdout/stderr were redirected together. Guarded original/candidate nested and direct consumer proofs independently establish the defect, without expanding this partial run to full-suite acceptance.',
        rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + PREFIX + 'regression-review.py decodes and verifies the retained phase0-diagnostic.json channel and reached last group; do not replay it as complete acceptance.',
            granularity='Actual complete process output,98 failed/926 observed groups, missing final plan and named nested entry helper error; no unobserved groups.', result='Complete retained process output distinguishes failed partial traversal from a passing full suite.'),
        falsify=dict(status='checked', hypothesis='An ended Phase0 process or passing quote fixture is equivalent to full regression acceptance.',
            oracle='Actual final TAP/process summary and reached pplugin_parser_smoke group926; explicit no-plan and exits255/1. Independent guarded nested original/candidate channels and unchanged consumer failure corroborate lost continuation.',
            red_control='Actual candidate root process RED98/926/no plan rejects full acceptance; guarded nested original GREEN/candidate RED prevents misclassifying a probe artifact as the runtime mechanism.'),
        durability=dict(status='gap', reason='Complete combined channels, candidate and harness sources are retained and hash-bound in the main diagnosis claim, but the original evolving-root full input graph and distinct output channels were not recorded and cannot be reconstructed. Fresh corrected full guarded Phase0 proof is required; no historical refresh or current-root replay repairs this run.', repair_owner=PARENT + '.1.2'))])
raw = (json.dumps(record, indent=2) + '\n').encode(); assert len(raw) <= 131072
(ROOT / CLAIM).write_bytes(raw)
assert all(sha(read(path)) == digest for path, digest in guard.items())
print(json.dumps(dict(complete=True, claim=CLAIM, inputs=len(inputs), bytes=len(raw), disclosed_gaps=1)))
