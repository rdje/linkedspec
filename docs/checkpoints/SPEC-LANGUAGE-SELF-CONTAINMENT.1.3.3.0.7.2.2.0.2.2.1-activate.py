"""Activate the bounded callable membership repair from its clean checkpoint."""
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.1'
REVISION = '484fe128f945af9c53d82fe44f6498002dcfd771'


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == REVISION
    path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
    text = path.read_text()
    start = text.index('- ID: `' + OWNER + '`')
    end = text.index('\n- ID:', start + 1)
    block = text[start:end]
    assert '  Status: `pending`' in block
    block = block.replace('  Status: `pending`', '  Status: `in_progress`', 1)
    block += ('\n  Activation: Clean484fe128f observed with empty brief and no required jobs before authoring this leaf. README/bootstrap/memory, current task/roadmap/book, Knowledge cause and original callable/splitter records, ADR0031/0032/0073/0126, exact SourceMembership/Core precedence and compiler/callable fixtures are reviewed.\n'
              '  Owned paths: SourceMembership.pm and t/actionir_compiler_source_membership.t; new leaf-prefixed authored before/after/capture/reviewer/claim/publication artifacts and this claim record; prior checkpoint claim mode/revision-only freeze; current Knowledge/book/task/index/roadmaps/live/resume/change/notes. MethodExpr, StatementSplit, original callable fixture, source/event/schema/dependencies/CI/hooks remain unchanged.\n'
              '  Verification tier: `focused`\n'
              '  Focused checks: Author actual operator/header/host-quote/body/source/reference regression before code changes; retain complete immutable original-owner RED/current-owner GREEN with exact declared source/test overlays and input guards. Original isolated callable before channels and independently fresh emitted after values; unchanged callable/AST/private/source-frame/regex/raw/trace/generated consumers and complete Phase0. Preserve old318-input claim hashes, effective component/evidence/history/render controls; syntax/book/Knowledge/memory/history/diff and normal doctrines/hooks.\n'
              '  Canonical trigger: None for the exact private lexical precedence correction; no grammar/backend/public schema/parent closure. Fresh committed .0.2.2.2 requires exact canonical acceptance before membership closes. Escalate further cross-cutting uncertainty before landing.\n'
              '  Claim verification: `docs/claims/' + OWNER + '.json`\n'
              '  Implementation boundary: Mirror Core\'s invocation-local exact unquoted {| / closing-pipe ownership in the literal-range loop. Genuine host quotes consume their payload before a signature flag can activate. Protect only delimiters, then resume normal body lexing; no masked/reparsed source, new event fields, equal-raw pairing or changed MethodExpr helper rules.\n')
    text = text[:start] + block + text[end:]
    text = text.replace('| `' + OWNER + '` | `pending` | Correct callable signature membership precedence. |',
                        '| `' + OWNER + '` | `in_progress` | Preserve original RED and correct callable signature membership precedence. |')
    path.write_text(text)
    path = ROOT / 'MEMORY.md'
    text = path.read_text()
    values = {
        'activation_commit': '`' + REVISION + '` — clean callable-membership correction activation.',
        'active_work_unit': '`' + OWNER + '` (in_progress) — exact callable signature membership precedence.',
        'next_action': 'Freeze the original checkpoint without refreshing hashes; author the source/reference/header regression, retain original-owner RED, correct only signature delimiter precedence, then complete owned GREEN/direct-consumer/book/claim checks and commit. Fresh committed .0.2.2.2 remains required.',
        'in_flight_uncommitted': 'Owned activation and new instruments. Prior checkpoint is committed. Production correction has not started; preserve original callable/source-range RED and complete before/after inputs/channels. No successful canonical receipt or parent closure.',
    }
    for field, value in values.items():
        text, count = re.subn(r'^- ' + field + r':.*$', lambda match: '- ' + field + ': ' + value, text, flags=re.M)
        assert count == 1
    path.write_text(text)
    print('Activated', OWNER, 'from', REVISION)


if __name__ == '__main__':
    main()
