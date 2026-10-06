"""Publish only the accepted complete rollover evidence and its actual inputs."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('claim.py')
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1.1'
BASE = '224d5443af794d4e5ade6e80bd8f09145ee7b5b3'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def read(suffix):
    return json.loads(Path(PREFIX + suffix).read_bytes())


def decode(value):
    raw = gzip.decompress(base64.b64decode(value['data'], validate=True))
    assert value['encoding'] == 'gzip-base64' and sha(raw) == value['sha256'] and len(raw) == value['bytes']
    return raw


v, book, freeze = read('verification.json'), read('book-verification.json'), read('freeze.json')
audit = read('audit-verification.json')
assert v['complete'] and (v['immutable_inputs'], v['commands_per_epoch'], v['groups'],
                        v['original_red_groups'], v['repaired_green_groups'], len(v['controls'])) == (91, 36, 41, 12, 41, 153)
assert v['instrument_sha256'] == sha(Path(PREFIX + 'review.py').read_bytes())
assert book['complete'] and (book['book_inputs'], book['rendered_examples'],
                           book['rendered_sections'], len(book['controls'])) == (58, 17, 4, 28)
assert book['instrument_sha256'] == sha(Path(PREFIX + 'book.py').read_bytes())
assert (freeze['bound_inputs'], freeze['unique_inputs'], freeze['claims']) == (31, 31, 1)
assert audit['complete'] and (audit['commands'], audit['audited_sources'], audit['checkpoints'],
    audit['historical_source_references'], audit['restored_inputs'], audit['restored_bytes'],
    audit['recovery_controls'], audit['evolution_controls'], audit['boundary_fixture_groups'],
    len(audit['controls'])) == (3, 149, 24, 257, 134, 84613241, 22, 56, 46, 20)
assert audit['instrument_sha256'] == sha(Path(PREFIX + 'audit.py').read_bytes())
for path, identity in audit['input_bindings'].items():
    assert sha((ROOT / path).read_bytes()) == identity, 'actual complete audit input'
old_claim = read('before-entry-claim.json')
for claim in old_claim['claims']:
    assert claim['durability']['mode'] == 'live'
    for entry in claim['durability']['inputs']:
        assert sha(subprocess.check_output(['git', 'show', BASE + ':' + entry['path']], cwd=ROOT)) == entry['sha256']
    claim['durability'].update(mode='historical', revision=BASE)
assert old_claim == json.loads((ROOT / 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.6.json').read_bytes())

# Retained preflights explain corrections; they are distinct from accepted proof.
for epoch in ('before', 'after'):
    initial = read('preflight-' + epoch + '.json')
    outer = read('preflight-' + epoch + '-command.json')
    assert initial['instrument_sha256'] == sha(Path(PREFIX + 'preflight-regression.py').read_bytes())
    assert outer['result_sha256'] == sha(Path(PREFIX + 'preflight-' + epoch + '.json').read_bytes())
    assert outer['inputs_before'] == outer['inputs_after'] and decode(outer['stderr']) == b''
    assert len(initial['results']) == 36 and sum(not r['ok'] for r in initial['results']) == (12 if epoch == 'before' else 2)
assert read('initial-before.json')['instrument_sha256'] == sha(Path(PREFIX + 'initial-regression.py').read_bytes())
assert read('warned-before.json')['instrument_sha256'] == sha(Path(PREFIX + 'preflight-regression.py').read_bytes())
initial_book = read('initial-book.json')
assert initial_book['complete'] and initial_book['instrument_sha256'] == sha(Path(PREFIX + 'initial-book.py').read_bytes())
assert Path(PREFIX + 'initial-book-inputs.tar.gz').read_bytes() == Path(PREFIX + 'pre-route-book-inputs.tar.gz').read_bytes()
assert read('initial-book-inputs.json') == read('pre-route-book-inputs.json')
assert (read('initial-book-verification.json')['rendered_examples'], read('initial-book-verification.json')['rendered_sections']) == (14, 3)
prior_book = read('pre-audit-book.json')
assert prior_book['instrument_sha256'] == sha(Path(PREFIX + 'pre-audit-book.py').read_bytes())
assert read('pre-audit-book-verification.json')['rendered_examples'] == 16
second = read('second-canonical.json')
assert second['exit'] == 1 and second['base'] == BASE
assert decode(second['log']).endswith(b'ValueError: current executable evidence drift: perl/LinkedSpec/ActionIR/Contracts.pm\n')
assert b'doctrines: ALL 10 enforced doctrines PASS.' in decode(second['log'])
decode(second['staged_candidate'])
assert second['instrument_sha256'] == sha(Path(PREFIX + 'audit-census.py').read_bytes())
for label in ('preflight', 'count', 'subset'):
    retained = read(label + '-audit-observations.json')
    assert retained['instrument_sha256'] == sha(Path(PREFIX + label + '-audit.py').read_bytes())
assert len(read('subset-audit-verification.json')['controls']) == 17

statement = ('Both history formats preserve exact source/suffix/older manifest and archive '
    'bytes while normalizing only mutable terminal LF separators. Pending segment IDs '
    'remain JSON strings after numeric eligibility; actual reruns recover the exact '
    'generation, and contradictory same-HEAD metadata or invalid targets reject without '
    'publication. The complete original/repaired proof retains91 immutable Git fixture '
    'inputs and36 public commands/41 checks per epoch, original RED12/final GREEN41, a causal JSON '
    'type RED/GREEN probe and153 effective evidence controls. The complete58-input book '
    'renders17 examples/four chapters with28 RED controls.31 prior entry claim hashes '
    'verify before exact historical freeze. The historical-audit compatibility repair '
    'reconstructs only the committed Contracts import/loop and Phase0 nested-boundary '
    'insertion, preserving24 checkpoints/257 historical source references/149 selected '
    'sources and134 archived inputs/84613241 bytes. Three complete guarded commands '
    'retain original auditor RED, isolated recovery GREEN and46 boundary groups; '
    '22 recovery/56 evolution/20 audit-evidence controls pass.')
paths = {p.relative_to(ROOT).as_posix() for p in Path(PREFIX).parent.glob(Path(PREFIX).name + '*')}
paths.update(['tools/roll_document_history.pl', 'tools/test_document_history_rollover.py',
    'tools/read_document_history.pl', 'scripts/check_document_history.sh',
    'scripts/check_document_history.pl', 'tools/project_data_env.sh',
    'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
    'tools/check_claim_verification.py', 'docs/knowledge/document-history-rollover-eof-separator.md',
    'docs/knowledge/bounded-change-notes-history-contract.md',
    'docs/linkedspec-book/src/development/local-ci-and-regression.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md',
    'docs/knowledge/three-objective-language-readiness.md',
    'docs/knowledge/historical-objective-audit-input-recovery.md'])
paths.update(audit['input_bindings'])
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
           'role': 'producer' if path.endswith(('.py', '.pl', '.sh')) else 'input'} for path in sorted(paths)]
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'rollover-eof-and-pending-generation-recovery', 'statement': statement,
    'scope': ('Original producer at224d5443 and fixed pressure-bearing public Git sources '
        'atb2156813. Each report losslessly retains all91 source inputs, the full actual '
        'producer and read-only Git source shim. Fixture views are ordinary repository-local '
        'files, not new repositories; the shim permits only show/rev-parse and resolves HEAD '
        'to the declared exact public source identity. No Git metadata write occurs. '
        'Complete per-command file/symbolic-target guards and unfiltered stdout/stderr/exits '
        'distinguish recovery, false duplicate publication and no-write rejection. '
        'No-index whitespace RED is exit3 with the exact EOF diagnostic; clean differing '
        'files produce exit1 and empty channels. Missing pending-target rejection is '
        'observed exit2, other named invalid-input failures exit255. The reviewer '
        'reconstructs the full original root including the one omitted LF from its bound '
        'Git prefix; archive-only --all remains unchanged. Source inverse permits only '
        'EOF normalization, pending string restoration and same-HEAD metadata rejection. '
        'Actual production manifests/archives and all schema/capacity scalars are unchanged. '
        'The registered DOCUMENT-HISTORY gate executes the retained actual regression. '
        'Initial preamble, no-index exit, book summary and missing-target reviewer corrections '
        'are separately retained and not accepted final counts. The warned direct invocation '
        'lacks separately enveloped complete outer streams and is diagnostic only; final '
        'accepted outer channels are complete and empty on stderr. Existing startup .7 '
        'owns wrapper establishment/liveness; no recovery/purge or lifecycle guarantee. '
        'Host Perl/Git/mdBook executables are necessary read-only toolchain inputs; project '
        'data stays on the repository volume and other repositories remain read-only. '
        'No language/runtime/schema/helper/callback/dependency change or black-box inspection. '
        'The first exact canonical candidate is retained with its complete combined stream and binary staged diff; it exits1 only for reserved checked-label wording and diagnostics chapter pressure and supplies no receipt. The new detail is routed to the existing documentation-workflow chapter without raising limits. Five current report-path probes distinguish valid relative output from traversal, absolute, symbolic-parent and Git-metadata destinations; the old lexical guard witness is retained without outside writes. Those current instrument probes are shared by both epochs; original refers to the old rollover producer, not an old path-validation acceptance. '
        'The second candidate passes all10 doctrines and stops in the historical audit; its complete combined stream and exact staged candidate are retained. Only the source-bound committed Contracts import/loop and Phase0 nested-boundary insertion are normalized; all original checkpoints, hashes, logs and dated runtime claims remain unchanged. Current historical recovery does not re-execute those runtime producers. The added proof guards the conservative complete regular committed parent perl/t/specs source population, two actual literal fixture files, selected historical evidence and actual wrappers/instruments, excluding Gitlinks and nonregular metadata without payload reads. This is a supplied boundary, not minimal observed I/O; RGX/PGEN remain black boxes. The narrower selected-input proof, count correction and first post-Contracts Phase0 failure remain retained as preflights. '
        'Canonical CI is required by the exact staged receipt before landing; its pass is '
        'not inferred from these focused measurements. Complete Legacy acceptance remains '
        '.1.4.7-owned; other defects and audits stay with their existing owners.'),
    'rederive': {'status': 'checked',
        'command': ' ; '.join('bash tools/run_python_project_data.sh ' +
            Path(PREFIX + command).relative_to(ROOT).as_posix() for command in
            ['freeze.py', 'capture.py before', 'capture.py after', 'diagnosis.py',
             'review.py', 'audit.py capture', 'audit.py review', 'book.py --review', 'claim.py']),
        'granularity': 'Two history formats/91 exact source inputs/36 commands and41 groups per epoch/RED12-GREEN41/153 controls;58 book inputs/17 examples/four chapters/28 controls;31 prior hashes. Historical audit24 checkpoints/257 references/149 selected sources/134 recovered inputs; three guarded commands/46 boundary groups/22 recovery/56 evolution/20 evidence denials.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Whitespace removal, shallow recovery self-tests, numeric pending IDs, duplicate publication or missing inputs/channels/guards could falsely establish safe rollover.',
        'oracle': 'Exact independent committed source/suffix/manifest reconstruction, literal pressure records, full filesystem/public-command guards, ordered original RED/final GREEN TAP, isolated JSON string/number comparison and three-edit source inverse.',
        'red_control': 'Actual original12 RED and repaired41 GREEN;153 effective controls reject false report-path/witness evidence, false exits, all91 omitted inputs, lost separators/suffixes/rows, numeric segment ID, changed actual producer/command, false original GREEN, missing guards/channels/TAP and duplicate recovery output.28 book controls observe exact RED; the isolated numeric-ID comparison fails before string restoration. Original audit rejects current Contracts; final historical recovery passes22 recovery and56 effective evolution controls, including six new Contracts and six new Phase0 denials.20 audit-evidence controls reject false exits/guards/commands/producer/channels, missing original or new decoder/fixture inputs, hidden warnings, false original RED, escaped recovery and refreshed historical identities.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs},
}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print(str(len(inputs)) + ' actual producer/artifact inputs bound; rollover claim published')
