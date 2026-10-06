"""Capture the committed complete dedicated annotation family without runtime overlays."""
from pathlib import Path
import importlib.util
import json
import os
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('capture.py')
REVISION = '7dc393211a12d54d5986c8f6a5462c25615ccbc4'
DIAGNOSIS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-'
OVERLAYS = []
ORIGINAL='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.0-'
TESTS = ['t/staged_ast_enrichment_perl_contract.t', 't/progressive_span_dispatch_perl_contract.t', 't/progressive_span_dispatch_perl_authority.t', 't/recognition_transaction_perl_authority.t', 't/recognition_transaction_perl_contract.t', 't/generated_source_contract.t', 't/recursive_observation_perl_contract.t', 't/actionir_helper_source_provenance.t', 't/actionir_statement_source_frames.t', 't/actionir_ast_parser.t', 't/canonical_event_occurrence_order.t', 't/actionir_nested_block_source_spans.t']
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
    scratch = ROOT / '.linkedspec-data/scratch/dedicated-family-acceptance'
    scratch.mkdir(parents=True, exist_ok=True)
    tree = Path(tempfile.mkdtemp(prefix='dedicated-family-acceptance-', dir=scratch))
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
    overlays = []
    for path in OVERLAYS:
        target = tree / Path(path).relative_to(ROOT)
        raw = Path(path).read_bytes()
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw); target.chmod(0o644)
        overlays.append({'path': target.relative_to(tree).as_posix(), 'mode':'100644', 'bytes':len(raw), 'sha256':streams.sha(raw)})
    guarded = entries + overlays
    manifest = {'revision': REVISION, 'entries': entries, 'overlays': overlays, 'excluded_metadata': excluded,
                'scope': 'Complete regular parent Git superset with no runtime overlays; not minimal observed IO. Gitlinks and non-regular metadata excluded without payload reads.'}
    Path(PREFIX + 'inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
    report = {'revision': REVISION, 'complete': False, 'runs': [],
              'input_tree': tree.relative_to(ROOT).as_posix(),
              'instrument_sha256': streams.sha(Path(__file__).read_bytes()),
              'stream_instrument_sha256': streams.sha((ROOT / (DIAGNOSIS + 'capture.py')).read_bytes()),
              'host_scope': 'Read-only host OS/Perl and standard libraries; project scratch and output on repository volume.'}
    reset = {'TMPDIR', 'TMP', 'TEMP', 'CARGO_HOME', 'CARGO_TARGET_DIR', 'PUB_CACHE',
             'JULIA_DEPOT_PATH', 'PYTHONPYCACHEPREFIX', 'MDBOOK_BUILD__BUILD_DIR'}
    env = {k: v for k, v in os.environ.items() if k not in reset and not k.startswith('LINKEDSPEC_')}
    env.update(PERL5LIB='', PERL5OPT='', PERL_PERTURB_KEYS='2')
    commands = [('fixtures', 0, ['prove', '-v', '-Iperl'] + TESTS)]
    commands += [('dedicated', seed, ['perl', '-Iperl', ORIGINAL+'probe.pl']) for seed in (0,1,42)]
    for kind, seed, tail in commands:
        env['PERL_HASH_SEED'] = str(seed)
        before = streams.verify_tree(tree, guarded)
        command = ['bash', 'tools/project_data_run.sh'] + tail
        result = subprocess.run(command, cwd=tree, env=env, capture_output=True)
        row = {'kind': kind, 'seed': seed, 'command': command, 'exit': result.returncode,
               'stdout': streams.envelope(result.stdout), 'stderr': streams.envelope(result.stderr),
               'inputs_before': before}
        report['runs'].append(row)
        Path(PREFIX + 'observations.json').write_text(json.dumps(report, indent=2) + '\n')
        row['inputs_after'] = streams.verify_tree(tree, guarded)
        Path(PREFIX + 'observations.json').write_text(json.dumps(report, indent=2) + '\n')
        assert result.returncode == 0, 'successful actual complete-family recurrence'
        print(kind + ' seed' + str(seed) + ' actual exit0', flush=True)
    assert report['instrument_sha256'] == streams.sha(Path(__file__).read_bytes())
    report['complete'] = True
    Path(PREFIX + 'observations.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
