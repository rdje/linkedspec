"""Own the bounded replacement diagnosis before producing evidence."""
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PARENT = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3'
OWNER = PARENT + '.0'
REVISION = 'fa9b7608ed9e49712129bb5456d75d118e7207a0'


def replace(pattern, value, text):
    text, count = re.subn(pattern, lambda m: value, text, flags=re.M)
    assert count == 1, (pattern, count)
    return text


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == REVISION
    rows = subprocess.check_output(['git', 'status', '--porcelain', '-z'], cwd=ROOT).decode().split('\0')
    assert [r for r in rows if r] == ['?? docs/checkpoints/' + OWNER + '-activate.py']
    assert (ROOT / 'git_message_brief.txt').read_bytes() == b''
    path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
    text = path.read_text(); start = text.index('- ID: `' + PARENT + '`')
    end = text.index('\n- ID:', start + 1); block = text[start:end]
    assert '  Status: `pending`' in block
    block = block.replace('  Status: `pending`', '  Status: `active`', 1)
    block += ('\n  Children: `' + PARENT + '.0`, `' + PARENT + '.1`, `' + PARENT + '.2`\n'
        '  Safe-slice split: First retain current Toolbox source/AST/substitution/descriptor/dump/native/fresh '
        'observations and independent identical-occurrence oracles; select the exact original/rewritten frame '
        'owners from reached traces. Repair only that measured scope in .1; .2 independently recurs committed '
        'behavior and requires exact canonical receipt before parent closure. Do not infer spans from equal raw '
        'text or change contract-family precedence. Diagnostic origin, comments and recurring registration keep '
        'their existing owners.\n')
    block += ('\n- ID: `' + OWNER + '`\n'
        '  Status: `in_progress`\n'
        '  Goal: Diagnose the selected residual occurrence in original and rewritten source frames.\n'
        '  Dependencies: `.1.3.3.0.7.2.2.0.2`\n'
        '  Activation: Clean ' + REVISION + ', empty brief, successful exact canonical receipt/normal hooks '
        'and no required job. Relevant roadmap, task, book, source-membership, original producer-frame and '
        'residual-order facts reviewed. The replacement mechanism is not presumed fixed by membership.\n'
        '  Owned paths: Leaf-prefixed tracked diagnosis/freeze/capture/reviewer/fixture/book artifacts and claim; '
        'prior318-input membership claim mode/revision-only freeze; source-ownership Knowledge/book, '
        'task/index/roadmaps/resume/live/change/notes. No production, standard test, CI/hook or dependency edits.\n'
        '  Verification tier: `focused`\n'
        '  Focused checks: Actual public Toolbox observations and reached source-location traces; independent '
        'literal/occurrence/frame/order/native/fresh/error oracles, exact committed producer/input identities, '
        'complete diagnostic RED with healthy guards, effective reason-specific evidence controls; unchanged '
        'AST/canonical/source-membership consumers, actual book render, claims/Knowledge/memory/history/diff '
        'and all normal doctrines.\n'
        '  Canonical trigger: None; diagnosis and safe ownership decomposition only. Repair and committed '
        'acceptance remain separately owned; no behavior or public contract admission here.\n'
        '  Claim verification: `docs/claims/' + OWNER + '.json`\n'
        '  Acceptance: Retain exact original source and all observed failures without claiming runtime repair. '
        'Distinguish selected real origins from actual replacement locations in both orders, repeated and '
        'interleaved twins, nested/deferred and rewritten data; preserve arguments/references, genuine raw '
        'spans, family order and successful guards. Select a safe .1 scope from observed mechanisms and commit.\n')
    for suffix, goal, acceptance in (
        ('.1', 'Repair only the measured selected-occurrence replacement boundary.',
         'Author source-identical RED/GREEN before production changes; preserve original/rewritten literal bytes, '
         'real origin/reference identity, genuine raw spans, arguments, family order and native/fresh/error '
         'contracts. Split further before widening ownership; focused verification and normal hooks precede .2.'),
        ('.2', 'Independently accept the committed replacement repair.',
         'Recur complete retained original/corrected oracles and unchanged consumers from committed inputs, '
         'with effective evidence/history/render controls. Exact staged canonical receipt and normal hooks '
         'precede closure of replacement .0.3 only; recurring .0.4, diagnostics and comments remain open.'),
    ):
        block += ('\n- ID: `' + PARENT + suffix + '`\n  Status: `pending`\n  Goal: ' + goal + '\n'
                  '  Dependencies: `' + PARENT + ('.0' if suffix == '.1' else '.1') + '`\n'
                  '  Acceptance: ' + acceptance + '\n')
    text = text[:start] + block + text[end:]
    text = replace(r'^\| 43\.4\.2\.0\.3 \|.*$',
        '| 43.4.2.0.3 | `' + PARENT + '` | `active` | Diagnose exact selected-occurrence replacement first. |\n'
        '| 43.4.2.0.3.0 | `' + OWNER + '` | `in_progress` | Original/rewritten Toolbox diagnosis and independent oracles. |\n'
        '| 43.4.2.0.3.1 | `' + PARENT + '.1` | `pending` | Repair the measured replacement boundary. |\n'
        '| 43.4.2.0.3.2 | `' + PARENT + '.2` | `pending` | Committed recurrence and canonical replacement acceptance. |', text)
    path.write_text(text)
    path = ROOT / 'MEMORY.md'; text = path.read_text()
    for field, value in {
        'activation_commit': '`' + REVISION + '` — clean canonical membership boundary.',
        'active_work_unit': '`' + OWNER + '` (in_progress) — exact replacement diagnosis.',
        'next_action': 'Freeze the original318-input membership claim at activation; retain current Toolbox '
                       'occurrence/frame/literal/value/error evidence before choosing the bounded replacement repair.',
        'in_flight_uncommitted': 'Owned .0.3.0 activation and diagnosis only; no production change. '
                               'Complete retained proof/docs/focused checks and normal commit before .0.3.1.',
    }.items():
        text = replace(r'^- ' + field + r':.*$', '- ' + field + ': ' + value, text)
    assert len(text.encode()) <= 8192 and len(text.splitlines()) <= 60
    path.write_text(text)
    print('Activated', OWNER, 'at', REVISION)


if __name__ == '__main__':
    main()
