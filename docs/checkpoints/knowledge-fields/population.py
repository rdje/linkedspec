"""Capture the complete first-header field population before generator changes."""
import collections
import json
import re
import subprocess
from pathlib import Path
import common as c

assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=c.ROOT, text=True).strip() == c.BASE
paths = sorted(path.relative_to(c.ROOT).as_posix() for directory in ('docs/knowledge', 'docs/decisions')
               for path in (c.ROOT / directory).rglob('*.md') if path.is_file())
assert len(paths) == 1487
sources = {path: c.read(path) for path in paths}
for path, item in sources.items():
    assert c.decode(item['base64']) == subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)


def fields(value):
    lines = value.decode().splitlines()
    if not lines or lines[0].strip() != '---':
        return {}
    result, active = {}, None
    for number, line in enumerate(lines[1:], 2):
        if line.strip() == '---':
            break
        key = re.match(r'^([A-Za-z_][A-Za-z0-9_]*):\s*(.*)$', line)
        item = re.match(r'^[ \t]+-[ \t]+(.*)$', line)
        if key:
            name, text = key.groups()
            kind = 'block' if not text else 'inline' if text.startswith('[') and text.endswith(']') else 'scalar'
            assert name not in result, ('duplicate current first-header key', name)
            result[name] = dict(kind=kind, line=number, raw=text, items=[])
            active = name if kind == 'block' else None
        elif item and active is not None:
            result[active]['items'].append(dict(line=number, raw=item[1]))
    return result


rows = []
counts = collections.defaultdict(collections.Counter)
affected = []
for path, item in sources.items():
    parsed = fields(c.decode(item['base64']))
    answers = parsed.get('answers')
    fact = answers is not None and (answers['kind'] == 'block' and bool(answers['items']) or
                                   answers['kind'] == 'inline' and answers['raw'] != '[]')
    if fact:
        for name, value in parsed.items():
            counts[name][value['kind']] += 1
        missing = {name: parsed[name] for name in ('evidence', 'reverify') if name in parsed and parsed[name]['kind'] != 'scalar'}
        if missing:
            affected.append(dict(path=path, fields=missing))
    rows.append(dict(path=path, fact=fact, fields=parsed))
assert sum(row['fact'] for row in rows) == 1349
extras = ['.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
          'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/check_knowledge_map.sh',
          'knowledge-map/KNOWLEDGE_MAP_ARCHITECTURE.md', 'knowledge-map/templates/FACT_TEMPLATE.md',
          't/knowledge_map_header_lists.t',
          'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-metadata-lists.json',
          'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
          c.HOME + 'common.py', c.HOME + 'population.py']
inputs = dict(sources)
inputs.update({path: c.read(path) for path in extras})
inputs['KNOWLEDGE_MAP.md'] = c.read('KNOWLEDGE_MAP.md')
assert c.unchanged(inputs)
capsule = dict(base=c.BASE, inputs=inputs, scope='Complete actual1487 first-header source graph; all Markdown equals activation Git. Full source bytes/modes precede behavior changes.')
capsule_sha = c.write_new(c.HOME + 'population-inputs.json.gz', capsule, packed=True)
report = dict(version=1, result='PASS', base=c.BASE, markdown=len(paths), facts=sum(row['fact'] for row in rows),
              capsule_sha256=capsule_sha, rows=rows, field_shapes={name: dict(value) for name, value in counts.items()},
              affected_metadata=affected, producer_sha256=c.sha(Path(__file__).read_bytes()),
              inputs={path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in inputs.items()},
              scope='Independent first-header population parser retains raw field text and each block item/line. '
                    'Field-shape counts describe the complete actual current fact population, not arbitrary YAML '
                    'support. Public original20/80 and metadata reproductions remain independent retained oracles. '
                    'No generation, metadata edit or runtime/native capture occurs here.')
c.write_new(c.HOME + 'population.json', report)
print(json.dumps(dict(result='PASS', markdown=report['markdown'], facts=report['facts'],
                     evidence=report['field_shapes'].get('evidence'), reverify=report['field_shapes'].get('reverify'),
                     affected=[row['path'] for row in affected]), sort_keys=True))
