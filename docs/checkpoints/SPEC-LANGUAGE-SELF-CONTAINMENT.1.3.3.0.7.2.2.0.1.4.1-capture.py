"""Capture an original Legacy producer diagnosis from immutable regular Git inputs."""
from pathlib import Path
import importlib.util
import json
import os
import subprocess
import tempfile
import sys

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('capture.py')
REVISION = '0083dc7af44fe64f329339da6b764d0806cf1717'
DIAGNOSIS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-'
EPOCH = sys.argv[1]
assert EPOCH in ('before','after')
OWNER = 'perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm'
FIXTURE = 't/actionir_helper_source_provenance.t'
OVERLAYS = [PREFIX + n for n in ('cases.json','probe.pl','oracle.py')]
TESTS = ['t/actionir_helper_source_provenance.t','t/actionir_statement_source_frames.t','t/actionir_ast_parser.t','t/canonical_event_occurrence_order.t','t/actionir_nested_block_source_spans.t','t/trace_actionir_method_lowering.t','t/phase0_regression.t']
spec = importlib.util.spec_from_file_location('streams', ROOT / (DIAGNOSIS + 'capture.py'))
streams = importlib.util.module_from_spec(spec)
spec.loader.exec_module(streams)


def main():
    entries, excluded = [], []
    listing = subprocess.check_output(['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT)
    for row in filter(None, listing.split(b'\0')):
        metadata, path = row.split(b'\t', 1)
        mode, kind, oid, size = metadata.split()
        if kind != b'blob' or mode not in (b'100644', b'100755'):
            excluded.append({'path': path.decode(), 'mode': mode.decode(), 'kind': kind.decode()})
            continue
        entries.append({'path': path.decode(), 'mode': mode.decode(), 'oid': oid.decode(), 'bytes': int(size)})
    scratch = ROOT / '.linkedspec-data/scratch/legacy-call-source'
    scratch.mkdir(parents=True, exist_ok=True)
    tree = Path(tempfile.mkdtemp(prefix='legacy-'+EPOCH+'-', dir=scratch))
    assert tree.stat().st_dev == ROOT.stat().st_dev
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for entry in entries:
            process.stdin.write((entry['oid'] + '\n').encode())
            process.stdin.flush()
            assert process.stdout.readline().split() == [entry['oid'].encode(), b'blob', str(entry['bytes']).encode()]
            raw = process.stdout.read(entry['bytes'])
            assert process.stdout.read(1) == b'\n'
            target = tree / entry['path']
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod(int(entry['mode'][-3:], 8))
            entry['sha256'] = streams.sha(raw)
    finally:
        process.stdin.close()
        process.stdout.close()
        assert process.wait() == 0
    # Preserve original Git identities and declare the exact fixture/runtime replacements.
    for path, kind in [(FIXTURE, 'declared_fixture_overlay')] + ([(OWNER, 'declared_owner_delta')] if EPOCH == 'after' else []):
        raw = (ROOT/path).read_bytes();target = tree/path
        entry = next(e for e in entries if e['path'] == path)
        entry.update(baseline_sha256=entry['sha256'], baseline_bytes=entry['bytes'])
        entry.update(sha256=streams.sha(raw), bytes=len(raw));entry[kind] = True
        target.write_bytes(raw)
    overlays = []
    for path in OVERLAYS:
        target = tree / Path(path).relative_to(ROOT)
        raw = Path(path).read_bytes()
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw); target.chmod(0o644)
        overlays.append({'path': target.relative_to(tree).as_posix(), 'mode':'100644', 'bytes':len(raw), 'sha256':streams.sha(raw)})
    guarded = entries + overlays
    manifest = {'revision': REVISION, 'epoch': EPOCH, 'entries': entries, 'overlays': overlays, 'excluded_metadata': excluded,
                'scope': 'Complete original regular parent Git superset, exact declared standard-test replacement in both epochs and one Legacy owner replacement after, plus three exact authored overlays; not minimal observed IO. Gitlinks and non-regular metadata excluded without payload reads.'}
    Path(PREFIX + EPOCH+'-inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
    report = {'revision': REVISION, 'epoch': EPOCH, 'complete': False, 'runs': [],
              'input_tree': tree.relative_to(ROOT).as_posix(),
              'instrument_sha256': streams.sha(Path(__file__).read_bytes()),
              'stream_instrument_sha256': streams.sha((ROOT / (DIAGNOSIS + 'capture.py')).read_bytes()),
              'host_scope': 'Read-only host OS/Perl and standard libraries; project scratch and output on repository volume.'}
    reset = {'TMPDIR', 'TMP', 'TEMP', 'CARGO_HOME', 'CARGO_TARGET_DIR', 'PUB_CACHE',
             'JULIA_DEPOT_PATH', 'PYTHONPYCACHEPREFIX', 'MDBOOK_BUILD__BUILD_DIR'}
    env = {k: v for k, v in os.environ.items() if k not in reset and not k.startswith('LINKEDSPEC_')}
    env.update(PERL5LIB='', PERL5OPT='', PERL_PERTURB_KEYS='2')
    commands = [('regression', 0, ['prove', '-v', '-Iperl', FIXTURE])] if EPOCH == 'before' else [('fixtures', 0, ['prove', '-v', '-Iperl'] + TESTS)]
    cases = json.loads(Path(PREFIX+'cases.json').read_bytes())
    commands += [('legacy', seed, ['perl','-Iperl',Path(PREFIX+'probe.pl').relative_to(ROOT).as_posix()]) for seed in (0,1,42)]
    for kind, seed, tail in commands:
        env['PERL_HASH_SEED'] = str(seed)
        before = streams.verify_tree(tree, guarded)
        command = ['bash', 'tools/project_data_run.sh'] + tail
        result = subprocess.run(command, cwd=tree, env=env, capture_output=True)
        row = {'kind': kind, 'seed': seed, 'command': command, 'exit': result.returncode,
               'stdout': streams.envelope(result.stdout), 'stderr': streams.envelope(result.stderr),
               'inputs_before': before}
        report['runs'].append(row)
        Path(PREFIX + EPOCH+'-observations.json').write_text(json.dumps(report, indent=2) + '\n')
        row['inputs_after'] = streams.verify_tree(tree, guarded)
        Path(PREFIX + EPOCH+'-observations.json').write_text(json.dumps(report, indent=2) + '\n')
        assert result.returncode == (1 if EPOCH == 'before' and kind == 'regression' else 0), 'actual expected RED or GREEN exit'
        print(EPOCH+' '+kind+' seed'+str(seed)+' actual expected exit'+str(result.returncode),flush=True)
    assert report['instrument_sha256'] == streams.sha(Path(__file__).read_bytes())
    report['complete'] = True
    Path(PREFIX + EPOCH+'-observations.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
