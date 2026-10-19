"""Prepare then apply unbound continuity for the repaired metadata publication."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/knowledge-fields'))
import common as c

HOME = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12-portability/'
PATHS = ['docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md', 'MEMORY.md', 'docs/TASK_TREE.md',
         'ROADMAP.md', 'ROADMAP_V2.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md']
assert sys.argv[1:] in (['--prepare'], ['--apply'])
if sys.argv[1:] == ['--prepare']:
    c.write_new(HOME + 'continuity-before.json.gz', dict(inputs={path: c.read(path) for path in PATHS},
        producer_sha256=c.sha(Path(__file__).read_bytes())), packed=True)
    print('Whole pre-repair continuity preserved; no root writes')
    raise SystemExit(0)
before = json.loads(gzip.decompress((ROOT / (HOME + 'continuity-before.json.gz')).read_bytes()))
assert before['producer_sha256'] == c.sha(Path(__file__).read_bytes())
assert c.unchanged(before['inputs'])
raw = (ROOT / c.CLAIM).read_bytes()
claim = json.loads(raw)
count = len(claim['claims'][0]['durability']['inputs'])
assert not set(PATHS) & {row['path'] for row in claim['claims'][0]['durability']['inputs']}
original = json.loads(gzip.decompress((ROOT / (HOME + 'original.json.gz')).read_bytes()))
values = {path: c.decode(item['base64']).decode() for path, item in before['inputs'].items()}
old_summary = values['LIVE_ACHIEVEMENT_STATUS.md'].split('## Latest Completed Slice\n\n', 1)[1].split('\n\n## Next Action', 1)[0]
summary = old_summary.replace('binds196 inputs/full35922', f'binds{count} inputs/full{len(raw)}')
needle = 'Exact staged canonical receipt and all normal hooks govern landing.'
assert summary.count(needle) == 1
summary = summary.replace(needle,
    'Whole original196/full35922 and the failed108-file candidate remain recoverable; actual '
    'original-reader baseline/replay pass. Standard JSON solidus transport preserves decoded '
    'render arguments and exact inverse bytes; three isolated transport/draft REDs restore. '
    'The original extra-file review failure is retained; its distinct correction retains actual '
    'tool temporary outputs and guards all supplied sources. ' + needle)
for path in PATHS:
    values[path] = values[path].replace(old_summary, summary)
    values[path] = values[path].replace('current196/full35922', f'current{count}/full{len(raw)}')
    values[path] = values[path].replace('readonly196/35922', f'readonly{count}/{len(raw)}')
tree = PATHS[0]
values[tree] = values[tree].replace('- Status: `active` / metadata .12 canonical transport repair',
    '- Status: `active` / bounded frontier complete; original independent admissions open', 1)
values[tree] = values[tree].replace('Status: `active` / P1 render-record JSON transport repair',
    'Status: `done` / canonical boundary; exact staged receipt required for landing', 1)
start = values[tree].index('## Current Frontier\n')
end = values[tree].index('\n## Handoff', start)
staged_tree = c.decode(original['staged_supplement'][tree]['base64']).decode()
old_start = staged_tree.index('## Current Frontier\n')
old_end = staged_tree.index('\n## Handoff', old_start)
values[tree] = values[tree][:start] + staged_tree[old_start:old_end] + values[tree][end:]
marker = '\n## Current Frontier\n'
values[tree] = values[tree].replace(marker,
    '\n  Canonical transport closure: Original196/full35922 and whole failed108 staged candidate '
    'are preserved before the two bound source/data writes. Actual baseline and exact original-reader '
    'replay PASS; all196 and whole claim bytes/modes stay unchanged. Three supplied transport/draft '
    'denials restore. Original review/cache assertion failure and unavailable first cache bytes are '
    'disclosed; distinct reader retains actual temporary outputs and rejects source outputs. '
    f'Current readonly{count}/full{len(raw)} binds every sibling producer/input. First canonical '
    'exits1 with nine PASS/path RED; fresh exact repaired canonical receipt and all normal hooks '
    'remain required for landing. No recorded native arguments, gate, budget or retired producer changes.\n'
    + marker, 1)
# Recover the already-reviewed intended post-landing pointer, rather than the in-flight reopen.
values['MEMORY.md'] = c.decode(original['staged_supplement']['MEMORY.md']['base64']).decode()
values['MEMORY.md'] = values['MEMORY.md'].replace('current196/full35922', f'current{count}/full{len(raw)}')
values['MEMORY.md'] = values['MEMORY.md'].replace('- custody: ', '- transport: Original196/full35922 and failed108 staged candidate preserved; original-reader replay, decoded equality/inverse and three transport/draft denials PASS. Distinct reader retains tool temporary outputs.\n- custody: ', 1)
for path, value in values.items():
    (ROOT / path).write_text(value)
c.write_new(HOME + 'continuity.json', dict(result='PASS', claim_sha256=c.sha(raw), input_count=count,
    claim_bytes=len(raw), producer_sha256=c.sha(Path(__file__).read_bytes()),
    before_sha256=c.sha((ROOT / (HOME + 'continuity-before.json.gz')).read_bytes()),
    outputs={path: c.sha(value.encode()) for path, value in values.items()},
    scope='Root continuity remains deliberately unbound; original before bytes are bound. '
          'Staged docs describe COMMIT.md intended clean post-landing handoff. Canonical receipt required.'))
print('Repaired metadata continuity finalized:', count, 'inputs;', len(raw), 'bytes;TYPE-REFERENCE-BOOK.1 next')
