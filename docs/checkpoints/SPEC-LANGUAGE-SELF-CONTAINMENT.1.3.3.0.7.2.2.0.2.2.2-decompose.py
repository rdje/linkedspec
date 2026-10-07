"""Keep corrected membership open after the grouped-pattern interaction diagnosis."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
PARENT = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2'
OWNER = PARENT + '.0'


def main():
    path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'; text = path.read_text()
    start = text.index('- ID: `' + PARENT + '`'); end = text.index('\n- ID:', start + 1)
    block = text[start:end]; assert '  Status: `in_progress`' in block
    block = block.replace('  Status: `in_progress`', '  Status: `active`', 1)
    block = re.sub(r'^  (Verification tier|Focused checks|Canonical trigger|Claim verification):.*\n', '', block, flags=re.M)
    block += ('\n  Owned grouped-pattern defect: On exact corrected0f31461d6, fixed x,y causes MethodExpr::_helper_pattern_ranges to interpret the signature closer at8 as a host quote, skipping real grouped pattern roles at43..64/43..63. SourceMembership already protects its own two signature delimiters, but its precomputed helper-role query does not. The grouped slash fallback retains numeric-call precedence, so actual set_value origin45..59 inside regex data stays selected. x,z/rest-y retain their pattern roles and exclude the same raw event. All native values return1; return_general-only checks also pass and are insufficient. Preserve exact source/real origins/producer channels; no source-span, value, fixture or diagnostic waiver.\n'
        '  Safe decomposition: .0 commits completed bounded immutable73-command proof, exact202-hash history freeze and supplemental diagnosis without closure. .1 owns the compiler-specific callable/helper-pattern precedence repair while preserving ordinary scanner/default MethodExpr/numeric/host-quote contracts. .2 independently accepts the corrected committed source with grouped-pattern oracles and exact staged canonical receipt. This parent and membership .0.2 stay open.\n')
    children = ('\n- ID: `' + OWNER + '`\n'
        '  Status: `in_progress`\n'
        '  Goal: Retain bounded corrected membership recurrence and own the grouped-pattern defect.\n'
        '  Dependencies: `.1.3.3.0.7.2.2.0.2.2.1`\n'
        '  Activation: Same clean0f31461d696186775585e19355a0bc5c41849dfb acceptance boundary; no production/test change or task-tree pivot. Transfer the already owned in-flight acceptance evidence after a tool-proved interaction gap.\n'
        '  Owned paths: Existing .0.2.2.2-prefixed immutable capture/review/book/history/grouped diagnosis and retention instruments/artifacts; this child claim; prior .1 record mode/revision-only freeze; new grouped-pattern Knowledge and current book/task/index/roadmaps/live/resume/change/notes. Production/tests/contracts/CI/hooks/dependencies remain unchanged.\n'
        '  Verification tier: `focused`\n'
        '  Focused checks: Complete immutable73-command compiler40/original22-public/callable3/direct16-suite proof and retained original RED/effective controls; actual grouped primitive/return-family diagnostics with complete committed inputs and separately declared observer programs, source/real origin/native/fresh channels and distinguishing controls. Exact202-hash historical freeze, full book render/claim/Knowledge/memory/history/diff and normal hooks.\n'
        '  Canonical trigger: None for this bounded proof checkpoint and diagnosis; no production or parent/admission closure. Grouped-pattern correction .1 and fresh committed canonical .2 remain mandatory before membership closes.\n'
        '  Claim verification: `docs/claims/' + OWNER + '.json`\n'
        '  Acceptance: Preserve completed original bounded recurrence without promoting successful values to full membership acceptance. Record exact new defect/reproduction/impact/repair owner and original instrument retention, commit the bounded proof, then activate repair .1 from clean HEAD.\n'
        '\n- ID: `' + PARENT + '.1`\n'
        '  Status: `pending`\n'
        '  Goal: Preserve grouped helper-pattern roles in compiler membership inside callable signatures.\n'
        '  Dependencies: `.1.3.3.0.7.2.2.0.2.2.2.0`\n'
        '  Candidate owners: SourceMembership helper-role query and narrowly opt-in MethodExpr helper-pattern traversal; retain original ordinary scanner/default query, host/numeric/grouped/indexed roles and event/argument/origin/schema/caller-error contracts. Select exact shared delimiter ownership after original Toolbox source/packet diagnosis; no masked source or inferred equal-raw pairing.\n'
        '  Acceptance: Author grouped dot/comma and genuine/numeric/host/indexed/body/nested/operator/fixed/rest controls before production; retain original source-bound RED and exact GREEN, original public/native/fresh/metadata/channel authority, all unchanged direct consumers/full Phase0, book/claims/Knowledge and normal hooks. Parent remains open for .2.\n'
        '\n- ID: `' + PARENT + '.2`\n'
        '  Status: `pending`\n'
        '  Goal: Independently accept committed membership including callable grouped patterns.\n'
        '  Dependencies: `.1.3.3.0.7.2.2.0.2.2.2.1`\n'
        '  Acceptance: Fresh immutable corrected committed inputs without production overlays; original membership/signature/grouped-pattern/source/argument/reference/value/error/metadata oracles and unchanged complete consumers. Effective evidence/retention/render controls and exact staged canonical receipt/normal hooks before closing this acceptance parent, .0.2.2 and membership .0.2 only. Replacement .0.3, recurring .0.4, diagnostic origin .7.2.2.1 and comments .7.3 remain separate.\n')
    text = text[:start] + block + children + text[end:]
    old = '| 43.4.2.0.2.2.2 | `' + PARENT + '` | `in_progress` | Fresh corrected committed recurrence and exact canonical membership acceptance. |'
    assert text.count(old) == 1
    text = text.replace(old, '| 43.4.2.0.2.2.2 | `' + PARENT + '` | `active` | Bounded recurrence exposes grouped-pattern signature gap; corrective children own acceptance. |\n'
        '| 43.4.2.0.2.2.2.0 | `' + OWNER + '` | `in_progress` | Retain immutable proof and source-bound grouped-pattern diagnosis. |\n'
        '| 43.4.2.0.2.2.2.1 | `' + PARENT + '.1` | `pending` | Correct compiler callable/grouped-helper pattern precedence. |\n'
        '| 43.4.2.0.2.2.2.2 | `' + PARENT + '.2` | `pending` | Independently accept complete corrected committed membership. |')
    path.write_text(text)
    path = ROOT / 'MEMORY.md'; text = path.read_text()
    for field, value in {
        'active_work_unit': '`' + OWNER + '` (in_progress) — bounded corrected recurrence and grouped-pattern diagnosis.',
        'next_action': 'Finish immutable73-command capture and supplemental source/real-origin/public diagnosis; grade controls/history/book, retain bounded checkpoint and commit. Then activate grouped-pattern repair .0.2.2.2.1; fresh committed canonical .0.2.2.2.2 precedes membership closure.',
        'in_flight_uncommitted': 'Owned immutable recurrence/supplemental capture still running; no production/tests change. Actual x,y grouped dot/comma regex retains fake set origin45..59, unlike x,z/rest-y; native1/return scans alone miss it. Original202 hashes frozen exactly. Membership stays open; checkpoint and corrective/canonical children own the work.',
    }.items():
        text, count = re.subn(r'^- ' + field + r':.*$', lambda m: '- ' + field + ': ' + value, text, flags=re.M)
        assert count == 1
    path.write_text(text)
    print('Owned bounded checkpoint', OWNER, 'and grouped-pattern repair', PARENT + '.1')


if __name__ == '__main__':
    main()
