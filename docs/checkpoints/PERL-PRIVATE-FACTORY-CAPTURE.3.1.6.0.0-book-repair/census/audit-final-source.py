"""Narrow the historical inverse to the public checker actually audited."""
import base64
import gzip
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
AUDITOR = 'tests/language-readiness/verify_objectives.py'
PUBLIC = 'tools/check_public_aggregate_selector_surface.py'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--apply'])
failed = json.loads(gzip.decompress((HERE.parent / 'before.json.gz').read_bytes()))
original = base64.b64decode(failed['inputs'][AUDITOR]['data'], validate=True)
draft = json.loads(gzip.decompress((HERE / 'audit-proof.json.gz').read_bytes()))
draft_source = base64.b64decode(draft['inputs'][AUDITOR]['data'], validate=True)
function = '''def verify_selector_governance_evolution(source, contents, historical_hash):
    require(source == "tools/check_public_aggregate_selector_surface.py",
            f"unapproved selector governance source: {source}")
    before = b"EXPECTED_CLASSIFIED_REFERENCE_COUNT = 36\\n"
    after = b"EXPECTED_CLASSIFIED_REFERENCE_COUNT = 40\\n"
    require(contents.count(after) == 1,
            f"selector governance registration mismatch: {source}")
    normalized = contents.replace(after, before, 1)
    require(digest(normalized) == historical_hash,
            f"unreviewed selector governance drift: {source}")
    return {"path": source, "historical": historical_hash,
            "current": digest(contents), "owner": SCALAR_RECEIVER_COPY_OWNER,
            "scope": "exact public census inverse; every original checker byte preserved"}


'''.encode()
dispatch = '''            if source == "tools/check_public_aggregate_selector_surface.py":
                governance_updates.append(verify_selector_governance_evolution(
                    source, read(source), row["sha256"]))
                continue
'''.encode()
controls = '''        elif source == "tools/check_public_aggregate_selector_surface.py":
            line = b"EXPECTED_CLASSIFIED_REFERENCE_COUNT = 40\\n"
            altered = (
                current + b"# unreviewed edit\\n",
                current.replace(line, b"", 1),
                current.replace(line, line * 2, 1),
                current.replace(line, b"EXPECTED_CLASSIFIED_REFERENCE_COUNT = 39\\n", 1),
                current.replace(b"reference_count = check_exact_references(paths)", b"reference_count = 0", 1),
                current.replace(b"EXPECTED_PUBLIC_FILE_COUNT = 70", b"EXPECTED_PUBLIC_FILE_COUNT = 69", 1),
            )
            verify = verify_selector_governance_evolution
            reasons = ("selector governance registration mismatch:", "unreviewed selector governance drift:")
'''.encode()
expected = original
for old,new in (
 (b'def signature_subtest(contents):\n', function + b'def signature_subtest(contents):\n'),
 (b'            require(source.startswith("docs/") and source.endswith(".md"),\n', dispatch + b'            require(source.startswith("docs/") and source.endswith(".md"),\n'),
 (b'        else:\n            raise ValueError(f"unapproved governance control source: {source}")\n', controls + b'        else:\n            raise ValueError(f"unapproved governance control source: {source}")\n'),
):
    assert expected.count(old) == 1
    expected = expected.replace(old,new,1)
compile(expected, AUDITOR, 'exec')
target = HERE / 'audit-final-source.json'
if sys.argv[1:]:
    assert not target.exists() and (ROOT / AUDITOR).read_bytes() == draft_source, 'one-shot narrowing'
    (ROOT / AUDITOR).write_bytes(expected)
    target.write_text(json.dumps({'producer_sha256':digest(Path(__file__).read_bytes()),
        'original_sha256':digest(original),'draft_sha256':digest(draft_source),'final_sha256':digest(expected),
        'scope':'Discard unused scanner historical inverse/control branches. The historical producer reads183 inputs; the earlier192 capsule added nine supplementary retained files. Only public checker evolution is encountered by the historical auditor. Original failed wrapper and captured actual183/80 result remain immutable; scanner registry has separate17/27/51 proof.'},indent=2)+'\n')
else:
    record = json.loads(target.read_bytes())
    assert record['producer_sha256'] == digest(Path(__file__).read_bytes())
    assert record['original_sha256'] == digest(original) and record['draft_sha256'] == digest(draft_source)
    assert record['final_sha256'] == digest(expected) and (ROOT / AUDITOR).read_bytes() == expected
print('Final historical source PASS: public checker constant-only inverse and six controls; unused scanner branches removed')
