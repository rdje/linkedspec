"""Publish the bounded callable repair after all retained focused proof completes."""
from pathlib import Path
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.1'
NEXT = OWNER.rsplit('.', 1)[0] + '.2'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
PREVIOUS = 'docs/checkpoints/' + OWNER.rsplit('.', 1)[0] + '-'
SUBJECT = OWNER + ' - preserve callable signature membership'
CLAIM = 'docs/claims/' + OWNER + '.json'
STREAM = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'


def read(path):
    return json.loads((ROOT / path).read_bytes())


def replace(pattern, replacement, text):
    text, count = re.subn(pattern, lambda m: replacement, text, flags=re.M)
    assert count == 1, (pattern, count)
    return text


def node(text, owner, change):
    start = text.index('- ID: `' + owner + '`'); end = text.index('\n- ID:', start + 1)
    return text[:start] + change(text[start:end]) + text[end:]


def main():
    proof = read(PREFIX + 'verification.json'); book = read(PREFIX + 'book-verification.json')
    history = read(PREFIX + 'freeze.json'); instrument = read(PREFIX + 'instrument-controls.json')
    assert proof['complete'] and history['complete'] and instrument['complete']
    before, after = proof['epochs']['before'], proof['epochs']['after']
    assert before['compiler']['failed_assertions'] == 10 and after['compiler']['groups'] == 40
    assert after['consumers']['files'] == 16 and after['consumers']['plans'][-1] == 1035
    assert len(proof['controls']) == 21 and history['bound_inputs'] == 318 and len(history['controls']) == 5
    assert book['book_inputs'] == 58 and book['exact_examples'] == 4 and len(book['controls']) == 7
    statement = (
        f"Exact {proof['revision'][:9]} regular Git input snapshots plus declared common fixture/probe "
        f"overlays supply {before['supplied_inputs']} inputs before and {after['supplied_inputs']} after; "
        "only the after tree replaces SourceMembership. Fourteen complete guarded commands retain "
        "original compiler RED and corrected GREEN under seeds0/1/42. All original39 compiler groups "
        "stay intact; the new27-row signature group fails ten authored assertions before and passes225 "
        "after, reaching40 total groups per seed. Original x,y fails native/fresh before; all three "
        "original public sources return ok on both routes under all three seeds (18 values), with "
        "identical source/typed AST and all healthy x,z/rest-y channels unchanged. The unchanged "
        "callable fixture loads generated source before its original execution abort, then passes "
        f"all11 groups after. Sixteen unchanged consumers pass{after['consumers']['groups']} ordered "
        f"groups including full Phase0{after['consumers']['plans'][-1]}. Twenty-one effective evidence "
        "controls/five historical controls/seven publication controls reject; all318 prior checkpoint "
        "hashes freeze mode/revision only. Full book58-input render preserves four exact examples. "
        "The new reviewer's relative-runpy prefix rejection and original bytes are retained, followed "
        "by absolute-prefix correction. MethodExpr, StatementSplit, original callable fixture, public "
        "schema/dependencies/CI/hooks remain unchanged. Focused repair is complete; fresh committed "
        "canonical .0.2.2.2 remains required before membership closure. Replacement, diagnostic origin "
        "and comments retain their owners.")
    next_action = ('Activate ' + NEXT + ' from clean committed corrected HEAD. Independently recur '
        'the original compiler/public membership population plus callable regression with no production '
        'overlays; run exact staged canonical CI and normal hooks before closing membership .0.2. '
        'Then proceed to exact selected residual replacement .0.3. Preserve historical claims and '
        'their original hashes; diagnostic origin .7.2.2.1, recurring .0.4 and comments .7.3 remain owned.')
    path = ROOT / 'docs/knowledge/perl-source-membership-callable-signature-precedence.md'
    text = path.read_text()
    text = replace(r'^status:.*$', 'status: Focused repair verified; fresh committed canonical acceptance .0.2.2.2 remains open', text)
    text = replace(r'^evidence:.*$', 'evidence: ' + json.dumps(statement), text)
    path.write_text(text)
    for name in ('perl-compiler-source-membership', 'perl-executable-source-membership'):
        path = ROOT / ('docs/knowledge/' + name + '.md'); text = path.read_text()
        text = replace(r'^status:.*$', 'status: Compiler integrated and callable signature precedence repaired; canonical membership acceptance remains open', text)
        text = replace(r'^evidence:.*$', 'evidence: ' + json.dumps(
            'Original private .2.0 and integrated .2.1 measurements remain historical at their exact boundaries. '
            'Focused .0.2.2.1 retains actual original ten-assertion RED, corrected compiler40/new225 assertions per seed, '
            'original3 public sources/18 native-fresh values and unchanged sixteen-consumer1473 groups/Phase01035. '
            'All318 preceding checkpoint hashes freeze without refresh. Fresh committed canonical .0.2.2.2 remains required.'), text)
        text = text.replace('  - "bash tools/run_python_project_data.sh ' + PREVIOUS + 'review.py"',
                            '  - "bash tools/run_python_project_data.sh ' + PREFIX + 'review.py"')
        text += ('\nCallable signature precedence is repaired by .0.2.2.1; retrieve '
                 '[[perl-source-membership-callable-signature-precedence]] for original RED, exact '
                 'delimiter ownership and full unchanged consumer proof. Prior .0.2.2.0 is '
                 'historical at484fe128f with all318 original hashes unchanged; do not run its '
                 'current-root producer against corrected source. Fresh .0.2.2.2 still owns '
                 'canonical membership acceptance.\n')
        path.write_text(text)
    path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'; text = path.read_text()
    text = text.replace('and generated emission exits255 after four groups.',
                        'and the generated source loads before its execution throws an uncaught structured error; the fixture exits255 after four groups.')
    def complete(block):
        assert '  Status: `in_progress`' in block
        block = block.replace('  Status: `in_progress`', '  Status: `done`', 1)
        block += '\n  Verified focused result: ' + statement + '\n  Commit: `' + SUBJECT + '` (Git owns identity).\n  Next: ' + next_action + '\n\n'
        for label, detail in (
            ('REPRODUCE / ISSUE', 'New authored27-row fixture precedes production: original39 groups pass while ten header/body assertions fail under all three seeds; unchanged callable fixture aborts after generated module load.'),
            ('ROOT CAUSE (WHY + WHERE)', 'SourceMembership treats the unquoted signature closing pipe after y/q/etc. as a host quote opener, swallowing real return spans. AST/splitter remain correct.'),
            ('FIX', 'Invocation-local exact {| / closing-pipe precedence mirrors the unchanged splitter; protect only two delimiters and preserve genuine host quote ownership. Sole production delta is14 inserted lines.'),
            ('ADDRESSED (verified)', 'Compiler40 groups/new225 assertions per seed, original3 public sources/18 native/fresh values, identical AST/source and healthy channels; actual original producer RED and twenty-one effective evidence denials are retained.'),
            ('NO REGRESSION', f"Sixteen unchanged direct suites reach{after['consumers']['groups']} exact ordered groups including callable11 and Phase01035; MethodExpr/StatementSplit/other production and tests retain committed bytes. No membership or new grammar admission follows."),
            ('LOCKSTEP', 'Book58 inputs/four exact examples/seven RED, exact318-hash historical freeze/five RED, claim/Knowledge/task/index/roadmaps/live/resume and bounded histories align. Reviewer relative-runpy failure retains original source and channels; corrected prefix accepts both invocation methods.'),
        ):
            block += '- [x] **' + label + '** — ' + detail + '\n'
        return block
    text = node(text, OWNER, complete)
    text = replace(r'^\| 43\.4\.2\.0\.2\.2\.1 \|.*$',
        '| 43.4.2.0.2.2.1 | `' + OWNER + '` | `done` | Exact callable signature precedence; original RED/corrected GREEN and unchanged consumers. |', text)
    text = text.replace('## Verification Log\n', '## Verification Log\n\nOctober7 `' + OWNER + '`: ' + statement + '\n', 1)
    text = text.replace('## Commit Log\n', '## Commit Log\n\n- `' + SUBJECT + '` — focused repair; fresh committed canonical acceptance remains open. Git owns identity.\n', 1)
    text = text.replace('## Changelog\n', '## Changelog\n\n- `2026-10-07`: .0.2.2.1 corrects callable signature delimiter precedence with original RED and unchanged full consumer proof; .0.2.2.2 requires fresh committed canonical acceptance before membership closes.\n', 1)
    path.write_text(text)
    for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
        path = ROOT / name
        path.write_text(replace(r'^\| Expressive `\.spec` self-containment \|.*$',
            '| Expressive `.spec` self-containment | `active: corrected membership acceptance next` | ' + statement + ' | ' + next_action + ' |', path.read_text()))
    path = ROOT / 'docs/TASK_TREE.md'
    path.write_text(replace(r'^\| `SPEC-LANGUAGE-SELF-CONTAINMENT` \|.*$',
        '| `SPEC-LANGUAGE-SELF-CONTAINMENT` | `active: corrected membership acceptance next` | `.spec language evolution / expressive self-containment and alternate authoring profiles` | ' + statement + ' Next: ' + next_action + ' | [docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md](docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md) |', path.read_text()))
    for name, title, content in (
        ('CHANGES.md', '2026-10-07 — Preserve callable signature membership precedence', statement),
        ('DEVELOPMENT_NOTES.md', '2026-10-07 — Callable signature delimiters precede host quote suffix recognition',
         'Existing operator-suffix recognition cannot authorize the unquoted signature closer. Mirror the unchanged splitter with invocation-local state; genuine host quotes consume their payload first. Protect only exact delimiters, preserving original source/body parsing and real producer references. The original failed callable fixture loads its emitted module; the structured execution exception, rather than emission itself, aborts it. ' + statement)):
        path = ROOT / name; text = path.read_text(); offset = text.index('\n## ')
        path.write_text(text[:offset] + '\n## ' + title + '\n\n' + content + '\n' + text[offset:])
    path = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'; text = path.read_text()
    for title, value, following in (
        ('Current Activity', 'Full PNT: callable signature membership repaired; fresh committed canonical acceptance precedes exact residual replacement.', 'Latest Completed Slice'),
        ('Latest Completed Slice', '`' + OWNER + '` — ' + statement, 'Next Action'),
        ('Next Action', next_action, 'Recent Completions'),
    ):
        text, count = re.subn(r'(## ' + title + r'\n\n).*?(\n## ' + following + r')',
                             lambda m: m[1] + value + '\n' + m[2], text, flags=re.S)
        assert count == 1
    recent = text.split('## Recent Completions\n\n', 1)[1].split('\n## History', 1)[0]
    rows = [r for r in recent.splitlines() if r.startswith('- `')]
    rows.insert(0, '- `' + OWNER + '` — callable signature RED10/GREEN225; compiler40/18 values/direct1473 groups; canonical acceptance next.')
    text = re.sub(r'(## Recent Completions\n\n).*?(\n## History)', lambda m: m[1] + '\n'.join(rows[:16]) + '\n' + m[2], text, flags=re.S)
    path.write_text(text)
    path = ROOT / 'MEMORY.md'; text = path.read_text()
    for field, value in {
        'latest_completed_leaf': '`' + SUBJECT + '`.',
        'active_work_unit': '`' + OWNER + '` (done) — bounded callable signature membership correction.',
        'next_action': next_action,
        'in_flight_uncommitted': 'None; intended clean focused post-landing handoff. Original RED/corrected GREEN, unchanged consumers/Phase0 and publication/claim checks complete. Fresh canonical acceptance starts only after this commit; membership remains open.',
    }.items():
        text = replace(r'^- ' + field + r':.*$', '- ' + field + ': ' + value, text)
    path.write_text(text)
    paths = {p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if p.is_file()}
    paths.update(e['path'] for e in read(PREFIX + 'book-inputs.json')['entries'])
    paths.update(p for p in subprocess.check_output(['git', 'ls-files', '-z', '--', 'perl'], cwd=ROOT).decode().split('\0') if p)
    paths.update(read(PREFIX + 'after-observations.json')['runs'][-1]['command'][5:])
    paths.update((
        't/actionir_compiler_source_membership.t', 'capability_conformance/callable_codeblock_contract.json',
        'capability_conformance/outward_descriptor_contract.json',
        'docs/knowledge/perl-source-membership-callable-signature-precedence.md',
        'docs/knowledge/perl-compiler-source-membership.md', 'docs/knowledge/perl-executable-source-membership.md',
        'docs/claims/' + OWNER.rsplit('.', 1)[0] + '.0.json',
        PREVIOUS + 'callable-review.py', PREVIOUS + 'observations.json', STREAM,
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-fresh.pl',
        'tools/project_data_run.sh', 'tools/project_data_env.sh', 'tools/run_python_project_data.sh',
        'tools/check_claim_verification.py'))
    bindings = []
    for path in sorted(paths):
        source = ROOT / path; assert source.is_file() and not source.is_symlink(), path
        bindings.append({'path': path, 'sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
                         'role': 'producer' if source.suffix in ('.py', '.pl', '.pm', '.sh', '.t') else 'input'})
    claim = {'version': 1, 'owner': OWNER, 'claims': [{
        'name': 'callable-signature-membership-precedence', 'statement': statement,
        'scope': 'Bounded Perl compiler lexical precedence repair only. Complete regular committed Git supplied supersets reconstruct from exact retained per-file object/hash/size/mode manifests at484fe128f. Both epochs add the same authored regression and transparent actual-compiler observer; after alone replaces SourceMembership. Each complete command guards all supplied input bytes and modes before/after. This is a supplied-input superset, not minimal observed IO. Gitlinks/nonregular payloads are excluded without implementation inspection. Original39 compiler groups, all other Perl production/tests, MethodExpr/StatementSplit and original callable fixture retain committed bytes. Source/AST/signature/body/schema/reference/error/ordinary-scanner contracts remain exact; original x,z/rest-y complete public channels remain identical. Original x,y native/fresh errors are independently authored RED, and all three original sources have successful native/fresh value oracles under three seeds. Sixteen unchanged consumers include full callable11 and Phase01035. Twenty-one effective evidence corruptions, five exact historical controls and seven actual-render controls reject. Prior318-input checkpoint freezes only mode/revision at484fe128f without refreshed hashes. Original relative-runpy review source and observed path rejection remain reproducible through the retained instrument. Full58-input publication capsule retains actual render channels/HTML/four examples. Original before channels remain immutable; do not recapture them with corrected source or refresh original checkpoint producers. Necessary read-only OS/Perl/Python/mdBook/toolchain access; all project outputs remain repository-local/same-volume. This focused record has no canonical success claim and closes no membership parent, grammar/backend admission, precise replacement, comment classification or diagnostic origin. Fresh committed canonical .0.2.2.2 is mandatory before membership closure; other repair owners remain open. Other repositories read-only; RGX/PGEN black boxes; no recovery/purge or verification waiver.',
        'rederive': {'status': 'checked',
            'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'capture.py before; bash tools/run_python_project_data.sh ' + PREFIX + 'capture.py after; bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'freeze.py; bash tools/run_python_project_data.sh ' + PREFIX + 'book.py --review; bash tools/run_python_project_data.sh ' + PREFIX + 'instrument-controls.py',
            'granularity': json.dumps(proof, sort_keys=True), 'result': statement},
        'falsify': {'status': 'checked',
            'hypothesis': 'A host-quote suffix can still swallow the callable signature closer, or forged/truncated source/AST/origin/value/TAP/input/publication channels could falsely establish the repair.',
            'oracle': 'The authored27-row compiler regression predates the sole14-line production delta. Original fixed y/tr/s/q/qq/qx/qr/m and quoted/pattern bodies fail ten assertions under every seed while all original39 groups pass. The unchanged callable fixture and three independently observed public sources distinguish a correctly typed AST with excluded real return origins from actual healthy native/fresh values. Exact full original consumer group names/plans and original healthy public channels remain authority.',
            'red_control': 'Actual original compiler ten-assertion RED and original callable execution abort are retained under exact immutable inputs; original x,y native/fresh fails under seeds0/1/42. Twenty-one effective evidence corruptions reject completeness, command order, capture identity, input guard, actual exit, channel hash, nested assertion/header reach and truncation, source/AST/origin/native/fresh/literal-range authority, full Phase0 plan, complete supplied population/declared overlay/production hash and sole production delta. Five historical corruptions and seven actual publication corruptions reject. The original relative-runpy reviewer path error recurs from its exact retained source, followed by normalized-prefix acceptance.'},
        'durability': {'status': 'checked', 'mode': 'live', 'inputs': bindings}}]}
    raw = json.dumps(claim, indent=2) + '\n'; assert len(raw.encode()) <= 131072
    (ROOT / CLAIM).write_text(raw)
    (ROOT / 'git_message_brief.txt').write_text(SUBJECT + '\n\n' + statement + '\n\n' + next_action + '\n')
    print(statement); print('Bound current claim inputs:', len(bindings))


if __name__ == '__main__':
    main()
