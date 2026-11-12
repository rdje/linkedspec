"""Independently recover the bounded current-pointer correction and binding query."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
OUT = BASE / 'selection-frontier'
packet = json.loads(gzip.decompress((OUT / 'inputs.json.gz').read_bytes()))
report = json.loads((OUT / 'binding-result.json').read_bytes())
assert packet['source_commit'] == report['source_commit']
names = [name for name in subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', packet['source_commit'], 'docs/claims'], text=True).splitlines() if name.endswith('.json')]
assert set(names) == packet['records'].keys()
for name in names:
    assert packet['records'][name].encode() == subprocess.check_output(['git', 'show', packet['source_commit'] + ':' + name])
assert packet['before'].encode() == subprocess.check_output(['git', 'show', packet['source_commit'] + ':' + packet['card']])
def query(records):
    hits = [dict(record=name, claim=claim['name'], mode=claim['durability']['mode'])
        for name, body in records.items() for claim in json.loads(body)['claims']
        if claim['durability']['status'] == 'checked'
        for item in claim['durability']['inputs'] if item['path'] == packet['card']]
    assert all(row['mode'] != 'live' for row in hits), 'live selection-card binding'
    return hits
assert query(packet['records']) == report['intersections'] == []
changed = copy.deepcopy(packet['records'])
name = names[0]
record = json.loads(changed[name])
record['claims'][0]['durability'] = dict(status='checked', mode='live', inputs=[dict(path=packet['card'], sha256='0'*64)])
changed[name] = json.dumps(record)
try:
    query(changed)
except AssertionError as failure:
    assert str(failure) == 'live selection-card binding'
else:
    raise AssertionError('live binding accepted')
before = gzip.decompress((OUT / 'before.md.gz').read_bytes()).decode()
after = gzip.decompress((OUT / 'after.md.gz').read_bytes()).decode()
assert before == packet['before']
old_status = 'status: focused selection42 frozen; Perl80.1 focused-complete, independent peers pending'
new_status = 'status: focused selection42 frozen; all five bounded80 backend outcomes recorded; full admission separate'
old_next = 'Independent Rust80.2 is next; the selection evidence above is historical.'
start = after.index('Rust80.2, Dart80.3, Julia80.4 and installed Lua80.5 now have independent focused')
end = after.index('selection evidence above is historical.', start) + len('selection evidence above is historical.')
assert after.replace(new_status, old_status, 1).replace(after[start:end], old_next, 1) == before
assert Path(packet['card']).read_text() == after
print(json.dumps(dict(selection_frontier_recovery='PASS', accepted_records=len(names), checked_intersections=0, rejected_live_controls=1, exact_two_pointer_replacements=True, after_sha256=hashlib.sha256(after.encode()).hexdigest(), scope='No SDK replay or original observation/claim refresh.')))
