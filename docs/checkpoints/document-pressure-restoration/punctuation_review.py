"""Verify the retained public evidence for the punctuation assertion repair."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import sys

from book_review import Visible, normal

HERE = Path(__file__).parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(ROOT / 'tools'))


def decode(row):
    assert set(row) == {'base64', 'sha256'}
    raw = base64.b64decode(row['base64'], validate=True)
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'punctuation packet identity'
    return raw


def review():
    record = json.loads(gzip.decompress((HERE / 'punctuation-intake.json.gz').read_bytes()))
    assert record['schema_version'] == 1
    assert record['owner'] == 'TYPE-REFERENCE-BOOK.1.2.20.1.12'
    assert record['activation_commit'] == '0db5e9e87b7c1cfaf09936b9629974787038f5e3'
    for section in ('before', 'after', 'channels', 'producers'):
        for row in record[section].values():
            decode(row)
    from check_claim_verification import InputSnapshot, index_files
    files = index_files()
    snapshot = InputSnapshot(files)
    for name, expected in record['runtime_source_epoch'].items():
        raw = snapshot.read(name, record['activation_commit'])
        assert hashlib.sha256(raw).hexdigest() == expected, 'runtime source epoch drift'
    assert index_files() == files, 'index changed during punctuation epoch review'
    failure = record['canonical_failure']
    assert failure['path'] == 'docs/checkpoints/document-pressure-restoration/canonical-punctuation-failure.log.gz'
    raw = (ROOT / failure['path']).read_bytes()
    assert hashlib.sha256(raw).hexdigest() == failure['sha256']
    assert b"Failed test 'nonzero_arg_method keeps the existing zero-argument rejection'" in gzip.decompress(raw)
    channels = {name: decode(row) for name, row in record['channels'].items()}
    assert b'Failed 1/7 subtests' in channels['punctuation-before.log']
    assert b'Result: FAIL' in channels['punctuation-before.log']
    assert b'Files=2, Tests=14' in channels['punctuation-after.log']
    assert b'Result: PASS' in channels['punctuation-after.log']
    assert not channels['punctuation-probe.stderr']
    rows = [json.loads(line) for line in channels['punctuation-probe.jsonl'].splitlines()]
    assert len(rows) == 5
    observations = {(row['case'], row['route']): row for row in rows}
    expected = [None, None, '', 1]
    for route in ('native', 'fresh'):
        row = observations['healthy', route]
        assert row['value'] == expected and not row['error']
    assert not observations['healthy', 'native']['thrown']
    assert observations['healthy', 'fresh']['loaded'] == 1
    meta = observations['healthy', 'descriptor']['rewriter']
    for field in ('canonical_action_ir_fallback_count', 'raw_perl_dependency_count',
                  'unresolved_helper_count'):
        assert meta[field] == 0
    assert meta['canonical_action_ir_count'] > 0
    controls = {'rejected_alias_admitted': [1, None, 'B', 1],
                'valid_needle_removed': [None, None, '', None]}
    for name, value in controls.items():
        row = observations[name, 'native']
        assert row['value'] == value and value != expected
        assert not row['thrown'] and not row['error']
    lowering = [json.loads(line) for line in channels['punctuation-public-lowering.jsonl'].splitlines()]
    assert [row['lowered'] for row in lowering[:2]] == ['return undef', 'return undef']
    assert lowering[2]['lowered'] != 'return undef'
    book = record['book']
    before, after = (decode(record[section][book['path']]).decode() for section in ('before', 'after'))
    old, new = (book['edit'][key] for key in ('before', 'after'))
    assert before.count(old) == 1 and before.replace(old, new, 1) == after
    visible = Visible()
    visible.feed(decode(book['rendered']).decode())
    text = normal(''.join(visible.parts))
    assert 'With no authored needle' in text and 'return null before receiver effects' in text
    assert 'accepted generated source' in text
    return 'punctuation RED/GREEN, native/fresh null-before-effects, valid membership and distinguishing controls PASS; no runtime edits'


if __name__ == '__main__':
    print(review())
