"""Review and install the exact Phase0 inverse; retain every before/proposed byte first."""
import ast
import difflib
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-signature/'
TABLE = 'tests/language-readiness/evaluated-value-regression-evolution.json'
AUDITOR = 'tests/language-readiness/verify_objectives.py'
PROOF = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
SOURCE = 't/phase0_regression.t'
assert (ROOT / '.linkedspec-data/verification/type-values-signature-readonly.status').read_text().strip() == '0'
preserved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
assert c.read(c.CLAIM) == preserved['original_claim']
for path, identity in preserved['inputs'].items():
    assert all(c.read(path)[key] == identity[key] for key in ('sha256', 'mode')), path
assert all(c.read(path) == item for path, item in preserved['before'].items())
baseline = json.loads((ROOT / (P + 'baseline.json')).read_bytes())
assert baseline['returncode'] == 0 and baseline['claim'] == preserved['original_claim']
old_run = c.run(['git', 'show', c.BASE + ':' + SOURCE])
assert old_run['returncode'] == 0
before = c.decode(old_run['stdout_base64'])
after = (ROOT / SOURCE).read_bytes()
original_namespace = dict(__name__='original_signature_auditor', __file__=str(ROOT / AUDITOR))
exec(compile(c.decode(preserved['before'][AUDITOR]['base64']), AUDITOR, 'exec'), original_namespace)
historical_source = original_namespace['git']('show', original_namespace['SIGNATURE_BEFORE'] + ':' + SOURCE)
historical_hash = c.sha(historical_source)
try:
    original_namespace['verify_signature_regression_evolution'](SOURCE, after, historical_hash)
except ValueError as error:
    original_red = str(error)
    assert original_red == 'unreviewed signature-regression drift: ' + SOURCE
else:
    raise AssertionError('Original historical auditor must reproduce the actual canonical failure')
old_lines, new_lines = before.splitlines(keepends=True), after.splitlines(keepends=True)
hunks = []
for group in difflib.SequenceMatcher(None, old_lines, new_lines, autojunk=False).get_grouped_opcodes(3):
    old = b''.join(old_lines[group[0][1]:group[-1][2]])
    new = b''.join(new_lines[group[0][3]:group[-1][4]])
    assert old and new and old != new
    assert before.count(old) == after.count(new) == 1
    hunks.append(dict(before=old.decode(), after=new.decode()))
assert hunks
forward, inverse = before, after
for row in hunks:
    old, new = row['before'].encode(), row['after'].encode()
    assert forward.count(old) == inverse.count(new) == 1
    forward = forward.replace(old, new, 1)
    inverse = inverse.replace(new, old, 1)
assert forward == after and inverse == before
table = dict(version=1, owner=c.OWNER, source=SOURCE, before_revision=c.BASE,
             before_sha256=c.sha(before), after_sha256=c.sha(after), hunks=hunks)
table_raw = (json.dumps(table, sort_keys=True, indent=1) + '\n').encode()
auditor = c.decode(preserved['before'][AUDITOR]['base64']).decode()
anchor = 'COMPILER_SCAN_BEFORE = '
assert auditor.count(anchor) == 1
constants = (f'EVALUATED_VALUES_OWNER = {c.OWNER!r}\n'
             f'EVALUATED_VALUES_TABLE = {TABLE!r}\n'
             f'EVALUATED_VALUES_TABLE_SHA256 = {c.sha(table_raw)!r}\n'
             f'EVALUATED_VALUES_BEFORE = {c.BASE!r}\n')
auditor = auditor.replace(anchor, constants + anchor, 1)
anchor = '\ndef verify_signature_regression_evolution(source, contents, historical_hash):\n'
inverse_source = '''
def restore_evaluated_value_regressions(source, contents):
    raw = read_relative(EVALUATED_VALUES_TABLE)
    require(digest(raw) == EVALUATED_VALUES_TABLE_SHA256,
            "evaluated-value inverse table identity mismatch: " + source)
    table = json.loads(raw)
    require(table["version"] == 1 and table["owner"] == EVALUATED_VALUES_OWNER and
            table["source"] == source == "t/phase0_regression.t" and
            table["before_revision"] == EVALUATED_VALUES_BEFORE,
            "evaluated-value inverse owner mismatch: " + source)
    before = git("show", f"{EVALUATED_VALUES_BEFORE}:{source}")
    require(digest(before) == table["before_sha256"],
            "evaluated-value inverse base mismatch: " + source)
    rebuilt = before
    for row in table["hunks"]:
        old, new = row["before"].encode(), row["after"].encode()
        require(old and new and old != new and rebuilt.count(old) == 1,
                "evaluated-value inverse reconstruction mismatch: " + source)
        rebuilt = rebuilt.replace(old, new, 1)
    require(digest(rebuilt) == table["after_sha256"],
            "evaluated-value inverse reconstruction mismatch: " + source)
    for row in table["hunks"]:
        old, new = row["before"].encode(), row["after"].encode()
        require(contents.count(new) == 1,
                "evaluated-value regression registration mismatch: " + source)
        contents = contents.replace(new, old, 1)
    return contents

'''
assert auditor.count(anchor) == 1
auditor = auditor.replace(anchor, '\n' + inverse_source + anchor, 1)
anchor = '    current_hash = digest(contents)\n    contents = restore_compiler_scanner_mock(source, contents)'
replacement = ('    current_hash = digest(contents)\n'
               '    contents = restore_evaluated_value_regressions(source, contents)\n'
               '    contents = restore_compiler_scanner_mock(source, contents)')
assert auditor.count(anchor) == 1
auditor = auditor.replace(anchor, replacement, 1)
anchor = '            "compiler_membership_owner": COMPILER_MEMBERSHIP_OWNER,'
replacement = ('            "evaluated_values_owner": EVALUATED_VALUES_OWNER,\n'
               '            "evaluated_values_input": EVALUATED_VALUES_TABLE,\n'
               '            "evaluated_values_table_sha256": EVALUATED_VALUES_TABLE_SHA256,\n'
               '            "evaluated_values_before_revision": EVALUATED_VALUES_BEFORE,\n' + anchor)
assert auditor.count(anchor) == 1
auditor = auditor.replace(anchor, replacement, 1)
anchor = '"scope": "exact committed compiler-scanner mock-entry replacement,'
replacement = '"scope": "exact owner-bound evaluated-value test inverse, committed compiler-scanner mock-entry replacement,'
assert auditor.count(anchor) == 1
auditor = auditor.replace(anchor, replacement, 1)
anchor = '            verify = verify_signature_regression_evolution\n'
replacement = '''            inverse_table = json.loads(read_relative(EVALUATED_VALUES_TABLE))
            for row in inverse_table["hunks"]:
                fragment = row["after"].encode()
                require(current.count(fragment) == 1,
                        "evaluated-value control registration mismatch: " + source)
                changed = bytes([fragment[0] ^ 1]) + fragment[1:]
                altered += (current.replace(fragment, b"", 1),
                            current.replace(fragment, fragment * 2, 1),
                            current.replace(fragment, changed, 1))
''' + anchor
assert auditor.count(anchor) == 1
auditor = auditor.replace(anchor, replacement, 1)
anchor = '                       "boundary recurrence registration mismatch:", "compiler scanner mock registration mismatch:")'
replacement = ('                       "boundary recurrence registration mismatch:", "compiler scanner mock registration mismatch:",\n'
               '                       "evaluated-value regression registration mismatch:")')
assert auditor.count(anchor) == 1
auditor = auditor.replace(anchor, replacement, 1)
proof = c.decode(preserved['before'][PROOF]['base64']).decode()
anchor = '                   "docs/language-readiness/objective-reconciliation.md"))'
replacement = ('                   "docs/language-readiness/objective-reconciliation.md",\n'
               '                   audit.EVALUATED_VALUES_TABLE))')
assert proof.count(anchor) == 1
proof = proof.replace(anchor, replacement, 1)
ast.parse(auditor, filename=AUDITOR)
ast.parse(proof, filename=PROOF)
after_items = {TABLE: dict(base64=c.encode(table_raw), sha256=c.sha(table_raw), mode=0o644)}
for path, value in ((AUDITOR, auditor), (PROOF, proof)):
    raw = value.encode()
    after_items[path] = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=preserved['before'][path]['mode'])
assert not (ROOT / TABLE).exists()
c.write_new(P + 'proposals.json.gz', dict(producer=c.read(P + 'apply.py'),
    before={path: preserved['before'][path] for path in (AUDITOR, PROOF)}, after=after_items,
    phase0_before_command=old_run, phase0_after=c.read(SOURCE), hunks=len(hunks),
    original_verifier_red=original_red,
    historical_source=dict(revision=original_namespace['SIGNATURE_BEFORE'],
                           base64=c.encode(historical_source), sha256=historical_hash),
    scope='Exact reviewed c053-to-current Phase0 delta. Hunk fragments reconstruct both complete '
          'files and retain every unrelated current byte for the existing full historical hash '
          'check. Original signature/metadata/scanner/boundary controls remain; three actual '
          'input denials per new fragment are additional. The recurring recovery instrument '
          'retains the newly consumed table. Historical hashes/logs are unchanged.'), packed=True)
for path, item in after_items.items():
    target = ROOT / path
    target.write_bytes(c.decode(item['base64']))
    target.chmod(item['mode'])
    assert c.read(path) == item
print('Installed exact Phase0 inverse:', len(hunks), 'reviewed fragments; before/after reconstruct byte-for-byte')
