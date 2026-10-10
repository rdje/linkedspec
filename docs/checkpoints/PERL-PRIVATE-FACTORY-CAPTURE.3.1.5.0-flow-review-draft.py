"""Readonly native package-flow diagnosis, including its rejected argument premise.

--capture repeats the actual original/fixed probes in accepted supplied Git inputs.
Default execution checks those complete repeat channels and all original identities.
The optional/direct repair is separately owned; this script admits no fix.
"""
import base64
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '4b48593b59acb7aba4d616ae1bdc4320fbbf5364'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.4-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TARGET = ROOT / (PREFIX + 'flow-review.json')
assert sys.argv[1:] in ([], ['--capture'])
checked = {}
digest = lambda raw: hashlib.sha256(raw).hexdigest()
blob = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def read(path):
    raw = (ROOT / path).read_bytes()
    checked[path] = digest(raw)
    return raw


def channels(row):
    return tuple(base64.b64decode(row[key], validate=True) for key in ('stdout_base64', 'stderr_base64'))


def tap(raw):
    assert re.findall(rb'^1\.\.(\d+)$', raw, re.M) == [b'16']
    assert [int(n) for n in re.findall(rb'^(?:not )?ok (\d+)', raw, re.M)] == list(range(1, 17))


seed_raw = read(SEED)
assert seed_raw == blob(SEED)
seed = json.loads(seed_raw)
files = {p: blob(p) for p in sorted(seed['inputs'])}
assert len(files) == 168 and {p: digest(raw) for p, raw in files.items()} == seed['inputs']
source = files[MODULE].decode()
start = source.index('sub _lower_mutation_slot_value_expr {')
end = source.index('\nsub ', start + 1)
body = source[start:end]
guard = "ref($lower_flow_composite_expr) eq 'CODE'"
assert body.count(guard) == 1
changed = (source[:start] + body.replace(guard, '0', 1) + source[end:]).encode()
old_test = PREFIX + 'flow-probe.pl'
new_test = PREFIX + 'flow-probe-fixed.pl'
old_probe, new_probe = read(old_test), read(new_test)
old_argument = b"[['and(true,false)']]"
new_argument = b"[['and(true, false)']]"
assert old_probe.count(old_argument) == 1
assert new_probe == old_probe.replace(old_argument, new_argument, 1), 'probe exceeds argument-expectation correction'
old_producer = read(PREFIX + 'flow-capture.py')
new_producer = read(PREFIX + 'flow-capture-fixed.py')
assert new_producer == old_producer.replace(b"'flow-probe.pl'", b"'flow-probe-fixed.pl'").replace(
    b"'flow-capture.json'", b"'flow-capture-fixed.json'"), 'producer exceeds separate target paths'
old = json.loads(read(PREFIX + 'flow-capture.json'))
new = json.loads(read(PREFIX + 'flow-capture-fixed.json'))
assert old['result'] == 'pending' and len(old['rows']) == 2
assert new['result'] == 'PASS' and len(new['rows']) == 4
all_rows = []
for report, producer, test, probe in ((old, old_producer, old_test, old_probe),
                                      (new, new_producer, new_test, new_probe)):
    assert report['base'] == BASE and report['seed'] == SEED
    assert report['seed_sha256'] == digest(seed_raw) and report['producer_sha256'] == digest(producer)
    assert [r['case'] for r in report['rows']] == ['native-observe', 'native'] + (
        ['removed-package-branch-syntax', 'removed-package-branch'] if report is new else [])
    for row in report['rows']:
        raw_source = changed if row['case'].startswith('removed-') else files[MODULE]
        population = dict(seed['inputs'], **{test: digest(probe), MODULE: digest(raw_source)})
        assert len(population) == 169 and row['inputs'] == population and row['unchanged'] is True
        expected_command = ['perl', '-Iperl', '-c', MODULE] if row['case'].endswith('syntax') else [
            'perl', '-Iperl', test] + (['observe'] if row['case'] == 'native-observe' else [])
        assert row['command'] == expected_command
        out, err = channels(row)
        if row['case'] == 'native-observe':
            observed = json.loads(out)
            assert row['returncode'] == 0 and not err
            assert observed['public_calls'] == [['and(true, false)']]
            assert observed['controlled'][0]['value'] == 'METHOD_FALLBACK'
            assert observed['controlled'][1]['value'] == 'FLOW_OVERRIDE'
            assert all(r['map_calls'] == 0 and r['map_identity'] == 1 for r in observed['controlled'])
            assert all(r['parent_packet'] == 1 and r['eligible'] == [1] for r in observed['publication'])
        elif row['case'].endswith('syntax'):
            assert row['returncode'] == 0 and b'syntax OK' in err
        else:
            tap(out)
            failures = [line for line in out.splitlines() if line.startswith(b'not ok ')]
            if report is old:
                assert row['returncode'] == 1 and len(failures) == 1
                assert failures[0] == b'not ok 3 - public package-flow callback executes once with actual value source'
                assert b"and(true, false)" in err and b"and(true,false)" in err
            elif row['case'] == 'native':
                assert row['returncode'] == 0 and not failures and not err
            else:
                assert row['returncode'] != 0
                assert any(b'actual package callback controls the legacy branch' in line for line in failures)
        all_rows.append((row, test, probe, raw_source))

report = {'result': 'PASS', 'base': BASE, 'producer_sha256': digest(Path(__file__).read_bytes()),
          'checked': dict(sorted(checked.items())), 'original_files': seed['inputs'],
          'scope': 'Accepted4b48593b5 actual public Toolbox and controlled native package-flow selection. Original pending16 TAP has exactly one rejected compact-argument premise; corrected native16 passes. Disabling only the actual package branch is syntax-valid and semantically RED. All six original/fixed observe/TAP/syntax channels are repeated byte-exactly in169 supplied files. Actual private publication inheritance is diagnosed and scheduled under .3.2.0; no optional/direct fix or authored-language failure is admitted.'}
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot native replay already retained'
    rows = []
    environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0',
                       LINKEDSPEC_MEMBERSHIP_BASELINE='0')
    environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
    for original, test, probe, raw_source in all_rows:
        with tempfile.TemporaryDirectory(prefix='flow-native-repeat-', dir=os.environ['TMPDIR']) as directory:
            supplied = Path(directory)
            assert supplied.stat().st_dev == ROOT.stat().st_dev
            selected = dict(files, **{test: probe, MODULE: raw_source})
            for path, raw in selected.items():
                target = supplied / path
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(raw)
            result = subprocess.run(original['command'], cwd=supplied, env=environment, capture_output=True, check=False)
            row = {'command': original['command'], 'returncode': result.returncode,
                   'stdout_base64': base64.b64encode(result.stdout).decode(),
                   'stderr_base64': base64.b64encode(result.stderr).decode(),
                   'inputs': {p: digest(raw) for p, raw in selected.items()},
                   'unchanged': all((supplied / p).read_bytes() == raw for p, raw in selected.items())}
            rows.append(row)
            assert row['unchanged'] and row['returncode'] == original['returncode']
            assert channels(row) == channels(original), 'native replay channel drift'
    report['rows'] = rows
    TARGET.write_text(json.dumps(report, indent=2) + '\n')
else:
    retained = json.loads(TARGET.read_bytes())
    rows = retained['rows']
    assert len(rows) == len(all_rows) == 6
    for row, (original, test, probe, raw_source) in zip(rows, all_rows):
        assert row['command'] == original['command'] and row['returncode'] == original['returncode']
        assert row['inputs'] == original['inputs'] and row['unchanged'] is True
        assert channels(row) == channels(original), 'retained native repeat differs'
    report['rows'] = rows
    assert retained == report, 'native flow review drift'
print('Legacy flow diagnosis review PASS: original argument-premise RED retained; fixed16/169; six exact native replay channels; optional repair .3.2.0')
