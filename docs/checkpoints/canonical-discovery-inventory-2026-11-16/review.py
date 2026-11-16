"""Read retained source/selector evidence; never execute SDKs or old capture writers."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import shlex
import stat
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = 'e3940a675d6313b226c6492198cbdb60c18b78dd'


def source_archive(phase):
    folder = BASE / 'launches' / phase
    identities = json.loads((folder / 'source-identities.json').read_bytes())
    with tarfile.open(folder / 'sources-before-child.tar.gz') as archive:
        assert set(archive.getnames()) == identities.keys(), 'project source namespace'
        for member in archive:
            assert member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            assert hashlib.sha256(archive.extractfile(member).read()).hexdigest() == identities[member.name]['sha256']
            assert member.mode & 0o777 == identities[member.name]['mode']
    return identities


def plan_archive(metadata):
    folder = BASE / 'plan-archive'
    result = json.loads((folder / 'result.json').read_bytes())
    assert result['activation'] == ACTIVATION
    legacy = Path(result['legacy_archive']).read_bytes()
    assert hashlib.sha256(legacy).hexdigest() == result['legacy_archive_sha256']
    assert hashlib.sha1(b'blob ' + str(len(legacy)).encode() + b'\0' + legacy).hexdigest() == metadata[result['legacy_archive']]['blob']
    canonical_source = 'docs/checkpoints/canonical-discovery-plan-2026-11-16/publish.py'
    assert result['canonical_source'] == canonical_source
    source = gzip.decompress((folder / 'publisher-source-stdout.gz').read_bytes())
    assert hashlib.sha1(b'blob ' + str(len(source)).encode() + b'\0' + source).hexdigest() == metadata[canonical_source]['blob']
    expected, aliases = [], 0
    with tarfile.open(result['legacy_archive']) as archive:
        for member in archive:
            assert member.isfile()
            body = archive.extractfile(member).read()
            name = member.name
            if name not in metadata:
                assert hashlib.sha256(name.encode()).hexdigest() == result['legacy_source_name_sha256']
                assert body == source
                name, aliases = canonical_source, aliases + 1
            expected.append((name, body, member.mode))
    assert aliases == 1
    qualified = Path(result['qualified_archive'])
    assert hashlib.sha256(qualified.read_bytes()).hexdigest() == result['qualified_sha256']
    actual = []
    with tarfile.open(qualified) as archive:
        for member in archive:
            assert member.isfile() and member.name in metadata and not Path(member.name).is_absolute()
            actual.append((member.name, archive.extractfile(member).read(), member.mode))
    assert actual == expected and len({row[0] for row in actual}) == len(actual), 'qualified archive body/mode population'
    for name in ('native-names', 'native-modes', 'native-bodies', 'legacy-blob', 'publisher-source', 'root-tree'):
        assert (folder / (name + '-exit.txt')).read_text() == '0\n'
        assert gzip.decompress((folder / (name + '-stderr.gz')).read_bytes()) == b''
    assert gzip.decompress((folder / 'native-names-stdout.gz').read_bytes()).decode().splitlines() == [row[0] for row in actual]
    assert gzip.decompress((folder / 'native-bodies-stdout.gz').read_bytes()) == b''.join(row[1] for row in actual)
    modes = gzip.decompress((folder / 'native-modes-stdout.gz').read_bytes()).decode().splitlines()
    assert len(modes) == len(actual)
    for line, (name, _, mode) in zip(modes, actual):
        assert line.startswith(stat.filemode(stat.S_IFREG | mode)) and line.endswith(' ' + name)
    assert result['legacy_namespace'] == 'observed RED'
    assert result['rejected'] == ['missing', 'duplicate', 'unsafe-path', 'body', 'mode']
    source_archive('plan-archive')
    return dict(result='PASS', canonical_members=len(actual), original_retained=True)


def channel(tag, kind):
    return gzip.decompress((BASE / (tag + '-' + kind + '.gz')).read_bytes())


def events(wire):
    cells = wire.split(b'\0')
    assert cells.pop() == b'' and len(cells) % 2 == 0, 'selector wire'
    return [dict(kind=cells[index].decode(), path=cells[index + 1].decode()) for index in range(0, len(cells), 2)]


def expected_events(source):
    """Interpret the fixed selector vocabulary separately from its Bash producer."""
    arrays, result = {}, []
    active = None
    in_loop = False
    loop_body = []
    for line in source.splitlines():
        if active is not None:
            if line == ')':
                active = None
            else:
                arrays[active].extend(shlex.split(line, comments=True))
            continue
        if line in ('private_factory_suites=(', 'private_factory_helpers=('):
            active = line.split('=')[0]
            arrays[active] = []
            continue
        if line.startswith('for private_factory_input in '):
            assert not in_loop
            in_loop = True
            loop_body = []
            continue
        if in_loop:
            if line == 'done':
                assert loop_body == [' require_tracked_file "$private_factory_input"', ' perl -c -Iperl "$private_factory_input"']
                for name in arrays['private_factory_suites'] + arrays['private_factory_helpers']:
                    result.extend([dict(kind='declared_presence', path=name), dict(kind='declared_syntax', path=name)])
                in_loop = False
            else:
                loop_body.append(line)
            continue
        if not line or line[0].isspace():
            continue
        if line.startswith('require_tracked_file '):
            words = shlex.split(line, comments=True)
            assert len(words) == 2
            result.append(dict(kind='declared_presence', path=words[1]))
        elif line.startswith('perl -c '):
            result.append(dict(kind='declared_syntax', path=shlex.split(line)[-1]))
        else:
            words = shlex.split(line, comments=True) if re.search(r'(^|[ \t])prove[ \t]', line) else []
            position = words.index('prove') if 'prove' in words else -1
            if position >= 0 and all('=' in word and word.partition('=')[0].isidentifier() for word in words[:position]):
                words = words[position + 1:]
                expanded = []
                for word in words:
                    if word == '${private_factory_suites[@]}':
                        expanded.extend(arrays['private_factory_suites'])
                    else:
                        assert '$' not in word, 'unhandled selector variable'
                        expanded.append(word)
                result.extend(dict(kind='selected_test', path=word) for word in expanded if word.endswith('.t'))
    assert active is None and not in_loop
    return result


def packets(raw, names, metadata):
    result, cursor = {}, 0
    for name in sorted(names):
        end = raw.index(b'\n', cursor)
        header = raw[cursor:end].decode().split()
        assert len(header) == 3 and header[:2] == [metadata[name]['blob'], 'blob'], 'source packet header'
        size = int(header[2])
        body = raw[end + 1:end + size + 1]
        assert len(body) == size and raw[end + size + 1:end + size + 2] == b'\n'
        assert hashlib.sha1(b'blob ' + str(size).encode() + b'\0' + body).hexdigest() == header[0], 'source blob identity'
        result[name] = body
        cursor = end + size + 2
    assert cursor == len(raw), 'source packet tail'
    return result


def read_evidence():
    report = json.loads(gzip.decompress((BASE / 'inventory.json.gz').read_bytes()))
    assert report['activation'] == ACTIVATION and report['owner'] == 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.0'
    metadata = {}
    for row in channel('git-tree', 'stdout').split(b'\0'):
        if row:
            header, path = row.split(b'\t', 1)
            mode, kind, blob = header.decode().split()
            if kind == 'blob' and mode in ('100644', '100755'):
                metadata[path.decode()] = dict(mode=mode, blob=blob)
    sources = {}
    for command in sorted(BASE.glob('*blobs*-command.json')):
        tag = command.name.removesuffix('-command.json')
        if tag.endswith('-sizes'):
            continue
        request = channel(tag, 'stdin').decode().splitlines()
        ordered = json.loads((BASE / (tag + '-paths.json')).read_bytes())
        assert ordered == sorted(ordered), 'source acquisition order'
        assert [metadata[name]['blob'] for name in ordered] == request, 'source request identity'
        acquired = packets(channel(tag, 'stdout'), ordered, metadata)
        assert not sources.keys() & acquired.keys(), 'source acquired twice'
        sources.update(acquired)
    assert sources.keys() == report['sources'].keys(), 'source population'
    for name, row in report['sources'].items():
        assert dict(mode=row['mode'], blob=row['blob']) == metadata[name]
        assert hashlib.sha256(sources[name]).hexdigest() == row['sha256'], 'retained source hash'
    ci = sources['tools/run_ci_local.sh'].decode()
    observed = events(channel('perl-selector', 'stdout'))
    assert observed == expected_events(ci) == report['perl_events'], 'actual Bash selector population/order'
    for command in BASE.glob('*-command.json'):
        tag = command.name.removesuffix('-command.json')
        assert (BASE / (tag + '-exit.txt')).read_text() == '0\n', 'native exit:' + tag
        assert channel(tag, 'stderr') == b'', 'native stderr:' + tag
    identities = source_archive('capture')
    with tarfile.open(BASE / 'producer-inputs.tar.gz') as archive:
        for member in archive:
            assert member.isfile() and '..' not in Path(member.name).parts
            assert hashlib.sha256(archive.extractfile(member).read()).hexdigest() == identities[member.name]['sha256'], 'producer capture identity'
            assert member.mode & 0o777 == identities[member.name]['mode']
    return report, sources, metadata


def main():
    report, sources, metadata = read_evidence()
    qualified_archive = plan_archive(metadata)
    # A separate Git invocation checks the exact activation population, not today's files.
    actual = subprocess.check_output(['git', 'ls-tree', '-rz', ACTIVATION])
    assert actual == channel('git-tree', 'stdout'), 'activation Git inventory'
    rows = report['rows']
    assert [row['path'] for row in rows] == sorted({row['path'] for row in rows}), 'duplicate/unsorted consumer'
    expected_paths = set(channel('git-universe', 'stdout').decode().rstrip('\0').split('\0'))
    expected_paths = {name for name in expected_paths if not name.startswith('rust/') or name.count('/') == 3}
    expected_paths.update(event['path'] for event in report['perl_events'] if event['kind'] == 'selected_test')
    assert {row['path'] for row in rows} == expected_paths, 'independent Git consumer population'
    for row in rows:
        assert row['path'] in metadata and row['path'] in sources
        assert row['sha256'] == hashlib.sha256(sources[row['path']]).hexdigest()
        lines = sources[row['path']].decode('utf-8', 'surrogateescape').splitlines()
        for site in row['loader_sites']:
            assert site['source'] == lines[site['line'] - 1], 'loader source location'
        assert all(path in metadata for path in row['literal_tracked_references']), 'candidate reference identity'
    if (BASE / 'controls.json').exists():
        controls = json.loads((BASE / 'controls.json').read_bytes())
        expected = expected_events(sources['tools/run_ci_local.sh'].decode())
        for item in controls['rejected']:
            tag = 'controls/' + item['name']
            assert (BASE / (tag + '-exit.txt')).read_text() == '0\n'
            assert channel(tag, 'stderr') == b'' and events(channel(tag, 'stdout')) != expected
            assert item['oracle'] == 'RED' and item['shell_exit'] == 0
    result = dict(result='PASS', consumers=len(rows), required=sum(row['required'] for row in rows),
        qualified_archive=qualified_archive,
        direct_perl_omissions=[row['path'] for row in rows if row['required'] and row['backend'] == 'perl' and row['declared_route'] == 'no-direct-unconditional-perl-selector'],
        limits=report['limits'])
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
