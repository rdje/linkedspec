"""Register the exact supplied fixture population and its narrow historical inverse."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BASE='858eba97c89239d187765c4af9ad18057d28a1b0'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
RUNNER='tools/run_ci_local.sh'
AUDITOR='tests/language-readiness/verify_objectives.py'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
target=ROOT/(PREFIX+'registration.json');assert not target.exists()
inventory=json.loads((ROOT/(PREFIX+'inventory.json')).read_bytes())
assert inventory['result']=='PASS' and inventory['base']==BASE
suites=inventory['suites'];helpers=inventory['helpers']
assert len(suites)==91 and len(helpers)==46 and len(set(suites+helpers))==137
old_runner=(ROOT/(PREFIX+'runner-original.sh')).read_bytes()
old_auditor=(ROOT/(PREFIX+'auditor-original.py')).read_bytes()
assert (ROOT/RUNNER).read_bytes()==old_runner and (ROOT/AUDITOR).read_bytes()==old_auditor
anchor=b'PERL5LIB= prove -Iperl t/actionir_raw_dependency_metadata.t t/actionir_raw_dependency_provenance.t t/actionir_nested_block_source_spans.t t/actionir_raw_dependency_compatibility.t\n'
assert old_runner.count(anchor)==1
block=('\n# PERL-PRIVATE-FACTORY-CAPTURE.7: exact supplied fixture admission.\n'
    'private_factory_suites=(\n'+''.join(' '+p+'\n' for p in suites)+')\n'
    'private_factory_helpers=(\n'+''.join(' '+p+'\n' for p in helpers)+')\n'
    'log "checking complete private factory fixture inputs and syntax"\n'
    'for private_factory_input in "${private_factory_suites[@]}" "${private_factory_helpers[@]}"; do\n'
    ' require_tracked_file "$private_factory_input"\n'
    ' perl -c -Iperl "$private_factory_input"\n'
    'done\n'
    'log "running complete supplied private factory regression population"\n'
    'LINKEDSPEC_EVENT_ORDER_BASELINE=0 LINKEDSPEC_MEMBERSHIP_BASELINE=0 PERL5LIB= PERL5OPT= prove -Iperl "${private_factory_suites[@]}"\n').encode()
runner=old_runner.replace(anchor,anchor+block,1)
with (ROOT/(PREFIX+'registration-block.sh')).open('xb') as output:output.write(block)

def invoke():
    command=['python3',PREFIX+'audit-original.py'];run=subprocess.run(command,cwd=ROOT,capture_output=True)
    return dict(command=command,returncode=run.returncode,stdout_base64=encode(run.stdout),stderr_base64=encode(run.stderr))
baseline=invoke()
with (ROOT/(PREFIX+'audit-original-baseline.json')).open('x') as output:output.write(json.dumps(baseline,indent=2)+'\n')
assert baseline['returncode']==0 and not base64.b64decode(baseline['stderr_base64'])
(ROOT/RUNNER).write_bytes(runner)
rejected=invoke()
with (ROOT/(PREFIX+'audit-original-red.json')).open('x') as output:output.write(json.dumps(rejected,indent=2)+'\n')
assert rejected['returncode']!=0 and b'unreviewed governance drift: tools/run_ci_local.sh' in base64.b64decode(rejected['stderr_base64'])

constant=('PRIVATE_FACTORY_FIXTURE_OWNER = "PERL-PRIVATE-FACTORY-CAPTURE.7"\n'
    'PRIVATE_FACTORY_FIXTURE_PATHS = (\n'+''.join('    '+repr(p)+',\n' for p in suites+helpers)+')\n'
    'PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS = ((\n    '+repr(anchor)+',\n    (\n'
    +''.join('        '+repr(line)+'\n' for line in block.splitlines(keepends=True))+ '    ),\n),)\n\n').encode()
marker=b'PERL_STORAGE_REPLACEMENTS = (\n';assert old_auditor.count(marker)==1
auditor=old_auditor.replace(marker,constant+marker,1)
old=b'(KNOWLEDGE_HEADER_GATE_CI_INSERTIONS + SCALAR_RECEIVER_COPY_CI_INSERTIONS'
new=b'(PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS + KNOWLEDGE_HEADER_GATE_CI_INSERTIONS + SCALAR_RECEIVER_COPY_CI_INSERTIONS'
assert auditor.count(old)==1;auditor=auditor.replace(old,new,1)
old=b'            "knowledge_header_gate_owner": KNOWLEDGE_HEADER_GATE_OWNER,\n'
new=old+b'            "private_factory_fixture_owner": PRIVATE_FACTORY_FIXTURE_OWNER,\n'
assert auditor.count(old)==1;auditor=auditor.replace(old,new,1)
old=b'            verify = verify_governance_evolution\n'
controls=b'''            altered += tuple(current.replace(insertion, b"", 1)
                             for _, insertion in PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS)
            altered += tuple(current.replace(insertion, insertion * 2, 1)
                             for _, insertion in PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS)
            for path in PRIVATE_FACTORY_FIXTURE_PATHS:
                line = b" " + path.encode() + b"\\n"
                require(current.count(line) == 1, "private fixture path is not unique")
                altered += (current.replace(line, b"", 1),
                            current.replace(line, line * 2, 1))
            altered += (
                current.replace(b'PERL5OPT= prove -Iperl "${private_factory_suites[@]}"',
                                b'PERL5OPT= true "${private_factory_suites[@]}"', 1),
                current.replace(b' perl -c -Iperl "$private_factory_input"',
                                b' true "$private_factory_input"', 1),
                current.replace(b' require_tracked_file "$private_factory_input"',
                                b' true "$private_factory_input"', 1),
                current.replace(b" t/actionir_default_object_capture.t\\n",
                                b" t/other_private_fixture.t\\n", 1),
            )
'''
assert auditor.count(old)==1;auditor=auditor.replace(old,controls+old,1)
with (ROOT/(PREFIX+'auditor-constant.py')).open('xb') as output:output.write(constant)
with (ROOT/(PREFIX+'auditor-controls.py')).open('xb') as output:output.write(controls)
(ROOT/AUDITOR).write_bytes(auditor)
record=dict(result='PASS',base=BASE,producer_sha256=sha(Path(__file__).read_bytes()),
    suites=suites,helpers=helpers,anchor_base64=encode(anchor),block_sha256=sha(block),
    runner_before_sha256=sha(old_runner),runner_after_sha256=sha(runner),
    auditor_before_sha256=sha(old_auditor),auditor_after_sha256=sha(auditor),
    baseline=baseline,original_audit_red=rejected,
    inputs={p:sha((ROOT/p).read_bytes()) for p in [PREFIX+n for n in ('register.py','inventory-final.py','inventory.json','inventory.py','repair-inventory.py','inventory-repair.json','audit-original.py','runner-original.sh','auditor-original.py','registration-block.sh','auditor-constant.py','auditor-controls.py','audit-original-baseline.json','audit-original-red.json')]+['docs/checkpoints/REPO-HYGIENE.19/canonical.log.gz']},
    scope='One exact insertion selects every91 accepted supplied suite and46 supplied test helper through actual tracked-presence and syntax commands, followed by the unchanged complete supplied prove population. Existing commands stay byte-exact. Original auditor baseline PASS and actual post-insertion RED precede a narrow inverse/owner and280 additional exact registration mutations. Full original runner/auditor and actual channels remain retained. No fixture/runtime/dependency implementation changes.')
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
print('Exact registration written:91 suites/46 helpers;original audit PASS then RED;current inverse requires independent proof')
