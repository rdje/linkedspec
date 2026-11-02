"""Retain the exact authored punctuation-fixture repair epoch, once."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
SCRATCH = ROOT / '.linkedspec-data/normal-hook-restoration'
REVISION = '0db5e9e87b7c1cfaf09936b9629974787038f5e3'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(),
                sha256=hashlib.sha256(raw).hexdigest())


def capture():
    destination = HERE / 'punctuation-intake.json.gz'
    if destination.exists():
        raise ValueError('retain prior punctuation epochs rather than replacing them')
    before = json.loads((SCRATCH / 'punctuation-before-inputs.json').read_bytes())
    book = 'docs/linkedspec-book/src/appendix/formal-grammar.md'
    old_book = base64.b64decode(before[book]['base64']).decode()
    new_book = (ROOT / book).read_text()
    start = "Rust, Dart, Julia, and Lua's pre-existing zero-argument"
    old_paragraph = old_book[old_book.index(start):].split('\n\n', 1)[0]
    start = 'With no authored needle'
    new_paragraph = new_book[new_book.index(start):].split('\n\n', 1)[0]
    if old_book.replace(old_paragraph, new_paragraph, 1) != new_book:
        raise ValueError('unreviewed formal-grammar edit')
    names = subprocess.check_output(
        ['git', 'ls-tree', '-rz', '--name-only', REVISION, '--', 'perl', 'specs'],
        cwd=ROOT).split(b'\0')
    source_epoch = {}
    for encoded in names:
        if not encoded:
            continue
        name = encoded.decode()
        raw = subprocess.check_output(['git', 'show', REVISION + ':' + name], cwd=ROOT)
        if (ROOT / name).read_bytes() != raw:
            raise ValueError('unexpected runtime source edit: ' + name)
        source_epoch[name] = hashlib.sha256(raw).hexdigest()
    failure = HERE / 'canonical-punctuation-failure.log.gz'
    record = dict(
        schema_version=1, owner='TYPE-REFERENCE-BOOK.1.2.20.1.12',
        activation_commit=REVISION, before=before,
        after={name: packet((ROOT / name).read_bytes()) for name in before},
        channels={name: packet((SCRATCH / name).read_bytes()) for name in (
            'punctuation-before.log', 'punctuation-after.log',
            'punctuation-probe.jsonl', 'punctuation-probe.stderr',
            'punctuation-public-lowering.jsonl', 'punctuation-review-initial.log')},
        producers={str(path.relative_to(ROOT)): packet(path.read_bytes()) for path in (
            HERE / 'punctuation_probe.pl', HERE / 'punctuation_lowering.pl',
            Path(__file__), HERE / 'punctuation_review.py',
            ROOT / 'tools/run_mdbook_local.sh', ROOT / 'tools/project_data_run.sh',
            ROOT / 'tools/project_data_env.sh')},
        runtime_source_epoch=source_epoch,
        canonical_failure=dict(path=str(failure.relative_to(ROOT)),
                               sha256=hashlib.sha256(failure.read_bytes()).hexdigest()),
        book=dict(path=book, edit=dict(before=old_paragraph, after=new_paragraph),
                  rendered=packet((ROOT / 'docs/linkedspec-book/book/appendix/formal-grammar.html').read_bytes())),
        limits='Exact authored programs and declared immutable Perl/spec source epoch; no complete transitive generation-input, new runtime implementation or portable feature admission claim. Broader input custody/admission remain TYPE23.4.2/23.4.')
    destination.write_bytes(gzip.compress(json.dumps(record, sort_keys=True).encode(), mtime=0))
    print('punctuation epoch retained with actual RED/GREEN and public native/fresh controls')


if __name__ == '__main__':
    capture()
