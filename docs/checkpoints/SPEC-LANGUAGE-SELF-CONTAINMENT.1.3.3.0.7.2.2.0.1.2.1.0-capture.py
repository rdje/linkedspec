"""Capture a nineteen-contract pipeline recurrence from immutable regular Git inputs."""
from pathlib import Path
import argparse
import importlib.util
import json
import os
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('capture.py')
REVISION = 'b6fa57422a803a8d70b3e391cc2c4c70d7d6cf25'
DIAGNOSIS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-'
DIAGNOSIS_PROBE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.0-'
OWNER = 'perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm'
FIXTURE = 't/actionir_pipeline_regex_source_provenance.t'
COMMON = [FIXTURE, Path(PREFIX + 'before-PrimitivePipelineRules.pm').relative_to(ROOT).as_posix()]
GUARD = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2-'
TESTS = ['t/actionir_statement_source_frames.t', 't/actionir_helper_source_provenance.t',
         't/actionir_ast_parser.t', 't/canonical_event_occurrence_order.t',
         't/uniform_binding_contract.t', 't/codeblock_push_composition_perl.t',
         't/trace_actionir_pipeline.t']
spec = importlib.util.spec_from_file_location('streams', ROOT / (DIAGNOSIS + 'capture.py'))
streams = importlib.util.module_from_spec(spec)
spec.loader.exec_module(streams)


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--epoch',choices=('before','after'),required=True)
    epoch=parser.parse_args().epoch
    overlays=COMMON+([OWNER] if epoch=='after' else [])
    output=PREFIX+epoch+'-'
    entries, excluded = [], []
    listing = subprocess.check_output(['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT)
    for row in filter(None, listing.split(b'\0')):
        metadata, path = row.split(b'\t', 1)
        mode, kind, oid, size = metadata.split()
        if kind != b'blob' or mode not in (b'100644', b'100755'):
            excluded.append({'path': path.decode(), 'mode': mode.decode(), 'kind': kind.decode()})
            continue
        entries.append({'path': path.decode(), 'mode': mode.decode(), 'oid': oid.decode(), 'bytes': int(size)})
    scratch = ROOT / '.linkedspec-data/scratch/pipeline-source-provenance'
    scratch.mkdir(parents=True, exist_ok=True)
    tree = Path(tempfile.mkdtemp(prefix=epoch+'-regex-', dir=scratch))
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
    replacements=[]
    for path in overlays:
        raw = (ROOT / path).read_bytes()
        target = tree / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
        target.chmod(0o644)
        previous=next((e for e in entries if e['path']==path),None)
        if previous:
            replacements.append(previous);entries.remove(previous)
        entries.append({'path': path, 'mode': '100644', 'bytes': len(raw), 'sha256': streams.sha(raw), 'overlay': True})
    manifest = {'revision': REVISION, 'entries': entries, 'excluded_metadata': excluded,
                'epoch':epoch,'replaced_git_members':replacements,
                'scope':'Complete regular parent Git superset plus unchanged original-owner/new-fixture overlays; after replaces exactly one producer with the candidate bytes. Not minimal observed IO; black-box metadata excluded without payload reads.'}
    Path(output + 'inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
    report = {'revision': REVISION, 'epoch':epoch, 'complete': False, 'runs': [],
              'input_tree': tree.relative_to(ROOT).as_posix(),
              'instrument_sha256': streams.sha(Path(__file__).read_bytes()),
              'stream_instrument_sha256': streams.sha((ROOT / (DIAGNOSIS + 'capture.py')).read_bytes()),
              'host_scope': 'Read-only host OS/Perl and standard libraries; project scratch and output on repository volume.'}
    reset = {'TMPDIR', 'TMP', 'TEMP', 'CARGO_HOME', 'CARGO_TARGET_DIR', 'PUB_CACHE',
             'JULIA_DEPOT_PATH', 'PYTHONPYCACHEPREFIX', 'MDBOOK_BUILD__BUILD_DIR'}
    env = {k: v for k, v in os.environ.items() if k not in reset and not k.startswith('LINKEDSPEC_')}
    env.update(PERL5LIB='', PERL5OPT='', PERL_PERTURB_KEYS='2')
    commands=[('regression',0,['prove','-v','-Iperl',FIXTURE])]
    commands += [('toolbox', seed, ['perl','-Iperl',DIAGNOSIS_PROBE+'probe.pl']) for seed in (0,1,42)]
    commands += [('foreign-source',seed,['perl','-Iperl',GUARD+'guard-probe.pl']) for seed in (0,1,42)]
    commands += [('split-toolbox',0,['perl','-Iperl',DIAGNOSIS_PROBE+'split-probe.pl'])]
    if epoch=='after':
        commands += [('fixtures',0,['prove','-v','-Iperl']+TESTS),('phase0',0,['prove','-v','-Iperl','t/phase0_regression.t'])]
    for kind, seed, tail in commands:
        env['PERL_HASH_SEED'] = str(seed)
        env['LINKEDSPEC_PIPELINE_REGEX_BASELINE']='1' if epoch=='before' and kind=='regression' else '0'
        before = streams.verify_tree(tree, entries)
        command = ['bash', 'tools/project_data_run.sh'] + tail
        result = subprocess.run(command, cwd=tree, env=env, capture_output=True)
        row = {'kind': kind, 'seed': seed, 'command': command, 'exit': result.returncode,
               'stdout': streams.envelope(result.stdout), 'stderr': streams.envelope(result.stderr),
               'inputs_before': before,'baseline_environment':env['LINKEDSPEC_PIPELINE_REGEX_BASELINE']}
        report['runs'].append(row)
        Path(output + 'observations.json').write_text(json.dumps(report, indent=2) + '\n')
        row['inputs_after'] = streams.verify_tree(tree, entries)
        Path(output + 'observations.json').write_text(json.dumps(report, indent=2) + '\n')
        expected_exit=1 if epoch=='before' and kind=='regression' else 0
        assert result.returncode == expected_exit, 'actual expected exit'
        print(epoch+' '+kind+' seed'+str(seed)+' actual exit'+str(result.returncode),flush=True)
    assert report['instrument_sha256'] == streams.sha(Path(__file__).read_bytes())
    report['complete'] = True
    Path(output + 'observations.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
