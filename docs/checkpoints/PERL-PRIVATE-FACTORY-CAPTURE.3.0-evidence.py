"""Actual reason-sensitive reviewer rejection controls; restore every evidence byte."""
import base64
import copy
import hashlib
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
REVIEW = PREFIX + 'review.py'
TARGET = ROOT / (PREFIX + 'evidence.json')
assert not TARGET.exists(), 'one-shot evidence controls already published'
original = {p.relative_to(ROOT).as_posix(): p.read_bytes()
            for p in sorted((ROOT / 'docs/checkpoints').glob(LEAF + '-*.json'))}
rows = []


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def run():
    result = subprocess.run(['python3', REVIEW], cwd=ROOT,
                            env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    return {'command': ['python3', REVIEW], 'returncode': result.returncode,
            'stdout_base64': base64.b64encode(result.stdout).decode(),
            'stderr_base64': base64.b64encode(result.stderr).decode()}


def control(name, changes, reason):
    try:
        for path, row in changes.items():
            (ROOT / path).write_text(json.dumps(row, indent=2) + '\n')
        result = run()
        result.update(case=name, reason=reason, reviewer_sha256=digest((ROOT / REVIEW).read_bytes()),
                      changes={p: {'before_sha256': digest(original[p]),
                                   'after_base64': base64.b64encode((ROOT / p).read_bytes()).decode()}
                               for p in changes})
        rows.append(result)
        assert result['returncode'] != 0 and reason.encode() in base64.b64decode(result['stderr_base64']), name
    finally:
        for path in changes:
            (ROOT / path).write_bytes(original[path])
        assert all((ROOT / p).read_bytes() == raw for p, raw in original.items())


try:
    positive = json.loads(original[PREFIX + 'fixture.json']); positive['returncode'] = 1
    control('failed-positive', {PREFIX + 'fixture.json': positive}, 'positive method default capture failed')
    consumers = json.loads(original[PREFIX + 'consumers.json'])
    artifact = next(p for p in consumers['inputs'] if p.startswith('docs/checkpoints/') and p.endswith('.json'))
    del consumers['inputs'][artifact]
    control('missing-reader-input', {PREFIX + 'consumers.json': consumers}, 'supplied input population/content mismatch')
    index = json.loads(original[PREFIX + 'inverses.json']); index['rows'].pop()
    control('missing-inverse', {PREFIX + 'inverses.json': index}, 'missing inverse')
    path = PREFIX + 'inverse-native-trim_action_ir_value.json'
    inverse = json.loads(original[path])
    reason = inverse['distinguishing_reason']
    out = base64.b64decode(inverse['stdout_base64'])
    assert reason.encode() in out
    inverse['stdout_base64'] = base64.b64encode(out.replace(reason.encode(), b'unrelated assertion')).decode()
    index = json.loads(original[PREFIX + 'inverses.json'])
    index['rows'][0]['sha256'] = digest((json.dumps(inverse, indent=2) + '\n').encode())
    control('lost-semantic-reason', {path: inverse, PREFIX + 'inverses.json': index}, 'missing distinguishing semantic RED')
    restored = run()
    assert restored['returncode'] == 0
    report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
              'original_inputs': {p: digest(raw) for p, raw in original.items()}, 'rows': rows,
              'restored': restored, 'unchanged': all((ROOT / p).read_bytes() == raw for p, raw in original.items()),
              'scope': 'Four actual reviewer subprocess RED controls with complete counterfactual artifact bytes and actual channels/reasons. Original runtime results are never replaced; all successful evidence bytes restore before final readonly PASS.'}
    TARGET.write_text(json.dumps(report, indent=2) + '\n')
    print('Independent composition evidence PASS4 actual reason-sensitive reviewer REDs/restored PASS')
except BaseException:
    TARGET.write_text(json.dumps({'result': 'incomplete', 'rows': rows,
                                 'producer_sha256': digest(Path(__file__).read_bytes())}, indent=2) + '\n')
    raise
