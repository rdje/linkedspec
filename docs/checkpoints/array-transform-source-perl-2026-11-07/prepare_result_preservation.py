"""Retain the original37 current result defects separately from source repair."""
from pathlib import Path

BASE = Path(__file__).resolve().parent
PRIOR = Path('docs/checkpoints/array-transform-result-perl-2026-11-07')
fixture = 'tests/fixtures/array_transform_result_guard_cases.json'
observer = (PRIOR / 'observer.pl').read_text()
observer = observer.replace('array-transform-result-perl-2026-11-07', 'array-transform-source-perl-2026-11-07')
observer = observer.replace('docs/checkpoints/array-transform-source-perl-2026-11-07/cases.json', fixture)
(BASE / 'observe_results.pl').write_text(observer)
capture = (PRIOR / 'capture_qualified.py').read_text()
capture = capture.replace("('preflight', 'after', 'inverse', 'restored')", "('preserved_results',)")
capture = capture.replace("BASE / 'observer.pl'", "BASE / 'observe_results.pl'")
capture = capture.replace("BASE / 'cases.json'", "Path('" + fixture + "')")
(BASE / 'capture_results.py').write_text(capture)
print('Prepared unchanged37 current result-preservation observer; no result guard edit')
