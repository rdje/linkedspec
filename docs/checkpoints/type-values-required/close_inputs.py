"""Bind every new supporting source and artifact without duplicating old direct bindings."""
import gzip
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-required/'
recovery = json.loads((ROOT / (P + 'capsule-recovery.json')).read_bytes())
assert recovery['result'] == 'PASS'
assert all(not (ROOT / row['path']).exists() for row in recovery['rows'])
selected = json.loads((ROOT / (P + 'focused-final-inputs.json')).read_bytes())['selected']
native = set()
for path in selected:
    source = (ROOT / path).read_text()
    native.update(re.findall(r"['\"](docs/checkpoints/[^'\"]+\.json)['\"]", source))
    for prefix in re.findall(r"my \$prefix\s*=\s*'([^']+)'", source):
        native.update(prefix + name for name in re.findall(r"\$prefix\s*\.\s*'([^']+\.json)'", source))
assert len(native) == 15
paths = native | {str(path.relative_to(ROOT)) for path in (ROOT / P).iterdir() if path.is_file()}
inputs = {path: {key: c.read(path)[key] for key in ('sha256', 'mode')} for path in sorted(paths)}
c.write_new(P + 'closure.json', dict(inputs=inputs, native_inputs=sorted(native),
    producer=c.read(P + 'close_inputs.py'),
    scope='Closed support manifest includes every new source, measured artifact, exact '
          'recovery reference and all 15 original native JSON inputs. The current reader '
          'checks each hash and mode; the live claim directly binds this manifest and '
          'retains all823 prior direct inputs. No cap increase or prior binding removal.'))
print('Closed support manifest:', len(inputs), 'inputs including15 frozen native captures')
