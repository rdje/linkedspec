"""Retain actual public channels and final product/instrument bytes before review."""
import sys
import common as c
name=sys.argv[1]
plan=c.load('cases2.json')
sources={p:c.read(p) for p in c.SOURCES+[c.PREFIX+'common.py',c.PREFIX+'measure.py',c.PREFIX+'cases2.json',c.PREFIX+'probe.pl']}
run=c.observe(plan);failed=c.failures(run,plan)
c.save(name,dict(sources=sources,run=run,failures=failed))
print('Public cases:',len(plan['cases']),'; failures:',failed)
