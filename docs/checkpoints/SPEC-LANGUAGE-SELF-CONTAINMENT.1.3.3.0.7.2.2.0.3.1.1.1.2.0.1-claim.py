"""Publish the bounded foundation claim with exact retained producer/input bytes."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.1'
PREFIX = 'docs/checkpoints/' + OWNER
review = json.loads((ROOT / (PREFIX + '-review.json')).read_text())
assert review['result'] == 'PASS'
statement = (
    f"The recovered private two-owner foundation passes {review['final_assertions']} fixture assertions "
    f"and {review['effective_source_inverses']} effective reason-sensitive production-source inverses. "
    "An independent labelled-character oracle distinguishes generated, copied, consumed, repeated, Unicode and CRLF pieces. "
    "Actual callback/capture/event/invocation identities, scalar context, argument aliases, opaque results and nested fatal unwind are verified. "
    "The initial draft, ineffective/masked inverse attempts and actual channels remain retained; the recovery claim preserves its original inputs by mode/revision only."
)
sources = [p.as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*')]
sources = [str(Path(p).relative_to(ROOT)) for p in sources]
sources += ['perl/LinkedSpec/ActionIR/SourceOrigins.pm', 'perl/LinkedSpec/ActionIR/SourceEmissions.pm',
            't/actionir_source_emissions.t', 'tools/run_python_project_data.sh', 'tools/project_data_env.sh',
            'tools/project_data_run.sh',
            PREFIX.replace('.0.1', '.0.0') + '-crash.json',
            PREFIX.replace('.0.1', '.0.0') + '-handoff.md',
            'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-plan.json',
            'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0.json']
inputs = [{'path': p, 'sha256': hashlib.sha256((ROOT / p).read_bytes()).hexdigest(),
           'role': 'producer' if p.endswith('.py') else 'input'} for p in sorted(set(sources))]
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'private-emission-foundation', 'statement': statement,
    'scope': 'Standalone private protocol only. Original absent-module RED proves availability; semantic source inverses prove distinguishers. The seven unchanged direct consumers are supplemental guarded live recurrence with complete captured channels and parent input hash superset, reusing standard Perl/core and published dependency outputs. No immutable full Phase0/dependency reproduction, built-in producer integration, mapping, public runtime fix, recurring CI registration, parent repair closeout or cross-host proof is claimed. Later integration and complete acceptance remain .2.1-.2.5, mapping .1.1.2 and independent canonical .0.3.2.',
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + '-proof.py final; bash tools/run_python_project_data.sh ' + PREFIX + '-review.py',
                 'granularity': 'Every original/generated character and copied occurrence, consumed interval, callback result/effect/identity, nested scope, retained source inverse and original claim input.',
                 'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'Equal text or copied objects might grant origin; wrappers might alter callback context/aliases/count/errors; scope and mutable packets might leak authority.',
                'oracle': 'Independently authored cumulative occurrence coordinates and labelled characters; actual reference identities, wantarray, argument aliases, effect counts and exception objects. Valid production-source mutations run the unchanged final fixture in isolated repository-volume supplied trees.',
                'red_control': 'Sixteen actual source inverses reach named failing assertions: registration, invocation identity, callback count/context/aliases, capture/callback/event identity, generated/source/consumed fragments, coordinates, builder validation, packet detachment and nested unwind. Initial inverse failures remain explicitly retained and corrected.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}
}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print('Foundation claim published with', len(inputs), 'exact input bindings.')
