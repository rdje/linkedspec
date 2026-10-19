"""Preserve accepted migration proof and all live guards before bound inventory writes."""
import json
import subprocess
import common as c

assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=c.ROOT).decode().strip() == c.BASE
original = c.read(c.OLD_CLAIM)
preflight = c.read('docs/checkpoints/type-reference-migrations/publication-final-preflight.json')
claim = json.loads(c.decode(original['base64']))
proof = json.loads(c.decode(preflight['base64']))
assert proof['draft_base64'] == original['base64'] and proof['draft_sha256'] == original['sha256']
bindings = claim['claims'][0]['durability']['inputs']
assert len(bindings) == 396 and len(c.decode(original['base64'])) == 68960
assert claim['claims'][0]['durability']['mode'] == 'live'
planned = {'KNOWLEDGE_MAP.md', 'docs/knowledge/terse-type-method-surface-inventory.md',
    'docs/knowledge/uniform-binding-neutral-contract.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md'}
namespace_paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', c.BASE, '--', 'docs/claims'], cwd=c.ROOT, text=True).splitlines()
namespace_paths = sorted(path for path in namespace_paths if path.endswith('.json'))
assert namespace_paths == sorted(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / 'docs/claims').glob('*.json'))
namespace, live, intersections = {}, {}, {}
for path in namespace_paths:
    item = c.read(path)
    assert subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT) == c.decode(item['base64'])
    namespace[path] = dict(sha256=item['sha256'], mode=item['mode'])
    record = json.loads(c.decode(item['base64']))
    for index, entry in enumerate(record['claims']):
        durability = entry['durability']
        if durability.get('mode') != 'live':
            continue
        key = path + '#' + str(index)
        inputs = {}
        for binding in durability['inputs']:
            actual = c.read(binding['path'])
            assert actual['sha256'] == binding['sha256'], (key, binding['path'])
            inputs[binding['path']] = dict(sha256=actual['sha256'], mode=actual['mode'])
        live[key] = dict(original=item, inputs=inputs, name=entry['name'])
        overlap = sorted(set(inputs) & planned)
        if overlap:
            intersections[key] = overlap
assert list(intersections) == [c.OLD_CLAIM + '#0']
for binding in bindings:
    path = binding['path']
    actual = c.read(path)
    assert subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT) == c.decode(actual['base64'])
    assert actual['mode'] == proof['input_modes'][path]
record = dict(base_commit=c.BASE, original=original, preflight=preflight,
    namespace=namespace, live=live, planned_paths=sorted(planned), intersections=intersections,
    before_planned={path: c.read(path) for path in sorted(planned)},
    producer=c.read(c.PREFIX + 'preserve.py'), helper=c.read(c.PREFIX + 'common.py'),
    scope='Whole accepted396/full68960 and actual modes precede bound writes. Every input '
          'matches the real accepted Git BASE, which retains complete recoverable bytes. All '
          'current claim records match that same accepted namespace; only the migration claim '
          'intersects planned book/Knowledge changes. No uncommitted draft is assigned a Git revision.')
c.write_new(c.PREFIX + 'preservation.json.gz', record, packed=True)
baseline = c.run(['python3', c.OLD_PUBLISHER])
assert baseline['returncode'] == 0 and not c.decode(baseline['stderr_base64']), baseline
assert c.decode(baseline['stdout_base64']) == b'Current migration publication PASS: 396 inputs; 68960 bytes;17 payloads;five controls;prior208/full39111\n'
for item in live.values():
    assert all(c.read(path)['sha256'] == identity['sha256'] and c.read(path)['mode'] == identity['mode'] for path, identity in item['inputs'].items())
assert c.read(c.OLD_CLAIM) == original
c.write_new(c.PREFIX + 'baseline.json', dict(result='PASS', run=baseline,
    preservation_sha256=c.sha((c.ROOT / (c.PREFIX + 'preservation.json.gz')).read_bytes()),
    original_claim_unchanged=True, all_live_inputs_bytes_modes_unchanged=True))
print('Accepted396/full68960 and actual readonly baseline preserved; only migration claim intersects planned writes')
