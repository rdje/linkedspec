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
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5-'
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
    inverse = load(PREFIX + 'inverse-pipeline.json')
    green = load(PREFIX + 'green.json')
    for key in ('returncode', 'stdout_base64', 'stderr_base64'): inverse[key] = green[key]
    consumers = load(PREFIX + 'consumers.json')
    out = base64.b64decode(consumers['stdout_base64'], validate=True)
    original = consumers['command'][3].encode()
    header = re.compile(rb'(?m)^' + re.escape(original) + rb'(?=[ \t]+\.{2,}[ \t]*$)')
    assert len(header.findall(out)) == 1
    out = header.sub(b't/forged_consumer_name.t', out, count=1)
    consumers['stdout_base64'] = base64.b64encode(out).decode()
    original_path = PREFIX + 'before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4.json'
    original_claim = load(original_path)
    original_claim['claims'][0]['durability']['inputs'][0]['sha256'] = '0' * 64
    original_raw = encode(original_claim)
    preservation = load(PREFIX + 'preservation.json')
    preservation['selected'][0]['sha256'] = sha(original_raw)
    chapter = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
    changed_chapter = (ROOT / chapter).read_bytes() + b'\nUnverified evidence mutation.\n'
    book_review = load(PREFIX + 'book-review.json')
    book_review['source_inputs'][chapter] = sha(changed_chapter)
    after_path = PREFIX + 'after-stable-native.json'
    after_reached_path = PREFIX + 'after-stable-reached.json'
    native_report_path = PREFIX + 'native-review.json'
    after = load(after_path)
    payload = json.loads(base64.b64decode(after['rows'][0]['stdout_base64'], validate=True))
    payload['callbacks'][0]['value'] = 'FORGED_NATIVE_RESULT'
    after['rows'][0]['stdout_base64'] = base64.b64encode((json.dumps(payload, sort_keys=True, separators=(',', ':')) + '\n').encode()).decode()
    after_reached = load(after_reached_path)
    after_reached['rows'] = after['rows']
    after_raw, reached_raw = encode(after), encode(after_reached)
    native_report = load(native_report_path)
    native_report['inputs'][after_path] = sha(after_raw)
    native_report['inputs'][after_reached_path] = sha(reached_raw)
    recurrence_path = PREFIX + 'before-recheck-stable-native.json'
    recurrence_reached_path = PREFIX + 'before-recheck-stable-reached.json'
    recurrence = load(recurrence_path)
    recurrence_payload = json.loads(base64.b64decode(recurrence['rows'][0]['stdout_base64'], validate=True))
    recurrence_payload['callbacks'][0]['value'] = 'FORGED_RECURRENCE_VALUE'
    recurrence['rows'][0]['stdout_base64'] = base64.b64encode((json.dumps(recurrence_payload, sort_keys=True, separators=(',', ':')) + '\n').encode()).decode()
    recurrence_reached = load(recurrence_reached_path)
    recurrence_reached['rows'] = recurrence['rows']
    recurrence_raw, recurrence_reached_raw = encode(recurrence), encode(recurrence_reached)
    iterator_path = PREFIX + 'iterator-review.json'
    iterator_report = load(iterator_path)
    iterator_report['inputs'][recurrence_path] = sha(recurrence_raw)
    iterator_report['inputs'][recurrence_reached_path] = sha(recurrence_reached_raw)
    iterator_raw = encode(iterator_report)
    recurrence_native_report = load(native_report_path)
    recurrence_native_report['inputs'][iterator_path] = sha(iterator_raw)
    return [
        ('hidden-inverse-red', {PREFIX + 'inverse-pipeline.json': encode(inverse)}, 'actual distinguishing source failure population'),
        ('forged-consumer-name', {PREFIX + 'consumers.json': encode(consumers)}, 'complete actual consumer header population'),
        ('forged-original-beyond-preservation', {original_path: original_raw, PREFIX + 'preservation.json': encode(preservation)}, 'exact original full publication'),
        ('changed-book-beyond-report', {chapter: changed_chapter, PREFIX + 'book-review.json': encode(book_review)}, 'wrong book input population/content'),
        ('changed-native-beyond-report', {after_path: after_raw, after_reached_path: reached_raw, native_report_path: encode(native_report)}, 'complete native population / sole authority changes'),
        ('changed-iterator-recurrence-beyond-report', {recurrence_path: recurrence_raw, recurrence_reached_path: recurrence_reached_raw, iterator_path: iterator_raw, native_report_path: encode(recurrence_native_report)}, 'sole native clone FETCH-order variability'),
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
print('AST optional evidence PASS: six semantic REDs beyond immediate hashes and exact restorations')
