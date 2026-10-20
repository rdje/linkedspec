"""Close the quiet observer epoch, preserving the previous support manifest."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-required/'
prior = json.loads((ROOT / (P + 'closure.json')).read_bytes())
native = prior['native_inputs']
assert len(native) == 15
assert all(all(c.read(path)[key] == prior['inputs'][path][key] for key in ('sha256', 'mode'))
           for path in native)
paths = set(native) | {str(path.relative_to(ROOT)) for path in (ROOT / P).iterdir() if path.is_file()}
inputs = {path: {key: c.read(path)[key] for key in ('sha256', 'mode')} for path in sorted(paths)}
c.write_new(P + 'closure-final.json', dict(inputs=inputs, native_inputs=native,
    producer=c.read(P + 'close_inputs_final.py'),
    scope='The former support manifest stays immutable. This complete epoch adds the '
          'warning correction, stopped publication manifest and exact rejected environment '
          'result. Every support source/artifact and all15 frozen inputs are hash/mode gated; '
          'the live claim still retains all823 former direct input bindings.'))
print('Final support closure:', len(inputs), 'inputs; all15 native identities unchanged')
