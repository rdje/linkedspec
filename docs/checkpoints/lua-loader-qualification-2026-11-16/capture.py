"""Capture additional direct inputs while reusing the unchanged committed source epoch."""
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
ACTIVATION = '341f488d36b15cb39069db32a74e3dc5d82a70d8'


def main():
    assert not (BASE / 'inputs.tar.gz').exists(), 'one-shot capture'
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    rows = json.loads((PRIOR / 'roles.json').read_bytes())['candidates']
    names = [row['path'] for row in rows if row['backend'] == 'lua' and row['route'].startswith('no direct')]
    paths = {name.removesuffix('_test.lua') + '_cases.json' for name in names
             if name not in ('lua/test/raw_error_observation_test.lua', 'lua/test/gap_ls_selected_cursor_test.lua')}
    paths.update(['dart/test/fixtures/gap_ls_cursor.json', 'dart/test/fixtures/gap_ls_broad_carrier.json',
        'tests/fixtures/lua_raw_error_observation_cases.json', 'tests/fixtures/lua_raw_error_observation_profiles.json',
        'specs/user_function_definition.spec', 'lua/test/raw_error_observation.lua', 'lua/test/callable_array_transform_observation.lua',
        'lua/src/linkedspec/user_function_definition_parser.lua',
        'docs/checkpoints/lua-raw-error-observation-2026-11-13/normal/input-identities.json'])
    references = {}
    for leaf in ('review.py', 'inputs.tar.gz', 'identities.json', 'activation-tree.json', 'roles.json'):
        path = PRIOR / leaf
        references[str(path)] = dict(sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
    (BASE / 'reused-inputs.json').write_text(json.dumps(references, indent=2, sort_keys=True) + '\n')
    argv = ['git', 'ls-tree', '-rz', ACTIVATION, '--', *sorted(paths | set(references))]
    result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (BASE / 'activation-tree.json').write_text(json.dumps(dict(activation=ACTIVATION, argv=argv, cwd='.',
        exit=result.returncode, stdout_hex=result.stdout.hex(), stderr_hex=result.stderr.hex()), indent=2) + '\n')
    assert result.returncode == 0 and not result.stderr
    paths.update(str(BASE / leaf) for leaf in ('capture.py', 'review.py', 'run_step.py'))
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
    spec = importlib.util.spec_from_file_location('lua_loader_epoch', BASE / 'review.py')
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    sources, _ = module.recover()
    ledger = module.reconstruct(sources)
    (BASE / 'loaders.json').write_text(json.dumps(ledger, indent=2, sort_keys=True) + '\n')
    print(json.dumps(dict(result='PASS', consumers=len(names), additional_inputs=len(identities)), sort_keys=True))


if __name__ == '__main__':
    main()
