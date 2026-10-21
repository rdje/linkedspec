"""Exercise three metadata denials and an actual discarded-validator source fault."""
import copy
import importlib.util
import common as c
import publish


def outcomes(module,cases,actual):
    result={}
    for name,case in cases.items():
        try:module.validate_inputs(case['declared'],actual)
        except AssertionError as error:result[name]=dict(rejected=True,reason=str(error))
        else:result[name]=dict(rejected=False,reason='')
    return result


def load_module(name):
    spec=importlib.util.spec_from_file_location(name,c.ROOT/(c.PREFIX+'publish.py'))
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    return module


def main():
    actual=publish.current_inputs()
    cases={}
    for name,path in [('missing-instrument',c.PREFIX+'probe.pl'),
                      ('changed-fixture',c.PREFIX+'cases2.json'),
                      ('changed-mode',c.PREFIX+'malformed.pl')]:
        declared=copy.deepcopy(actual)
        if name=='missing-instrument':del declared[path];reason='publication input population mismatch'
        elif name=='changed-fixture':
            declared[path]['sha256']='0'*64;reason='publication input byte mismatch: '+path
        else:
            declared[path]['mode']^=0o100;reason='publication input mode mismatch: '+path
        cases[name]=dict(path=path,declared=declared,reason=reason)
    producer=c.read(c.PREFIX+'publish.py')
    source=c.decode(producer['base64']).decode()
    start=source.index('def validate_inputs(');end=source.index('\n\ndef record(',start)
    mutant=source[:start]+'def validate_inputs(declared,actual):\n    return None\n'+source[end:]
    c.write_new('artifact-inputs.json.gz',dict(actual=actual,cases=cases,producer=producer,
        mutant_base64=c.encode(mutant.encode()),instrument=c.read(c.PREFIX+'artifact_controls.py'),
        scope='Synthetic declarations compare with one actual pre-control input dataset. Own new '
              'control outputs and concurrent retained test outputs are not in that dataset; every '
              'initial byte/mode identity is checked after restoration. Final publication closes them all.'))
    healthy=outcomes(publish,cases,actual)
    try:
        (c.ROOT/(c.PREFIX+'publish.py')).write_text(mutant)
        fault=outcomes(load_module('aggregate_manifest_fault'),cases,actual)
        c.write_new('artifact-fault-observed.json.gz',dict(producer=c.read(c.PREFIX+'publish.py'),outcomes=fault))
    finally:
        (c.ROOT/(c.PREFIX+'publish.py')).write_bytes(c.decode(producer['base64']))
        (c.ROOT/(c.PREFIX+'publish.py')).chmod(producer['mode'])
    restored=outcomes(load_module('aggregate_manifest_restored'),cases,actual)
    stable=c.unchanged(actual)
    c.write_new('artifact-run.json.gz',dict(healthy=healthy,fault=fault,restored=restored,
        initial_inputs_unchanged=stable,producer_restored=c.read(c.PREFIX+'publish.py')==producer))
    assert stable and restored==healthy
    for name,case in cases.items():
        assert healthy[name]==dict(rejected=True,reason=case['reason'])
        assert fault[name]==dict(rejected=False,reason='')
    print('Artifact controls:3 denials; actual validator fault admits3; restored3 with original inputs unchanged')


if __name__=='__main__':main()
