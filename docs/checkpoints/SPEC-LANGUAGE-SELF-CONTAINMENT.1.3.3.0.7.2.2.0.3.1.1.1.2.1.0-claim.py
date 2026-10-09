"""Bind diagnosis producers, actual inputs, observations and selected protocol."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
review = json.loads((ROOT / (PREFIX + 'review.json')).read_text())
assert review['result'] == 'PASS'
actual = json.loads((ROOT / (PREFIX + 'actual.json')).read_text())
sources = set(actual['inputs'])
sources.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*'))
sources.update(['tools/run_python_project_data.sh', 'tools/project_data_env.sh', 'tools/project_data_run.sh',
                'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
                'docs/knowledge/perl-private-input-authority-selection.md',
                'docs/knowledge/perl-private-method-argument-authority.md',
                'docs/claims/REPO-HYGIENE.14.json'])
statement = ('Four actual AST/MethodExpr inputs match eight independently authored original argument intervals. '
             'Seven actual callback modes retain the observed result/context/count/error and identity behavior. '
             'Two actual Contracts dependency interventions distinguish inherited opaque publication from a separately captured dependency, preserving value/order/scalar context. '
             'Seven reason-sensitive evidence RED controls pass; all116 parent Perl/spec production inputs remain unchanged. '
             'The prior cleanup claim changes mode/revision only, with all25 original input hashes verified at476bbd.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'private-input-capture-selection', 'statement': statement,
    'scope': 'Bounded unchanged-production diagnosis/design at476bbd. AST construction identities are observed, not integrated source authority. Empty CSV slots are parser-only observations. The injected controlled future builder is not a production emission producer: nested opaque inheritance is an integration constraint owned by .2.1.3. Guarded live parent Perl/spec superset reuses standard Perl/core and published dependency outputs; no immutable complete Phase0/dependency reproduction, mapped replacement, public runtime fix, recurring CI or canonical admission is claimed. Four selected input children and original six-slice producer obligations remain open.',
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'capture.py; bash tools/run_python_project_data.sh ' + PREFIX + 'review.py',
                 'granularity': 'Each authored argument and actual constructor/callback/returned reference, dependency intervention, full command channel and immutable original cleanup input.', 'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'Public source fields or equal dependency output may transfer private authority; observation may hide copied references, changed original intervals, extra callback effects or forged actual channels.',
                'oracle': 'Authored cumulative piece intervals independent of parser search; retained actual constructor and callback identities; actual nested capture intervention with equal value/order/context.',
                'red_control': 'The actual unguarded dependency route inherits a packet and the captured opaque route declines it with unchanged ordinary effects. Seven named evidence corruptions reject failed exit, forged source hash, missing case, copied root identity, shifted original frame, extra callback and inherited opaque packet.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': [
        {'path': p, 'sha256': hashlib.sha256((ROOT / p).read_bytes()).hexdigest(),
         'role': 'producer' if p.endswith(('.py', '.pl', '.pm', '.sh')) else 'input'} for p in sorted(sources)]}
}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print('Input diagnosis claim:', len(sources), 'retained inputs.')
