"""Retain the actual initial missing-artifact rejection before correcting its reader."""
from pathlib import Path
import gzip
import hashlib
import json
import shutil

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('retain-review.py')


def main():
    target = Path(PREFIX + 'initial-review.py'); assert not target.exists()
    shutil.copyfile(PREFIX + 'review.py', target)
    raw = (ROOT / '.linkedspec-data/logs/committed-membership-acceptance-review.log').read_bytes()
    assert b'grouped-cause.json' in raw and b'CalledProcessError' in raw
    archive = gzip.compress(raw, mtime=0)
    Path(PREFIX + 'initial-review-error.log.gz').write_bytes(archive)
    report = {'actual_exit': 1, 'channel_scope': 'Exact merged stdout/stderr of initial executed review command; no reviewer output preceded this failure.',
        'command': ['bash', 'tools/run_python_project_data.sh', target.relative_to(ROOT).as_posix().replace('initial-review.py', 'review.py')],
        'source_sha256': hashlib.sha256(target.read_bytes()).hexdigest(),
        'error_bytes': len(raw), 'error_sha256': hashlib.sha256(raw).hexdigest(),
        'archive_sha256': hashlib.sha256(archive).hexdigest(),
        'instrument_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
    Path(PREFIX + 'initial-review-error.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Retained exact initial reviewer and actual missing-artifact rejection')


if __name__ == '__main__':
    main()
