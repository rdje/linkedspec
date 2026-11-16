"""One-shot logical source capture; no Perl tests or historical writers execute."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import stat
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = '3f619e9c2aa74d0f3f8d9d64c2c90e82d11d81e0'
PRIOR = Path('docs/checkpoints/canonical-discovery-inventory-2026-11-16')


def main():
    assert not (BASE / 'inputs.tar.gz').exists(), 'capture is one-shot'
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    inventory = json.loads(gzip.decompress((PRIOR / 'inventory.json.gz').read_bytes()))
    paths = {row['path'] for row in inventory['rows'] if row['backend'] == 'perl'
             and (row['required'] or row['review_candidate'])}
    for target in re.findall(r"do File::Spec->catfile\(\$repo_root, 't', '([^']+\.t)'\)",
                             Path('t/callable_codeblock_literal_contract.t').read_text()):
        paths.add('t/' + target)
    paths.update(['tools/run_ci_local.sh', str(PRIOR / 'inventory.json.gz'),
                  str(PRIOR / 'perl-selector-stdout.gz'),
                  'tools/run_python_project_data.sh', 'tools/project_data_run.sh', 'tools/project_data_env.sh'])
    argv = ['git', 'ls-tree', '-rz', ACTIVATION, '--', *sorted(paths)]
    result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (BASE / 'git-tree.json.gz').write_bytes(gzip.compress(json.dumps(dict(
        argv=argv, cwd='.', exit=result.returncode, stdout_hex=result.stdout.hex(),
        stderr_hex=result.stderr.hex()), sort_keys=True).encode(), mtime=0))
    assert result.returncode == 0 and not result.stderr
    paths.update(str(BASE / name) for name in ('capture.py', 'review.py', 'run_step.py'))
    identities = {}
    with tarfile.open(BASE / 'inputs.tar.gz', 'x:gz') as archive:
        for name in sorted(paths):
            path = Path(name)
            assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
            assert path.resolve().is_relative_to(ROOT) and path.stat().st_dev == ROOT.stat().st_dev
            info = path.stat()
            assert stat.S_ISREG(info.st_mode)
            identities[name] = dict(sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                                    mode=stat.S_IMODE(info.st_mode))
            archive.add(path, arcname=name, recursive=False)
    (BASE / 'identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
    spec = importlib.util.spec_from_file_location('perl_roles', BASE / 'review.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    inputs = module.recover()
    roles, includes = module.reconstruct(inputs)
    (BASE / 'roles.json').write_text(json.dumps(roles, indent=2, sort_keys=True) + '\n')
    (BASE / 'named-includes.json').write_text(json.dumps(includes, indent=2, sort_keys=True) + '\n')
    print(json.dumps(module.validate(inputs, roles), sort_keys=True))


if __name__ == '__main__':
    main()
