"""Check only the changed generator from a read-only outside working directory."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
with tempfile.TemporaryDirectory(prefix='knowledge-routing-', dir=os.environ['LINKEDSPEC_RUN_DIR']) as name:
    output = Path(name) / 'map.md'
    relative = output.relative_to(ROOT).as_posix()
    result = subprocess.run(
        ['bash', str(ROOT / 'knowledge-map/scripts/gen_knowledge_map.sh')],
        cwd='/', env=dict(os.environ, KM_OUTPUT=relative), capture_output=True)
    assert result.returncode == 0 and result.stdout == b'', result.stderr
    assert output.stat().st_dev == ROOT.stat().st_dev
    raw = output.read_bytes()
    assert raw == (ROOT / 'KNOWLEDGE_MAP.md').read_bytes()
    expected = ('knowledge-map: wrote ' + relative + ' (1710 facts, 12237 question keys)\n').encode()
    assert result.stderr == expected
    print(json.dumps({'result': 'PASS', 'outside_cwd': 'OS root, read-only',
                      'output_device': 'repository', 'map_sha256': hashlib.sha256(raw).hexdigest()}, sort_keys=True))
