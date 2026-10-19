"""Capture the complete unchanged-source graph with repaired metadata projection."""
import gzip
import json
import os
import re
import tempfile
from pathlib import Path
import common as c

old_raw = (c.ROOT / (c.HOME + 'population-inputs.json.gz')).read_bytes()
old = json.loads(gzip.decompress(old_raw))
population = json.loads((c.ROOT / (c.HOME + 'population.json')).read_bytes())
assert c.sha(old_raw) == population['capsule_sha256']
inputs = {path: c.read(path) for path in old['inputs']}
markdown = {path for path in old['inputs'] if path.startswith(('docs/knowledge/', 'docs/decisions/')) and path.endswith('.md')}
assert len(markdown) == 1487
for path in markdown:
    assert inputs[path] == old['inputs'][path], ('same complete original Markdown graph', path)
paths = ['docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-headers-census.json',
         c.HOME + 'capture-compact.py', c.HOME + 'population.json', c.HOME + 'population-inputs.json.gz',
         c.HOME + 'before.json.gz', c.HOME + 'controls-final.json', c.HOME + 'red.json.gz',
         c.HOME + 'red-final.json.gz', c.HOME + 'assertion-repair.json', c.HOME + 'preservation.json',
         c.HOME + 'contain.py', c.HOME + 'containment.json', c.HOME + 'pressure-preparation.json.gz',
         c.HOME + 'pressure-red.json.gz', c.HOME + 'after.json.gz', c.HOME + 'after-inputs.json.gz',
         c.HOME + 'review-epoch.py', c.HOME + 'review-epoch.json']
inputs.update({path: c.read(path) for path in paths})
assert c.unchanged(inputs)
syntax = [c.run(command) for command in (
    ['bash', '-n', 'knowledge-map/scripts/gen_knowledge_map.sh'],
    ['bash', '-n', 'knowledge-map/scripts/check_knowledge_map.sh'],
    ['perl', '-c', 't/knowledge_map_header_lists.t'])]
assert all(row['returncode'] == 0 for row in syntax)
with tempfile.TemporaryDirectory(prefix='knowledge-fields-after-', dir=os.environ['TMPDIR']) as directory:
    scratch = Path(directory)
    assert scratch.stat().st_dev == c.ROOT.stat().st_dev
    output = scratch / 'whole-map.md'
    environment = dict(os.environ, KM_OUTPUT=output.relative_to(c.ROOT).as_posix())
    generated = c.run(['bash', 'knowledge-map/scripts/gen_knowledge_map.sh'], env=environment)
    checked = c.run(['bash', 'knowledge-map/scripts/check_knowledge_map.sh'], env=environment)
    mapping = output.read_bytes()
    assert generated['returncode'] == checked['returncode'] == 0
tap = c.run(['perl', 't/knowledge_map_header_lists.t'])
native = c.run(['perl', 't/knowledge_map_header_lists.t', '--observe'])
assert tap['returncode'] == native['returncode'] == 0
assert not c.decode(tap['stderr_base64']) and not c.decode(native['stderr_base64'])
assert c.decode(tap['stdout_base64']).endswith(b'1..176\n')
assert not re.search(rb'^not ok', c.decode(tap['stdout_base64']), re.M)
observed = json.loads(c.decode(native['stdout_base64']))
assert len(observed['rows']) == 30
assert c.unchanged(inputs)
capsule_sha = c.write_new(c.HOME + 'compact-inputs.json.gz', dict(base=c.BASE, inputs=inputs), packed=True)
record = dict(version=1, result='PASS', base=c.BASE, original_markdown=1487, original_facts=1349,
              same_complete_markdown_graph=True, generation=generated, check=checked,
              map_base64=c.encode(mapping), map_sha256=c.sha(mapping),
              tap=tap, public_native=native, syntax=syntax, capsule_sha256=capsule_sha,
              inputs_unchanged=True,
              inputs={path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in inputs.items()},
              producer_sha256=c.sha(Path(__file__).read_bytes()),
              scope='Distinct structured repaired epoch on all1487 original Markdown inputs before '
                    'current-route or book changes. Complete actual whole generator/checker output, '
                    '176-assertion TAP and all30 public native rows retain separate complete channels. '
                    'The fixed historical census is supplied before each control invocation. Source '
                    'bytes/modes precede the commands and remain unchanged; every input is recoverable.')
c.write_new(c.HOME + 'compact.json.gz', record, packed=True)
print('Repaired epoch captured:complete1487/1349;176 assertions;30 native rows;all input guards PASS')
