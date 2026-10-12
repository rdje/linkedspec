"""Readonly evidence review; --capture retains actual corruptions and exact restorations."""
import base64
import gzip
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-'
REPORT = PREFIX + 'review.json'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
pack = lambda raw: {'sha256': sha(raw), 'bytes': len(raw), 'gzip_base64': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}
load = lambda p: json.loads((ROOT / p).read_bytes())
encode = lambda obj: (json.dumps(obj, indent=2) + '\n').encode()
assert sys.argv[1:] in ([], ['--capture'])
target = ROOT / (PREFIX + 'evidence.json')
oracle = ['python3', PREFIX + 'review.py']

def run():
    result = subprocess.run(oracle, cwd=ROOT, capture_output=True)
    return {'command': oracle, 'returncode': result.returncode,
        'stdout_base64': base64.b64encode(result.stdout).decode(),
        'stderr_base64': base64.b64encode(result.stderr).decode()}

def mutations():
    inverse = load(PREFIX + 'inverse-brace-first.json')
    green = load(PREFIX + 'green.json')
    for key in ('returncode', 'stdout_base64', 'stderr_base64'): inverse[key] = green[key]
    consumers = load(PREFIX + 'consumers.json')
    out = base64.b64decode(consumers['stdout_base64'], validate=True)
    original = consumers['command'][3].encode()
    header = re.compile(rb'(?m)^' + re.escape(original) + rb'(?=[ \t]+\.{2,}[ \t]*$)')
    assert len(header.findall(out)) == 1
    consumers['stdout_base64'] = base64.b64encode(header.sub(b't/forged_consumer_name.t', out, count=1)).decode()
    original_path = PREFIX + 'before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6.json'
    original_claim = load(original_path)
    original_claim['claims'][0]['durability']['inputs'][0]['sha256'] = '0' * 64
    original_raw = encode(original_claim)
    preservation = load(PREFIX + 'preservation.json')
    preservation['selected'][0]['sha256'] = sha(original_raw)
    chapter = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
    changed_chapter = (ROOT / chapter).read_bytes() + b'\nUnverified evidence mutation.\n'
    book_review = load(PREFIX + 'book-review.json')
    book_review['source_inputs'][chapter] = sha(changed_chapter)
    native_report_path = PREFIX + 'native-review.json'
    def native_changes(mode, forged):
        path = PREFIX + mode + '-native.json'
        reached_path = PREFIX + mode + '-reached.json'
        record = load(path)
        payload = json.loads(base64.b64decode(record['rows'][0]['stdout_base64'], validate=True))
        payload['callbacks'][0]['value'] = forged
        record['rows'][0]['stdout_base64'] = base64.b64encode((json.dumps(payload, sort_keys=True, separators=(',', ':')) + '\n').encode()).decode()
        reached = load(reached_path)
        reached['rows'] = record['rows']
        raw, reached_raw = encode(record), encode(reached)
        native_report = load(native_report_path)
        native_report['inputs'][path] = sha(raw)
        native_report['inputs'][reached_path] = sha(reached_raw)
        return {path: raw, reached_path: reached_raw, native_report_path: encode(native_report)}
    return [
        ('hidden-inverse-red', {PREFIX + 'inverse-brace-first.json': encode(inverse)}, 'actual distinguishing source failure population'),
        ('forged-consumer-name', {PREFIX + 'consumers.json': encode(consumers)}, 'complete actual consumer header population'),
        ('forged-original-beyond-preservation', {original_path: original_raw, PREFIX + 'preservation.json': encode(preservation)}, 'exact original full publication'),
        ('changed-book-beyond-report', {chapter: changed_chapter, PREFIX + 'book-review.json': encode(book_review)}, 'wrong book input population/content'),
        ('changed-native-beyond-report', native_changes('after', 'FORGED_NATIVE_RESULT'), 'complete native population / sole authority changes'),
        ('changed-recurrence-beyond-report', native_changes('before-recheck', 'FORGED_RECURRENCE_VALUE'), 'complete unchanged-source recurrence bytes'),
    ]

if sys.argv[1:]:
    assert not target.exists(), 'one-shot actual evidence capture'
    healthy = run()
    assert healthy['returncode'] == 0 and not base64.b64decode(healthy['stderr_base64']), 'healthy reviewer before controls'
    rows = []
    for name, changes, reason in mutations():
        original = {p: (ROOT / p).read_bytes() for p in set(changes) | {REPORT}}
        immediate = json.loads(original[REPORT])
        for path, raw in changes.items(): immediate['input_metadata'][path] = sha(raw)
        damaged = dict(changes, **{REPORT: encode(immediate)})
        try:
            for path, raw in damaged.items(): (ROOT / path).write_bytes(raw)
            denied = run()
        finally:
            for path, raw in original.items(): (ROOT / path).write_bytes(raw)
        restored = run()
        row = {'name': name, 'reason': reason,
            'damaged': {p: pack(raw) for p, raw in damaged.items()},
            'original_sha256': {p: sha(raw) for p, raw in original.items()},
            'denied': denied, 'restored': restored}
        rows.append(row)
        reached = {'healthy': healthy, 'rows': rows}
        (ROOT / (PREFIX + 'evidence-reached.json')).write_bytes(encode(reached))
        target.write_bytes(encode({'result': 'pending', **reached}))
        assert denied['returncode'] != 0 and reason.encode() in base64.b64decode(denied['stderr_base64']), ('actual named evidence RED', name)
        assert restored == healthy, ('exact restored reviewer PASS', name)
    report = {'result': 'PASS', **reached,
        'inputs': {p: sha((ROOT / p).read_bytes()) for p in (PREFIX + 'evidence.py', PREFIX + 'review.py', REPORT, PREFIX + 'book-review.py')},
        'scope': 'Six actual record/native/teaching corruptions beyond rehashed immediate report identities; full damaged bytes and separate command channels retained. ROOT is restored in finally before acceptance; no original observation is refreshed.'}
    target.write_bytes(encode(report))
else:
    report = load(PREFIX + 'evidence.json')
    assert report['result'] == 'PASS' and report['healthy']['returncode'] == 0
    assert report['inputs'] == {p: sha((ROOT / p).read_bytes()) for p in (PREFIX + 'evidence.py', PREFIX + 'review.py', REPORT, PREFIX + 'book-review.py')}
    assert len(report['rows']) == 6
    for row, (name, changes, reason) in zip(report['rows'], mutations()):
        assert row['name'] == name and row['reason'] == reason
        immediate = load(REPORT)
        for path, raw in changes.items(): immediate['input_metadata'][path] = sha(raw)
        damaged = dict(changes, **{REPORT: encode(immediate)})
        assert row['damaged'] == {p: pack(raw) for p, raw in damaged.items()}, 'exact retained semantic counterfactual bytes'
        assert row['original_sha256'] == {p: sha((ROOT / p).read_bytes()) for p in damaged}, 'exact current restored files'
        assert row['denied']['command'] == oracle and row['denied']['returncode'] != 0
        assert reason.encode() in base64.b64decode(row['denied']['stderr_base64'], validate=True), 'actual named semantic RED'
        assert row['restored'] == report['healthy'] and not base64.b64decode(row['restored']['stderr_base64'])
print('Formal trim evidence PASS: six semantic REDs beyond immediate hashes and exact restorations')
