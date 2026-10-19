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
target = ROOT / (PREFIX + 'evidence.json')
original_path = ROOT / (PREFIX + 'evidence-originals.json.gz')
reached = ROOT / (PREFIX + 'evidence-reached.json.gz')
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
    ('hidden-positive-failure', b"assert [name.decode() for name in failures] == row['failures']"),
    ('missing-control', b'assert len(rows) == len(runtime'),
    ('false-source-inverse', b'exact source inverse'),
    ('forged-original-native-observation', b'immutable native observation'),
    ('wrong-native-context', b'assert expected_native in native_tables'),
    ('wrong-rendered-count', b'assert expected_workflow in workflow_tables'),
    ('missing-knowledge-member', b'assert len(original) == 1487'),
]
if sys.argv[1:]:
    assert not target.exists() and not original_path.exists() and not reached.exists()
    inputs = copy.deepcopy(read('current-review.json')['inputs'])
    for path in (PREFIX + 'evidence.py', PREFIX + 'current-review.json'):
        inputs[path] = dict(sha256=sha(raw(path)), mode=(ROOT / path).stat().st_mode & 0o7777)
    originals = {path: dict(bytes_base64=encode(raw(path)), sha256=sha(raw(path)),
                            mode=(ROOT / path).stat().st_mode & 0o7777) for path in targets}
    with original_path.open('xb') as output: output.write(pack(originals))
    baseline = execute()
    assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
    rows = []
    reached.write_bytes(pack(rows))
    for name, reason in specifications:
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
                   exact_restoration=all(sha(raw(path)) == value['sha256']
                                        and (ROOT / path).stat().st_mode & 0o7777 == value['mode']
                                        for path, value in originals.items()))
        rows.append(row)
        reached.write_bytes(pack(rows))
        assert denial['returncode'] != 0 and reason in decode(denial['stderr_base64']), (name, denial)
        assert restored['returncode'] == 0 and not decode(restored['stderr_base64']) and row['exact_restoration'], name
        assert all(sha(raw(path)) == item['sha256'] and (ROOT / path).stat().st_mode & 0o7777 == item['mode']
                   for path, item in inputs.items()), name
        print('Pipeline evidence denial/restoration retained:', name, flush=True)
    report = dict(result='PASS', producer_sha256=sha(Path(__file__).read_bytes()),
                  originals_sha256=sha(original_path.read_bytes()), reached_sha256=sha(reached.read_bytes()),
                  inputs=inputs, baseline=baseline, controls=[dict(name=row['name'], denial_returncode=row['denial']['returncode'],
                      restored_returncode=row['restored']['returncode'], expected_reason_base64=row['expected_reason_base64']) for row in rows],
                  scope='Eight actual artifact interventions retain full changed bytes/modes and separated reviewer '
                        'channels with exact restoration. Immediate witness hashes are repaired where applicable. '
                        'All writable-target originals stay whole; the complete remaining reader input population '
                        'is explicitly byte/mode-gated and retained by the publication/runtime/Knowledge/book inputs. '
                        'No original native/capture/generator is rerun or refreshed.')
    with target.open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
else:
    report = read('evidence.json')
    assert report['result'] == 'PASS' and sha(Path(__file__).read_bytes()) == report['producer_sha256']
    assert sha(original_path.read_bytes()) == report['originals_sha256']
    assert sha(reached.read_bytes()) == report['reached_sha256']
    originals = json.loads(gzip.decompress(original_path.read_bytes()))
    rows = json.loads(gzip.decompress(reached.read_bytes()))
    assert [row['name'] for row in rows] == [name for name, _ in specifications]
    assert report['baseline']['returncode'] == 0 and not decode(report['baseline']['stderr_base64'])
    for row, (name, reason), summary in zip(rows, specifications, report['controls'], strict=True):
        assert row['name'] == summary['name'] == name and decode(row['expected_reason_base64']) == reason
        assert row['denial']['returncode'] != 0 and reason in decode(row['denial']['stderr_base64'])
        assert row['restored']['returncode'] == 0 and not decode(row['restored']['stderr_base64'])
        assert row['exact_restoration'] and row['changed']
        assert all(sha(decode(value['bytes_base64'])) == value['sha256'] != originals[path]['sha256']
                   for path, value in row['changed'].items())
    for path, item in originals.items():
        assert sha(raw(path)) == item['sha256'] and (ROOT / path).stat().st_mode & 0o7777 == item['mode']
    for path, item in report['inputs'].items():
        assert sha(raw(path)) == item['sha256'] and (ROOT / path).stat().st_mode & 0o7777 == item['mode']
print('Pipeline evidence PASS:8 effective denials; whole counterfactuals/channels/exact restoration')
