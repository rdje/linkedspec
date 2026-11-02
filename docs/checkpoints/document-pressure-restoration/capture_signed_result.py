"""Retain the reached Count callable-path repair and its exact authored evidence."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
SCRATCH = ROOT / '.linkedspec-data/normal-hook-restoration'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert hashlib.sha256(raw).hexdigest() == row['sha256']
    return raw


def capture():
    destination = HERE / 'signed-result-repair.json.gz'
    assert not destination.exists(), 'keep completed evidence epochs immutable'
    intake_path = HERE / 'signed-result-intake.json.gz'
    intake = json.loads(gzip.decompress(intake_path.read_bytes()))
    for row in intake['inputs'].values():
        decode(row)
    book = 'docs/linkedspec-book/src/appendix/formal-grammar.md'
    old_book = subprocess.check_output(['git', 'show', ':' + book], cwd=ROOT)
    previous = json.loads(gzip.decompress((HERE / 'punctuation-intake.json.gz').read_bytes()))
    epoch = previous['runtime_source_epoch']
    changed = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
    for name, expected in epoch.items():
        raw = (ROOT / name).read_bytes()
        if name == changed:
            assert intake['inputs'][name]['sha256'] == expected
        else:
            assert hashlib.sha256(raw).hexdigest() == expected, 'unexpected runtime edit: ' + name
    record = dict(
        owner='TYPE-REFERENCE-BOOK.1.2.20.1.14',
        intake=packet(intake_path.read_bytes()),
        after_inputs={name: packet((ROOT / name).read_bytes()) for name in intake['inputs']},
        channels={name: packet((SCRATCH / name).read_bytes()) for name in (
            'signed-result-after.json', 'signed-count-after.log', 'signed-native-check-final.log',
            'objective-count-inverse-rejected.py', 'objective-recovery-count.stderr',
            'book-count-build.log', 'book-count-build-final.log')},
        auditor=packet((ROOT / 'tests/language-readiness/verify_objectives.py').read_bytes()),
        prior_runtime_epoch=epoch,
        producers={str(path.relative_to(ROOT)): packet(path.read_bytes()) for path in (
            Path(__file__), HERE / 'signed_result_review.py', HERE / 'signed_result_probe.pl',
            ROOT / 'tools/project_data_run.sh', ROOT / 'tools/project_data_env.sh',
            ROOT / 'tools/run_mdbook_local.sh')},
        book=dict(path=book, before=packet(old_book), after=packet((ROOT / book).read_bytes()),
                  rendered=packet((ROOT / 'docs/linkedspec-book/book/appendix/formal-grammar.html').read_bytes())),
        limits='Exact four authored callable-result observations and selected direct regression suites. All declared Perl/spec predecessor inputs are immutable Git bytes except the explicit MethodLowering repair. No general raw-expression readiness, full transitive/toolchain closure, historical objective source-population expansion or portable admission. Broader fixture custody remains TYPE-REFERENCE-BOOK.1.2.23.4.2; canonical CI and normal hooks govern landing.')
    destination.write_bytes(gzip.compress(json.dumps(record, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
    print('signed result-path repair evidence retained')


if __name__ == '__main__':
    capture()
