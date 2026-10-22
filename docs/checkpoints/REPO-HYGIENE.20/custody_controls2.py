"""Exercise actual accepted-custody denials without changing original packets."""
import copy
import json
import common as c


def main():
    value = c.load('prior10.json.gz')
    command = ['bash','tools/run_python_project_data.sh',c.PREFIX+'custody_final.py']
    healthy = c.run(command)
    c.write_new('custody2-healthy.json.gz',dict(run=healthy))
    cases = {name:copy.deepcopy(value) for name in ('missing','mode','permission','baseline')}
    cases['missing']['images'].pop('MEMORY.md')
    cases['mode']['images']['docs/claims/TYPE-REFERENCE-BOOK.1.2.10.json']['mode'] ^= 0o100
    cases['permission']['images']['noncore/AmbiTiming.pm']['mode'] ^= 0o004
    cases['baseline']['baseline']['returncode'] = 1
    reasons = dict(missing=b'complete image population',mode=b'owned full-mode packet',permission=b'accepted byte/mode declaration',baseline=b'actual clean baseline')
    results = {}
    for name,mutant in cases.items():
        stem = 'custody2-fault-'+name+'.json.gz'
        c.write_new(stem,mutant)
        run = c.run(command+[stem])
        results[name] = run
        assert run['returncode'] != 0 and b'AssertionError: '+reasons[name] in c.decode(run['stderr_base64']),name
    restored = c.run(command)
    c.write_new('custody2-controls.json.gz',dict(healthy=healthy,faults=results,restored=restored))
    assert healthy['returncode']==restored['returncode']==0
    assert not c.decode(healthy['stderr_base64']) and not c.decode(restored['stderr_base64'])
    print('Accepted10 custody PASS; missing-image/executable/full-permission/baseline actual denials; original packets unchanged')


if __name__ == '__main__':
    main()
