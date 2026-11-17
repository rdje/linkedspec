"""Capture fixed sources before interpretation, then all manifest-selected bodies."""
import hashlib
import importlib.util
import json
from pathlib import Path
import stat
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
PRIOR = Path('docs/checkpoints/native-consumer-routes-2026-11-16')


def archive(label, paths):
    identities = {}
    with tarfile.open(BASE / (label + '.tar.gz'), 'x:gz') as packed:
        for name in sorted(paths):
            path = Path(name)
            assert not path.is_absolute() and '..' not in path.parts and path.is_file() and not path.is_symlink()
            assert path.resolve().is_relative_to(ROOT) and path.stat().st_dev == ROOT.stat().st_dev
            body = path.read_bytes()
            identities[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
            packed.add(path, arcname=name, recursive=False)
    (BASE / (label + '-identities.json')).write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')


def main():
    plan = json.loads((BASE / 'plan.json').read_bytes())
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == plan['activation']
    assert not (BASE / 'preparation.tar.gz').exists(), 'one-shot capture'
    references = {}
    for leaf in ('review.py', 'inputs.tar.gz', 'identities.json', 'activation-tree.json', 'roles.json'):
        path = PRIOR / leaf
        references[str(path)] = dict(sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
    (BASE / 'reused-inputs.json').write_text(json.dumps(references, indent=2, sort_keys=True) + '\n')
    instruments = {str(BASE / name) for name in ('plan.json', 'capture.py', 'review.py', 'run_step.py')}
    fixed = set(plan['fixed_inputs']) | instruments
    archive('preparation', fixed)
    spec = importlib.util.spec_from_file_location('generated_rust_roles', BASE / 'review.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    sources, _ = module.prior_sources()
    prepared, _ = module.image('preparation')
    assert not set(sources) & set(prepared)
    sources.update(prepared)
    targets = set(module.expand(sources))
    assert not targets & set(sources)
    archive('corpus', targets)
    corpus, _ = module.image('corpus')
    sources.update(corpus)
    argv = ['git', 'ls-tree', '-rz', plan['activation'], '--', *sorted((set(sources) - instruments) | set(references))]
    result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (BASE / 'activation-tree.json').write_text(json.dumps(dict(activation=plan['activation'], argv=argv, cwd='.',
        exit=result.returncode, stdout_hex=result.stdout.hex(), stderr_hex=result.stderr.hex()), indent=2) + '\n')
    assert result.returncode == 0 and not result.stderr
    sources, _ = module.recover()
    ledger = module.scan(sources)
    (BASE / 'loaders.json').write_text(json.dumps(ledger, indent=2, sort_keys=True) + '\n')
    print(json.dumps(dict(result='PASS', retained_inputs=len(sources), bindings=len(ledger['input_edges']))))


if __name__ == '__main__':
    main()
