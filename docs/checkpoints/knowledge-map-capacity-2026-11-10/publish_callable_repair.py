"""Append bounded source-custody proof and disclose the native-closure gap."""
import copy
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.18.1'
RECORD = ROOT / 'docs/claims' / (OWNER + '.json')
old_bytes = RECORD.read_bytes()
old = json.loads(old_bytes)
assert len(old['claims']) == 5
original = HERE / 'implementation-pre-callable-claim.json.gz'
assert not original.exists(), 'one-shot claim supplement'
original.write_bytes(gzip.compress(old_bytes, mtime=0))
prefixes = ('codeblock', 'count-fence', 'count_fence', 'callable-', 'callable_', 'calibrate_count_fence',
            'package_callable_channels', 'publish_callable_repair')
paths = {path for path in HERE.iterdir() if path.is_file() and path.name.startswith(prefixes)}
paths.update(ROOT / name for name in (
    'perl/LinkedSpec/ActionIR/MethodLowering.pm', 't/callable_codeblock_literal_contract.t',
    't/count_result_guard_source_fences.t', 't/count_result_guard_composition.t',
    't/length_result_guard_composition.t', 't/length_count_source_ownership.t',
    'tests/fixtures/count_result_guard_excluded_ast.json', 'capability_conformance/callable_codeblock_contract.json',
    'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
    'docs/knowledge/perl-count-result-source-guards.md',
    'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md',
))
paths.update(HERE / name for name in ('factory-boundary-after.json.gz', 'canonical-sixth.log.gz'))
inputs = [dict(path=path.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
               role='producer' if path.suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input')
          for path in sorted(paths)]
command = ('bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/codeblock_review.py && '
           'bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/count_fence_review.py')
codeblock = (HERE / 'codeblock-review-result.json').read_text().strip()
fence = (HERE / 'count-fence-review-result.json').read_text().strip()
source_claim = dict(
    name='callable-prepared-index-and-count-snapshot-source-custody',
    statement='Retained public diagnostics identify discarded prepared callable-index source. Exact activation and repaired module observations agree on all18 Count excluded-source rows; only the old fixture first lowered cell is stale. The source correction changes that cell alone, retaining unsupported ownership.',
    scope='Readonly replay of exact retained project-source and diagnostic artifacts, not a rerun or full custody of the native process. Complete declared parent-owned Perl/spec/conf/tablescript/ebnf source bodies remain in the frozen factory-after bundle, with captured pre-use member identities and only the explicit MethodLowering override. Initial Trace framing and wrong-module overlay attempts remain uncredited; original fixture/module/consumer and all actual channels stay retained. No malformed Count authority, broad raw-source readiness or peer/full-feature admission.',
    rederive=dict(status='checked', command=command, granularity='Every retained source packet/member, actual loaded module SHA, original Git fixture/module byte, all18 AST/lowered/diagnostic rows, excluded generated/native/metadata artifact fields, and the one changed fixture cell.', result=codeblock + '\n' + fence),
    falsify=dict(status='checked', hypothesis='Old emitted source, altered values/effects, missing producer bytes, the old snapshot or another changed fixture cell could pass.', oracle='Actual committed activation module and original fixture, original neutral contract, independent public AST query, exact full-row comparison and retained SDK native/fresh channels.', red_control='Readonly reviews reject native-value, fresh-effect, old-emitted-source, missing-producer-image, old-snapshot, extra-cell and unsupported-owner corruptions. Healthy retained source/diagnostic replay passes; first overlay is disqualified by its loaded-module SHA.'),
    durability=dict(status='checked', mode='live', inputs=inputs),
)
native_claim = dict(
    name='callable-indexed-value-focused-behavior-with-custody-gap',
    statement='The unchanged neutral callable fixture and six authored indexed-result cases pass in native and independently loaded generated Perl after the repair; the original implementation fails the neutral fixture and five target cases while healthy Count passes. Direct Count/Length composition and ownership pass; after the one-cell calibration, the18-row source-fence test passes.',
    scope='Finite authored assertions and retained actual command channels only. The first five-file run exits1 solely at the stale source-fence snapshot, with the other four files passing; the calibrated source-fence rerun exits0. Post-exit packaging grants no original acquisition credit. The source-artifact claim retains project bytes/instruments/channels; shared native/cache/OS/transitive inputs are incomplete and do not earn complete native custody or full canonical/feature admission.',
    rederive=dict(status='checked', command=command, granularity='Exact retained unchanged-fixture native/fresh observations, six authored assertions in the existing consumer and observed direct-dependent test channels; diagnostic replay does not re-execute the historical native epoch.', result='Qualified unchanged fixture native/fresh matches; original callable consumer plus new cases PASS. Direct five-file run: four files pass, source-fence single stale lowered cell fails. Final calibrated18-row source-fence consumer: exit0/PASS. Exact channels are retained in callable-focused-results.json and named gzip streams.'),
    falsify=dict(status='checked', hypothesis='The original implementation can load the unchanged emitted callable fixture, or a double call/wrong selected result is accepted.', oracle='Unchanged neutral contract plus independent emitted execution and authored expected value/caller-effect pairs; healthy Count control.', red_control='Original qualified native result is undef and emitted loading fails with invalid callable/index source. Old-module direct callable consumer exits1; Count remains healthy and the five Length/String targets fail. Corrupt retained native value/fresh effect/old emitted source reject.'),
    durability=dict(status='gap', reason='Project-source bodies and actual diagnostic/test artifacts are retained by the companion source-custody claim. Complete shared Perl/native runtime, cache, OS/toolchain and transitive first-use input closure is not acquired by these probes; post-exit channel packaging cannot repair that missing leg.', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2'),
)
updated = copy.deepcopy(old)
updated['claims'].extend([source_claim, native_claim])
assert updated['claims'][:5] == old['claims'], 'preserve every older statement/result/input binding'
raw = (json.dumps(updated, indent=2) + '\n').encode()
assert len(raw) <= 128 * 1024
RECORD.write_bytes(raw)
print(json.dumps(dict(result='appended', claims=len(updated['claims']), bytes=len(raw), native_durability_gap_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2'), sort_keys=True))
