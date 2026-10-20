"""Preserve the whole accepted inventory and every live guard before runtime writes."""
import json
import subprocess
import common as c

assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=c.ROOT, text=True).strip() == c.BASE
original = c.read(c.OLD_CLAIM)
preflight = c.read('docs/checkpoints/type-reference-inventory/publication.json')
claim = json.loads(c.decode(original['base64']))
proof = json.loads(c.decode(preflight['base64']))
assert proof['record_base64'] == original['base64'] and proof['record_sha256'] == original['sha256']
bindings = claim['claims'][0]['durability']['inputs']
assert len(bindings) == 388 and len(c.decode(original['base64'])) == 68814
assert claim['claims'][0]['durability']['mode'] == 'live'
planned = {'perl/LinkedSpec/ActionIR/MethodLowering.pm', 'KNOWLEDGE_MAP.md',
    'docs/knowledge/terse-type-method-surface-inventory.md',
    'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'}
namespace_paths = sorted(path for path in subprocess.check_output(
    ['git', 'ls-tree', '-r', '--name-only', c.BASE, '--', 'docs/claims'], cwd=c.ROOT, text=True).splitlines()
    if path.endswith('.json'))
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
assert list(intersections) == [c.OLD_CLAIM + '#0'], intersections
for binding in bindings:
    path = binding['path']
    actual = c.read(path)
    assert subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT) == c.decode(actual['base64'])
    assert actual['mode'] == proof['input_modes'][path]
c.write_new(c.PREFIX + 'preservation.json.gz', dict(base_commit=c.BASE, original=original,
    preflight=preflight, namespace=namespace, live=live, planned_paths=sorted(planned),
    intersections=intersections, producer=c.read(c.PREFIX + 'preserve.py'), helper=c.read(c.PREFIX + 'common.py'),
    scope='Whole accepted388/full68814 and actual modes precede bound writes; every input is recoverable '
          'from real accepted Git BASE. All current records match that namespace. Original model defects, '
          'raw channels and failed instruments remain immutable. No invented revision for uncommitted work.'), packed=True)
baseline = c.run(['python3', c.OLD_PUBLISHER])
assert baseline['returncode'] == 0 and not c.decode(baseline['stderr_base64']), baseline
assert c.decode(baseline['stdout_base64']) == b'Current type authority/model publication PASS: 388 inputs; 68814 bytes; runtime repairs3/4 pending\n'
for item in live.values():
    assert all(c.read(path)['sha256'] == wanted['sha256'] and c.read(path)['mode'] == wanted['mode']
               for path, wanted in item['inputs'].items())
assert c.read(c.OLD_CLAIM) == original
c.write_new(c.PREFIX + 'baseline.json', dict(result='PASS', run=baseline,
    preservation_sha256=c.sha((c.ROOT / (c.PREFIX + 'preservation.json.gz')).read_bytes()),
    original_claim_unchanged=True, all_live_inputs_bytes_modes_unchanged=True))
print('Accepted inventory388/full68814 and actual readonly baseline preserved')
