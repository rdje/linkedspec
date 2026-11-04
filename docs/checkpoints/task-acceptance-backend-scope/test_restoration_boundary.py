"""Exercise the accepted restoration boundary and the independent live CLI count."""
import argparse
import base64
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
RESTORATION = ROOT / 'docs/checkpoints/document-pressure-restoration'
sys.path.insert(0, str(RESTORATION))
import book_count as book
import execution_evidence as execution
import phase0_evidence as phase0


def packet(raw):
    return dict(sha256=hashlib.sha256(raw).hexdigest(), base64=base64.b64encode(raw).decode())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--record', action='store_true')
    args = parser.parse_args()
    captured = {}
    original = book.capture_read

    def capture(name):
        raw = original(name)
        row = packet(raw)
        assert captured.setdefault(name, row) == row
        return raw

    book.capture_read = capture
    # Observe all file artifacts used by the bounded replay, including nested
    # retained capsules. Executed producer modules are bound separately below.
    current_inputs = {}
    read_bytes = Path.read_bytes

    def observe(path):
        raw = read_bytes(path)
        name = path.resolve().relative_to(ROOT).as_posix()
        assert current_inputs.setdefault(name, packet(raw)) == packet(raw)
        return raw

    Path.read_bytes = observe
    try:
        result = book.review()  # Retains all five original capture corruption REDs.
        execution_result = execution.review()
        phase0_result = phase0.review()
    finally:
        Path.read_bytes = read_bytes
    current = (ROOT / book.BOOK).read_bytes()
    manifest = json.loads((ROOT / 'cli_conformance/manifest.json').read_bytes())
    book.validate_live_count(current + b'\nAuthored prose outside the summary.\n', manifest)
    # A matching future manifest/summary passes without changing the historical66.
    future = json.loads(json.dumps(manifest))
    future['cases'].append(dict(id='boundary-synthetic-next-case'))
    count = len(manifest['cases'])
    marker = book.NEW.replace('all 66 primary', 'all ' + str(count) + ' primary').encode()
    next_marker = book.NEW.replace('all 66 primary', 'all ' + str(count + 1) + ' primary').encode()
    book.validate_live_count(current.replace(marker, next_marker, 1), future)
    rejected = []
    duplicate = json.loads(json.dumps(manifest))
    duplicate['cases'].append(duplicate['cases'][0])
    for label, source, cases in (
        ('stale-live-count', current.replace(marker, book.OLD.encode(), 1), manifest),
        ('wrong-live-count', current.replace(marker, next_marker, 1), manifest),
        ('missing-live-summary', current.replace(marker, b'', 1), manifest),
        ('duplicate-live-summary', current + marker, manifest),
        ('duplicate-case-id', current, duplicate),
    ):
        try:
            book.validate_live_count(source, cases)
        except AssertionError:
            rejected.append(label)
        else:
            raise AssertionError('live count corruption admitted: ' + label)
    revision = book.CAPTURE_REVISION
    try:
        book.CAPTURE_REVISION = '0' * 40
        try:
            book.capture_read(book.BOOK)
        except AssertionError as error:
            assert 'capture revision differs' in str(error)
            rejected.append('wrong-capture-revision')
        else:
            raise AssertionError('wrong capture revision admitted')
    finally:
        book.CAPTURE_REVISION = revision
    source = (ROOT / execution.SOURCE).read_bytes()
    execution.validate_live_prerequisite(source + b'\n# Authored CI addition\n')
    without = source.replace(execution.BLOCK, b'', 1)
    for label, candidate in (
        ('missing-live-prerequisite', without),
        ('duplicate-live-prerequisite', source.replace(execution.BLOCK, execution.BLOCK * 2, 1)),
        ('wrong-live-platform', source.replace(b'== Darwin', b'== Linux', 1)),
        ('late-live-prerequisite', without + execution.BLOCK),
    ):
        try:
            execution.validate_live_prerequisite(candidate)
        except AssertionError:
            rejected.append(label)
        else:
            raise AssertionError('current prerequisite corruption admitted: ' + label)
    names = [book.BOOK, 'cli_conformance/manifest.json',
             'docs/claims/TYPE-REFERENCE-BOOK.1.2.20.1.10.json',
             'docs/checkpoints/document-pressure-restoration/book_count.py',
             'docs/checkpoints/document-pressure-restoration/book-count-intake.json.gz',
             'docs/checkpoints/document-pressure-restoration/book-count-evidence.json.gz',
             'docs/checkpoints/document-pressure-restoration/execution_evidence.py',
             'docs/checkpoints/document-pressure-restoration/phase0_evidence.py',
             'tools/run_ci_local.sh',
             Path(__file__).relative_to(ROOT).as_posix(),
             'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh']
    for name in names:
        raw = (ROOT / name).read_bytes()
        assert current_inputs.setdefault(name, packet(raw)) == packet(raw)
    report = dict(capture_revision=revision, historical_result=result,
                  execution_result=execution_result, phase0_result=phase0_result,
                  historical_inputs=captured, rejected=rejected,
                  current_inputs=current_inputs,
                  live_authored_prose_accepted=True, synthetic_future_count_accepted=True,
                  limits='Historical66 capture and original five REDs remain exact. Current count follows the live manifest; the synthetic next count is only a counter-predicate control, not a new admitted CLI case or runtime result. No transitive canonical/toolchain producer closure is claimed.')
    if args.record:
        target = Path(__file__).parent / 'boundary-after.json'
        with target.open('x') as output:
            json.dump(report, output, indent=2)
            output.write('\n')
    print(json.dumps(dict(original_capture_reds=5, new_rejected=rejected,
                         authored_prose_and_synthetic_future_count='PASS',
                         historical_inputs=len(captured)), sort_keys=True))


if __name__ == '__main__':
    main()
