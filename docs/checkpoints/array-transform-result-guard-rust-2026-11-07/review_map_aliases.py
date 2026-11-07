"""Readonly alias containment: old questions, fact bytes and existing limits stay."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path(__file__).resolve().parent / 'map-capacity'


def questions(body):
    return set(re.findall(r'^- "(.*)" -> ', body.decode(), re.M))


def without_answers(body):
    return re.sub(rb'(?ms)^answers:\n.*?(?=^[A-Za-z_][A-Za-z_0-9]*:|^---$)', b'answers:\n', body, count=1)


def validate(golden, current, before_facts, after_facts, limits):
    assert questions(golden) <= questions(current), 'published lookup lost'
    for name, before in before_facts.items():
        assert without_answers(before) == without_answers(after_facts[name]), 'fact content changed'
    assert current.count(b'\n') <= limits['max_lines'], 'map line limit'
    assert len(current) <= limits['max_bytes'], 'map byte limit'


rows = json.loads((BASE / 'input-identities.json').read_bytes())
before = {}
with tarfile.open(BASE / 'inputs-before-alias-change.tar.gz') as archive:
    for member in archive:
        assert member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
        assert member.name not in before
        body = archive.extractfile(member).read()
        row = rows[member.name]
        assert hashlib.sha256(body).hexdigest() == row['sha256']
        assert len(body) == row['bytes'] and member.mode & 0o777 == row['mode']
        before[member.name] = body
assert before.keys() == rows.keys()
changes = json.loads((BASE / 'alias-changes.json').read_bytes())
for name, (first, second, combined) in changes.items():
    assert before[name].decode().replace(first, combined, 1).replace(second, '', 1) == (ROOT / name).read_text()
for name in ('knowledge-map/scripts/gen_knowledge_map.sh', 'doctrine/readme_stability/routes.jsonl'):
    assert (ROOT / name).read_bytes() == before[name], 'generator/control changed'
limits = next(json.loads(line)['limits'] for line in before['doctrine/readme_stability/routes.jsonl'].decode().splitlines()
              if json.loads(line).get('id') == 'knowledge_map')
assert limits == dict(max_bytes=8388608, max_lines=22500)
old = gzip.decompress((BASE / 'activation-knowledge-map.md.gz').read_bytes())
current = (ROOT / 'KNOWLEDGE_MAP.md').read_bytes()
before_facts = {name: before[name] for name in changes}
after_facts = {name: (ROOT / name).read_bytes() for name in changes}
validate(old, current, before_facts, after_facts, limits)
assert before['KNOWLEDGE_MAP.md'].count(b'\n') == 22501
assert current.count(b'\n') == 22499
controls = 0
old_key = sorted(questions(old))[0]
line = next(line for line in current.splitlines(keepends=True) if line.startswith(('- "' + old_key + '" -> ').encode()))
for bad_map, bad_facts, reason in (
    (current.replace(line, b'', 1), after_facts, 'published lookup lost'),
    (current, {**after_facts, next(iter(after_facts)): after_facts[next(iter(after_facts))] + b'changed'}, 'fact content changed'),
    (current + b'\n\n', after_facts, 'map line limit'),
):
    try:
        validate(old, bad_map, before_facts, bad_facts, limits)
    except AssertionError as error:
        assert str(error) == reason
        controls += 1
    else:
        raise AssertionError('ineffective alias containment corruption')
print(f'Knowledge Map22501 to22499 under unchanged22500 limit; {len(questions(old))} published questions retained, all fact bytes outside aliases exact; {controls} corruptions rejected')
