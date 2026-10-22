"""Attribute the old selector regression with actual prior-bridge/reapply controls."""
import common as c
import oracle

def main():
    path=c.SOURCES[0]
    saved=c.read(path)
    original=c.decode(saved['base64']).decode()
    old,new=c.load('refinement.json.gz')['replacements'][2]
    assert original.count(new)==1
    plan=c.load('compatibility-cases.json')
    c.write_new('compatibility-attribution-before.json.gz',dict(source=saved,old=old,new=new,
        producer=c.read(c.PREFIX+'compatibility_attribution.py')))
    try:
        c.source(path).write_text(original.replace(new,old,1))
        prior_source=c.read(path)
        prior=c.observe(plan)
        prior_failures=oracle.failures(prior,plan)
        c.write_new('compatibility-prior-bridge.json.gz',dict(source=prior_source,run=prior,failures=prior_failures))
    finally:
        c.source(path).write_bytes(c.decode(saved['base64']))
    reapplied=c.observe(plan)
    failures=oracle.failures(reapplied,plan)
    exact=c.read(path)==saved
    c.write_new('compatibility-reapplied.json.gz',dict(source=c.read(path),run=reapplied,failures=failures,sources_restored=exact))
    assert not prior_failures,prior_failures
    assert failures==c.load('compatibility-red.json.gz')['failures'] and exact
    print('Single bridge rollback GREEN / exact candidate3 reapply RED; actual attribution retained')

if __name__=='__main__':main()
