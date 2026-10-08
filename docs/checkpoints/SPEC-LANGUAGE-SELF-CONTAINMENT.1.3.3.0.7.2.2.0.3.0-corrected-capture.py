"""Capture unchanged committed owners plus explicit authored diagnosis overlays."""
from pathlib import Path
import importlib.util
import json
import os
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('capture.py')
REVISION = 'fa9b7608ed9e49712129bb5456d75d118e7207a0'
STREAM = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
TESTS = ['t/' + name + '.t' for name in (
    'actionir_ast_parser', 'canonical_event_occurrence_order',
    'actionir_nested_block_source_spans', 'actionir_compiler_source_membership',
    'actionir_executable_source_membership', 'trace_emit_context_bridge')]
spec = importlib.util.spec_from_file_location('replacement_streams', ROOT / STREAM)
streams = importlib.util.module_from_spec(spec); spec.loader.exec_module(streams)


def environment(seed):
    reset = {'TMPDIR', 'TMP', 'TEMP', 'CARGO_HOME', 'CARGO_TARGET_DIR', 'PUB_CACHE',
             'JULIA_DEPOT_PATH', 'PYTHONPYCACHEPREFIX', 'MDBOOK_BUILD__BUILD_DIR'}
    env = {k: v for k, v in os.environ.items() if k not in reset and not k.startswith('LINKEDSPEC_')}
    env.update(PERL5LIB='', PERL5OPT='', PERL_PERTURB_KEYS='2', PERL_HASH_SEED=str(seed))
    return env


def main():
    entries, excluded = [], []
    listing = subprocess.check_output(['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT)
    for row in filter(None, listing.split(b'\0')):
        metadata, path = row.split(b'\t', 1); mode, kind, oid, size = metadata.split()
        if kind != b'blob' or mode not in (b'100644', b'100755'):
            excluded.append({'path': path.decode(), 'mode': mode.decode(), 'kind': kind.decode()})
        else:
            entries.append({'path': path.decode(), 'mode': mode.decode(),
                            'oid': oid.decode(), 'bytes': int(size)})
    committed_count = len(entries)
    scratch = ROOT / '.linkedspec-data/scratch/replacement-diagnosis'; scratch.mkdir(parents=True, exist_ok=True)
    tree = Path(tempfile.mkdtemp(prefix='fixed-', dir=scratch)); assert tree.stat().st_dev == ROOT.stat().st_dev
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for entry in entries:
            process.stdin.write((entry['oid'] + '\n').encode()); process.stdin.flush()
            assert process.stdout.readline().split() == [entry['oid'].encode(), b'blob', str(entry['bytes']).encode()]
            raw = process.stdout.read(entry['bytes']); assert len(raw) == entry['bytes'] and process.stdout.read(1) == b'\n'
            target = tree / entry['path']; target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw); target.chmod(int(entry['mode'][-3:], 8)); entry['sha256'] = streams.sha(raw)
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    overlays = []
    for suffix in ('cases.json', 'probe.pl', 'red-fixture.t'):
        path = Path(PREFIX + suffix); relative = path.relative_to(ROOT).as_posix(); raw = path.read_bytes()
        assert relative not in {entry['path'] for entry in entries}
        target = tree / relative; target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw); target.chmod(0o644); overlays.append(relative)
        entries.append({'path': relative, 'mode': '100644', 'bytes': len(raw),
                        'sha256': streams.sha(raw), 'overlay': True})
    manifest = {'revision': REVISION, 'entries': entries, 'overlays': overlays,
                'regular_git_inputs': committed_count, 'excluded_metadata': excluded,
                'scope': 'Complete regular committed Git supplied superset plus three authored diagnosis '
                         'overlays; no production replacements. Gitlinks/nonregular payloads excluded '
                         'without inspection. Not a minimal observed IO set.'}
    Path(PREFIX + 'inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
    report = {'revision': REVISION, 'complete': False, 'runs': [], 'input_tree': tree.relative_to(ROOT).as_posix(),
              'instrument_sha256': streams.sha(Path(__file__).read_bytes()),
              'stream_instrument_sha256': streams.sha((ROOT / STREAM).read_bytes()),
              'host_scope': 'Necessary read-only OS/Perl/Python standard libraries; project data local/same-volume.'}
    cases = json.loads(Path(PREFIX + 'cases.json').read_bytes())
    probe = Path(PREFIX + 'probe.pl').relative_to(ROOT).as_posix()
    fixture = Path(PREFIX + 'red-fixture.t').relative_to(ROOT).as_posix()
    commands = [('public:' + case['id'], seed, ['perl', '-Iperl', probe, case['id']])
                for seed in (0, 1, 42) for case in cases]
    commands += [('diagnostic-tap', 0, ['prove', '-v', '-Iperl', fixture]),
                 ('consumers', 0, ['prove', '-v', '-Iperl'] + TESTS)]
    for kind, seed, tail in commands:
        before = streams.verify_tree(tree, entries); command = ['bash', 'tools/project_data_run.sh'] + tail
        result = subprocess.run(command, cwd=tree, env=environment(seed), capture_output=True)
        report['runs'].append({'kind': kind, 'seed': seed, 'command': command, 'exit': result.returncode,
            'stdout': streams.envelope(result.stdout), 'stderr': streams.envelope(result.stderr),
            'inputs_before': before, 'inputs_after': streams.verify_tree(tree, entries)})
        Path(PREFIX + 'observations.json').write_text(json.dumps(report, indent=2) + '\n')
        print(kind, seed, result.returncode, flush=True)
    assert report['instrument_sha256'] == streams.sha(Path(__file__).read_bytes())
    report['complete'] = True
    Path(PREFIX + 'observations.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
