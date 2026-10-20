"""Preserve the whole live837 draft and exact failed canonical candidate before scanner edits."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P, F = 'docs/checkpoints/type-values-selector/', c.PREFIX
claim = c.read(c.CLAIM)
record = json.loads(c.decode(claim['base64']))
bindings = record['claims'][0]['durability']['inputs']
assert len(bindings) == 837 and len(c.decode(claim['base64'])) == 130737
receipt = json.loads((ROOT / (F + 'publication-required-final.json')).read_bytes())
assert receipt['record_base64'] == claim['base64'] and receipt['result'] == 'PASS'
inputs = {item['path']: {key: c.read(item['path'])[key] for key in ('sha256', 'mode')} for item in bindings}
assert all(inputs[item['path']]['sha256'] == item['sha256'] for item in bindings)
paths = ('tools/check_executable_aggregate_selector_sources.py',
         'docs/knowledge/aggregate-selector-self-test-concurrency-boundary.md',
         'docs/linkedspec-book/src/development/documentation-workflow.md',
         'KNOWLEDGE_MAP.md', F + 'publish.py', F + 'README.md')
before = {path: c.read(path) for path in paths}
patch = c.run(['git', 'diff', '--cached', '--binary', '--full-index', '--no-ext-diff', 'HEAD'])
assert patch['returncode'] == 0
status = c.read('.linkedspec-data/verification/type-values-canonical4.status')
assert c.decode(status['base64']).strip() == b'1'
c.write_new(P + 'preservation.json.gz', dict(original_claim=claim, inputs=inputs, before=before,
    producer=c.read(P + 'preserve.py'), receipt=c.read(F + 'publication-required-final.json'),
    failed_candidate=dict(base_commit=c.BASE, staged_binary_diff=patch),
    canonical=dict(status=status, output=c.read('.linkedspec-data/verification/type-values-canonical4.log')),
    scope='The whole837/full130737 uncommitted draft and each original input hash/mode '
          'remain recoverable. Immutable inputs stay at their exact tracked paths; full '
          'changed-before bytes and exact failed staged delta are retained. No fake '
          'historical Git identity. All original/readable actors stay unchanged.'),
    packed=True)
print('Whole837 draft, input identities/modes and exact failed canonical4 candidate preserved')
