"""Project current routes and author guidance, then capture the complete current map."""
import gzip
import json
from pathlib import Path
import common as c

preserved = json.loads((c.ROOT / (c.HOME + 'preservation.json')).read_bytes())
old_claim = json.loads(c.decode(preserved['original']['base64']))
facts = sorted(item['path'] for item in old_claim['claims'][0]['durability']['inputs'] if item['path'].startswith('docs/knowledge/'))
assert len(facts) == 15
architecture = 'knowledge-map/KNOWLEDGE_MAP_ARCHITECTURE.md'
template = 'knowledge-map/templates/FACT_TEMPLATE.md'
book = 'docs/linkedspec-book/src/development/documentation-workflow.md'
card = 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md'
originals = {path: c.read(path) for path in facts + [architecture, template, book]}
proposals = {}
route = 'reverify: "Readonly: bash tools/run_python_project_data.sh docs/checkpoints/knowledge-fields/publish.py. Prior:f7e8b292f."'
for path in facts:
    header, body = c.decode(originals[path]['base64']).decode().split('\n---\n', 1)
    lines = header.splitlines()
    indexes = [i for i, line in enumerate(lines) if line.startswith('reverify:')]
    assert len(indexes) == 1 and 'docs/checkpoints/pipeline-scope/publish.py' in lines[indexes[0]]
    lines[indexes[0]] = route
    proposals[path] = ('\n'.join(lines) + '\n---\n' + body).encode()
value = proposals[card].decode()
header, body = value.split('\n---\n', 1)
questions = ('  - "why does accepted block metadata disappear from the Knowledge Map"\n'
             '  - "how are evidence and reverify lists displayed without executing commands"\n')
assert questions not in header and header.count('\ndate:') == 1
header = header.replace('\ndate:', '\n' + questions + 'date:', 1)
old = ('Valid block-evidence and block-reverify inputs are accepted by the original checker but omitted from generated metadata. '
       'Two exact public generator reproductions and their original acceptance channels are retained in '
       'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-metadata-lists.json. P3 .3.2.1.12 owns the field/projection '
       'contract and current affected-population census after the factory/pipeline activity, before TYPE-REFERENCE-BOOK. '
       'No full population count or remedy is inferred from these two named cases.')
assert body.count(old) == 1
new = ('At the .11 boundary, two named public reproductions showed accepted block evidence/reverify disappearing from '
       'the map; their original source/channels remain in docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-metadata-lists.json. '
       'The October19 .12 capture independently checks all1487 source documents/1349 facts: the old generator omits897 '
       'entries in248 nonempty list fields while the checker accepts them. The repaired generator preserves authored '
       'order and duplicates, uses separate code spans, and links each reverify question to its complete fact list. '
       'Scalar field bytes remain unchanged. Commands are displayed, never executed or combined. A quoted evidence/reverify '
       'inline item protects commas; complex values can use block lists. The checker retains its documented presence/list '
       'association limits, without a full YAML/type-validation admission. Complete source-bound observations, failed '
       'instruments, compact-format/render proof and current readonly verification belong to docs/checkpoints/knowledge-fields/.')
body = body.replace(old, new, 1)
proposals[card] = (header + '\n---\n' + body).encode()

text = c.decode(originals[architecture]['base64']).decode()
marker = 'association check does not constitute a complete YAML parser or field-type validator.\n'
assert text.count(marker) == 1
section = '''
### Evidence and reverify values

Both fields support a scalar, an inline list, or a block list. Nonempty list items
appear in authored order, including repeated values, as separate code spans in
the fact entry. Each question keeps its existing inline scalar command or links
to the complete reverify list with an `N entries` label. Metadata is displayed;
generation and validation never execute it or combine commands.

For evidence/reverify inline lists, a double-quoted item can contain a comma or
escaped quote. Existing outer-quote/literal-escape treatment is preserved. Block
lists are convenient for complex commands. The existing answers-list restriction
still applies: questions containing commas use the block form.

Prefer one cheap re-check. When several commands or instructions are needed, keep
them as separate authored entries and follow their stated context. List syntax
does not make them a shell pipeline or an automatic execution sequence.
'''
proposals[architecture] = text.replace(marker, marker + section, 1).encode()
text = c.decode(originals[template]['base64']).decode()
marker = 'reverify: grep -n "Symbol" path/to/file # REQUIRED (this OR evidence): ONE cheap re-check\n'
assert text.count(marker) == 1
comment = ('# evidence/reverify also accept inline or block lists of nonempty entries.\n'
           '# Items appear separately in authored order; question rows link to the full list.\n'
           '# Quote an evidence/reverify inline item containing a comma, or use a block list.\n'
           '# Metadata commands are never executed or combined by generation/validation.\n')
proposals[template] = text.replace(marker, marker + comment, 1).encode()
text = c.decode(originals[book]['base64']).decode()
marker = '\n## Public book\n'
assert text.count(marker) == 1
section = '''
### Evidence and verification lists

The map displays scalar and list values for `evidence` and `reverify`. Lists keep
their authored order and repeated entries. For example:

```yaml
evidence: ["source, notes.md", tests/evidence.t]
reverify:
  - bash scripts/check_memory_architecture.sh
  - bash knowledge-map/scripts/check_knowledge_map.sh
```

The fact entry shows each value in its own code span:

```markdown
- **evidence:** `source, notes.md` · `tests/evidence.t`
- **reverify:** `bash scripts/check_memory_architecture.sh` · `bash knowledge-map/scripts/check_knowledge_map.sh`
```

Question rows link to the complete fact list with an `N entries` label. A scalar
command keeps its existing inline presentation. Generation and validation display
these commands without running or combining them; follow the context written in
the fact when choosing a check. Code-span delimiters preserve backticks inside
list values. Double-quoted evidence/reverify inline items can protect commas and
escaped quotes; block lists keep complex commands readable. Questions containing
commas continue to use the existing block-list form.
'''
proposals[book] = text.replace(marker, '\n' + section + marker, 1).encode()
registry = c.read('doctrine/readme_stability/routes.jsonl')
control = next(json.loads(line) for line in c.decode(registry['base64']).decode().splitlines() if json.loads(line).get('id') == 'knowledge_cards')
before_bytes = sum(path.stat().st_size for path in (c.ROOT / 'docs/knowledge').rglob('*.md'))
assert before_bytes == 8386222
after_bytes = before_bytes + sum(len(proposals[path]) - len(c.decode(originals[path]['base64'])) for path in facts)
assert after_bytes <= control['limits']['max_bytes'] == 8388608
for path in facts:
    assert len(proposals[path]) <= control['member_limits']['max_bytes']
    assert len(proposals[path].splitlines()) <= control['member_limits']['max_lines']
record = dict(result='prepared', base=c.BASE, originals=originals,
    proposals={path: dict(base64=c.encode(value), sha256=c.sha(value), mode=originals[path]['mode']) for path, value in proposals.items()},
    registry=registry, knowledge_bytes_before=before_bytes, knowledge_bytes_after=after_bytes,
    changed_facts=facts, new_question_keys=2, producer_base64=c.encode(Path(__file__).read_bytes()),
    scope='All fifteen current route headers move from the now historical .6 publisher to the '
          'current metadata owner. The existing canonical card gains two questions and a dated '
          'causal finding without a new card or threshold change. Original full files/headers '
          'and historical observations stay recoverable. Architecture/template/book explain '
          'the supported format and separate displayed commands. No claim/proof epoch is refreshed.')
c.write_new(c.HOME + 'docs-preparation.json.gz', record, packed=True)
assert all(c.read(path) == item for path, item in originals.items())
for path, value in proposals.items():
    (c.ROOT / path).write_bytes(value)
old = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'population-inputs.json.gz')).read_bytes()))
markdown = {path for path in old['inputs'] if path.startswith(('docs/knowledge/', 'docs/decisions/')) and path.endswith('.md')}
current = {path: c.read(path) for path in markdown}
for path, item in current.items():
    if path in proposals:
        assert c.decode(item['base64']) == proposals[path]
    else:
        assert item == old['inputs'][path]
paths = ['.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
         'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/check_knowledge_map.sh',
         'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
         architecture, template, book, c.HOME + 'common.py', c.HOME + 'prepare-docs.py',
         c.HOME + 'docs-preparation.json.gz', 'doctrine/readme_stability/routes.jsonl']
current.update({path: c.read(path) for path in paths})
capsule_sha = c.write_new(c.HOME + 'current-inputs.json.gz', dict(base=c.BASE, original_markdown=1487, inputs=current), packed=True)
generated = c.run(['bash', 'knowledge-map/scripts/gen_knowledge_map.sh'])
checked = c.run(['bash', 'knowledge-map/scripts/check_knowledge_map.sh'])
mapping = (c.ROOT / 'KNOWLEDGE_MAP.md').read_bytes()
report = dict(result='PASS', base=c.BASE, capsule_sha256=capsule_sha, generation=generated, check=checked,
              map_base64=c.encode(mapping), map_sha256=c.sha(mapping), map_lines=len(mapping.splitlines()),
              markdown=1487, facts=1349, question_keys=10455, changed_facts=facts,
              knowledge_bytes=after_bytes, inputs_unchanged=c.unchanged(current),
              inputs={path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in current.items()},
              producer_sha256=c.sha(Path(__file__).read_bytes()))
c.write_new(c.HOME + 'current.json.gz', report, packed=True)
assert generated['returncode'] == checked['returncode'] == 0 and report['inputs_unchanged']
assert b'(1349 facts, 10455 question keys)' in c.decode(generated['stderr_base64'])
assert len(mapping.splitlines()) <= 22500 and len(mapping) <= 8388608
print('Current docs/map PASS:1487/1349/10455;', len(facts), 'routes;knowledge bytes', after_bytes,
      ';map lines', len(mapping.splitlines()))
