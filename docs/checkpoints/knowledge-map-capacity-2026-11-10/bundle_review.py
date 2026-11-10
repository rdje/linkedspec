"""Replay the exact qualified source epoch from a hash-bound input bundle."""
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent


def verify(images, manifest):
    expected = {row['path']: row['sha256'] for row in manifest['inputs']}
    assert set(images) == set(expected), 'input population'
    result = {}
    for name, image in images.items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts
        raw = base64.b64decode(image['base64'], validate=True)
        assert hashlib.sha256(raw).hexdigest() == image['sha256'] == expected[name], 'input byte identity'
        result[name] = raw
    return result


def review():
    manifest = json.loads((HERE / 'current-generation.json').read_text())
    images = json.loads(gzip.decompress((HERE / 'input-epoch.json.gz').read_bytes()))
    sources = verify(images, manifest)
    rejected = []
    for name in ('missing-input', 'altered-producer'):
        changed = dict(images)
        if name == 'missing-input':
            changed.pop(next(iter(changed)))
        else:
            producer = 'knowledge-map/scripts/gen_knowledge_map.sh'
            changed[producer] = dict(changed[producer], base64=base64.b64encode(b'corrupted producer\n').decode())
        try:
            verify(changed, manifest)
        except AssertionError:
            rejected.append(name)
        else:
            raise AssertionError('ineffective source control: ' + name)
    with tempfile.TemporaryDirectory(prefix='knowledge-epoch-', dir=os.environ['LINKEDSPEC_RUN_DIR']) as name:
        fixture = Path(name)
        for source, raw in sources.items():
            target = fixture / source
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
        bin_dir = fixture / 'bin'
        bin_dir.mkdir()
        (bin_dir / 'git').write_text('''#!/bin/sh
[ "$#" -eq 4 ] && [ "$1" = -C ] && [ "$3" = rev-parse ] && [ "$4" = --show-toplevel ] || exit 97
printf '%s\\n' "$LINKEDSPEC_KNOWLEDGE_EPOCH_ROOT"
''')
        (bin_dir / 'git').chmod(0o755)
        (fixture / 'fixture-initializer.sh').write_text('# Rendering-only fixture; production initialization was acquired separately.\n')
        env = dict(os.environ, PATH=str(bin_dir) + os.pathsep + os.environ['PATH'],
                   LINKEDSPEC_KNOWLEDGE_EPOCH_ROOT=str(fixture),
                   KM_SCAN_DIRS='docs/knowledge docs/decisions', KM_OUTPUT='replay.md',
                   KM_ENV_INITIALIZER='fixture-initializer.sh', KM_RUN_INITIALIZER=':', KM_OUTPUT_VALIDATOR=':')
        result = subprocess.run(['bash', 'knowledge-map/scripts/gen_knowledge_map.sh'],
                                cwd=fixture, env=env, capture_output=True)
        assert result.returncode == 0 and result.stdout == b'', result.stderr
        raw = (fixture / 'replay.md').read_bytes()
        assert hashlib.sha256(raw).hexdigest() == manifest['map_sha256']
        assert raw == (ROOT / 'KNOWLEDGE_MAP.md').read_bytes()
    return {'result': 'PASS', 'all_source_bodies': 'exact qualified epoch',
            'map_sha256': manifest['map_sha256'], 'rejected_controls': rejected,
            'limits': 'Frozen rendering replay; production initialization/publication/locality were acquired separately. No later live-source freshness or full native custody credit.'}


if __name__ == '__main__':
    print(json.dumps(review(), sort_keys=True))
