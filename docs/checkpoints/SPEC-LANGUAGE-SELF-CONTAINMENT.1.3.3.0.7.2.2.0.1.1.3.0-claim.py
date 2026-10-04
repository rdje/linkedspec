"""Publish only the independently accepted input-preparation/smoke measurement."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.0'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
result = json.loads((ROOT / (PREFIX + 'acceptance.json')).read_bytes())
paths = [path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if path.is_file()]
paths += ['tools/run_python_project_data.sh', 'tools/project_data_run.sh', 'tools/project_data_env.sh',
          'docs/linkedspec-book/src/development/documentation-workflow.md',
          'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0.json', 'docs/claims/REPO-HYGIENE.8.json']
old = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0-'
paths += [old + suffix for suffix in ('consumers.json', 'book.json', 'claim-initial.json', 'claim-initial.py', 'publish.py')]
inputs = [{'path': path, 'sha256': hashlib.sha256((ROOT / path).read_bytes()).hexdigest(),
           'role': 'producer' if path.endswith(('.py', '.sh')) else 'input'} for path in sorted(set(paths))]
statement = (f"A recoverable conservative capsule binds {result['files']} regular parent-owned files to exact Git3fc589f8494fd55b4f0154d6c226797a4fa2f711 plus one explicit book overlay. "
             f"Independent Git/rg review verifies {result['lexical_sites']} source-related lexical sites and {result['named_input_edges']} named input edges. "
             f"Two selected smoke suites pass {result['smoke_tests']} complete top-level groups; two source-identical examples and the overlay render. "
             'Eighteen reason-checked controls reject, including an actual post-run input mutation with completed channels retained.')
command = 'bash tools/run_python_project_data.sh ' + PREFIX
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'selected-input-capsule-preparation-and-smoke', 'statement': statement,
    'scope': 'Preparation and two-suite smoke only, not thirteen-suite acceptance or retrospective recovery of the earlier live run. The capsule is a conservative supplied-input superset, not a minimal runtime read set. Lexical sites include writes and quoted program text and are not classified defects or all actual filesystem reads. Full unchanged consumer remeasurement/adjudication remains .3.1; wider historical audit remains SESSION-STARTUP-READING.5. Root continuity bytes are the fixed historical Git inputs; only the declared development chapter is a candidate overlay. All capsule entry bytes, types and directory memberships are independently Git-gated, with overlay bytes retained in the capsule and tracked chapter. Project scratch/output stays on the repository filesystem. PATH-resolved host OS/Perl/prove/mdBook installations are read-only execution prerequisites; executable identities are retained, not a cross-host or byte-identical transcript portability claim. No submodule payload is included.',
    'rederive': {'status': 'checked', 'command': command + 'prepare.py; ' + command + 'review.py; ' + command + 'run.py --mode smoke --output ' + PREFIX + 'smoke.json; ' + command + 'run-controls.py; ' + command + 'accept.py',
                 'granularity': 'Every regular capsule entry and Git object/content identity; every named source-related lexical site/required edge; complete named two-suite TAP plans and actual rendered original examples; actual completed channels at a deliberately failing post-run input boundary.',
                 'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'A named suite hash, matching aggregate count or passing truncated output could conceal a missing/changed transitive input, changed directory population or failed/incomplete execution.',
                'oracle': 'Independent immutable Git tree/content census plus independent rg site population; authored retained case bytes and actual rendered code blocks; exact ordered complete TAP plans and prove final success markers. Input failure after actual execution must retain its completed output and cannot declare completion.',
                'red_control': 'Ten capsule controls, five TAP corruptions and two graph omissions reject for exact expected reasons. An actual added snapshot corpus member after the first successful consumer causes runtime input directory population RED; its complete 13-group TAP and both channels remain saved. Original broader observations remain unchanged and explicitly unadjudicated until .3.1.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}
}]}
target = ROOT / 'docs/claims' / (OWNER + '.json')
target.write_text(json.dumps(record, indent=2) + '\n')
assert target.stat().st_size <= 131072
print(f'Published bounded preparation claim with {len(inputs)} producer/input artifacts and a byte-complete capsule')
