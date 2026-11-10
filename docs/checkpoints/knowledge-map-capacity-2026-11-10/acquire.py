"""Bind the current public generation to its complete source-file population."""
import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OUTPUT = HERE / 'current-generation.json'
FIXED = (
    '.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
    'knowledge-map/scripts/gen_knowledge_map.sh',
    'tools/project_data_env.sh', 'tools/project_data_run.sh',
    'tools/run_python_project_data.sh',
)


def identities():
    paths = [ROOT / name for name in FIXED]
    for directory in ('docs/knowledge', 'docs/decisions'):
        paths.extend((ROOT / directory).rglob('*.md'))
    result = []
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_symlink()
        raw = path.read_bytes()
        result.append({'path': path.relative_to(ROOT).as_posix(),
                       'sha256': hashlib.sha256(raw).hexdigest()})
    return result


def capture():
    assert not OUTPUT.exists(), 'one-shot acquisition already exists'
    before = identities()
    with tempfile.TemporaryDirectory(prefix='knowledge-inputs-', dir=os.environ['LINKEDSPEC_RUN_DIR']) as name:
        path = Path(name) / 'map.md'
        relative = path.relative_to(ROOT).as_posix()
        command = ['bash', 'knowledge-map/scripts/gen_knowledge_map.sh']
        result = subprocess.run(command, cwd=ROOT,
                                env=dict(os.environ, KM_SCAN_DIRS='docs/knowledge docs/decisions', KM_OUTPUT=relative),
                                capture_output=True)
        assert result.returncode == 0 and result.stdout == b'', result.stderr
        raw = path.read_bytes()
        assert raw == (ROOT / 'KNOWLEDGE_MAP.md').read_bytes()
    assert identities() == before, 'source membership or bytes changed during generation'
    packet = {'inputs': before, 'command': command,
              'environment': {'KM_SCAN_DIRS': 'docs/knowledge docs/decisions', 'KM_OUTPUT': relative},
              'returncode': result.returncode,
              'stdout_base64': base64.b64encode(result.stdout).decode(),
              'stderr_base64': base64.b64encode(result.stderr).decode(),
              'map_sha256': hashlib.sha256(raw).hexdigest()}
    OUTPUT.write_text(json.dumps(packet, sort_keys=True, indent=2) + '\n')


def review():
    packet = json.loads(OUTPUT.read_text())
    assert packet['inputs'] == identities()
    assert packet['map_sha256'] == hashlib.sha256((ROOT / 'KNOWLEDGE_MAP.md').read_bytes()).hexdigest()
    assert packet['returncode'] == 0 and packet['stdout_base64'] == ''
    expected = ('knowledge-map: wrote ' + packet['environment']['KM_OUTPUT'] + ' (1710 facts, 12237 question keys)\n').encode()
    assert base64.b64decode(packet['stderr_base64'], validate=True) == expected
    return {'result': 'PASS', 'source_population_and_bytes': 'unchanged across actual generation',
            'map_sha256': packet['map_sha256']}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', action='store_true')
    args = parser.parse_args()
    if args.capture:
        capture()
    print(json.dumps(review(), sort_keys=True))
