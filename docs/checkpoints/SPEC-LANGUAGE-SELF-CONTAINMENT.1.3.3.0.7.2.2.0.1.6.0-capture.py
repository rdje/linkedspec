"""Capture original family channels and new cross-family evidence on fixed Git inputs."""
from pathlib import Path
import importlib.util
import json
import os
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('capture.py')
REVISION = '37401f576c517a91f49942893c41af020bcbfda4'
BASE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.'
STREAM = BASE + '1.1.0-capture.py'
OVERLAYS = [Path(PREFIX + name).relative_to(ROOT).as_posix() for name in ('cases.json', 'probe.pl')]
TESTS = [
    'actionir_statement_source_frames', 'actionir_basic_statement_source_provenance',
    'actionir_basic_regex_source_provenance', 'actionir_helper_source_provenance',
    'actionir_ast_parser', 'canonical_event_occurrence_order', 'actionir_raw_dependency_provenance',
    'actionir_nested_block_source_spans', 'uniform_binding_contract', 'codeblock_push_composition_perl',
    'trace_actionir_pipeline', 'actionir_pipeline_regex_source_provenance',
    'actionir_pipeline_split_source_metadata', 'actionir_pipeline_statement_source_provenance',
    'actionir_flow_recursive_source_provenance', 'actionir_flow_direct_source_provenance',
    'actionir_method_argument_source_frames', 'trace_actionir_method_lowering',
    'nested_boundary_quoted_labels', 'capture_boundary_quoted_labels',
    'typed_source_location_perl_contract', 'complete_named_mark_contract', 'generated_source_contract',
    'staged_ast_enrichment_perl_contract', 'progressive_span_dispatch_perl_contract',
    'progressive_span_dispatch_perl_authority', 'recognition_transaction_perl_authority',
    'recognition_transaction_perl_contract', 'recursive_observation_perl_contract',
]
TESTS = ['t/' + name + '.t' for name in TESTS]
PROBES = [
    ('basic', BASE + '1.2.0-probe.pl'),
    ('pipeline', BASE + '2.2-probe.pl'),
    ('flow', BASE + '3.2.1-probe.pl'),
    ('legacy', BASE + '4.6-probe.pl'),
    ('dedicated', BASE + '5.0-probe.pl'),
    ('foreign-source', BASE + '1.1.2-guard-probe.pl'),
    ('method-frames', BASE + '3.2.0.1-frames-probe.pl'),
]
spec = importlib.util.spec_from_file_location('retained_stream_guard', ROOT / STREAM)
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
    scratch = ROOT / '.linkedspec-data/scratch/all-producer-source-composition'
    scratch.mkdir(parents=True, exist_ok=True)
    tree = Path(tempfile.mkdtemp(prefix='original-composition-', dir=scratch))
    assert tree.stat().st_dev == ROOT.stat().st_dev
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for entry in entries:
            process.stdin.write((entry['oid'] + '\n').encode()); process.stdin.flush()
            assert process.stdout.readline().split() == [entry['oid'].encode(), b'blob', str(entry['bytes']).encode()]
            raw = process.stdout.read(entry['bytes'])
            assert process.stdout.read(1) == b'\n'
            target = tree / entry['path']
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod(int(entry['mode'][-3:], 8))
            entry['sha256'] = streams.sha(raw)
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    original_count = len(entries)
    for path in OVERLAYS:
        assert path not in {e['path'] for e in entries}, 'authored overlay cannot replace committed input'
        raw = (ROOT / path).read_bytes()
        target = tree / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw); target.chmod(0o644)
        entries.append({'path': path, 'mode': '100644', 'bytes': len(raw),
                        'sha256': streams.sha(raw), 'declared_authored_overlay': True})
    manifest = {'revision': REVISION, 'entries': entries, 'overlays': OVERLAYS,
                'regular_git_inputs': original_count, 'excluded_metadata': excluded,
                'scope': 'Complete regular committed Git superset plus exactly two authored observation inputs; no production/fixture replacements. Not minimal observed IO; Gitlink/nonregular payloads excluded.'}
    Path(PREFIX + 'inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
    report = {'revision': REVISION, 'complete': False, 'runs': [],
              'input_tree': tree.relative_to(ROOT).as_posix(),
              'instrument_sha256': streams.sha(Path(__file__).read_bytes()),
              'stream_instrument_sha256': streams.sha((ROOT / STREAM).read_bytes()),
              'host_scope': 'Necessary read-only OS/Perl/standard libraries; project outputs on repository volume.'}
    reset = {'TMPDIR', 'TMP', 'TEMP', 'CARGO_HOME', 'CARGO_TARGET_DIR', 'PUB_CACHE',
             'JULIA_DEPOT_PATH', 'PYTHONPYCACHEPREFIX', 'MDBOOK_BUILD__BUILD_DIR'}
    env = {k: v for k, v in os.environ.items() if k not in reset and not k.startswith('LINKEDSPEC_')}
    env.update(PERL5LIB='', PERL5OPT='', PERL_PERTURB_KEYS='2')
    probe_path = Path(PREFIX + 'probe.pl').relative_to(ROOT).as_posix()
    commands = [('cross-family', seed, ['perl', '-Iperl', probe_path]) for seed in (0, 1, 42)]
    commands += [('fixtures', 0, ['prove', '-v', '-Iperl'] + TESTS)]
    commands += [(kind, seed, ['perl', '-Iperl', path]) for kind, path in PROBES for seed in (0, 1, 42)]
    commands += [('identity-control', 0, ['perl', '-Iperl', BASE + '2.2-identity-probe.pl'])]
    for kind, seed, tail in commands:
        env['PERL_HASH_SEED'] = str(seed)
        before = streams.verify_tree(tree, entries)
        command = ['bash', 'tools/project_data_run.sh'] + tail
        result = subprocess.run(command, cwd=tree, env=env, capture_output=True)
        row = {'kind': kind, 'seed': seed, 'command': command, 'exit': result.returncode,
               'stdout': streams.envelope(result.stdout), 'stderr': streams.envelope(result.stderr),
               'inputs_before': before}
        report['runs'].append(row)
        Path(PREFIX + 'observations.json').write_text(json.dumps(report, indent=2) + '\n')
        row['inputs_after'] = streams.verify_tree(tree, entries)
        Path(PREFIX + 'observations.json').write_text(json.dumps(report, indent=2) + '\n')
        assert result.returncode == 0, 'actual completed observation command'
        print(kind + ' seed' + str(seed) + ' actual exit0', flush=True)
    assert report['instrument_sha256'] == streams.sha(Path(__file__).read_bytes())
    report['complete'] = True
    Path(PREFIX + 'observations.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
