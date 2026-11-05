"""Focused Count/length and copied-null index compatibility with actual inputs."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tarfile

root = Path.cwd()
base = Path(__file__).resolve().parent.relative_to(root)
out = base / 'compat'
out.mkdir()
paths = ['dart/pubspec.yaml', 'dart/pubspec.lock', 'dart/.dart_tool/package_config.json',
         'dart/lib/src/runtime/interpreter.dart', 'dart/test/count_length_receivers_test.dart',
         'dart/test/copied_null_index_composition_test.dart', 'tests/fixtures/copied_null_index_cases.json']
images = {name: hashlib.sha256(Path(name).read_bytes()).hexdigest() for name in paths}
with tarfile.open(out / 'before-first-run.tar.gz', 'w:gz') as archive:
    for name in paths:
        assert not Path(name).is_symlink()
        archive.add(name, arcname=name, recursive=False)
with tarfile.open(out / 'before-first-run.tar.gz') as archive:
    assert {m.name: hashlib.sha256(archive.extractfile(m).read()).hexdigest()
            for m in archive.getmembers() if m.isfile()} == images
(out / 'inputs.json').write_text(json.dumps(images, sort_keys=True, indent=2) + '\n')
for tag, arguments in [
    ('length', ['test/count_length_receivers_test.dart']),
    ('index', ['test/copied_null_index_composition_test.dart', '--name', '^valid_null_numeric_copy$']),
]:
    command = ['bash', '../tools/ram_guard.sh', '--danger-pct', '86', '--ceiling-mb', '2048', '--',
               'bash', '../tools/run_dart_project_data.sh', 'test', '--reporter', 'expanded',
               '--concurrency=1', *arguments]
    (out / (tag + '-command.json')).write_text(json.dumps({'cwd': 'dart', 'command': command}) + '\n')
    with (out / (tag + '-stdout.log')).open('wb') as stdout, (out / (tag + '-stderr.log')).open('wb') as stderr:
        result = subprocess.run(command, cwd=root / 'dart', env=dict(os.environ, TERM='dumb', NO_COLOR='1'), stdout=stdout, stderr=stderr)
    (out / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, tag
assert all(hashlib.sha256(Path(name).read_bytes()).hexdigest() == digest for name, digest in images.items())
print('PASS: Count/length2 and copied-null index1; actual root inputs retained unchanged')
