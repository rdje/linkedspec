"""Publish bounded committed recurrence and the owned grouped-pattern defect."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
PARENT = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2'
OWNER, NEXT = PARENT + '.0', PARENT + '.1'
PREFIX = 'docs/checkpoints/' + PARENT + '-'
OLD = 'docs/checkpoints/' + PARENT.rsplit('.', 1)[0] + '.1-'
SUBJECT = OWNER + ' - retain grouped-pattern membership diagnosis'
CLAIM = 'docs/claims/' + OWNER + '.json'


def read(path):
    return json.loads((ROOT / path).read_bytes())


def replace(pattern, value, text):
    text, count = re.subn(pattern, lambda m: value, text, flags=re.M)
    assert count == 1, (pattern, count)
    return text


def main():
    proof, grouped, history, book, retention, instrument = [read(PREFIX + suffix) for suffix in (
        'verification.json', 'grouped-verification.json', 'freeze.json',
        'book-verification.json', 'retention.json', 'instrument-controls.json')]
    assert proof['complete'] and grouped['complete'] and history['complete'] and retention['complete']
    assert proof['commands'] == 73 and proof['regular_git_inputs'] == 4941 and proof['compiler_groups'] == 40
    assert proof['direct_consumers']['groups'] == 1473 and proof['direct_consumers']['plans'][-1] == 1035
    assert proof['authored_route_values'] == 120 and proof['callable_route_values'] == 18
    assert len(proof['controls']) == 22 and len(grouped['controls']) == 12
    assert grouped['selected_pattern_data_origins'] == 6 and grouped['excluded_control_origins'] == 12
    assert grouped['successful_native_fresh_values'] == 36 and grouped['membership_closed'] is False
    assert history['bound_inputs'] == 202 and len(history['controls']) == 5
    assert book['book_inputs'] == 58 and book['exact_examples'] == 4 and len(book['controls']) == 8
    assert len(retention['controls']) == 5
    assert instrument['complete'] and len(instrument['controls']) == len(grouped['retention_controls']) == 3
    statement = (
        'Immutable0f31461d6 supplies4941 regular inputs/no overlays for73 guarded commands. '
        'Compiler40/new225 signature assertions per seed0/1/42, original66 public channels/120 '
        'authored route values, plain callable18 values and unchanged16-consumer1473 groups/'
        'Phase01035 pass; original38 and signature10 RED recur. Two original unassessed value '
        'cases remain explicit. Twenty-two evidence controls reject. Nine supplemental commands '
        'retain18 primitive and18 return-family observations plus18 full public pairs/36 native-fresh '
        'values. Fixed x,y selects6 pattern-data origins; x,z/rest-y exclude12. Its helper-role '
        'query consumes the signature closer as y|; public ASSIGN2 versus1 distinguishes the '
        'defect despite all values1 and readiness1. Twelve diagnostic controls reject. Exact202 '
        'historical hashes freeze mode/revision only; five controls reject. Book58/four examples/'
        'eight controls and initial publication retention/five controls pass. Exact initial18718-byte '
        'grouped report/source survive the portable metadata correction with identical channels. '
        'Original report guard accepts3 corruptions; corrected guard rejects all3 with exact source retained. '
        'Production/tests/contracts/dependencies/CI unchanged. This checkpoint closes no membership '
        'parent; grouped-role repair .0.2.2.2.1 and fresh committed canonical .0.2.2.2.2 remain required.')
    next_action = ('Activate ' + NEXT + ' from clean committed HEAD. Author grouped-pattern/source/'
        'origin/metadata/default-query controls before correcting the compiler helper-role query. '
        'Preserve original RED, source/AST/arguments/references and numeric/host/indexed/caller-error '
        'contracts; run unchanged consumers/full Phase0 and commit focused repair. Fresh committed '
        'canonical ' + PARENT + '.2 must pass before membership parents close. Replacement .0.3, '
        'recurring .0.4, diagnostic origin .7.2.2.1 and comments .7.3 remain owned.')
    for name in ('perl-compiler-source-membership', 'perl-executable-source-membership',
                 'perl-source-membership-callable-signature-precedence'):
        path = ROOT / ('docs/knowledge/' + name + '.md'); text = path.read_text()
        text = replace(r'^status:.*$', 'status: Bounded committed recurrence verified; grouped-pattern repair and canonical membership acceptance remain open', text)
        text = replace(r'^date:.*$', 'date: 2026-10-08', text)
        text = replace(r'^evidence:.*$', 'evidence: ' + json.dumps(statement), text)
        lines = text.splitlines()
        lines = [line for line in lines if not (line.startswith('  - "bash tools/run_python_project_data.sh ') and line.endswith('-review.py"'))]
        insertion = lines.index('reverify:') + 1
        lines[insertion:insertion] = [
            '  - "bash tools/run_python_project_data.sh ' + PREFIX + 'review.py"',
            '  - "bash tools/run_python_project_data.sh ' + PREFIX + 'grouped-review.py"',
            '  - "These measurements use exact committed0f31461d6; preserve historical producers and hashes after any repair."']
        text = '\n'.join(lines) + '\n'
        text = text.replace('Public substitution still serializes', 'At the original484fe128f boundary, public substitution serialized')
        text = text.replace('but leaves\nthe final', 'but left\nthe final').replace('Native execution reports undefined', 'Native execution reported undefined')
        text = text.replace('independently emitted execution reports the same', 'independently emitted execution reported the same')
        text = text.replace('Fresh .0.2.2.2 still owns canonical membership acceptance.',
            'Fresh .0.2.2.2.2 owns canonical membership acceptance after grouped-role repair .0.2.2.2.1.')
        text += ('\nThe independently observed grouped-pattern interaction remains open; retrieve '
            '[[perl-callable-grouped-pattern-membership]]. The delimiter-loop repair alone does not '
            'protect its separate helper-role query. The bounded .0.2.2.2.0 checkpoint preserves '
            'complete successful original populations without promoting them to parent acceptance.\n')
        path.write_text(text)
    path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'; text = path.read_text()
    start = text.index('- ID: `' + OWNER + '`'); end = text.index('\n- ID:', start + 1)
    block = text[start:end]; assert 'Status: `in_progress`' in block
    block = block.replace('Status: `in_progress`', 'Status: `done`', 1)
    block += '\n  Verified focused result: ' + statement + '\n  Commit: `' + SUBJECT + '` (Git owns identity).\n  Next: ' + next_action + '\n\n'
    for label, detail in (
        ('REPRODUCE / ISSUE', 'Exact six authored grouped dot/comma sources and three seeds distinguish fixed x,y from x,z/rest-y; actual primitive regex-data origin45..59 remains selected and public ASSIGN rises2 instead of1.'),
        ('ROOT CAUSE (WHY + WHERE)', 'MethodExpr::_helper_pattern_ranges probes the unquoted signature closer8 as y| before discovering body patterns; SourceMembership protects only its own later loop. Numeric grouped-call fallback correctly retains existing precedence.'),
        ('FIX', 'This checkpoint retains the complete bounded evidence and concrete repair ownership; product correction remains .0.2.2.2.1-owned and is not claimed here.'),
        ('ADDRESSED (verified)', 'Immutable73-command original bounded recurrence, real source/AST/event/origin/native/fresh/metadata channels, original RED and effective evidence/diagnostic controls are retained. Production is unchanged.'),
        ('REPAIR OWNERSHIP', 'Correction .0.2.2.2.1 and fresh committed canonical .0.2.2.2.2 remain open. Passing return-family controls, values1 and readiness1 do not authorize membership closure.'),
        ('NO REGRESSION', 'Unchanged16 consumers retain1473 exact ordered groups/Phase01035; complete original public channels and plain callable oracles remain exact. No new grammar or default scanner behavior follows.'),
        ('LOCKSTEP', 'Exact202-hash freeze, current/initial publication capsules, original metadata-bearing report and producer, claims/Knowledge/book/task/index/roadmaps/live/resume and bounded histories align; no historical hashes refresh. Original report-retention checker accepts three actual population/producer/input-guard corruptions; exact original source/results survive while corrected complete guards reject all three.'),
    ):
        block += '- [x] **' + label + '** — ' + detail + '\n'
    text = text[:start] + block + text[end:]
    text = replace(r'^\| 43\.4\.2\.0\.2\.2\.2\.0 \|.*$',
        '| 43.4.2.0.2.2.2.0 | `' + OWNER + '` | `done` | Immutable recurrence and grouped-pattern cause retained; repair next. |', text)
    text = text.replace('## Verification Log\n', '## Verification Log\n\nOctober8 `' + OWNER + '`: ' + statement + '\n', 1)
    text = text.replace('## Commit Log\n', '## Commit Log\n\n- `' + SUBJECT + '` — bounded checkpoint; grouped-role repair/canonical membership acceptance remain open. Git owns identity.\n', 1)
    text = text.replace('## Changelog\n', '## Changelog\n\n- `2026-10-08`: .0.2.2.2.0 retains original bounded recurrence and owns the actual grouped-pattern primitive membership defect; repair .1 and canonical .2 precede parent closure.\n', 1)
    path.write_text(text)
    for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
        path = ROOT / name; path.write_text(replace(r'^\| Expressive `\.spec` self-containment \|.*$',
            '| Expressive `.spec` self-containment | `active: grouped-pattern membership repair next` | ' + statement + ' | ' + next_action + ' |', path.read_text()))
    path = ROOT / 'docs/TASK_TREE.md'; path.write_text(replace(r'^\| `SPEC-LANGUAGE-SELF-CONTAINMENT` \|.*$',
        '| `SPEC-LANGUAGE-SELF-CONTAINMENT` | `active: grouped-pattern membership repair next` | `.spec language evolution / expressive self-containment and alternate authoring profiles` | ' + statement + ' Next: ' + next_action + ' | [docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md](docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md) |', path.read_text()))
    for name in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
        path = ROOT / name; text = path.read_text(); offset = text.index('\n## ')
        path.write_text(text[:offset] + '\n## 2026-10-08 — Retain grouped-pattern membership diagnosis\n\n' + statement + '\n' + text[offset:])
    path = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'; text = path.read_text()
    for title, value, following in (
        ('Current Activity', 'Full PNT: bounded membership recurrence retained; actual grouped-pattern role repair precedes canonical acceptance.', 'Latest Completed Slice'),
        ('Latest Completed Slice', '`' + OWNER + '` — ' + statement, 'Next Action'),
        ('Next Action', next_action, 'Recent Completions'),
    ):
        text, count = re.subn(r'(## ' + title + r'\n\n).*?(\n## ' + following + r')', lambda m: m[1] + value + '\n' + m[2], text, flags=re.S)
        assert count == 1
    recent = text.split('## Recent Completions\n\n', 1)[1].split('\n## History', 1)[0]
    rows = [r for r in recent.splitlines() if r.startswith('- `')]
    rows.insert(0, '- `' + OWNER + '` — immutable73/consumer1473; grouped-pattern primitive cause retained; focused repair next.')
    text = re.sub(r'(## Recent Completions\n\n).*?(\n## History)', lambda m: m[1] + '\n'.join(rows[:16]) + '\n' + m[2], text, flags=re.S)
    path.write_text(text)
    path = ROOT / 'MEMORY.md'; text = path.read_text()
    for field, value in {
        'latest_completed_leaf': '`' + SUBJECT + '`.',
        'active_work_unit': '`' + OWNER + '` (done) — bounded committed recurrence/grouped-pattern diagnosis.',
        'next_action': next_action,
        'in_flight_uncommitted': 'None; intended clean focused post-landing handoff. All retained proof/consumer/publication checks complete. Grouped-pattern repair starts after this commit; membership parents remain open.',
    }.items():
        text = replace(r'^- ' + field + r':.*$', '- ' + field + ': ' + value, text)
    path.write_text(text)
    prior_claim = 'docs/claims/' + PARENT.rsplit('.', 1)[0] + '.1.json'
    paths = {e['path'] for e in read(prior_claim)['claims'][0]['durability']['inputs']}
    paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(PARENT + '-*') if p.is_file())
    paths.update(e['path'] for e in read(PREFIX + 'book-inputs.json')['entries'])
    paths.update(read(PREFIX + 'observations.json')['runs'][-1]['command'][5:])
    paths.update((prior_claim, 'docs/knowledge/perl-callable-grouped-pattern-membership.md'))
    for stem in ('SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.1-',
                 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-'):
        suffixes = ('review.py', 'before-inputs.json', 'before-observations.json', 'final-after-observations.json') if '.0.2.1-' in stem else ('cases.json', 'probe.pl', 'fresh.pl')
        paths.update('docs/checkpoints/' + stem + suffix for suffix in suffixes)
    paths.update((OLD + 'review.py', OLD + 'before-inputs.json', OLD + 'before-observations.json',
                  OLD + 'after-inputs.json', OLD + 'after-observations.json', OLD + 'probe.pl'))
    bindings = []
    for path in sorted(paths):
        source = ROOT / path; assert source.is_file() and not source.is_symlink(), path
        bindings.append({'path': path, 'sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
            'role': 'producer' if source.suffix in ('.py', '.pl', '.pm', '.sh', '.t') else 'input'})
    scope = ('Bounded committed Perl membership recurrence and source-bound grouped-pattern diagnosis at exact0f31461d696186775585e19355a0bc5c41849dfb. Complete4941 regular Git supplied inputs reconstruct from retained object/hash/size/mode manifest without overlays; Gitlinks/nonregular payloads excluded without inspection. Every command guards all supplied inputs, not minimal observed IO. Nine supplemental commands separately supply retained read-only observer programs with producer hashes and the same immutable input tree. All original typed source/AST/origins and complete public channels remain authoritative. Original unsupported_nested/raw_operand successful values remain unassessed. Current grouped sources all return1 and report readiness1; only real primitive membership and public assignment counters distinguish this gap. Initial grouped report18718 bytes and exact producer survive gzip retention; original and portable-metadata recurrence have byte-identical stdout/stderr. Original actual argv survives an encoded envelope; durable command metadata is repository-relative. Initial58-input publication capsule and exact original producer/render/control channels remain retained; current capsule differs only in the owned teaching page and explicitly preserves the open boundary. Historical202-input claim freezes mode/revision only at0f31461d6 with no refreshed hashes. Necessary read-only OS/Perl/Python/mdBook/toolchain access; all project data remains local on the repository volume. No canonical success, membership-parent closure, new grammar/backend admission, replacement, diagnostic-origin, comment or readiness waiver follows. Corrective .0.2.2.2.1 and fresh committed canonical .0.2.2.2.2 own remaining acceptance. Other repositories read-only; RGX/PGEN black boxes; no recovery/purge.')
    claim = {'version': 1, 'owner': OWNER, 'claims': [{
        'name': 'bounded-recurrence-and-grouped-pattern-diagnosis', 'statement': statement, 'scope': scope,
        'rederive': {'status': 'checked', 'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + suffix for suffix in (
            'capture.py', 'review.py', 'grouped-capture.py', 'cause-capture.py', 'grouped-review.py', 'freeze.py', 'book.py --review', 'retention.py', 'instrument-controls.py')),
            'granularity': json.dumps({'committed': proof, 'grouped': grouped, 'history': history, 'book': book, 'retention': retention, 'instrument_controls': [{'name': c['name'], 'original_instrument_accepted': c['original_instrument_accepted'], 'corrected_observed_red': c['corrected_observed_red']} for c in instrument['controls']]}, sort_keys=True), 'result': statement},
        'falsify': {'status': 'checked', 'hypothesis': 'Passing return-family scans, native/fresh values and readiness establish grouped-pattern membership; incomplete or forged source/AST/origin/metadata/input/TAP/render channels could support closure.',
            'oracle': 'Original authored literal/value/callable and complete consumer plans remain unchanged; original compiler38/signature10 RED recur. Six grouped dot/comma sources distinguish fixed x,y from x,z/rest-y using actual producer-bound set_value origins and real compiler public descriptor assignment counts2 versus1, despite identical successful value1. Host quote end and missing helper ranges independently locate the cause; return-family controls deliberately pass.',
            'red_control': 'Actual six falsely selected regex-data origins and public ASSIGN2 recur under three seeds; twelve effective source/origin/metadata/cause/value/input/producer controls reject. Twenty-two bounded recurrence corruptions, five historical-hash controls, eight current publication corruptions and five original publication retention corruptions reject. Exact original report checker and three falsely accepted corruptions/complete outputs survive; corrected full population/producer/input-guard checks reject all three. All complete original failed channels and source inputs remain exact.'},
        'durability': {'status': 'checked', 'mode': 'live', 'inputs': bindings}}]}
    raw = json.dumps(claim, indent=2) + '\n'; assert len(raw.encode()) <= 131072
    (ROOT / CLAIM).write_text(raw)
    (ROOT / 'git_message_brief.txt').write_text(SUBJECT + '\n\n' + statement + '\n\n' + next_action + '\n')
    print(statement); print('Bound claim inputs:', len(bindings))


if __name__ == '__main__':
    main()
