"""Capture original producers and private selection from complete closed inputs."""
from pathlib import Path
import importlib.util
import json
import os
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('capture.py')
REL = Path(PREFIX).relative_to(ROOT).as_posix()
REVISION = '5f700625ef4bce962285ece583b088c457f2dd63'
STREAM = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
OWNER = 'perl/LinkedSpec/ActionIR/SourceMembership.pm'
FIXTURE = 't/actionir_executable_source_membership.t'
AUTHORED = [FIXTURE] + [REL + name for name in
    ('cases.json', 'oracle.py', 'intake.pl', 'probe.pl', 'capture.py')]
TESTS = ['t/' + name + '.t' for name in (
    'actionir_helper_source_provenance', 'actionir_ast_parser',
    'canonical_event_occurrence_order', 'actionir_pipeline_regex_source_provenance',
    'actionir_pipeline_statement_source_provenance', 'actionir_statement_source_frames',
    'actionir_method_argument_source_frames', 'actionir_nested_block_source_spans')]
spec = importlib.util.spec_from_file_location('retained_membership_stream_guard', ROOT / STREAM)
streams = importlib.util.module_from_spec(spec)
spec.loader.exec_module(streams)


def make_tree(mode, overrides=None):
    assert mode in ('before', 'after')
    entries, excluded = [], []
    for row in filter(None, subprocess.check_output(
            ['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT).split(b'\0')):
        metadata, path = row.split(b'\t', 1)
        git_mode, kind, oid, size = metadata.split()
        if kind != b'blob' or git_mode not in (b'100644', b'100755'):
            excluded.append({'path': path.decode(), 'mode': git_mode.decode(), 'kind': kind.decode()})
        else:
            entries.append({'path': path.decode(), 'mode': git_mode.decode(),
                            'oid': oid.decode(), 'bytes': int(size)})
    scratch = ROOT / '.linkedspec-data/scratch/executable-source-membership'
    scratch.mkdir(parents=True, exist_ok=True)
    tree = Path(tempfile.mkdtemp(prefix=mode + '-', dir=scratch))
    assert tree.stat().st_dev == ROOT.stat().st_dev
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for entry in entries:
            process.stdin.write((entry['oid'] + '\n').encode()); process.stdin.flush()
            assert process.stdout.readline().split() == [
                entry['oid'].encode(), b'blob', str(entry['bytes']).encode()]
            raw = process.stdout.read(entry['bytes'])
            assert process.stdout.read(1) == b'\n'
            target = tree / entry['path']
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw); target.chmod(int(entry['mode'][-3:], 8))
            entry['sha256'] = streams.sha(raw)
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    regular_count = len(entries)
    overlays = AUTHORED + ([OWNER] if mode == 'after' else [])
    overrides = overrides or {}
    assert set(overrides) <= {OWNER} and (not overrides or mode == 'after')
    for path in overlays:
        assert path not in {entry['path'] for entry in entries}, 'new authored input only'
        raw = (ROOT / overrides.get(path, path)).read_bytes()
        target = tree / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw); target.chmod(0o644)
        entries.append({'path': path, 'mode': '100644', 'bytes': len(raw),
                        'sha256': streams.sha(raw), 'declared_authored_overlay': True,
                        'artifact': overrides.get(path, path)})
    return tree, {'revision': REVISION, 'mode': mode, 'entries': entries,
                  'regular_git_inputs': regular_count, 'excluded_metadata': excluded,
                  'overlays': overlays,
                  'scope': 'Complete regular committed Git input superset plus declared new authored assets; not minimal observed IO. Gitlink/nonregular payloads excluded; necessary OS/Perl reads only; project outputs repository-local.'}


def environment(seed, mode):
    reset = {'TMPDIR', 'TMP', 'TEMP', 'CARGO_HOME', 'CARGO_TARGET_DIR', 'PUB_CACHE',
             'JULIA_DEPOT_PATH', 'PYTHONPYCACHEPREFIX', 'MDBOOK_BUILD__BUILD_DIR'}
    env = {key: value for key, value in os.environ.items()
           if key not in reset and not key.startswith('LINKEDSPEC_')}
    env.update(PERL5LIB='', PERL5OPT='', PERL_PERTURB_KEYS='2', PERL_HASH_SEED=str(seed))
    if mode == 'before':
        env['LINKEDSPEC_MEMBERSHIP_BASELINE'] = '1'
    return env


def run(tree, manifest, kind, seed, tail, mode):
    before = streams.verify_tree(tree, manifest['entries'])
    command = ['bash', 'tools/project_data_run.sh'] + tail
    result = subprocess.run(command, cwd=tree, env=environment(seed, mode), capture_output=True)
    return {'kind': kind, 'seed': seed, 'command': command, 'exit': result.returncode,
            'stdout': streams.envelope(result.stdout), 'stderr': streams.envelope(result.stderr),
            'inputs_before': before, 'inputs_after': streams.verify_tree(tree, manifest['entries'])}


def main(mode):
    tree, manifest = make_tree(mode)
    Path(PREFIX + mode + '-inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
    report = {'revision': REVISION, 'mode': mode, 'complete': False,
              'input_tree': tree.relative_to(ROOT).as_posix(),
              'instrument_sha256': streams.sha(Path(__file__).read_bytes()),
              'stream_instrument_sha256': streams.sha((ROOT / STREAM).read_bytes()),
              'runs': []}
    commands = [('authored-oracle', 0, ['python3', REL + 'oracle.py'])]
    commands += [('membership-tap', seed, ['prove', '-v', '-Iperl', FIXTURE]) for seed in (0, 1, 42)]
    commands += [('membership-probe', seed, ['perl', '-Iperl', REL + 'probe.pl', mode]) for seed in (0, 1, 42)]
    commands += [('public-intake', seed, ['perl', '-Iperl', REL + 'intake.pl']) for seed in (0, 1, 42)]
    commands += [('consumers', 0, ['prove', '-v', '-Iperl'] + TESTS)]
    destination = Path(PREFIX + mode + '-observations.json')
    for kind, seed, tail in commands:
        row = run(tree, manifest, kind, seed, tail, mode)
        report['runs'].append(row)
        destination.write_text(json.dumps(report, indent=2) + '\n')
        expected = 1 if mode == 'before' and kind == 'membership-tap' else 0
        assert row['exit'] == expected, 'complete declared command exit'
    report['complete'] = True
    destination.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({'mode': mode, 'regular_inputs': manifest['regular_git_inputs'],
                      'overlays': len(manifest['overlays']), 'commands': len(commands)}))


if __name__ == '__main__':
    assert len(sys.argv) == 2
    main(sys.argv[1])
