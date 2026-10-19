"""Retain/recover the complete667 draft and correct its unexecuted continuity writer."""
import ast
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/pipeline-scope/'
SELF = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-continuity-repair.py'
RECORD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-continuity-repair.json.gz'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.6.json'
FINALIZER = PREFIX + 'finalize-continuity.py'
PUBLISHER = PREFIX + 'publish.py'
sys.path.insert(0, str(ROOT / PREFIX))
from common_final import load, encode, decode

sha = lambda value: hashlib.sha256(value).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
if sys.argv[1:]:
    target = ROOT / RECORD
    assert not target.exists()
    claim_raw = (ROOT / CLAIM).read_bytes()
    claim = json.loads(claim_raw)
    bindings = claim['claims'][0]['durability']['inputs']
    assert len(bindings) == 667 and len(claim_raw) == 111477
    preflight = (ROOT / (PREFIX + 'publication-preflight.json')).read_bytes()
    assert decode(json.loads(preflight)['draft_base64']) == claim_raw
    inputs = {}
    for item in bindings:
        source = ROOT / item['path']
        value = source.read_bytes()
        assert sha(value) == item['sha256']
        inputs[item['path']] = dict(sha256=sha(value), mode=source.stat().st_mode & 0o7777)
    before = {path: (ROOT / path).read_bytes() for path in (FINALIZER, PUBLISHER)}
    command = ['python3', PUBLISHER]
    baseline = subprocess.run(command, cwd=ROOT, capture_output=True)
    assert baseline.returncode == 0 and not baseline.stderr
    assert baseline.stdout == b'Current pipeline publication PASS: 667 live inputs; 111477 bytes; original625+161 supplied\n'
    for path, item in inputs.items():
        assert sha((ROOT / path).read_bytes()) == item['sha256']
        assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
    needle = b"    PREFIX + 'publish.py before bound metadata/Knowledge/book changes. Continue TYPE-REFERENCE-BOOK '\n"
    assert before[FINALIZER].count(needle) == 1
    after_finalizer = before[FINALIZER].replace(needle, b'    + ' + needle[4:])
    publisher = before[PUBLISHER]
    needle = b"for name in ('review.py', 'complete-replay.py', 'controls.py'):\n"
    assert publisher.count(needle) == 1
    addition = ("repair = subprocess.run(['python3', " + repr(SELF) + "], cwd=ROOT, capture_output=True)\n"
                "assert repair.returncode == 0 and not repair.stderr, ('continuity source custody', repair.stdout, repair.stderr)\n")
    publisher = publisher.replace(needle, addition.encode() + needle)
    needle = b"              'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.7.json'])\n"
    assert publisher.count(needle) == 1
    publisher = publisher.replace(needle,
        ("              'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.7.json',\n              " +
         repr(SELF) + ",\n              " + repr(RECORD) + "])\n").encode())
    needle = b"        'Observed wrapper warnings remain disclosed under SESSION-STARTUP-READING.7; no minimal IO, '\n"
    assert publisher.count(needle) == 1
    publisher = publisher.replace(needle,
        b"        'The complete667 draft, actual readonly baseline and AST failure of its unexecuted '\n"
        b"        'continuity writer remain losslessly recoverable through current unchanged inputs plus '\n"
        b"        'both retained before source byte streams. A one-operator repair changes no measurement. '\n" + needle)
    ast.parse(after_finalizer, filename=FINALIZER)
    ast.parse(publisher, filename=PUBLISHER)
    failure_path = '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.6-transport-syntax-attempt1.log'
    failure = (ROOT / failure_path).read_bytes()
    assert b'SyntaxError' in failure and b'line 91' in failure and FINALIZER.encode() in failure
    record = dict(version=1, result='PASS', claim_base64=encode(claim_raw), claim_sha256=sha(claim_raw),
        preflight_base64=encode(preflight), inputs=inputs,
        before_sources={path: encode(value) for path, value in before.items()},
        after_sources={FINALIZER: encode(after_finalizer), PUBLISHER: encode(publisher)},
        producer_base64=encode(Path(__file__).read_bytes()),
        baseline=dict(command=command, returncode=baseline.returncode,
            stdout_base64=encode(baseline.stdout), stderr_base64=encode(baseline.stderr)),
        syntax_failure=dict(path=failure_path, base64=encode(failure), sha256=sha(failure)),
        scope='Complete uncommitted667 draft before two source changes: whole claim/preflight and '
              'all actual input hashes/modes, exact before/after finalizer/publisher bytes and actual '
              'readonly baseline. Every other665 before byte stream is identical to an explicitly '
              'gated current input; the reader recovers and checks every before byte without '
              'inventing a Git revision. No native/runtime/documentation observation is refreshed. '
              'Only an unexecuted continuity expression and publication repair registration change. '
              'The prior625 target is restored only after this whole667 draft is recoverable.')
    with target.open('xb') as output:
        output.write(gzip.compress(json.dumps(record, sort_keys=True).encode(), mtime=0))
    (ROOT / FINALIZER).write_bytes(after_finalizer)
    (ROOT / PUBLISHER).write_bytes(publisher)
    (ROOT / CLAIM).write_bytes(decode(load()['claim_base64']))

record = json.loads(gzip.decompress((ROOT / RECORD).read_bytes()))
assert record['result'] == 'PASS' and decode(record['producer_base64']) == Path(__file__).read_bytes()
claim_raw = decode(record['claim_base64'])
assert sha(claim_raw) == record['claim_sha256'] and len(claim_raw) == 111477
bindings = json.loads(claim_raw)['claims'][0]['durability']['inputs']
assert len(bindings) == len(record['inputs']) == 667
assert decode(json.loads(decode(record['preflight_base64']))['draft_base64']) == claim_raw
for item in bindings:
    path = item['path']
    before = decode(record['before_sources'][path]) if path in record['before_sources'] else (ROOT / path).read_bytes()
    assert sha(before) == item['sha256'] == record['inputs'][path]['sha256'], ('complete667 before bytes', path)
    assert (ROOT / path).stat().st_mode & 0o7777 == record['inputs'][path]['mode']
for path, value in record['after_sources'].items():
    assert (ROOT / path).read_bytes() == decode(value)
    ast.parse(decode(value), filename=path)
baseline = record['baseline']
assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64']) == b'Current pipeline publication PASS: 667 live inputs; 111477 bytes; original625+161 supplied\n'
assert sha(decode(record['syntax_failure']['base64'])) == record['syntax_failure']['sha256']
print('Continuity preparation correction PASS:whole667/full111477 recovered; original sources/failure retained')
