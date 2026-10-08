"""Observe actual admission functions with explicit status-distinguishing fixtures."""
from pathlib import Path
import base64
import hashlib
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3-'
CAPACITY = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2-'
ADR = 'docs/decisions/0128-replacement-note-history-capacity.md'
INITIAL = 'docs/decisions/0063-bounded-readme-landing-page.md'
INDEX = 'docs/decisions/INDEX.md'
PERL = 'scripts/check_readme_routing_pressure.pl'
BASH = 'scripts/check_readme_stability.sh'
epoch = sys.argv[1] if len(sys.argv) == 2 else None
assert epoch in ('before','after'), 'usage: component-probe.py before|after'

def sha(raw): return hashlib.sha256(raw).hexdigest()
def channel(raw): return {'base64':base64.b64encode(raw).decode(),'bytes':len(raw),'sha256':sha(raw)}
def read(path): return (ROOT/path).read_bytes()
def perl_function(source,name,optional=False):
    match = re.search(r'^sub '+re.escape(name)+r' \{.*?(?=^sub |\Z)',source,re.M|re.S)
    assert match or optional, 'actual Perl function '+name
    return match.group() if match else ''
def bash_function(source,name,optional=False):
    match = re.search(r'^'+re.escape(name)+r'\(\) \{\n.*?^\}\n',source,re.M|re.S)
    assert match or optional, 'actual Bash function '+name
    return match.group() if match else ''

paths = [PERL,BASH,ADR,INITIAL,INDEX,CAPACITY+'capacity-plan.json',str(Path(__file__).relative_to(ROOT))]
before = {path:sha(read(path)) for path in paths}
perl_source,bash_source = read(PERL).decode(),read(BASH).decode()
plan = json.loads(read(CAPACITY+'capacity-plan.json'))
original_body = read(ADR).decode()
initial_body = read(INITIAL).decode()
index = read(INDEX).decode()
assert len(re.findall(r'^- Status:.*$',original_body,re.M)) == 1
assert len(re.findall(r'^- Status:.*$',initial_body,re.M)) == 1

functions = ''.join(perl_function(perl_source,name) for name in (
    'canonical_object','numeric_increase','limit_change_permitted','debt_retirement_permitted',
    'adr_authorizes_limit_change','adr_authorizes_contract_change','validate_registry_governance'))
functions = perl_function(perl_source,'adr_is_accepted',True)+functions
perl_driver = ("use v5.20; use strict; use warnings; use JSON::PP ();\n"
               "my $JSON=JSON::PP->new->canonical(1); my $INDEX_MODE=1;\n"
               "my $REGISTRY_PATH='doctrine/readme_stability/routes.jsonl';\n"
               "local $/; my $fixture=$JSON->decode(<STDIN>);\n"
               "sub staged_new_adrs { return '"+ADR+"' }\n"
               "sub snapshot_content { return $fixture->{files}{$_[0]} }\n"
               "sub head_content { return undef }\n"+functions+
               "my $answer;\n"
               "if ($fixture->{branch} eq 'routed_limits') { $answer=adr_authorizes_limit_change('engineering_notes',$fixture->{old},$fixture->{new}); }\n"
               "elsif ($fixture->{branch} eq 'routed_contract') { $answer=adr_authorizes_contract_change('engineering_notes',$fixture->{old},$fixture->{new}); }\n"
               "else { my @errors=validate_registry_governance([]); $answer=!@errors; }\n"
               "print $JSON->encode({authorized=>$answer ? JSON::PP::true : JSON::PP::false}),qq(\\n);\n")
shell_functions = (bash_function(bash_source,'adr_has_accepted_status',True)+
                   bash_function(bash_source,'new_adr_authorizes_caps')+
                   bash_function(bash_source,'initial_adr_authorizes_caps'))
bash_driver = ("set -euo pipefail\n"
               "stream_file() { if [[ \"$1\" == '"+INITIAL+"' ]]; then printf '%s\\n' \"$ACCEPTED_STATE_BODY\"; else printf '%s\\n' \"$ACCEPTED_STATE_INDEX\"; fi; }\n"
               "git() { if [[ \"$1\" == 'diff' ]]; then printf '%s\\n' '"+ADR+"'; elif [[ \"$2\" == ':"+INDEX+"' ]]; then printf '%s\\n' \"$ACCEPTED_STATE_INDEX\"; else printf '%s\\n' \"$ACCEPTED_STATE_BODY\"; fi; }\n"+
               shell_functions+
               "if [[ \"$ACCEPTED_STATE_BRANCH\" == 'new_readme_caps' ]]; then\n"
               "  if new_adr_authorizes_caps 128 129 6144 6145; then printf '1\\n'; else printf '0\\n'; fi\n"
               "else\n"
               "  if initial_adr_authorizes_caps 128 6144; then printf '1\\n'; else printf '0\\n'; fi\n"
               "fi\n")
caps_markers = ('\n- Previous README line cap: `128`\n- New README line cap: `129`\n'
                '- Previous README byte cap: `6144`\n- New README byte cap: `6145`\n')

def status_variant(body,status):
    if status == 'accepted_original': return body
    if status == 'accepted_bare': return re.sub(r'^- Status:.*$', '- Status: accepted',body,count=1,flags=re.M)
    if status == 'proposed': return re.sub(r'^- Status:.*$', '- Status: proposed; not accepted',body,count=1,flags=re.M)
    if status == 'missing': return re.sub(r'^- Status:.*\n', '',body,count=1,flags=re.M)
    assert status == 'duplicate'
    return body+'\n- Status: proposed; ambiguous duplicate\n'

observations = []
for branch in ('routed_limits','routed_contract','initial_registry','new_readme_caps','initial_readme_caps'):
    for status in ('accepted_original','accepted_bare','proposed','missing','duplicate'):
        base = initial_body if branch.startswith('initial_') else original_body
        body = status_variant(base,status)
        if branch == 'initial_registry':
            # The original required phrase occurs in the Status line itself.
            # Keep that independent predicate true even when Status disappears.
            body += '\nRouting-pressure fixture marker independent of the Status field.\n'
        if branch == 'new_readme_caps': body += caps_markers
        fixture = {'branch':branch,'status':status,'files':{ADR:body,INITIAL:body,INDEX:index}}
        if branch in ('routed_limits','routed_contract'):
            suffix = 'limits' if branch == 'routed_limits' else 'contract'
            fixture.update(old=plan['old_'+suffix],new=plan['new_'+suffix])
        if branch in ('routed_limits','routed_contract','initial_registry'):
            args = ['perl','-e',perl_driver]
            process = subprocess.run(args,cwd=ROOT,input=json.dumps(fixture).encode(),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            authorized = json.loads(process.stdout)['authorized'] if process.returncode == 0 else None
        else:
            import os
            env = dict(os.environ)
            env.update(ACCEPTED_STATE_BODY=body,ACCEPTED_STATE_INDEX=index,ACCEPTED_STATE_BRANCH=branch)
            args = ['bash','-c',bash_driver]
            process = subprocess.run(args,cwd=ROOT,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            assert process.stdout in (b'0\n',b'1\n') or process.returncode != 0
            authorized = process.stdout == b'1\n' if process.returncode == 0 else None
        observations.append({'branch':branch,'status':status,'fixture':fixture,
                             'driver_sha256':sha((perl_driver if args[0]=='perl' else bash_driver).encode()),
                             'exit_code':process.returncode,'stdout':channel(process.stdout),'stderr':channel(process.stderr),
                             'authorized':authorized,'expected_policy_authorized':status.startswith('accepted_'),
                             'policy_result':'GREEN' if authorized == status.startswith('accepted_') else 'RED'})
        assert process.returncode == 0 and process.stderr == b'', 'actual complete component command '+branch+'/'+status
        assert authorized is True if epoch == 'before' else authorized == status.startswith('accepted_'), 'expected reached epoch behavior '+branch+'/'+status

after = {path:sha(read(path)) for path in paths}
assert before == after, 'all actual component inputs remain unchanged during capture'
result = {'complete':True,'epoch':epoch,'producer_sha256':sha(Path(__file__).read_bytes()),
          'input_hashes_before':before,'input_hashes_after':after,
          'drivers':{'perl':channel(perl_driver.encode()),'bash':channel(bash_driver.encode())},
          'observations':observations,
          'scope':'Actual unchanged/exact changed production admission functions with explicit in-memory carriers. Bash Git/stream getters and Perl Git/snapshot getters are fixture stubs; this is component proof, not a full resulting-tree or global doctrine bypass. Initial registry fixtures keep the existing routing-pressure phrase independently true when Status is removed, because the original phrase is in its Status line. Accepted original/bare, proposed/missing/duplicate variants preserve all required index/object/cap markers. No original decision or policy file is modified; full actual Git/resulting-tree proof remains required.'}
(ROOT/(PREFIX+epoch+'-components.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,'epoch':epoch,'branches':5,'observations':25,
                  'policy_red':sum(row['policy_result']=='RED' for row in observations)}))
