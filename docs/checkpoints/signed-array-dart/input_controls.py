"""Actual publication faults and physical reviewer discard/restoration."""
import json
import os
import common as a


def main():
    reader = a.PREFIX+'publish.py'
    target = a.PREFIX+'source-fault-result.json'
    manifest = a.PREFIX+'publication.json'
    originals = {name: a.read(name) for name in [reader, target, manifest]}
    current = a.decode(originals[reader]['base64'])
    start = current.index(b'def check(base_only=False):\n')
    stop = current.index(b"\n\nif __name__=='__main__':", start)
    bad = current[:start]+b'def check(base_only=False):\n    return {"discarded_validator": True}\n'+current[stop:]
    faulty = dict(base64=a.encode(bad), sha256=a.sha(bad), mode=originals[reader]['mode'])
    a.save('input-control-inputs.json.gz', dict(originals=originals, actual_faulty_reader=faulty,
        producer=a.read(a.PREFIX+'input_controls.py'), helper=a.read(a.PREFIX+'common.py')))

    def write(name, packet):
        (a.ROOT/name).write_bytes(a.decode(packet['base64']))
        os.chmod(a.ROOT/name, packet['mode'])
        assert a.read(name) == packet

    def run():
        return a.run(['bash', 'tools/run_python_project_data.sh', reader, '--base'])

    healthy = run()
    a.save('review-run.json.gz', healthy)
    assert healthy['returncode'] == 0
    cases = {}
    held = a.ROOT/'.linkedspec-data/verification/signed-dart17-held-input'
    assert not held.exists()
    lease=a.ROOT/'.linkedspec-data/verification/signed-dart17-input-lease.json'
    assert not lease.exists()
    lease.write_text(json.dumps(dict(originals=originals,closed=False)))
    try:
        for name in ['missing', 'bytes', 'mode', 'required-omission']:
            if name == 'missing':
                (a.ROOT/target).rename(held)
                changed = dict(path=target, absent=True)
            elif name == 'bytes':
                (a.ROOT/target).write_bytes(a.decode(originals[target]['base64'])+b' ')
                changed = dict(path=target, packet=a.read(target))
            elif name == 'mode':
                os.chmod(a.ROOT/target, originals[target]['mode'] ^ 0o100)
                changed = dict(path=target, packet=a.read(target))
            else:
                value = json.loads(a.decode(originals[manifest]['base64']))
                del value['inputs']['history-final-run.json.gz']
                (a.ROOT/manifest).write_text(json.dumps(value, sort_keys=True)+'\n')
                changed = dict(path=manifest, packet=a.read(manifest))
            red = run()
            assert red['returncode'] != 0
            write(reader, faulty)
            bypass = run()
            assert bypass['returncode'] == 0
            assert json.loads(a.decode(bypass['stdout_base64'])) == {'discarded_validator': True}
            write(reader, originals[reader])
            restored = run()
            assert restored['returncode'] != 0
            cases[name] = dict(changed=changed, red=red, bypass=bypass, restored_rejection=restored)
            a.save('input-control-'+name+'.json.gz', cases[name])
            if name == 'missing':
                held.rename(a.ROOT/target)
            else:
                write(target if name in ('bytes', 'mode') else manifest,
                      originals[target if name in ('bytes', 'mode') else manifest])
    finally:
        if held.exists():
            held.rename(a.ROOT/target)
        for path, packet in originals.items():
            write(path, packet)
    lease.write_text(json.dumps(dict(originals=originals,closed=True)))
    final = run()
    assert final['returncode'] == 0 and final['stdout_base64'] == healthy['stdout_base64']
    assert all(a.read(path) == packet for path, packet in originals.items())
    a.save('input-controls.json.gz', dict(cases=cases, healthy=healthy, final=final,
        inputs_restored=True, scope='Four actual current publication-input faults; whole validator discard admits each, exact restoration rejects each. Final healthy result matches original channels. This measures evidence rejection, not additional runtime behavior.'))
    print('Admission reader PASS; four actual input faults/bypass/restoration; exact healthy channels restored.')


if __name__ == '__main__':
    main()
