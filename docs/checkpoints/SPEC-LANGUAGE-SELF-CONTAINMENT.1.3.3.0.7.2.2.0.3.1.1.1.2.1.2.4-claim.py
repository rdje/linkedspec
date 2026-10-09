"""Bind the actual public empty-span repair and all retained proof producers."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.4'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0-'
assert json.loads((ROOT / (PREFIX + 'review.json')).read_text())['result'] == 'PASS'
sources = set()
for suffix in ('final', 'consumers', 'toolbox'):
    sources.update(json.loads((ROOT / (PREFIX + suffix + '.json')).read_text())['inputs'])
sources.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*'))
sources.update(['tools/run_python_project_data.sh', 'tools/project_data_env.sh', 'tools/project_data_run.sh',
                'docs/knowledge/perl-private-ast-input-frames.md', 'docs/knowledge/perl-empty-ast-trim-span.md',
                'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md', PREVIOUS + 'actual.json',
                'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0.json'])
statement = ('The same supplied65-assertion public facade/native/nonempty fixture fails18 public whitespace assertions on original e0eb with47 controls passing, then final65 GREEN. '
             'A two-line trailing-trim clamp after leading trim restores ordered after-leading zero-width intervals without changing nonempty bodies or native frames. '
             'Four effective semantic source inverses, twelve guarded direct suites, three unchanged actual Toolbox lowering routes and eight reason-sensitive evidence controls pass. '
             'Only AST/Parser production changes; all241 original native-claim bindings remain historical at e0eb by mode/revision only.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'ordered-public-empty-ast-source-intervals', 'statement': statement,
    'scope': 'Bounded public AST empty-span invariant bug fix within the existing expression/statement shapes. The authored empty/undefined/CRLF/Unicode-whitespace cases use bases0,7,23; nonempty Unicode/literal/call/array/body controls use bases0,23. Private frames and existing constructor semantics recur. No new compiler-event authority, output lowering, mapped residual repair, complete Phase0 or canonical admission is claimed. Consumers/Toolbox reuse guarded live sources, the standard toolchain and published dependency outputs; supplied original/final fixture copies retain the exact Perl/spec closure and actual channels.',
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'proof.py original; bash tools/run_python_project_data.sh ' + PREFIX + 'proof.py final; bash tools/run_python_project_data.sh ' + PREFIX + 'proof.py consumers; bash tools/run_python_project_data.sh ' + PREFIX + 'toolbox.py; bash tools/run_python_project_data.sh ' + PREFIX + 'review.py',
                 'granularity': 'Every authored public/native interval, original/final TAP row, semantic source intervention and actual copied producer closure; complete selected consumer commands and three retained Toolbox lowering oracles; every preceding native-claim input.', 'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'The fix may merely reorder endpoints at the wrong anchor, lose base_start, consume nonempty bodies or hide an incomplete/failed/forged evidence route.',
                'oracle': 'Authored leading/body/trailing pieces and Unicode character lengths independently define after-leading empty points and nonempty intervals at explicit bases; full public facade shapes and native frames, plus retained original lowering output.',
                'red_control': 'Original committed source reaches exactly18 actual semantic TAP failures while47 controls pass. Four valid source inverses restore double trimming, use a wrong empty anchor, drop the public base or consume the nonempty body; all reach named semantic failures. Eight evidence corruptions reject failed final/consumer channels, forged inputs/inverse producer, lost original RED, missing inverse/consumer and forged Toolbox output.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': [
        {'path': p, 'sha256': hashlib.sha256((ROOT / p).read_bytes()).hexdigest(),
         'role': 'producer' if p.endswith(('.pm', '.pl', '.py', '.sh', '.t')) else 'input'} for p in sorted(sources)]}
}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print('Empty-span claim:', len(sources), 'retained exact inputs.')
