"""Publish the finished proof checkpoint while keeping canonical acceptance open."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
PARENT = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2'
OWNER = PARENT + '.0'
NEXT = PARENT + '.1'
PREFIX = 'docs/checkpoints/' + PARENT + '-'
SUBJECT = OWNER + ' - retain bounded membership proof'


def node(text, owner, change):
    start = text.index('- ID: `' + owner + '`')
    end = text.index('\n- ID:', start + 1)
    return text[:start] + change(text[start:end]) + text[end:]


def replace(pattern, replacement, text):
    text, count = re.subn(pattern, lambda match: replacement, text, flags=re.M)
    assert count == 1, pattern
    return text


def main():
    proof = json.loads((ROOT / (PREFIX + 'verification.json')).read_bytes())
    book = json.loads((ROOT / (PREFIX + 'book-verification.json')).read_bytes())
    callable_proof = json.loads((ROOT / (PREFIX + 'callable-verification.json')).read_bytes())
    assert proof['complete'] and callable_proof['complete'] and len(book['controls']) == 6
    statement = (f"Immutable{proof['revision'][:9]} supplies{proof['regular_git_inputs']} regular inputs/no "
        f"overlays and{proof['commands']} guarded commands. Original compiler{proof['compiler_groups']} per "
        f"seed0/1/42, {proof['public_seed_observations']} original public channel observations and"
        f"{proof['authored_route_values']} authored native/fresh values pass. Two original no-value-oracle "
        f"cases remain explicit. Fifteen unchanged consumers pass{proof['direct_consumers']['groups']} "
        f"groups including Phase0{proof['direct_consumers']['plans'][-1]}; original38 RED/17 evidence "
        "controls recur. Original133 historical hashes/five controls stay exact. The historical auditor "
        "admits only the committed scanner-mock inverse; original auditor RED/five source controls and "
        "isolated134-input recovery/22 controls/60 evolution denials pass. Two complete failed canonical "
        "candidates remain retained. The second exposes valid x,y callable membership corruption: three "
        "typed public sources distinguish one native/fresh bad pair from two healthy pairs, with five "
        f"observation controls. Book{book['book_inputs']} inputs/{book['exact_examples']} exact examples/"
        f"{len(book['controls'])} controls passes. This is a bounded proof checkpoint; membership "
        "acceptance remains open for signature repair .0.2.2.1 and fresh committed canonical .0.2.2.2. "
        "Production/Perl fixtures/CI/hooks/dependencies unchanged. Replacement, diagnostic origin and "
        "comments retain their later owners.")
    next_action = ('Activate ' + NEXT + ' from clean committed HEAD. Preserve the original callable '
        'RED and correct only exact unquoted signature pipe precedence in SourceMembership. Verify '
        'unchanged callable/private/compiler and direct consumers before committing. Fresh committed '
        'canonical .0.2.2.2 precedes membership closure and precise replacement .0.3.')
    path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
    text = path.read_text()
    start = text.index('- ID: `' + PARENT + '`')
    end = text.index('\n- ID:', start + 1)
    block = text[start:end]
    old = re.search(r'^  Verified focused result: (.+)$', block, re.M)[1]
    for name in ('CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
                 'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md'):
        target = ROOT / name
        content = target.read_text()
        assert old in content, name
        content = content.replace(old, statement)
        if name == 'CHANGES.md':
            content = content.replace('2026-10-07 — Accept committed compiler source membership',
                                      '2026-10-07 — Retain bounded membership proof and own callable regression')
        elif name == 'DEVELOPMENT_NOTES.md':
            content = content.replace('2026-10-07 — Immutable membership acceptance preserves original source authority',
                                      '2026-10-07 — Bounded membership recurrence exposes callable compatibility gap')
        elif name == 'LIVE_ACHIEVEMENT_STATUS.md':
            content = content.replace('Full PNT: committed compiler membership accepted; exact selected residual replacement follows the clean canonical boundary.',
                                      'Full PNT: bounded membership proof retained; callable signature repair and fresh canonical acceptance precede replacement.')
            content = content.replace('`' + PARENT + '` — ', '`' + OWNER + '` — ', 1)
            content = content.replace('Activate SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3 from clean committed HEAD. Diagnose exact selected residual replacement through original Toolbox/source-frame oracles; preserve quoted twins, literal bytes, genuine raw spans and occurrence/family order. Recurring .0.4, diagnostic origin .7.2.2.1 and source comments .7.3 remain separate.', next_action)
            content = content.replace('- `' + PARENT + '` — immutable4878/no overlays; compiler39/public66/1462 groups; canonical membership closeout.',
                                      '- `' + OWNER + '` — bounded immutable proof/historical inverse; callable signature regression owned; membership stays open.')
        else:
            content = content.replace('`active: precise replacement next`', '`active: callable membership repair next`')
            content = content.replace('Activate SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3 from clean committed HEAD. Diagnose exact selected residual replacement through original Toolbox/source-frame oracles; preserve quoted twins, literal bytes, genuine raw spans and occurrence/family order. Recurring .0.4, diagnostic origin .7.2.2.1 and source comments .7.3 remain separate.', next_action)
        target.write_text(content)
    text = text.replace(old, statement)
    def reopen(block):
        block = block.replace('  Status: `done`', '  Status: `active`', 1)
        block = re.sub(r'^  (Verification tier|Focused checks|Canonical trigger|Claim verification):.*\n', '', block, flags=re.M)
        block = re.sub(r'^  Canonical landing condition:.*$',
                       '  Canonical landing condition: Membership acceptance remains open. Child .0 retains the original bounded proof; .1 corrects the callable regression; .2 independently accepts the committed correction with exact canonical proof.', block, flags=re.M)
        block = re.sub(r'^  Commit:.*\n', '', block, flags=re.M)
        block = re.sub(r'^  Next:.*$', '  Next: ' + next_action, block, flags=re.M)
        block = block.replace('- [x] **FIX**', '- [ ] **FIX**').replace('- [x] **NO REGRESSION**', '- [ ] **NO REGRESSION**').replace('- [x] **LOCKSTEP**', '- [ ] **LOCKSTEP**')
        block += '\n  Decomposition: Two exact failed candidates are retained; no successful canonical receipt exists. Completed measurement/evidence-auditor work lands only as focused child .0. Corrective .1 and immutable canonical .2 keep this parent and membership .0.2 open. No verification policy or failure is bypassed.\n'
        return block
    text = node(text, PARENT, reopen)
    def membership_open(block):
        block = block.replace('  Status: `done`', '  Status: `active`', 1)
        block = re.sub(r'^  Closeout:.*$', '  Closeout: Open. Original bounded recurrence does not close the callable signature compatibility defect; corrective .0.2.2.1 and exact committed canonical .0.2.2.2 are required.', block, flags=re.M)
        return block
    text = node(text, PARENT.rsplit('.', 1)[0], membership_open)
    def complete(block):
        assert '  Status: `in_progress`' in block
        block = block.replace('  Status: `in_progress`', '  Status: `done`', 1)
        block += '\n  Verified focused result: ' + statement + '\n  Commit: `' + SUBJECT + '` (Git owns identity).\n  Next: ' + next_action + '\n\n'
        for label, detail in (
            ('REPRODUCE / ISSUE', 'Original bounded immutable source/AST/value/consumer streams and both failed canonical candidates survive; public x,y fails both routes, x,z/rest-y return ok.'),
            ('ROOT CAUSE (WHY + WHERE)', 'Real original spans show the y| signature closer starts literal range8..48 and filters the real return at23..48; AST/splitter typed signature remains correct. SourceMembership host-quote precedence owns repair.'),
            ('FIX', 'Historical evidence auditor reverses only the committed af5d/31395 scanner-mock line and recovers complete historical bytes; five source controls reject. Production compatibility repair remains separately owned.'),
            ('ADDRESSED (verified)', 'Bounded compiler39/public66/120 route values/direct1462 and original RED/evidence controls pass; isolated134-input audit and actual callable diagnosis/five controls pass. No membership closure is inferred.'),
            ('NO REGRESSION', 'Production, Perl fixtures, CI, hooks and dependencies stay unchanged. Exact historical source/hash authority persists; original known callable RED is retained and scheduled for the next leaf.'),
            ('LOCKSTEP', 'Rendered book58/three exact examples/six controls, claim/Knowledge/task/index/roadmaps/live/resume and bounded histories disclose the same open parent/corrective frontier.'),
        ):
            block += '- [x] **' + label + '** — ' + detail + '\n'
        return block
    text = node(text, OWNER, complete)
    text = replace(r'^\| 43\.4\.2\.0\.2\.2 \|.*$', '| 43.4.2.0.2.2 | `' + PARENT + '` | `active` | Original bounded proof retained; callable correction and fresh canonical acceptance remain. |\n| 43.4.2.0.2.2.0 | `' + OWNER + '` | `done` | Immutable proof/historical inverse/callable RED retained. |\n| 43.4.2.0.2.2.1 | `' + NEXT + '` | `pending` | Correct callable signature membership precedence. |\n| 43.4.2.0.2.2.2 | `' + PARENT + '.2` | `pending` | Independently accept corrected committed membership. |', text)
    text = text.replace('- `' + PARENT + ' - accept committed compiler membership` — exact staged canonical receipt and normal hooks gate membership closure; Git owns identity.',
                        '- `' + SUBJECT + '` — bounded focused proof checkpoint; original parent stays open. Git owns identity.')
    text = text.replace('- `2026-10-07`: .0.2.2 accepts immutable committed compiler membership; original source/fixture/evidence boundaries preserved. Precise replacement .0.3 follows clean landing.',
                        '- `2026-10-07`: .0.2.2 decomposes after retained canonical historical-audit and callable failures: .0 retains bounded proof/inverse, .1 owns compiler signature correction, .2 requires fresh committed canonical acceptance.')
    text = text.replace('Initial direct ScannerCore call supplied Scanner\'s facade bundle instead of the compiler\'s actual nested dependency bundle and exits before its public observation.',
                        "Initial direct ScannerCore probe exits255 before public observation; exact retained-source replay attributes this to missing callback LinkedSpec::_split_action_ir_statements in the supplied facade bundle.")
    path.write_text(text)
    path = ROOT / 'MEMORY.md'
    content = path.read_text()
    content = replace(r'^- latest_completed_leaf:.*$', '- latest_completed_leaf: `' + SUBJECT + '`.', content)
    content = replace(r'^- active_work_unit:.*$', '- active_work_unit: `' + OWNER + '` (done) — bounded proof checkpoint; canonical membership remains open.', content)
    content = replace(r'^- next_action:.*$', '- next_action: ' + next_action, content)
    content = replace(r'^- in_flight_uncommitted:.*$', '- in_flight_uncommitted: None; intended clean focused post-landing handoff. Checkpoint proof/docs complete; no required background job remains. Both failed canonical candidates and callable RED are retained; corrective production work starts only after this commit.', content)
    path.write_text(content)
    path = ROOT / 'docs/knowledge/perl-compiler-source-membership.md'
    content = path.read_text().replace('status: compiler membership accepted; later source repairs remain separate', 'status: compiler integrated; callable signature correction and canonical acceptance remain open')
    content = content.replace('and accepts membership through exact staged canonical proof.', 'within the original bounded population. Canonical CI exposes a callable signature membership regression; acceptance remains open.')
    content = content.replace('Independent committed recurrence .0.2.2 accepts only the\nmembership parent through original oracles and exact staged canonical proof.', 'Independent committed recurrence .0.2.2.0 verifies its bounded original\npopulation. [[perl-source-membership-callable-signature-precedence]] owns the\nnew callable regression; corrective .0.2.2.1 and committed canonical .0.2.2.2\nare required before membership acceptance.')
    path.write_text(content)
    path = ROOT / 'docs/knowledge/perl-executable-source-membership.md'
    path.write_text(path.read_text().replace('status: selector connected to compiler; independent membership acceptance complete', 'status: selector connected to compiler; callable correction and canonical membership acceptance remain open'))
    path = ROOT / 'docs/knowledge/phase0-compiler-scanner-mock-historical-inverse.md'
    path.write_text(path.read_text().replace('status: Exact Git-bound inverse verified; canonical receipt gates membership acceptance', 'status: Exact Git-bound inverse verified in bounded checkpoint; callable correction and canonical membership acceptance remain open'))
    (ROOT / 'git_message_brief.txt').write_text(SUBJECT + '\n\nRetain immutable compiler/public/source/consumer evidence and exact historical Phase0 mock inverse. Preserve both failed canonical candidates and public/source-origin callable RED.\n\nMembership remains open: correct signature precedence next, then independently accept the committed fix through canonical CI. Production/Perl fixtures/CI/hooks/dependencies stay unchanged in this checkpoint.\n')
    print(statement)


if __name__ == '__main__':
    main()
