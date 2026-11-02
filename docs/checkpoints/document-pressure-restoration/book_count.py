"""Exact owner22 CLI-count correction and preserved storage-evidence source view."""
import argparse
import base64
import gzip
import hashlib
from html.parser import HTMLParser
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OWNER = 'TYPE-REFERENCE-BOOK.1.2.20.1.22'
BOOK = 'docs/linkedspec-book/src/development/local-ci-and-regression.md'
READER = 'docs/checkpoints/document-pressure-restoration/storage_inventory.py'
OLD = 'runs the focused runner/trace suites and all 61 primary CLI cases under default and POSIX option environments'
NEW = 'runs the focused runner/trace suites and all 66 primary CLI cases under default and POSIX option environments'
READER_EDITS = [
    ('def review():\n', '''def review():
    # Owner22 validates actual current book/reader bytes before exposing the exact
    # predecessor view expected by the unchanged component19 evidence capsule.
    from book_count import storage_read
'''),
    ("        assert (ROOT / name).read_bytes() == decode(row), 'storage evidence input drift: ' + name\n",
     "        assert storage_read(name) == decode(row), 'storage evidence input drift: ' + name\n"),
    ('                 (ROOT / book).read_text(), approval[\'books\'][book])\n',
     '                 storage_read(book).decode(), approval[\'books\'][book])\n'),
]


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=sha(raw))


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert sha(raw) == row['sha256']
    return raw


def intake():
    data = json.loads(gzip.decompress((HERE / 'book-count-intake.json.gz').read_bytes()))
    assert data['owner'] == OWNER
    return data


def changed_reader(before):
    source = before.decode()
    for old, new in READER_EDITS:
        assert source.count(old) == 1, 'storage reader edit anchor'
        source = source.replace(old, new, 1)
    return source.encode()


def validate_current(book=None, reader=None):
    saved = intake()
    before_book, before_reader = (decode(saved['inputs'][name]) for name in (BOOK, READER))
    assert before_book.decode().count(OLD) == 1
    book = (ROOT / BOOK).read_bytes() if book is None else book
    reader = (ROOT / READER).read_bytes() if reader is None else reader
    assert book == before_book.decode().replace(OLD, NEW, 1).encode(), 'unreviewed current CLI-count book change'
    assert reader == changed_reader(before_reader), 'unreviewed storage reader evolution'
    return saved


def storage_read(name):
    """Only two exact, independently verified source transitions have a legacy view."""
    saved = validate_current()
    if name in (BOOK, READER):
        return decode(saved['inputs'][name])
    return (ROOT / name).read_bytes()


def capture_intake():
    destination = HERE / 'book-count-intake.json.gz'
    assert not destination.exists()
    names = [BOOK, READER, 'cli_conformance/manifest.json', 'tools/run_cli_conformance.pl',
             'tools/run_ci_local.sh', 'tools/run_mdbook_local.sh', 'docs/linkedspec-book/book.toml',
             'docs/checkpoints/document-pressure-restoration/book_review.py',
             'docs/checkpoints/document-pressure-restoration/book-edits.json',
             'docs/checkpoints/document-pressure-restoration/storage-evidence-accepted.json.gz',
             'tools/project_data_run.sh', 'tools/project_data_env.sh', 'tools/run_python_project_data.sh',
             str(Path(__file__).relative_to(ROOT))]
    saved = dict(owner=OWNER, inputs={n: packet((ROOT / n).read_bytes()) for n in names},
        interrupted_run=packet((ROOT / '.linkedspec-data/normal-hook-restoration/canonical-ci.log').read_bytes()),
        interrupted_exit=143,
        limits='Complete interrupted38905, not a completed canonical pass. Default CLI leg passes; POSIX/Phase0/final receipt do not receive completion credit. Preserves exact preceding book and storage-evidence reader sources before correction.')
    destination.write_bytes(gzip.compress(json.dumps(saved, sort_keys=True, separators=(',', ':')).encode(), mtime=0))


def apply():
    saved = intake()
    for name in (BOOK, READER):
        assert (ROOT / name).read_bytes() == decode(saved['inputs'][name]), 'pre-edit source drift'
    (ROOT / BOOK).write_text(decode(saved['inputs'][BOOK]).decode().replace(OLD, NEW, 1))
    (ROOT / READER).write_bytes(changed_reader(decode(saved['inputs'][READER])))
    validate_current()


def capture():
    destination = HERE / 'book-count-evidence.json.gz'
    assert not destination.exists()
    validate_current()
    names = [BOOK, READER, 'cli_conformance/manifest.json', 'tools/run_cli_conformance.pl',
             'tools/run_mdbook_local.sh', 'docs/linkedspec-book/book.toml',
             'tools/project_data_run.sh', 'tools/project_data_env.sh', 'tools/run_python_project_data.sh',
             str(Path(__file__).relative_to(ROOT))]
    scratch = ROOT / '.linkedspec-data/normal-hook-restoration'
    saved = dict(owner=OWNER, intake_sha256=sha((HERE / 'book-count-intake.json.gz').read_bytes()),
        inputs={n: packet((ROOT / n).read_bytes()) for n in names},
        book_build=packet((scratch / 'book-count-build.log').read_bytes()),
        storage_review=packet((scratch / 'book-count-storage-review.log').read_bytes()),
        rendered=packet((ROOT / 'docs/linkedspec-book/book/development/local-ci-and-regression.html').read_bytes()),
        limits='One current summary token changes61 to66; all historical observations and other words remain exact. Actual manifest and interrupted default CLI producer independently establish66; old and missing/current/source mutations reject. Current source transitions are separately verified before the component19 historical book/reader view. No storage oracle/population or execution-profile change, whole CI success, or transitive mdBook-generator closure follows.')
    destination.write_bytes(gzip.compress(json.dumps(saved, sort_keys=True, separators=(',', ':')).encode(), mtime=0))


def review():
    prior = validate_current()
    saved = json.loads(gzip.decompress((HERE / 'book-count-evidence.json.gz').read_bytes()))
    assert saved['owner'] == OWNER and saved['intake_sha256'] == sha((HERE / 'book-count-intake.json.gz').read_bytes())
    for name, row in saved['inputs'].items():
        assert (ROOT / name).read_bytes() == decode(row), 'CLI-count input drift: ' + name
    manifest = json.loads(decode(saved['inputs']['cli_conformance/manifest.json']))
    assert manifest['suite'] == 'linkedspec-primary-cli' and len(manifest['cases']) == 66
    assert len({r['id'] for r in manifest['cases']}) == 66
    run = decode(prior['interrupted_run'])
    assert prior['interrupted_exit'] == 143 and b'[ci] running primary CLI conformance (POSIX option environment)' in run
    first_leg = run.split(b'[ci] running primary CLI conformance (default option environment)\n', 1)[1].split(b'[ci] running primary CLI conformance (POSIX option environment)', 1)[0]
    assert len(re.findall(rb'^\[cli-conformance\] PASS ', first_leg, re.M)) == 66
    assert b'local CI gate passed' not in run, 'interrupted run promoted'
    before_book, before_reader = (decode(prior['inputs'][name]) for name in (BOOK, READER))
    book, reader = (ROOT / BOOK).read_bytes(), (ROOT / READER).read_bytes()
    for label, bad_book, bad_reader in (
        ('stale-count', before_book, reader), ('book-loss', book + b'\nunreviewed\n', reader),
        ('wrong-count', book.replace(NEW.encode(), NEW.replace('66', '67').encode(), 1), reader),
        ('old-reader', book, before_reader), ('reader-loss', book, reader + b'# unreviewed\n')):
        try:
            validate_current(bad_book, bad_reader)
        except AssertionError:
            pass
        else:
            raise AssertionError('CLI-count corruption admitted: ' + label)
    assert b'HTML book written to' in decode(saved['book_build'])
    assert b'storage inventory: four exact populations' in decode(saved['storage_review'])
    class Visible(HTMLParser):
        def __init__(self):
            super().__init__(); self.parts = []
        def handle_data(self, data):
            self.parts.append(data)
    visible = Visible(); visible.feed(decode(saved['rendered']).decode())
    assert NEW in ' '.join(''.join(visible.parts).split())
    return dict(current_cases=66, exact_book_replacements=1, historical_counts_preserved=True,
                source_and_count_mutations_rejected=5, interrupted_run_exit=143, limits=saved['limits'])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--intake', action='store_true')
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--capture', action='store_true')
    args = parser.parse_args()
    if args.intake:
        capture_intake()
    elif args.apply:
        apply()
    else:
        if args.capture:
            capture()
        print(json.dumps(review(), sort_keys=True))
