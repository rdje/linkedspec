"""Capture actual public-generation epochs, or review them without writing."""
import argparse
import base64
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
GENERATOR = 'knowledge-map/scripts/gen_knowledge_map.sh'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def capture(epoch):
    destination = HERE / (epoch + '-generation.json')
    assert not destination.exists(), 'epoch capture is one-shot'
    with tempfile.TemporaryDirectory(prefix='knowledge-capacity-', dir=os.environ['LINKEDSPEC_RUN_DIR']) as name:
        output = Path(name) / 'map.md'
        relative = output.relative_to(ROOT).as_posix()
        env = dict(os.environ, KM_OUTPUT=relative)
        producer = (ROOT / GENERATOR).read_bytes()
        result = subprocess.run(['bash', GENERATOR], cwd=ROOT, env=env, capture_output=True)
        assert result.returncode == 0, result.stderr
        assert result.stdout == b''
        assert result.stderr == ('knowledge-map: wrote ' + relative + ' (1710 facts, 12237 question keys)\n').encode()
        raw = output.read_bytes()
        assert producer == (ROOT / GENERATOR).read_bytes(), 'producer changed during capture'
    packet = {'epoch': epoch, 'generator_sha256': sha(producer),
              'generator_base64': base64.b64encode(producer).decode(),
              'command': ['bash', GENERATOR], 'KM_OUTPUT': relative,
              'returncode': result.returncode,
              'stdout_base64': base64.b64encode(result.stdout).decode(),
              'stderr_base64': base64.b64encode(result.stderr).decode(),
              'map_sha256': sha(raw), 'map_lines': len(raw.splitlines()), 'map_bytes': len(raw)}
    destination.write_text(json.dumps(packet, sort_keys=True, indent=2) + '\n')
    return packet


def review():
    baseline = json.loads(gzip.decompress((HERE / 'baseline.json.gz').read_bytes()))
    original = base64.b64decode(baseline['inputs']['KNOWLEDGE_MAP.md']['base64'])
    assert sha(original) == baseline['inputs']['KNOWLEDGE_MAP.md']['sha256']
    spec = importlib.util.spec_from_file_location('capacity_plan', HERE / 'review.py')
    plan = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(plan)
    before = json.loads((HERE / 'before-generation.json').read_text())
    after = json.loads((HERE / 'after-generation.json').read_text())
    current = (ROOT / 'KNOWLEDGE_MAP.md').read_bytes()
    plan.preserved(original.decode(), current.decode())
    for row, raw in ((before, original), (after, current)):
        assert row['map_sha256'] == sha(raw)
        assert row['map_lines'] == len(raw.splitlines()) and row['map_bytes'] == len(raw)
        assert row['returncode'] == 0 and row['stdout_base64'] == ''
        assert sha(base64.b64decode(row['generator_base64'])) == row['generator_sha256']
    assert before['generator_sha256'] == baseline['inputs'][GENERATOR]['sha256']
    assert after['generator_sha256'] == sha((ROOT / GENERATOR).read_bytes())
    expected = original.decode().splitlines(keepends=True)
    actual = current.decode().splitlines(keepends=True)
    assert len(expected) - len(actual) == plan.review()['facts']
    denied = []
    # The retained plan's actual original-line walk is independent of the AWK emitter.
    for label, text in (
        ('question', current.decode().replace('- "', '- "CORRUPTED ', 1)),
        ('source', current.decode().replace('**source:** ', '**source:** CORRUPTED ', 1)),
        ('anchor', current.decode().replace('### ', '### CORRUPTED ', 1)),
        ('restored-duplicate', original.decode()),
    ):
        try:
            plan.preserved(original.decode(), text)
        except ValueError:
            denied.append(label)
        else:
            raise AssertionError('ineffective control: ' + label)
    return {'result': 'PASS', 'before_lines': before['map_lines'], 'after_lines': after['map_lines'],
            'before_bytes': before['map_bytes'], 'after_bytes': after['map_bytes'],
            'removed_lines': len(expected) - len(actual), 'rejected_controls': denied,
            'map_sha256': sha(current), 'question_and_remaining_records': 'byte-identical'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', choices=('before', 'after'))
    args = parser.parse_args()
    print(json.dumps(capture(args.capture) if args.capture else review(), sort_keys=True))
