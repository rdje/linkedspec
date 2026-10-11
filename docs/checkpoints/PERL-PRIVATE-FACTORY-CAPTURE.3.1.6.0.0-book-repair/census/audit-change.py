"""Apply once, or verify, exact owner-bound selector checker historical inverses."""
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
SCANNER = 'tools/check_executable_aggregate_selector_sources.py'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--apply'])
failed = json.loads(gzip.decompress((HERE.parent / 'before.json.gz').read_bytes()))
original = base64.b64decode(failed['inputs'][AUDITOR]['data'], validate=True)
scanner = json.loads(gzip.decompress((HERE / 'scanner-before.json.gz').read_bytes()))
entries = sorted((p,r['sha256']) for p,r in scanner['inputs'].items())
constants = ('SELECTOR_GOVERNANCE_SOURCES = ' + repr((PUBLIC,SCANNER)) + '\n'
             'SELECTOR_DIAGNOSTIC_ENTRIES = ' + repr(tuple(entries)) + '\n'
             'SELECTOR_DIAGNOSTIC_INSERTION = b"    # Exact negative/private synthetic fixtures; any byte edit or copied path rejects.\\n"\n'
             'for _path, _sha in SELECTOR_DIAGNOSTIC_ENTRIES:\n'
             '    SELECTOR_DIAGNOSTIC_INSERTION += ("    " + repr(_path) + ":\\n        " + repr(_sha) + ",\\n").encode()\n\n').encode()
function = '''def verify_selector_governance_evolution(source, contents, historical_hash):
    require(source in SELECTOR_GOVERNANCE_SOURCES,
            f"unapproved selector governance source: {source}")
    if source == SELECTOR_GOVERNANCE_SOURCES[0]:
        before = b"EXPECTED_CLASSIFIED_REFERENCE_COUNT = 36\\n"
        after = b"EXPECTED_CLASSIFIED_REFERENCE_COUNT = 40\\n"
        require(contents.count(after) == 1,
                f"selector governance registration mismatch: {source}")
        normalized = contents.replace(after, before, 1)
    else:
        block = SELECTOR_DIAGNOSTIC_INSERTION + b"}\\nSELECTOR = re.compile("
        require(contents.count(block) == 1,
                f"selector governance registration mismatch: {source}")
        normalized = contents.replace(block, b"}\\nSELECTOR = re.compile(", 1)
    require(digest(normalized) == historical_hash,
            f"unreviewed selector governance drift: {source}")
    return {"path": source, "historical": historical_hash,
            "current": digest(contents), "owner": SCALAR_RECEIVER_COPY_OWNER,
            "scope": "exact public census or diagnostic registry inverse; every original checker byte preserved"}


'''.encode()
dispatch = '''            if source in SELECTOR_GOVERNANCE_SOURCES:
                governance_updates.append(verify_selector_governance_evolution(
                    source, read(source), row["sha256"]))
                continue
'''.encode()
controls = '''        elif source == SELECTOR_GOVERNANCE_SOURCES[0]:
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
        elif source == SELECTOR_GOVERNANCE_SOURCES[1]:
            altered = (
                current + b"# unreviewed edit\\n",
                current.replace(SELECTOR_DIAGNOSTIC_INSERTION, b"", 1),
                current.replace(SELECTOR_DIAGNOSTIC_INSERTION, SELECTOR_DIAGNOSTIC_INSERTION * 2, 1),
                current.replace(b"hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == historical_digest", b"True", 1),
            )
            for path, sha in SELECTOR_DIAGNOSTIC_ENTRIES:
                entry = ("    " + repr(path) + ":\\n        " + repr(sha) + ",\\n").encode()
                altered += (current.replace(entry, b"", 1),
                            current.replace(entry, entry * 2, 1),
                            current.replace(entry, entry.replace(sha.encode(), b"0" * 64), 1))
            verify = verify_selector_governance_evolution
            reasons = ("selector governance registration mismatch:", "unreviewed selector governance drift:")
'''.encode()
expected = original
for old,new in (
    (b'PERL_STORAGE_REPLACEMENTS = (\n', constants + b'PERL_STORAGE_REPLACEMENTS = (\n'),
    (b'def signature_subtest(contents):\n', function + b'def signature_subtest(contents):\n'),
    (b'            require(source.startswith("docs/") and source.endswith(".md"),\n', dispatch + b'            require(source.startswith("docs/") and source.endswith(".md"),\n'),
    (b'        else:\n            raise ValueError(f"unapproved governance control source: {source}")\n', controls + b'        else:\n            raise ValueError(f"unapproved governance control source: {source}")\n'),
):
    assert expected.count(old) == 1, 'auditor evolution anchor'
    expected = expected.replace(old,new,1)
compile(expected, AUDITOR, 'exec')
target = HERE / 'audit-before.json.gz'
if sys.argv[1:]:
    assert (ROOT / AUDITOR).read_bytes() == original and not target.exists(), 'one-shot auditor evolution'
    logroot = ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0'
    packet = {'producer_sha256': digest(Path(__file__).read_bytes()),
              'original_base64': base64.b64encode(original).decode(), 'original_sha256': digest(original),
              'actual_exit_code': 1,
              'channels': {name: base64.b64encode((logroot / ('census-historical-audit.' + name + '.log')).read_bytes()).decode() for name in ('stdout','stderr')},
              'scope': 'Original auditor and complete redirected failed historical proof channels. Exit1 transcribed from actual tool completion, not original transport envelope. Exact source additions are reconstructed by this retained producer.'}
    assert b'current executable evidence drift: tools/check_public_aggregate_selector_surface.py' in base64.b64decode(packet['channels']['stderr'])
    target.write_bytes(gzip.compress((json.dumps(packet,indent=2)+'\n').encode(),mtime=0))
    (ROOT / AUDITOR).write_bytes(expected)
else:
    packet = json.loads(gzip.decompress(target.read_bytes()))
    assert packet['producer_sha256'] == digest(Path(__file__).read_bytes())
    assert base64.b64decode(packet['original_base64']) == original
    assert (ROOT / AUDITOR).read_bytes() == expected, 'foreign auditor source change'
print('Exact historical selector evolution source PASS: two complete-hash inverses; explicit reason-sensitive source controls')
