"""Publish the bounded constructor claim with recoverable exact input closure."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.1'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
review = json.loads((ROOT / (PREFIX + 'review.json')).read_text())
assert review['result'] == 'PASS'
sources = set()
for suffix in ('final', 'consumers', 'toolbox'):
    sources.update(json.loads((ROOT / (PREFIX + suffix + '.json')).read_text())['inputs'])
sources.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*'))
sources.update(['tools/run_python_project_data.sh', 'tools/project_data_env.sh', 'tools/project_data_run.sh',
                'docs/knowledge/perl-private-ast-constructions.md',
                'docs/knowledge/perl-private-input-authority-selection.md',
                'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
                'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0.json'])
sources.add(PREFIX.replace('.1.1-', '.1.0-') + 'actual.json')
statement = ('The standalone AST construction collector passes77 supplied-tree assertions and15 effective semantic source inverses. '
             'Actual capture/callback/returned-root/reachable-node identities, detached descriptions, public AST, argument aliases, callback count/context/error and nested fatal restoration are verified. '
             'An actual lifetime RED exposes snapshot back-edge retention after original cyclic metadata is broken; identity-only aliases fix release, and the restored back-edge fails the same oracle. '
             'The initial74/14 draft and actual producers remain preserved. Ten guarded live consumer suites, three actual public Toolbox lowering routes and eight reason-sensitive evidence RED controls pass; only Parser changes production. '
             'The prior diagnosis claim preserves all134 original inputs at f61130d by mode/revision only.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'standalone-ast-construction-descriptions', 'statement': statement,
    'scope': 'Standalone descriptive construction channel only. It grants no original event/argument source authority and is not integrated with emission producers or mapping. Original absent-interface RED proves availability; actual lifetime RED and semantic source inverses establish behavior. Plain hash/array snapshots compare identity/data; opaque references are retained by identity without inspecting third-party internals. Ten direct consumers are guarded live parent-source recurrence, reusing standard toolchain and published dependency outputs, not immutable full Phase0/dependency reproduction. Original-frame/factory joining, typed builders, packet composition, full Phase0, mapped repair, public runtime fix, recurring CI and independent canonical admission remain open.',
    'rederive': {'status': 'checked',
                 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'proof.py original; bash tools/run_python_project_data.sh ' + PREFIX + 'proof.py cycle; bash tools/run_python_project_data.sh ' + PREFIX + 'proof.py final; bash tools/run_python_project_data.sh ' + PREFIX + 'proof.py consumers; bash tools/run_python_project_data.sh ' + PREFIX + 'toolbox.py; bash tools/run_python_project_data.sh ' + PREFIX + 'review.py',
                 'granularity': 'Every actual constructor/capture/root/child reference and field, authored Unicode occurrence, callback context/alias/effect/error, nested scope, source inverse, actual channels, draft producer and original diagnosis binding.',
                 'result': statement},
    'falsify': {'status': 'checked',
                'hypothesis': 'Equal copies or mutated descendants might inherit construction descriptions; snapshots may retain cyclic graphs after scope exit; collectors may change callback semantics or lose nested restoration; forged channels or incomplete source inputs may hide failures.',
                'oracle': 'Independent cumulative authored occurrence intervals, actual reference identities and weak-reference lifetime observation; public AST equality and callback context/alias/count/error/exception controls; exact supplied source closure and retained actual channels.',
                'red_control': 'Actual old-draft lifetime reproduction fails the release assertion, corrected code passes, and restored snapshot back-edge fails again. Fifteen valid production-source inverses reach named TAP assertion failures. Eight reason-sensitive evidence controls reject failed/truncated/forged final channels/inputs, missing or forged source inverses and failed/incomplete consumers.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': [
        {'path': p, 'sha256': hashlib.sha256((ROOT / p).read_bytes()).hexdigest(),
         'role': 'producer' if p.endswith(('.pm', '.pl', '.py', '.sh', '.t', '.py.txt', '.pm.txt')) else 'input'}
        for p in sorted(sources)]}
}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print('Constructor claim:', len(sources), 'exact retained inputs.')
