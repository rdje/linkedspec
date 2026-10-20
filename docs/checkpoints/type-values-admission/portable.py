"""Normalize derived display metadata while preserving the complete original epoch."""
import ast
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

ADMISSION = 'docs/checkpoints/type-values-admission/'
PREFIX = 'docs/checkpoints/type-evaluated-values/'
assert (ROOT / '.linkedspec-data/verification/type-values-admission-readonly.status').read_text().strip() == '0'
assert (ROOT / '.linkedspec-data/verification/type-values-ordinary-phase0.status').read_text().strip() == '0'
preserved = json.loads(gzip.decompress((ROOT / (ADMISSION + 'preservation.json.gz')).read_bytes()))
assert c.read(c.CLAIM) == preserved['original_claim']
for path, item in preserved['inputs'].items():
    assert all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')), path
review_path = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-focused-final-review.json'
entrypoint = PREFIX + 'publish.py'
readme_path = PREFIX + 'README.md'
before = {path: c.read(path) for path in (review_path, entrypoint, readme_path)}
for path, item in before.items():
    if path in preserved['before']:
        assert item == preserved['before'][path], path
    else:
        assert all(item[key] == preserved['inputs'][path][key] for key in ('sha256', 'mode')), path
display = json.loads(c.decode(before[review_path]['base64']))
relative = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
assert display['actual']['loaded_method_lowering'].endswith('/' + relative)
display['actual']['loaded_method_lowering'] = relative
record_source = (ROOT / (PREFIX + 'phase0_records.py')).read_text()
old = "    assert record['actual'] == actual and record['result'] == 'PASS'"
new = """    relative = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
    tail = Path(relative).parts
    assert Path(actual['loaded_method_lowering']).parts[-len(tail):] == tail
    display = dict(actual, loaded_method_lowering=relative)
    assert record['actual'] == display and record['result'] == 'PASS'"""
assert record_source.count(old) == 1
record_source = record_source.replace(old, new, 1)
old = '    assert c.unchanged(target)\n'
new = """    admission = json.loads(gzip.decompress(
        (c.ROOT / 'docs/checkpoints/type-values-admission/portable-proposals.json.gz').read_bytes()))
    path = c.PREFIX + 'README.md'
    assert target[path] == admission['before'][path]
    target[path] = admission['after'][path]
    assert c.unchanged(target)
"""
assert record_source.count(old) == 1
record_source = record_source.replace(old, new, 1)
review_source = (ROOT / (PREFIX + 'review_phase0.py')).read_text()
assert review_source.count('import phase0_records\n') == 1
review_source = review_source.replace('import phase0_records\n',
    'import phase0_records_portable as phase0_records\n', 1)
publisher_source = (ROOT / (PREFIX + 'publish_phase0.py')).read_text()
assert publisher_source.count('import review_phase0 as review') == 1
assert publisher_source.count('import phase0_records as records') == 1
publisher_source = publisher_source.replace('import json\n', 'import gzip\nimport json\n', 1)
publisher_source = publisher_source.replace('import review_phase0 as review', 'import review_portable as review', 1)
publisher_source = publisher_source.replace('import phase0_records as records', 'import phase0_records_portable as records', 1)
publisher_source = publisher_source.replace('publication-phase0', 'publication-portable')
publisher_source = publisher_source.replace("c.PREFIX + 'publish_phase0.py'", "c.PREFIX + 'publish_portable.py'")
publisher_source = publisher_source.replace("c.PREFIX + 'review_phase0.py'", "c.PREFIX + 'review_portable.py'")
old = "    paths.update(('KNOWLEDGE_MAP.md', c.OLD_CLAIM,"
new = """    paths.update('docs/checkpoints/type-values-admission/' + name for name in (
        'preservation.json.gz', 'baseline.json', 'canonical1.json.gz',
        'canonical1-candidate.patch.gz', 'ordinary-phase0.json.gz',
        'portable-proposals.json.gz', 'portable.py', 'archive.py'))
    paths.update(('KNOWLEDGE_MAP.md', c.OLD_CLAIM,"""
assert publisher_source.count(old) == 1
publisher_source = publisher_source.replace(old, new, 1)
old = "        assert c.read(c.CLAIM) == records.load('preservation.json.gz')['original_claim']"
new = """        preserved = json.loads(gzip.decompress(
            (c.ROOT / 'docs/checkpoints/type-values-admission/preservation.json.gz').read_bytes()))
        assert c.read(c.CLAIM) == preserved['original_claim']"""
assert publisher_source.count(old) == 1
publisher_source = publisher_source.replace(old, new, 1)
texts = {
    PREFIX + 'phase0_records_portable.py': record_source,
    PREFIX + 'review_portable.py': review_source,
    PREFIX + 'publish_portable.py': publisher_source,
    entrypoint: '"""Stable readonly publication entrypoint; --capture is one-shot."""\nfrom publish_portable import main\n\nif __name__ == "__main__":\n    main()\n',
}
readme = c.decode(before[readme_path]['base64']).decode()
old = 'publication-phase0.json is the current receipt. No historical\nGit identity is invented for the uncommitted draft.'
new = ('publication-phase0.json retains the third draft; publication-portable.json\n'
       'is the current receipt. The admission capsule preserves the whole636-input\n'
       'draft, its actual readonly baseline, the first failed canonical candidate\n'
       'and the complete wrapped ordinary Phase0 result. Only derived loaded-module\n'
       'display metadata becomes repository-relative; its raw observation remains\n'
       'recoverable. No historical Git identity is invented for uncommitted drafts.')
assert readme.count(old) == 1
for path, source in texts.items():
    ast.parse(source, filename=path)
    if path != entrypoint:
        assert not (ROOT / path).exists()
texts[readme_path] = readme.replace(old, new, 1)
after = {path: dict(base64=c.encode(source.encode()), sha256=c.sha(source.encode()),
    mode=before[path]['mode'] if path in before else 0o644) for path, source in texts.items()}
raw = (json.dumps(display, sort_keys=True, indent=1) + '\n').encode()
after[review_path] = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=before[review_path]['mode'])
c.write_new(ADMISSION + 'portable-proposals.json.gz', dict(before=before, after=after,
    producer=c.read(ADMISSION + 'portable.py'),
    original_records=c.read(PREFIX + 'phase0_records.py'),
    original_review=c.read(PREFIX + 'review_phase0.py'),
    original_publisher=c.read(PREFIX + 'publish_phase0.py'),
    scope='Only derived display metadata becomes repository-relative. The original absolute '
          'observation remains encoded in the immutable focused run and in the whole636 draft '
          'preservation. Separate portable reader/publisher modules retain every original actor. '
          'The full ordinary prerequisite completes before writes; no warning gate, runtime, '
          'test value/golden or observation is changed.'), packed=True)
assert c.unchanged(before)
for path, item in after.items():
    target = ROOT / path
    target.write_bytes(c.decode(item['base64']))
    target.chmod(item['mode'])
    assert c.read(path) == item
print('Derived loaded-module display is relative; original raw path and complete636 epoch remain intact')
