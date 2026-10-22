"""Reproduce the exact existing count/first controls through public diagnostics."""
import json
import common as c
import oracle

def main():
    fixture='tests/numeric-codeblocks/count-first.json'
    ids={scope+'/'+method+'/effects/receiver/extra' for scope in ('ordinary','deferred') for method in ('count','first')}
    original=json.loads(c.source(fixture).read_bytes())
    plan=dict(cases=[case for case in original['cases'] if case['id'] in ids])
    assert {case['id'] for case in plan['cases']}==ids
    c.write_new('compatibility-cases.json',plan)
    supplied=c.epoch()
    run=c.observe(plan)
    failures=oracle.failures(run,plan)
    c.write_new('compatibility-red.json.gz',dict(context=supplied,fixture=c.read(fixture),run=run,failures=failures,
        producer=c.read(c.PREFIX+'compatibility.py')))
    assert set(failures)=={name for name in ids if name.startswith('ordinary/')},failures
    print('Exact old public controls: two ordinary RED, two deferred GREEN; fixture unchanged')

if __name__=='__main__':main()
