"""Retain the completed selected Phase0 command channels without first-use credit."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OUTPUT = HERE / 'phase0-selected-channels.json'
assert not OUTPUT.exists()
rows = {}
for stage, exit_code in (('before', 7), ('after', 0)):
    argv = ['bash', 'tools/project_data_run.sh', 'perl', '-Iperl',
            str((HERE / 'phase0_selected.pl').relative_to(ROOT)),
            str((HERE / 'phase0-selected-names.json').relative_to(ROOT)),
            '.linkedspec-data/phase0-selected-' + stage + '-seen.json']
    channels = {}
    for channel in ('stdout.log', 'stderr.log', 'seen.json'):
        name = 'phase0-selected-' + stage + '-' + channel if channel == 'seen.json' else 'phase0-selected-' + stage + '.' + channel
        source = ROOT / '.linkedspec-data' / name
        raw = source.read_bytes()
        destination = HERE / (name + '.gz')
        assert not destination.exists()
        destination.write_bytes(gzip.compress(raw, mtime=0))
        assert gzip.decompress(destination.read_bytes()) == raw
        channels[channel] = dict(path=destination.relative_to(ROOT).as_posix(),
                                 decoded_sha256=hashlib.sha256(raw).hexdigest())
    rows[stage] = dict(argv=argv, cwd='.', exit=exit_code, channels=channels)
OUTPUT.write_text(json.dumps(dict(commands=rows,
    limits='Completed command channels retained after exit; no original first-use or full native/cache custody credit.'), indent=2) + '\n')
raw = (ROOT / '.linkedspec-data/phase0-review.stdout.log').read_bytes()
assert json.loads(raw)['result'] == 'PASS'
assert (ROOT / '.linkedspec-data/phase0-review.stderr.log').read_bytes() == b''
(HERE / 'phase0-review-result.json').write_bytes(raw)
print(json.dumps(dict(result='retained', commands={stage: row['exit'] for stage, row in rows.items()}), sort_keys=True))
