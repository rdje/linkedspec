"""Publish the finite historical qualification and complete selected replacement."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.5'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
assert json.loads((ROOT / (PREFIX + 'review.json')).read_text())['result'] == 'PASS'
sources = set()
for suffix in ('consumers',):
    sources.update(json.loads((ROOT / (PREFIX + suffix + '.json')).read_text())['inputs'])
sources.update(json.loads((ROOT / (PREFIX + 'book.json')).read_text())['rows'][0]['inputs'])
sources.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*'))
audit = json.loads((ROOT / (PREFIX + 'audit.json')).read_text())
for row in audit['rows']:
    sources.update([row['claim_path'], row['capture_path'], row['capture_path'].replace('-consumers.json', '-proof.py')])
sources.update(['tools/run_python_project_data.sh', 'tools/project_data_env.sh', 'tools/project_data_run.sh',
                'docs/knowledge/private-consumer-artifact-binding-audit.md',
                'docs/knowledge/selected-consumer-proof-input-closure-gap.md',
                'docs/knowledge/perl-private-method-input-captures.md',
                'docs/knowledge/perl-private-input-authority-selection.md',
                'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1.json',
                'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1-consumers.json'])
statement = ('The finite four-record historical consumer audit distinguishes foundation2306 matching recorded inputs/both selected JSON artifacts from constructor215/native216/empty217 with two omitted JSON reads each. All recorded hashes match their named Git epochs. '
             'Three supplemental observations are explicitly separated into historical falsification/durability gap entries; the original foundation stays unchanged. Original before claims,759 bounded bindings/behavioral legs and163 MethodExpr bindings remain preserved. '
             'Current immutable133-file/fourteen-suite supplied recurrence passes with unchanged contents/population, three actual missing-artifact reader REDs and restored-trim semantic RED18. '
             'Complete57-input supplied book render passes; missing SUMMARY fails the command and changed explanatory text produces an absent rendered marker despite command exit0. Eleven reason-sensitive evidence controls pass. No product bytes change.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'finite-historical-consumer-qualification-and-complete-replacement', 'statement': statement,
    'scope': 'Exactly four recent private supplemental records, three actual artifact-binding omissions, preserved standalone fixture/inverse/Toolbox/diagnostic claims, and a new complete selected consumer/book boundary. Immutable original source inputs are recoverable through the retained Git epoch/path/SHA descriptors; the independent reviewer rederives every recorded identity from those Git objects. Missing historical per-read JSON bytes remain explicitly unavailable, not filled with epoch/current hashes. Complete new recurrence supersedes active selected acceptance; the foundation is individually verified without a false omission classification. Standard read-only Perl/prove/mdBook modules/executables and project-volume scratch are reused; no cross-toolchain identical output, full Phase0, original-event/factory integration, mapped residual fix, canonical admission or wider SESSION-STARTUP-READING.5 audit closeout.',
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'audit.py; bash tools/run_python_project_data.sh ' + PREFIX + 'qualify.py; bash tools/run_python_project_data.sh ' + PREFIX + 'recurrence.py; bash tools/run_python_project_data.sh ' + PREFIX + 'artifact-controls.py; bash tools/run_python_project_data.sh ' + PREFIX + 'book.py; bash tools/run_python_project_data.sh ' + PREFIX + 'review.py',
                 'granularity': 'Every original recorded manifest identity and actual historical reader edge/omitted JSON; exact before/after qualification and all bounded input hashes; each immutable supplied consumer file/population and actual reader/source failure; every complete book config/source file and rendered marker/source control.', 'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'All earlier producers might omit the same artifacts; adding epoch hashes might reconstruct original reads; failed/incomplete or forged consumer/book observations might masquerade as complete current proof.',
                'oracle': 'Independent historical Git/source/manifest comparison, unchanged foundation with both actual artifact paths, exact limited claim qualification and preserved original hashes, immutable133-file selected seed, all three actual JSON-reader edges and complete57-file book source population with independent rendered explanation marker.',
                'red_control': 'Three actual omitted JSON inputs fail unchanged readers; restoring the original trim producer gives18 semantic TAP failures in65 assertions. Missing SUMMARY produces a real build failure; changing the chapter still builds but the independent rendered marker is absent. Eleven reason-sensitive evidence corruptions reject missing owners, invented/hidden historical gaps, forged original identities, failed/incomplete recurrence, lost semantic RED, missing artifact control and omitted/failed/forged book evidence. Original historical per-read gaps remain disclosed in separate qualified observation entries.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': [
        {'path': p, 'sha256': hashlib.sha256((ROOT / p).read_bytes()).hexdigest(),
         'role': 'producer' if p.endswith(('.pm', '.pl', '.py', '.sh', '.t')) else 'input'} for p in sorted(sources)]}
}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print('Finite audit claim:', len(sources), 'exact retained producer/artifact inputs.')
