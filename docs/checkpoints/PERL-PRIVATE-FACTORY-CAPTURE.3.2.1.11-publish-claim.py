"""Readonly Knowledge gate publication; --capture writes the bounded record once."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
for tail in ('review.py', 'evidence.py'):
    process = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly proof', tail, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS'
assert (review['cases'], review['assertions'], review['original_red'], review['original_controls']) == (20, 80, 16, 64)
assert review['fault_reds'] == [14, 2, 16] and len(evidence['rows']) == 2
completions = json.loads((ROOT / (PREFIX + 'outer-completions.json')).read_bytes())['rows']
assert len(completions) == 12 and sum(row['actual_returncode'] != 0 for row in completions) == 1
for row in completions:
    assert sha((ROOT / row['producer']).read_bytes()) == row['producer_sha256']
    assert sha((ROOT / row['report']).read_bytes()) == row['report_sha256']
    log = base64.b64decode(row['merged_log_base64'], validate=True)
    assert log
    if row['actual_returncode']:
        assert row['actual_tool_session'] == 58494 and b'AssertionError' in log
paths = set(review['input_metadata']) | set(evidence['inputs'])
paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if path.is_file())
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
    'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'} for path in sorted(paths)]
statement = ('Knowledge header list association is repaired: only empty-value keys own following block items; '
    'scalar and inline values close association, and malformed scalar answers remain visible to denial. '
    'Identical20-case/80-assertion public checker proof changes16 original REDs/64 controls to all GREEN. '
    'Three actual source controls fail14/2/16 with complete plans and exact restoration; two semantic '
    'evidence corruptions reject and restore. Full original1485 Markdown inputs/1349 facts are retained '
    'in a recoverable capsule; the current full gate passes with six planned header overlays and '
    'unchanged fact bodies. Original534 bindings/full123810-byte callback publication and actual '
    'readonly baseline are preserved at328b11c5. Book89 inputs/four render controls pass.')
scope = ('This is the existing Knowledge doctrine list-association boundary, its public generator/checker '
    'fixture and canonical selection. The full original scan bytes are capsule inputs; six current '
    'card overlays, exact current source identities and map are independently checked by the reader. '
    'Historical callback bindings are recovered from accepted Git without refreshing their native '
    'observations. Current reverify routes retain all prior header routes and original body prefixes. '
    'The first source-control producer fails because its third mutation reverses rather than disables '
    'the verdict, yielding14/2/34 failures; its source/full observations/actual outer1 remain immutable. '
    'A distinct producer changes that operator and output identity only, yielding14/2/16 and restored '
    'GREEN. Complete actual tool logs and native separate channels are retained. Two public valid '
    'block metadata cases reproduce missing evidence/reverify projection; P3 '
    'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12 owns the field contract and affected population after '
    'factory/pipeline, before TYPE-REFERENCE-BOOK. No complete YAML/field-type, new runtime, private '
    'parent or other-backend admission is claimed. The exact staged canonical receipt is the required '
    'landing boundary, separate from this focused retained measurement. No immutable toolchain or '
    'cross-version HTML identity is claimed.')
claim = {'name': 'knowledge-header-list-association', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; review.py, evidence.py and book-review.py have readonly defaults. Capture/population/run/fault/book/current/preservation writers are retired.',
        'granularity': 'Every20 named public case/header/native channel; identical80 assertion names/plans;16 original failures; three source faults and their14/2/16 distinguishing failures; two semantic corruption/restoration pairs; complete1485 original Markdown byte inputs/1349 facts and six exact current overlays;534 original bindings/full123810 publication;89 book inputs/four controls; two named metadata projection reproductions.',
        'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'The presence-only checker may admit detached list entries, hide malformed answers as nonfacts or reject valid scalar/list cards. Rehashed observations or headers may appear verified while carrying wrong semantic verdicts. Generated and rendered outputs may silently omit required teaching.',
        'oracle': 'Original accepted Git source and full publication, complete retained byte capsule and independent header parser; unchanged public generator/checker fixture including both original malformed headers; complete source mutations and TAP plans; current full gate channels; actual source/include/render controls and deeper composed-reader denials.',
        'red_control': 'Original unchanged80 assertion test observes16 failures from eight admitted malformed headers while64 controls pass. Source regressions fail14/2/16 and restore all80. First mistaken reversed-verdict control and its34 failures are retained. Forged native acceptance and an orphan current header with its immediate input hash amended each receive the named semantic denial, then exact restoration PASS. Missing SUMMARY, both removed workflow markers despite exit0 and missing recursive include produce four rendered controls. Valid block metadata omission remains reproduced and separately owned.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded publication', len(raw))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact readonly publication'
print('Knowledge gate publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
