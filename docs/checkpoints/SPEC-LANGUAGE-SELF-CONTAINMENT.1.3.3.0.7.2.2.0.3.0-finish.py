"""Publish the verified diagnosis and a clean post-landing resume pointer."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
PARENT = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3'
OWNER = PARENT + '.0'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
CLAIM = 'docs/claims/' + OWNER + '.json'
SUBJECT = OWNER + ' - retain exact replacement diagnosis'
REVISION = 'fa9b7608ed9e49712129bb5456d75d118e7207a0'


def read(path):
    return json.loads((ROOT / path).read_bytes())


def replace(pattern, value, text):
    text, count = re.subn(pattern, lambda m: value, text, flags=re.M)
    assert count == 1, (pattern, count)
    return text


def main():
    proof, instrument, freeze, book = [read(PREFIX + suffix) for suffix in (
        'verification.json', 'instrument-verification.json', 'freeze.json', 'book-verification.json')]
    assert proof['complete'] and instrument['complete'] and freeze['complete']
    assert proof['regular_git_inputs'] == 5045 and proof['commands_per_capture'] == 44
    assert proof['authored_sources'] == 14 and proof['source_seed_pairs_per_capture'] == 42
    assert len(proof['actual_red_groups']) == proof['healthy_groups'] == 7
    assert sum(proof['consumer_plans']) == 144 and len(proof['controls']) == 20
    assert freeze['bound_inputs'] == 318 and len(freeze['controls']) == 5
    assert len(instrument['controls']) == 5 and book['book_inputs'] == 58
    assert book['exact_examples'] == 7 and len(book['controls']) == 11
    statement = (
        'Unchanged fa9b7608e supplies 5,045 regular Git inputs plus three explicit diagnosis overlays '
        'for each of two 44-command captures. Fourteen authored sources recur under seeds0/1/42. '
        'Corrected native/fresh routes expose seven replacement failures and seven healthy controls; '
        'complete RED reaches14 groups. Six unchanged consumers pass144 groups per capture. '
        'The selected original assignment32–53 is correct, but its rewritten twin lookup chooses quoted11 '
        'instead of executable35. Actual event/argument identities expose collector/canonical copies '
        'without private-origin handoff. Three actual built-in traces per population retain reached '
        'rewrites; initial invalid cat and mismatched deferred-context channels remain explicit. '
        'Twenty evidence, five instrument, five history and eleven render controls reject. '
        'Original318 membership hashes freeze mode/revision only at fa9b7608e; book58/seven exact '
        'examples passes. Production/tests/CI/hooks/contracts/dependencies remain unchanged. '
        'Diagnosis does not repair runtime or close replacement, recurring, diagnostic-origin or comment owners.')
    next_action = ('Activate REPO-HYGIENE.12 from the clean diagnosis commit; qualify the dated Phase0 '
        'Knowledge snapshot without refreshing its measurements. Then activate ' + PARENT + '.1.0 '
        'for private original-origin handoff, checking history capacity first. Preserve exact source '
        'and event/argument/reference authority; authored RED/GREEN precedes production changes. '
        'Mapped replacement .1.1 and committed canonical .2 remain required; no raw-text pairing/global sort.')
    path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'; text = path.read_text()
    start = text.index('- ID: `' + OWNER + '`'); end = text.index('\n- ID:', start + 1)
    block = text[start:end]; assert '  Status: `in_progress`' in block
    block = block.replace('  Status: `in_progress`', '  Status: `done`', 1)
    block += '\n  Verification: ' + statement + '\n'
    block += ('  Owned instrument corrections: Initial display assumes public scanner contract_id and rejects; '
        'exact source/actual rejection recurrence and sole raw-watch display correction survive. Initial '
        'generated-data cat has one argument and is unsupported; explicit corrected source has two, with13 '
        'other source oracles unchanged. Original deferred guard compares facade binding context with a '
        'direct owner lacking it; corrected same-facade comparison passes and direct-owner channel remains '
        'separate. Complete original/current channels and exact correction inverses are verified; no '
        'production defect is inferred from these instrument errors.\n'
        '  Encountered documentation defect: Dated June12 Phase0 card still says current/1004/approximately3 '
        'minutes. Actual .0.2.2.2.2 canonical output is1035/1185 wallclock seconds for that exact run, without '
        'a universal duration claim. REPO-HYGIENE.12 owns qualification immediately after this clean commit.\n'
        '  Commit: `' + SUBJECT + '` (Git owns identity).\n  Next: ' + next_action + '\n\n')
    block += '## Acceptance Checklist — ' + OWNER + '\n\n'
    for label, detail in (
        ('REPRODUCE / ISSUE', 'Actual LinkedSpec::Get/return_descriptor/call_spec_handler_subst/dump_parser_source and independent emitted execution retain seven corrected failing sources/three seeds; complete14-group RED has seven healthy guards.'),
        ('ROOT CAUSE (WHY + WHERE)', 'Observed real scanner/AST interval32–53 and reached RewritePipeline original32/rewritten11 queries distinguish executable35 from quoted11 after expansion. Actual collector/canonical reference copies lose original occurrence authority.'),
        ('FIX', 'Diagnosis/evidence and safe repair decomposition only; all production, standard tests and mechanical owners remain activation-exact.'),
        ('ADDRESSED (verified)', 'Complete original/corrected44 commands,42 source/seed pairs each, exact source/frame/argument/reference/metadata/value/error channels, actual traces and20 evidence controls; no runtime repair claimed.'),
        ('NO REGRESSION', 'Six unchanged direct consumers pass144 complete ordered groups twice. Exact canonical Phase01035 completed at activation; diagnosis changes no production or standard tests and does not claim a new full gate.'),
        ('LOCKSTEP', 'Book58/seven exact examples/11 controls, original318 hashes/five controls and five instrument controls; task/index/roadmaps/live/resume/Knowledge/claims/history/diff and normal hooks govern landing.'),
    ):
        block += '- [x] **' + label + '** — ' + detail + '\n'
    text = text[:start] + block + text[end:]
    identity = PARENT + '.1'; start = text.index('- ID: `' + identity + '`'); end = text.index('\n- ID:', start + 1)
    block = text[start:end]
    block += ('\n  Children: `' + identity + '.0`, `' + identity + '.1`\n'
        '  Safe-slice split: Private origin handoff through actual compiler event copies first, then exact '
        'original-to-rewritten interval mapping and insertion ownership. The before diagnostic corpus '
        'remains immutable; preserve callbacks, public schemas, family and consumed/exclusive order. '
        'No quoted rescanning or inferred equal-raw span may grant authority.\n')
    for suffix, goal, scope in (
        ('.0', 'Preserve private original occurrence authority through compiler collection/canonical copies.',
         'Candidate owners: new perl/LinkedSpec/ActionIR/SourceOrigins.pm, Scanner.pm, Diagnostics.pm, '
         'CanonicalEvents.pm, CanonicalEvents/Core.pm and RewritePipeline.pm. Select exact invocation-local '
         'capture/copy and actual splitter-frame seams before editing; author source/ref/args/raw/fallback/'
         'foreign/malformed/delegation/error/reentrant controls. Keep replacement behavior unchanged here; '
         'verify original diagnostics/source/value/error channels and unchanged consumers, then focused commit.'),
        ('.1', 'Replace selected original intervals in the current rewritten frame.',
         'Candidate owner: RewritePipeline.pm and its private original interval/edit translation seam. '
         'Author source-identical quoted/generated/interleaved/duplicate/nested/raw/implicit-newline/closure '
         'RED/GREEN before changing searches or insertions. Preserve literals, real spans, args/references, '
         'family ordering and native/fresh/errors; resolve every observed defect in a safely bounded slice. '
         'Focused repair precedes independently committed canonical replacement .0.3.2.'),
    ):
        block += ('\n- ID: `' + identity + suffix + '`\n  Status: `pending`\n  Goal: ' + goal + '\n'
                  '  Dependencies: `' + (OWNER if suffix == '.0' else identity + '.0') + '`\n'
                  '  Acceptance: ' + scope + '\n')
    text = text[:start] + block + text[end:]
    text = replace(r'^\| 43\.4\.2\.0\.3\.0 \|.*$',
        '| 43.4.2.0.3.0 | `' + OWNER + '` | `done` | Original/rewritten diagnosis verified; repair remains open. |', text)
    anchor = '| 43.4.2.0.3.1 | `' + identity + '` | `pending` | Repair the measured replacement boundary. |'
    assert text.count(anchor) == 1
    text = text.replace(anchor, anchor + '\n'
        '| 43.4.2.0.3.1.0 | `' + identity + '.0` | `pending` | Private occurrence handoff through actual copies. |\n'
        '| 43.4.2.0.3.1.1 | `' + identity + '.1` | `pending` | Original-to-rewritten mapped replacement and insertions. |')
    text = text.replace('## Verification Log\n', '## Verification Log\n\nOctober8 `' + OWNER + '`: ' + statement + '\n', 1)
    text = text.replace('## Commit Log\n', '## Commit Log\n\n- `' + SUBJECT + '` — bounded diagnosis; Git owns identity.\n', 1)
    text = text.replace('## Changelog\n', '## Changelog\n\n- 2026-10-08: Exact replacement diagnosis retained; private handoff/mapped repair split before production and dated Phase0 correction owned.\n', 1)
    path.write_text(text)
    for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
        path = ROOT / name; path.write_text(replace(r'^\| Expressive `\.spec` self-containment \|.*$',
            '| Expressive `.spec` self-containment | `active: exact replacement repair` | ' + statement + ' | ' + next_action + ' |', path.read_text()))
    path = ROOT / 'docs/TASK_TREE.md'; text = path.read_text()
    text = replace(r'^\| `SPEC-LANGUAGE-SELF-CONTAINMENT` \|.*$',
        '| `SPEC-LANGUAGE-SELF-CONTAINMENT` | `active: exact replacement repair` | `.spec language evolution / expressive self-containment and alternate authoring profiles` | ' + statement + ' Next: ' + next_action + ' | [docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md](docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md) |', text)
    text = replace(r'^\| `REPO-HYGIENE` \|.*$',
        '| `REPO-HYGIENE` | `active: dated Phase0 record correction pending` | `Overall roadmap — repository maintenance` | .11 remains the latest daily census, zero removals. .12 owns qualification of the dated June12 testing record after clean replacement diagnosis, then returns to .0.3.1.0. | [docs/tasks/REPO-HYGIENE.md](docs/tasks/REPO-HYGIENE.md) |', text)
    text = replace(r'^Latest maintenance:.*$', 'Latest maintenance: REPO-HYGIENE.11 remains the October7 zero-removal census. REPO-HYGIENE.12 now owns the dated Phase0 Knowledge correction after clean replacement diagnosis.', text)
    path.write_text(text)
    note = ('## 2026-10-08 — Exact replacement diagnosis\n\n'
        'Selected origin32 maps to rewritten35; raw search replaces quoted11. Preserve authority through '
        'copies/edits. See docs/knowledge/perl-residual-replacement-source-frames.md.\n')
    for name, record in (
        ('CHANGES.md', '## 2026-10-08 — Retain selected replacement diagnosis\n\n' + statement + '\n'),
        ('DEVELOPMENT_NOTES.md', note),
    ):
        path = ROOT / name; text = path.read_text(); offset = text.index('\n## ')
        candidate = text[:offset] + '\n' + record + text[offset:]
        if name == 'DEVELOPMENT_NOTES.md':
            assert len(candidate.encode()) <= 65536 * 9 // 10, 'diagnosis fits existing rollover budget'
        path.write_text(candidate)
    path = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'; text = path.read_text()
    for title, value, following in (
        ('Current Activity', 'Full PNT: exact replacement diagnosis verified; dated Phase0 qualification then private occurrence handoff/mapped repair.', 'Latest Completed Slice'),
        ('Latest Completed Slice', '`' + OWNER + '` — ' + statement, 'Next Action'),
        ('Next Action', next_action, 'Recent Completions'),
    ):
        text, count = re.subn(r'(## ' + title + r'\n\n).*?(\n## ' + following + r')', lambda m: m[1] + value + '\n' + m[2], text, flags=re.S)
        assert count == 1
    recent = text.split('## Recent Completions\n\n', 1)[1].split('\n## History', 1)[0]
    rows = [row for row in recent.splitlines() if row.startswith('- `')]
    rows.insert(0, '- `' + OWNER + '` — two44-command captures, seven real failures/seven healthy guards, consumer144; exact replacement remains open.')
    text = re.sub(r'(## Recent Completions\n\n).*?(\n## History)', lambda m: m[1] + '\n'.join(rows[:16]) + '\n' + m[2], text, flags=re.S); path.write_text(text)
    path = ROOT / 'MEMORY.md'; text = path.read_text()
    for field, value in {
        'latest_completed_leaf': '`' + SUBJECT + '`.',
        'active_work_unit': '`' + OWNER + '` (done) — original/rewritten replacement diagnosis.',
        'next_action': next_action,
        'in_flight_uncommitted': 'None; intended clean post-landing handoff. Complete source-bound diagnosis, '
            'history/instrument/book/claim checks and normal focused hooks govern this commit; no production repair.',
    }.items():
        text = replace(r'^- ' + field + r':.*$', '- ' + field + ': ' + value, text)
    assert len(text.encode()) <= 8192 and len(text.splitlines()) <= 60; path.write_text(text)
    paths = {entry['path'] for entry in read(PREFIX + 'inputs.json')['entries'] if entry['path'].startswith('perl/')}
    paths.update('t/' + name + '.t' for name in ('actionir_ast_parser', 'canonical_event_occurrence_order',
        'actionir_nested_block_source_spans', 'actionir_compiler_source_membership',
        'actionir_executable_source_membership', 'trace_emit_context_bridge'))
    paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if path.is_file())
    paths.update(entry['path'] for entry in read(PREFIX + 'book-inputs.json')['entries'])
    paths.update({
        'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.2-review.py',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-fresh.pl',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm',
        'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.2.json',
        'docs/knowledge/perl-residual-replacement-source-frames.md',
    })
    bindings = []
    for name in sorted(paths):
        source = ROOT / name; assert source.is_file() and not source.is_symlink()
        bindings.append({'path': name, 'sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
                         'role': 'producer' if source.suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'})
    claim = {'version': 1, 'owner': OWNER, 'claims': [{
        'name': 'selected-original-and-rewritten-occurrence-diagnosis', 'statement': statement,
        'scope': ('Bounded unchanged fa9b7608e diagnosis, not a product repair. Each supplied regular Git '
            'superset excludes Gitlinks/nonregular payload without inspection and reconstructs via exact '
            'object/byte/hash/mode manifests; three explicit case/probe/fixture overlays, no production '
            'replacement. This is not minimal IO. Two complete44-command captures each retain42 source/seed '
            'pairs,14-group RED and six complete consumers144. Initial wrong-context deferred channels are '
            'explicitly incomplete and one-argument cat is unsupported; corrected same-facade comparison '
            'and two-argument cat preserve all originals and13 other source oracles. Six corrected compile '
            'failures/one set runtime failure plus seven healthy source controls distinguish original '
            'authority from rewritten replacement; original intervals are independent literal assemblies. '
            'Twenty evidence and five exact instrument controls are record/source falsifiers, not runtime '
            'semantic mutants. Original318 hashes freeze only mode/revision; five denials verify it. '
            'Actual initial Toolbox capsule retains the tool-returned combined channel, not unavailable '
            'separate stdout/stderr. Display schema error source and actual recurrence retain original '
            'traceback context; no universal first-error replay identity is inferred. Three built-in traces '
            'per initial/corrected population,58 complete book inputs/capsule/full render channels/seven '
            'exact examples and11 effective controls retain source coverage. Necessary read-only OS/Perl/'
            'Python/mdBook inputs; all project data repository-local/same-volume. No production/test/CI/'
            'hook/contract/dependency change or new syntax/backend admission, no readiness claim from healthy '
            'values. Private handoff/mapped replacement and canonical .0.3.2 stay open; recurring .0.4, '
            'diagnostic origin and comments retain owners. Dated Phase0 metadata is separately scheduled '
            'REPO-HYGIENE.12, without a new universal performance claim. Other repositories are read-only.'),
        'rederive': {'status': 'checked', 'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + suffix
            for suffix in ('capture.py', 'corrected-capture.py', 'trace-capture.py', 'corrected-trace-capture.py',
                           'review.py', 'instrument-review.py', 'freeze.py', 'book.py --review')),
            'granularity': json.dumps(proof, sort_keys=True), 'result': statement},
        'falsify': {'status': 'checked', 'hypothesis': 'Executable membership or successful healthy values locate the same original occurrence after text expansion.',
            'oracle': 'Independent authored literal/value/scalar intervals; actual selected reference/origin, copier references and reached original/rewritten query locations. Quoted-before/after and repeated/interleaved/distinct/nested/deferred/generated controls distinguish the competing hypothesis.',
            'red_control': 'Complete corrected14-group RED fails exactly seven groups; seven healthy guards pass. Twenty actual evidence corruptions, five instrument inverses/rejection corruptions, five history corruptions and eleven actual-render corruptions reject. Initial instrument failures remain separate from product failures.'},
        'durability': {'status': 'checked', 'mode': 'live', 'inputs': bindings}}]}
    raw = json.dumps(claim, indent=2) + '\n'; assert len(raw.encode()) <= 131072
    (ROOT / CLAIM).write_text(raw)
    (ROOT / 'git_message_brief.txt').write_text(SUBJECT + '\n\n' + statement + '\n\n' + next_action + '\n')
    print(statement); print('Bound claim inputs:', len(bindings))


if __name__ == '__main__':
    main()
