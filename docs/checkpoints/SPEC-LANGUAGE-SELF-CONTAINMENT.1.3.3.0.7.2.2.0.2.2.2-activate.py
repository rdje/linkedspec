"""Activate immutable corrected membership acceptance from the clean repair commit."""
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2'
REVISION = '0f31461d696186775585e19355a0bc5c41849dfb'


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == REVISION
    assert (ROOT / 'git_message_brief.txt').stat().st_size == 0
    path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'; text = path.read_text()
    start = text.index('- ID: `' + OWNER + '`'); end = text.index('\n- ID:', start + 1)
    block = text[start:end]; assert '  Status: `pending`' in block
    block = block.replace('  Status: `pending`', '  Status: `in_progress`', 1)
    block += ('\n  Activation: Clean0f31461d6 observed with empty brief and no required jobs. Focused callable repair .1 passed complete immutable before/after proof, all1473 direct groups/Phase01035 and normal ten-doctrine hooks. Current task/roadmap/book, original literal/source/value/consumer authority, Knowledge causes and canonical ADR0073/0126 boundaries are reviewed.\n'
        '  Owned paths: New leaf-prefixed immutable capture/reviewer/claim/publication/history artifacts and this claim; prior202-input .1 record mode/revision-only freeze; current Knowledge/book/task/index/roadmaps/live/resume/change/notes. Production, all original tests, contracts, CI/hooks and dependencies stay unchanged.\n'
        '  Verification tier: `canonical`\n'
        '  Focused checks: Complete corrected committed regular Git snapshot with no overlays, compiler40/new225 signature assertions per seed0/1/42; original22 public sources/66 complete channels/120 authored native-fresh values plus original3 callable sources/18 values. All16 unchanged consumers/1473 exact ordered groups including callable11 and full Phase01035. Effective channel/source/AST/reference/metadata/value/input/TAP/producer controls; exact202-hash mode/revision freeze, book render/claim/Knowledge/memory/history/diff and normal hooks.\n'
        '  Canonical trigger: Corrected committed membership acceptance and .0.2.2/.0.2 parent closure require the exact staged canonical receipt and normal hooks. No successful canonical measurement is preclaimed.\n'
        '  Claim verification: `docs/claims/' + OWNER + '.json`\n'
        '  Source boundary: Independently compose the original literal/scanner/reference/caller-error and current signature authority. Preserve original checkpoint318/current202 hashes and all failed historical canonical candidates. Original no-value-oracle unsupported_nested/raw_operand remain explicit; successful values do not establish readiness. Replacement .0.3, recurring .0.4, diagnostic origin .7.2.2.1 and comments .7.3 remain open.\n')
    text = text[:start] + block + text[end:]
    text = text.replace('| `' + OWNER + '` | `pending` | Independently accept corrected committed membership. |',
                        '| `' + OWNER + '` | `in_progress` | Fresh corrected committed recurrence and exact canonical membership acceptance. |')
    path.write_text(text)
    path = ROOT / 'MEMORY.md'; text = path.read_text()
    for field, value in {
        'activation_commit': '`' + REVISION + '` — clean corrected committed membership acceptance activation.',
        'active_work_unit': '`' + OWNER + '` (in_progress) — immutable corrected membership acceptance.',
        'next_action': 'Freeze the completed202-input repair record without refreshing hashes; capture compiler/original public/callable/unchanged consumers from exact corrected committed inputs with no overlays, verify controls/book/claims, then stage exact canonical candidate and run CI/normal hooks before parent closure.',
        'in_flight_uncommitted': 'Owned canonical acceptance activation and new instruments. Corrected production and full focused repair are committed. No successful canonical receipt or membership closure yet; preserve all historical evidence and original inputs.',
    }.items():
        text, count = re.subn(r'^- ' + field + r':.*$', lambda m: '- ' + field + ': ' + value, text, flags=re.M)
        assert count == 1
    path.write_text(text)
    print('Activated', OWNER, 'from', REVISION)


if __name__ == '__main__':
    main()
