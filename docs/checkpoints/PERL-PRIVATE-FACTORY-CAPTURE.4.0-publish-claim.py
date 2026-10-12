"""Readonly required FlowExpr publication; --capture writes one bounded claim."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.4.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for tail in ['review.py', 'evidence.py', 'validation.py']:
    process = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly required FlowExpr proof', tail, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
validation = json.loads((ROOT / (PREFIX + 'validation.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS'
assert review['paired_assertions'] == 1795 and review['original_red'] == 490 and review['original_controls'] == 1305
assert (review['consumer_suites'], review['consumer_inputs'], review['consumer_assertions']) == (77, 256, 19470)
assert (review['original_bindings'], review['original_publication_bytes']) == (218, 58582)
assert len(review['source_faults']) == 13 and len(evidence['controls']) == 5
completions = json.loads((ROOT / (PREFIX + 'completions.json')).read_bytes())
assert completions['producer_sha256'] == sha((ROOT / (PREFIX + 'completions.py')).read_bytes())
assert [(row['name'], row['actual_tool_session'], row['actual_returncode']) for row in completions['rows']] == [
 ('preserve', 39679, 0), ('observe', 7081, 0), ('before', 83992, 0), ('after', 80572, 0),
 ('observe-after', 43065, 0), ('faults', 38856, 0), ('consumers', 41833, 0), ('compat', 91242, 0),
 ('book', 7677, 0), ('knowledge', 30369, 0), ('review', 65530, 0), ('evidence', 66746, 0)]
for row in completions['rows']:
    assert sha((ROOT / row['source']).read_bytes()) == row['producer_sha256']
    assert sha((ROOT / row['artifact']).read_bytes()) == row['artifact_sha256']
    assert base64.b64decode(row['merged_log_base64'], validate=True).endswith(b'\n')
paths = set(review['inputs']) | set(evidence['inputs']) | set(validation['sources'])
paths.update(PREFIX + tail for tail in [
 'review.json', 'evidence.py', 'evidence.json', 'evidence-data.json.gz', 'validation.py', 'validation.json',
 'completions.py', 'completions.json', 'continuity-first.json', 'continuity.py', 'continuity.json', 'publish-claim.py'])
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
           'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'} for path in sorted(paths)]
statement = ('Five required FlowExpr validator returns isolate each selected actual CODE callback while preserving '
 'every original helper body byte except those returns and all global diagnostic line locations. Complete100-input '
 'first native observations retain387 warm/235 cold rows and exact fresh-process recurrences before expectations or '
 'source edits. Identical1795 assertions have490 original authority REDs/1305 controls and all current GREEN. All622 '
 'native compatibility rows stay exact. Thirteen syntax-valid complete-source faults fail490/111/119/117/74/126/338/'
 '18/522/1012/2/602/100; the sole inverse restores every original failure name/number. All77 ordered supplied suites/'
 '256 inputs/19470 assertions, five actual beyond-hash artifact denials/restorations, complete Knowledge1485 Markdown/'
 '1349 facts/seven original header lineages and book89/four rendered controls pass. Original218 bindings/full58582 '
 'publication and actual readonly baseline stay exact at81b356cef997ea2bb65a8fb120c77506fed9241e.')
scope = ('Required injected boundaries only in array/hash value inference, emptiness, defined-target and composite '
 'flow-expression lowering. The complete real owner bodies execute with explicit injected dependencies and actual '
 'SourceOrigins/SourceEmissions protocol. Controlled callback implementations are not complete helper admission. '
 'Selection/eager validation order, missing/non-CODE diagnostics and original source lines, actual public map refs, '
 'local scalar copies/shared parser argument arrays, scalar callback contexts under scalar/list/void owners, ordinary '
 'fallback/undefined/reference values, once-only effects, successful error state, fatal objects and cold lazy loading '
 'remain native. Actual callback identity selects only its own registration; no child donates equal-text parent '
 'publication, while a registered matching child retains its own packet. Default selection/EmitContext and optional '
 'two-read kind sites are unchanged and remain .4.1/.4.2. Every native/paired/fault/consumer supplied byte/mode and '
 'raw channel, original full claim, complete original/current Knowledge population and current full book/include '
 'inputs are recoverable; fixed accepted Git claim namespace and original218 bindings are independently checked. '
 'All first runtime diagnostic/oracle/capture writers are unchanged and retired. Actual completed outer tool sessions '
 'and exact merged logs are retained; separate outer channels were not captured. A routine inline documentation '
 'writer stopped on its own table count; its exact expression/stderr and unavailable full-inline-source limit are '
 'disclosed, and a distinct corrected writer finishes projections without changing runtime or observations. '
 'Supplemental standard syntax/public Phase01035 and the staged-fixture composed public selector/capability guard '
 'pass with full channels but without complete transitive input capsules; independent full-private Phase0 '
 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.5 and existing public capability owners retain those '
 'admissions. System Perl/stdlib/mdBook are reused read-only with no immutable portable toolchain or cross-version '
 'HTML claim. No authored-language, other-backend, complete-helper/private/parent/pipeline/canonical admission is '
 'inferred. Fixture registration .7 precedes pipeline .6; metadata .12 precedes TYPE-REFERENCE-BOOK after pipeline.')
claim = {'name': 'required-flowexpr-callback-private-boundaries', 'statement': statement, 'scope': scope,
 'rederive': {'status': 'checked',
   'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; review.py, evidence.py, validation.py and book-review.py under the same wrapper/prefix have readonly defaults. All --capture/preserve/observe/run/fault/consumer/compat/book/knowledge/continuity/completion writers are retired.',
   'granularity': 'Every387 warm/235 cold complete native row and recurrence; actual callback identity/eligibility and child/parent packet ownership;1795 identical paired names/numbers/490 RED/1305 controls;13 complete source variants/syntax/TAP/channels;77 ordered numeric consumer plans/19470 assertions/256 inputs and modes; fixed original claim namespace/218 bindings/full58582/baseline; Knowledge1485 original/current bytes/1349 facts/seven headers;book89 recursive inputs/four rendered controls;five semantic denials and exact restorations.',
   'result': statement},
 'falsify': {'status': 'checked',
   'hypothesis': 'Required callbacks may borrow enclosing eligibility or donate equal-text publication. Opaque wrappers may lose identity; copied arguments, localized errors, duplicate execution, eager loading, map rebinding or disabled validation may appear equivalent. Native channels, source-fault REDs, complete consumer plans, whole original publications or rendered teaching may be forged beyond immediate hashes.',
   'oracle': 'Unchanged first native instrument and complete original observations/recurrences, exact accepted original source/publication, actual CODE registration and retained-child packets; identical paired regression, independently checked full source faults and ordered consumer TAP; full Knowledge scan/header lineage and full supplied book/config/include population plus actual rendered markers; unchanged independent artifact reader.',
   'red_control': 'Same1795 fixture fails490 original authority assertions while1305 controls pass; all current GREEN. Exact inverse restores all490 names/numbers. Five owner bypasses and seven identity/alias/error/effect/loading/map/validation faults each give complete syntax-valid semantic RED with the recorded exact populations. Five actual rehashed/coherent native-identity, hidden-inverse-RED, forged-consumer-header, whole-original-publication and removed-rendered-teaching controls reject for named deeper reasons and restore exact readonly PASS. Book missing-summary fails, two removed teaching markers give product RED despite exit0, and missing-include emits the retained error.'},
 'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded required FlowExpr publication', len(raw))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot current publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact current readonly publication'
print('Required FlowExpr publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
