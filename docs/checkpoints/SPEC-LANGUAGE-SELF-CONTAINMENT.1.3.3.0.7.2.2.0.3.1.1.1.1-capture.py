"""Capture actual lowering producers from complete immutable parent-owned inputs."""
import importlib.util
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-'
BASE = '997f1cb8f32ff4eaa1ba278e124cbaaac1942780'
STREAM = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
CANDIDATE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1-pipeline-candidate.pm'
OWNER = 'perl/LinkedSpec/ActionIR/RewritePipeline.pm'
spec = importlib.util.spec_from_file_location('retained_streams', ROOT / STREAM)
streams = importlib.util.module_from_spec(spec)
spec.loader.exec_module(streams)

def environment(seed):
    reset = {'TMPDIR', 'TMP', 'TEMP', 'CARGO_HOME', 'CARGO_TARGET_DIR', 'PUB_CACHE',
             'JULIA_DEPOT_PATH', 'PYTHONPYCACHEPREFIX', 'MDBOOK_BUILD__BUILD_DIR'}
    env = {key: value for key, value in os.environ.items() if key not in reset and not key.startswith('LINKEDSPEC_')}
    env.update(PERL5LIB='', PERL5OPT='', PERL_PERTURB_KEYS='2', PERL_HASH_SEED=str(seed))
    return env

def materialize(epoch):
    entries, excluded = [], []
    listing = subprocess.check_output(['git', 'ls-tree', '-rlz', BASE], cwd=ROOT)
    for row in filter(None, listing.split(b'\0')):
        metadata, path = row.split(b'\t', 1)
        mode, kind, oid, size = metadata.split()
        if kind != b'blob' or mode not in (b'100644', b'100755'):
            excluded.append({'path': path.decode(), 'mode': mode.decode(), 'kind': kind.decode()})
        else:
            entries.append({'path': path.decode(), 'mode': mode.decode(), 'oid': oid.decode(), 'bytes': int(size)})
    committed_count = len(entries)
    scratch = ROOT / '.linkedspec-data/scratch/residual-producers'
    scratch.mkdir(parents=True, exist_ok=True)
    tree = Path(tempfile.mkdtemp(prefix=epoch + '-', dir=scratch))
    assert tree.stat().st_dev == ROOT.stat().st_dev
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for entry in entries:
            process.stdin.write((entry['oid'] + '\n').encode())
            process.stdin.flush()
            assert process.stdout.readline().split() == [entry['oid'].encode(), b'blob', str(entry['bytes']).encode()]
            raw = process.stdout.read(entry['bytes'])
            assert len(raw) == entry['bytes'] and process.stdout.read(1) == b'\n'
            target = tree / entry['path']
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod(int(entry['mode'][-3:], 8))
            entry['sha256'] = streams.sha(raw)
    finally:
        process.stdin.close()
        process.stdout.close()
        assert process.wait() == 0
    overlays = [PREFIX + name for name in ('cases.json', 'probe.pl')]
    if epoch == 'candidate':
        overlays.append(OWNER)
    for path in overlays:
        source = CANDIDATE if path == OWNER else path
        raw = (ROOT / source).read_bytes()
        target = tree / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
        target.chmod(0o644)
        entries = [entry for entry in entries if entry['path'] != path]
        entries.append({'path': path, 'mode': '100644', 'bytes': len(raw), 'sha256': streams.sha(raw),
                        'overlay': True, 'recover_from': source})
    manifest = {'revision': BASE, 'epoch': epoch, 'regular_git_inputs': committed_count,
                'entries': entries, 'overlays': overlays, 'excluded_metadata': excluded,
                'scope': 'Complete regular immutable Git superset plus exact authored observations; candidate replaces only the retained rejected pipeline. Gitlinks/nonregular entries excluded without inspection.'}
    (ROOT / (PREFIX + epoch + '-inputs.json')).write_text(json.dumps(manifest, indent=2) + '\n')
    return tree, entries

cases = json.loads((ROOT / (PREFIX + 'cases.json')).read_bytes())
watched = [PREFIX + name for name in ('capture.py', 'cases.json', 'probe.pl')] + [STREAM, CANDIDATE]
guards = {path: streams.sha((ROOT / path).read_bytes()) for path in watched}
report = {'revision': BASE, 'complete': False, 'producer_inputs': guards, 'epochs': [],
          'scope': 'Actual Toolbox/contract/parser-frame/source-origin channels under seeds0/1/42. Read-only OS/toolchain/standard libraries are prerequisites; all project inputs and output stay on the repository volume. This is bounded diagnosis, not repaired-production or full Phase0 acceptance.'}
for epoch in ('original', 'candidate'):
    tree, entries = materialize(epoch)
    observed = {'epoch': epoch, 'input_tree': tree.relative_to(ROOT).as_posix(), 'runs': []}
    report['epochs'].append(observed)
    for seed in (0, 1, 42):
        for case in cases:
            before = streams.verify_tree(tree, entries)
            command = ['bash', 'tools/project_data_run.sh', 'perl', '-Iperl', PREFIX + 'probe.pl', case['id']]
            result = subprocess.run(command, cwd=tree, env=environment(seed), capture_output=True)
            observed['runs'].append({'case': case['id'], 'seed': seed, 'command': command, 'exit': result.returncode,
                'stdout': streams.envelope(result.stdout), 'stderr': streams.envelope(result.stderr),
                'inputs_before': before, 'inputs_after': streams.verify_tree(tree, entries)})
            (ROOT / (PREFIX + 'observations.json')).write_text(json.dumps(report, indent=2) + '\n')
            assert {path: streams.sha((ROOT / path).read_bytes()) for path in watched} == guards
            assert result.returncode == 0, (epoch, seed, case['id'])
            print(epoch, seed, case['id'], 'complete guarded channels', flush=True)
    observed['complete'] = True
report['complete'] = True
(ROOT / (PREFIX + 'observations.json')).write_text(json.dumps(report, indent=2) + '\n')
