"""Preserve the exact rejected staged candidate before its tier-spelling correction."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-scoped-with'))
import common as c

prefix = 'docs/checkpoints/type-scoped-with-admission/'
claim = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.4.json'
status = c.read('.linkedspec-data/verification/type-scoped-with-canonical1.status')
assert c.decode(status['base64']).strip() == b'1'
patch = c.run(['git', 'diff', '--cached', '--binary', '--full-index', '--no-ext-diff', 'HEAD'])
assert patch['returncode'] == 0
owner = c.run(['perl', 'tools/check_task_verification_fields.pl', '--owner'])
assert owner['returncode'] != 0
assert b'invalid Verification tier' in c.decode(owner['stderr_base64'])
manifest = c.read(c.PREFIX + 'publication-inputs.json')
assert c.unchanged(json.loads(c.decode(manifest['base64']))['inputs'])
record = dict(base=c.BASE, claim=c.read(claim), input_manifest=manifest,
    publication=c.read(c.PREFIX + 'publication.json'), staged_binary_diff=patch,
    task_before=c.read('docs/tasks/TYPE-REFERENCE-BOOK.md'),
    producer=c.read(prefix + 'preserve.py'), primitives=c.read(c.PREFIX + 'common.py'),
    owner_probe=owner, canonical_status=status,
    canonical_log=c.read('.linkedspec-data/verification/type-scoped-with-canonical1.log'),
    scope='Exact uncommitted candidate and complete current claim/input closure precede correction. '
          'The existing Git base plus full staged patch recover every candidate byte; the manifest '
          'retains full modes. Actual canonical failure is a tier-declaration error, not runtime RED. '
          'No historical revision is invented for this draft; current runtime inputs do not change.')
raw = gzip.compress((json.dumps(record, sort_keys=True, separators=(',', ':')) + '\n').encode(), mtime=0)
with (ROOT / prefix / 'canonical1.json.gz').open('xb') as output:
    output.write(raw)
print('Rejected canonical1 candidate, whole current claim, modes and owner failure preserved')
