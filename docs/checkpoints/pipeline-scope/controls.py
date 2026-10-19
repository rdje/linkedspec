"""Three actual transport/closure denials; default validates retained artifacts only."""
import gzip
import json
import subprocess
import sys
from pathlib import Path
from common_final import ROOT, PREFIX, NATIVE, BASE, load, sha, encode, decode

assert sys.argv[1:] in ([], ['--capture'])
original = load()
namespace_path = PREFIX + 'namespace.json.gz'
selected = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.7.json'
command = ['python3', PREFIX + 'review.py', '--transport-only']
originals_path = ROOT / (PREFIX + 'control-originals.json.gz')
reached_path = ROOT / (PREFIX + 'controls-reached.json.gz')
report_path = ROOT / (PREFIX + 'controls.json')


def observe(command):
    run = subprocess.run(command, cwd=ROOT, capture_output=True)
    return dict(command=command, returncode=run.returncode,
                stdout_base64=encode(run.stdout), stderr_base64=encode(run.stderr))


def changes(originals):
    view = json.loads(decode(originals[NATIVE]['base64']))
    view['command'][1] += '/different-observed-argument'
    forged = (json.dumps(view, indent=2) + '\n').encode().replace(b'/', b'\\/')
    namespace = json.loads(gzip.decompress(decode(originals[namespace_path]['base64'])))
    del namespace['inputs'][selected]
    namespace['fixed_names'].remove(selected)
    namespace['added_names'].remove(selected)
    omitted = gzip.compress(json.dumps(namespace, sort_keys=True).encode(), mtime=0)
    return [
        ('forged-native-argument', NATIVE, forged, 'decoded native observation is identical'),
        ('original-unescaped-transport', NATIVE, decode(original['inputs'][NATIVE]['base64']),
         'exact standard JSON solidus transport'),
        ('omitted-fixed-claim', namespace_path, omitted, 'fixed supplied claim namespace'),
    ]


if sys.argv[1:]:
    assert not report_path.exists() and not originals_path.exists() and not reached_path.exists()
    originals = {}
    for path in (NATIVE, namespace_path):
        source = ROOT / path
        value = source.read_bytes()
        originals[path] = dict(base64=encode(value), sha256=sha(value), mode=source.stat().st_mode & 0o7777)
    with originals_path.open('xb') as output:
        output.write(gzip.compress(json.dumps(originals, sort_keys=True).encode(), mtime=0))
    baseline = observe(command)
    assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64']), baseline
    rows = []
    for name, path, value, reason in changes(originals):
        source = ROOT / path
        try:
            source.write_bytes(value)
            source.chmod(originals[path]['mode'])
            negative = observe(command)
            attempted = dict(base64=encode(source.read_bytes()), sha256=sha(source.read_bytes()),
                             mode=source.stat().st_mode & 0o7777)
        finally:
            for restore_path, item in originals.items():
                (ROOT / restore_path).write_bytes(decode(item['base64']))
                (ROOT / restore_path).chmod(item['mode'])
        restored = observe(command)
        rows.append(dict(name=name, path=path, reason=reason, counterfactual=attempted,
                         negative=negative, restored=restored))
        reached_path.write_bytes(gzip.compress(json.dumps(rows, sort_keys=True).encode(), mtime=0))
        assert negative['returncode'] != 0 and reason.encode() in decode(negative['stderr_base64']), rows[-1]
        assert restored == baseline, rows[-1]
    gate_path = 'scripts/check_repo_root_path_portability.sh'
    gate_source = (ROOT / gate_path).read_bytes()
    assert gate_source == subprocess.check_output(['git', 'show', BASE + ':' + gate_path], cwd=ROOT)
    gate = observe(['bash', gate_path])
    report = dict(result='PASS', producer_sha256=sha(Path(__file__).read_bytes()), baseline=baseline,
                  originals_sha256=sha(originals_path.read_bytes()), reached_sha256=sha(reached_path.read_bytes()),
                  controls=[dict(name=row['name'], path=row['path'], reason=row['reason']) for row in rows],
                  unchanged_gate=dict(path=gate_path, source_base64=encode(gate_source), sha256=sha(gate_source), observation=gate),
                  scope='Three actual whole-file counterfactual CLI denials, complete channels and exact '
                        'restoration. Whole counterfactual bytes/modes and both original targets are '
                        'retained. The unchanged actual path gate passes after restoration; its '
                        'original full normal-hook rejection remains in replay-repair.json.')
    with report_path.open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
    assert gate['returncode'] == 0 and not decode(gate['stderr_base64']), gate

report = json.loads(report_path.read_bytes())
assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
assert sha(originals_path.read_bytes()) == report['originals_sha256']
assert sha(reached_path.read_bytes()) == report['reached_sha256']
originals = json.loads(gzip.decompress(originals_path.read_bytes()))
rows = json.loads(gzip.decompress(reached_path.read_bytes()))
assert len(rows) == len(report['controls']) == 3
for path, item in originals.items():
    assert sha(decode(item['base64'])) == item['sha256']
    assert (ROOT / path).read_bytes() == decode(item['base64'])
    assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
for row, (name, path, expected, reason) in zip(rows, changes(originals)):
    actual = decode(row['counterfactual']['base64'])
    assert (row['name'], row['path'], row['reason']) == (name, path, reason)
    assert sha(actual) == row['counterfactual']['sha256'] and row['counterfactual']['mode'] == originals[path]['mode']
    if path == namespace_path:
        assert json.loads(gzip.decompress(actual)) == json.loads(gzip.decompress(expected))
    else: assert actual == expected
    assert row['negative']['command'] == command and row['negative']['returncode'] != 0
    assert reason.encode() in decode(row['negative']['stderr_base64'])
    assert row['restored'] == report['baseline'] and row['restored']['returncode'] == 0
gate = report['unchanged_gate']
assert (ROOT / gate['path']).read_bytes() == decode(gate['source_base64'])
assert sha(decode(gate['source_base64'])) == gate['sha256']
assert gate['observation']['returncode'] == 0 and not decode(gate['observation']['stderr_base64'])
failure = json.loads((ROOT / (PREFIX + 'replay-repair.json')).read_bytes())
original_gate_log = decode(failure['originals'][
    '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.6-commit.log']['base64'])
assert b'FAIL  REPO-ROOT-PATHS' in original_gate_log and b'native-prove-context-before.json:5:' in original_gate_log
print('Transport/closure artifact controls PASS:3 actual denials; exact restoration; unchanged path gate')
