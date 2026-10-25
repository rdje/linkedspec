"""Physical historical-auditor rollback/bypass, exact restoration and controls."""
import importlib.util
import json
import os
import common as a

AUDIT = 'tests/language-readiness/verify_objectives.py'
PROOF = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'


def module():
    # Compile the bytes just read, avoiding timestamp-based import cache reuse.
    import types
    result = types.ModuleType('actual_signed_dart_auditor')
    result.__file__ = str(a.ROOT/AUDIT)
    exec(compile((a.ROOT/AUDIT).read_bytes(), result.__file__, 'exec'), result.__dict__)
    return result


def main():
    before = a.read(AUDIT)
    old = a.load('admission-before-images.json.gz')['auditor_before']
    inputs = a.load('history-final-read-inputs.json.gz')['files']
    assert inputs[AUDIT] == before
    engine = 'dart/lib/src/runtime/interpreter.dart'
    assert inputs[engine] == a.read(engine)
    own = {name: a.read(name) for name in
           [a.PREFIX+'auditor_faults.py', a.PREFIX+'common.py']}
    a.save('auditor-fault-inputs.json.gz', dict(current=before, accepted=old,
        producer_inputs=own, input_reference=a.PREFIX+'history-final-read-inputs.json.gz',
        scope='Every unchanged historical-read input is compared before each actual subprocess; whole auditor variants are retained separately. Actual original recovery driver/guards and installed Python/OS are used. No runtime source or sealed proof is mutated.'))

    def stable_other_inputs():
        return all(path == AUDIT or a.read(path) == packet for path, packet in inputs.items())

    def write(packet):
        (a.ROOT/AUDIT).write_bytes(a.decode(packet['base64']))
        os.chmod(a.ROOT/AUDIT, packet['mode'])
        assert a.read(AUDIT) == packet

    def run(label):
        assert stable_other_inputs()
        source = a.read(AUDIT)
        result = a.run(['bash', 'tools/run_python_project_data.sh', PROOF])
        stable = stable_other_inputs() and a.read(AUDIT) == source
        a.save('auditor-'+label+'.json.gz', dict(source=source, run=result,
            all_supplied_inputs_unchanged=stable))
        assert stable
        return result

    current = a.decode(before['base64'])
    guard = b'require(digest(contents) == DART_SIGNED_AFTER,'
    assert current.count(guard) == 1
    bad = current.replace(guard, b'require(True,', 1)
    bypass = dict(base64=a.encode(bad), sha256=a.sha(bad), mode=before['mode'])
    lease=a.ROOT/'.linkedspec-data/verification/signed-dart17-auditor-lease.json'
    assert not lease.exists()
    lease.write_text(json.dumps(dict(path=AUDIT,before=before,closed=False)))
    try:
        write(old)
        rollback = run('accepted-rollback')
        assert rollback['returncode'] != 0
        assert b'current executable evidence drift: '+engine.encode() in a.decode(rollback['stderr_base64'])
        write(before)
        audit = module()
        data = a.decode(inputs[engine]['base64'])
        healthy = audit.verify_dart_signed_evolution(engine, data, audit.DART_SIGNED_BEFORE)
        controls = []
        for name, path, raw, historical, reason in [
            ('wrong-source', engine+'.other', data, audit.DART_SIGNED_BEFORE, 'unapproved Dart runtime source:'),
            ('wrong-history', engine, data, '0'*64, 'Dart runtime historical boundary mismatch:'),
            ('unreviewed-current', engine, data+b'\n// unreviewed\n', audit.DART_SIGNED_BEFORE, 'unreviewed Dart runtime drift:'),
            ('old-current', engine, audit.git('show', a.BASE+':'+engine), audit.DART_SIGNED_BEFORE, 'unreviewed Dart runtime drift:'),
        ]:
            try:
                audit.verify_dart_signed_evolution(path, raw, historical)
            except ValueError as error:
                assert str(error).startswith(reason)
                controls.append(dict(name=name, path=path, source_base64=a.encode(raw),
                    historical=historical, reason=str(error)))
            else:
                raise AssertionError('auditor admitted '+name)
        a.save('auditor-direct-controls.json.gz', dict(source=before, healthy=healthy, rejected=controls))
        write(bypass)
        admitted = module().verify_dart_signed_evolution(
            engine, data+b'\n// unreviewed\n', audit.DART_SIGNED_BEFORE)
        faulty = run('actual-hash-guard-bypass')
        assert faulty['returncode'] != 0
        assert b'runtime corruption control did not reject' in a.decode(faulty['stderr_base64'])
        a.save('auditor-bypass-admission.json.gz', dict(source=bypass, admitted=admitted,
            competing_source_base64=a.encode(data+b'\n// unreviewed\n')))
    finally:
        write(before)
        lease.write_text(json.dumps(dict(path=AUDIT,before=before,closed=True)))
    restored = run('restored')
    assert restored['returncode'] == 0 and not a.decode(restored['stderr_base64'])
    assert json.loads(a.decode(restored['stdout_base64'])) == a.load('history-final-result.json.gz')
    assert a.read(AUDIT) == before
    a.save('auditor-fault-result.json.gz', dict(accepted_rollback_rejected=True,
        actual_bypass_admits_unreviewed_source=True, actual_bypass_rejected_by_driver=True,
        direct_rejections=len(controls), exact_source_and_mode_restored=True,
        restored_driver_matches_initial_healthy_report=True))
    print('Auditor rollback RED; actual hash bypass admits drift and driver rejects; exact restoration GREEN; four direct denials.')


if __name__ == '__main__':
    main()
