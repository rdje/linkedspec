"""Judge corrected214 while retaining original rejected epochs and known95 distinction."""
import json
import sys
import common as c
import oracle


def check(epoch="candidate3"):
    plan=c.load('cases2.json')
    run=c.load(epoch+'-run.json.gz')
    assert run['inputs_unchanged']
    failures=oracle.failures(run['run'],plan)
    return dict(cases=len(plan['cases']),failures=failures,
        value_cases=sum('expected' in row for row in plan['cases']),
        diagnostics=sum('expected' not in row for row in plan['cases']))


def main():
    epoch=sys.argv[1] if len(sys.argv)>1 else "candidate3"
    assert epoch in ("candidate2","candidate3")
    result=check(epoch)
    c.write_new(epoch+'-review.json.gz',dict(result=result,producer=c.read(c.PREFIX+'review_current.py'),
        oracle=c.read(c.PREFIX+'oracle.py')))
    print(json.dumps(result,sort_keys=True))
    assert not result['failures']


if __name__=='__main__':main()
