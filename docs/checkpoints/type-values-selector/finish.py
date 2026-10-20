"""Resolve captured before-epoch metadata without changing current source verification."""
import ast
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import partition_storage as storage

P, F = storage.P, c.PREFIX
saved = storage.load('preservation.json.gz')
composed = storage.load('compose-proposals.json.gz')
paths = (P + 'partition_storage.py', F + 'selector_records.py', F + 'publish_selector.py')
before = {path: c.read(path) for path in paths}
assert before[paths[0]] == storage.load('partition-copy.json')['reader']
assert all(before[path] == composed['after'][path] for path in paths[1:])
versions = {}
snapshots = [saved['before'], storage.load('proposals.json.gz')['before'],
             storage.load('docs-proposals.json.gz')['before'], composed['before'], before]
for snapshot in snapshots:
    for path, item in snapshot.items():
        assert c.sha(c.decode(item['base64'])) == item['sha256']
        rows = versions.setdefault(path, [])
        if not any((row['sha256'], row['mode']) == (item['sha256'], item['mode']) for row in rows):
            rows.append(item)
c.write_new(P + 'historical-versions.json.gz', dict(versions=versions,
    producer=c.read(P + 'finish.py'),
    scope='Only exact already-captured before-epoch bytes. The historical getter requires '
          'path, desired hash and mode and verifies payload bytes; current c.read remains '
          'the actual worktree accessor except for the two declared partitioned artifacts.'),
    packed=True)
reader = c.decode(before[paths[0]]['base64']).decode()
needle = '\ndef install_legacy(common, capsules):\n'
getter = '''
_history = None


def historical_version(path, wanted):
    global _history
    if _history is None:
        _history = load('historical-versions.json.gz')['versions']
    for item in _history.get(path, []):
        if item['sha256'] == wanted['sha256'] and item['mode'] == wanted['mode']:
            assert c.sha(c.decode(item['base64'])) == item['sha256']
            return item
    return None

'''
assert reader.count(needle) == 1
reader = reader.replace(needle, getter + needle, 1)
needle = '        return original(path, wanted)\n'
replacement = '''        historical = historical_version(path, wanted)
        if historical is not None:
            return historical
        return original(path, wanted)
'''
assert reader.count(needle) == 1
reader = reader.replace(needle, replacement, 1)
# The measured byte decoder and physical-input guards remain the same actual producer.
old_ast = ast.parse(c.decode(before[paths[0]]['base64']).decode())
new_ast = ast.parse(reader)
for name in ('checked_target', 'physical', 'read_partition', 'read_bytes', 'read', 'load'):
    old = next(node for node in old_ast.body if isinstance(node, ast.FunctionDef) and node.name == name)
    new = next(node for node in new_ast.body if isinstance(node, ast.FunctionDef) and node.name == name)
    assert ast.dump(old, include_attributes=False) == ast.dump(new, include_attributes=False), name
records = c.decode(before[paths[1]]['base64']).decode()
needle = "    current_sources.update(selected['after'])\n"
replacement = needle + '''    finished_selector = selector_load('finish-proposals.json.gz')
    assert finished_selector['producer'] == c.read(Q + 'finish.py')
    for path, item in finished_selector['before'].items():
        if path in current_sources:
            assert current_sources[path] == item, path
        else:
            assert path == Q + 'partition_storage.py'
            assert selector_load('partition-copy.json')['reader'] == item
    current_sources.update(finished_selector['after'])
'''
assert records.count(needle) == 1
records = records.replace(needle, replacement, 1)
records = records.replace("closure = selector_load('closure.json')",
                          "closure = selector_load('closure-final.json')", 1)
needle = "    copy = selector_load('partition-copy.json')\n"
replacement = '''    history = selector_load('history-review.json')
    assert history['result'] == 'PASS' and history['denials'] == 4
    assert history['actual_payload_guard_red'] == 1
''' + needle
assert records.count(needle) == 1
records = records.replace(needle, replacement, 1)
needle = "                storage_denials=10, whole_hash_producer_red=2,\n"
assert records.count(needle) == 1
records = records.replace(needle, needle + "                historical_metadata_denials=4, historical_metadata_producer_red=1,\n", 1)
publisher = c.decode(before[paths[2]]['base64']).decode()
publisher = publisher.replace('type-values-selector/closure.json', 'type-values-selector/closure-final.json')
close_path = P + 'close_final.py'
close = (ROOT / (P + 'close_inputs.py')).read_text().replace('close_inputs.py', 'close_final.py')
close = close.replace("P + 'closure.json'", "P + 'closure-final.json'")
texts = {paths[0]: reader, paths[1]: records, paths[2]: publisher, close_path: close}
for path, source in texts.items():
    ast.parse(source, filename=path)
after = {path: dict(base64=c.encode(source.encode()), sha256=c.sha(source.encode()),
                   mode=before[path]['mode'] if path in before else 0o644)
         for path, source in texts.items()}
c.write_new(P + 'finish-proposals.json.gz', dict(before=before, after=after,
    producer=c.read(P + 'finish.py'), original_closure=c.read(P + 'closure.json'),
    rejected_output=c.read('.linkedspec-data/verification/type-values-selector-preflight.log'),
    scope='The first retained preflight rejects a changed metadata card in an older '
          'source capsule. Before-epoch resolution uses exact recorded versions only. '
          'The original byte-decoder/physical-guard ASTs are unchanged; current source '
          'verification still requires actual current bytes. A fresh final closure and '
          'getter denial/actual-producer-fault controls are required.'),
    packed=True)
assert c.unchanged(before) and not (ROOT / close_path).exists()
for path, item in after.items():
    (ROOT / path).write_bytes(c.decode(item['base64']))
    (ROOT / path).chmod(item['mode'])
print('Exact historical metadata getter added; current source/byte decoder checks preserved')
