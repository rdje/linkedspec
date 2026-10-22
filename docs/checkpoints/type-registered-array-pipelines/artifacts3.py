"""Falsify the actual publisher's population, byte and full-mode reader."""
import copy
import json
import common as c

def main():
    path=c.PREFIX+'publish3.py'
    original=c.read(path)
    raw=c.decode(original['base64'])
    marker=b'def validate_inputs(declared, actual):\n'
    assert raw.count(marker)==1
    actual={c.PREFIX+'cases.json':c.identity(c.PREFIX+'cases.json')}
    cases={name:copy.deepcopy(actual) for name in ('missing','bytes','mode')}
    cases['missing'].clear()
    target=next(iter(actual))
    cases['bytes'][target]['sha256']='0'*64
    cases['mode'][target]['mode']^=0o111
    reasons=dict(missing='input population',bytes='input bytes: '+target,mode='input mode: '+target)
    c.write_new('artifact3-inputs.json.gz',dict(actual=actual,cases=cases,reasons=reasons,
        producer=c.read(c.PREFIX+'artifacts3.py'),publisher=original))
    command=['bash','tools/run_python_project_data.sh',path,'--controls']
    healthy=c.run(command)
    try:
        c.source(path).write_bytes(raw.replace(marker,marker+b'    return\n',1))
        mutant=c.read(path)
        fault=c.run(command)
    finally:
        c.source(path).write_bytes(raw)
    restored=c.run(command)
    exact=c.read(path)==original
    c.write_new('artifact3-run.json.gz',dict(original=original,mutant=mutant,healthy=healthy,fault=fault,
        restored=restored,sources_restored=exact))
    for run in (healthy,restored):
        assert run['returncode']==0 and not c.decode(run['stderr_base64'])
        result=json.loads(c.decode(run['stdout_base64']))
        assert set(result)==set(cases)
        assert all(row['rejected'] and row['reason']==reasons[name] for name,row in result.items())
    assert fault['returncode']==0 and not c.decode(fault['stderr_base64'])
    assert all(not row['rejected'] for row in json.loads(c.decode(fault['stdout_base64'])).values())
    assert exact
    print('Three actual artifact denials / bypass admission / exact restoration PASS')

if __name__=='__main__':main()
