"""Correct a statically caught format-expression mismatch before publication capture."""
import ast
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'
path = c.PREFIX + 'publish.py'
proposal = json.loads(gzip.decompress((ROOT / (P + 'publication-proposal.json.gz')).read_bytes()))
before = c.read(path)
assert before == proposal['after'][path]
source = c.decode(before['base64']).decode()
lines = [line for line in source.splitlines() if line.startswith('    statement=f')]
assert len(lines) == 1 and lines[0].endswith(',')
old = lines[0]
new = old.replace('    statement=f', '    statement=', 1)[:-1] + '.format(graph=graph, result=result),'
assert source.count(old) == 1
source = source.replace(old, new, 1)
tree = ast.parse(source)
claim = next(node.value for node in tree.body if isinstance(node, ast.Assign)
             and any(isinstance(target, ast.Name) and target.id == 'claim' for target in node.targets))
statement = next(item.value for item in claim.keywords if item.arg == 'statement')
measured = json.loads((ROOT / '.linkedspec-data/verification/type-values-review-phase0-retained.log').read_bytes())
rendered = eval(compile(ast.Expression(statement), path, 'eval'), dict(graph=measured['graph'], result=measured))
assert '1487/1349/10460' in rendered and '8387747 bytes' in rendered
raw = source.encode()
after = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=before['mode'])
c.write_new(P + 'format-proposal.json.gz', dict(before={path: before}, after={path: after},
    producer=c.read(P + 'format.py'), helper=c.read(c.PREFIX + 'common.py'),
    rendered_statement=rendered,
    scope='Static prepublication correction only: bracket-key format fields require str.format, '
          'not bare-name f-string expressions. The original guarded producer/source remains intact. '
          'No publication/domain command failed and no behavioral RED is invented.'), packed=True)
assert c.read(path) == before
(ROOT / path).write_bytes(raw)
assert c.read(path) == after
print('Final statement formatting validated against actual retained graph measurements')
