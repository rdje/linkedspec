"""Execute actual authority branches, effective inverse mutants and pressure oracles."""
from pathlib import Path
import base64
import copy
import hashlib
import json
import os
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3-'
ADR = 'docs/decisions/0128-replacement-note-history-capacity.md'
INITIAL = 'docs/decisions/0063-bounded-readme-landing-page.md'
INDEX = 'docs/decisions/INDEX.md'
PERL = 'scripts/check_readme_routing_pressure.pl'
BASH = 'scripts/check_readme_stability.sh'

def sha(raw): return hashlib.sha256(raw).hexdigest()
def envelope(raw): return {'base64':base64.b64encode(raw).decode(),'bytes':len(raw),'sha256':sha(raw)}
def decode(item):
    raw = base64.b64decode(item['base64'],validate=True)
    assert envelope(raw) == item
    return raw
def read(path): return (ROOT/path).read_bytes()
def function(source,name,language):
    pattern = r'^sub '+name+r' \{.*?(?=^sub |\Z)' if language == 'perl' else r'^'+name+r'\(\) \{\n.*?^\}\n'
    match = re.search(pattern,source,re.M|re.S)
    assert match, 'complete source function '+name
    return match.group()

reports = {epoch:json.loads(read(PREFIX+epoch+'-components.json')) for epoch in ('before','after')}
drivers = {epoch:{language:decode(item).decode() for language,item in report['drivers'].items()} for epoch,report in reports.items()}
paths = [PERL,BASH,PREFIX+'component-probe.py',PREFIX+'before-components.json',PREFIX+'after-components.json',str(Path(__file__).relative_to(ROOT))]
guard = {path:sha(read(path)) for path in paths}

def run(driver,fixture):
    perl = fixture['branch'] in ('routed_limits','routed_contract','initial_registry')
    if perl:
        args = ['perl','-e',driver]
        process = subprocess.run(args,cwd=ROOT,input=json.dumps(fixture).encode(),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        answer = json.loads(process.stdout)['authorized'] if process.returncode == 0 else None
    else:
        args = ['bash','-c',driver]
        env = dict(os.environ)
        env.update(ACCEPTED_STATE_BODY=fixture['files'][ADR],ACCEPTED_STATE_INDEX=fixture['files'][INDEX],ACCEPTED_STATE_BRANCH=fixture['branch'])
        process = subprocess.run(args,cwd=ROOT,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        assert process.stdout in (b'0\n',b'1\n') or process.returncode != 0
        answer = process.stdout == b'1\n' if process.returncode == 0 else None
    row = {'branch':fixture['branch'],'fixture':fixture,'driver':envelope(driver.encode()),
           'exit_code':process.returncode,'stdout':envelope(process.stdout),'stderr':envelope(process.stderr),'authorized':answer}
    assert process.returncode == 0 and process.stderr == b'', 'actual complete semantic command'
    return row

recurrence = []
supplemental = []
for epoch,report in reports.items():
    for observed in report['observations']:
        language = 'perl' if observed['branch'] in ('routed_limits','routed_contract','initial_registry') else 'bash'
        row = run(drivers[epoch][language],observed['fixture'])
        assert row['authorized'] == observed['authorized'] and row['stdout'] == observed['stdout'] and row['stderr'] == observed['stderr'] and row['exit_code'] == observed['exit_code'], 'exact retained component recurrence'
        recurrence.append({'epoch':epoch,'status':observed['status'],**row})
    accepted = [row for row in report['observations'] if row['status'] == 'accepted_bare']
    for observed in accepted:
        for status in ('duplicate_accepted','duplicate_reverse','malformed_token'):
            fixture = copy.deepcopy(observed['fixture'])
            body = fixture['files'][ADR]
            if status == 'duplicate_accepted': body += '\n- Status: accepted\n'
            elif status == 'duplicate_reverse': body = '- Status: proposed\n'+body
            else: body = body.replace('- Status: accepted','- Status: acceptedish',1)
            fixture['files'][ADR] = fixture['files'][INITIAL] = body
            language = 'perl' if observed['branch'] in ('routed_limits','routed_contract','initial_registry') else 'bash'
            row = run(drivers[epoch][language],fixture)
            assert row['authorized'] == (epoch == 'before'), 'independent malformed/duplicate status oracle'
            supplemental.append({'epoch':epoch,'status':status,**row})

mutants = []
branch_functions = {'routed_limits':('perl','adr_authorizes_limit_change','adr_is_accepted($body)\n            && '),
                    'routed_contract':('perl','adr_authorizes_contract_change','adr_is_accepted($body)\n            && '),
                    'initial_registry':('perl','validate_registry_governance','!adr_is_accepted($adr) || '),
                    'new_readme_caps':('bash','new_adr_authorizes_caps','adr_has_accepted_status "$body" &&\n       '),
                    'initial_readme_caps':('bash','initial_adr_authorizes_caps','adr_has_accepted_status "$body" &&\n    ')}
for branch,(language,name,predicate) in branch_functions.items():
    driver = drivers['after'][language]
    block = function(driver,name,language)
    assert block.count(predicate) == 1, 'exact inverse admission predicate '+branch
    mutant = driver.replace(block,block.replace(predicate,'',1),1)
    observed = next(row for row in reports['after']['observations'] if row['branch'] == branch and row['status'] == 'proposed')
    result = run(mutant,observed['fixture'])
    assert result['authorized'] is True, 'branch inverse mutation escapes proposed-status oracle'
    mutants.append({'name':'omit_'+branch+'_guard','observed_policy':'RED','competing_hypothesis':'Existing index/markers suffice without accepted status',**result})

# Distinguish exact token and field cardinality from an unconditionally false helper.
for language,name,change in [
    ('perl','adr_is_accepted',('return @statuses == 1','return @statuses >= 1')),
    ('bash','adr_has_accepted_status',('"$count" -eq 1','"$count" -ge 1')),
    ('perl','adr_is_accepted',('accepted(?:[ \\t;]|\\z)','accepted')),
    ('bash','adr_has_accepted_status',('accepted([[:blank:];]|$)','accepted')),
]:
    driver = drivers['after'][language]
    block = function(driver,name,language)
    old,new = change
    assert block.count(old) == 1, 'exact semantic helper mutation '+name+'/'+old
    mutant = driver.replace(block,block.replace(old,new,1),1)
    status = 'duplicate_accepted' if 'count' in old or '@statuses' in old else 'malformed_token'
    fixture_row = next(row for row in supplemental if row['epoch'] == 'after' and row['status'] == status and (row['branch'] == 'routed_limits' if language == 'perl' else row['branch'] == 'new_readme_caps'))
    result = run(mutant,fixture_row['fixture'])
    assert result['authorized'] is True, 'semantic mutation distinguished by independent field/token oracle'
    mutants.append({'name':language+'_'+status+'_bypass','observed_policy':'RED',**result})

authority_controls = []
for observed in reports['after']['observations']:
    if observed['status'] != 'accepted_original': continue
    branch = observed['branch']
    language = 'perl' if branch in ('routed_limits','routed_contract','initial_registry') else 'bash'
    for control in ('missing_index','missing_exact_marker'):
        fixture = copy.deepcopy(observed['fixture'])
        if control == 'missing_index': fixture['files'][INDEX] = ''
        else:
            body = fixture['files'][ADR]
            if branch == 'initial_registry': body = re.sub('routing-pressure|routed-destination','navigation',body,flags=re.I)
            else:
                marker = {'routed_limits':'Previous routed limits','routed_contract':'Previous routed contract',
                          'new_readme_caps':'Previous README line cap','initial_readme_caps':'Previous README line cap'}[branch]
                body = re.sub(r'^- '+marker+r':.*\n','',body,flags=re.M)
            fixture['files'][ADR] = fixture['files'][INITIAL] = body
        result = run(drivers['after'][language],fixture)
        assert result['authorized'] is False, 'existing independent authority predicate retained'
        authority_controls.append({'name':branch+'/'+control,'observed_rejection':True,**result})

pressure_source = function(read(PERL).decode(),'exceeds_limits','perl')
pressure_driver = ('use strict; use warnings; use JSON::PP (); local $/; my $f=JSON::PP->new->decode(<STDIN>);\n'+pressure_source+
                   'my @v=exceeds_limits($f->{metrics},$f->{limits}); print JSON::PP->new->canonical->encode(\\@v),qq(\\n);\n')
pressure = []
metrics = {'files':10,'lines':10,'bytes':10,'members':['fixture'],'per_file':{'fixture':{'lines':10,'bytes':10}}}
for key in ('max_lines','max_bytes','max_files','max_total_lines','max_total_bytes','max_lines_per_file','max_bytes_per_file'):
    for limit in (9,10,11):
        fixture = {'metrics':metrics,'limits':{key:limit}}
        process = subprocess.run(['perl','-e',pressure_driver],cwd=ROOT,input=json.dumps(fixture).encode(),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        assert process.returncode == 0 and process.stderr == b''
        violations = json.loads(process.stdout)
        assert bool(violations) == (limit == 9), 'independent exact/under/overflow pressure oracle'
        pressure.append({'key':key,'limit':limit,'fixture':fixture,'exit_code':process.returncode,'stdout':envelope(process.stdout),'stderr':envelope(process.stderr),'violations':violations})

assert guard == {path:sha(read(path)) for path in paths}, 'unchanged actual source/observation inputs'
result = {'complete':True,'producer_sha256':sha(Path(__file__).read_bytes()),'input_hashes_before':guard,'input_hashes_after':guard,
          'recurrence':recurrence,'supplemental_status_oracles':supplemental,'effective_source_inverse_mutants':mutants,
          'independent_authority_denials':authority_controls,'pressure_driver':envelope(pressure_driver.encode()),'pressure_boundaries':pressure,
          'scope':'Actual complete source-bound component drivers recur all retained before/after channels. Supplemental duplicate-accepted, reversed-conflicting and malformed-token fixtures distinguish field uniqueness and exact state token; before is replay of retained original source, not a new live before snapshot. Nine effective inverse source mutants change only in-memory actual function blocks and escape independent proposed/duplicate/token policy oracles. Ten independent index/marker denials and21 actual pressure exact/under/overflow boundaries retain existing defenses. Fixture getters are explicit stubs; full actual Git/resulting-tree routes are separately captured. No original production file or historical evidence mutation, global doctrine bypass, cap increase or runtime repair.'}
(ROOT/(PREFIX+'semantic-controls.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,'recurrence':len(recurrence),'supplemental':len(supplemental),'source_mutants':len(mutants),'authority_denials':len(authority_controls),'pressure_boundaries':len(pressure)}))
