"""Reconcile the owned canonical blocker into the prepared membership handoff."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2'
OLD = 'closeout; production/fixtures/CI/hooks/dependencies unchanged.'
NEW = ('closeout; production/Perl fixtures/CI/hooks/dependencies unchanged. '
       'Historical evidence auditor now admits only the committed one-line scanner-mock '
       'delta through an exact whole-file Git inverse. Original auditor RED/five source '
       'denials and isolated134-input recovery/22 controls/60 evolution denials pass; '
       'original historical bytes and hashes remain exact.')


def main():
    verification = json.loads((ROOT / ('docs/checkpoints/' + OWNER + '-historical-verification.json')).read_bytes())
    assert verification['complete'] and verification['evolution_controls'] == 60
    for name in ('CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
                 'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md',
                 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'):
        path = ROOT / name
        text = path.read_text()
        assert OLD in text, name
        path.write_text(text.replace(OLD, NEW))
    path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
    text = path.read_text()
    start = text.index('- ID: `' + OWNER + '`')
    end = text.index('\n- ID:', start + 1)
    block = text[start:end]
    block = block.replace('Production, original fixtures/producers, dependencies, CI and hooks remain unchanged.',
                          'Also own tests/language-readiness/verify_objectives.py for the exact historical scanner-mock inverse and its falsifiers. Production, original Perl fixtures/producers, dependencies, CI and hooks remain unchanged.')
    block = block.replace('Run claims/Knowledge/memory/history/diff and all doctrines.',
                          'Retain the original failed canonical candidate and auditor; independently recur original historical RED, exact whole-file inverse GREEN and missing/duplicate/disabled/foreign/unrelated source denials. Execute isolated historical recovery with original-log-read/tracked-write guards. Run claims/Knowledge/memory/history/diff and all doctrines.')
    block = block.replace('Acceptance changes evidence/teaching/current pointers only; every production and standard-test input remains activation-exact.',
                          'Acceptance preserves every production and Perl-test input. The historical evidence auditor adds only the Git-bound inverse of the committed scanner mock; original historical source/hash authority remains exact.')
    block += ('\n  Verified canonical-blocker repair: Original auditor reproduces unreviewed signature-regression drift on the committed Phase0 source. The new exact af5d/31395 one-line inverse reconstructs the complete historical source; five missing/duplicate/disabled/foreign/extra-edit controls reject. Complete isolated historical replay restores134 inputs/84,613,241 bytes, passes22 recovery controls and60 evolution denials, and records zero healthy original-log reads/tracked writes. Retained failed-canonical.json includes the complete initial CI stream and exact staged binary patch; before-historical-verifier.py preserves the original producer. No prior historical measurement is refreshed.\n')
    text = text[:start] + block + text[end:]
    later = '- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.4`'
    start = text.index(later)
    end = text.index('\n- ID:', start + 1)
    block = text[start:end]
    block += '\n  Dependency correction: The already committed Phase0 compiler-mock inverse is verified by .0.2.2 because it blocks canonical membership acceptance. This leaf still owns only its later recurring-registration historical reconciliation.\n'
    path.write_text(text[:start] + block + text[end:])
    # Keep the original handoff producer honest about the final repair scope.
    path = ROOT / ('docs/checkpoints/' + OWNER + '-publish-docs.py')
    text = path.read_text().replace('"closeout; production/fixtures/CI/hooks/dependencies unchanged. Replacement, diagnostic "',
        '"closeout; production/Perl fixtures/CI/hooks/dependencies unchanged. The exact historical scanner-mock inverse and original auditor RED/source controls are retained in this leaf. Replacement, diagnostic "')
    text = text.replace('Acceptance changes evidence/teaching/current pointers only; every production and standard-test input remains activation-exact.',
                        'Acceptance preserves production/Perl tests and adds only the exact historical scanner-mock inverse; original historical source/hash authority remains exact.')
    path.write_text(text)
    path = ROOT / 'git_message_brief.txt'
    text = path.read_text()
    path.write_text(text.rstrip() + '\n\nReconcile only the committed Phase0 scanner mock through an exact Git-bound historical inverse; retain original CI/auditor RED, five source denials and complete isolated134-input audit.\n')
    print('Historical blocker and dependency correction recorded in current handoff')


if __name__ == '__main__':
    main()
