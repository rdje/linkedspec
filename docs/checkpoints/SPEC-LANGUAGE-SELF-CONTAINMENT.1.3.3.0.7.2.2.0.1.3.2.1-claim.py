"""Bind original argument diagnosis to its actual producers and complete inputs."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.1'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REVISION = '441f9c82343507f98428fa8982e5ad13c0cdae8c'


def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


runtime, book, freeze = [json.loads((ROOT / (PREFIX + n + '.json')).read_bytes())
                         for n in ('verification', 'book-verification', 'freeze')]
assert runtime['complete'] and book['complete'] and runtime['revision'] == freeze['revision'] == REVISION
assert (runtime['regular_inputs'],runtime['overlays'],runtime['contracts'],runtime['recursive_contracts'],runtime['consumer_delta'],runtime['seeds'],runtime['actual_commands'],runtime['authority_groups'],runtime['authority_before_red'],runtime['before_red_groups'],runtime['after_green_groups'],runtime['fixture_suites'],runtime['fixture_groups'],runtime['before_origins'],runtime['after_origins'],runtime['complete_compiler_pairs'])==(4197,2,16,2,1,3,14,3,1,6,7,10,1180,87,147,48)
assert len(runtime['controls'])==29 and all(c['observed']=='RED' and c['reason'] for c in runtime['controls'])
assert (book['book_inputs'],book['rendered_examples'],book['rendered_sections'],len(book['controls']),freeze['bound_inputs'])==(58,19,3,18,49)
for result, producer in ((runtime, 'review.py'), (book, 'book.py'), (freeze, 'freeze.py')):
    assert result['instrument_sha256'] == digest(PREFIX + producer)
paths = [p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if p.is_file()]
base = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.0-'
paths += [base + n for n in ('review.py', 'review-oracle.py')]
argument='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0-'
paths += [argument+n for n in ('review.py','oracle.py','cases.json','probe.pl')]
paths += ['perl/LinkedSpec/OwnerDispatch.pm','t/actionir_flow_recursive_source_provenance.t','t/actionir_flow_direct_source_provenance.t']
paths += ['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
          'perl/LinkedSpec/ActionIR/MethodExpr.pm', 'perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm',
          'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md', 'tools/check_claim_verification.py',
          'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh']
inputs = [{'path': p, 'sha256': digest(p),
           'role': 'producer' if p.endswith(('.py', '.pl', '.pm', '.sh')) else 'input'} for p in sorted(set(paths))]
statement=('Recursive case/default Flow producers translate original captured-block and verified parsed argument frames into full-action scalar origins while preserving original event/argument objects, callbacks and marker-first/inline-second traversal. Each immutable epoch supplies4197 regular Git inputs, two compatibility overlays or one authority overlay, one Flow owner delta and one exact direct-test recursive-boundary assertion delta.14 fully guarded commands across three seeds retain original87 origins before/full147 origins after with actual references and48 complete original compiler/callback pairs unchanged. Corrected seven-group regression is RED6/GREEN7; ten suites including1034 Phase0 pass1180 groups; three separate authority groups recur GREEN after and original RED1 before.29 reason-specific evidence controls observe RED. Complete58-input book renders19 examples/three chapters with18 rejection controls.49 prior bridge input hashes verify before historical freeze.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name':'recursive-original-flow-source-frames', 'statement': statement,
    'scope': ('Immutable '+REVISION+' regular Git supplied-input conservative superset, not minimal observed IO. Every original object/byte/mode/member and complete command/channel is retained. Only one declared Flow producer delta plus exact direct-test historical recursive-origin assertions change; all other production/spec/tests unchanged. Independent original corrected Flow literal source/args/scalar/traversal oracle includes quoted syntactic case observation, not executable membership. Regex captures snapshot own source bounds before callbacks; recursive original block bases and actual private MethodExpr argument frames translate without raw-text search or lexical sort. Copied/foreign/opaque/changed/trim callback ordinary events remain intact with bounded authority denials; arbitrary malicious callbacks/host syntax not admitted. Actual returned/constructor/args identities recur across seeds. Initial fixture outer end30 is corrected by independently authored fragment length31, retaining original source/output; book instrument quote failure and reviewer exact-consumer guard failure are retained before final corrections. Complete book render is teaching, not new recognition/native admission. Prior49 hashes and earlier adjudications remain exact after mode/revision-only freeze. No MethodExpr/Core/recognizer/dispatch/public schema/new dependency callback/CI/storage/dependency/other-repository change. Required OS/Perl/Python/prove/mdBook are read-only prerequisites; project data remains repository-local, Gitlinks/nonregular metadata exclude payloads and RGX/PGEN remain black boxes. Whole-family canonical acceptance .1.3.3 and membership/comments/replacement/global audits remain separate.'),
    'rederive': {'status': 'checked', 'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + n
                 for n in ('capture.py before','capture.py after','authority-capture.py before','authority-capture.py after','review.py','freeze.py','book.py --review')),
                 'granularity':'4197 regular inputs/2 compatibility or1 authority overlay per epoch/one owner+one consumer delta/14 commands;16 contracts/3 seeds/87-to147 origins/48 full compiler pairs;RED6-GREEN7/10 suites1180 groups/3 authority groups;58 book inputs19 examples3 chapters;49 prior hashes.',
                 'result': statement},
    'falsify': {'status': 'checked',
                'hypothesis': 'Equal string values, copied returns, lost empty slots, callback reordering or incomplete channels could incorrectly establish original argument authority.',
                'oracle': 'Independent cumulative original fragments/intervals, actual CSV-return refaddr comparison, exact callback/result/error/traversal literals, complete immutable Git and runtime channel/TAP checks.',
                'red_control':'Untouched corrected final regression actually RED6 of7 and producer GREEN7; separate authority fixture RED1 of3 before/GREEN3 after under three seeds.29 reason-specific controls reject per-contract missing origins, forged actual event/constructor/args references, wrong scalar spans/lost callbacks, commands/Git input/unrelated RED stderr and authority proof corruption.18 complete book controls reject.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print(str(len(inputs)) + ' actual producer/artifact bindings')
