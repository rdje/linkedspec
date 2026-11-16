"""Preserve the exact rejected raw log while removing its plaintext path leak."""
import gzip
import hashlib
import json
from pathlib import Path
import stat
import subprocess

BASE = Path(__file__).resolve().parent
raw = BASE / 'book-build.log'
assert raw.is_file() and not raw.is_symlink()
body = raw.read_bytes()
compressed = BASE / 'book-build.log.gz'
assert not compressed.exists(), 'one-shot repair'
compressed.write_bytes(gzip.compress(body, mtime=0))
assert gzip.decompress(compressed.read_bytes()) == body
mode = stat.S_IMODE(raw.stat().st_mode)
diff = subprocess.run(['git', 'diff', '--cached', '--binary', '--full-index'], capture_output=True)
assert diff.returncode == 0 and diff.stderr == b''
(BASE / 'first-staged-diff.patch.gz').write_bytes(gzip.compress(diff.stdout, mtime=0))
log = Path('.linkedspec-data/dart-loader-commit.log').read_bytes()
assert b'book-build.log:5: current checkout identity:' in log
(BASE / 'first-normal.log.gz').write_bytes(gzip.compress(log, mtime=0))
(BASE / 'log-preservation.json').write_text(json.dumps(dict(
    source='book-build.log', retained='book-build.log.gz',
    sha256=hashlib.sha256(body).hexdigest(), mode=mode,
    representation='Exact original output bytes, compressed; no rewritten log or repeated build.',
    first_commit_exit=143, first_hook='Interrupted after observed path failure; no all-doctrine pass credit.',
    staged_diff_sha256=hashlib.sha256(diff.stdout).hexdigest(),
    partial_hook_sha256=hashlib.sha256(log).hexdigest()), indent=2) + '\n')
raw.unlink()
print('Exact raw mdBook log, rejected index diff and partial first hook preserved; plaintext log removed.')
