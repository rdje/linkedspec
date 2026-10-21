"""Falsify the actual publisher's physical byte/mode/population validation."""
import copy
import json
import sys
import common as c
import publish

def main():
    producer=c.read(c.PREFIX+'publish.py')
    path=c.PREFIX+'candidate3-run.json.gz'
    actual={path:c.identity(path)}
    cases=dict(omission={},byte=copy.deepcopy(actual),mode=copy.deepcopy(actual))
    cases['byte'][path]['sha256']='0'*64
    cases['mode'][path]['mode']^=0o100
    c.write_new('artifact-inputs.json.gz',dict(actual=actual,cases=cases,producer=producer,
        actor=c.read(c.PREFIX+'artifacts.py')))
    command=[sys.executable,c.PREFIX+'publish.py','--controls']
    healthy=c.run(command)
    before='def validate_inputs(declared,actual):\n'
    text=c.decode(producer['base64']).decode();assert text.count(before)==1
    mutant=text.replace(before,before+'    return\n',1).encode()
    try:
        (c.ROOT/(c.PREFIX+'publish.py')).write_bytes(mutant)
        fault=c.run(command)
        c.write_new('artifact-observed.json.gz',dict(producer=c.read(c.PREFIX+'publish.py'),run=fault))
    finally:
        (c.ROOT/(c.PREFIX+'publish.py')).write_bytes(c.decode(producer['base64']))
        (c.ROOT/(c.PREFIX+'publish.py')).chmod(producer['mode'])
    restored=c.run(command)
    c.write_new('artifact-run.json.gz',dict(healthy=healthy,fault=fault,restored=restored,
        producer_restored=c.read(c.PREFIX+'publish.py')==producer))
    for run in (healthy,fault,restored):assert run['returncode']==0 and not c.decode(run['stderr_base64'])
    good=json.loads(c.decode(healthy['stdout_base64']));bad=json.loads(c.decode(fault['stdout_base64']))
    assert all(item['rejected'] for item in good.values()) and all(not item['rejected'] for item in bad.values())
    assert good==json.loads(c.decode(restored['stdout_base64'])) and c.read(c.PREFIX+'publish.py')==producer
    print('Three actual artifact declarations reject; actual publisher fault admits3; exact restoration verified')

if __name__=='__main__':main()
