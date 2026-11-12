"""Retain exact inputs and format new Dart instruments before runtime use."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
out = BASE / 'normal-format'
out.mkdir()
targets = [Path('dart/test/array_concat_open_arity_result_guard_composition_test.dart')]
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'dart', 'tests/fixtures'], text=True).splitlines()]
paths += targets
paths += [Path('tests/fixtures/array_concat_open_arity_dart_cases.json'), Path('tests/fixtures/array_concat_open_arity_result_guard_dart_profiles.json'), Path('dart/tool/probe_open_arity_array_concat_results.dart')]
paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
paths += [Path('tools') / name for name in ('project_data_run.sh', 'project_data_env.sh', 'run_dart_project_data.sh')]
paths += [p.relative_to(ROOT) for p in BASE.iterdir() if p.is_file()]
config = Path('dart/.dart_tool/package_config.json')
if config.exists():
    paths.append(config)
rows = {}
with tarfile.open(out / 'inputs-before-use.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        rows[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(out / 'inputs-before-use.tar.gz') as archive:
    assert set(archive.getnames()) == rows.keys()
    for member in archive:
        raw = archive.extractfile(member).read()
        row = rows[member.name]
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
(out / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
command = ['bash', '../tools/run_dart_project_data.sh', 'format', *[str(path.relative_to('dart')) for path in targets]]
(out / 'command.json').write_text(json.dumps(dict(argv=command, cwd='dart', environment={}), indent=2) + '\n')
result = subprocess.run(command, cwd=ROOT / 'dart', stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (out / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(out / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0
after = {}
for name, row in rows.items():
    path = Path(name)
    raw = path.read_bytes()
    if path in targets:
        packed = out / (path.name + '.gz')
        packed.write_bytes(gzip.compress(raw, mtime=0))
        after[name] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
    else:
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode'], name
(out / 'formatted-identities.json').write_text(json.dumps(after, indent=2, sort_keys=True) + '\n')
print('New Dart instruments formatted with complete before-use input retention; production unchanged')
