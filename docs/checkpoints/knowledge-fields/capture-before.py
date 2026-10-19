"""Capture actual public metadata omissions and unchanged header controls."""
import gzip
import json
import os
import re
import tempfile
from pathlib import Path
import common as c

population_raw = (c.ROOT / (c.HOME + 'population.json')).read_bytes()
population = json.loads(population_raw)
packed = (c.ROOT / (c.HOME + 'population-inputs.json.gz')).read_bytes()
assert c.sha(packed) == population['capsule_sha256']
capsule = json.loads(gzip.decompress(packed))
inputs = dict(capsule['inputs'])
for path in (c.HOME + 'capture-before.py', c.HOME + 'population.json', c.HOME + 'population-inputs.json.gz'):
    inputs[path] = c.read(path)
assert c.unchanged(inputs)
markdown = {path for path in inputs if path.startswith(('docs/knowledge/', 'docs/decisions/')) and path.endswith('.md')}
actual = {path.relative_to(c.ROOT).as_posix() for directory in ('docs/knowledge', 'docs/decisions')
          for path in (c.ROOT / directory).rglob('*.md') if path.is_file()}
assert markdown == actual and len(markdown) == 1487
rows = []
base = 'id: sample\ntitle: Metadata sample\ndate: 2026-10-19\nanswers: [metadata question]\n'
cases = [
    ('scalar-evidence', 'evidence: first.md\n', {'evidence': ['first.md']}),
    ('scalar-reverify', 'reverify: printf first\n', {'reverify': ['printf first']}),
    ('block-evidence', 'evidence:\n  - first.md\n  - second.md\n', {'evidence': ['first.md', 'second.md']}),
    ('inline-evidence', 'evidence: [first.md, second.md]\n', {'evidence': ['first.md', 'second.md']}),
    ('block-reverify', 'reverify:\n  - printf first\n  - printf second\n', {'reverify': ['printf first', 'printf second']}),
    ('inline-reverify', 'reverify: [printf first, printf second]\n', {'reverify': ['printf first', 'printf second']}),
    ('both-block', 'evidence:\n  - "source, Unicode β.md"\nreverify:\n  - "printf `first`"\n  - printf second\n',
     {'evidence': ['source, Unicode β.md'], 'reverify': ['printf `first`', 'printf second']}),
]
with tempfile.TemporaryDirectory(prefix='knowledge-fields-before-', dir=os.environ['TMPDIR']) as directory:
    scratch = Path(directory)
    assert scratch.stat().st_dev == c.ROOT.stat().st_dev
    output = scratch / 'whole-map.md'
    environment = dict(os.environ, KM_OUTPUT=output.relative_to(c.ROOT).as_posix())
    generate = c.run(['bash', 'knowledge-map/scripts/gen_knowledge_map.sh'], env=environment)
    check = c.run(['bash', 'knowledge-map/scripts/check_knowledge_map.sh'], env=environment)
    whole_map = output.read_bytes()
    assert generate['returncode'] == check['returncode'] == 0
    assert whole_map == c.decode(capsule['inputs']['KNOWLEDGE_MAP.md']['base64'])
    text = whole_map.decode()
    missing = []
    population_by_path = {row['path']: row for row in population['rows']}
    for row in population['affected_metadata']:
        fact = population_by_path[row['path']]
        identifier = fact['fields']['id']['raw'].strip('"')
        section = text.split('\n### ' + identifier + '\n', 1)[1].split('\n### ', 1)[0]
        question_rows = [line for line in text.splitlines() if ' -> [' + identifier + '](' + row['path'] + ')' in line]
        assert question_rows
        for key, field in row['fields'].items():
            assert field['kind'] == 'block' and field['items']
            assert '- **' + key + ':**' not in section, ('actual absent fact metadata', row['path'], key)
            if key == 'reverify':
                assert all(' · reverify:' not in line for line in question_rows)
            missing.append(dict(path=row['path'], key=key, items=len(field['items']), question_rows=len(question_rows),
                                fact_section_base64=c.encode(section.encode()), question_rows_base64=c.encode('\n'.join(question_rows).encode())))
    for index, (name, metadata, expected) in enumerate(cases):
        case = scratch / ('case-%d' % index)
        case.mkdir()
        header = '---\n' + base + metadata + '---\n\nBody is not metadata.\n'
        (case / 'fact.md').write_bytes(header.encode())
        output = scratch / ('map-%d.md' % index)
        environment = dict(os.environ, KM_SCAN_DIRS=case.relative_to(c.ROOT).as_posix(),
                           KM_OUTPUT=output.relative_to(c.ROOT).as_posix())
        generated = c.run(['bash', 'knowledge-map/scripts/gen_knowledge_map.sh'], env=environment)
        checked = c.run(['bash', 'knowledge-map/scripts/check_knowledge_map.sh'], env=environment)
        mapping = output.read_bytes()
        assert generated['returncode'] == checked['returncode'] == 0
        present = {key: all(value.encode() in mapping for value in values) and
                         ('- **' + key + ':**').encode() in mapping for key, values in expected.items()}
        assert all(present.values()) == name.startswith('scalar-'), (name, present)
        rows.append(dict(name=name, header_base64=c.encode(header.encode()), expected=expected,
                         generate=generated, check=checked, map_base64=c.encode(mapping), displayed=present))
controls = c.run(['perl', 't/knowledge_map_header_lists.t'])
assert controls['returncode'] == 0 and not c.decode(controls['stderr_base64'])
assert c.decode(controls['stdout_base64']).endswith(b'1..80\n')
assert not re.search(rb'^not ok', c.decode(controls['stdout_base64']), re.M)
assert c.unchanged(inputs)
record = dict(version=1, result='PASS', base=c.BASE, original_controls=controls,
              original_markdown=1487, original_facts=1349, generation=generate, check=check,
              whole_map_base64=c.encode(whole_map), missing_fields=missing, public_cases=rows,
              affected_cards=len({row['path'] for row in missing}), missing_field_count=len(missing),
              missing_item_count=sum(row['items'] for row in missing),
              producer_sha256=c.sha(Path(__file__).read_bytes()), inputs_unchanged=True,
              inputs={path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in inputs.items()},
              scope='Actual unchanged full public generator/checker accept the complete supplied1487/1349 '
                    'population while omitting each named nonempty block metadata field. Every actual '
                    'fact section and reverify question route is retained. Seven separate public cases '
                    'distinguish scalar preservation from block/inline omission; unchanged original20/80 '
                    'controls pass. No metadata command is evaluated and no source changes occur.')
c.write_new(c.HOME + 'before.json.gz', record, packed=True)
print('Original metadata projection RED retained:', record['affected_cards'], 'cards;', len(missing),
      'fields;', record['missing_item_count'], 'items; original80 controls PASS; five public list REDs')
