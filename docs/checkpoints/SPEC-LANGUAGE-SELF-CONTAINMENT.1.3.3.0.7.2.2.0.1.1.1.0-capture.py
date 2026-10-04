"""Capture Toolbox observations from immutable parent-owned Git inputs."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import os
import stat
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('capture.py')
REVISION = 'c02ce88826f815c201a652d5b29bd3cf044d2740'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def envelope(data):
    return {'encoding': 'gzip-base64', 'bytes': len(data), 'sha256': sha(data),
            'data': base64.b64encode(gzip.compress(data, mtime=0)).decode()}


def verify_tree(tree, entries):
    expected = {entry['path'] for entry in entries}
    actual = set()
    for path in tree.rglob('*'):
        relative = path.relative_to(tree).as_posix()
        if relative.startswith('.linkedspec-data/'):
            continue
        assert not path.is_symlink(), relative
        if path.is_file():
            actual.add(relative)
    assert actual == expected, 'exact snapshot input population'
    for entry in entries:
        path = tree / entry['path']
        data = path.read_bytes()
        assert len(data) == entry['bytes'] and sha(data) == entry['sha256'], entry['path']
        assert stat.S_IMODE(path.stat().st_mode) == int(entry['mode'][-3:], 8), entry['path']
    return len(entries)


def main():
    # Preserve the first actual output byte-for-byte; its B callback filename
    # was an absolute runtime locator. Retention is an explicit forensic stream,
    # rather than a rewritten observation or a persisted project path.
    initial = Path(PREFIX + 'initial.json')
    if initial.exists() and 'rows' in json.loads(initial.read_bytes()):
        raw = initial.read_bytes()
        initial.write_text(json.dumps({'stdout': envelope(raw), 'scope': 'Exact first probe stdout, including its derived runtime locator. No projection or input/source rewrite.'}, indent=2) + '\n')
    raw_rows = subprocess.check_output(['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT)
    entries = []
    excluded = []
    for row in filter(None, raw_rows.split(b'\0')):
        meta, path = row.split(b'\t', 1)
        mode, kind, oid, size = meta.split()
        if kind != b'blob' or mode not in (b'100644', b'100755'):
            excluded.append({'path': path.decode(), 'mode': mode.decode(), 'kind': kind.decode()})
            continue
        entries.append({'path': path.decode(), 'mode': mode.decode(), 'oid': oid.decode(), 'bytes': int(size)})
    scratch = ROOT / '.linkedspec-data/scratch/basic-statement-provenance'
    scratch.mkdir(parents=True, exist_ok=True)
    tree = Path(tempfile.mkdtemp(prefix='fixed-inputs-', dir=scratch))
    assert tree.stat().st_dev == ROOT.stat().st_dev
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for entry in entries:
            process.stdin.write((entry['oid'] + '\n').encode()); process.stdin.flush()
            oid, kind, size = process.stdout.readline().split()
            assert oid.decode() == entry['oid'] and kind == b'blob' and int(size) == entry['bytes']
            raw = process.stdout.read(entry['bytes'])
            assert len(raw) == entry['bytes'] and process.stdout.read(1) == b'\n'
            target = tree / entry['path']
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw); target.chmod(int(entry['mode'][-3:], 8))
            entry['sha256'] = sha(raw)
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    for suffix in ('cases.json', 'probe.pl'):
        source = Path(PREFIX + suffix)
        relative = source.relative_to(ROOT).as_posix()
        raw = source.read_bytes()
        target = tree / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw); target.chmod(0o644)
        entries.append({'path': relative, 'mode': '100644', 'bytes': len(raw), 'sha256': sha(raw), 'overlay': True})
    inputs = {'revision': REVISION, 'scope': 'Conservative complete regular parent-owned Git snapshot plus two explicit probe/case overlays. Gitlinks and non-regular entries excluded without reading their payload. Not a minimal runtime read set.', 'entries': entries, 'excluded_metadata': excluded}
    Path(PREFIX + 'inputs.json').write_text(json.dumps(inputs, indent=2) + '\n')
    output = Path(PREFIX + 'observations.json')
    report = {'revision': REVISION, 'input_tree': tree.relative_to(ROOT).as_posix(), 'runs': [], 'complete': False,
              'instrument_sha256': sha(Path(__file__).read_bytes()),
              'host_scope': 'Read-only host OS/Perl and standard libraries are execution prerequisites; no submodule payload is used. Project inputs and generated work stay on the repository volume.'}
    reset = {'TMPDIR','TMP','TEMP','CARGO_HOME','CARGO_TARGET_DIR','PUB_CACHE','JULIA_DEPOT_PATH','PYTHONPYCACHEPREFIX','MDBOOK_BUILD__BUILD_DIR'}
    env = {k:v for k,v in os.environ.items() if k not in reset and not k.startswith('LINKEDSPEC_')}
    env.update(PERL5LIB='', PERL5OPT='', PERL_PERTURB_KEYS='2')
    probe = Path(PREFIX + 'probe.pl').relative_to(ROOT).as_posix()
    for seed in (0,1,42):
        env['PERL_HASH_SEED'] = str(seed)
        before = verify_tree(tree, entries)
        command = ['bash','tools/project_data_run.sh','perl','-Iperl',probe]
        result = subprocess.run(command,cwd=tree,env=env,capture_output=True)
        row = {'seed':seed,'perturb':2,'command':command,'exit':result.returncode,
               'stdout':envelope(result.stdout),'stderr':envelope(result.stderr),'inputs_before':before}
        report['runs'].append(row)
        output.write_text(json.dumps(report,indent=2)+'\n')
        try:
            row['inputs_after'] = verify_tree(tree,entries)
        except AssertionError as error:
            row['input_failure'] = str(error)
            output.write_text(json.dumps(report,indent=2)+'\n')
            raise
        output.write_text(json.dumps(report,indent=2)+'\n')
        assert result.returncode == 0, 'actual complete probe exit'
        data = json.loads(result.stdout)
        print(f"seed{seed}: {len(data['rows'])} complete Toolbox observations; {before} fixed inputs",flush=True)
    assert report['instrument_sha256'] == sha(Path(__file__).read_bytes())
    report['complete'] = True
    output.write_text(json.dumps(report,indent=2)+'\n')


if __name__ == '__main__':
    main()
