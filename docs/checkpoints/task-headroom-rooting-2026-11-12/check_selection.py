"""Compare the actual epoch selection with the independently retained preflight."""
import json
from pathlib import Path
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
expected=json.loads((BASE/'preflight-result.json').read_bytes())
actual=json.loads(Path('docs/history/task-narrative-epochs/TYPE-REFERENCE-BOOK.1.2.23.4.32.json').read_bytes())
assert actual['selected']==expected['eligible_closed']
assert actual['sha256']==expected['sha256'] and actual['bytes']==expected['bytes']
assert actual['source_commit']==expected['activation'] and actual['source_path']==expected['source']
print(json.dumps(dict(actual_selection='PASS',selected_closed=len(actual['selected']),source=actual['source_path'],scope='Actual selection/source identity matches independent preflight; complete preservation and historical corruptions remain separately required.')))
