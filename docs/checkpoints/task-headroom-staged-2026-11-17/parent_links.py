"""Capture or recover the bounded current parent-link repair; no task mutation."""
import argparse
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path, PurePosixPath
import re
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PARENT = 'TYPE-REFERENCE-BOOK.1.2.23.4'
PART = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
ACTIVATION = '873003e8901e2b48fd0a289db2540e94bc4d5039'


def node(body, identifier):
    marker = ('- ID: `' + identifier + '`' + chr(10)).encode()
    starts = list(re.finditer(rb'(?m)^' + re.escape(marker), body))
    assert len(starts) == 1, 'unique public node'
    start = starts[0].start()
    end = body.find(bytes([10]) + b'- ID:', starts[0].end())
    return body[start:end if end >= 0 else None]


def linked(body):
    found = node(body, PARENT)
    line, = re.findall(rb'(?m)^  Children: (.*)$', found)
    for suffix in ('.35', '.36'):
        assert line.count(('`' + PARENT + suffix + '`').encode()) == 1, 'required parent link' + suffix
    return found


def recover():
    ids = json.loads((BASE / 'parent-identities.json').read_bytes())
    sources = {}
    with tarfile.open(BASE / 'parent-inputs.tar.gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in sources
            body = archive.extractfile(member).read()
            row = ids[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert stat.S_IMODE(member.mode) == row['mode']
            sources[member.name] = body
    assert set(sources) == set(ids)
    expected = linked(sources[PART])
    def observation(label, argv):
        command = json.loads((BASE / 'commands' / (label + '-command.json')).read_bytes())
        assert command == dict(argv=argv, cwd='.')
        assert (BASE / 'commands' / (label + '-exit.txt')).read_text() == '0\n'
        assert gzip.decompress((BASE / 'commands' / (label + '-stderr.gz')).read_bytes()) == b''
        return gzip.decompress((BASE / 'commands' / (label + '-stdout.gz')).read_bytes())
    original = observation('parent-source-before', ['git', 'show', ACTIVATION + ':' + PART])
    original_parent = node(original, PARENT)
    original_children, = re.findall(rb'(?m)^  Children: (.*)$', original_parent)
    assert ('`' + PARENT + '.35`').encode() not in original_children
    assert ('- ID: `' + PARENT + '.35`' + chr(10)).encode() in original
    for label, identifier in [('parent-current', PARENT), ('child35-current', PARENT + '.35'), ('child36-current', PARENT + '.36')]:
        value = observation(label, ['perl', 'tools/read_task_tree.pl', '--tree', 'TYPE-REFERENCE-BOOK', '--id', identifier])
        assert linked(value) == expected, 'actual current parent block'
        assert node(value, identifier) == node(sources[PART], identifier), 'actual public node source'
    controls = {}
    for suffix in ('.35', '.36'):
        changed = expected.replace(('`' + PARENT + suffix + '`').encode(), b'`omitted-link`', 1)
        try:
            linked(changed)
        except AssertionError as error:
            assert str(error) == 'required parent link' + suffix
            controls[suffix] = 'RED'
        else:
            raise AssertionError('missing parent link accepted')
    return dict(result='PASS', original35_node_present=True, original35_parent_link=False,
        current35_and36_links=True, actual_current_queries=3, controls=controls,
        limits='Only retained source/current public-query parent links. No runtime/canonical selection or complete tool/library/native/first-use/per-read/source-origin/physical closure;4.2/SESSION5 remain.')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--capture', action='store_true')
    args = parser.parse_args()
    if args.capture:
        paths = [Path(PART), Path('docs/tasks/TYPE-REFERENCE-BOOK.index.jsonl'), Path('docs/tasks/TYPE-REFERENCE-BOOK.md'),
            Path('tools/read_task_tree.pl'), BASE / 'capture.py', BASE / 'parent_links.py']
        paths += list(Path('tools/lib').rglob('*.pm'))
        identities = {}
        with tarfile.open(BASE / 'parent-inputs.tar.gz', 'x:gz') as archive:
            for path in sorted(set(paths)):
                assert not path.is_absolute() and not path.is_symlink() and path.stat().st_dev == Path.cwd().stat().st_dev
                body = path.read_bytes()
                identities[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
                archive.add(path, arcname=str(path), recursive=False)
        (BASE / 'parent-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + chr(10))
        spec = importlib.util.spec_from_file_location('epoch_parent_recorder', BASE / 'capture.py')
        recorder = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(recorder)
        recorder.native('parent-source-before', ['git', 'show', ACTIVATION + ':' + PART])
        for label, identifier in [('parent-current', PARENT), ('child35-current', PARENT + '.35'), ('child36-current', PARENT + '.36')]:
            recorder.native(label, ['perl', 'tools/read_task_tree.pl', '--tree', 'TYPE-REFERENCE-BOOK', '--id', identifier])
        result = recover()
        (BASE / 'parent-review.json').write_text(json.dumps(result, indent=2, sort_keys=True) + chr(10))
    else:
        result = recover()
        assert result == json.loads((BASE / 'parent-review.json').read_bytes())
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
