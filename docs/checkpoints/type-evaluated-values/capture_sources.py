"""Capture current owned authorities from the accepted complete conservative selection."""
import gzip
import json
import subprocess
import common as c

prior = json.loads(gzip.decompress((c.ROOT / 'docs/checkpoints/type-reference-inventory/source-inputs.json.gz').read_bytes()))
paths = set(prior['inputs'])
paths.update(c.PREFIX + name for name in ('common.py', 'preserve.py', 'capture_sources.py'))
inputs = {path: c.read(path) for path in sorted(paths)}
for path in prior['inputs']:
    raw = subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
    assert c.decode(inputs[path]['base64']) == raw, ('actual accepted current source', path)
c.write_new(c.PREFIX + 'source-inputs.json.gz', dict(inputs=inputs, base_commit=c.BASE,
    prior_selection_sha256=c.sha((c.ROOT / 'docs/checkpoints/type-reference-inventory/source-inputs.json.gz').read_bytes()),
    producer=c.read(c.PREFIX + 'capture_sources.py'), helper=c.read(c.PREFIX + 'common.py'),
    scope='Reuse the declared conservative owned selection, retaining current accepted bytes/modes before '
          'diagnostics. This is custody, not a new full-reading or operation-count admission. Submodules '
          'and other-repository implementations remain excluded.'), packed=True)
print('Current owned authority/runtime/test/book source custody retained:', len(inputs))
