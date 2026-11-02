"""Freeze one actual pre-repair selector scan and its complete file population."""
import base64
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
REVISION = '0db5e9e87b7c1cfaf09936b9629974787038f5e3'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(),
                sha256=hashlib.sha256(raw).hexdigest())


def capture():
    destination = HERE / 'selector-source-population.json.gz'
    if destination.exists():
        raise ValueError('retain existing selector population epochs')
    source = ROOT / 'tools/check_executable_aggregate_selector_sources.py'
    spec = importlib.util.spec_from_file_location('selector_epoch', source)
    scanner = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(scanner)
    command = ['bash', 'tools/run_python_project_data.sh',
               'tools/check_executable_aggregate_selector_sources.py']
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    if result.returncode != 1:
        raise ValueError('expected actual pre-repair scanner rejection')
    paths = scanner.candidate_files()
    tree = {}
    for row in subprocess.check_output(['git', 'ls-tree', '-rz', REVISION], cwd=ROOT).split(b'\0'):
        if row:
            header, name = row.split(b'\t', 1)
            mode, kind, oid = header.decode().split()
            if kind == 'blob' and mode in ('100644', '100755'):
                tree[name.decode()] = oid
    entries = {}
    with subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                          stdin=subprocess.PIPE, stdout=subprocess.PIPE) as reader:
        for name in paths:
            if Path(name).suffix in scanner.EXCLUDED_SUFFIXES:
                continue
            try:
                raw = (ROOT / name).read_bytes()
            except OSError:
                entries[name] = dict(disposition='unreadable')
                continue
            try:
                raw.decode('utf-8')
                disposition = 'utf8'
            except UnicodeDecodeError:
                disposition = 'binary'
            row = dict(disposition=disposition, sha256=hashlib.sha256(raw).hexdigest())
            oid = tree.get(name)
            same = False
            if oid:
                reader.stdin.write((oid+'\n').encode())
                reader.stdin.flush()
                header = reader.stdout.readline().split()
                if len(header) != 3 or header[1] != b'blob':
                    raise ValueError('unexpected Git blob response')
                baseline = reader.stdout.read(int(header[2]))
                if reader.stdout.read(1) != b'\n':
                    raise ValueError('truncated Git blob response')
                same = baseline == raw
            if same:
                row['revision'] = REVISION
            else:
                row['payload'] = packet(raw)
            entries[name] = row
        reader.stdin.close()
        if reader.wait() != 0:
            raise ValueError('Git blob reader failed')
    if scanner.candidate_files() != paths:
        raise ValueError('candidate membership changed during capture')
    for name, row in entries.items():
        if 'sha256' in row and hashlib.sha256((ROOT/name).read_bytes()).hexdigest() != row['sha256']:
            raise ValueError('candidate bytes changed during capture: '+name)
    value = dict(schema_version=1, owner='TYPE-REFERENCE-BOOK.1.2.20.1.13.1',
                 command=command, returncode=result.returncode,
                 stdout=packet(result.stdout), stderr=packet(result.stderr),
                 candidate_paths=paths, inputs=entries, scanner=packet(source.read_bytes()),
                 producer=packet(Path(__file__).read_bytes()),
                 limits='Exact captured parent-repository candidate population. Excluded suffixes are not read by the scanner; unreadable paths and binary inputs retain their observed disposition. System toolchains are outside this artifact scope.')
    destination.write_bytes(gzip.compress(json.dumps(value, sort_keys=True).encode(), mtime=0))
    print('selector source population retained:',len(paths),'candidates /',len(entries),'read candidates')


if __name__ == '__main__':
    capture()
