"""Publish the focused grouped-role correction after all required proof completes."""
from pathlib import Path
import hashlib
import importlib.util
import json
import re

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1'
NEXT = OWNER.rsplit('.', 1)[0] + '.2'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
PREVIOUS = 'docs/checkpoints/' + OWNER.rsplit('.', 1)[0] + '-'
PRIOR_CLAIM = 'docs/claims/' + OWNER.rsplit('.', 1)[0] + '.0.json'
SUBJECT = OWNER + ' - preserve callable grouped-pattern membership'
CLAIM = 'docs/claims/' + OWNER + '.json'


def read(path):
    return json.loads((ROOT / path).read_bytes())


def replace(pattern, value, text):
    text, count = re.subn(pattern, lambda m: value, text, flags=re.M)
    assert count == 1, (pattern, count)
    return text


def main():
    proof, history, book, instrument, publication = [read(PREFIX + suffix) for suffix in (
        'verification.json', 'freeze.json', 'book-verification.json', 'instrument-controls.json', 'book-controls.json')]
    assert proof['complete'] and history['complete'] and instrument['complete'] and publication['complete']
    before, after = proof['epochs']['before'], proof['epochs']['after']
    assert before['compiler']['failed_assertions'] == 114 and before['compiler']['assertions'] == 903
    assert after['compiler']['groups'] == 41 and after['compiler']['assertions'] == 789
    assert before['supplied_inputs'] == after['supplied_inputs'] == 4982
    assert len(after['consumers']['plans']) == 22 and after['consumers']['plans'][15] == 1035
    assert len(proof['controls']) == 21 and history['bound_inputs'] == 247 and len(history['controls']) == 5
    assert book['book_inputs'] == 58 and book['exact_examples'] == 5 and len(book['controls']) == 9
    assert len(instrument['controls']) == 3 and publication['corrected_effective_controls'] == 9
    spec = importlib.util.spec_from_file_location('grouped_repair_publication', ROOT / (PREFIX + 'book.py'))
    renderer = importlib.util.module_from_spec(spec); spec.loader.exec_module(renderer)
    observed = read(PREFIX + 'after-observations.json')
    for run in observed['runs']:
        if run['kind'] == 'public':
            rows = json.loads(renderer.decode(run['stdout']))
            assert renderer.EXAMPLES[-1] == rows[0]['source'] + '\n# result: 1'
            assert rows[0]['native']['value'] == rows[0]['fresh']['value'] == 1
    statement = (
        'Exact78012b1e7 snapshots/common authored fixture/cases/default observer supply4982 inputs per epoch; '
        'only after replaces MethodExpr/SourceMembership. Fifteen guarded commands retain original114 '
        'RED/903 assertions and corrected789 GREEN per seed0/1/42 across72 rows. All original40 groups/'
        'signature225 assertions remain intact; total41 groups pass. Six original grouped public sources '
        'preserve every source/AST/lowering/emitted/dump/native/fresh/error channel (36 route values); '
        'x,y only excludes its real regex-data origin and removes its false event from helper/canonical '
        'lists with their counts/hits. All72 default query/view/numeric/ordinary-scan channels remain '
        f"byte-identical. Twenty-two unchanged consumers pass{after['consumers']['groups']} groups, "
        'including original1473/Phase01035. Twenty-one evidence controls/five historical controls/'
        'nine publication controls reject; exact247 prior hashes freeze mode/revision only. Book58/'
        'five exact examples passes. Original metadata-oracle rejection/source and ineffective newline '
        'publication control/render are retained; exact corrected oracles accept. Default MethodExpr/'
        'ordinary scanners/splitter/other tests/contracts/CI/dependencies remain unchanged. Focused '
        'repair closes no parent; fresh committed canonical .0.2.2.2.2 remains required.')
    next_action = ('Activate ' + NEXT + ' from clean corrected HEAD. Independently recur original membership/'
        'public/value channels, callable and grouped-pattern source/metadata/default-query oracles from '
        'committed inputs without production overlays; verify unchanged consumers and exact staged canonical '
        'CI/normal hooks before closing membership parents. Then precise selected replacement .0.3; '
        'recurring .0.4, diagnostic origin .7.2.2.1 and comments .7.3 remain owned. Preserve historical hashes.')
    for name in ('perl-callable-grouped-pattern-membership', 'perl-source-membership-callable-signature-precedence',
                 'perl-compiler-source-membership', 'perl-executable-source-membership'):
        path = ROOT / ('docs/knowledge/' + name + '.md'); text = path.read_text()
        text = replace(r'^date:.*$', 'date: 2026-10-08', text)
        text = replace(r'^status:.*$', 'status: Focused callable grouped-role correction verified; fresh committed canonical acceptance .0.2.2.2.2 remains open', text)
        text = replace(r'^evidence:.*$', 'evidence: ' + json.dumps(statement), text)
        start = text.index('reverify:\n'); end = text.index('\n---', start)
        text = text[:start] + ('reverify:\n'
            '  - "bash tools/project_data_run.sh prove -v -Iperl t/actionir_compiler_source_membership.t t/multiline_helper_pattern_validation.t"\n'
            '  - "bash tools/run_python_project_data.sh ' + PREFIX + 'review.py"\n'
            '  - "Original diagnosis at0f31461d6 and checkpoint78012b1e7 remain historical; preserve their producers, channels and hashes."') + text[end:]
        if name == 'perl-callable-grouped-pattern-membership':
            text = text.replace('That query\nstill calls', 'At the original0f31461d6 boundary, that query\ncalled')
            text = text.replace('inside the regex remains selected.', 'inside the regex remained selected at that boundary.')
            text = text.replace('origin45..59 lies within the real grouped pattern at43..64 or43..63 but is selected.',
                'origin45..59 lay within the real grouped pattern at43..64 or43..63 and was selected.')
            text = text.replace('Native and independently fresh emitted values remain1',
                'At the original0f31461d6 boundary, native and independently fresh emitted values remained1')
            text = text.replace('while the descriptor reports', 'while the descriptor reported')
            text = text.replace('`.0.2.2.2.1` owns\ncompiler-specific', '`.0.2.2.2.1` completes\ncompiler-specific')
        if name == 'perl-source-membership-callable-signature-precedence':
            text = text.replace('SourceMembership now recognizes exact unquoted', 'The .0.2.2.1 delimiter-loop repair recognizes exact unquoted')
            text = text.replace('No MethodExpr or StatementSplit change,', 'For that delimiter-loop repair alone, no MethodExpr or StatementSplit change,')
        text = text.replace('The independently observed grouped-pattern interaction remains open; retrieve [[perl-callable-grouped-pattern-membership]]. The delimiter-loop repair alone does not protect its separate helper-role query.',
            'The original grouped-pattern diagnosis is retained in [[perl-callable-grouped-pattern-membership]]. The delimiter-loop repair alone did not protect its separate helper-role query; focused .0.2.2.2.1 now does.')
        text += ('\nThe focused .0.2.2.2.1 correction makes compiler membership explicitly request exact '
            'callable delimiter ownership from the helper-role traversal. The default query/structural view/'
            'numeric discriminator and ordinary syntactic packets retain all72 original channels. Only '
            'the false grouped-pattern event and its helper/canonical aggregate metadata are removed; '
            'source/AST/substitution/emitted/dump/native/fresh channels stay byte-identical on the six '
            'original public sources. Fresh committed canonical .0.2.2.2.2 is still required before '
            'membership closes; this is no new grammar or all-contract/backend admission.\n')
        path.write_text(text)
    path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'; text = path.read_text()
    start = text.index('- ID: `' + OWNER + '`'); end = text.index('\n- ID:', start + 1)
    block = text[start:end]; assert 'Status: `in_progress`' in block
    block = block.replace('Status: `in_progress`', 'Status: `done`', 1)
    block += '\n  Verified focused result: ' + statement + '\n  Commit: `' + SUBJECT + '` (Git owns identity).\n  Next: ' + next_action + '\n\n'
    for label, detail in (
        ('REPRODUCE / ISSUE', 'Authored72-row fixture precedes production: original38 affected rows fail114 source/role/occurrence assertions under every seed, while all original40 compiler groups pass. Actual public descriptor retains a false regex-data ASSIGN despite native/fresh value1.'),
        ('ROOT CAUSE (WHY + WHERE)', 'MethodExpr::_helper_pattern_ranges probes operator-named signature closers as host quote delimiters before discovering body helper roles. SourceMembership had protected only its own range loop; grouped numeric fallback keeps established precedence.'),
        ('FIX', 'Private opt-in query mirrors exact unquoted signature pipes with invocation-local state; only SourceMembership requests it. Default structural/operand/numeric consumers preserve original policy; no masking/reparse/equal-raw pairing or public fields.'),
        ('ADDRESSED (verified)', 'Original114 RED/903 assertions becomes789 GREEN; compiler41/original40/signature225 reach under all three seeds. Actual primitive events/arguments/origins/order/caller errors retain authored authority; original six-source public values/channels and default72 snapshots remain exact.'),
        ('NO REGRESSION', f"Twenty-two unchanged consumers pass{after['consumers']['groups']} full groups including original1473/Phase01035 and all grouped-helper compatibility files; syntax checks pass. Sole production inverse verifies MethodExpr opt-in and compiler call; splitter/other tests unchanged. No parent closure follows."),
        ('LOCKSTEP', 'Book58/five exact source/value examples/nine observed RED; exact247 historical hashes/five RED; claims/Knowledge/task/index/roadmaps/live/resume and bounded histories align. Exact initial reviewer metadata rejection and ineffective newline publication control/render/source remain retained; corrected oracles preserve complete channel and boundary guards.'),
    ):
        block += '- [x] **' + label + '** — ' + detail + '\n'
    text = text[:start] + block + text[end:]
    text = replace(r'^\| 43\.4\.2\.0\.2\.2\.2\.1 \|.*$',
        '| 43.4.2.0.2.2.2.1 | `' + OWNER + '` | `done` | Compiler grouped roles repaired; original114 RED/corrected789 GREEN and unchanged default/public/consumers. |', text)
    text = text.replace('## Verification Log\n', '## Verification Log\n\nOctober8 `' + OWNER + '`: ' + statement + '\n', 1)
    text = text.replace('## Commit Log\n', '## Commit Log\n\n- `' + SUBJECT + '` — focused repair; fresh committed canonical acceptance remains open. Git owns identity.\n', 1)
    text = text.replace('## Changelog\n', '## Changelog\n\n- `2026-10-08`: .0.2.2.2.1 corrects compiler-only grouped-pattern roles with authored original RED and unchanged default/public consumers; .2 requires fresh committed canonical acceptance.\n', 1)
    path.write_text(text)
    for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
        path = ROOT / name; path.write_text(replace(r'^\| Expressive `\.spec` self-containment \|.*$',
            '| Expressive `.spec` self-containment | `active: complete committed membership acceptance next` | ' + statement + ' | ' + next_action + ' |', path.read_text()))
    path = ROOT / 'docs/TASK_TREE.md'; path.write_text(replace(r'^\| `SPEC-LANGUAGE-SELF-CONTAINMENT` \|.*$',
        '| `SPEC-LANGUAGE-SELF-CONTAINMENT` | `active: complete committed membership acceptance next` | `.spec language evolution / expressive self-containment and alternate authoring profiles` | ' + statement + ' Next: ' + next_action + ' | [docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md](docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md) |', path.read_text()))
    for name in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
        path = ROOT / name; text = path.read_text(); offset = text.index('\n## ')
        path.write_text(text[:offset] + '\n## 2026-10-08 — Preserve callable grouped-pattern membership\n\n' + statement + '\n' + text[offset:])
    path = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'; text = path.read_text()
    for title, value, following in (
        ('Current Activity', 'Full PNT: focused compiler grouped-pattern membership repaired; committed canonical acceptance precedes precise replacement.', 'Latest Completed Slice'),
        ('Latest Completed Slice', '`' + OWNER + '` — ' + statement, 'Next Action'),
        ('Next Action', next_action, 'Recent Completions'),
    ):
        text, count = re.subn(r'(## ' + title + r'\n\n).*?(\n## ' + following + r')', lambda m: m[1] + value + '\n' + m[2], text, flags=re.S)
        assert count == 1
    recent = text.split('## Recent Completions\n\n', 1)[1].split('\n## History', 1)[0]
    rows = [r for r in recent.splitlines() if r.startswith('- `')]
    rows.insert(0, '- `' + OWNER + '` — grouped-role RED114/GREEN789; default72/public36/consumer' + str(after['consumers']['groups']) + '; fresh canonical next.')
    text = re.sub(r'(## Recent Completions\n\n).*?(\n## History)', lambda m: m[1] + '\n'.join(rows[:16]) + '\n' + m[2], text, flags=re.S); path.write_text(text)
    path = ROOT / 'MEMORY.md'; text = path.read_text()
    for field, value in {
        'latest_completed_leaf': '`' + SUBJECT + '`.',
        'active_work_unit': '`' + OWNER + '` (done) — bounded compiler callable/grouped-role correction.',
        'next_action': next_action,
        'in_flight_uncommitted': 'None; intended clean focused post-landing handoff. Original RED/corrected GREEN/default/public/full consumer/book/claim checks complete. Fresh committed canonical acceptance starts after this commit; membership parents remain open.',
    }.items(): text = replace(r'^- ' + field + r':.*$', '- ' + field + ': ' + value, text)
    path.write_text(text)
    paths = {e['path'] for e in read(PRIOR_CLAIM)['claims'][0]['durability']['inputs']}
    paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if p.is_file())
    paths.update(e['path'] for e in read(PREFIX + 'book-inputs.json')['entries'])
    paths.update(observed['runs'][-1]['command'][5:])
    paths.update((PRIOR_CLAIM, 'docs/knowledge/perl-callable-grouped-pattern-membership.md',
                  PREVIOUS + 'cause-observations.json', PREVIOUS + 'cause-probe.pl', PREVIOUS + 'grouped-review.py',
                  PREVIOUS + 'observations.json'))
    bindings = []
    for path in sorted(paths):
        source = ROOT / path; assert source.is_file() and not source.is_symlink(), path
        bindings.append({'path': path, 'sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
            'role': 'producer' if source.suffix in ('.py', '.pl', '.pm', '.sh', '.t') else 'input'})
    scope = ('Bounded compiler-only callable/grouped-pattern membership correction at exact78012b1e78bb114a41f54873f30ca63c421568c8. Complete4980 regular Git supplied supersets plus exactly common authored fixture/cases/default observer reconstruct from retained object/hash/size/mode manifests; after only replaces MethodExpr/SourceMembership. Each command guards all4982 supplied inputs; this is not minimal observed IO. Gitlinks/nonregular payloads excluded without inspection. Original40 compiler groups and unchanged27-row signature225 authority remain intact. The72 new rows are authored scanner/role/occurrence controls, not universal grammar or all174 contracts. Thirty-eight original bad rows fail exactly114 assertions under all three seeds; zero/rest/nested/host/numeric controls distinguish lexical ownership. Six original full public sources retain every field except the actual falsely selected regex-data origin/range and false helper/canonical event plus its aggregate counts/hits. All typed source/AST/lowering/emitted/dump/native/fresh/error channels remain byte-identical before/after, with36 route values per epoch. All72 default-query/structural-view/numeric/ordinary set and return snapshots remain byte-identical; invocation-local compiler opt-in does not change default MethodExpr consumers. Twenty-two unchanged consumer files include the original1473 groups/full Phase01035 and current grouped-helper compatibility. Exact247 checkpoint hashes freeze mode/revision only at78012b1e7. Book58-input capsule/render/HTML carries five exact examples; the new fifth source equals the real six-source public dot/fixed-y case under every seed. Original initial reviewer rejects corrected metadata because its oracle omitted coupled lists/counts/hits; source and exact initial1218-byte failure JSON survive gzip retention, and rejection independently recurs under all three seeds before the exact corrected oracle accepts. Original render/control producer, full initial capsule/report and actual ineffective newline-control rejection remain retained; sole whitespace-aware control correction is checked and nine effective publication denials recur. Necessary read-only OS/Perl/Python/mdBook/toolchain access; all project data remains local/same-volume. This focused record closes no membership parent, public schema/grammar/backend admission, precise replacement, recurring registration, diagnostic origin, comments or readiness. Fresh committed canonical .0.2.2.2.2 remains required. Other repositories read-only; RGX/PGEN black boxes; no recovery/purge/verification waiver.')
    claim = {'version': 1, 'owner': OWNER, 'claims': [{
        'name': 'compiler-callable-grouped-pattern-membership', 'statement': statement, 'scope': scope,
        'rederive': {'status': 'checked', 'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + suffix for suffix in (
            'capture.py before', 'capture.py after', 'review.py', 'freeze.py', 'preflight.py', 'channel-diff.py',
            'instrument-controls.py', 'book.py --review', 'book-controls.py')),
            'granularity': json.dumps(proof, sort_keys=True), 'result': statement},
        'falsify': {'status': 'checked', 'hypothesis': 'Signature quote suffixes still hide grouped helper roles, or successful values/default-query changes/forged or truncated channels could falsely establish membership repair.',
            'oracle': 'The72 independent authored source/range/argument/occurrence oracles predate the two production deltas. Original38 rows fail114 role/selection/origin assertions under seeds0/1/42 while all original40 groups pass; corrected789 assertions and preserved225 signature assertions reach complete41 plans. Original six public sources distinguish false regex-data origins/helper/canonical events from unchanged source/AST/lowering/emitted/dump/native/fresh values1; healthy x,z/rest-y channels remain exact. Seventy-two retained complete original default query/view/numeric/syntactic snapshots, exact original16 consumer group names/plans and full Phase0 reach retain authority.',
            'red_control': 'Actual original114-assertion regression RED is retained at immutable original production with common authored inputs. Twenty-one effective capture/input/source/AST/origin/metadata/native/fresh/default-query/TAP/Phase0 corruptions reject. Five exact historical controls and nine effective actual-render controls reject. Initial metadata-oracle rejection recurs from exact retained source under three seeds; corrected complete event/count/hit oracle accepts all original channels. Original ineffective publication control and source/render inputs recur, followed by sole whitespace-aware control correction and observed RED.'},
        'durability': {'status': 'checked', 'mode': 'live', 'inputs': bindings}}]}
    raw = json.dumps(claim, indent=2) + '\n'; assert len(raw.encode()) <= 131072
    (ROOT / CLAIM).write_text(raw)
    (ROOT / 'git_message_brief.txt').write_text(SUBJECT + '\n\n' + statement + '\n\n' + next_action + '\n')
    print(statement); print('Bound claim inputs:', len(bindings))


if __name__ == '__main__':
    main()
