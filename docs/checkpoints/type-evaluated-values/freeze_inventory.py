"""Freeze only the accepted inventory after whole-context replay, never an uncommitted draft."""
import gzip
import json
import common as c

preserved = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'preservation.json.gz')).read_bytes()))
assert json.loads((c.ROOT / (c.PREFIX + 'inventory-replay.json')).read_bytes())['result'] == 'PASS'
assert json.loads((c.ROOT / (c.PREFIX + 'baseline.json')).read_bytes())['result'] == 'PASS'
assert c.read(c.OLD_CLAIM) == preserved['original']
for key, item in preserved['live'].items():
    assert c.read(key.rsplit('#', 1)[0]) == item['original']
    for path, wanted in item['inputs'].items():
        assert all(c.read(path)[field] == wanted[field] for field in ('sha256', 'mode'))
planned = set(preserved['planned_paths']) | {'t/callable_codeblock_literal_contract.t'}
intersections = {key: sorted(set(item['inputs']) & planned) for key, item in preserved['live'].items()
                 if set(item['inputs']) & planned}
assert list(intersections) == [c.OLD_CLAIM + '#0']
c.write_new(c.PREFIX + 'freeze-inputs.json', dict(producer=c.read(c.PREFIX + 'freeze_inventory.py'),
    helper=c.read(c.PREFIX + 'common.py'), original=preserved['original'],
    actual_complete_plan=sorted(planned), intersections=intersections,
    actual_baseline=c.read(c.PREFIX + 'baseline.json'), actual_replay=c.read(c.PREFIX + 'inventory-replay.json')))
raw = c.decode(preserved['original']['base64'])
assert raw.count(b'"mode": "live"') == 1
frozen = raw.replace(b'"mode": "live"', ('"mode": "historical",\n    "revision": "' + c.BASE + '"').encode(), 1)
expected = json.loads(raw)
expected['claims'][0]['durability'].update(mode='historical', revision=c.BASE)
assert json.loads(frozen) == expected
(c.ROOT / c.OLD_CLAIM).write_bytes(frozen)
print('Only inventory388/full68814 frozen by mode/revision at actual accepted Git BASE')
