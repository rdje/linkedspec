"""Eight source-aware evidence denials; defaults readonly, --capture restores every actual mutation."""
import base64
import copy
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
decode = base64.b64decode
raw = lambda path: (ROOT / path).read_bytes()
read = lambda name: json.loads(raw(PREFIX + name))
serialize = lambda value: (json.dumps(value, indent=1) + '\n').encode()
pack = lambda value: gzip.compress(json.dumps(value, sort_keys=True).encode(), mtime=0)
assert sys.argv[1:] in ([], ['--capture'])
target = ROOT / (PREFIX + 'evidence-final.json')
original_path = ROOT / (PREFIX + 'evidence-originals.json.gz')
reached = ROOT / (PREFIX + 'evidence-final-reached.json.gz')
targets = [PREFIX + name for name in ('preservation.json', 'runtime.json', 'runtime-reached.json.gz',
          'runtime-inputs.json.gz', 'native-before.json', 'book.json', 'knowledge.json', 'knowledge-inputs.json.gz')]
command = ['python3', PREFIX + 'review-current.py']

def execute():
    run = subprocess.run(command, cwd=ROOT, capture_output=True)
    return dict(command=command, returncode=run.returncode,
                stdout_base64=encode(run.stdout), stderr_base64=encode(run.stderr))

def runtime_rows_change(kind):
    metadata = read('runtime.json')
    rows = json.loads(gzip.decompress(raw(PREFIX + 'runtime-reached.json.gz')))
    if kind == 'hidden-positive-failure':
        value = decode(rows[0]['stdout_base64'])
        assert value.count(b'\nok 1 - ') == 1
        rows[0]['stdout_base64'] = encode(value.replace(b'\nok 1 - ', b'\nnot ok 1 - ', 1))
    elif kind == 'missing-control':
        del rows[9]
        del metadata['rows'][9]
    else:
        source = decode(json.loads(gzip.decompress(raw(PREFIX + 'runtime-inputs.json.gz')))[
            'perl/LinkedSpec/ActionIR/RewritePipeline.pm']['bytes_base64'])
        rows[9]['source_base64'] = encode(source)
        rows[9]['source_sha256'] = sha(source)
        metadata['rows'][9]['source_sha256'] = sha(source)
    packed = pack(rows)
    metadata['reached_sha256'] = sha(packed)
    return {PREFIX + 'runtime-reached.json.gz': packed, PREFIX + 'runtime.json': serialize(metadata)}

def book_change(kind):
    envelope = read('book.json')
    inner = json.loads(gzip.decompress(decode(envelope['data'])))
    field = 'target_html_base64' if kind == 'wrong-native-context' else 'html_base64'
    html = decode(inner['rows'][0][field])
    if kind == 'wrong-native-context':
        start = html.index(b'<th>Pipeline seam</th>')
        position = html.index(b'<td>Scalar</td>', start)
        html = html[:position] + html[position:].replace(b'<td>Scalar</td>', b'<td>List</td>', 1)
    else:
        start = html.index(b'<th>Current focused observation</th>')
        position = html.index(b'<td>2,065 assertions</td>', start)
        html = html[:position] + html[position:].replace(b'<td>2,065 assertions</td>', b'<td>2,066 assertions</td>', 1)
    inner['rows'][0][field] = encode(html)
    value = (json.dumps(inner, indent=2) + '\n').encode()
    envelope.update(bytes=len(value), sha256=sha(value), data=encode(gzip.compress(value, mtime=0)))
    return {PREFIX + 'book.json': serialize(envelope)}

def mutation(name):
    if name == 'forged-whole-original-claim':
        value = read('preservation.json')
        selected = value['selected'][0]
        original = decode(selected['original_base64'])
        assert original.count(b'Exact150-line') == 1
        changed = original.replace(b'Exact150-line', b'Exact149-line', 1)
        selected.update(original_base64=encode(changed), sha256=sha(changed), bytes=len(changed))
        for row in value['census']:
            if row['path'] == selected['path']: row['sha256'] = sha(changed)
        return {PREFIX + 'preservation.json': serialize(value)}
    if name in ('hidden-positive-failure', 'missing-control', 'false-source-inverse'):
        return runtime_rows_change(name)
    if name == 'forged-original-native-observation':
        value = read('native-before.json')
        observed = json.loads(decode(value['stdout_base64']))
        assert observed[0]['ordinary']['values'][0] == 'LOWERED'
        observed[0]['ordinary']['values'][0] = 'FORGED'
        value['stdout_base64'] = encode(json.dumps(observed, sort_keys=True, ensure_ascii=False).encode())
        changed = serialize(value)
        metadata = read('runtime.json')
        capsule = json.loads(gzip.decompress(raw(PREFIX + 'runtime-inputs.json.gz')))
        item = capsule[PREFIX + 'native-before.json']
        item.update(bytes_base64=encode(changed), sha256=sha(changed))
        packed = pack(capsule)
        metadata['inputs'][PREFIX + 'native-before.json']['sha256'] = sha(changed)
        metadata['capsule_sha256'] = sha(packed)
        return {PREFIX + 'native-before.json': changed, PREFIX + 'runtime-inputs.json.gz': packed,
                PREFIX + 'runtime.json': serialize(metadata)}
    if name in ('wrong-native-context', 'wrong-rendered-count'):
        return book_change(name)
    value = read('knowledge.json')
    capsule = json.loads(gzip.decompress(raw(PREFIX + 'knowledge-inputs.json.gz')))
    omitted = next(path for path in sorted(capsule['original']) if path.startswith('docs/decisions/'))
    del capsule['original'][omitted]
    del capsule['current'][omitted]
    del value['inputs'][omitted]
    value['markdown'] = 1486
    packed = pack(capsule)
    value['capsule_sha256'] = sha(packed)
    return {PREFIX + 'knowledge.json': serialize(value), PREFIX + 'knowledge-inputs.json.gz': packed}

specifications = [
    ('forged-whole-original-claim', b'assert original_claim == old'),
    ('hidden-positive-failure', b'assert [name.decode() for name in failures]'),
    ('missing-control', b'assert len(rows) == len(runtime'),
    ('false-source-inverse', b'exact source inverse'),
    ('forged-original-native-observation', b'immutable native observation'),
    ('wrong-native-context', b'assert expected_native in native_tables'),
    ('wrong-rendered-count', b'assert expected_workflow in workflow_tables'),
    ('missing-knowledge-member', b'assert len(original) == 1487'),
]

repair = read('evidence-repair.json')
if sys.argv[1:]:
    assert not target.exists() and not reached.exists() and original_path.exists()
    originals = json.loads(gzip.decompress(original_path.read_bytes()))
    assert all(sha(raw(path)) == value['sha256'] and (ROOT / path).stat().st_mode & 0o7777 == value['mode']
               for path, value in originals.items())
    rows = json.loads(gzip.decompress(raw(PREFIX + 'evidence-reached.json.gz')))
    assert len(rows) == 2
    for row, (name, reason) in zip(rows, specifications[:2], strict=True):
        assert row['name'] == name and row['denial']['returncode'] != 0
        assert reason in decode(row['denial']['stderr_base64'])
        row['original_expected_reason_base64'] = row['expected_reason_base64']
        row['expected_reason_base64'] = encode(reason)
        row['actor'] = dict(path=PREFIX + 'evidence.py', sha256=sha(raw(PREFIX + 'evidence.py')))
    baseline = rows[1]['restored']
    inputs = copy.deepcopy(read('current-review.json')['inputs'])
    for path in (PREFIX + 'evidence.py', PREFIX + 'evidence-final.py', PREFIX + 'current-review.json',
                 PREFIX + 'evidence-originals.json.gz', PREFIX + 'evidence-reached.json.gz',
                 PREFIX + 'evidence-repair.json'):
        inputs[path] = dict(sha256=sha(raw(path)), mode=(ROOT / path).stat().st_mode & 0o7777)
    reached.write_bytes(pack(rows))
    for name, reason in specifications[2:]:
        changed = mutation(name)
        assert changed and all(path in originals and sha(value) != originals[path]['sha256'] for path, value in changed.items())
        try:
            for path, value in changed.items(): (ROOT / path).write_bytes(value)
            denial = execute()
        finally:
            for path, value in originals.items():
                (ROOT / path).write_bytes(decode(value['bytes_base64']))
                (ROOT / path).chmod(value['mode'])
        restored = execute()
        row = dict(name=name, expected_reason_base64=encode(reason),
                   changed={path: dict(bytes_base64=encode(value), sha256=sha(value), mode=originals[path]['mode'])
                            for path, value in changed.items()}, denial=denial, restored=restored,
                   actor=dict(path=PREFIX + 'evidence-final.py', sha256=sha(Path(__file__).read_bytes())),
                   exact_restoration=all(sha(raw(path)) == value['sha256']
                                        and (ROOT / path).stat().st_mode & 0o7777 == value['mode']
                                        for path, value in originals.items()))
        rows.append(row)
        reached.write_bytes(pack(rows))
        assert denial['returncode'] != 0 and reason in decode(denial['stderr_base64']), (name, denial)
        assert restored['returncode'] == 0 and not decode(restored['stderr_base64']) and row['exact_restoration'], name
        assert all(sha(raw(path)) == item['sha256'] and (ROOT / path).stat().st_mode & 0o7777 == item['mode']
                   for path, item in inputs.items()), name
        print('Remaining pipeline evidence denial/restoration retained:', name, flush=True)
    report = dict(result='PASS', producer_sha256=sha(Path(__file__).read_bytes()),
                  originals_sha256=sha(original_path.read_bytes()), reached_sha256=sha(reached.read_bytes()),
                  inputs=inputs, baseline=baseline, baseline_actor=rows[1]['actor'],
                  controls=[dict(name=row['name'], denial_returncode=row['denial']['returncode'],
                      restored_returncode=row['restored']['returncode'], expected_reason_base64=row['expected_reason_base64'],
                      actor=row['actor']) for row in rows],
                  scope='Eight effective actual denials/restorations. First two commands/channels/actors '
                        'remain original; only metadata adjudication of the quoted assertion prefix changes. '
                        'This actor executes only the remaining six controls. The retained second healthy '
                        'restoration is the baseline; the original initial-baseline variable was not '
                        'serialized, and no substitute original transport is invented. Whole variants '
                        'and modes plus separated channels and exact restoration remain retained.')
    with target.open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
else:
    report = read('evidence-final.json')
    assert report['result'] == 'PASS' and sha(Path(__file__).read_bytes()) == report['producer_sha256']
    assert sha(original_path.read_bytes()) == report['originals_sha256']
    assert sha(reached.read_bytes()) == report['reached_sha256']
    originals = json.loads(gzip.decompress(original_path.read_bytes()))
    rows = json.loads(gzip.decompress(reached.read_bytes()))
    original_rows = json.loads(gzip.decompress(raw(PREFIX + 'evidence-reached.json.gz')))
    assert len(original_rows) == 2 and len(rows) == len(report['controls']) == 8
    for index in range(2):
        compared = {key: value for key, value in rows[index].items()
                    if key not in ('actor', 'original_expected_reason_base64', 'expected_reason_base64')}
        original_compared = {key: value for key, value in original_rows[index].items() if key != 'expected_reason_base64'}
        assert compared == original_compared
    assert report['baseline'] == original_rows[1]['restored'] and report['baseline']['returncode'] == 0
    for index, (row, (name, reason), summary) in enumerate(zip(rows, specifications, report['controls'], strict=True)):
        assert row['name'] == summary['name'] == name and decode(row['expected_reason_base64']) == reason
        assert row['denial']['returncode'] != 0 and reason in decode(row['denial']['stderr_base64'])
        assert row['restored']['returncode'] == 0 and not decode(row['restored']['stderr_base64'])
        assert row['exact_restoration'] and row['changed'] and summary['actor'] == row['actor']
        actor = PREFIX + ('evidence.py' if index < 2 else 'evidence-final.py')
        assert row['actor'] == dict(path=actor, sha256=sha(raw(actor)))
        expected = mutation(name)
        assert set(expected) == set(row['changed'])
        for path, value in row['changed'].items():
            assert decode(value['bytes_base64']) == expected[path]
            assert sha(expected[path]) == value['sha256'] != originals[path]['sha256']
    for path, item in originals.items():
        assert sha(raw(path)) == item['sha256'] and (ROOT / path).stat().st_mode & 0o7777 == item['mode']
    for path, item in report['inputs'].items():
        assert sha(raw(path)) == item['sha256'] and (ROOT / path).stat().st_mode & 0o7777 == item['mode']
print('Pipeline evidence PASS:8 effective denials; original first2 actors; remaining6; exact restoration')
