"""Capture supplemental grouped-pattern observer against exact committed inputs."""
from pathlib import Path
import importlib.util
import json
import os
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('grouped-capture.py')
STREAM = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
spec = importlib.util.spec_from_file_location('grouped_streams', ROOT / STREAM)
streams = importlib.util.module_from_spec(spec); spec.loader.exec_module(streams)


def main():
    inputs = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    capture = json.loads(Path(PREFIX + 'observations.json').read_bytes())
    assert inputs['overlays'] == [] and inputs['revision'] == '0f31461d696186775585e19355a0bc5c41849dfb'
    tree = ROOT / capture['input_tree']; assert tree.stat().st_dev == ROOT.stat().st_dev
    report = {'complete': False, 'revision': inputs['revision'], 'input_tree': capture['input_tree'],
              'input_manifest_sha256': streams.sha(Path(PREFIX + 'inputs.json').read_bytes()),
              'instrument_sha256': streams.sha(Path(__file__).read_bytes()),
              'stream_instrument_sha256': streams.sha((ROOT / STREAM).read_bytes()), 'runs': [],
              'scope': 'Exact complete committed regular input superset; one explicitly supplied external '
                       'read-only observer per command. No production/test overlays; all project data stays '
                       'repository-local/same-volume. Separate from the main73-command population.'}
    for probe in ('return-grouped-probe.pl', 'grouped-probe.pl'):
        path = Path(PREFIX + probe); digest = streams.sha(path.read_bytes())
        for seed in (0, 1, 42):
            reset = {'TMPDIR', 'TMP', 'TEMP', 'CARGO_HOME', 'CARGO_TARGET_DIR', 'PUB_CACHE',
                     'JULIA_DEPOT_PATH', 'PYTHONPYCACHEPREFIX', 'MDBOOK_BUILD__BUILD_DIR'}
            env = {k: v for k, v in os.environ.items() if k not in reset and not k.startswith('LINKEDSPEC_')}
            env.update(PERL5LIB='', PERL5OPT='', PERL_HASH_SEED=str(seed), PERL_PERTURB_KEYS='2')
            count = streams.verify_tree(tree, inputs['entries'])
            command = ['bash', 'tools/project_data_run.sh', 'perl', '-Iperl', str(path)]
            actual = subprocess.run(command, cwd=tree, env=env, capture_output=True)
            assert streams.sha(path.read_bytes()) == digest, 'unchanged actual supplied observer'
            report['runs'].append({'kind': probe, 'seed': seed,
                'command': ['bash', 'tools/project_data_run.sh', 'perl', '-Iperl',
                            {'read_only_program_from_repository_root': path.relative_to(ROOT).as_posix()}],
                'actual_command': streams.envelope(json.dumps(command).encode()),
                'producer': path.relative_to(ROOT).as_posix(), 'producer_sha256': digest,
                'inputs_before': count, 'inputs_after': streams.verify_tree(tree, inputs['entries']),
                'exit': actual.returncode, 'stdout': streams.envelope(actual.stdout),
                'stderr': streams.envelope(actual.stderr)})
            Path(PREFIX + 'grouped-observations.json').write_text(json.dumps(report, indent=2) + '\n')
            print(probe, seed, actual.returncode, flush=True)
    assert report['instrument_sha256'] == streams.sha(Path(__file__).read_bytes()), 'unchanged actual capture producer'
    report['complete'] = True
    Path(PREFIX + 'grouped-observations.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
