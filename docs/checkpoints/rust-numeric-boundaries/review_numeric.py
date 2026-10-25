"""Read-only independent targets over complete actual process observations."""
import json
import math
import re
import struct
import common as c


def exact(actual,expected):
    if type(actual) is not type(expected):return False
    if isinstance(expected,dict):return actual.keys()==expected.keys() and all(exact(actual[key],value) for key,value in expected.items())
    if isinstance(expected,list):return len(actual)==len(expected) and all(exact(a,b) for a,b in zip(actual,expected))
    if isinstance(expected,float):return struct.pack('>d',actual)==struct.pack('>d',expected)
    return actual==expected


def value(actual,target):
    if 'binary64' in target:
        if target['json_kind'] in ('signed_integer','unsigned_integer'):
            return type(actual) is int and str(actual)==target['integer']
        return type(actual) is float and math.isfinite(actual) and struct.pack('>d',actual).hex()==target['binary64']
    if 'exact' in target:return exact(actual,target['exact'])
    if 'array' in target:return isinstance(actual,list) and len(actual)==len(target['array']) and all(value(a,b) for a,b in zip(actual,target['array']))
    if 'object' in target:return isinstance(actual,dict) and actual.keys()==target['object'].keys() and all(value(actual[key],wanted) for key,wanted in target['object'].items())
    raise AssertionError('unknown target')


def outcome(row,target):
    error=row.get('raw_error')
    if 'ok' in target:return error is None and 'ok' in row and value(row['ok'],target['ok'])
    if not isinstance(error,str):return False
    parsed=json.loads(error)
    return all(key in parsed and exact(parsed[key],wanted) for key,wanted in target['error'].items())


def stdout(run):return c.decode(run['stdout_base64']).decode()


def rows(run,marker):
    return [json.loads(line.split(marker,1)[1]) for line in stdout(run).splitlines() if line.startswith(marker)]


def source_fixture(packet,path):
    return json.loads(c.decode(packet['context']['sources'][path]['base64']))


def core(stem,green):
    supplied=c.load(stem+'-inputs.json.gz')
    fixture=source_fixture(supplied,'tests/numeric-conversion/cases.json')
    saved=c.load(stem+'-run.json.gz');run=saved['run']
    assert saved['inputs_unchanged'] and saved['executable_unchanged']
    observed=rows(run,'NUMERIC_CORE\t');expected={row['id']:row for row in fixture['cases']}
    assert len(observed)==len(expected)==36 and {row['id'] for row in observed}==expected.keys()
    failures=[]
    for row in observed:
        target=expected[row['id']]
        projection=json.loads(row['projected_raw'])
        assert exact(projection,row['projected'])
        kind=target['json_kind']
        if kind=='null':correct=projection is None
        else:correct=value(projection,{'binary64':target['bits'],'json_kind':kind,'integer':target['integer']})
        if not correct:failures.append((row['id'],'json'))
        text=target['expected_text']
        if text is not None:correct=row['text']==row['display']==text and row['length']==len(text)
        else:
            correct=struct.pack('>d',float(row['text'])).hex()==target['bits'] \
                and row['display']==row['text'] and row['length']==len(row['text'])
        if not correct:failures.append((row['id'],'text/display/length'))
        if target['finite']:
            if row['recovered_bits']!=target['bits']:failures.append((row['id'],'serde'))
        else:assert row['raw_serde']=='null' and row['recovered_bits'] is None
    assert run['returncode']==(0 if green else 101)
    assert (not failures)==green
    return dict(rows=len(observed),mismatches=len(failures),fields=failures)


def runtime(stem,green,functions=True):
    supplied=c.load(stem+'-inputs.json.gz')
    fixture=source_fixture(supplied,'tests/numeric-conversion/programs.json')
    cases=list(fixture['cases'])
    if functions:cases+=source_fixture(supplied,'tests/numeric-conversion/functions.json')['cases']
    saved=c.load(stem+'-run.json.gz');run=saved['run'];observed=rows(run,'NUMERIC_RUNTIME\t')
    width=next(int(row['id'].split('/')[1]) for row in observed if row['id'].startswith('write/') and row['id'].split('/')[1].isdigit())
    cases={row['id']:row for row in cases if row['pointer_width'] in (None,width)}
    wanted={(name,route) for name in cases for route in ['native','spec_json','compiled_json','generated_plan']}
    assert len(observed)==len(wanted) and {(row['id'],row['route']) for row in observed}==wanted
    failures=[(row['id'],row['route']) for row in observed if not outcome(row,cases[row['id']]['expected'])]
    metadata=rows(run,'NUMERIC_METADATA\t');assert len(metadata)==23
    meta_fail=[]
    for row in metadata:
        accepted=row['case'] in ('small-integer','small-float','below','maximum-integer')
        if row['case']=='below' and width==32:accepted=False
        if row['case']=='maximum-integer' and width==32:accepted=False
        if row['accepted']!=accepted:meta_fail.append((row['field'],row['case']))
    assert saved['inputs_unchanged'] and saved['executable_unchanged']
    assert run['returncode']==(0 if green else 101)
    assert (not failures and not meta_fail)==green
    return dict(rows=len(observed),metadata=len(metadata),mismatches=len(failures),metadata_mismatches=len(meta_fail))


def emitted(stem,green,functions=False):
    supplied=c.load(stem+'-inputs.json.gz')
    path='tests/numeric-conversion/'+('functions.json' if functions else 'programs.json')
    fixture=source_fixture(supplied,path)
    width=c.load('function-emission-result.json.gz' if functions else 'emission-result.json.gz')['pointer_width']
    cases={row['id']:row for row in fixture['cases'] if row['pointer_width'] in (None,width)}
    saved=c.load(stem+'-run.json.gz');run=saved['run'];observed=rows(run,'NUMERIC_EMITTED\t')
    assert run['returncode']==0 and saved['inputs_unchanged'] and saved['executable_unchanged']
    assert len(observed)==len(cases) and {row['id'] for row in observed}==cases.keys()
    failures=[row['id'] for row in observed if not outcome(row,cases[row['id']]['expected'])]
    assert (not failures)==green
    return dict(rows=len(observed),mismatches=len(failures))


def check():
    return dict(core=core('core-after-complete',True),
        runtime=runtime('runtime-functions-after',True),
        emitted=emitted('emitted-after',True),
        emitted_functions=emitted('emitted-functions-after',True,True))


if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
