"""Publish the bounded producer diagnosis and preserve its source closure."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-'
OWNER = PREFIX.removeprefix('docs/checkpoints/').removesuffix('-')
BASE = '997f1cb8f32ff4eaa1ba278e124cbaaac1942780'

def sha(raw):
    return hashlib.sha256(raw).hexdigest()

def data(suffix):
    return json.loads((ROOT / (PREFIX + suffix)).read_bytes())

verified = data('verification.json')
assert verified['complete'] and verified['revision'] == BASE
assert verified['producer_sha256'] == sha((ROOT / (PREFIX + 'review.py')).read_bytes())
assert all(control['observed'] == 'RED' for control in verified['controls'])
preparation = data('preparation-verification.json')
assert preparation['complete'] and preparation['revision'] == BASE
assert preparation['original_claim_exact'] and preparation['real_index_unchanged']
assert preparation['producer_sha256'] == sha((ROOT / (PREFIX + 'preparation-review.py')).read_bytes())
plan = data('plan.json')
assert plan['status'] == 'selected design; production unmodified; transfer protocol unimplemented and unverified'
for path, digest in plan['bounded_owners'].items():
    raw = (ROOT / path).read_bytes()
    assert sha(raw) == digest
    assert raw == subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT), path
freeze = data('freeze.json')
assert freeze['revision'] == BASE
assert freeze['producer_sha256'] == sha((ROOT / (PREFIX + 'preserve.py')).read_bytes())
for entry in freeze['records']:
    original = (ROOT / entry['before']).read_bytes()
    assert sha(original) == entry['original_sha256']
    expected = json.loads(original)
    count = 0
    for claim in expected['claims']:
        durability = claim['durability']
        if durability.get('mode') != 'live':
            continue
        for item in durability['inputs']:
            raw = subprocess.check_output(['git', 'show', BASE + ':' + item['path']], cwd=ROOT)
            assert sha(raw) == item['sha256'], item['path']
            count += 1
        durability.update(mode='historical', revision=BASE)
    assert count == entry['verified_bindings']
    assert json.loads((ROOT / entry['path']).read_bytes()) == expected
    assert sha((ROOT / entry['path']).read_bytes()) == entry['after_sha256']

statement = (str(verified['actual_commands']) + ' actual guarded original/candidate commands under three hash seeds '
    'recover from four complete ' + str(verified['regular_git_inputs']) + '-input regular Git supplied graphs. '
    + str(verified['authored_typed_cases']) + ' typed/literal and ' + str(verified['authored_raw_cases']) +
    ' raw compatibility sources distinguish retained capture/mark/entry-named/raw continuations from consumed '
    'typed entry groups. Authored cumulative occurrence pieces, actual callback arguments/scalar context/error '
    'effects, parser argument references/frames and complete Toolbox channels pass independent review with '
    + str(len(verified['controls'])) + ' effective evidence/authority RED controls. Original production remains '
    'unchanged. The selected output-emission and callback-identity protocol is unimplemented and unverified. '
    'The initial seven-owner declaration rejection retains its exact staged delta and every original claim/input identity; pending nodes use planning metadata.')
scope = ('Bounded diagnosis and future repair selection, not production GREEN, generated-output transfer acceptance, '
    'arbitrary opaque-callback proof, full Phase0, readiness, other-backend or global audit closure. Raw compatibility '
    'probes measure substitution/AST/producer paths only, not reference-value execution. Typed group [null] is a '
    'nullable baseline, not a non-null result promise. Literal replacement/readiness retain separate existing '
    'owners. Complete ordinary/emitted/native/fresh typed channels and original rejected-candidate channels remain '
    'distinct. The exact full regular supplied superset is recoverable from immutable Git blobs/modes plus '
    'declared authored overlays; gitlinks and nonregular payloads are excluded without inspection. Necessary '
    'read-only OS/Perl/Python/Git standard-library prerequisites are external; no cross-host reproducibility claim '
    'is made. Every project-owned output remains repository-volume rooted. Existing public book teaching remains '
    'accurate and unchanged. Future actual producer RED/GREEN, source inverses, adversarial callback/nested/literal '
    'controls, complete Phase0/direct consumers and independent canonical replacement admission remain required. '
    'The exact initial declaration failure is an unadmitted preparation, independently recovered with an isolated same-volume index/object store while preserving the real index.')
paths = [path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/checkpoints').glob(Path(PREFIX).name + '*') if path.is_file()]
paths += list(plan['bounded_owners'])
paths += ['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1-pipeline-candidate.pm',
    'tools/run_python_project_data.sh', 'tools/project_data_env.sh', 'tools/project_data_run.sh',
    'tools/check_task_verification_fields.pl',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
    'docs/knowledge/perl-residual-lowering-producer-selection.md',
    'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'MEMORY.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'docs/TASK_TREE.md', 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md', 'ROADMAP.md', 'ROADMAP_V2.md']
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
           'role': 'producer' if path.endswith(('.py', '.pl', '.pm', '.sh')) else 'input'} for path in sorted(set(paths))]
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'actual-typed-and-raw-producer-diagnosis', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'capture.py; bash tools/run_python_project_data.sh '
            + PREFIX + 'raw-capture.py; bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; '
            'bash tools/run_python_project_data.sh ' + PREFIX + 'preserve.py; bash tools/run_python_project_data.sh '
            + PREFIX + 'preparation-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'claim.py',
        'granularity': 'Each full supplied Git input/mode/hash, declared overlay, actual command/exits/full channels; '
            'each authored helper occurrence, parser frame/reference and reached scalar callback; original/candidate '
            'typed/native/fresh or raw-substitution population; original prior-claim hashes. Future protocol is explicitly pending.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'An enclosing edit may appear to consume every nested helper; counts alone or equal text may conceal lost genuine continuations or literal rewrites.',
        'oracle': 'Independent authored cumulative source pieces; actual original callback/output/event origins and '
            'parser frames; known healthy typed consumption; separately retained rejected candidate and native/fresh or raw continuation RED.',
        'red_control': 'Ten actual reason-sensitive mutations reject incomplete capture, lost epoch, failed command, '
            'missing source guard, wrong seed, forged stdout, hidden canonical origin, forged argument boundary, '
            'changed callback context and changed callback input. The actual rejected source loses capture/mark/'
            'entry-named/raw continuations while typed entry-group consumption stays healthy.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}]}
target = ROOT / 'docs/claims' / (OWNER + '.json')
target.write_text(json.dumps(record, indent=2) + '\n')
assert target.stat().st_size <= 131072
print(statement)
