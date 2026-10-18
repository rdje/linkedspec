"""Readonly output-family publication; --capture writes its claim once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.4/'
TARGET = ROOT / 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.4.json'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for name in ('review.py', 'evidence.py', 'group-review.py'):
    result = subprocess.run(['python3', PREFIX + name], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, (name, result.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS'
population = review['population']
assert tuple(population[k] for k in ('required_validators', 'required_roles', 'warm_rows', 'cold_rows',
    'paired_assertions', 'original_red', 'passing_controls', 'source_faults', 'consumer_suites',
    'consumer_inputs', 'consumer_assertions', 'knowledge_bytes')) == (
    4, 6, 234, 198, 1146, 264, 882, 13, 87, 332, 27762, 8388501)
paths = set(review['inputs']) | set(evidence['inputs']) | {
    PREFIX + n for n in ('review.json', 'evidence.py', 'evidence.json', 'evidence-data.json.gz',
        'evidence-baseline.json', 'compat.json', 'publish.py')}
def binding(path, role=None):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    return {'path': path, 'sha256': sha(source.read_bytes()),
            'role': role or ('producer' if source.suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input')}
inputs = [binding(p) for p in sorted(paths)]
statement = (
    'Four original ControlFlow required-validator returns isolate six output-helper roles: method '
    'parser in say/print/print_each/exit_now, plus print_each trim and array-symbol extraction. The '
    'helper, algorithms, generated text and line count remain unchanged. All432 ordinary native rows '
    '(234 warm/198 cold),1240 observed scalar calls, actual references/maps, argument aliases, values, '
    'effects/errors/fatal identities, rule labels, legacy call forms and cold loading remain exact '
    'with byte-identical recurrences. Identical1146 assertions retain264 original authority REDs/'
    '882 controls and all GREEN. Opaque callbacks cannot donate a parent packet; registered matching '
    'scalar trim/extractor returns may retain only their own packet, while parser hashes cannot. '
    'Thirteen complete-source faults reject, including the exact264-failure inverse and four '
    'individual validator inverses. All87 supplied suites/332 inputs/27762 top-level assertions pass '
    'with predecessor85 headers/plans/stderr unchanged. Dedicated public diagnostic before/after '
    'captures supply329 inputs and16 top-level assertions each, covering native/generated/CLI '
    'events, quietness, typed exit, error identity, arity and ordered effects. Nine coherent artifact '
    'denials/restorations, full Knowledge1486 Markdown/1349 facts/twelve overlays/8388501 bytes, '
    'full book89/four actual source/render controls, public guard and standard public Phase01035 '
    'pass. Whole prior480-input/111654-byte publication and actual baseline remain historical at '
    '4a8e92aef. Optional kind, direct/rule calls, mixed defaults, fixture registration and pipeline '
    'activation remain open; no broader admission is claimed.')
claim = {
    'name': 'controlflow-output-required-callback-capture', 'statement': statement,
    'scope': 'Only four validator return lines change; all22 required validators now use the existing '
        'helper. Native controlled dependencies delegate actual MethodExpr parsing but are not facade '
        'execution; the separate diagnostic suite supplies public coverage. The original inventory '
        'guard rejects duplicate exit_now_zero before callback execution; complete source/inputs/'
        'channels remain frozen and the successful instrument changes exactly that label. Source '
        'faults cover observed witnesses, not exhaustive per-role mutations or every injection. '
        'Whole original/current Knowledge custody is retained; eleven card bodies remain unchanged. '
        'System Perl/stdlib/mdBook are read-only dependencies without portable immutable toolchain '
        'claims. Standard/public guard are supplemental without complete transitive input capsules. '
        'The separately disclosed managed-wrapper observation is not compiler or lifecycle admission.',
    'rederive': {
        'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py (readonly default). '
            'review.py, evidence.py, book-review.py, validation.py and group-review.py are readonly '
            'by default. Native/paired/diagnostic/consumer/Knowledge/book/source-fault/standard capture '
            'writers are retired one-shot instruments.',
        'granularity': 'Every105/110-input native capture and234/198 row; full1146 TAP/264 original '
            'RED/882 controls; each13 complete source variants and exact inverse;87 ordered suites/'
            '332 inputs/27762 top-level assertions; public diagnostic before/after329 inputs/16 top-level '
            'assertions; all480 prior bindings/full111654 bytes and actual baseline; full Knowledge/book '
            'populations and nine coherent artifact controls.',
        'result': statement,
    },
    'falsify': {
        'status': 'checked',
        'hypothesis': 'Required callbacks could borrow outer identity or donate equal-text publication, '
            'lose their own matching packet, copy aliases, reselect/mutate dependency maps, repeat '
            'effects, localize errors, disable required validation or eagerly load the private channel. '
            'Rehashed artifacts could conceal changed native slots, packets, inverse failures, prior '
            'publications, suite population, rendered teaching or runtime paths.',
        'oracle': 'First successful native ordinary ledger and independently checked accepted Git '
            'source; unchanged paired fixture checks actual identity/eligibility and parent/child '
            'packets separately. Independent source reconstruction retains every complete variant, '
            'the exact original264-failure inverse, predecessor ordered suites and public diagnostic '
            'before/after channels. Fixed Git claim census and independently enumerated/rendered '
            'book/source populations distinguish the artifact controls.',
        'red_control': 'Before264 of1146 fail and882 controls pass; afterward all1146 pass. Thirteen '
            'syntax-valid complete-source variants fail264,57,48,108,51,228,238,408,672,2,36,410,24 '
            'assertions with full plans. Nine coherently rehashed artifacts reject native alias loss, '
            'parent donation, matching child-packet loss, hidden inverse failure, altered whole prior '
            'claim, forged consumer header, missing rendered parser/trim teaching or wrong runtime '
            'path, then restore exact bytes/modes and PASS. Book controls retain missing SUMMARY, '
            'two absent rendered markers and a missing recursive include.',
    },
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs},
}
sample = json.loads((ROOT / (PREFIX + 'group-observation.json')).read_bytes())
kernel = {
    'name': 'historical-managed-wrapper-warning-sample',
    'statement': 'The actual standard launch reports child29169 setpgid/Operation not permitted; one '
        'subsequent os.getpgid(29169) observation returns29169 at the recorded time. No timing cause, '
        'target start-time identity, general establishment/lifecycle or cleanup guarantee follows.',
    'scope': 'One changing-runtime numeric PID/PGID sample, not a current liveness or causality claim. '
        'The known warning and repair remain under SESSION-STARTUP-READING.7. No wrapper source, '
        'recovery or purge changes occur. Raw launch output and the exact executed producer are '
        'retained as encoded/inert data; historical PIDs must not be rerun as current identities.',
    'rederive': {'status': 'checked',
        'command': 'Original one-shot group-observation.py via tools/run_python_project_data.sh; '
            'complete executed source is recoverable from group-observation-source.json.gz. '
            'Readonly custody: bash tools/run_python_project_data.sh ' + PREFIX + 'group-review.py.',
        'granularity': 'One actual launch warning and one kernel API result at ' + sample['observed_at'],
        'result': 'Observed numeric PID29169/PGID29169; actual warning/result and source bytes/hash/mode retained.'},
    'falsify': {'status': 'gap',
        'reason': 'No contemporaneous independent target start-time/group oracle or distinguishing '
            'kernel failure control was captured. The sample cannot establish the warning cause, '
            'process identity across time, general group establishment, lifecycle safety or cleanup '
            'authority; those questions remain with the existing scheduled repair.',
        'repair_owner': 'SESSION-STARTUP-READING.7'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': [
        binding(PREFIX + n, 'producer' if n == 'group-observation-source.json.gz' else None)
        for n in ('group-observation-source.json.gz', 'group-observation.json', 'group-review.py')
    ] + [binding(p) for p in ('tools/project_data_run.sh', 'tools/project_data_env.sh',
                             'tools/run_python_project_data.sh')]},
}
record = {'version': 1, 'owner': 'PERL-PRIVATE-FACTORY-CAPTURE.5.4', 'claims': [claim, kernel]}
value = (json.dumps(record, indent=2) + '\n').encode()
assert len(value) <= 131072
if sys.argv[1:]:
    with TARGET.open('xb') as output:
        output.write(value)
else:
    assert TARGET.read_bytes() == value
print('ControlFlow output publication PASS:', len(inputs), 'compiler inputs;', len(value), 'bytes; kernel gap: startup.7')
