#!/usr/bin/env python3
"""Capture each readiness child build and exact executable before its tests."""
import fcntl
import json
import os
from pathlib import Path
import subprocess
import sys
import time
import admission_common as a


def workspace_inputs(root):
    values = {}
    for file in sorted(root.rglob('*')):
        assert not file.is_symlink()
        if file.is_file():
            assert file.name != '.git'
            values[file.relative_to(root).as_posix()] = a.read(file.relative_to(a.ROOT).as_posix())
    return values


def main():
    assert sys.argv[1:] == ['test', '--offline', '--quiet', '--color', 'never']
    root = Path.cwd().resolve()
    assert root.is_relative_to(a.ROOT / '.linkedspec-data/scratch')
    assert not any((parent / '.git').exists() for parent in [root, *root.parents]
                   if parent != a.ROOT and parent.is_relative_to(a.ROOT))
    assert root.stat().st_dev == a.ROOT.stat().st_dev
    stem = f'readiness-child-{os.getpid()}-{time.time_ns()}'
    before = workspace_inputs(root)
    a.save(stem + '-inputs.json.gz', dict(producer=a.read(a.PREFIX+'capture_cargo.py'),
        helper=a.read(a.PREFIX+'admission_common.py'), workspace=root.relative_to(a.ROOT).as_posix(),
        original_argv=sys.argv[1:], files=before,
        scope='Actual emitted first-party workspace before Cargo. Split no-run build/direct test execution preserves exact binary custody; the unchanged parent assertions still run all child tests. SDK/dependency implementations remain read-only prerequisites.'))
    lock = a.ROOT / '.linkedspec-data/verification/rust-readiness-capture.lock'
    with lock.open('a+b') as held:
        fcntl.flock(held.fileno(), fcntl.LOCK_EX)
        cargo = os.environ['LINKEDSPEC_READINESS_REAL_CARGO']
        build = a.run([cargo, 'test', '--offline', '--no-run', '--message-format=json',
                       '--color', 'never'], cwd=root)
        a.save(stem + '-build.json.gz', build)
        if build['returncode'] != 0:
            sys.stderr.buffer.write(a.decode(build['stderr_base64']))
            return build['returncode']
        artifacts = []
        for line in a.decode(build['stdout_base64']).splitlines():
            item = json.loads(line)
            if item.get('reason') == 'compiler-artifact' and item.get('executable') \
                    and item.get('profile', {}).get('test'):
                artifacts.append(Path(item['executable']))
        assert len(artifacts) == 1
        executable = artifacts[0]
        relative = executable.relative_to(a.ROOT).as_posix()
        artifact = a.archive(executable, stem)
        supplied = workspace_inputs(root)
        for path, packet in before.items():
            if path != 'Cargo.lock':
                assert supplied[path] == packet
        a.save(stem + '-execution-inputs.json.gz', dict(files=supplied,
            executable=dict(path=relative, artifact=artifact)))
        run = a.run([str(executable)], cwd=root)
        unchanged = a.identity(relative) == {key: artifact[key] for key in ('sha256', 'mode')}
        a.save(stem + '-run.json.gz', dict(run=run, executable_unchanged=unchanged))
        assert unchanged
        sys.stdout.buffer.write(a.decode(run['stdout_base64']))
        sys.stderr.buffer.write(a.decode(run['stderr_base64']))
        return run['returncode']


if __name__ == '__main__':
    raise SystemExit(main())
