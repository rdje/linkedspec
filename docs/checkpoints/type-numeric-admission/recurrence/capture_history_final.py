"""Run old controls in isolation and the current complete historical recovery proof."""
import gzip
import importlib.util
import json
import os
import sys
from pathlib import Path
sys.path.insert(1, str(Path(__file__).resolve().parents[2] / 'type-numeric-codeblocks'))
import common as c
PREFIX='docs/checkpoints/type-numeric-admission/recurrence/'
AUDIT='tests/language-readiness/verify_objectives.py'
PROOF='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
TABLE='tests/language-readiness/scalar-numeric-regression-evolution.json.gz'
OLD='docs/checkpoints/type-values-signature/'


def read(name):
    raw=(c.ROOT/name).read_bytes()
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)


def put(name,value):
    raw=(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode()
    with (c.ROOT/(PREFIX+name)).open('xb') as out:
        out.write(gzip.compress(raw,mtime=0))


def load(name,path):
    spec=importlib.util.spec_from_file_location(name,c.ROOT/path)
    module=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    saved=read(PREFIX+'canonical2.json.gz')
    old_plan=read(OLD+'historical-final-inputs.json')
    old_review=read(OLD+'historical-final-review.json')
    old_run=read(OLD+'historical-final-run.json.gz')['run']
    prior_actual=json.loads(c.decode(old_run['stdout_base64']))
    proof_inputs=set(old_plan['proof_inputs'])|{TABLE}
    paths=proof_inputs|{PREFIX+name for name in ('canonical2.json.gz','implementation.json.gz','key-correction.json.gz','baseline-run.json.gz','historical-inputs.json.gz','capture_history.py','capture_history_final.py')}
    paths.update((OLD+'historical-final-inputs.json',OLD+'historical-final-review.json',OLD+'historical-final-run.json.gz',
                  c.PREFIX+'common.py',c.PREFIX+'phase0-migration.json.gz'))
    inputs={path:c.identity(path) for path in sorted(paths)}
    put('historical-final-inputs.json.gz',dict(inputs=inputs,proof_inputs=sorted(proof_inputs),
        original_auditor=saved['before'][AUDIT],current_auditor=c.read(AUDIT),current_proof=c.read(PROOF),
        producer=c.read(PREFIX+'capture_history_final.py'),
        scope='Declared original explicit isolated-proof input membership plus the new table precedes execution. '
              'The separately retained actual578-control isolated baseline uses real accepted203cde315 Phase0 bytes; '
              'this is source-integrity replay, not reconstruction of an old runtime process. Accepted historical '
              'Git revisions remain explicit immutable inputs in the retained auditor and evidence records.'))
    prior_baseline=read(PREFIX+'baseline-run.json.gz')
    controls=prior_baseline['controls']
    assert controls==old_review['current_controls']
    assert prior_baseline['calibration'] and prior_baseline['healthy_guard']==dict(original_log_attempts=0,tracked_write_attempts=0)
    print('Retained original isolated controls verified:',controls['governance_mutations_rejected'],flush=True)
    run=c.run(['bash','tools/run_python_project_data.sh',PROOF])
    put('historical-final-run.json.gz',dict(run=run,inputs_unchanged=c.unchanged(inputs),producer=c.read(PREFIX+'capture_history_final.py')))
    assert run['returncode']==0 and not c.decode(run['stderr_base64'])
    actual=json.loads(c.decode(run['stdout_base64']))
    assert set(actual['tracked_inputs'])==proof_inputs
    assert all(actual['tracked_inputs'][path]==inputs[path]['sha256'] for path in proof_inputs)
    assert actual['isolated_deterministic_capture'] and actual['healthy_audit_guard']==dict(original_log_attempts=0,tracked_write_attempts=0)
    assert actual['restored_inputs']==prior_actual['restored_inputs']
    assert actual['restored_bytes']==prior_actual['restored_bytes'] and actual['controls']==prior_actual['controls']
    current=actual['audit_controls']
    assert current['governance_mutations_rejected']==controls['governance_mutations_rejected']+66
    assert set(current['governance_mutations_by_source'])==set(controls['governance_mutations_by_source'])
    for path,count in controls['governance_mutations_by_source'].items():
        assert current['governance_mutations_by_source'][path]==count+(66 if path=='t/phase0_regression.t' else 0)
    module=load('numeric_current_auditor',AUDIT)
    source=(c.ROOT/'t/phase0_regression.t').read_bytes()
    historical=next(row['historical'] for row in actual['audit_report']['governance_updates'] if row['path']=='t/phase0_regression.t')
    raw=(c.ROOT/TABLE).read_bytes()
    body=gzip.decompress(raw)
    changed=gzip.compress(body[:-1]+b' ',mtime=0)
    assert json.loads(gzip.decompress(changed))==json.loads(body) and changed!=raw
    original=module.read_relative
    module.read_relative=lambda path:changed if path==TABLE else original(path)
    error=None
    try:
        module.verify_signature_regression_evolution('t/phase0_regression.t',source,historical)
    except ValueError as failure:
        error=str(failure)
    finally:
        module.read_relative=original
    restored=module.verify_signature_regression_evolution('t/phase0_regression.t',source,historical)
    put('table-final-control.json.gz',dict(changed_base64=c.encode(changed),semantic_json_unchanged=True,
        observed_red=error,restored=restored,producer=c.read(PREFIX+'capture_history_final.py')))
    assert error=='numeric inverse table identity mismatch: t/phase0_regression.t'
    assert c.unchanged(inputs)
    put('historical-final-review.json.gz',dict(result='PASS',original_controls=controls,current_controls=current,
        fragments=22,additional_denials=66,restored_inputs=actual['restored_inputs'],restored_bytes=actual['restored_bytes'],
        recovery_controls=len(actual['controls']),healthy_guard=actual['healthy_audit_guard'],
        proof_inputs=len(proof_inputs),table_identity_red=error,inputs_unchanged=True,
        scope='Every original historical byte/hash and reason-sensitive control remains effective; new22-fragment '
              'numeric evolution adds66 denials. Original134-input archive and recovery controls remain exact. '
              'No runtime, milestone/hash/log or historical observation is refreshed.'))
    print('Current isolated historical inverse PASS:22 fragments;66 additional denials;',actual['restored_inputs'],
          'restored inputs;',len(actual['controls']),'recovery controls; table identity RED')


if __name__=='__main__':
    main()
