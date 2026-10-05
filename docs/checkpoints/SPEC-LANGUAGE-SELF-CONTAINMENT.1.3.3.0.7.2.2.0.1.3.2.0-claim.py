"""Bind original argument diagnosis to its actual producers and complete inputs."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REVISION = '6ce479842be85219990be889914f354f1a4aaa44'


def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


runtime, book, freeze = [json.loads((ROOT / (PREFIX + n + '.json')).read_bytes())
                         for n in ('verification', 'book-verification', 'freeze')]
assert runtime['complete'] and book['complete'] and runtime['revision'] == freeze['revision'] == REVISION
assert (runtime['regular_inputs'], runtime['overlays'], runtime['commands'], runtime['cases'],
        runtime['arguments'], runtime['seeds'], runtime['callback_controls'], runtime['fixture_suites'],
        runtime['fixture_groups'], len(runtime['controls'])) == (4141, 2, 4, 10, 23, 3, 14, 7, 124, 23)
assert all(c['observed'] == 'RED' and c['reason'] for c in runtime['controls'])
assert (book['book_inputs'], book['rendered_examples'], book['rendered_sections'],
        len(book['controls']), freeze['bound_inputs']) == (58, 17, 3, 17, 55)
for result, producer in ((runtime, 'review.py'), (book, 'book.py'), (freeze, 'freeze.py')):
    assert result['instrument_sha256'] == digest(PREFIX + producer)
paths = [p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if p.is_file()]
base = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.0-'
paths += [base + n for n in ('review.py', 'review-oracle.py')]
paths += ['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
          'perl/LinkedSpec/ActionIR/MethodExpr.pm', 'perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm',
          'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md', 'tools/check_claim_verification.py',
          'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh']
inputs = [{'path': p, 'sha256': digest(p),
           'role': 'producer' if p.endswith(('.py', '.pl', '.pm', '.sh')) else 'input'} for p in sorted(set(paths))]
statement = ('Original MethodExpr/CSV callback diagnosis supplies4141 immutable regular Git inputs/two exact runtime overlays. '
             'Four fully guarded commands verify ten independently authored cases/23 original scalar argument intervals across '
             'three identical full seed channels,14 controlled callback records and seven suites124 groups. Exact CSV-return '
             'references, trim/payload bases, dropped empty slots, receiver/helper-pattern context, transformed/foreign/opaque '
             'returns, nested calls, exceptions and caller error state are retained.23 reason-specific evidence controls observe '
             'RED. Complete58-input book renders17 examples/three chapters with17 rejection controls;55 prior claim hashes '
             'verify before mode/revision-only historical freeze. No argument frames are published by the current parser.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'original-method-argument-authority-diagnosis', 'statement': statement,
    'scope': ('Clean immutable ' + REVISION + ' original producer plus two exact authored runtime overlays. Complete regular '
              'Git inventory is a conservative supplied-input superset, not minimal observed IO; every byte/mode/member and '
              'full stdout/stderr is retained. The literal author constructs positions cumulatively from source fragments '
              'without observed-text lookup. These23 intervals specify future bridge expectations, not current published '
              'frames. Custom callbacks retain ordinary returned identity/value even when authority would be denied; no '
              'arbitrary malicious callback admission follows. Exact controlled Flow callback populations and public '
              'substitution/descriptor/parser dump recur across seeds. Production/spec/standard-test bytes are unchanged. '
              'No public API/schema/recognition/dispatch/dependency/CI/storage/other-repository change. Bridge implementation '
              '.1.3.2.0.1 and recursive Flow consumers .1.3.2.1 remain separate; whole-family .1.3.3 needs canonical signoff. '
              'Book teaching is separate actual complete-input render; no native executable admission. Required host '
              'OS/Perl/Python/prove/mdBook are read-only dependencies, project data remains repository-local. Gitlinks and '
              'nonregular entries are metadata-only exclusions; RGX/PGEN remain black boxes. Initial authoring heredoc '
              'failed before files/observations and was replaced by exact patch authoring. Prior claim freeze preserves all '
              'earlier adjudications. Global history/reading/backend/membership audits remain separately owned.'),
    'rederive': {'status': 'checked', 'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + n
                 for n in ('capture.py', 'review.py', 'freeze.py', 'book.py --review')),
                 'granularity': '4141 regular Git inputs/2 runtime overlays/4 guarded commands;10 cases23 arguments/3 seeds/14 callback controls;7 suites124 groups;58 book inputs17 examples3 chapters;55 prior hashes.',
                 'result': statement},
    'falsify': {'status': 'checked',
                'hypothesis': 'Equal string values, copied returns, lost empty slots, callback reordering or incomplete channels could incorrectly establish original argument authority.',
                'oracle': 'Independent cumulative original fragments/intervals, actual CSV-return refaddr comparison, exact callback/result/error/traversal literals, complete immutable Git and runtime channel/TAP checks.',
                'red_control': '23 actual reason-specific evidence corruptions reject per-case changed source, copied reference, omitted callbacks, wrong empty slots/traversal/foreign/transformed values/caller error/exception, missing commands/guards/Git inputs and forged channel/producer.17 complete-book corruption controls reject.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print(str(len(inputs)) + ' actual producer/artifact bindings')
