"""One-cell source-layout calibration after exact activation/current comparison."""
import base64
import gzip
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
NAME = 'tests/fixtures/count_result_guard_excluded_ast.json'
original = (ROOT / NAME).read_bytes()
assert original == subprocess.check_output(['git', 'show', '7289836f28e4873463ad1c50d354d8e66c77af8d:' + NAME], cwd=ROOT)
saved = HERE / 'count-fence-original.json.gz'
assert not saved.exists(), 'one-shot original fixture retention'
saved.write_bytes(gzip.compress(original, mtime=0))
capture = json.loads(gzip.decompress((HERE / 'count-fence-qualified.json.gz').read_bytes()))
frames = {name: json.loads(base64.b64decode(row['frame']['base64'])) for name, row in capture['commands'].items()}
assert frames['activation']['rows'] == frames['repaired']['rows']
assert frames['activation']['excluded'] == frames['repaired']['excluded']
rows = json.loads(original)
changes = [(index, key) for index, (old, new) in enumerate(zip(rows, frames['activation']['rows']))
           for key in old if old[key] != new[key]]
assert len(rows) == len(frames['activation']['rows']) == 18 and changes == [(0, 'lowered')]
old_cell = json.dumps(rows[0]['lowered'], ensure_ascii=False)
new_cell = json.dumps(frames['activation']['rows'][0]['lowered'], ensure_ascii=False)
assert original.count(old_cell.encode()) == 1
updated = original.replace(old_cell.encode(), new_cell.encode(), 1)
assert json.loads(updated) == frames['activation']['rows']
(ROOT / NAME).write_bytes(updated)
print(json.dumps(dict(result='calibrated', changed_cells=changes), sort_keys=True))
