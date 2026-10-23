"""Replay the corrected contract against accepted sources and restore current bytes."""
import common as c
plan=__import__('json').loads((c.ROOT/'tests/numeric-codeblocks/indexed-writes.json').read_bytes())
original=c.load('baseline2.json.gz')['source_inputs']
current={p:c.read(p) for p in c.SOURCES}
c.save('attribution4-before.json.gz',dict(current=current,original={p:original[p] for p in c.SOURCES},producer=c.read(c.PREFIX+'attribute4.py')))
try:
 for p in c.SOURCES:(c.ROOT/p).write_bytes(c.decode(original[p]['base64']))
 before=c.observe(plan)
finally:
 for p in c.SOURCES:(c.ROOT/p).write_bytes(c.decode(current[p]['base64']))
after=c.observe(plan)
stable=all(c.read(p)==packet for p,packet in current.items())
c.save('attribution4.json.gz',dict(plan=plan,before=before,after=after,before_failures=c.failures(before,plan),after_failures=c.failures(after,plan),restored=stable,sources=current,producer=c.read(c.PREFIX+'attribute4.py')))
print('Accepted RED',len(c.failures(before,plan)),'/ current failures',c.failures(after,plan),'/ exact restore',stable)
assert stable and not c.failures(after,plan)
