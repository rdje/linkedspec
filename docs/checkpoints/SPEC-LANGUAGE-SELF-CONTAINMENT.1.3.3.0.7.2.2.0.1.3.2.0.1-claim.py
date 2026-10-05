"""Bind original argument diagnosis to its actual producers and complete inputs."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0.1'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REVISION = '2fd4e499e68f19d6a481662f46c4e24a1c0896a1'


def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


runtime, book, freeze = [json.loads((ROOT / (PREFIX + n + '.json')).read_bytes())
                         for n in ('verification', 'book-verification', 'freeze')]
assert runtime['complete'] and book['complete'] and runtime['revision'] == freeze['revision'] == REVISION
assert (runtime['regular_inputs'],runtime['compatibility_overlays'],runtime['frame_overlays'],runtime['commands'],runtime['cases'],runtime['arguments'],runtime['seeds'],runtime['before_red_groups'],runtime['after_green_groups'],runtime['fixture_suites'],runtime['fixture_groups'],runtime['observed_frames'],runtime['complete_compiler_pairs'])==(4162,2,1,14,10,23,3,10,15,9,1173,138,3)
assert len(runtime['controls'])==23 and all(c['observed']=='RED' and c['reason'] for c in runtime['controls'])
assert (book['book_inputs'],book['rendered_examples'],book['rendered_sections'],len(book['controls']),freeze['bound_inputs'])==(58,18,3,17,29)
for result, producer in ((runtime, 'review.py'), (book, 'book.py'), (freeze, 'freeze.py')):
    assert result['instrument_sha256'] == digest(PREFIX + producer)
paths = [p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if p.is_file()]
base = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.0-'
paths += [base + n for n in ('review.py', 'review-oracle.py')]
argument='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0-'
paths += [argument+n for n in ('review.py','oracle.py','cases.json','probe.pl')]
paths += ['perl/LinkedSpec/OwnerDispatch.pm','t/actionir_method_argument_source_frames.t']
paths += ['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
          'perl/LinkedSpec/ActionIR/MethodExpr.pm', 'perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm',
          'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md', 'tools/check_claim_verification.py',
          'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh']
inputs = [{'path': p, 'sha256': digest(p),
           'role': 'producer' if p.endswith(('.py', '.pl', '.pm', '.sh')) else 'input'} for p in sorted(set(paths))]
statement=('Invocation-local private MethodExpr CSV/parser sidecars retain actual callback returns and independently authored original scalar argument frames. Each immutable epoch supplies4162 regular Git inputs with two exact compatibility overlays or one exact frame overlay and only one declared MethodExpr delta. Fourteen guarded commands retain ten cases23 arguments across three seeds: zero original frames before and138 observed parser/CSV frames after. Final15-group regression is RED10/GREEN15; nine affected suites including1034 Phase0 pass1173 groups. Three full original diagnosis/compiler channels remain byte-identical.23 reason-specific evidence controls observe RED. Complete58-input book renders18 examples/three chapters with17 rejection controls. All29 prior diagnosis input hashes verify before historical freeze.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name':'private-original-method-argument-frames', 'statement': statement,
    'scope': ('Immutable '+REVISION+' regular Git conservative supplied-input superset, not minimal observed IO. Complete original byte/mode/member guards and full channels retained; one declared MethodExpr delta only. Independent original literal source fragments author all scalar intervals, including trim/payload bases, dropped empty slots, repeated twins, Unicode/CRLF and receiver/helper-pattern context. CSV and parser wrappers preserve exact returned arrays/hashes/argument references and call dependencies once with original signatures. Copied/foreign/opaque returns decline authority; changed entries decline individually; parser source/method transformations also decline. Nested recorders and original exceptions/caller error state remain exact. Original local RED and first GREEN/refined GREEN are separately retained; first producer/test are reconstructed by reversing the exact recorded refinement patch with explicit identity limits. Final immutable proof supplies actual final bytes. Initial reviewer import fails before oracle execution and is retained; corrected actual complete reviewer must pass. No Flow recursive consumption/recognizer/dispatch/public result fields/new callback/CI/storage/dependency/other-repository change. Complete book render is teaching, not new DSL/native admission. Required host OS/Perl/Python/prove/mdBook are read-only; project data stays repository-local; gitlinks/nonregular metadata exclude payload inspection. Arbitrary malicious callbacks/host syntax/global audit/membership are not admitted. Prior diagnosis is historical and all earlier adjudications remain exact. Recursive Flow .1.3.2.1 and canonical family acceptance .1.3.3 remain separate.'),
    'rederive': {'status': 'checked', 'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + n
                 for n in ('capture.py before','capture.py after','frames-capture.py before','frames-capture.py after','review.py','freeze.py','book.py --review')),
                 'granularity':'4162 regular inputs/2 compatibility or1 frame overlay per epoch/one owner delta/14 commands;10 cases23 arguments/3 seeds/138 observed frames;RED10-GREEN15/9 suites1173 groups;58 book inputs18 examples3 chapters;29 prior hashes.',
                 'result': statement},
    'falsify': {'status': 'checked',
                'hypothesis': 'Equal string values, copied returns, lost empty slots, callback reordering or incomplete channels could incorrectly establish original argument authority.',
                'oracle': 'Independent cumulative original fragments/intervals, actual CSV-return refaddr comparison, exact callback/result/error/traversal literals, complete immutable Git and runtime channel/TAP checks.',
                'red_control':'Untouched final regression actually RED10 of15 and implemented producer GREEN15.23 reason-specific controls reject each nonempty case missing parser/CSV frames, forged actual returned references, wrong scalar spans, lost commands/Git input and unrelated RED stderr.17 book controls reject.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print(str(len(inputs)) + ' actual producer/artifact bindings')
