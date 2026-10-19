"""One-shot pre-write preservation of the accepted metadata graph and namespace."""
import gzip
import json
import subprocess
from pathlib import Path
import common as c

assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=c.ROOT).decode().strip() == c.BASE
prior = c.read(c.PRIOR_CLAIM)
preflight = c.read('docs/checkpoints/knowledge-fields/publication-preflight.json')
parsed = json.loads(c.decode(prior['base64']))
assert len(c.decode(prior['base64'])) == 39111
assert parsed['claims'][0]['durability']['mode'] == 'live'
bindings = parsed['claims'][0]['durability']['inputs']
assert len(bindings) == 208
pre = json.loads(c.decode(preflight['base64']))
assert c.decode(pre['draft_base64']) == c.decode(prior['base64']) and pre['draft_sha256'] == prior['sha256']
metadata = json.loads(gzip.decompress((c.ROOT / 'docs/checkpoints/knowledge-fields/current.json.gz').read_bytes()))
facts = metadata['changed_facts']
assert len(facts) == 15
planned = set(facts) | {c.PRIOR_CLAIM, 'KNOWLEDGE_MAP.md',
    'docs/knowledge/retired-return-helpers-canonical-rewrite.md',
    'docs/knowledge/actionir-return-node-retired-to-return.md',
    'docs/linkedspec-book/src/appendix/formal-grammar.md'}
namespace_paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', c.BASE, '--', 'docs/claims'], cwd=c.ROOT).decode().splitlines()
namespace_paths = sorted(path for path in namespace_paths if path.endswith('.json'))
assert namespace_paths == sorted(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / 'docs/claims').glob('*.json'))
namespace, live, intersections = {}, {}, {}
for path in namespace_paths:
    item = c.read(path)
    committed = subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
    assert committed == c.decode(item['base64']), ('actual accepted claim namespace', path)
    namespace[path] = dict(sha256=item['sha256'], mode=item['mode'])
    data = json.loads(committed)
    for index, claim in enumerate(data.get('claims', [])):
        durability = claim.get('durability', {})
        if durability.get('mode') != 'live':
            continue
        key = path + '#' + str(index)
        paths = {row['path'] for row in durability['inputs']}
        supplied = {}
        for binding in durability['inputs']:
            actual = c.read(binding['path'])
            assert actual['sha256'] == binding['sha256'], (key, binding['path'])
            supplied[binding['path']] = dict(sha256=actual['sha256'], mode=actual['mode'])
        live[key] = dict(original=item, inputs=supplied, name=claim['name'])
        if paths & planned:
            intersections[key] = sorted(paths & planned)
assert list(intersections) == [c.PRIOR_CLAIM + '#0']
inputs = live[c.PRIOR_CLAIM + '#0']['inputs']
for path, item in inputs.items():
    assert subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT) == (c.ROOT / path).read_bytes(), ('recoverable accepted input', path)
    assert item['mode'] == pre['input_modes'][path]
record = dict(base_commit=c.BASE, original=prior, preflight=preflight, inputs=inputs,
    namespace=namespace, live=live, planned_paths=sorted(planned), intersections=intersections,
    route_facts=facts, before_planned={path: c.read(path) for path in sorted(planned)},
    producer=c.read(c.PREFIX + 'preserve.py'), helper=c.read(c.PREFIX + 'common.py'),
    scope='Whole accepted208/full39111 and every actual input byte identity/mode precede bound writes. '
          'Every input and original claim equals the real accepted BASE Git object; no synthetic revision. '
          'Complete actual claim namespace is retained by BASE/hash/mode manifest; all three live claims '
          'and their current input guards are retained. Only the metadata claim intersects these planned '
          'documentation/Knowledge edits. Wrapper-warning6 and private-capacity14 inputs stay unchanged.')
c.write_new(c.PREFIX + 'preservation.json.gz', record, packed=True)
run = c.run(['python3', c.PRIOR_PUBLISHER])
assert run['returncode'] == 0 and not c.decode(run['stderr_base64']), run
assert c.decode(run['stdout_base64']) == b'Metadata publication PASS: 208 inputs; 39111 bytes;1487/1349/10455;897/248\n'
assert c.unchanged(inputs) and c.read(c.PRIOR_CLAIM) == prior
assert all(c.unchanged(item['inputs']) for item in live.values())
c.write_new(c.PREFIX + 'baseline.json', dict(result='PASS', command=run,
    preservation_sha256=c.sha((c.ROOT / (c.PREFIX + 'preservation.json.gz')).read_bytes()),
    whole_claim_bytes_mode_unchanged=True, all208_inputs_bytes_modes_unchanged=True,
    all_live_input_guards_unchanged=True))
print('Accepted metadata208/full39111 preservation and actual readonly baseline PASS;only metadata intersects planned writes')
