"""Preserve the original two observations; write a distinct remaining-six finisher."""
import base64
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'evidence-repair.json')
final = ROOT / (PREFIX + 'evidence-final.py')
assert not target.exists() and not final.exists()
original = (ROOT / (PREFIX + 'evidence.py')).read_bytes()
rows = json.loads(gzip.decompress((ROOT / (PREFIX + 'evidence-reached.json.gz')).read_bytes()))
assert len(rows) == 2 and all(row['denial']['returncode'] != 0 and row['restored']['returncode'] == 0
                            and row['exact_restoration'] for row in rows)
prefix = original[:original.index(b'if sys.argv[1:]:\n')]
prefix = prefix.replace(b"'evidence.json'", b"'evidence-final.json'").replace(
    b"'evidence-reached.json.gz'", b"'evidence-final-reached.json.gz'")
old = b'''b"assert [name.decode() for name in failures] == row['failures']"'''
new = b"b'assert [name.decode() for name in failures]'"
assert prefix.count(old) == 1
prefix = prefix.replace(old, new)
body = r'''
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
'''.encode()
corrected = prefix + body
compile(corrected, str(final), 'exec')
failure = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.6-evidence-attempt1.log').read_bytes()
record = dict(result='reason matcher metadata repair; original first two observations stay exact',
              producer_sha256=sha(Path(__file__).read_bytes()), original_source_base64=encode(original),
              corrected_source_sha256=sha(corrected), original_reached_sha256=sha(
                  (ROOT / (PREFIX + 'evidence-reached.json.gz')).read_bytes()),
              tool_observed_returncode=1, actual_combined_outer_failure_base64=encode(failure),
              original_reason_base64=encode(old), corrected_reason_base64=encode(new),
              channel_limit='Original shell merged outer streams; child reviewer channels remain separately retained.')
with target.open('x') as output: output.write(json.dumps(record, indent=2) + '\n')
with final.open('xb') as output: output.write(corrected)
print('Original two evidence observations retained; distinct remaining-six finisher written')
