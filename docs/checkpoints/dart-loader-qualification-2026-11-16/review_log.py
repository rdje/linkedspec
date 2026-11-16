"""Recover the original book log independently from the rejected staged diff."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
metadata = json.loads((BASE / 'log-preservation.json').read_bytes())
patch = gzip.decompress((BASE / 'first-staged-diff.patch.gz').read_bytes())
hook = gzip.decompress((BASE / 'first-normal.log.gz').read_bytes())
body = gzip.decompress((BASE / 'book-build.log.gz').read_bytes())
name = str(BASE.relative_to(Path.cwd())) + '/book-build.log'
block = next(block for block in patch.split(b'diff --git ') if block.startswith(('a/' + name + ' b/' + name + '\n').encode()))
original = b''.join(line[1:] for line in block.splitlines(keepends=True)
                    if line.startswith(b'+') and not line.startswith(b'+++'))
mode = int(re.search(rb'^new file mode 100([0-7]{3})$', block, re.M)[1], 8)


def verify(value, record):
    assert value == original, 'raw output differs from rejected index'
    assert record['mode'] == mode, 'raw mode differs from rejected index'
    assert hashlib.sha256(value).hexdigest() == record['sha256'], 'raw digest'
    assert hashlib.sha256(patch).hexdigest() == record['staged_diff_sha256'], 'staged diff digest'
    assert hashlib.sha256(hook).hexdigest() == record['partial_hook_sha256'], 'partial hook digest'
    assert ('book-build.log:5: current checkout identity:' in hook.decode()), 'original failure'
    assert record['first_commit_exit'] == 143, 'interrupted first attempt'


verify(body, metadata)
controls = []
for label, field in [('mode', 'mode'), ('digest', 'sha256'), ('index-digest', 'staged_diff_sha256')]:
    changed = copy.deepcopy(metadata)
    changed[field] = 0 if field == 'mode' else '0' * 64
    try:
        verify(body, changed)
    except AssertionError:
        controls.append(label)
    else:
        raise AssertionError('ineffective log control')
try:
    verify(body + b'altered', metadata)
except AssertionError:
    controls.append('body')
else:
    raise AssertionError('ineffective body control')
print(json.dumps(dict(result='PASS', original_body_and_mode_preserved=True,
    controls=controls, first_hook_credit='partial failure only; complete retry required'), sort_keys=True))
