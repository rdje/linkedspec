"""Retain fixed-oracle classification before judging aggregate candidate results."""
import collections
import json
import common as c
import oracle


def main():
    plan=c.load('final-cases.json')
    result={}
    for epoch in ('red-final','candidate1'):
        record=c.load(epoch+'-run.json.gz')
        assert record['inputs_unchanged']
        failed=oracle.failures(record['run'],plan)
        result[epoch]=dict(failures=failed,raw=c.identity(c.PREFIX+epoch+'-run.json.gz'),
            inputs=c.identity(c.PREFIX+epoch+'-inputs.json.gz'))
        print(epoch,len(failed),'failures',collections.Counter(row['id'].split('/')[0] for row in failed))
        for row in failed[:8]:print(json.dumps(row,sort_keys=True))
    c.write_new('candidate1-review.json.gz',dict(result=result,
        producer=c.read(c.PREFIX+'review_candidate.py'),oracle=c.read(c.PREFIX+'oracle.py')))
    assert result['red-final']['failures']
    assert not result['candidate1']['failures']
    print('All214 fixed aggregate values/causes PASS; known sorted diagnostic remains owned9')


if __name__=='__main__':main()
