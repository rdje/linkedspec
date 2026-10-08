"""Execute the exact initial reviewer with its original filename and line cache."""
from pathlib import Path
import hashlib
import json
import linecache

PREFIX = __file__.removesuffix('initial-review-replay.py')
source = Path(PREFIX + 'initial-review.py').read_bytes()
metadata = json.loads(Path(PREFIX + 'initial-review-error.json').read_bytes())
assert hashlib.sha256(source).hexdigest() == metadata['source_sha256']
original = str(Path(PREFIX + 'review.py').resolve())
linecache.cache[original] = (len(source), None, source.decode().splitlines(keepends=True), original)
exec(compile(source, original, 'exec'), {'__file__': original, '__name__': '__main__'})
