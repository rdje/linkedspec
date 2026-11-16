"""Qualify one retained Dart export regex; preserve the original reader and failure."""
import contextlib
import gzip
import hashlib
import io
import json
from pathlib import Path
import stat
import tarfile
import types

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
OLD = b"re.findall(r'^\\S+ (observe\\w+)\\(', body, re.M)"
NEW = b"re.findall(r'^Map<String, Object\\?> (observe\\w+)\\(', body, re.M)"


def qualified_source():
    original = (BASE / 'review.py').read_bytes()
    expected = json.loads((BASE / 'identities.json').read_bytes())[str(BASE / 'review.py')]['sha256']
    assert hashlib.sha256(original).hexdigest() == expected, 'original reader unchanged'
    assert original.count(OLD) == 1 and NEW not in original, 'single export interpretation correction'
    return original, original.replace(OLD, NEW, 1)


def load_source(body, name):
    module = types.ModuleType(name)
    module.__file__ = str(BASE / 'review.py')
    exec(compile(body, str(BASE / (name + '.py')), 'exec'), module.__dict__)
    return module


def verify_qualification(current):
    identities = json.loads((BASE / 'qualification-identities.json').read_bytes())
    seen = set()
    with tarfile.open(BASE / 'qualification-sources.tar.gz') as archive:
        assert len(archive.getmembers()) == len(identities)
        for member in archive:
            assert member.isfile() and member.name in identities and member.name not in seen
            assert not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            body = archive.extractfile(member).read(); row = identities[member.name]
            assert hashlib.sha256(body).hexdigest() == row['sha256'] and len(body) == row['bytes']
            assert stat.S_IMODE(member.mode) == row['mode']
            if current:
                path = Path(member.name)
                assert path.is_file() and not path.is_symlink() and path.read_bytes() == body
                assert stat.S_IMODE(path.stat().st_mode) == row['mode']
            seen.add(member.name)
    assert seen == set(identities)
    original, qualified = qualified_source()
    assert gzip.decompress((BASE / 'qualified-source.py.gz').read_bytes()) == qualified
    assert (BASE / 'capture-exit.txt').read_text() == '1\n'
    assert b'AssertionError: observation support export' in gzip.decompress((BASE / 'capture-stderr.gz').read_bytes())
    baseline = load_source(original, 'retained_original_reader')
    sources, _ = baseline.recover()
    try:
        baseline.reconstruct(sources)
    except AssertionError as error:
        assert str(error) == 'observation support export'
    else:
        raise AssertionError('original reader no longer distinguishes its export refusal')
    return qualified


def main():
    import sys
    qualified = verify_qualification('--current' in sys.argv[1:])
    module = load_source(qualified, 'qualified_export_reader')
    output = io.StringIO()
    with contextlib.redirect_stdout(output):
        module.main()
    result = json.loads(output.getvalue())
    result['qualification'] = dict(original_capture_exit=1, original_reader_refusal='observation support export',
        changed_expression='Only observe entrypoint return-type regex: single token -> exact Map<String, Object?>',
        original_source_unchanged=True, capture_replayed=False, dart_executed=False)
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
