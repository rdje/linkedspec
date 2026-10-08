"""Bind the finite measurement to its complete retained producer/input closure."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
review = json.loads((ROOT / (PREFIX + 'verification.json')).read_bytes())
controls = json.loads((ROOT / (PREFIX + 'controls.json')).read_bytes())
paths = set(review['input_hashes'])
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*'))
paths.update(['tools/roll_document_history.pl', 'tools/read_document_history.pl',
              'scripts/check_readme_routing_pressure.pl', 'tools/run_python_project_data.sh',
              'tools/project_data_env.sh', 'README_POLICY.md', 'docs/decisions/0069-bounded-change-and-notes-history.md'])
inputs = [{'path': path, 'sha256': hashlib.sha256((ROOT / path).read_bytes()).hexdigest(),
           'role': 'producer' if path.endswith(('.py', '.pl', '.sh')) else 'input'} for path in sorted(paths)]
claim = {'version': 1, 'owner': LEAF, 'claims': [{
    'name': 'finite_lossless_change_history_admission',
    'statement': 'One exact clean-record rollover and five finite registry scalars preserve all prior archive, decision and unrelated registry bytes; actual threshold and accepted-authority controls reject.',
    'scope': 'Exact clean e7674382295936a1d6d3dbd34272d9c6803a269d source and one actual new archive/manifest row. Initial formatting output and producer are retained, not silently refreshed. This measures storage admission only; canonical receipt/hooks independently govern landing. Public parser behavior, dependency boundaries and other controls stay unchanged. Git/OS/Perl/Python are necessary read-only external tools; all project data remains repository-local. No new explicit director grant, unlimited reserve or runtime repair is asserted.',
    'rederive': {'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'capacity.py review',
        'granularity': 'Individual source lines, complete records, exact physical manifest/registry rows and every prior archive/decision file; collection counts are derived from this enumeration.',
        'result': json.dumps({'history': review['history'], 'decisions': review['decisions'], 'archive': review['archive'], 'evidence_red': len(review['evidence_red'])}, sort_keys=True)},
    'falsify': {'status': 'checked',
        'hypothesis': 'Fitting capacity or matching aggregate sizes suffices even if history bytes, order, accepted authority or unrelated controls change.',
        'oracle': 'Existing ADR0069 retention contract and independently recovered clean Git line range/prefix/full suffix, manifest row order and prior file bytes; actual unmodified production limit and authorization functions.',
        'red_control': f'Actual rollover-required nonzero channel precedes actual --apply GREEN; {len(review["evidence_red"])} effective root/archive/decision/manifest/index/registry evidence corruptions reject. Actual production records retain {len(controls["thresholds"])} threshold observations and {len(controls["controls"])} missing/malformed authority RED controls. Retained initial normalization and index placement both reject under strengthened exact-byte review.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}
}]}
(ROOT / ('docs/claims/' + LEAF + '.json')).write_text(json.dumps(claim, indent=2) + '\n')
print('Claim binds retained actual producers, original snapshots and all artifact inputs.')
