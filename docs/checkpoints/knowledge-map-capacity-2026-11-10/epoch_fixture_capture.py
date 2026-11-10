"""Retain scoped epoch-source inputs and actual full fixture-check observations."""
import argparse
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
TEST = 'tools/test_task_narrative.py'


def image(raw):
    return {'sha256': hashlib.sha256(raw).hexdigest(), 'base64': base64.b64encode(raw).decode()}


def capture(epoch):
    destination = HERE / ('epoch-fixture-qualified-' + epoch + '.json.gz')
    assert not destination.exists(), 'one-shot epoch capture already exists'
    paths = [TEST, 'tools/task_narrative.py', 'tools/migrate_task_narrative.py',
             'tools/read_task_narrative.py', 'tools/run_python_project_data.sh',
             'tools/project_data_env.sh', 'tools/project_data_run.sh',
             Path(__file__).relative_to(ROOT).as_posix()]
    for path in sorted((ROOT / 'docs/history/task-narrative-epochs').iterdir()):
        row = json.loads(path.read_bytes())
        paths.extend((path.relative_to(ROOT).as_posix(), row['source_path']))
    inputs = {name: image((ROOT / name).read_bytes()) for name in sorted(set(paths))}
    # The original staged producer is still retained while its worktree repair
    # is prepared. Execute those exact bytes privately with the real owned
    # helper modules, without replacing the repaired production file.
    command = ['bash', 'tools/run_python_project_data.sh', TEST]
    if epoch == 'before':
        original = subprocess.check_output(['git', 'show', ':' + TEST], cwd=ROOT)
        inputs[TEST] = image(original)
        with tempfile.TemporaryDirectory(prefix='epoch-before-', dir=os.environ['LINKEDSPEC_RUN_DIR']) as name:
            path = Path(name) / 'test_task_narrative.py'
            path.write_bytes(original)
            command[-1] = path.relative_to(ROOT).as_posix()
            result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, PYTHONPATH='tools'), capture_output=True)
    else:
        result = subprocess.run(command, cwd=ROOT, capture_output=True)
    for name, saved in inputs.items():
        if name != TEST or epoch != 'before':
            assert image((ROOT / name).read_bytes()) == saved, 'input changed during observation'
    packet = {'epoch': epoch, 'command': command, 'inputs': inputs,
              'returncode': result.returncode, 'stdout': image(result.stdout), 'stderr': image(result.stderr),
              'logical_producer': TEST,
              'source_version': 'staged-original' if epoch == 'before' else 'worktree-candidate',
              'scope': 'Complete scoped fixture-seeding files and actual consumer channels; historical Git source identities remain governed by retained epoch manifests. No full native/cache/control-program input closure claim.'}
    destination.write_bytes(gzip.compress(json.dumps(packet, sort_keys=True).encode(), mtime=0))
    print(json.dumps({'epoch': epoch, 'returncode': result.returncode}, sort_keys=True))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('epoch', choices=('before', 'after'))
    capture(parser.parse_args().epoch)
