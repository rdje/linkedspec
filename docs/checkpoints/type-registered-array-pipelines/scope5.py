"""Falsify the actual input enumerator against an independent measured-input floor."""
import json
import common as c

def main():
    path=c.PREFIX+'publish5.py'
    original=c.read(path)
    raw=c.decode(original['base64'])
    enumeration=b'    return sorted(set(regular_paths()) - {MANIFEST,PUBLICATION,CLAIM})\n'
    scope=b'def validate_scope(actual):\n'
    assert raw.count(enumeration)==raw.count(scope)==1
    omitted=raw.replace(enumeration,b'    return sorted(set(regular_paths()) - {MANIFEST,PUBLICATION,CLAIM,TARGET})\n',1)
    bypass=omitted.replace(scope,scope+b'    return\n',1)
    command=['bash','tools/run_python_project_data.sh',path,'--scope-control']
    healthy=c.run(command)
    c.write_new('scope5-healthy.json.gz',dict(run=healthy,publisher=original,producer=c.read(c.PREFIX+'scope5.py')))
    assert healthy['returncode']==0 and not c.decode(healthy['stderr_base64'])
    assert json.loads(c.decode(healthy['stdout_base64']))==dict(rejected=False,reason='')
    runs={}
    sources={}
    try:
        for name,source in [('omitted',omitted),('bypass',bypass),('validator_restored',omitted)]:
            c.source(path).write_bytes(source)
            sources[name]=c.read(path)
            runs[name]=c.run(command)
    finally:
        c.source(path).write_bytes(raw)
    restored=c.run(command)
    exact=c.read(path)==original
    c.write_new('scope5-run.json.gz',dict(original=original,enumeration=c.encode(enumeration),scope=c.encode(scope),
        sources=sources,healthy=healthy,runs=runs,restored=restored,sources_restored=exact,
        producer=c.read(c.PREFIX+'scope5.py')))
    for run in [healthy,restored]+list(runs.values()):
        assert run['returncode']==0 and not c.decode(run['stderr_base64'])
    assert json.loads(c.decode(healthy['stdout_base64']))==dict(rejected=False,reason='')
    assert json.loads(c.decode(restored['stdout_base64']))==dict(rejected=False,reason='')
    import publish5
    expected=dict(rejected=True,reason='measurement input: '+publish5.TARGET)
    for name in ('omitted','validator_restored'):
        assert json.loads(c.decode(runs[name]['stdout_base64']))==expected
    assert json.loads(c.decode(runs['bypass']['stdout_base64']))==dict(rejected=False,reason='')
    assert exact
    print('Actual fixture enumeration omission RED / scope bypass admission / validator RED / exact restoration GREEN')

if __name__=='__main__':main()
