"""Prepare exact Git-owned input bytes, without consulting a live worktree."""
from pathlib import Path, PurePosixPath
import gzip
import hashlib
import io
import json
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('prepare.py')


def sha(data):
    return hashlib.sha256(data).hexdigest()


def selected(path, plan):
    return '/' not in path or any(path.startswith(root + '/') for root in plan['roots']) or any(
        path.startswith(prefix) for prefix in plan['checkpoint_prefixes'])


def git_entries(revision):
    rows = subprocess.check_output(['git', 'ls-tree', '-rlz', revision], cwd=ROOT)
    result = []
    for row in filter(None, rows.split(b'\0')):
        meta, name = row.split(b'\t', 1)
        mode, kind, oid, size = meta.split()
        result.append({'path': name.decode(), 'mode': mode.decode(), 'kind': kind.decode(),
                       'oid': oid.decode(), 'bytes': int(size) if size != b'-' else None})
    return result


def blobs(entries):
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for entry in entries:
            process.stdin.write((entry['oid'] + '\n').encode())
            process.stdin.flush()
            oid, kind, size = process.stdout.readline().split()
            assert oid.decode() == entry['oid'] and kind == b'blob'
            size = int(size)
            data = process.stdout.read(size)
            assert len(data) == size and process.stdout.read(1) == b'\n'
            yield entry, data
    finally:
        process.stdin.close()
        process.stdout.close()
        assert process.wait() == 0


def main():
    plan = json.loads(Path(PREFIX + 'plan.json').read_bytes())
    assert subprocess.check_output(['git', 'rev-parse', plan['revision']], cwd=ROOT).decode().strip() == plan['revision']
    entries = [entry for entry in git_entries(plan['revision']) if selected(entry['path'], plan)]
    assert entries and all(entry['mode'] in ('100644', '100755') for entry in entries), 'selected non-regular Git entry'
    assert all(not PurePosixPath(entry['path']).is_absolute() and '..' not in PurePosixPath(entry['path']).parts for entry in entries)
    files = {}
    output = io.BytesIO()
    with gzip.GzipFile(fileobj=output, mode='wb', filename='', mtime=0) as compressed:
        with tarfile.open(fileobj=compressed, mode='w|', format=tarfile.USTAR_FORMAT) as archive:
            for entry, data in blobs(entries):
                files[entry['path']] = data
                entry['sha256'] = sha(data)
                member = tarfile.TarInfo(entry['path'])
                member.size = len(data)
                member.mode = int(entry['mode'][-3:], 8)
                archive.addfile(member, io.BytesIO(data))
    capsule = output.getvalue()
    Path(PREFIX + 'inputs.tar.gz').write_bytes(capsule)
    manifest = {'version': 1, 'revision': plan['revision'], 'scope': plan['scope'],
                'capsule_sha256': sha(capsule), 'entries': entries}
    Path(PREFIX + 'inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
    sites = []
    for path in dict.fromkeys(plan['tests'] + plan['nested_tests']):
        text = files[path].decode()
        for number, line in enumerate(text.splitlines(), 1):
            if re.search(r'\b(?:open|opendir|slurp|read_text|discover_specs|discover_markdown_docs|discover_dir_files_by_suffix|run_perl_test_file_in_subprocess)\b|docs/checkpoints|\bdo\s+[\x27\x22]', line):
                sites.append({'path': path, 'line': number, 'source': line})
    sentinels = []
    for path, literal, role in plan['graph_sentinels']:
        lines = files[path].decode().splitlines()
        found = [number for number, line in enumerate(lines, 1) if literal in line]
        assert found, (path, literal)
        sentinels.append({'path': path, 'literal': literal, 'role': role, 'lines': found})
    graph = {'revision': plan['revision'], 'source_related_sites': sites, 'required_input_edges': sentinels,
             'classification': 'Source-related lexical sites are a census to review, not classified defect counts or a minimal runtime read graph. Complete selected directory contents form a conservative retained superset.'}
    Path(PREFIX + 'input-graph.json').write_text(json.dumps(graph, indent=2) + '\n')
    print(f'Prepared {len(entries)} exact Git files; {len(sites)} source-related sites; {len(capsule)} capsule bytes')


if __name__ == '__main__':
    main()
