"""Falsify the exact historical getter without altering current source reads."""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import partition_storage as storage

P = storage.P
path = 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md'
item = storage.load('docs-proposals.json.gz')['before'][path]
reader = c.read(P + 'partition_storage.py')
source = c.decode(reader['base64'])
needle = b"            assert c.sha(c.decode(item['base64'])) == item['sha256']\n"
assert source.count(needle) == 1
fault = source.replace(needle, b'', 1)
c.write_new(P + 'history-inputs.json.gz', dict(
    producer=c.read(P + 'history_controls.py'), reader=reader, fixture={path: item},
    fault=dict(base64=c.encode(fault), sha256=c.sha(fault)),
    scope='Actual getter source, captured before-card bytes and explicit path/hash/mode '
          'oracle precede all controls. Only supplied namespaces are mutated.'),
    packed=True)
results = []
for name, code in (('healthy', source), ('payload-guard-bypass', fault), ('restored', source)):
    namespace = dict(__name__='history_control', __file__=str(ROOT / (P + 'partition_storage.py')))
    exec(compile(code, P + 'partition_storage.py', 'exec'), namespace)
    namespace['_history'] = {path: [dict(item)]}
    wanted = {key: item[key] for key in ('sha256', 'mode')}
    assert namespace['historical_version'](path, wanted) == item
    assert namespace['historical_version'](path, dict(wanted, sha256='0' * 64)) is None
    assert namespace['historical_version'](path, dict(wanted, mode=0o600)) is None
    assert namespace['historical_version']('docs/knowledge/copied-before-card.md', wanted) is None
    namespace['_history'][path][0]['base64'] = c.encode(c.decode(item['base64']) + b'!')
    rejected = False
    try:
        actual = namespace['historical_version'](path, wanted)
        wrong = actual is not None and c.sha(c.decode(actual['base64'])) != wanted['sha256']
    except AssertionError:
        rejected, wrong = True, False
    results.append(dict(name=name, source_sha256=c.sha(code),
                        wrong_hash_rejected=True, wrong_mode_rejected=True, copied_path_rejected=True,
                        changed_payload_rejected=rejected, unexpected_wrong_payload=wrong))
assert results[0]['changed_payload_rejected'] and results[2]['changed_payload_rejected']
assert results[1]['unexpected_wrong_payload']
assert c.read(path) != item  # Current verification still sees the actual updated card.
assert c.read(P + 'partition_storage.py') == reader
c.write_new(P + 'history-run.json.gz', dict(results=results,
    producer=c.read(P + 'history_controls.py'), reader=reader), packed=True)
c.write_new(P + 'history-review.json', dict(result='PASS', denials=4,
    actual_payload_guard_red=1, current_worktree_read_preserved=True, restoration=True))
print('Historical getter PASS:4 denials, actual payload-guard RED1 and restoration; current reads intact')
