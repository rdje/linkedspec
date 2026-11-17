"""Recover a one-byte scalar reference without trusting a JSON-escaped display."""
import ast
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


def review():
    identities = json.loads((BASE / 'book-byte-identities.json').read_bytes())
    sources = {}
    with tarfile.open(BASE / 'book-byte-inputs.tar.gz') as archive:
        assert len(archive.getmembers()) == len(identities)
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in sources
            body = archive.extractfile(member).read()
            row = identities[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert stat.S_IMODE(member.mode) == row['mode']
            sources[member.name] = body
    assert set(sources) == set(identities)
    book = sources['docs/linkedspec-book/src/development/documentation-workflow.md']
    paragraph = sources[str(BASE / 'book-rendered-paragraph.html')]
    one = bytes([96, 92, 36]) + b'buffer' + bytes([96])
    two = bytes([96, 92, 92, 36]) + b'buffer' + bytes([96])
    assert book.count(one) == 1 and book.count(two) == 0
    assert paragraph.count(b'<code>' + one[1:-1] + b'</code>') == 1
    assert paragraph.count(b'<code>' + two[1:-1] + b'</code>') == 0
    publisher = ast.parse(sources[str(BASE / 'publish.py')])
    value = next(ast.literal_eval(n.value) for n in publisher.body if isinstance(n, ast.Assign)
        and any(isinstance(t, ast.Name) and t.id == 'paragraph' for t in n.targets))
    assert book.count(value.encode()) == 1, 'actual published paragraph unchanged'
    failure = gzip.decompress(sources[str(BASE / 'book-refused.log.gz')])
    assert b'line 15' in failure and b'AssertionError' in failure
    refused = ast.parse(sources[str(BASE / 'qualify_book.py')])
    assert next(n.lineno for n in refused.body if isinstance(n, ast.Assert)) == 15
    assert next(n.lineno for n in ast.walk(refused) if isinstance(n, ast.Call) and isinstance(n.func, ast.Attribute)
        and n.func.attr == 'write_bytes') > 15, 'refusal precedes write'
    assert b'HTML book written' in gzip.decompress(sources[str(BASE / 'book-first.log.gz')])
    expected = list(one + bytes([10]))
    for label, snippet, healthy in [('book-source-byte', one, True), ('book-two-slash-control', two, False)]:
        command = json.loads((BASE / 'commands' / (label + '.json')).read_bytes())
        assert command == dict(argv=['od', '-An', '-tu1'], cwd='.')
        assert (BASE / 'commands' / (label + '-exit.txt')).read_text() == '0\n'
        for channel in ('stdin', 'stdout', 'stderr'):
            data = gzip.decompress((BASE / 'commands' / (label + '-' + channel + '.gz')).read_bytes())
            if channel == 'stdin':
                assert data == snippet + bytes([10])
            elif channel == 'stderr':
                assert not data
            else:
                assert ([int(c) for c in data.split()] == expected) == healthy, 'native byte oracle'
    assert json.loads(json.dumps(one.decode())).encode() == one, 'JSON display roundtrip'
    return dict(result='PASS', source_backslashes=1, rendered_backslashes=1, actual_book_edit=False,
        refused_attempt='Actual guard fails at line15 before writes; source and failure retained after use.',
        independent_od='PASS: ASCII92 once; actual two-backslash command is RED against the single-byte oracle at exit0.',
        limits='Only retained source/render paragraph and command bytes. Full native od/renderer/toolchain/OS/first-use/source-origin/physical closure remains4.2/SESSION5.')


if __name__ == '__main__':
    report = review()
    assert report == json.loads((BASE / 'book-byte-review.json').read_bytes())
    print(json.dumps(report, sort_keys=True))
