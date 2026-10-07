"""Retain complete compiler membership before/after channels and supplied inputs."""
from pathlib import Path
import hashlib
import importlib.util
import json
import os
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('capture.py')
REL = Path(PREFIX).relative_to(ROOT).as_posix()
REVISION = '31395e440a38acec7a6712d470a90a90a6567863'
STREAM = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
FIXTURE = 't/actionir_compiler_source_membership.t'
OWNERS = ['perl/LinkedSpec/ActionIR/Scanner.pm', 'perl/LinkedSpec/RuleIR/EmitContext.pm']
AUTHORED = [FIXTURE, REL + 'capture.py']
PUBLIC = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-'
TESTS = ['t/' + name + '.t' for name in (
    'actionir_executable_source_membership', 'actionir_helper_source_provenance',
    'actionir_ast_parser', 'canonical_event_occurrence_order',
    'actionir_pipeline_regex_source_provenance', 'actionir_pipeline_statement_source_provenance',
    'actionir_statement_source_frames', 'actionir_method_argument_source_frames',
    'actionir_nested_block_source_spans', 'trace_emit_context_bridge',
    'actionir_raw_dependency_metadata', 'actionir_raw_dependency_provenance',
    'actionir_raw_dependency_compatibility', 'generated_source_contract')]
spec = importlib.util.spec_from_file_location('retained_compiler_membership_streams', ROOT / STREAM)
streams = importlib.util.module_from_spec(spec)
spec.loader.exec_module(streams)


def make_tree(mode):
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
    scratch = ROOT / '.linkedspec-data/scratch/compiler-source-membership'
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
    for path in AUTHORED:
        assert path not in {e['path'] for e in entries}, 'new authored input only'
        raw = (ROOT / path).read_bytes()
        target = tree / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw); target.chmod(0o644)
        entries.append({'path': path, 'mode': '100644', 'bytes': len(raw),
                        'sha256': streams.sha(raw), 'authored_overlay': True})
    replacements = []
    if mode == 'after':
        for path in OWNERS:
            entry = next(e for e in entries if e['path'] == path)
            original = dict(entry)
            raw = (ROOT / path).read_bytes()
            (tree / path).write_bytes(raw)
            entry.update(bytes=len(raw), sha256=streams.sha(raw), replacement=True)
            replacements.append({'path': path, 'original': original, 'after': dict(entry)})
    return tree, {'revision': REVISION, 'mode': mode, 'entries': entries,
                  'excluded_metadata': excluded, 'overlays': AUTHORED,
                  'replacements': replacements,
                  'scope': 'Complete regular committed Git input superset plus exactly two authored overlays; after replaces only two declared compiler owners. No Gitlink/nonregular payloads. Necessary OS/toolchain reads only; all project data repository-local. Not a minimal observed IO census.'}


def environment(seed):
    reset = {'TMPDIR', 'TMP', 'TEMP', 'CARGO_HOME', 'CARGO_TARGET_DIR', 'PUB_CACHE',
             'JULIA_DEPOT_PATH', 'PYTHONPYCACHEPREFIX', 'MDBOOK_BUILD__BUILD_DIR'}
    env = {k: v for k, v in os.environ.items() if k not in reset and not k.startswith('LINKEDSPEC_')}
    env.update(PERL5LIB='', PERL5OPT='', PERL_PERTURB_KEYS='2', PERL_HASH_SEED=str(seed))
    return env


def main(mode):
    tree, manifest = make_tree(mode)
    Path(PREFIX + mode + '-inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
    report = {'revision': REVISION, 'mode': mode, 'complete': False,
              'input_tree': tree.relative_to(ROOT).as_posix(),
              'instrument_sha256': streams.sha(Path(__file__).read_bytes()),
              'stream_instrument_sha256': streams.sha((ROOT / STREAM).read_bytes()), 'runs': []}
    cases = json.loads((tree / (PUBLIC + 'cases.json')).read_text())
    commands = [('compiler-tap', seed, ['prove', '-v', '-Iperl', FIXTURE]) for seed in (0, 1, 42)]
    commands += [('public:' + case['id'], 0, ['perl', '-Iperl', PUBLIC + 'probe.pl', case['id']]) for case in cases]
    commands += [('consumers', 0, ['prove', '-v', '-Iperl'] + TESTS)]
    for kind, seed, tail in commands:
        before = streams.verify_tree(tree, manifest['entries'])
        command = ['bash', 'tools/project_data_run.sh'] + tail
        result = subprocess.run(command, cwd=tree, env=environment(seed), capture_output=True)
        row = {'kind': kind, 'seed': seed, 'command': command, 'exit': result.returncode,
               'stdout': streams.envelope(result.stdout), 'stderr': streams.envelope(result.stderr),
               'inputs_before': before, 'inputs_after': streams.verify_tree(tree, manifest['entries'])}
        report['runs'].append(row)
        Path(PREFIX + mode + '-observations.json').write_text(json.dumps(report, indent=2) + '\n')
        print(mode, kind, seed, result.returncode, flush=True)
    report['complete'] = True
    Path(PREFIX + mode + '-observations.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    assert len(sys.argv) == 2
    main(sys.argv[1])
