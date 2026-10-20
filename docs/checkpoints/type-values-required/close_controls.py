"""Correct the premeasurement census guard from its actual fifteen-path inventory."""
import ast
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-required/'
before = c.read(P + 'control_capture_final.py')
source = c.decode(before['base64']).decode()
assert source.count('assert len(native_inputs) == 14, sorted(native_inputs)') == 1
source = source.replace('assert len(native_inputs) == 14, sorted(native_inputs)',
                        'assert len(native_inputs) == 15, sorted(native_inputs)', 1)
source = source.replace('control_capture_final.py', 'control_capture_complete.py').replace(
    'controls-final-', 'controls-complete-')
after = dict(base64=c.encode(source.encode()), sha256=c.sha(source.encode()), mode=before['mode'])
ast.parse(source)
c.write_new(P + 'control-census-repair.json.gz', dict(before=before, after=after,
    rejected_output=c.read('.linkedspec-data/verification/type-values-required-controls-final.log'),
    rejected_status=c.read('.linkedspec-data/verification/type-values-required-controls-final.status'),
    producer=c.read(P + 'close_controls.py'),
    scope='The literal-path inventory discovers 15 frozen native JSON inputs. The guessed '
          '14 guard rejects before any input capture or measurement. Preserve that exact '
          'source/output; the separate complete actor uses the observed census.'),
    packed=True)
path = ROOT / (P + 'control_capture_complete.py')
assert not path.exists()
path.write_bytes(source.encode())
path.chmod(after['mode'])
print('Actual fifteen-path census retained; complete actor prepared')
