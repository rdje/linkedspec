"""Freeze exact unchanged authored sources after original and copy qualification."""
import json
from pathlib import Path
BASE=Path('docs/checkpoints/hash-view-selection-2026-11-06')
original=json.loads((BASE/'cases.json').read_bytes())
copy_controls=json.loads((BASE/'copy-controls.json').read_bytes())
views=[row for row in original if row['id'] not in {'constructor_copy_oracle','arity_profile'}]
views += [row for row in copy_controls if row['id']=='constructor_rejected_with']
assert len(views)==15 and len(copy_controls)==6
for name,rows in [('hash_view_result_guard_cases.json',views),('copy_result_guard_cases.json',copy_controls)]:
 target=Path('tests/fixtures')/name;assert not target.exists();target.write_text(json.dumps(rows,indent=2)+'\n')
print('Unchanged source targets frozen: original14 plus qualified constructor1; separate copy6')
