"""Capture one finite native source epoch; never invoke an SDK or test suite."""
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
ACTIVATION = 'cb8978713452f427823f56e456ddc71ad75f0574'
PRIOR = Path('docs/checkpoints/canonical-discovery-inventory-2026-11-16/inventory.json.gz')


def main():
    assert not (BASE / 'inputs.tar.gz').exists(), 'one-shot capture'
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    inventory = json.loads(gzip.decompress(PRIOR.read_bytes()))
    paths = {row['path'] for row in inventory['rows'] if row['backend'] in ('rust', 'dart', 'julia', 'lua')
             and (row['required'] or row['review_candidate'])}
    paths.update(str(name) for name in [PRIOR, 'rust/Cargo.toml', 'rust/linkedspec-runtime/Cargo.toml',
        'dart/pubspec.yaml', 'julia/Project.toml', 'julia/test/runtests.jl', 'lua/test/run.lua',
        'tools/run_ci_local.sh', 'tools/run_rust_local.sh', 'tools/run_dart_local.sh',
        'tools/run_julia_local.sh', 'tools/run_lua_local.sh', 'tools/run_python_project_data.sh',
        'tools/project_data_run.sh', 'tools/project_data_env.sh'])
    command = ['git', 'ls-tree', '-rz', ACTIVATION, '--', *sorted(paths)]
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (BASE / 'activation-tree.json').write_text(json.dumps(dict(activation=ACTIVATION, argv=command,
        cwd='.', exit=result.returncode, stdout_hex=result.stdout.hex(), stderr_hex=result.stderr.hex()), indent=2) + '\n')
    assert result.returncode == 0 and result.stderr == b''
    paths.update(str(BASE / name) for name in ('capture.py', 'review.py', 'run_step.py', 'branches.py'))
    identities = {}
    with tarfile.open(BASE / 'inputs.tar.gz', 'x:gz') as archive:
        for name in sorted(paths):
            path = Path(name)
            assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
            assert path.resolve().is_relative_to(ROOT) and path.stat().st_dev == ROOT.stat().st_dev
            assert stat.S_ISREG(path.stat().st_mode)
            body = path.read_bytes()
            identities[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
            archive.add(path, arcname=name, recursive=False)
    (BASE / 'identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
    spec = importlib.util.spec_from_file_location('native_route_epoch', BASE / 'review.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    sources, _ = module.recover()
    ledger = module.reconstruct(sources)
    (BASE / 'roles.json').write_text(json.dumps(ledger, indent=2, sort_keys=True) + '\n')
    print(json.dumps(dict(result='PASS', sources=len(sources), candidates=len(ledger['candidates'])), sort_keys=True))


if __name__ == '__main__':
    main()
