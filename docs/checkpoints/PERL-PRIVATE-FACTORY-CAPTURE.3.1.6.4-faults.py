"""Capture five complete source interventions; original fixture and inputs remain untouched."""
import base64
import hashlib
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4-'
MODULE='perl/LinkedSpec/ActionIR/MethodLowering.pm'
OWNER='_parse_array_end_mutation_method_statement'
TARGET=ROOT/(PREFIX+'inverses.json')
digest=lambda raw:hashlib.sha256(raw).hexdigest()
assert not TARGET.exists(),'one-shot faults already retained'
fixture_raw=(ROOT/(PREFIX+'fixture.json')).read_bytes()
fixture=json.loads(fixture_raw)
assert fixture['returncode']==0 and fixture['unchanged']
files={path:(ROOT/path).read_bytes() for path in fixture['inputs']}
assert {path:digest(raw) for path,raw in files.items()}==fixture['inputs']
source=files[MODULE].decode()
begin=source.index('sub '+OWNER+' {')
end=source.index('\nsub ',begin+1)
body=source[begin:end]
binding='return _bind_emission_dependency($cb);'
assert body.count(binding)==1


def tap(raw):
    rows=re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$',raw,re.MULTILINE)
    plans=re.findall(rb'^1\.\.(\d+)$',raw,re.MULTILINE)
    assert len(plans)==1 and [int(n) for failed,n,label in rows]==list(range(1,int(plans[0])+1)),'complete fault TAP'
    return [label.decode() for failed,n,label in rows],[label.decode() for failed,n,label in rows if failed]


names,_=tap(base64.b64decode(fixture['stdout_base64'],validate=True))
assert len(names)==325
faults=[
 ('raw-callback',binding,'return $cb;',
  'array-end authority trim_action_ir_value known0 no child publication donation'),
 ('wrapper-identity',binding,'return _bind_emission_dependency(sub { return $cb->(@_) });',
  'array-end authority parse_method_function_expr known1 actual callback identity'),
 ('copied-arguments',binding,'return _bind_emission_dependency(sub { my @args=@_; return $cb->(@args) });',
  'array-end ordinary callback trim_action_ir_value-effect complete native effects and aliases'),
 ('late-map-selection',binding,'return _bind_emission_dependency(sub { return $deps->{$name}->(@_) });',
  'array-end branch replace-parse_method_function_expr complete native observation'),
 ('missing-diagnostic','::_require_dep)','::_wrong_dep)',
  'array-end branch missing-parse_method_function_expr complete native observation'),
]
environment=dict(os.environ,PERL5LIB='',PERL5OPT='',LINKEDSPEC_EVENT_ORDER_BASELINE='0',LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL',None)


def channels(result):
    return {'returncode':result.returncode,'stdout_base64':base64.b64encode(result.stdout).decode(),
            'stderr_base64':base64.b64encode(result.stderr).decode()}


def census(directory):
    return {p.relative_to(directory).as_posix():digest(p.read_bytes()) for p in sorted(directory.rglob('*')) if p.is_file()}


with tempfile.TemporaryDirectory(prefix='array-end-required-faults-',dir=os.environ['TMPDIR']) as temporary:
    supplied=Path(temporary)
    assert supplied.stat().st_dev==ROOT.stat().st_dev
    for path,raw in files.items():
        destination=supplied/path
        destination.parent.mkdir(parents=True,exist_ok=True)
        destination.write_bytes(raw)
    rows=[]
    for label,old,new,reason in faults:
        assert body.count(old)==1,'unique owner intervention'
        mutant=(source[:begin]+body.replace(old,new)+source[end:]).encode()
        (supplied/MODULE).write_bytes(mutant)
        population=dict(fixture['inputs'],**{MODULE:digest(mutant)})
        assert census(supplied)==population
        syntax_command=['perl','-Iperl','-c',MODULE]
        syntax=subprocess.run(syntax_command,cwd=supplied,env=environment,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=False)
        command=fixture['command']
        result=subprocess.run(command,cwd=supplied,env=environment,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=False)
        row={'label':label,'producer_sha256':digest(Path(__file__).read_bytes()),
             'fixture_sha256':digest(fixture_raw),'source_base64':base64.b64encode(mutant).decode(),
             'source_sha256':digest(mutant),'inputs':population,'syntax_command':syntax_command,
             'syntax':channels(syntax),'command':command,**channels(result),
             'unchanged':census(supplied)==population,'reason':reason}
        target=ROOT/(PREFIX+'inverse-'+label+'.json')
        assert not target.exists(),'one-shot inverse already retained'
        target.write_text(json.dumps(row,indent=2)+'\n')
        actual,failures=tap(result.stdout)
        assert syntax.returncode==0 and b'syntax OK' in syntax.stderr,'syntax-valid source fault'
        assert actual==names and result.returncode!=0 and reason in failures and row['unchanged'],'effective named source fault'
        rows.append({'label':label,'path':target.relative_to(ROOT).as_posix(),'sha256':digest(target.read_bytes()),
                     'failed':len(failures),'reason':reason})
    (supplied/MODULE).write_bytes(files[MODULE])
    assert census(supplied)==fixture['inputs']
assert all((ROOT/path).read_bytes()==raw for path,raw in files.items())
TARGET.write_text(json.dumps({'producer_sha256':digest(Path(__file__).read_bytes()),
 'fixture_sha256':digest(fixture_raw),'inputs':fixture['inputs'],'rows':rows,'unchanged':True,
 'scope':'Five actual syntax-valid full-module interventions restricted to the required array-end parser resolver. Identical325 assertion names/plans and actual named semantic failures; full mutant bytes,203 supplied inputs and distinct complete command channels retained. Original source/fixture/input population untouched.'},indent=2)+'\n')
print('Array-end required source faults PASS:',','.join(row['label']+'='+str(row['failed']) for row in rows))
