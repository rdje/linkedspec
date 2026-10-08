"""Activate independent committed membership acceptance from the clean repair."""
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.2'
REVISION = '5b4a9a8ca2203f651d3c9d3a36cc9836c30a5375'


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == REVISION
    rows = subprocess.check_output(['git', 'status', '--porcelain', '-z'], cwd=ROOT).decode().split('\0')
    assert [r for r in rows if r] == ['?? docs/checkpoints/' + OWNER + '-activate.py']
    assert (ROOT / 'git_message_brief.txt').read_bytes() == b''
    path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
    text = path.read_text(); start = text.index('- ID: `' + OWNER + '`')
    end = text.index('\n- ID:', start + 1); block = text[start:end]
    assert '  Status: `pending`' in block
    block = block.replace('  Status: `pending`', '  Status: `in_progress`', 1)
    block += (
        '\n  Activation: Clean5b4a9a8ca2203f651d3c9d3a36cc9836c30a5375, empty brief and no required job. '
        'Relevant roadmap/task/book and compiler/signature/grouped-pattern Knowledge facts reviewed. '
        'Exact original Toolbox packets, repaired source owners and unchanged consumer contracts are retained.\n'
        '  Owned paths: New leaf-prefixed immutable committed capture/review/history/book artifacts and claim; '
        'prior291-input repair mode/revision-only freeze; Knowledge/book/task/index/roadmaps/live/resume/change/notes. '
        'Production/tests/contracts/CI/hooks/dependencies stay unchanged.\n'
        '  Verification tier: `canonical`\n'
        '  Focused checks: Fresh exact committed compiler/public/callable/grouped/default-query/consumer populations '
        'under seeds0/1/42 without overlays; original source/AST/event/origin/argument/reference/value/error/metadata '
        'oracles, historical RED and effective evidence/history/render controls. All22 consumers/full Phase0; '
        'claim/Knowledge/memory/history/diff and normal hooks.\n'
        '  Canonical trigger: Membership parent closeout requires exact staged receipt-bound tools/run_ci_local.sh '
        'after complete independent committed acceptance. No closure on a failed candidate.\n'
        '  Claim verification: `docs/claims/' + OWNER + '.json`\n'
        '  Boundary: Preserve all291 original repair hashes; freeze only mode/revision. '
        'Accept membership .0.2 only after full proof. Precise replacement .0.3, recurring .0.4, '
        'diagnostic origin .7.2.2.1 and comments .7.3 remain owned.\n')
    text = text[:start] + block + text[end:]
    text, count = re.subn(r'^\| 43\.4\.2\.0\.2\.2\.2\.2 \|.*$',
        '| 43.4.2.0.2.2.2.2 | `' + OWNER + '` | `in_progress` | Fresh committed membership acceptance; canonical receipt required. |', text, flags=re.M)
    assert count == 1; path.write_text(text)
    path = ROOT / 'MEMORY.md'; text = path.read_text()
    fields = {
        'activation_commit': '`' + REVISION + '` — clean corrected membership activation.',
        'active_work_unit': '`' + OWNER + '` (in_progress) — independent committed canonical membership acceptance.',
        'next_action': 'Freeze291 exact repair hashes, capture complete committed compiler/public/signature/grouped/default/consumer channels without overlays, grade original oracles and controls, then run exact staged canonical CI and commit. Precise replacement .0.3 follows; recurring/origin/comments remain owned.',
        'in_flight_uncommitted': 'Owned acceptance activation; no production/test changes. Complete immutable proof, history/book/claim/docs and exact staged canonical receipt before membership closure.',
    }
    for field, value in fields.items():
        text, count = re.subn(r'^- ' + field + r':.*$', '- ' + field + ': ' + value, text, flags=re.M)
        assert count == 1
    assert len(text.encode()) <= 8192 and len(text.splitlines()) <= 60
    path.write_text(text)
    print('Activated', OWNER, 'from exact clean', REVISION)


if __name__ == '__main__':
    main()
