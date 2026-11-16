"""Capture a source inventory and actual Bash selector arguments, without SDK runs."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import posixpath
import re
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = 'e3940a675d6313b226c6492198cbdb60c18b78dd'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.0'
SOURCE_BYTES = 0
ENTRYPOINTS = ('tools/run_ci_local.sh', 'tools/run_rust_local.sh',
               'tools/run_dart_local.sh', 'tools/run_julia_local.sh',
               'tools/run_lua_local.sh', 'lua/test/run.lua', 'julia/test/runtests.jl')
PARTS = ('docs/tasks/TYPE-REFERENCE-BOOK.overview.md',
         'docs/tasks/TYPE-REFERENCE-BOOK.helpers-01-39.md',
         'docs/tasks/TYPE-REFERENCE-BOOK.helpers-40-59.md',
         'docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md')


def native(tag, command, data=None):
    prefix = BASE / tag
    prefix.parent.mkdir(parents=True, exist_ok=True)
    command_path = prefix.with_name(prefix.name + '-command.json')
    assert not command_path.exists(), 'one-shot command:' + tag
    command_path.write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    if data is not None:
        prefix.with_name(prefix.name + '-stdin.gz').write_bytes(gzip.compress(data, mtime=0))
    result = subprocess.run(command, input=data, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for name in ('stdout', 'stderr'):
        prefix.with_name(prefix.name + '-' + name + '.gz').write_bytes(gzip.compress(getattr(result, name), mtime=0))
    prefix.with_name(prefix.name + '-exit.txt').write_text(str(result.returncode) + '\n')
    assert result.returncode == 0 and result.stderr == b'', 'actual command channels retained:' + tag
    return result.stdout


def backend(path):
    if path.startswith('t/') and path.endswith('.t'):
        return 'perl'
    if path.startswith('rust/linkedspec-runtime/tests/') and path.endswith('.rs') and path.count('/') == 3:
        return 'rust'
    for family, suffix in (('dart', '_test.dart'), ('julia', '_test.jl'), ('lua', '_test.lua')):
        if path.startswith(family + '/test/') and path.endswith(suffix):
            return family
    return None


def literal_references(name, text, files):
    references = set()
    for quoted in re.finditer(r'''["']([^"'\n]+)["']''', text):
        value = quoted[1]
        if value in files:
            references.add(value)
        if not value.startswith('/'):
            try:
                relative = posixpath.normpath(posixpath.join(str(Path(name).parent), value))
            except ValueError:
                continue
            if relative in files:
                references.add(relative)
    return sorted(references)


def loader_sites(text):
    return [dict(line=number, source=line,
                 classification='potential loader keyword line; comments, strings, input/output and execution not resolved')
            for number, line in enumerate(text.splitlines(), 1)
            if re.search(r'\b(?:open|read|read_to_string|readAsStringSync|readAsString|include_str|include|dofile|File|load_fixture|load_cases|use|require|import|source|system|exec|run|Process|Command)\b', line)]


def read_blobs(tag, names, files):
    global SOURCE_BYTES
    names = sorted(names)
    with (BASE / (tag + '-paths.json')).open('x') as stream:
        json.dump(names, stream, indent=2)
        stream.write('\n')
    requests = ''.join(files[name]['blob'] + '\n' for name in names).encode()
    sizes = native(tag + '-sizes', ['git', 'cat-file', '--batch-check=%(objectname) %(objecttype) %(objectsize)'], requests)
    rows = [line.split() for line in sizes.decode().splitlines()]
    assert len(rows) == len(names) and all(row[1] == 'blob' for row in rows)
    SOURCE_BYTES += sum(int(row[2]) for row in rows)
    assert SOURCE_BYTES <= 256 * 1024 * 1024, 'bounded cumulative source acquisition'
    packed = native(tag, ['git', 'cat-file', '--batch'], requests)
    bodies, offset = {}, 0
    for name in names:
        end = packed.index(b'\n', offset)
        blob, kind, count = packed[offset:end].decode().split()
        count = int(count)
        assert blob == files[name]['blob'] and kind == 'blob'
        body = packed[end + 1:end + 1 + count]
        assert len(body) == count and packed[end + 1 + count:end + 2 + count] == b'\n'
        assert hashlib.sha1(b'blob ' + str(count).encode() + b'\0' + body).hexdigest() == blob
        if name != PARTS[0]:
            path = ROOT / name
            assert not path.is_symlink() and path.resolve().is_relative_to(ROOT)
            assert path.stat().st_dev == ROOT.stat().st_dev and path.read_bytes() == body, 'source changed:' + name
        bodies[name] = body
        offset = end + 2 + count
    assert offset == len(packed)
    return bodies


def selector_script(source):
    """Copy the actual unconditional Perl selector statements in source order."""
    chunks = []
    patterns = (r'^private_factory_(?:suites|helpers)=\([\s\S]*?^\)\n',
                r'^for private_factory_input in[^\n]*\n[\s\S]*?^done\n',
                r'^(?:require_tracked_file[ \t]+[^\n]+|perl -c[ \t]+[^\n]+|(?:[A-Z_][A-Z0-9_]*=[^ \t\n]*[ \t]+)*prove[ \t]+[^\n]+)\n')
    for pattern in patterns:
        for match in re.finditer(pattern, source, re.M):
            chunks.append((match.start(), match.end(), match[0]))
    chunks.sort()
    assert all(left[1] <= right[0] for left, right in zip(chunks, chunks[1:]))
    for _, _, body in chunks:
        assert '$(' not in body and '`' not in body, 'unreviewed command substitution'
    prelude = '''#!/usr/bin/env bash
set -euo pipefail
require_tracked_file() { printf 'declared_presence\\0%s\\0' "$1"; }
perl() { printf 'declared_syntax\\0%s\\0' "${@: -1}"; }
prove() {
 for selected in "$@"; do
  case "$selected" in *.t) printf 'selected_test\\0%s\\0' "$selected" ;; esac
 done
}
'''
    return prelude + ''.join(body for _, _, body in chunks), [dict(start=start, end=end) for start, end, _ in chunks]


def main():
    assert not (BASE / 'inventory.json.gz').exists(), 'one-shot inventory'
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    producers = (BASE / 'capture.py', BASE / 'review.py', BASE / 'controls.py', Path('tools/project_data_run.sh'),
                 Path('tools/project_data_env.sh'), Path('tools/run_python_project_data.sh'))
    with tarfile.open(BASE / 'producer-inputs.tar.gz', 'x:gz') as archive:
        for path in producers:
            assert not path.is_absolute() and '..' not in path.parts
            assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
            archive.add(path, arcname=str(path), recursive=False)
    memory = native('memory', ['memory_pressure'])
    free = re.search(rb'System-wide memory free percentage: (\d+)%', memory)
    assert free and int(free[1]) >= 45, 'conservative headroom before bounded serial source acquisition'
    listing = native('git-tree', ['git', 'ls-tree', '-rz', ACTIVATION])
    files = {}
    for item in listing.split(b'\0'):
        if item:
            header, name = item.split(b'\t', 1)
            mode, kind, blob = header.decode().split()
            if kind == 'blob' and mode in ('100644', '100755'):
                files[name.decode()] = dict(mode=mode, blob=blob)
    cached_origin = native('cached-origin', ['git', 'rev-parse', 'refs/remotes/origin/main']).decode().strip()
    changed = set(native('unpublished-paths', ['git', 'diff', '--name-only', '-z',
        cached_origin, ACTIVATION]).decode().rstrip('\0').split('\0'))
    native('git-universe', ['git', 'ls-files', '-z', '--', 't/*.t', 't/**/*.t',
        'rust/linkedspec-runtime/tests/*.rs', 'dart/test/*_test.dart', 'dart/test/**/*_test.dart',
        'julia/test/*_test.jl', 'julia/test/**/*_test.jl', 'lua/test/*_test.lua', 'lua/test/**/*_test.lua'])
    consumers = {name: backend(name) for name in files if backend(name)}
    needed = sorted(set(consumers) | set(ENTRYPOINTS) | set(PARTS))
    for name in needed:
        assert name in files, 'missing declared source:' + name
    bodies = read_blobs('source-blobs', needed, files)
    tasks = []
    for part in PARTS:
        text = bodies[part].decode()
        for node in re.finditer(r'^- ID: `([^`]+)`\n(.*?)(?=^- ID:|\Z)', text, re.M | re.S):
            status = re.search(r'^  Status: `([^`]+)`', node[2], re.M)
            tasks.append(dict(id=node[1], status=status[1] if status else 'unspecified', body=node[2]))
    parent, = [node for node in tasks if node['id'] == 'TYPE-REFERENCE-BOOK.1.2.23.4.1']
    script, chunks = selector_script(bodies[ENTRYPOINTS[0]].decode())
    (BASE / 'perl-selector.sh').write_text(script)
    wire = native('perl-selector', ['bash', '--noprofile', '--norc', str(BASE / 'perl-selector.sh')])
    cells = wire.split(b'\0')
    assert cells.pop() == b'' and len(cells) % 2 == 0
    events = [dict(kind=cells[index].decode(), path=cells[index + 1].decode()) for index in range(0, len(cells), 2)]
    selected = {event['path'] for event in events if event['kind'] == 'selected_test'}
    external = sorted(selected - consumers.keys())
    if external:
        assert all(name in files and name.endswith('.t') for name in external)
        bodies.update(read_blobs('external-selected-blobs', external, files))
        consumers.update({name: 'perl' for name in external})
    support, frontier, visited = set(), set(consumers), set(consumers)
    source_suffixes = {'.pl', '.pm', '.lua', '.dart', '.jl', '.rs', '.py', '.sh', '.spec'}
    layer = 0
    while frontier:
        references = {reference for name in frontier
                      for reference in literal_references(name, bodies[name].decode('utf-8', 'surrogateescape'), files)}
        new = sorted(name for name in references if name not in visited and Path(name).suffix in source_suffixes)
        if not new:
            break
        missing_bodies = [name for name in new if name not in bodies]
        if missing_bodies:
            bodies.update(read_blobs('helper-blobs-' + str(layer), missing_bodies, files))
        support.update(new)
        visited.update(new)
        frontier, layer = set(new), layer + 1
    graph = {name: dict(literal_tracked_references=literal_references(name, bodies[name].decode('utf-8', 'surrogateescape'), files),
                       loader_sites=loader_sites(bodies[name].decode('utf-8', 'surrogateescape')))
             for name in sorted(set(consumers) | support)}
    rows = []
    for name, family in sorted(consumers.items()):
        text = bodies[name].decode()
        basename = name.rsplit('/', 1)[1]
        token = re.compile(r'(?<![A-Za-z0-9_.-])' + re.escape(basename) + r'(?![A-Za-z0-9_.-])')
        references = [dict(id=node['id'], status=node['status']) for node in tasks if name in node['body'] or token.search(node['body'])]
        completed_reference = any(reference['status'].split()[0] in ('completed', 'verified', 'closed') for reference in references)
        parent_named = name in parent['body'] or bool(token.search(parent['body']))
        normal_root = family == 'dart' or name.count('/') == (3 if family == 'rust' else 1 if family == 'perl' else 2)
        required = parent_named or name in changed and normal_root
        if family == 'perl':
            route = 'direct-unconditional-perl-selector' if name in selected else 'no-direct-unconditional-perl-selector'
        elif family == 'rust':
            route = 'optional-Rust-package-test; automatic-target-discovery-not-executed'
        elif family == 'dart':
            route = 'optional-Dart-test-command; automatic-discovery-not-executed'
        else:
            entry = 'lua/test/run.lua' if family == 'lua' else 'julia/test/runtests.jl'
            indirect = basename in bodies[entry].decode()
            direct = family == 'lua' and name in bodies['tools/run_lua_local.sh'].decode()
            route = 'optional-source-reference:' + ('direct' if direct else 'indirect' if indirect else 'missing')
        rows.append(dict(path=name, backend=family, **files[name], sha256=hashlib.sha256(bodies[name]).hexdigest(),
            required=required, parent_named=parent_named, changed_since_cached_origin=name in changed,
            task_references=references, review_candidate=(completed_reference or name in changed) and not required,
            declared_route=route, **graph[name]))
    assert native('cached-origin-after', ['git', 'rev-parse', 'refs/remotes/origin/main']).decode().strip() == cached_origin
    report = dict(owner=OWNER, activation=ACTIVATION, cached_origin=cached_origin,
        sources={name: dict(**files[name], sha256=hashlib.sha256(body).hexdigest()) for name, body in bodies.items()},
        entrypoints=list(ENTRYPOINTS), task_parts=list(PARTS), rows=rows,
        helpers={name: graph[name] for name in sorted(support)},
        artifact_candidates={name: files[name] for name in sorted({path for item in graph.values() for path in item['literal_tracked_references']})},
        perl_events=events, selector_chunks=chunks,
        limits='Activation-bound source universe and declared routes only. Bash observes selector arguments with presence/syntax/prove stubs, never SDK tests. Literal references are candidate edges; loader expressions do not prove actual per-read/transitive closure. Automatic backend discovery, optional execution, native/toolchain custody and declared5.4 remain unproved under4.1.2/4.2/SESSION5 and their existing owners.')
    (BASE / 'inventory.json.gz').write_bytes(gzip.compress(json.dumps(report, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
    print('source inventory and actual Bash selector channels retained; no SDK test executed')


if __name__ == '__main__':
    main()
