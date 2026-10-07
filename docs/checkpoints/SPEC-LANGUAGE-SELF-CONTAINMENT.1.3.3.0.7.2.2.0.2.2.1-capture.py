"""Capture exact original/corrected compiler owners with one common authored fixture."""
from pathlib import Path
import argparse
import importlib.util
import json
import os
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('capture.py')
REVISION = '484fe128f945af9c53d82fe44f6498002dcfd771'
STREAM = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
PUBLIC = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-'
FIXTURE = 't/actionir_compiler_source_membership.t'
SOURCE = 'perl/LinkedSpec/ActionIR/SourceMembership.pm'
PROBE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.1-probe.pl'
TESTS = ['t/' + name + '.t' for name in (
    'actionir_executable_source_membership', 'actionir_helper_source_provenance',
    'actionir_ast_parser', 'canonical_event_occurrence_order',
    'actionir_pipeline_regex_source_provenance', 'actionir_pipeline_statement_source_provenance',
    'actionir_statement_source_frames', 'actionir_method_argument_source_frames',
    'actionir_nested_block_source_spans', 'trace_emit_context_bridge',
    'actionir_raw_dependency_metadata', 'actionir_raw_dependency_provenance',
    'actionir_raw_dependency_compatibility', 'generated_source_contract',
    'callable_codeblock_literal_contract', 'phase0_regression')]
spec = importlib.util.spec_from_file_location('committed_membership_streams', ROOT / STREAM)
streams = importlib.util.module_from_spec(spec)
spec.loader.exec_module(streams)


def environment(seed):
    reset = {'TMPDIR', 'TMP', 'TEMP', 'CARGO_HOME', 'CARGO_TARGET_DIR', 'PUB_CACHE',
             'JULIA_DEPOT_PATH', 'PYTHONPYCACHEPREFIX', 'MDBOOK_BUILD__BUILD_DIR'}
    env = {k: v for k, v in os.environ.items() if k not in reset and not k.startswith('LINKEDSPEC_')}
    env.update(PERL5LIB='', PERL5OPT='', PERL_PERTURB_KEYS='2', PERL_HASH_SEED=str(seed))
    return env


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('epoch', choices=['before', 'after'])
    epoch = parser.parse_args().epoch
    entries, excluded = [], []
    listing = subprocess.check_output(['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT)
    for row in filter(None, listing.split(b'\0')):
        metadata, path = row.split(b'\t', 1)
        mode, kind, oid, size = metadata.split()
        if kind != b'blob' or mode not in (b'100644', b'100755'):
            excluded.append({'path': path.decode(), 'mode': mode.decode(), 'kind': kind.decode()})
        else:
            entries.append({'path': path.decode(), 'mode': mode.decode(),
                            'oid': oid.decode(), 'bytes': int(size)})
    scratch = ROOT / '.linkedspec-data/scratch/compiler-signature-membership'
    scratch.mkdir(parents=True, exist_ok=True)
    tree = Path(tempfile.mkdtemp(prefix='committed-', dir=scratch))
    assert tree.stat().st_dev == ROOT.stat().st_dev
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for entry in entries:
            process.stdin.write((entry['oid'] + '\n').encode())
            process.stdin.flush()
            assert process.stdout.readline().split() == [
                entry['oid'].encode(), b'blob', str(entry['bytes']).encode()]
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
    overlays = []
    by_path = {entry['path']: entry for entry in entries}
    supplies = [(FIXTURE, Path(PREFIX + 'fixture.t')), (PROBE, ROOT / PROBE)]
    if epoch == 'after':
        supplies.append((SOURCE, ROOT / SOURCE))
    for name, supplied in supplies:
        raw = supplied.read_bytes()
        previous = by_path.get(name)
        if previous:
            assert raw != (tree / name).read_bytes(), 'effective declared replacement'
        target = tree / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw); target.chmod(0o644)
        entry = {'path': name, 'mode': '100644', 'oid': None,
                 'bytes': len(raw), 'sha256': streams.sha(raw),
                 'kind': 'replacement' if previous else 'added',
                 'supplier': supplied.relative_to(ROOT).as_posix()}
        if previous:
            entries[entries.index(previous)] = entry
        else:
            entries.append(entry)
        by_path[name] = entry
        overlays.append(entry)
    entries.sort(key=lambda entry: entry['path'])
    manifest = {'revision': REVISION, 'epoch': epoch, 'entries': entries, 'overlays': overlays,
                'regular_git_inputs': len(entries), 'excluded_metadata': excluded,
                'scope': 'Complete regular committed Git supplied superset plus exactly declared authored '
                         'compiler fixture/public observer; only after replaces SourceMembership. '
                         'Gitlinks/nonregular payloads excluded without inspection. Not minimal observed IO.'}
    Path(PREFIX + epoch + '-inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
    report = {'revision': REVISION, 'epoch': epoch, 'complete': False, 'runs': [],
              'input_tree': tree.relative_to(ROOT).as_posix(),
              'instrument_sha256': streams.sha(Path(__file__).read_bytes()),
              'stream_instrument_sha256': streams.sha((ROOT / STREAM).read_bytes()),
              'host_scope': 'Necessary read-only OS/Perl/standard libraries; all project outputs '
                            'repository-local on the repository volume.'}
    commands = [('compiler-tap', seed, ['prove', '-v', '-Iperl', FIXTURE]) for seed in (0, 1, 42)]
    commands += [('public', seed, ['perl', '-Iperl', PROBE]) for seed in (0, 1, 42)]
    commands += [('consumers', 0, ['prove', '-v', '-Iperl'] + TESTS)] if epoch == 'after' else [
        ('original-callable', 0, ['prove', '-v', '-Iperl', 't/callable_codeblock_literal_contract.t'])]
    for kind, seed, tail in commands:
        before = streams.verify_tree(tree, entries)
        command = ['bash', 'tools/project_data_run.sh'] + tail
        result = subprocess.run(command, cwd=tree, env=environment(seed), capture_output=True)
        report['runs'].append({
            'kind': kind, 'seed': seed, 'command': command, 'exit': result.returncode,
            'stdout': streams.envelope(result.stdout), 'stderr': streams.envelope(result.stderr),
            'inputs_before': before, 'inputs_after': streams.verify_tree(tree, entries)})
        Path(PREFIX + epoch + '-observations.json').write_text(json.dumps(report, indent=2) + '\n')
        print(kind, seed, result.returncode, flush=True)
    assert report['instrument_sha256'] == streams.sha(Path(__file__).read_bytes())
    report['complete'] = True
    Path(PREFIX + epoch + '-observations.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
