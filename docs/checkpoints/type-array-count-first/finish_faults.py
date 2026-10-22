"""Finish ordinary-only faults without asserting an unused interpreter was loaded."""
import json
from pathlib import Path
import traceback
import common as c
import context
import faults
import oracle


def loaded(run,inputs):
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    inc = json.loads(c.decode(run['stdout_base64']))['inc']
    actual = {}
    for path in c.SOURCES+['perl/LinkedSpec.pm']:
        key = path.removeprefix('perl/')
        if key not in inc:
            assert path == c.SOURCE
            continue
        assert Path(inc[key]).resolve() == c.ROOT/path
        actual[path] = c.identity(path)
        assert actual[path] == inputs[path]
    return actual


def main():
    previous = c.load('faults-before.json.gz')
    saved = previous['sources']
    assert all(c.read(path) == packet for path,packet in saved.items())
    plan = c.load('cases.json')
    epochs = {}
    for name,*_ in previous['tasks'][:6]:
        restored = c.load('fault-'+name+'-restored.json.gz')
        assert restored['sources_restored'] and restored['inputs_unchanged']
        epochs[name] = 'fault-'+name
    c.write_new('faults2-before.json.gz',dict(producer=c.read(c.PREFIX+'finish_faults.py'),
        original_producer=c.read(c.PREFIX+'faults.py'),context=context.snapshot(),sources=saved,
        scope='First six controls pass. Ordinary harray-only probes do not load CodeblockRuntime; the old loader assertion interrupted the seventh control after finally restoring source. Original supplied mutant epoch survives. Retain raw output before validating the corrected loader.'))
    for name,path,before,after,case_id in previous['tasks'][6:]:
        original = saved[path]
        text = c.decode(original['base64']).decode()
        assert text.count(before) == 1
        selected = dict(cases=[case for case in plan['cases'] if case['id'] == case_id])
        stem = 'fault2-'+name
        try:
            c.source(path).write_text(text.replace(before,after,1))
            c.source(path).chmod(original['mode'])
            supplied = context.snapshot()
            c.write_new(stem+'-inputs.json.gz',supplied)
            run = c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(selected).encode())
            c.write_new(stem+'-raw.json.gz',dict(run=run,plan=selected,mutant=c.read(path)))
            stable = c.unchanged(supplied['inputs'])
            if name == 'count-kind':
                try:
                    faults.loaded(run,supplied['inputs'])
                except KeyError:
                    refusal = traceback.format_exc()
                else:
                    raise AssertionError('Original overbroad loader unexpectedly admitted ordinary-only route')
                c.write_new('fault-loader-refusal.json.gz',dict(run=run,traceback=refusal,
                    original_producer=c.read(c.PREFIX+'faults.py'),corrected_producer=c.read(c.PREFIX+'finish_faults.py')))
            red = oracle.failures(run,selected)
            actual = loaded(run,supplied['inputs'])
            c.write_new(stem+'-observed.json.gz',dict(plan=selected,run=run,failures=red,
                loaded_sources=actual,inputs_unchanged=stable,mutant=c.read(path)))
        finally:
            c.source(path).write_bytes(c.decode(original['base64']))
            c.source(path).chmod(original['mode'])
        restored_inputs = context.snapshot()
        c.write_new(stem+'-restored-inputs.json.gz',restored_inputs)
        restored = c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(selected).encode())
        actual_restored = loaded(restored,restored_inputs['inputs'])
        exact = all(c.read(owner) == packet for owner,packet in saved.items())
        stable_restored = c.unchanged(restored_inputs['inputs'])
        c.write_new(stem+'-restored.json.gz',dict(run=restored,loaded_sources=actual_restored,
            inputs_unchanged=stable_restored,sources_restored=exact))
        assert exact and stable and stable_restored and set(red) == {case_id}
        assert not oracle.failures(restored,selected)
        epochs[name] = stem
        print(name,'actual RED / exact restoration GREEN; actual ordinary loaded modules verified',flush=True)
    c.write_new('faults-result.json',dict(faults=list(epochs),epochs=epochs,sources_restored=True))


if __name__ == '__main__':
    main()
