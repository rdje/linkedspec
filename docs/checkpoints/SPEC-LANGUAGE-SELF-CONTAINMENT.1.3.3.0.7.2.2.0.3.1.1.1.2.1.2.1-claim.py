"""Bind actual MethodExpr input semantics and the corrected selected consumer proof."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0-'
assert json.loads((ROOT / (PREFIX + 'review.json')).read_text())['result'] == 'PASS'
sources = set()
for suffix in ('final', 'consumers', 'toolbox'):
    sources.update(json.loads((ROOT / (PREFIX + suffix + '.json')).read_text())['inputs'])
sources.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*'))
sources.update(['tools/run_python_project_data.sh', 'tools/project_data_env.sh', 'tools/project_data_run.sh',
                'docs/knowledge/perl-private-method-input-captures.md', 'docs/knowledge/perl-private-method-argument-authority.md',
                'docs/knowledge/perl-private-input-authority-selection.md', 'docs/knowledge/selected-consumer-proof-input-closure-gap.md',
                'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md', PREVIOUS + 'actual.json',
                'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.4.json'])
statement = ('Standalone actual MethodExpr input captures pass107 supplied-tree assertions and13 effective semantic source inverses. '
             'Actual scope/capture/callback/returned value/argument-array/index identities, unchanged root fields and array shape select detached original input frames; direct aliases, scalar once-only calls, caller error, fatal identity and nested unwind stay exact. Legacy wrappers preserve their copied local arguments. '
             'Fourteen selected suites pass in a133-file supplied tree (116 Perl/spec,14 tests,3 actual checkpoint JSON inputs) with unchanged contents/population. Three actual artifact omissions fail their unchanged readers. Three actual Toolbox routes and ten reason-sensitive evidence controls pass. '
             'Only MethodExpr production changes; all239 prior empty-span bindings are preserved historically at8f0c by mode/revision only. Initial invalid syntax and incomplete broader manifest drafts are retained unadmitted.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'actual-methodexpr-input-captures-and-supplied-consumers', 'statement': statement,
    'scope': 'Bounded private standalone parser/CSV input descriptions and exact direct callback compatibility. Original interface RED proves availability only; thirteen final semantic source inverses establish the intended behavior. Selected consumers use only the supplied Perl/spec/test/three-JSON tree; standard read-only Perl/prove modules and project-volume TMPDIR are reused, without immutable toolchain reproduction. Toolbox captures guard live parent Perl/spec sources against retained original lowering values. No compiler-event SourceOrigins grant, source-copy/consumption, output producer/factory integration, mapped residual repair, complete Phase0 or canonical admission. Earlier finite supplemental consumer artifact durability gaps remain immediate P1 .2.1.2.5; original standalone proofs and passing broader observations are not retroactively upgraded. The ordinary book render check does not claim a complete source-bound rendering capsule.',
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'proof.py original; bash tools/run_python_project_data.sh ' + PREFIX + 'proof.py final; bash tools/run_python_project_data.sh ' + PREFIX + 'proof.py consumers; bash tools/run_python_project_data.sh ' + PREFIX + 'toolbox.py; bash tools/run_python_project_data.sh ' + PREFIX + 'artifact-controls.py; bash tools/run_python_project_data.sh ' + PREFIX + 'review.py',
                 'granularity': 'Every authored Unicode/CRLF/repeated/nested/quoted-comma argument interval, actual reference/alias/effect/scope identity, valid semantic inverse and actual supplied input file/content/population. Complete selected consumer commands/channels and each actual missing JSON reader. Every preceding empty-span binding.', 'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'Equal copies, wrong callbacks, changed roots/array shapes/values or foreign scopes may borrow input frames; direct aliases or legacy copied arguments may change; absent transitive artifacts or invalid syntax controls may be mistaken for complete semantic proof.',
                'oracle': 'Independent authored piece/separator cumulative character offsets; actual reference identities and alias effects; unchanged legacy bridge suite; exact supplied133-file population and three independently named JSON-reader edges; original three-route lowering values.',
                'red_control': 'Thirteen final valid source interventions reach named semantic TAP failures, including direct/legacy aliases, callback/array/capture/root/shape/value identity, detached frames and scoped unwind. Actual omission of each of three checkpoint JSON inputs fails its unchanged reader. Ten reason-sensitive record corruptions reject failed/forged/incomplete final/original/inverse/consumer/Toolbox/artifact evidence. Initial invalid syntax inverse and broader draft manifest remain rejected, retained and explicitly disclosed.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': [
        {'path': p, 'sha256': hashlib.sha256((ROOT / p).read_bytes()).hexdigest(),
         'role': 'producer' if p.endswith(('.pm', '.pl', '.py', '.sh', '.t')) else 'input'} for p in sorted(sources)]}
}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print('MethodExpr input claim:', len(sources), 'retained exact inputs.')
