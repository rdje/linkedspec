"""Retain the failed pre-write attempt and use the actual collection schema."""
import ast
import json
from pathlib import Path
import common as c

path = c.HOME + 'prepare-docs.py'
before = c.read(path)
failure = c.read('.linkedspec-data/verification/knowledge-fields-docs-attempt1.log')
assert b"KeyError: 'max_bytes'" in c.decode(failure['base64'])
assert not (c.ROOT / (c.HOME + 'docs-preparation.json.gz')).exists()
assert not (c.ROOT / (c.HOME + 'current-inputs.json.gz')).exists()
registry = c.read('doctrine/readme_stability/routes.jsonl')
row = next(json.loads(line) for line in c.decode(registry['base64']).decode().splitlines() if json.loads(line).get('id') == 'knowledge_cards')
assert row['member_limits'] == {} and row['limits']['max_total_bytes'] == 8388608
assert row['limits']['max_bytes_per_file'] == 65536 and row['limits']['max_lines_per_file'] == 512
source = c.decode(before['base64'])
edits = [
    (b"control['limits']['max_bytes']", b"control['limits']['max_total_bytes']"),
    (b"control['member_limits']['max_bytes']", b"control['limits']['max_bytes_per_file']"),
    (b"control['member_limits']['max_lines']", b"control['limits']['max_lines_per_file']"),
    (b"c.HOME + 'prepare-docs.py'", b"c.HOME + 'prepare-docs-final.py'"),
]
after = source
for old, new in edits:
    assert after.count(old) == 1
    after = after.replace(old, new, 1)
ast.parse(after, filename=c.HOME + 'prepare-docs-final.py')
record = dict(result='PASS', original_producer=before, complete_outer_failure=failure, actual_registry=registry,
              exact_edits=[dict(before=old.decode(), after=new.decode()) for old, new in edits],
              after_sha256=c.sha(after), after_base64=c.encode(after), producer_base64=c.encode(Path(__file__).read_bytes()),
              scope='The first writer stops at budget lookup before its proposal file or any '
                    'documentation write. Collection limits use max_total_bytes and per-file '
                    'keys in limits, while generated-projection surfaces use a different schema. '
                    'The distinct final actor reads the actual existing keys; no registry value '
                    'or policy changes. Original source, failure and all epoch observations stay exact.')
c.write_new(c.HOME + 'docs-budget-repair.json', record)
with (c.ROOT / (c.HOME + 'prepare-docs-final.py')).open('xb') as output:
    output.write(after)
print('Exact collection-budget schema correction prepared;first source/failure retained')
