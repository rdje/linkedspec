"""Retain each complete supplied epoch, actual observer output and loaded-source identities."""
import json
from pathlib import Path
import re
import sys
import common as c
import context
import oracle


def main():
    assert len(sys.argv) == 2 and re.fullmatch(r'accepted(?:[1-9][0-9]*)?|candidate[1-9][0-9]*', sys.argv[1])
    stem = sys.argv[1]
    plan = c.load('cases.json')
    supplied = context.snapshot()
    if stem.startswith('accepted'):
        prior = c.load('prior.json.gz')
        for path in c.SOURCES:
            assert supplied['inputs'][path] == {key: prior['images'][path][key] for key in ('sha256', 'mode')}
    c.write_new(stem + '-inputs.json.gz', supplied)
    run = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(plan).encode())
    stable = c.unchanged(supplied['inputs'])
    observed_name = stem + '-observed.json.gz'
    c.write_new(observed_name, dict(run=run, inputs_unchanged=stable))
    failed = oracle.failures(run, plan)
    loaded = {}
    if run['returncode'] == 0 and not c.decode(run['stderr_base64']):
        observed = json.loads(c.decode(run['stdout_base64']))
        for path in c.SOURCES + ['perl/LinkedSpec/CodeblockRuntime.pm']:
            key = path.removeprefix('perl/')
            actual = Path(observed['inc'][key]).resolve()
            assert actual == c.ROOT / path, path
            loaded[key] = dict(path=path, **c.identity(path))
    c.write_new(stem + '-run.json.gz', dict(observation=observed_name,
        observation_identity=c.identity(c.PREFIX + observed_name), failures=failed,
        inputs_unchanged=stable, loaded_sources=loaded,
        scope='Actual descriptor/native Get-dump/fresh emitted observations; loaded source paths and full byte/mode identities validated at measurement time. Raw original channels stay exact; durable path identities are repository-relative.'))
    assert stable, 'supplied input changed'
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64']), 'observer transport failed; retained raw channels'
    assert len(loaded) == len(c.SOURCES) + 1, 'loaded source identity check incomplete'
    if stem.startswith('accepted'):
        assert failed and 'ordinary/free/argument-copy/integer' in failed
        assert 'implicit-accumulator/argument-copy' in failed
        print('Actual accepted runtime:', len(failed), 'RED /', len(plan['cases']) - len(failed), 'controls;', len(plan['cases']), 'fixed cases; loaded source bytes and all supplied inputs unchanged')
    else:
        assert not failed, json.dumps(failed, sort_keys=True)
        print('Candidate typed-value GREEN:', len(plan['cases']), 'fixed cases; loaded sources and all supplied inputs unchanged')


if __name__ == '__main__':
    main()
