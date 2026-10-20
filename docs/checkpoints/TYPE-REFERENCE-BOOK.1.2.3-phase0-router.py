"""Preserve the static rewrite collision and install a small direct publisher entrypoint."""
import ast
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import publish_phase0

P = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'
path = c.PREFIX + 'publish.py'
before = c.read(path)
proposal = json.loads(gzip.decompress((ROOT / (P + 'publication-proposal.json.gz')).read_bytes()))
assert before == proposal['after'][path]
source = '"""Stable readonly publication entrypoint; --capture is one-shot."""\nfrom publish_phase0 import main\n\nif __name__ == "__main__":\n    main()\n'
ast.parse(source)
measured = json.loads((ROOT / '.linkedspec-data/verification/type-values-review-phase0-retained.log').read_bytes())
claim = publish_phase0.make_claim(measured, [])
assert '1487/1349/10460' in claim['statement'] and '8387747 bytes' in claim['statement']
raw = source.encode()
after = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=before['mode'])
c.write_new(P + 'router-proposal.json.gz', dict(before={path: before}, after={path: after},
    producer=c.read(P + 'router.py'), publisher=c.read(c.PREFIX + 'publish_phase0.py'),
    rejected_rewrite=c.read(P + 'publication.py'), rejected_format=c.read(P + 'format.py'),
    rejected_format_output=c.read('.linkedspec-data/verification/type-values-phase0-format.log'),
    scope='The broad rewrite matched a preflight scope before the claim scope, removing a block. '
          'Static inspection catches this before any publication/domain execution. Full malformed '
          'source and original writer remain intact. A directly authored module replaces rewriting; '
          'its statement is validated against actual retained measurements. No behavioral RED is invented.'), packed=True)
assert c.read(path) == before
(ROOT / path).write_bytes(raw)
assert c.read(path) == after
print('Direct publisher and stable entrypoint replace the retained static rewrite collision')
