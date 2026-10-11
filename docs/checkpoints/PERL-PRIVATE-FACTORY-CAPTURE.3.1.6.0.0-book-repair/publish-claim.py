"""Publish once, or readonly reconstruct, the bounded final composed claim."""
import base64
import copy
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
CARDS = {'docs/knowledge/perl-receiver-copy-book-prerequisite.md',
         'docs/knowledge/aggregate-selector-public-admission.md',
         'tools/check_executable_aggregate_selector_sources.py',
         'tests/language-readiness/verify_objectives.py'}
digest = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--extend-census'])
result = subprocess.run(['bash', 'tools/run_python_project_data.sh',
    (HERE / 'review.py').relative_to(ROOT).as_posix()], cwd=ROOT, capture_output=True)
assert result.returncode == 0, result.stderr.decode()
review = json.loads((HERE / 'review-final.json').read_bytes())
assert review['result'] == 'PASS' and review['producer_sha256'] == digest((HERE / 'review.py').read_bytes())
failed = json.loads(gzip.decompress((HERE / 'before.json.gz').read_bytes()))
original = json.loads(base64.b64decode(failed['claim']['data'], validate=True))
boundary = json.loads(gzip.decompress((HERE / 'census/before.json.gz').read_bytes()))
initial_bytes = base64.b64decode(boundary['claim_base64'], validate=True)
assert digest(initial_bytes) == boundary['claim_sha256']
initial = json.loads(initial_bytes)
census = json.loads(gzip.decompress((HERE / 'census/proof.json.gz').read_bytes()))
assert census['result'] == 'PASS'
paths = set(review['checked']) | CARDS
paths.update(p.relative_to(ROOT).as_posix() for p in HERE.rglob('*') if p.is_file())
for path in census['inputs']:
    tracked = subprocess.run(['git', 'ls-files', '--error-unmatch', '--', path], cwd=ROOT, capture_output=True)
    if tracked.returncode:
        assert path == 'rgx/README.md', 'unowned public input'
        # Its complete read-only published document bytes remain retained/gated in the capsule.
    else:
        paths.add(path)
inputs = [{'path': path, 'sha256': digest((ROOT / path).read_bytes()),
           'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'}
          for path in sorted(paths)]
for path,sha in review['checked'].items():
    assert digest((ROOT / path).read_bytes()) == sha, 'composed input drift: ' + path
runtime = original['claims'][0]
ci = original['claims'][2]
core = copy.deepcopy(runtime)
core['name'] = 'scalar-copy-runtime-ci-book-composition'
core['statement'] = runtime['statement'] + ' ' + ci['statement'] + (' Current admission additionally corrects one synthetic AST book example, retains four valid rejected examples in public70/40/0, and registers17 exact diagnostic files with27 lines and51 strict denial controls. Original502-binding and initial521-binding book publications replay from exact recoverable inputs. Current complete book89/3 and isolated historical183-input/22-recovery/80-evolution proof pass; only explicitly verified documentation/count/registry/auditor source deltas differ from original proof inputs.')
core['scope'] = ('Scalar-bound single-step receiver copy and explicit canonical regression wiring, preserving the original50 assertion/native14-case/source-fault/61-suite evidence and original historical CI proof. The original full book/publications replay against retained failed03 inputs; the initial book composition also replays against every521 declaration/506 files. Current runtime sources remain exact. Current public census changes only expected36 to40, with complete retained70 public files/69 parent historical files and exact four rejected-example additions. The scanner adds only17 exact path/full-byte diagnostic entries; no directory exemption or classifier change. Current book and count projections are source-bound separately. RGX published README is read-only with0 current references; historical submodule bytes and external OS/toolchain recovery are not claimed. Exact canonical receipt independently governs landing.')
core['rederive'] = {'status': 'checked',
 'command': 'bash tools/run_python_project_data.sh docs/checkpoints/' + LEAF + '-book-repair/review.py; separately book-repair/publish-claim.py under that wrapper. Defaults readonly. Original and initial compositions replay via replay.py and census/replay-first.py; all capture/publication writers are one-shot.',
 'granularity': runtime['rederive']['granularity'] + ' ' + ci['rederive']['granularity'] + ' Additionally all original/current identities, complete prior-stage replays, current89 book sources/includes/three render controls, current70 public document bytes and69 historical parent sources, exact3+1 rejected-reference additions, unchanged migration11, three actual census source-fault denials, and all17 exact registry inputs/51 copied-edited-added-selector denials.',
 'result': core['statement']}
core['falsify']['hypothesis'] += ' ' + ci['falsify']['hypothesis'] + ' An unclassified authored example, stale census, missing rejected reference or broad diagnostic exemption can conceal selector drift.'
core['falsify']['oracle'] += ' ' + ci['falsify']['oracle'] + ' Existing unchanged public classifier and complete historical/current document populations, exact constant-only count evolution and exact path/full-byte scanner registry.'
core['falsify']['red_control'] += ' ' + ci['falsify']['red_control'] + ' Original private-example text and its inverse reject. Original36 count rejects actual40; removing a classified reference rejects39; adding unclassified source rejects. Original scanner27 positives become classified only for17 exact inputs; all51 copied, edited and added-selector variants reject and restoration passes.'
core['durability'] = {'status': 'checked', 'mode': 'live', 'inputs': inputs}
historical = copy.deepcopy(original['claims'][1])
assert historical == initial['claims'][1], 'accepted regex preservation changed'
data = {'version': 1, 'owner': LEAF, 'claims': [core, historical]}
serialized = (json.dumps(data, indent=2) + '\n').encode()
assert len(serialized) <= 131072, ('claim exceeds bounded size', len(serialized))
if sys.argv[1:]:
    assert TARGET.read_bytes() == initial_bytes, 'one-shot final census extension'
    TARGET.write_bytes(serialized)
else:
    assert TARGET.read_bytes() == serialized, 'final publication drift'
print('Final receiver-copy publication PASS:', len(inputs), 'distinct live inputs;', len(serialized), 'bytes; original502/initial521 claims retained; historical regex claim exact')
