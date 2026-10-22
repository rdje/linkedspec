"""Measure the declared fixed plan, retaining inputs before every public observation."""
import json
from pathlib import Path
import re
import sys
import common as c
import context
import oracle


def loaded(run, inputs):
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    observed = json.loads(c.decode(run['stdout_base64']))
    result = {}
    for path in c.SOURCES + ['perl/LinkedSpec.pm']:
        key = path.removeprefix('perl/')
        assert Path(observed['inc'][key]).resolve() == c.ROOT/path, path
        result[path] = c.identity(path)
        assert result[path] == inputs[path], path
    return result


def main():
    assert len(sys.argv) == 2 and re.fullmatch(r'accepted|candidate[1-9][0-9]*', sys.argv[1])
    stem = sys.argv[1]
    plan = c.load('cases.json')
    supplied = context.snapshot()
    if stem == 'accepted':
        prior = c.load('prior.json.gz')
        for path in c.SOURCES:
            assert supplied['inputs'][path] == {key:prior['images'][path][key] for key in ('sha256','mode')}
    c.write_new(stem+'-inputs.json.gz', supplied)
    run = c.run(['perl','-Iperl',c.PREFIX+'probe.pl'], input=json.dumps(plan).encode())
    stable = c.unchanged(supplied['inputs'])
    c.write_new(stem+'-observed.json.gz', dict(run=run, inputs_unchanged=stable))
    failed = oracle.failures(run, plan)
    actual = loaded(run, supplied['inputs'])
    c.write_new(stem+'-run.json.gz', dict(failures=failed, loaded_sources=actual,
        inputs_unchanged=stable, cases=len(plan['cases'])))
    assert stable
    if stem == 'accepted':
        assert 'deferred/count/free/integers' in failed
        assert 'deferred/first/receiver/integers' in failed
        assert 'ordinary/count/free/harray' in failed
        assert 'ordinary/first/free/harray' in failed
        print('Accepted:',len(failed),'RED /',len(plan['cases'])-len(failed),'controls')
    else:
        assert not failed, json.dumps(failed, sort_keys=True)
        print('Candidate GREEN:',len(plan['cases']),'cases, native/descriptor/fresh source; inputs unchanged')


if __name__ == '__main__':
    main()
