"""Reject corrupt/truncated/reordered chunks and falsify the actual whole-stream check."""
import gzip
import json
import os
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import partition_storage as storage

P = storage.P
seed = b'original\x00byte-stream\xffpayload'
index_path = P + 'parts/fixture/index.json'
reader = c.read(P + 'partition_storage.py')
source = c.decode(reader['base64'])
needle = b"    assert total == index['size'] and hashlib.sha256(data).hexdigest() == index['sha256']\n"
assert source.count(needle) == 1
fault = source.replace(needle, b"    assert total == index['size']\n", 1)
cases = ('healthy', 'corrupt', 'truncated', 'reordered', 'missing', 'mode',
         'changed-payload', 'wrong-whole-hash', 'wrong-size', 'traversal', 'symlink')
c.write_new(P + 'partition-controls-inputs.json.gz', dict(
    producer=c.read(P + 'partition_controls.py'), reader=reader, seed_base64=c.encode(seed),
    fault=dict(base64=c.encode(fault), sha256=c.sha(fault)), cases=cases,
    scope='Fixed independent byte seed and actual loader source precede the supplied '
          'context controls; the source fault removes only its final whole-stream hash check.'),
    packed=True)


def write_part(root, path, payload):
    target = root / path
    target.parent.mkdir(parents=True, exist_ok=True)
    raw = gzip.compress((json.dumps(dict(version=1, payload_base64=c.encode(payload)),
                                   sort_keys=True) + '\n').encode(), mtime=0)
    target.write_bytes(raw)
    target.chmod(0o644)
    return dict(path=path, file_sha256=c.sha(raw), payload_sha256=c.sha(payload),
                size=len(payload), mode=0o644)


results = []
for name, code in (('healthy', source), ('whole-hash-bypass', fault), ('restored', source)):
    namespace = dict(__name__='partition_control', __file__=str(ROOT / (P + 'partition_storage.py')))
    exec(compile(code, P + 'partition_storage.py', 'exec'), namespace)
    rows = []
    for case in cases:
        with tempfile.TemporaryDirectory(prefix='partition-control-', dir=os.environ['TMPDIR']) as directory:
            root = Path(directory)
            assert root.stat().st_dev == ROOT.stat().st_dev
            parts = []
            for number, offset in enumerate(range(0, len(seed), 8)):
                part = write_part(root, str(Path(index_path).parent / f'part-{number}.json.gz'),
                                  seed[offset:offset + 8])
                parts.append(dict(part, offset=offset, number=number))
            index = dict(version=1, logical_path='fixture-original', sha256=c.sha(seed),
                         size=len(seed), mode=0o644, parts=parts)
            first = root / parts[0]['path']
            if case == 'corrupt':
                raw = first.read_bytes()
                first.write_bytes(raw[:12] + bytes([raw[12] ^ 1]) + raw[13:])
            elif case == 'truncated':
                first.write_bytes(first.read_bytes()[:-1])
            elif case == 'reordered':
                parts[0], parts[1] = parts[1], parts[0]
            elif case == 'missing':
                first.unlink()
            elif case == 'mode':
                first.chmod(0o600)
            elif case == 'changed-payload':
                replacement = write_part(root, parts[0]['path'], b'X' + seed[1:8])
                parts[0].update(replacement)
            elif case == 'wrong-whole-hash':
                index['sha256'] = '0' * 64
            elif case == 'wrong-size':
                index['size'] += 1
            elif case == 'traversal':
                parts[0]['path'] = '../outside.json.gz'
            elif case == 'symlink':
                copy = first.with_name('same-bytes-copy.json.gz')
                copy.write_bytes(first.read_bytes())
                copy.chmod(0o644)
                first.unlink()
                first.symlink_to(copy.name)
            (root / index_path).write_text(json.dumps(index))
            try:
                value, mode, _ = namespace['read_partition'](index_path, root)
                accepted = True
                if case == 'healthy':
                    assert value == seed and mode == 0o644
            except (AssertionError, OSError, ValueError, KeyError):
                accepted = False
            rows.append(dict(case=case, accepted=accepted, expected=case == 'healthy'))
    unexpected = [row['case'] for row in rows if row['accepted'] != row['expected']]
    results.append(dict(name=name, source_sha256=c.sha(code), rows=rows, unexpected=unexpected))
assert c.read(P + 'partition_storage.py') == reader
c.write_new(P + 'partition-controls.json', dict(results=results,
    producer=c.read(P + 'partition_controls.py'), reader=reader))
assert not results[0]['unexpected'] and not results[2]['unexpected']
assert results[1]['unexpected'] == ['changed-payload', 'wrong-whole-hash']
c.write_new(P + 'partition-controls-review.json', dict(result='PASS', healthy_controls=1,
    rejected_controls=len(cases) - 1, actual_whole_hash_fault=2, restoration=True,
    scope='Corruption, truncation, order, missing parts, mode, internally consistent '
          'changed payload, wrong whole checksum/size, traversal and identical-byte '
          'symlink controls reject. The actual whole-check bypass admits two wrong '
          'streams; the independent byte oracle rejects that producer and restoration passes.'))
print('Partition controls PASS:10 denials, actual whole-hash fault2 and exact restoration')
