"""Prepare the verified membership candidate; canonical receipt gates its landing."""
from pathlib import Path
import hashlib
import importlib.util
import json
import re

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.2'
BASE = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0'
NEXT = BASE + '.3'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REPAIR = 'docs/checkpoints/' + BASE + '.2.2.2.1-'
PRIOR_CLAIM = 'docs/claims/' + BASE + '.2.2.2.1.json'
SUBJECT = OWNER + ' - accept committed compiler membership'
CLAIM = 'docs/claims/' + OWNER + '.json'


def read(path):
    return json.loads((ROOT / path).read_bytes())


def replace(pattern, value, text):
    text, count = re.subn(pattern, lambda m: value, text, flags=re.M)
    assert count == 1, (pattern, count)
    return text


def main():
    proof, history, book = [read(PREFIX + suffix) for suffix in (
        'verification.json', 'freeze.json', 'book-verification.json')]
    assert proof['complete'] and history['complete'] and proof['commands'] == 77
    assert proof['regular_git_inputs'] == 5018 and proof['overlays'] == []
    assert proof['compiler_groups'] == 41 and proof['grouped_assertions_per_seed'] == 789
    assert proof['public_seed_observations'] == 66 and proof['authored_route_values'] == 120
    assert proof['callable_route_values'] == 18 and proof['grouped_route_values'] == 36
    assert proof['default_query_sources'] == 72 and proof['direct_consumers']['groups'] == 1644
    assert len(proof['direct_consumers']['plans']) == 22 and proof['direct_consumers']['plans'][15] == 1035
    assert len(proof['controls']) == 31 and history['bound_inputs'] == 291 and len(history['controls']) == 5
    assert book['book_inputs'] == 58 and book['exact_examples'] == 5 and len(book['controls']) == 9
    instrument = read(PREFIX + 'instrument-controls.json')
    assert instrument['complete'] and len(instrument['controls']) == 2
    spec = importlib.util.spec_from_file_location('acceptance_publication', ROOT / (PREFIX + 'book.py'))
    renderer = importlib.util.module_from_spec(spec); spec.loader.exec_module(renderer)
    observed = read(PREFIX + 'observations.json')
    for run in observed['runs']:
        if run['kind'] == 'grouped':
            rows = json.loads(renderer.decode(run['stdout']))
            assert renderer.EXAMPLES[-1] == rows[0]['source'] + '\n# result: 1'
            assert rows[0]['native']['value'] == rows[0]['fresh']['value'] == 1
    statement = (
        'Fresh immutable5b4a9a8 supplies5018 regular committed inputs/no overlays for77 guarded commands. '
        'Compiler41/original40/signature225/grouped789 pass per seed0/1/42. All original66 public '
        'source/AST/lowering/emitted/metadata/value/error channels recur with120 authored route values; '
        'unsupported_nested/raw_operand retain explicit unassessed value scope. Plain callable18 and '
        'grouped36 native/fresh values preserve complete corrected source/origin/metadata channels. '
        'All72 default query/view/numeric/syntactic snapshots remain byte-identical. Twenty-two unchanged '
        'consumers pass1644 ordered groups/full Phase01035. Historical membership38, signature10 and '
        'grouped114 RED recur from original retained producers. Thirty-one evidence controls, five '
        'history controls and nine render controls reject. Exact291 repair hashes freeze mode/revision '
        'only at5b4a9a8. Book58/five exact examples passes. Production/tests/contracts/CI/hooks/dependencies '
        'remain unchanged. Initial missing-artifact reviewer/source/error are retained; exact rejection '
        'recurs and sole corrected reference passes complete review. Exact staged canonical receipt '
        'and normal hooks gate membership parent closure; '
        'precise replacement .0.3, recurring .0.4, diagnostic origin .7.2.2.1 and comments .7.3 remain owned.')
    next_action = ('Activate ' + NEXT + ' from clean committed HEAD after checking bounded-history capacity. '
        'Retrieve original quoted-twin/mapping/occurrence facts and Toolbox source-bound probes; author '
        'exact original/rewritten occurrence oracles before a safely bounded replacement repair. '
        'Preserve quoted bytes, real spans, arguments/references, family order and native/fresh/error contracts. '
        'Recurring .0.4, diagnostic origin .7.2.2.1 and comments .7.3 remain owned.')
    for name in ('perl-callable-grouped-pattern-membership', 'perl-source-membership-callable-signature-precedence',
                 'perl-compiler-source-membership', 'perl-executable-source-membership'):
        path = ROOT / ('docs/knowledge/' + name + '.md'); text = path.read_text()
        text = replace(r'^date:.*$', 'date: 2026-10-08', text)
        text = replace(r'^status:.*$', 'status: Independent committed membership recurrence verified; exact canonical receipt gates parent closure', text)
        text = replace(r'^evidence:.*$', 'evidence: ' + json.dumps(statement), text)
        start = text.index('reverify:\n'); end = text.index('\n---', start)
        text = text[:start] + ('reverify:\n'
            '  - "bash tools/run_python_project_data.sh ' + PREFIX + 'review.py"\n'
            '  - "bash tools/project_data_run.sh prove -v -Iperl t/actionir_compiler_source_membership.t"\n'
            '  - "Historical .0.2.2.2.1 repair is frozen at5b4a9a8; all291 original hashes remain exact."') + text[end:]
        text += ('\nIndependent .0.2.2.2.2 recurs the corrected committed membership without production overlays. '
            'The focused checkpoint descriptions above retain their historical boundaries. The current '
            '77-command proof includes original public channels, both callable populations, default-query '
            'snapshots and all22 complete consumers. Exact staged canonical receipt/normal hooks gate '
            'membership parent landing. Precise selected-occurrence replacement, recurring registration, '
            'diagnostic origin, comments and all-contract/backend readiness remain separate.\n')
        path.write_text(text)
    path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'; text = path.read_text()
    start = text.index('- ID: `' + OWNER + '`'); end = text.index('\n- ID:', start + 1)
    block = text[start:end]; assert 'Status: `in_progress`' in block
    block = block.replace('Status: `in_progress`', 'Status: `done`', 1)
    block += '\n  Verified focused result: ' + statement + '\n'
    block += '  Owned reviewer defect (fixed): Initial reviewer references nonexistent grouped-cause.json and exits1 before grading. Exact source/actual merged error/preflight identity are retained; original-filename/line-cache source replay recurs the same CalledProcessError. Sole correction reads the already retained cause-observations.json; complete31-control reviewer passes. No product, input-channel or oracle change.\n'
    block += '  Canonical landing condition: Exact staged canonical receipt and normal hooks are mandatory before this intended done state lands. A failed gate leaves membership unaccepted and requires retained failure/repair ownership.\n'
    block += '  Commit: `' + SUBJECT + '` (Git owns identity).\n  Next: ' + next_action + '\n\n'
    for label, detail in (
        ('REPRODUCE / ISSUE', 'Complete original compiler RED38/signature10/grouped114 recur from historical channels; fresh exact committed oracles pass without overlays.'),
        ('ROOT CAUSE (WHY + WHERE)', 'Private compiler membership retains real source-bound references and exact lexical ownership; syntactic scans/default operand policy remain separate. Success values alone cannot establish event exclusion.'),
        ('FIX', 'Acceptance changes evidence, teaching and continuity only; all original production and Perl fixtures remain activation-exact.'),
        ('ADDRESSED (verified)', 'Original41 compiler groups/225 signature and789 grouped assertions reach each seed; full public/native/fresh/origin/metadata/default channels recur at their exact scope.'),
        ('NO REGRESSION', 'All22 unchanged direct consumers retain1644 ordered groups/full Phase01035. Exact canonical receipt and normal hooks gate membership closeout.'),
        ('LOCKSTEP', 'Book58/five exact examples/nine RED; original291 hashes/five RED;31 evidence RED; claim/Knowledge/task/index/roadmaps/live/resume/bounded histories agree. Later replacement/origin/comments remain owned.'),
    ):
        block += '- [x] **' + label + '** — ' + detail + '\n'
    text = text[:start] + block + text[end:]
    # Parent completion is part of this candidate and cannot land without its exact receipt.
    for suffix in ('.2', '.2.2', '.2.2.2'):
        parent = BASE + suffix; start = text.index('- ID: `' + parent + '`')
        end = text.index('\n- ID:', start + 1); block = text[start:end]
        assert '  Status: `active`' in block
        block = block.replace('  Status: `active`', '  Status: `done`', 1)
        block = block.replace('- [ ] **', '- [x] **')
        block += '\n  Final closeout: Independent ' + OWNER + ' verifies the complete corrected committed membership; exact staged canonical receipt and normal hooks are mandatory before this done state lands. Earlier open/blocker statements retain their dated checkpoint context. Replacement/origin/comments/recurring remain separate.\n'
        text = text[:start] + block + text[end:]
    for suffix in ('2', '2.2', '2.2.2', '2.2.2.2'):
        identity = BASE + '.' + suffix
        text = replace(r'^\| 43\.4\.2\.0\.' + re.escape(suffix) + r' \|.*$',
            '| 43.4.2.0.' + suffix + ' | `' + identity + '` | `done` | Complete committed membership verified; exact canonical receipt gates landing. |', text)
    text = text.replace('## Verification Log\n', '## Verification Log\n\nOctober8 `' + OWNER + '`: ' + statement + '\n', 1)
    text = text.replace('## Commit Log\n', '## Commit Log\n\n- `' + SUBJECT + '` — independent membership acceptance; exact canonical receipt gates landing. Git owns identity.\n', 1)
    text = text.replace('## Changelog\n', '## Changelog\n\n- `2026-10-08`: .0.2.2.2.2 independently accepts corrected committed membership; exact receipt gates parent closure and precise replacement follows.\n', 1)
    path.write_text(text)
    for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
        path = ROOT / name; path.write_text(replace(r'^\| Expressive `\.spec` self-containment \|.*$',
            '| Expressive `.spec` self-containment | `active: precise selected replacement next` | ' + statement + ' | ' + next_action + ' |', path.read_text()))
    path = ROOT / 'docs/TASK_TREE.md'; path.write_text(replace(r'^\| `SPEC-LANGUAGE-SELF-CONTAINMENT` \|.*$',
        '| `SPEC-LANGUAGE-SELF-CONTAINMENT` | `active: precise selected replacement next` | `.spec language evolution / expressive self-containment and alternate authoring profiles` | ' + statement + ' Next: ' + next_action + ' | [docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md](docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md) |', path.read_text()))
    records = {
        'CHANGES.md': statement,
        'DEVELOPMENT_NOTES.md': ('Independent membership acceptance uses exact committed inputs and complete historical/public/default/consumer oracles. Correct values do not establish source ownership. Exact staged canonical receipt gates closure; selected-occurrence replacement remains separate. Detailed proof and limits: [' + OWNER + '](' + CLAIM + ').'),
    }
    for name, record in records.items():
        path = ROOT / name; text = path.read_text(); offset = text.index('\n## ')
        path.write_text(text[:offset] + '\n## 2026-10-08 — Accept committed compiler membership\n\n' + record + '\n' + text[offset:])
    path = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'; text = path.read_text()
    for title, value, following in (
        ('Current Activity', 'Full PNT: complete committed membership accepted at its receipt-gated boundary; precise selected replacement next.', 'Latest Completed Slice'),
        ('Latest Completed Slice', '`' + OWNER + '` — ' + statement, 'Next Action'),
        ('Next Action', next_action, 'Recent Completions'),
    ):
        text, count = re.subn(r'(## ' + title + r'\n\n).*?(\n## ' + following + r')', lambda m: m[1] + value + '\n' + m[2], text, flags=re.S)
        assert count == 1
    recent = text.split('## Recent Completions\n\n', 1)[1].split('\n## History', 1)[0]
    rows = [r for r in recent.splitlines() if r.startswith('- `')]
    rows.insert(0, '- `' + OWNER + '` — committed77 commands/compiler41/public120+18+36/default72/consumer1644; canonical receipt gates membership closure.')
    text = re.sub(r'(## Recent Completions\n\n).*?(\n## History)', lambda m: m[1] + '\n'.join(rows[:16]) + '\n' + m[2], text, flags=re.S); path.write_text(text)
    path = ROOT / 'MEMORY.md'; text = path.read_text()
    for field, value in {
        'latest_completed_leaf': '`' + SUBJECT + '`.',
        'active_work_unit': '`' + OWNER + '` (done) — independent committed membership acceptance.',
        'next_action': next_action,
        'in_flight_uncommitted': 'None; intended clean post-landing handoff. Complete immutable membership/history/book/claim checks and exact staged canonical receipt/normal hooks gate this commit. Precise replacement follows; other owners remain open.',
    }.items(): text = replace(r'^- ' + field + r':.*$', '- ' + field + ': ' + value, text)
    assert len(text.encode()) <= 8192 and len(text.splitlines()) <= 60; path.write_text(text)
    paths = {e['path'] for e in read(PRIOR_CLAIM)['claims'][0]['durability']['inputs']}
    paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if p.is_file())
    paths.update(e['path'] for e in read(PREFIX + 'book-inputs.json')['entries'])
    paths.add(PRIOR_CLAIM)
    bindings = []
    for path in sorted(paths):
        source = ROOT / path; assert source.is_file() and not source.is_symlink(), path
        bindings.append({'path': path, 'sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
            'role': 'producer' if source.suffix in ('.py', '.pl', '.pm', '.sh', '.t') else 'input'})
    scope = ('Independent bounded membership acceptance at exact5b4a9a8ca2203f651d3c9d3a36cc9836c30a5375. '
        'All5018 regular Git supplied inputs reconstruct from object/byte/hash/mode manifests;77 commands '
        'guard every input before and after without overlays. Gitlinks/nonregular payloads excluded '
        'without implementation inspection; this supplied superset is not minimal observed IO. '
        'Compiler original36 literal cases plus original authority/value guards,27 signature rows and72 '
        'grouped rows retain exact authored assertions; no universal grammar/all174-contract claim. '
        'Original22 public cases retain all channels under three seeds;20 have authored successful native/fresh '
        'value oracles and unsupported_nested/raw_operand remain explicitly unassessed. Three plain callable '
        'and six grouped callable sources retain every corrected channel;72 default-query snapshots stay '
        'byte-identical. Twenty-two complete consumer files retain exact plans/group order including '
        'Phase01035. Original38-group membership,10-assertion signature and114-assertion grouped RED recur '
        'from immutable retained captures/producers; current correction never overwrites them. '
        'Five-example public render retains all58 source inputs/capsule/actual HTML/channels and nine '
        'effective denials. Actual fifth source/value equals the grouped public dot/fixed-y case. '
        'Original291 hashes freeze mode/revision only at5b4a9a8. Necessary read-only OS/Perl/Python/mdBook '
        'access; all project data local/same-volume. Exact staged canonical receipt/normal hooks are the '
        'separate landing authority, not inferred from focused proof. Exact initial reviewer/source/merged '
        'failure and partial preflight source identity survive; original-filename/line-cache replay '
        'recurs the actual absent-artifact rejection. Only the reference to already retained '
        'cause-observations.json changes, verified by exact inverse; complete corrected reviewer passes. '
        'No source/test/CI/hook/dependency '
        'change, new grammar/backend admission, readiness waiver or closure of replacement/registration/'
        'diagnostic origin/comments. Other repositories read-only and dependency black boxes respected.')
    claim = {'version': 1, 'owner': OWNER, 'claims': [{
        'name': 'independent-committed-compiler-membership', 'statement': statement, 'scope': scope,
        'rederive': {'status': 'checked', 'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + suffix for suffix in (
            'capture.py', 'review.py', 'freeze.py', 'preflight.py', 'instrument-controls.py', 'book.py --review')),
            'granularity': json.dumps(proof, sort_keys=True), 'result': statement},
        'falsify': {'status': 'checked', 'hypothesis': 'Successful returned values, incomplete populations or forged metadata/input channels can conceal membership defects.',
            'oracle': 'Original pre-repair authored literal/argument/occurrence/reference/error and callable/grouped roles, complete corrected public channels and72 unchanged default snapshots. Real source origins distinguish data events independently of successful values. Complete ordered consumer TAP/Phase0 retains original scope.',
            'red_control': 'Historical membership38/signature10/grouped114 RED recur at original producer boundaries. Thirty-one effective incomplete/reordered/exit/guard/channel/producer/TAP/source/AST/origin/metadata/native/fresh/default/consumer/input corruptions reject. Five historical mode/revision/hash/statement/input corruptions and nine actual-render corruptions reject. Exact initial missing-artifact rejection recurs from retained producer with original filename/line cache; sole corrected reference inverse and complete positive review pass.'},
        'durability': {'status': 'checked', 'mode': 'live', 'inputs': bindings}}]}
    raw = json.dumps(claim, indent=2) + '\n'; assert len(raw.encode()) <= 131072
    (ROOT / CLAIM).write_text(raw)
    (ROOT / 'git_message_brief.txt').write_text(SUBJECT + '\n\n' + statement + '\n\n' + next_action + '\n')
    print(statement); print('Bound claim inputs:', len(bindings))


if __name__ == '__main__':
    main()
