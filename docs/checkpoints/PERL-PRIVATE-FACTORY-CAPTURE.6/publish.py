"""Readonly source-bound pipeline publication; --capture creates its bounded claim once."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.6'
sha = lambda value: hashlib.sha256(value).hexdigest()
assert sys.argv[1:] in ([], ['--capture'], ['--preflight'])
for name in ('review-current.py', 'evidence-final.py'):
    run = subprocess.run(['python3', PREFIX + name], cwd=ROOT, capture_output=True)
    assert run.returncode == 0 and not run.stderr, ('actual readonly source review', name, run.stdout, run.stderr)
review = json.loads((ROOT / (PREFIX + 'current-review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence-final.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['controls']) == 8
population = review['population']
assert population['original_claim_inputs'] == 603 and population['original_claim_bytes'] == 115985
assert population['supplied_inputs'] == 426 and population['focused_assertions'] == 2065
assert population['semantic_inverses'] == 13 and population['direct_suites'] == 91
assert population['direct_assertions'] == 32235 and population['knowledge_bytes'] == 8384111
assert population['markdown'] == 1487 and population['current_routes'] == 15
assert population['book_inputs'] == 89 and population['render_controls'] == 4
paths = set(review['inputs']) | set(evidence['inputs'])
paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / PREFIX).iterdir()
             if path.is_file() and path.name not in ('publication-preflight.json', 'continuity.json'))
source_suffixes = {'.py', '.pm', '.pl', '.t', '.sh'}
bindings, modes = [], {}
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    bindings.append(dict(path=path, sha256=sha(source.read_bytes()),
                         role='producer' if source.suffix in source_suffixes else 'input'))
    modes[path] = source.stat().st_mode & 0o7777
claim = dict(
    name='pipeline-invocation-scopes-and-actual-callback-captures',
    statement='RewritePipeline opens producer/input scopes inside its original-source invocation before '
        'factories. Four actual dependency callbacks and canonical apply have separate scalar frames. '
        'Native96 and distinct9-row callable/load-context epochs preserve observed values, aliases, '
        'contexts, references, ordering, errors and release effects. Complete supplied426-input proof '
        'passes2065 assertions,13 exact syntax-valid semantic inverses with the same2065 plan and91 '
        'direct suites/32235 assertions. Public native return_general callback/origin/registry identities '
        'match. Whole603-input/115985-byte predecessor and actual baseline remain historical at64b66167c. '
        'Dated full Knowledge1487/1349 facts/10448 keys/15 routes/two bodies/8384111 bytes and book89/four '
        'render controls pass; eight artifact denials retain exact restoration.',
    scope='Only RewritePipeline production code and its already selected factory regression suite change. '
        'No canonical selector or new public DSL/schema/map/reference/replacement/family-order change. '
        'Actual CODE is captured by identity; other native callables stay opaque at original line489 '
        'with one lookup and call-local lifetime. Same-token opaque donation and nested equal-source '
        'success/fatal restoration are separately tested. Current native lowerers still return ordinary '
        'text: typed/raw output construction, packet composition, interval mapping, quoted-first repair, '
        'complete private Phase0 and independent parent/canonical admission retain separate owners. '
        'Knowledge reverify gates the captured full snapshot plus current15 overlays/map/config; other '
        'captured Markdown stays historical at64b66167c. All raw native/failed instrument epochs and '
        'uncommitted source identities remain distinct; expected-only owned filename projection does '
        'not normalize actual errors. Two direct early GREEN checks retain merged channels and disclosed '
        'post-run custody; the final supplied proof has pre-run inputs/separate channels. First two '
        'artifact controls retain their original actor; the finisher runs only six. The original initial '
        'artifact-baseline variable was not serialized; its actual second restoration supplies the '
        'healthy baseline. Host tools are reused read-only; no immutable host/dependency, minimal IO, '
        'arbitrary-shell, copied-root/liveness/recovery/purge or warning-zero claim.',
    rederive=dict(status='checked',
        command='bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py (readonly). '
            'review-current.py independently gates whole custody, exact runtime source inverses/coherent '
            'TAP and rendered semantics; evidence-final.py checks complete actual artifact controls. '
            'All native/capture/repair/preparation writers are retired.',
        granularity='Whole603/full115985 and every original binding/mode; native96 plus three distinct9-row '
            'epochs and actual before-import include observations; original missing-plan and all valid '
            'RED/reader failures;2065/13 exact source inverses in426 inputs;91 suites/32235; one actual '
            'native public callback;1487 captured Markdown/15 originals/13 exact bodies;89 book inputs/four '
            'render controls; eight actual artifact denials with original first-two actors.',
        result='All declared scoped checks PASS; ordinary focused history/Knowledge/memory/public-surface '
            'and all normal doctrine hooks govern landing.'),
    falsify=dict(status='checked',
        hypothesis='Equivalent strings or public IDs could lend private authority, green statuses could '
            'hide missing captures/work, or coherent hashes could relabel an original observation, '
            'source inverse, Knowledge population or rendered semantics.',
        oracle='Actual selected callback/event/rule references and SourceOrigins tokens, independently '
            'authored Unicode argument intervals, actual native context/alias/error/release ledgers, '
            'same-token real opaque publication and nested parent builder restoration, exact source '
            'recipes, complete ordered TAP and direct-suite population, accepted Git whole-claim '
            'identity and prior-capture native anchors, rendered tables derived from measured populations.',
        red_control='Pre-production fixed-plan1988/1128 semantic RED;13 syntax-valid source inverses each '
            'retain complete2065 TAP and a named semantic failure; eight whole-byte/mode artifact '
            'forgeries reject with named reasons and exact restored PASS. Book controls remove SUMMARY, '
            'each rendered marker or a recursive include. All failed reason/context/instrument '
            'calibrations stay retained with exact sources, channels and distinct corrections.'),
    durability=dict(status='checked', mode='live', inputs=bindings),
)
value = (json.dumps(dict(version=1, owner=LEAF, claims=[claim]), indent=1) + '\n').encode()
target = ROOT / ('docs/claims/' + LEAF + '.json')
if sys.argv[1:] == ['--preflight']:
    print(json.dumps(dict(result='PASS' if len(value) <= 131072 else 'OVER_CAP', bytes=len(value),
                         input_count=len(bindings), draft_sha256=sha(value),
                         draft_base64=base64.b64encode(value).decode(), input_modes=modes,
                         producer_sha256=sha(Path(__file__).read_bytes()),
                         scope='Pure complete logical draft before claim creation; no publication input '
                               'or observation is changed. This is an actual serialized preflight, not '
                               'a claimed Git revision for an uncommitted draft.'), indent=1))
    raise SystemExit(0 if len(value) <= 131072 else 1)
assert len(value) <= 131072, (len(value), len(bindings))
if sys.argv[1:]:
    with target.open('xb') as output: output.write(value)
else: assert target.read_bytes() == value
print('Pipeline invocation publication PASS:', len(bindings), 'live inputs;', len(value), 'bytes')
