"""Actual unregistered Dart candidate denial before historical-guard changes."""
import common as c

AUDIT='tests/language-readiness/verify_objectives.py'
LEDGER='docs/language-readiness/objective-reconciliation.md'
SOURCE='dart/lib/src/runtime/interpreter.dart'
PROOF='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'


def main():
    old=c.load('before-inputs.json.gz')['context']['sources'][SOURCE]
    git=c.run(['git','show',c.BASE+':'+SOURCE])
    assert git['returncode']==0 and c.decode(git['stdout_base64'])==c.decode(old['base64'])
    original_reads=c.load('audit-before.json.gz')['historical_report']
    historical=c.load('audit-before.json.gz')['historical_dart_boundary']
    assert old['sha256']==historical['sha256']
    current=c.read(SOURCE)
    assert current['sha256']!=old['sha256']
    c.save('admission-before-images.json.gz',dict(source=SOURCE,historical=historical,
        before=old,current=current,activation_git=git,auditor_before=c.read(AUDIT),
        ledger_before=c.read(LEDGER),prior_report=original_reads,
        producer=c.read(c.PREFIX+'admission_prepare.py'),
        scope='Whole exact Dart source before/after images and old auditor before admission. '
            'The source owner is17.4; the accepted Rust source/support exceptions remain unchanged.'))
    supplied=c.context([AUDIT,LEDGER,PROOF,
        'tests/language-readiness/recover_objective_audit_inputs.py',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-archive.py'])
    c.save('admission-unregistered-inputs.json.gz',supplied)
    run=c.run(['bash','tools/run_python_project_data.sh',PROOF])
    stable=c.unchanged(supplied['inputs'])
    c.save('admission-unregistered-run.json.gz',dict(run=run,inputs_unchanged=stable))
    assert stable and run['returncode']!=0
    assert b'current executable evidence drift: '+SOURCE.encode() in c.decode(run['stderr_base64'])
    print('Actual unchanged recovery rejects unregistered Dart source drift; exact original images retained.')


if __name__=='__main__':main()
