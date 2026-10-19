"""Coherent artifact denials against the complete current semantic reader."""
import copy
import gzip
import json
import re
import sys
from pathlib import Path
import common as c
import metadata_oracle as oracle

assert sys.argv[1:] in ([], ['--capture'])
RECORD = c.HOME + 'current.json.gz'
CAPSULE = c.HOME + 'current-inputs.json.gz'
MAP = 'KNOWLEDGE_MAP.md'
INPUTS = c.HOME + 'artifact-inputs.json.gz'
ROWS = c.HOME + 'artifacts-reached.json.gz'
REPORT = c.HOME + 'artifacts.json'
command = ['python3', c.HOME + 'review-current.py', '--semantic-only']


def packed(value):
    return gzip.compress(json.dumps(value, sort_keys=True).encode(), mtime=0)


def candidates(originals):
    record = json.loads(gzip.decompress(c.decode(originals[RECORD]['base64'])))
    capsule = json.loads(gzip.decompress(c.decode(originals[CAPSULE]['base64'])))
    mapping = c.decode(originals[MAP]['base64']).decode()
    sections = oracle.sections(mapping)
    chosen = None
    for path, item in sorted(capsule['inputs'].items()):
        if not path.startswith('docs/knowledge/') or not path.endswith('.md'):
            continue
        header = oracle.header(c.decode(item['base64']))
        field = header.get('reverify', {})
        if field.get('kind') == 'block' and len(field['items']) >= 2:
            values = [oracle.scalar(item) for item in field['items']]
            if all('`' not in value and not value.startswith(' ') and not value.endswith(' ') for value in values):
                chosen = path, oracle.scalar(header['id']['raw']), values
                break
    assert chosen is not None
    path, identifier, values = chosen
    section = sections[identifier]
    line = oracle.field_line(section, 'reverify')
    token = '`' + values[0] + '` · '
    assert line.count(token) == 1
    missing_line = line.replace(token, '', 1)
    missing = mapping.replace(section, section.replace(line, missing_line, 1), 1)
    question = next(line for line in mapping.splitlines() if ' -> [' + identifier + '](' + path + ')' in line)
    pointer = '[' + str(len(values)) + ' entries](#' + identifier + ')'
    assert pointer in question
    wrong_question = question.replace(pointer, '[' + str(len(values)+1) + ' entries](#' + identifier + ')', 1)
    wrong_pointer = mapping.replace(question, wrong_question, 1)
    result = []
    for name, value, reason in [('coherent-missing-entry', missing, 'authored metadata values/order/multiplicity'),
                                ('coherent-wrong-pointer', wrong_pointer, 'complete question metadata and pointers')]:
        forged = copy.deepcopy(record)
        forged['map_base64'] = c.encode(value.encode())
        forged['map_sha256'] = c.sha(value.encode())
        assert forged['map_lines'] == len(value.splitlines())
        result.append(dict(name=name, reason=reason, replacements={MAP: c.encode(value.encode()), RECORD: c.encode(packed(forged))}))
    omitted_capsule = copy.deepcopy(capsule)
    del omitted_capsule['inputs'][path]
    omitted_record = copy.deepcopy(record)
    del omitted_record['inputs'][path]
    value = packed(omitted_capsule)
    omitted_record['capsule_sha256'] = c.sha(value)
    result.append(dict(name='coherent-incomplete-graph', reason='complete current graph',
                       replacements={CAPSULE: c.encode(value), RECORD: c.encode(packed(omitted_record))}))
    return result


if sys.argv[1:]:
    originals = {path: c.read(path) for path in (RECORD, CAPSULE, MAP)}
    variants = candidates(originals)
    prepared = dict(originals=originals, candidates=variants, producer_base64=c.encode(Path(__file__).read_bytes()),
                    reader=c.read(c.HOME + 'review-current.py'), oracle=c.read(c.HOME + 'metadata_oracle.py'))
    c.write_new(INPUTS, prepared, packed=True)
    baseline = c.run(command)
    assert baseline['returncode'] == 0 and not c.decode(baseline['stderr_base64']), baseline
    rows = []
    for variant in variants:
        expected = {path: c.decode(variant['replacements'].get(path, item['base64'])) for path, item in originals.items()}
        try:
            for path, value in expected.items():
                assert c.read(path) == originals[path]
                (c.ROOT / path).write_bytes(value)
                (c.ROOT / path).chmod(originals[path]['mode'])
            negative = c.run(command)
            assert all((c.ROOT / path).read_bytes() == value for path, value in expected.items())
        finally:
            for path, item in originals.items():
                assert (c.ROOT / path).read_bytes() == expected[path], 'preserve unknown concurrent artifact changes'
                (c.ROOT / path).write_bytes(c.decode(item['base64']))
                (c.ROOT / path).chmod(item['mode'])
        restored = c.run(command)
        row = dict(name=variant['name'], negative=negative, restored=restored,
                   inputs_restored=all(c.read(path) == item for path, item in originals.items()))
        rows.append(row)
        (c.ROOT / ROWS).write_bytes(packed(rows))
        assert negative['returncode'] != 0 and variant['reason'].encode() in c.decode(negative['stderr_base64']), row
        assert restored == baseline and row['inputs_restored']
        print('Artifact semantic RED/restored:', variant['name'], flush=True)
    report = dict(result='PASS', baseline=baseline, producer_sha256=c.sha(Path(__file__).read_bytes()),
                  inputs_sha256=c.sha((c.ROOT / INPUTS).read_bytes()), reached_sha256=c.sha((c.ROOT / ROWS).read_bytes()),
                  controls=[dict(name=row['name']) for row in rows],
                  scope='Three actual coherent whole-file forgeries update the map and its report '
                        'hash together, or omit a source and coherently update the report/capsule. '
                        'The independent complete semantic reader rejects missing authored data, '
                        'wrong question pointers and graph omission for named reasons. Exact original '
                        'byte/mode restoration recurs after each case; native observations are unchanged.')
    c.write_new(REPORT, report)

prepared = json.loads(gzip.decompress((c.ROOT / INPUTS).read_bytes()))
report = json.loads((c.ROOT / REPORT).read_bytes())
rows = json.loads(gzip.decompress((c.ROOT / ROWS).read_bytes()))
assert c.decode(prepared['producer_base64']) == Path(__file__).read_bytes()
assert report['producer_sha256'] == c.sha(Path(__file__).read_bytes())
assert report['inputs_sha256'] == c.sha((c.ROOT / INPUTS).read_bytes()) and report['reached_sha256'] == c.sha((c.ROOT / ROWS).read_bytes())
assert prepared['reader'] == c.read(c.HOME + 'review-current.py') and prepared['oracle'] == c.read(c.HOME + 'metadata_oracle.py')
variants = candidates(prepared['originals'])
assert variants == prepared['candidates'] and len(rows) == len(variants) == 3
assert all(c.read(path) == item for path, item in prepared['originals'].items())
for row, variant in zip(rows, variants):
    assert row['name'] == variant['name'] and row['negative']['returncode'] != 0
    assert variant['reason'].encode() in c.decode(row['negative']['stderr_base64'])
    assert row['restored'] == report['baseline'] and row['inputs_restored'] and report['baseline']['returncode'] == 0
print('Current artifact sensitivity PASS:3 coherent semantic denials;exact restorations')
