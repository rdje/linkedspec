"""Replay retained source with its original filename and source-bound tracebacks."""
from pathlib import Path
import argparse
import linecache

ROOT = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('source', help='Repository-relative retained source')
parser.add_argument('logical', help='Repository-relative original logical filename')
args = parser.parse_args()
for value in (args.source, args.logical):
    assert not Path(value).is_absolute() and '..' not in Path(value).parts
    (ROOT / value).resolve().relative_to(ROOT)
source = (ROOT / args.source).read_bytes()
filename = str((ROOT / args.logical).resolve())
# A compile filename supplies coordinates, not the source used by traceback
# formatting. A virtual cache entry binds displayed lines to these exact bytes;
# mtime=None prevents checkcache from replacing them with a newer disk file.
linecache.cache[filename] = (len(source), None, source.decode('utf-8').splitlines(True), filename)
exec(compile(source, filename, 'exec'), {'__file__': filename, '__name__': '__main__'})
