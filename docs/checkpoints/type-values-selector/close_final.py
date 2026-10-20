"""Close actual scanner inputs and all selector/storage artifacts before fresh re-derivation."""
import json
import runpy
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import partition_storage as storage

P = storage.P
assert storage.load('partition-removal.json')['result'] == 'PASS'
namespace = runpy.run_path(str(ROOT / 'tools/check_executable_aggregate_selector_sources.py'))
candidates = namespace['candidate_files']()
eligible = sorted(path for path in candidates
                  if Path(path).suffix not in namespace['EXCLUDED_SUFFIXES']
                  and (ROOT / path).is_file())
assert all(not (ROOT / path).is_symlink() for path in eligible)
support = {str(path.relative_to(ROOT)) for path in (ROOT / P).rglob('*') if path.is_file()}
paths = set(eligible) | support
inputs = {path: {key: c.read(path)[key] for key in ('sha256', 'mode')} for path in sorted(paths)}
oversized = {path: (ROOT / path).stat().st_size for path in candidates
             if (ROOT / path).is_file() and (ROOT / path).stat().st_size > 100 * 1024 * 1024}
assert not oversized, oversized
commands = [
    ['bash', 'tools/run_python_project_data.sh', 'tools/check_executable_aggregate_selector_sources.py'],
    ['bash', 'tools/run_python_project_data.sh', 'tools/check_executable_aggregate_selector_sources.py', '--concurrency-self-test'],
    ['bash', 'tools/run_python_project_data.sh', 'tools/check_public_aggregate_selector_surface.py'],
]
c.write_new(P + 'closure-final.json', dict(inputs=inputs, scanner_candidates=eligible, commands=commands,
    producer=c.read(P + 'close_final.py'), candidate_files=len(candidates),
    oversized_files=oversized,
    scope='Every actual regular scanner input, including binary decoding candidates, and '
          'all supporting producers/artifacts/parts have identities and modes before fresh '
          'composed re-derivation. JSON measurement outputs are excluded by the unchanged '
          'scanner suffix contract. No initial full-global manifest is inferred for the '
          'earlier finite control epoch. Logical oversized inputs resolve through indices; '
          'the current claim binds their actual physical storage.'))
print('Complete closure:', len(inputs), 'inputs;', len(eligible), 'scanner candidates; oversized0')
