"""One-shot source capture for a static Dart loader qualification; no SDK use."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import stat
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)


def main():
    assert not (BASE / 'inputs.tar.gz').exists(), 'completed capture is not replayable'
    config = json.loads((BASE / 'qualification.json').read_bytes())
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == config['activation']
    prior = json.loads(Path(config['prior_ledger']).read_bytes())
    paths = {row['path'] for row in config['consumers']}
    paths.update(path for values in prior['consumers'].values() for path in values)
    paths.update(config['callable_inputs'])
    paths.update([config['loader'], config['grammar'], config['prior_ledger'], config['callable_support'],
                  'tools/run_python_project_data.sh', 'tools/project_data_env.sh', 'tools/project_data_run.sh'])
    argv = ['git', 'ls-tree', '-rz', 'HEAD', '--', *sorted(paths)]
    process = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    record = dict(argv=argv, cwd='.', exit=process.returncode,
                  stdout_hex=process.stdout.hex(), stderr=process.stderr.decode())
    (BASE / 'git-tree.json.gz').write_bytes(gzip.compress(json.dumps(record, sort_keys=True).encode(), mtime=0))
    assert process.returncode == 0 and not process.stderr
    paths.update(str(BASE / name) for name in ('capture.py', 'review.py', 'qualification.json'))
    identities = {}
    with tarfile.open(BASE / 'inputs.tar.gz', 'x:gz') as archive:
        for name in sorted(paths):
            path = Path(name)
            assert not path.is_absolute() and '..' not in path.parts
            assert not path.is_symlink() and path.resolve().is_relative_to(ROOT)
            info = path.stat()
            assert stat.S_ISREG(info.st_mode) and info.st_dev == ROOT.stat().st_dev
            identities[name] = dict(sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=stat.S_IMODE(info.st_mode))
            archive.add(path, arcname=name, recursive=False)
    (BASE / 'identities.json').write_text(json.dumps(identities, sort_keys=True, indent=2) + '\n')
    # Import only after preserving the actual instrument and its project inputs.
    spec = importlib.util.spec_from_file_location('dart_loader_review', BASE / 'review.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    inputs = module.recover()
    rows = module.reconstruct(inputs, config)
    (BASE / 'loaders.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
    result = module.validate(inputs, config, rows)
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
