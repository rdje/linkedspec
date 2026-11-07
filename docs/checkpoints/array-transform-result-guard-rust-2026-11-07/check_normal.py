"""Check actual semantic frames/counts before advancing from a normal epoch."""
import importlib.util
import json
from pathlib import Path
import sys

BASE = Path(__file__).resolve().parent
phase, image = sys.argv[1:]
assert phase in ('private-old', 'private-fixed', 'direct') and image in ('old', 'fixed')
assert (phase == 'private-old') == (image == 'old')
spec = importlib.util.spec_from_file_location('finite_array_recovery', BASE / 'review.py')
reader = importlib.util.module_from_spec(spec)
spec.loader.exec_module(reader)
cases = json.loads((BASE / 'intake/cases.json').read_bytes())
source_phase = 'intake' if image == 'old' else 'repaired-after'
expected = reader.frames(reader.raw(source_phase + '/native-stdout.log.gz'), 'ARRAY_TRANSFORM_RUST')
red = set(json.loads((BASE / 'baseline.json').read_bytes())['red']) if image == 'old' else set()
reader.normal(phase, expected, cases, red, phase == 'direct')
print(phase + ': actual195 semantic frames/counts match ' + image + ' public observations')
