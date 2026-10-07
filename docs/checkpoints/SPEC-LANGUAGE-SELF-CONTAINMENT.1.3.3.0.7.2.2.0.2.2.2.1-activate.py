"""Activate the focused grouped-pattern repair from a clean checkpoint."""
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1'
REVISION = '78012b1e78bb114a41f54873f30ca63c421568c8'


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == REVISION
    dirty = subprocess.check_output(['git', 'status', '--porcelain', '-z'], cwd=ROOT).decode().split('\0')
    assert [r for r in dirty if r] == ['?? docs/checkpoints/' + OWNER + '-activate.py'], 'clean activation except this owned instrument'
    assert (ROOT / 'git_message_brief.txt').read_bytes() == b''
    path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'; text = path.read_text()
    start = text.index('- ID: `' + OWNER + '`'); end = text.index('\n- ID:', start + 1)
    block = text[start:end]; assert '  Status: `pending`' in block
    block = block.replace('  Status: `pending`', '  Status: `in_progress`', 1)
    block += (
        '\n  Activation: Clean78012b1e78bb114a41f54873f30ca63c421568c8, empty brief and no required job. '
        'Current task/roadmap/book and canonical grouped-regex/signature/source-membership facts are reviewed; '
        'Toolbox actual compiler/substitution/descriptor/native/fresh source-bound packets already locate the gap. '
        'The default helper query has three other consumer sites (structural view, numeric discriminator and AST operand parsing); '
        'compiler membership alone requests callable delimiter precedence.\n'
        '  Owned paths: SourceMembership helper-role call, narrowly opt-in MethodExpr traversal, appended compiler regression, '
        'new leaf-prefixed immutable before/after/public/default-query/review/history/book artifacts and this claim; '
        'prior247-input checkpoint mode/revision-only freeze; Knowledge/book/task/index/roadmaps/live/resume/change/notes. '
        'Original40 compiler groups/other tests/splitter/contracts/CI/hooks/dependencies stay unchanged.\n'
        '  Verification tier: `focused`\n'
        '  Focused checks: Authored grouped dot/comma/operator/fixed/rest/zero/nested/body/host/numeric/indexed controls '
        'precede production; immutable original RED/corrected GREEN under seeds0/1/42, actual primitive origins/references/'
        'arguments/order and caller errors. Six original public grouped sources retain source/AST/native/fresh/error channels '
        'while correcting only false membership/counters. Default helper-query and unchanged consumer populations, '
        'full Phase0, exact historical hash freeze, book/claim/Knowledge/memory/history/diff and normal hooks.\n'
        '  Canonical trigger: None for this bounded compiler-specific repair. Fresh committed canonical .0.2.2.2.2 '
        'remains mandatory before membership parents close; no public schema or grammar admission.\n'
        '  Claim verification: `docs/claims/' + OWNER + '.json`\n'
        '  Source boundary: Preserve the original actual defect observations at0f31461d6 and all247 checkpoint hashes. '
        'Never refresh historical channels. Ordinary syntactic scanning/default query, genuine host quotes/numeric/'
        'grouped/indexed precedence, original event/argument/origin objects/source spans/schema and caller errors remain authority.\n')
    text = text[:start] + block + text[end:]
    text, count = re.subn(r'^\| 43\.4\.2\.0\.2\.2\.2\.1 \|.*$',
        '| 43.4.2.0.2.2.2.1 | `' + OWNER + '` | `in_progress` | Authored original RED before compiler grouped-role correction. |', text, flags=re.M)
    assert count == 1; path.write_text(text)
    path = ROOT / 'MEMORY.md'; text = path.read_text()
    fields = {
        'activation_commit': '`' + REVISION + '` — clean grouped-pattern checkpoint activation.',
        'active_work_unit': '`' + OWNER + '` (in_progress) — compiler callable/grouped-pattern role correction.',
        'next_action': 'Freeze exact247 checkpoint hashes; author compiler/grouped/default-query regression before production. Retain immutable original RED/public channels, correct only opt-in helper role query, verify GREEN/full consumers/Phase0/book/claims and commit. Fresh committed canonical .0.2.2.2.2 follows.',
        'in_flight_uncommitted': 'Owned repair activation only; no production/test change yet. Fixed x,y actual pattern-data event/counter defect and original evidence remain retained; default query and ordinary scanner contracts stay unchanged. No membership closure.',
    }
    for field, value in fields.items():
        text, count = re.subn(r'^- ' + field + r':.*$', '- ' + field + ': ' + value, text, flags=re.M)
        assert count == 1
    path.write_text(text)
    print('Activated', OWNER, 'from exact clean', REVISION)


if __name__ == '__main__':
    main()
