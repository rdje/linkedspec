"""Retain the additional Dart inputs before source qualification; never execute Dart."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import stat
import subprocess
import tarfile

ROOT = Path.cwd().resolve(); BASE = Path(__file__).resolve().parent.relative_to(ROOT)
PRIOR = Path('docs/checkpoints/native-consumer-routes-2026-11-16')


def main():
    assert not (BASE / 'inputs.tar.gz').exists(), 'one-shot capture'
    plan = json.loads((BASE / 'plan.json').read_bytes())
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == plan['activation']
    paths = {plan['grammar'], plan['grammar_constant_owner']}
    for row in plan['consumers']:
        paths.update(row[key] for key in ('cases', 'profiles', 'historical'))
        if 'support' in row:
            paths.add(row['support'])
    references = {}
    for leaf in ('review.py', 'inputs.tar.gz', 'identities.json', 'activation-tree.json', 'roles.json'):
        path = PRIOR / leaf
        references[str(path)] = dict(sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
    (BASE / 'reused-inputs.json').write_text(json.dumps(references, indent=2, sort_keys=True) + '\n')
    argv = ['git', 'ls-tree', '-rz', plan['activation'], '--', *sorted(paths | set(references))]
    result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (BASE / 'activation-tree.json').write_text(json.dumps(dict(activation=plan['activation'], argv=argv, cwd='.',
        exit=result.returncode, stdout_hex=result.stdout.hex(), stderr_hex=result.stderr.hex()), indent=2) + '\n')
    assert result.returncode == 0 and not result.stderr
    paths.update(str(BASE / leaf) for leaf in ('plan.json', 'capture.py', 'review.py', 'run_step.py'))
    identities = {}
    with tarfile.open(BASE / 'inputs.tar.gz', 'x:gz') as archive:
        for name in sorted(paths):
            path = Path(name)
            assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
            assert path.resolve().is_relative_to(ROOT) and path.stat().st_dev == ROOT.stat().st_dev and path.is_file()
            body = path.read_bytes()
            identities[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
            archive.add(path, arcname=name, recursive=False)
    (BASE / 'identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
    spec = importlib.util.spec_from_file_location('dart_array_loaders', BASE / 'review.py')
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    sources, _ = module.recover(); ledger = module.reconstruct(sources)
    (BASE / 'loaders.json').write_text(json.dumps(ledger, indent=2, sort_keys=True) + '\n')
    print(json.dumps(dict(result='PASS', additional_inputs=len(identities), consumers=3), sort_keys=True))


if __name__ == '__main__':
    main()
