"""Independently decode every list item and freshly re-derive the supplied graph."""
import gzip
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
import common as c

assert sys.argv[1:] in ([], ['--capture'])
population = json.loads((c.ROOT / (c.HOME + 'population.json')).read_bytes())
before = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'before.json.gz')).read_bytes()))
after = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'after.json.gz')).read_bytes()))
packed = (c.ROOT / (c.HOME + 'after-inputs.json.gz')).read_bytes()
assert c.sha(packed) == after['capsule_sha256']
capsule = json.loads(gzip.decompress(packed))
inputs = capsule['inputs']
assert set(inputs) == set(after['inputs'])
for path, item in inputs.items():
    assert c.sha(c.decode(item['base64'])) == item['sha256'] == after['inputs'][path]['sha256']
    assert item['mode'] == after['inputs'][path]['mode']
assert after['producer_sha256'] == c.sha((c.ROOT / (c.HOME + 'capture-after.py')).read_bytes())
for path in ('knowledge-map/scripts/gen_knowledge_map.sh', 't/knowledge_map_header_lists.t'):
    assert c.read(path) == inputs[path], ('current scoped producer', path)
old_capsule = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'population-inputs.json.gz')).read_bytes()))
markdown = {row['path'] for row in population['rows']}
assert len(markdown) == 1487
for path in markdown:
    assert inputs[path] == old_capsule['inputs'][path]
    assert c.decode(inputs[path]['base64']) == subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
assert before['generation']['returncode'] == before['check']['returncode'] == 0
assert after['generation']['returncode'] == after['check']['returncode'] == 0
assert after['tap']['returncode'] == after['public_native']['returncode'] == 0
assert c.decode(after['tap']['stdout_base64']).splitlines()[:80] == c.decode(before['original_controls']['stdout_base64']).splitlines()[:80]
assert c.decode(after['tap']['stdout_base64']).endswith(b'1..176\n')


def sections(mapping):
    pieces = re.split(r'^### ([^\n]+)\n', mapping, flags=re.M)
    result = dict(zip(pieces[1::2], pieces[2::2]))
    assert len(result) == (len(pieces) - 1) // 2 == 1349
    return result


def field(section, name):
    values = [line for line in section.splitlines() if line.startswith('- **' + name + ':** ')]
    assert len(values) <= 1
    return values[0] if values else None


def code_values(line, name):
    """Read exact CommonMark code delimiters, rather than reproduce the writer."""
    prefix = '- **' + name + ':** '
    assert line is not None and line.startswith(prefix), ('missing named metadata', name)
    text = line[len(prefix):]
    values, cursor = [], 0
    while cursor < len(text):
        opening = re.match(r'`+', text[cursor:])
        assert opening, ('metadata code span opening', name, text[cursor:])
        delimiter = opening[0]
        cursor += len(delimiter)
        closing = re.search(r'(?<!`)'+re.escape(delimiter)+r'(?!`)', text[cursor:])
        assert closing, ('metadata code span closing', name)
        value = text[cursor:cursor+closing.start()]
        if value.startswith(' ') and value.endswith(' ') and value.strip(' '):
            value = value[1:-1]
        values.append(value)
        cursor += closing.end()
        if cursor < len(text):
            assert text[cursor:cursor+3] == ' · ', ('metadata item separator', name)
            cursor += 3
    return values


def scalar(raw):
    value = raw.strip()
    if value.startswith('"'):
        value = value[1:]
    if value.endswith('"'):
        value = value[:-1]
    return value


old_map = c.decode(before['whole_map_base64']).decode()
new_bytes = c.decode(after['map_base64'])
assert c.sha(new_bytes) == after['map_sha256']
new_map = new_bytes.decode()
old_sections, new_sections = sections(old_map), sections(new_map)
assert set(old_sections) == set(new_sections)
old_questions = [line for line in old_map.splitlines() if line.startswith('- "') and ' -> [' in line]
new_questions = [line for line in new_map.splitlines() if line.startswith('- "') and ' -> [' in line]
assert len(old_questions) == len(new_questions) == 10453
items, fields, cards, scalar_fields = 0, 0, set(), 0
checked_fields = []
for row in population['rows']:
    if not row['fact']:
        continue
    identifier = scalar(row['fields']['id']['raw'])
    assert re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*', identifier), ('documented stable anchor', identifier)
    old_section, new_section = old_sections[identifier], new_sections[identifier]
    fixed = lambda section: [line for line in section.splitlines() if not line.startswith(('- **evidence:** ', '- **reverify:** '))]
    assert fixed(old_section) == fixed(new_section), ('all nonmetadata fact bytes', identifier)
    for name in ('evidence', 'reverify'):
        original, current = field(old_section, name), field(new_section, name)
        source = row['fields'].get(name)
        if source is not None and source['kind'] == 'block':
            expected = [scalar(item['raw']) for item in source['items']]
            assert original is None and expected
            assert code_values(current, name) == expected, ('every authored metadata item/order/multiplicity', row['path'], name)
            items += len(expected)
            fields += 1
            cards.add(row['path'])
            checked_fields.append(dict(path=row['path'], key=name, items=len(expected)))
        else:
            assert current == original, ('exact scalar or absent metadata bytes', row['path'], name)
            scalar_fields += int(original is not None)
    needle = ' -> [' + identifier + '](' + row['path'] + ')'
    old_rows = [line for line in old_questions if needle in line]
    new_rows = [line for line in new_questions if needle in line]
    assert old_rows and len(old_rows) == len(new_rows)
    source = row['fields'].get('reverify')
    if source is not None and source['kind'] == 'block':
        for original, current in zip(old_rows, new_rows):
            assert current.startswith(original), ('question content unchanged', identifier)
            pointer = re.fullmatch(r' · reverify: \[(\d+) (entry|entries)\]\(#([^)]+)\)', current[len(original):])
            assert pointer and pointer[3] == identifier
            assert int(pointer[1]) == len(source['items'])
            assert pointer[2] == ('entry' if int(pointer[1]) == 1 else 'entries')
    else:
        assert new_rows == old_rows, ('exact scalar/absent question presentation', identifier)
assert (items, fields, len(cards)) == (before['missing_item_count'], before['missing_field_count'], before['affected_cards']) == (897, 248, 248)

# Re-run the actual generator/checker with supplied original Markdown and the
# repaired producer, independent of later unbound live fact edits.
fresh_paths = markdown | {'.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
    'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/check_knowledge_map.sh',
    'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh'}
fresh = []
with tempfile.TemporaryDirectory(prefix='knowledge-fields-review-', dir=os.environ['TMPDIR']) as directory:
    fixture = Path(directory)
    assert fixture.stat().st_dev == c.ROOT.stat().st_dev
    for path in fresh_paths:
        target = fixture / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(c.decode(inputs[path]['base64']))
        target.chmod(inputs[path]['mode'])
    temporary = fixture / '.linkedspec-data/tmp'
    temporary.mkdir(parents=True)
    environment = dict(os.environ, GIT_DIR=subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=c.ROOT, text=True).strip(),
                       GIT_WORK_TREE=str(fixture), GIT_OPTIONAL_LOCKS='0', TMPDIR=str(temporary),
                       KM_SCAN_DIRS='docs/knowledge docs/decisions', KM_OUTPUT='generated-map.md')
    for command in (['bash', 'knowledge-map/scripts/gen_knowledge_map.sh'], ['bash', 'knowledge-map/scripts/check_knowledge_map.sh']):
        run = subprocess.run(command, cwd=fixture, env=environment, capture_output=True)
        fresh.append(dict(command=command, returncode=run.returncode,
                          stdout_base64=c.encode(run.stdout), stderr_base64=c.encode(run.stderr)))
        if run.returncode:
            break
    assert len(fresh) == 2 and all(row['returncode'] == 0 for row in fresh), fresh
    assert (fixture / 'generated-map.md').read_bytes() == new_bytes, 'fresh complete supplied map re-derives exactly'
    assert all(c.sha((fixture / path).read_bytes()) == inputs[path]['sha256'] and
               (fixture / path).stat().st_mode & 0o7777 == inputs[path]['mode'] for path in fresh_paths)
report = dict(result='PASS', producer_sha256=c.sha(Path(__file__).read_bytes()),
              restored=dict(cards=len(cards), fields=fields, items=items), scalar_fields_exact=scalar_fields,
              facts=1349, question_rows=10453, markdown=1487, original80_exact=True,
              checked_fields=checked_fields, fresh_commands=fresh, supplied_source_count=len(fresh_paths),
              scope='Every897 original item is independently decoded from actual generated CommonMark '
                    'code spans and compared in authored order/multiplicity with captured raw source. '
                    'All248 fields, every scalar/absent field and all10453 question rows are checked. '
                    'All nonmetadata fact bytes and original80 assertions remain exact. Actual '
                    'generator/checker freshly re-derive the complete supplied1487-source graph '
                    'using repaired source; no later live historical fact body is consulted.')
target = c.ROOT / (c.HOME + 'review-epoch.json')
if sys.argv[1:]:
    with target.open('x') as output:
        output.write(json.dumps(report, indent=1) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('Independent metadata epoch PASS:897 entries/248 fields;all scalar/nonmetadata bytes;10453 routes;fresh full graph')
