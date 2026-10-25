"""Read-only dependent suite and fresh emitted-readiness execution review."""
import json
import re
import common as c


def count(run):
    lines=c.decode(run['stdout_base64']).decode()
    found=re.findall(r'^test result: ok\. (\d+) passed; 0 failed; (\d+) ignored;',lines,re.M)
    assert len(found)==1 and found[0][1]=='0'
    return int(found[0][0])


def check():
    result=c.load('compatibility2-result.json.gz')
    assert result['inputs_unchanged'] and len(result['runs'])==8
    counts={}
    for target in result['runs']:
        saved=c.load('compatibility2-'+target+'-run.json.gz')
        assert saved['run']['returncode']==0 and saved['executable_unchanged']
        counts[target]=count(saved['run'])
    assert len(result['children'])==1
    child=result['children'][0]
    for key in ('sha256','bytes','mode'):
        assert child['artifact'][key]==child['before_execution_report'][key]
    readiness=c.load('readiness2-run.json.gz')
    assert readiness['run']['returncode']==0 and readiness['inputs_unchanged'] \
        and readiness['executable_unchanged']
    assert count(readiness['run'])==6 and len(readiness['child_records'])==3
    children=[]
    for path in readiness['child_records']:
        assert path.startswith(c.PREFIX) and path.endswith('-run.json.gz')
        stem=path[len(c.PREFIX):-len('-run.json.gz')]
        before=c.load(stem+'-inputs.json.gz')
        supplied=c.load(stem+'-execution-inputs.json.gz')
        run=c.load(stem+'-run.json.gz')
        assert run['run']['returncode']==0 and run['executable_unchanged']
        for name,packet in before['files'].items():
            if name!='Cargo.lock':assert supplied['files'][name]==packet
        assert 'Cargo.lock' in supplied['files']
        children.append(count(run['run']))
    assert sorted(children)==[3,4,4]
    return dict(dependent_suites=counts,dependent_tests=sum(counts.values()),
        readiness_parent=6,readiness_children=sorted(children))


if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
