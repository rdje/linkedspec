"""Append the bounded source-oracle proof while preserving all seven prior claims."""
import copy
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.18.1'
path = ROOT / 'docs/claims' / (OWNER + '.json')
original = path.read_bytes(); before = json.loads(original)
assert len(before['claims']) == 7
saved = HERE / 'implementation-pre-scalar-copy-claim.json.gz'
assert not saved.exists(), 'one-shot source-oracle supplement'
saved.write_bytes(gzip.compress(original, mtime=0))
names = ('scalar_copy_capture.py', 'scalar_copy_probe.pl', 'scalar_copy_review.py', 'package_scalar_copy.py',
         'publish_scalar_copy.py', 'scalar-copy-qualified.json.gz', 'scalar-copy-original.t.gz',
         'scalar-copy-normal-oracle.json.gz', 'scalar-copy-review-result.json',
         'scalar-copy-capture-result.json', 'scalar-copy-prefix-first.t.gz', 'scalar-copy-prefix-empty-output.gz',
         'scalar-copy-focused-result.json', 'scalar-copy-focused-stdout.log.gz', 'scalar-copy-focused-stderr.log.gz',
         'scalar-copy-retention-result.json', 'canonical-eighth.log.gz', 'factory-boundary-after.json.gz',
         'codeblock-method-before.pm.gz', saved.name)
paths = {HERE / name for name in names}
paths.update(ROOT / name for name in ('t/actionir_receiver_scalar_copy.t', 't/actionir_receiver_scalar_copy_probe.pl',
             't/actionir_legacy_hash_kind_probe.pl', 'perl/LinkedSpec/ActionIR/MethodLowering.pm',
             'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-native.json',
             'docs/knowledge/perl-scalar-bound-receiver-copy.md',
             'docs/linkedspec-book/src/development/documentation-workflow.md',
             'tools/project_data_run.sh', 'tools/project_data_env.sh', 'tools/run_python_project_data.sh'))
inputs = [dict(path=item.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(item.read_bytes()).hexdigest(),
               role='producer' if item.suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input') for item in sorted(paths)]
result = (HERE / 'scalar-copy-review-result.json').read_text().strip()
assert json.loads(result)['result'] == 'PASS' and json.loads(result)['focused_assertions'] == 487
command = 'bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/scalar_copy_review.py'
source = dict(name='legacy-rule-array-copy-source-oracle-calibration',
    statement='The retained activation and callable-repaired modules emit identical Top.copy source. Its retained snapshot observations and the actual normal test helper match the original executable snapshot oracle for values, shallow identities, mutation isolation and one size/six element reads. The normal test changes only its literal-source assertion, adding the observational helper; every other original assertion source remains exact.',
    scope='Source/diagnostic artifact comparison and actual extracted-helper interpretation at the qualified epoch. The public AST remains variable Top plus zero-operand copy; guarded emission preserves the original rule-array source snapshot. Empty/alias/lost-nesting/repeated-read programs are actual executed distinguishing controls. No production source or copy policy change, original canonical first-use custody, complete native/cache/OS/transitive closure or broad copy/feature admission. Native focused behavior has its separate durability-gap disclosure. The initial prefix-preservation refusal occurs before normal helper capture; the first test body and empty outer output survive. Restore the original blank-line prefix before qualified capture. Earlier pre-correction direct pass channels were not retained before log reuse and earn no original-channel credit.',
    rederive=dict(status='checked', command=command,
        granularity='Every retained project-source packet/member, exact original Git test/module, all source/AST/snapshot fields, every actual test-helper outcome and other original assertion bytes; exact final focused command/channel artifact and14-value/identity frame.', result=result),
    falsify=dict(status='checked', hypothesis='An empty snapshot, alias of original storage, lost nested references, repeated source reads or a false focused PASS could satisfy the repaired oracle.',
        oracle='Original literal Perl array snapshot executed independently with tied source storage and shallow identity/mutation observations. The actual test helper is extracted from the current consumer before interpreter use. Complete original observation and focused command channels are independent retained inputs.',
        red_control='Both exact module observations and the actual normal helper reject executed empty, alias, lost_nested and repeated programs. Actual source/helper outputs agree with the original oracle. Wrong-exit, missing-pass, missing-native-frame and changed-native-identity artifact corruptions reject; original assertion-tail changes and project-source drift reject.'),
    durability=dict(status='checked', mode='live', inputs=inputs))
native = dict(name='legacy-rule-array-copy-focused-consumer-with-custody-gap',
    statement='The final scalar receiver-copy consumer passes all487 assertions after replacing only the stale literal-source assertion with executable snapshot/identity/source-read comparison. Original live/generated14 values, shallow identity, poisoned AST source, arity and legacy callback controls remain passing.',
    scope='Exact final focused command and retained native/generated observation frame, following the independent old/current source calibration. The first canonical copy run fails only its literal-source assertion, with486 others passing. This is a finite test-oracle repair, with unchanged runtime production. Earlier direct pass streams were not retained before log reuse; only the final captured487 result receives current channel credit. No full canonical receipt, whole copy-family or complete native input-closure claim.',
    rederive=dict(status='checked', command=command,
        granularity='Every final command target/exit/full stdout/stderr frame and the original14 values/identity fields, plus actual extracted-helper counterexamples; this replays evidence and the helper rather than the historical whole native epoch.',
        result='Final exact t/actionir_receiver_scalar_copy.t: exit0/487 assertions/PASS. Full physical-gzip channels and decoded observation frame checked by scalar_copy_review.py; qualified original/candidate source equality and eight executable/channel controls pass.'),
    falsify=dict(status='checked', hypothesis='Wrong copy depth, aliasing, repeated array reads or missing native results can pass the calibrated consumer.',
        oracle='Original executable array snapshot, actual normal helper and unchanged scalar-copy native/generated value and identity controls.',
        red_control='Empty/alias/lost-nesting/repeated programs differ in both independent and actual normal helper runs. Wrong-exit, missing-pass, missing-native-frame and changed-native-identity controls reject; healthy retained artifacts pass. The original literal assertion fails in canonical CI.'),
    durability=dict(status='gap', reason='Project-source bodies, producers and exact diagnostic/focused channels are retained by the companion source-oracle claim. Complete shared Perl/native runtime, cache, OS/toolchain and transitive first-use closure is not acquired; post-exit packaging and supplied snapshots do not repair that missing native leg.', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2'))
record = copy.deepcopy(before); record['claims'].extend([source, native])
assert record['claims'][:7] == before['claims'], 'preserve every prior statement/result/producer/input binding'
raw = (json.dumps(record, indent=2) + '\n').encode()
assert len(raw) <= 128 * 1024
path.write_bytes(raw)
print(json.dumps(dict(result='appended', claims=len(record['claims']), bytes=len(raw), unchanged_prior_claims=7, native_gap='TYPE-REFERENCE-BOOK.1.2.23.4.2'), sort_keys=True))
