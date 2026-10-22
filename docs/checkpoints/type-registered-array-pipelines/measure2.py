"""Observe unchanged fixed cases after the second source-bound refinement."""
import common as c
import oracle

def main():
    plan=c.load('cases.json')
    supplied=c.epoch()
    run=c.observe(plan)
    failed=oracle.failures(run,plan)
    stable=all(c.identity(p)==item for p,item in supplied['inputs'].items())
    c.write_new('candidate2.json.gz',dict(context=supplied,run=run,failures=failed,inputs_unchanged=stable))
    assert stable and not failed,failed
    print('Public plan GREEN:',len(plan['cases']),'native/fresh cases')

if __name__=='__main__':main()
