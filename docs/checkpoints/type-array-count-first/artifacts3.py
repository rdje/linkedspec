"""Falsify the actual publication validator and retain every fault/restoration epoch."""
import copy
import json
import common as c
import context
import publish


def main():
    path = c.PREFIX+'publish.py'
    original = c.read(path)
    actual = {name:c.identity(name) for name in publish.input_paths()}
    cases = {name:copy.deepcopy(actual) for name in ('missing','bytes','mode')}
    target = c.PREFIX+'phase0-candidate-result.json'
    cases['missing'].pop(target)
    assert actual[target]['sha256'] != '0'*64
    cases['bytes'][target]['sha256'] = '0'*64
    cases['mode'][target]['mode'] ^= 0o100
    c.write_new('artifact3-inputs.json.gz',dict(actual=actual,cases=cases,
        producer=original,context=context.snapshot()))
    command = ['bash','tools/run_python_project_data.sh',path,'--controls']
    healthy = c.run(command)
    c.write_new('artifact3-healthy.json.gz',dict(run=healthy))
    text = c.decode(original['base64'])
    marker = b'def validate_inputs(declared,actual):\n'
    assert text.count(marker) == 1
    try:
        c.source(path).write_bytes(text.replace(marker,marker+b'    return\n',1))
        c.source(path).chmod(original['mode'])
        c.write_new('artifact3-fault-inputs.json.gz',context.snapshot())
        fault = c.run(command)
        c.write_new('artifact3-observed.json.gz',dict(run=fault,producer=c.read(path)))
    finally:
        c.source(path).write_bytes(text)
        c.source(path).chmod(original['mode'])
    c.write_new('artifact3-restored-inputs.json.gz',context.snapshot())
    restored = c.run(command)
    exact = c.read(path) == original
    c.write_new('artifact3-run.json.gz',dict(healthy=healthy,fault=fault,restored=restored,producer_restored=exact))
    for run in (healthy,fault,restored):
        assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    good = json.loads(c.decode(healthy['stdout_base64']))
    bad = json.loads(c.decode(fault['stdout_base64']))
    assert good == json.loads(c.decode(restored['stdout_base64'])) == publish.controls()
    assert exact and len(good) == 3
    assert all(item['rejected'] for item in good.values())
    assert all(not item['rejected'] for item in bad.values())
    print('Actual artifact validator: three denials / three fault admissions / exact restoration')


if __name__ == '__main__':
    main()
