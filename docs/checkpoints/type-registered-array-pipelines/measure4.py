"""Execute the fixed new plan and untouched prior selector controls on final code."""
import common as c
import oracle

def main():
    plan=c.load('cases.json')
    compatibility=c.load('compatibility-cases.json')
    supplied=c.epoch()
    run=c.observe(plan)
    prior=c.observe(compatibility)
    failures=oracle.failures(run,plan)
    prior_failures=oracle.failures(prior,compatibility)
    stable=all(c.identity(p)==item for p,item in supplied['inputs'].items())
    c.write_new('candidate4.json.gz',dict(context=supplied,run=run,failures=failures,
        compatibility=prior,compatibility_failures=prior_failures,inputs_unchanged=stable))
    assert stable and not failures and not prior_failures,(failures,prior_failures)
    print('Final public GREEN:',len(plan['cases']),'fixed cases +',len(compatibility['cases']),'unchanged selector controls')

if __name__=='__main__':main()
