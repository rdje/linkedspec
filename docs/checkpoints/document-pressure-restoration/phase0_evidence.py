"""Retain and review the exact six Phase0 behavior calibrations and source stages."""
import argparse
import base64
import copy
import gzip
import hashlib
from html.parser import HTMLParser
import importlib.util
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OWNER = 'TYPE-REFERENCE-BOOK.1.2.20.1.21'
AUDITOR = 'tests/language-readiness/verify_objectives.py'
FIXTURE = 't/phase0_regression.t'
TABLE = 'tests/language-readiness/phase0-fixture-calibration.json.gz'
BOOK = 'docs/linkedspec-book/src/development/regression-fixtures.md'
READER_TABLE_SHA = '018773723565ae2902501ff0aaf46ba45599f2ea8e5f4abfbf24ebffb5ce080b'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=sha(raw))


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert sha(raw) == row['sha256'], 'Phase0 packet identity'
    return raw


def validate_auditor_evolution(before, after):
    raw = (HERE / 'phase0-reader-evolution.json.gz').read_bytes()
    assert sha(raw) == READER_TABLE_SHA, 'unreviewed Phase0 reader evolution table'
    table = json.loads(gzip.decompress(raw))
    assert table['owner'] == OWNER and table['path'] == AUDITOR
    assert sha(before) == table['before_sha256'] and sha(after) == table['after_sha256']
    assert len(table['edits']) == 7
    reconstructed = before.decode()
    for edit in table['edits']:
        assert set(edit) == {'before', 'after'} and edit['before'] and edit['after']
        assert reconstructed.count(edit['before']) == 1, 'reader evolution anchor'
        reconstructed = reconstructed.replace(edit['before'], edit['after'], 1)
    assert reconstructed.encode() == after, 'unreviewed Phase0 reader source change'


def validate_execution_reader_evolution(old_reader, current_reader):
    anchor = b"        assert (ROOT / name).read_bytes() == decode(row), 'execution input drift: ' + name\n"
    replacement = b"        observed, retained = (ROOT / name).read_bytes(), decode(row)\n        if name == 'tests/language-readiness/verify_objectives.py' and observed != retained:\n            from phase0_evidence import validate_auditor_evolution\n            validate_auditor_evolution(retained, observed)\n        elif name == str(Path(__file__).relative_to(ROOT)):\n            from phase0_evidence import validate_execution_reader_evolution\n            validate_execution_reader_evolution(retained, observed)\n        else:\n            assert observed == retained, 'execution input drift: ' + name\n"
    assert old_reader.count(anchor) == 1 and old_reader.replace(anchor, replacement, 1) == current_reader


def validate_observations(saved):
    semantics = json.loads(decode(saved['semantics']))
    assert decode(saved['semantics_stderr']) == b''
    for name, expected in dict(decimal=4, block=5, order=3.75,
                               mutation=[3, [1, 2, 3], [1, 2]]).items():
        assert semantics['evaluated'][name] == dict(value=expected, warnings=[])
    endpoints = [('available', 'bc', 3), ('empty', '', 0), ('missing_start', 'bc', None),
                 ('missing_end', None, None), ('missing_match', None, None),
                 ('reversed', None, None), ('missing_mark', None, 3)]
    assert len(semantics['endpoints']) == len(endpoints)
    for actual, (name, text, width) in zip(semantics['endpoints'], endpoints):
        assert actual == dict(id=name, named=dict(value=text, warnings=[]),
                              width=dict(value=width, warnings=[]))
    expected = dict(decimal=[4, 3.75], block_once=[3.75, 'V'],
                    append_once=[3, [1, 2, 3], [1, 2], 'V'])
    assert len(semantics['public']) == len(expected)
    for row in semantics['public']:
        assert row['native'] == row['fresh'] == expected[row['id']]
        assert row['loaded'] == 1 and row['error'] == '' and row['native_error'] is None
        assert row['warnings'] == [] and row['output'] is None
        assert row['emitted'] and row['source']
    green = decode(saved['focused_green'])
    assert re.findall(rb'^ok ([1-6]) - ', green, re.M) == [str(n).encode() for n in range(1, 7)]
    assert b'\n1..6\n' in green and not re.search(rb'^\s*not ok ', green, re.M)
    faults = decode(saved['fault_controls'])
    assert re.findall(rb'^not ok ([1-6]) - ', faults, re.M) == [str(n).encode() for n in range(1, 7)]
    assert b'1..6\n' in faults and b'failed 6 tests of 6' in faults
    assert decode(saved['old_image_guard']) == b'unreviewed current source image: t/phase0_regression.t\n'
    assert b'HTML book written to' in decode(saved['book_build'])


def capture():
    destination = HERE / 'phase0-evidence-final.json.gz'
    assert not destination.exists(), 'never overwrite completed Phase0 epochs'
    intake_raw = (HERE / 'phase0-intake.json.gz').read_bytes()
    intake = json.loads(gzip.decompress(intake_raw))
    spec = importlib.util.spec_from_file_location('phase0_audit', ROOT / AUDITOR)
    audit = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(audit)
    previous = json.loads(decode(json.loads(gzip.decompress((HERE / 'objective-recovery-execution-preflight.json.gz').read_bytes()))['report']))
    images = audit.current_image_admissions(audit.read_relative)
    try:
        images.verify(previous['audit_report']['latest_source_inputs'], audit.read_relative)
    except ValueError as error:
        guard = (str(error) + '\n').encode()
    else:
        raise AssertionError('unchanged image guard silently accepted current fixture')
    scratch = ROOT / '.linkedspec-data/normal-hook-restoration'
    names = {FIXTURE, AUDITOR, TABLE, BOOK, 'docs/linkedspec-book/book.toml', 'tools/run_mdbook_local.sh',
             'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
             'tools/historical_objective_images.py', 'tests/language-readiness/current-source-images.json.gz',
             'docs/knowledge/phase0-behavior-calibration-source-stages.md',
             'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'}
    names.update(str((HERE / n).relative_to(ROOT)) for n in (
        'phase0_evidence.py', 'phase0_probe.pl', 'capture_phase0_intake.py', 'edit_phase0_reader.py',
        'phase0-reader-evolution.json.gz', 'phase0-execution-reader-before.py.gz', 'execution_evidence.py',
        'phase0-evidence.json.gz', 'phase0-evidence-accepted.json.gz',
        'phase0-composed-reader-rejection.log.gz', 'phase0-evidence-reader-initial.py.gz',
        'objective-recovery-phase0-calibration.json.gz', 'objective-recovery-phase0-stable-inputs.json.gz'))
    saved = dict(owner=OWNER, inputs={n: packet((ROOT / n).read_bytes()) for n in sorted(names)},
        intake_sha256=sha(intake_raw), old_image_guard=packet(guard),
        semantics=packet((scratch / 'phase0-semantics-final.json').read_bytes()),
        semantics_stderr=packet((scratch / 'phase0-semantics-final.stderr').read_bytes()),
        focused_green=packet((scratch / 'phase0-focused-final.log').read_bytes()),
        fault_controls=packet((scratch / 'phase0-fault-controls.log').read_bytes()),
        book_build=packet((scratch / 'book-phase0-build.log').read_bytes()),
        rendered=packet((ROOT / 'docs/linkedspec-book/book/development/regression-fixtures.html').read_bytes()),
        earlier_observations={n: packet((scratch / n).read_bytes()) for n in (
            'phase0-focused-before.log', 'phase0-focused-before-repaired.log', 'phase0-focused-red.log',
            'phase0-focused-green.log', 'phase0-semantics.json', 'phase0-semantics.stderr',
            'phase0-probe-instrument-before.pl')},
        limits='Six assertion spans only; independent current native/fresh programs and real lowered expressions, not broad runtime admission. Full original failed canonical and pre-edit producer population are retained. Early focused harness attempts lack prior-suite initialization and receive no product RED credit. Earlier focused observations precede the added fault-control mode; final observations use the retained final producer. Fault controls inject deliberately wrong emitted bodies into the same assertions; they do not claim new production defects. Rendered page is observed; transitive mdBook generation inputs are not fully closed. The intermediate composed review rejects the reader self-input drift; final exact reader evolution verifies that predecessor too. Earlier capsules and readers are retained. The initial recovery epoch is retained rejected for a concurrent book edit; stable-input rerun and accepted capsule correct custody, without rewriting that epoch. Exact final canonical CI and normal hooks remain required.')
    validate_observations(saved)
    destination.write_bytes(gzip.compress(json.dumps(saved, sort_keys=True, separators=(',', ':')).encode(), mtime=0))


def review():
    raw = (HERE / 'phase0-intake.json.gz').read_bytes()
    intake = json.loads(gzip.decompress(raw))
    saved = json.loads(gzip.decompress((HERE / 'phase0-evidence-final.json.gz').read_bytes()))
    assert saved['owner'] == intake['owner'] == OWNER and sha(raw) == saved['intake_sha256']
    for name, row in saved['inputs'].items():
        assert (ROOT / name).read_bytes() == decode(row), 'Phase0 input drift: ' + name
    for name, row in intake['inputs'].items():
        old = decode(row)
        if name.startswith(('perl/', 't/lib/')):
            assert (ROOT / name).read_bytes() == old, 'component21 production/support drift: ' + name
    baseline = decode(intake['failure'])
    assert b'Tests=1035' in baseline and b'Failed 6/1035 subtests' in baseline
    original = decode(intake['inputs'][FIXTURE])
    assert original == subprocess.check_output(['git', 'show', '0db5e9e87b7c1cfaf09936b9629974787038f5e3:' + FIXTURE], cwd=ROOT)
    table = json.loads(gzip.decompress((ROOT / TABLE).read_bytes()))
    assert table['owner'] == OWNER and len(table['hunks']) == 6
    current = original.decode()
    for hunk in table['hunks']:
        assert current.count(hunk['before']) == 1
        current = current.replace(hunk['before'], hunk['after'], 1)
    actual = decode(saved['inputs'][FIXTURE])
    assert current.encode() == actual
    assert re.findall(rb"^subtest '[^']+'", original, re.M) == re.findall(rb"^subtest '[^']+'", actual, re.M)
    before, after = decode(intake['inputs'][AUDITOR]), decode(saved['inputs'][AUDITOR])
    validate_auditor_evolution(before, after)
    for candidate in (after + b'# unreviewed\n', before, after.replace(b'fixture_read, fixture_evolution', b'ignored, fixture_evolution', 1)):
        try:
            validate_auditor_evolution(before, candidate)
        except AssertionError:
            pass
        else:
            raise AssertionError('unreviewed reader mutation admitted')
    old_reader = gzip.decompress((HERE / 'phase0-execution-reader-before.py.gz').read_bytes())
    current_reader = (HERE / 'execution_evidence.py').read_bytes()
    validate_execution_reader_evolution(old_reader, current_reader)
    for candidate in (old_reader, current_reader + b'# unreviewed\n',
                      current_reader.replace(b'elif name == str', b'elif False and name == str', 1)):
        try:
            validate_execution_reader_evolution(old_reader, candidate)
        except AssertionError:
            pass
        else:
            raise AssertionError('execution reader evolution corruption admitted')
    initial = json.loads(gzip.decompress((HERE / 'phase0-evidence.json.gz').read_bytes()))
    initial_reader = gzip.decompress((HERE / 'phase0-evidence-reader-initial.py.gz').read_bytes())
    assert initial_reader == decode(initial['inputs'][str(Path(__file__).relative_to(ROOT))])
    validate_observations(initial)
    provisional = json.loads(gzip.decompress((HERE / 'phase0-evidence-accepted.json.gz').read_bytes()))
    validate_observations(provisional)
    for row in provisional['inputs'].values():
        decode(row)
    rejection = gzip.decompress((HERE / 'phase0-composed-reader-rejection.log.gz').read_bytes())
    assert b'execution input drift: docs/checkpoints/document-pressure-restoration/execution_evidence.py' in rejection
    def recovery_epoch(name):
        epoch = json.loads(gzip.decompress((HERE / name).read_bytes()))
        return json.loads(decode(epoch['report']))
    rejected = recovery_epoch('objective-recovery-phase0-calibration.json.gz')
    mismatches = [name for name, value in rejected['observed_artifact_inputs'].items()
                  if rejected['tracked_inputs'][name] != value]
    assert mismatches == [BOOK], 'unexpected rejected recovery cause'
    accepted = recovery_epoch('objective-recovery-phase0-stable-inputs.json.gz')
    assert all(accepted['tracked_inputs'][n] == v for n, v in accepted['observed_artifact_inputs'].items())
    assert len(accepted['observed_artifact_inputs']) == 189 and len(accepted['tracked_inputs']) == 200
    validate_observations(saved)
    for key in ('semantics', 'focused_green', 'fault_controls', 'old_image_guard', 'book_build'):
        bad = copy.deepcopy(saved)
        bad[key] = packet(b'{}' if key == 'semantics' else b'')
        try:
            validate_observations(bad)
        except (AssertionError, KeyError):
            pass
        else:
            raise AssertionError('Phase0 outcome loss admitted: ' + key)
    for row in saved['earlier_observations'].values():
        decode(row)
    class Visible(HTMLParser):
        def __init__(self):
            super().__init__(); self.parts = []
        def handle_data(self, data):
            self.parts.append(data)
    visible = Visible(); visible.feed(decode(saved['rendered']).decode())
    text = ' '.join(''.join(visible.parts).split())
    for marker in ('Behavior checks across lowering changes', 'floor-before-add', 'committed activation fixture'):
        assert marker in text
    return dict(assertion_spans=6, unchanged_top_level_identities=True, focused_groups=6,
        public_native_and_fresh=3, endpoint_cases=7, wrong_emitted_bodies_rejected=6,
        exact_reader_mutations_rejected=3, execution_reader_mutations_rejected=3, outcome_loss_controls=5,
        prior_image_guard='actual RED retained; committed image table unchanged', limits=saved['limits'])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', action='store_true')
    args = parser.parse_args()
    if args.capture:
        capture()
    print(json.dumps(review(), sort_keys=True))
