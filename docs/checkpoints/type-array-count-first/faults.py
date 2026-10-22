"""Install actual comparator/copy faults, observe typed RED, restore exact owners."""
import json
from pathlib import Path
import common as c
import context
import oracle


def loaded(run, inputs):
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    observed = json.loads(c.decode(run['stdout_base64']))
    result = {}
    for path in c.SOURCES + ['perl/LinkedSpec.pm']:
        key = path.removeprefix('perl/')
        assert Path(observed['inc'][key]).resolve() == c.ROOT/path
        result[path] = c.identity(path)
        assert result[path] == inputs[path]
    return result


def main():
    implementation = c.load('implementation.json.gz')
    runtime, emitter = c.SOURCES[:2]
    replacements = implementation['replacements']
    tasks = [
        ('free-dispatch',runtime,replacements[0]['new'],replacements[0]['old'],'deferred/count/free/integers'),
        ('receiver-dispatch',runtime,replacements[3]['new'],replacements[3]['old'],'deferred/first/receiver/integers'),
        ('free-arity',runtime,'  return undef unless @$args == 1;\n  my $value = _eval_expr($args->[0], $ctx);',
            '  my $value = _eval_expr($args->[0], $ctx);','deferred/count/effects/free/extra'),
        ('receiver-arity',runtime,"  if ($method eq 'count' || $method eq 'first') {\n   return undef if @$args || $index < $#$calls;",
            "  if ($method eq 'count' || $method eq 'first') {\n   return undef if $index < $#$calls;",'deferred/first/effects/receiver/extra'),
        ('terminal-effects',runtime,"  if ($method eq 'count' || $method eq 'first') {\n   return undef if @$args || $index < $#$calls;",
            "  if ($method eq 'count' || $method eq 'first') {\n   return undef if @$args;",'deferred/count/effects/receiver/continuation'),
        ('first-selection',runtime," return ref($value) eq 'ARRAY' && @$value ? $value->[0] : undef",
            " return ref($value) eq 'ARRAY' && @$value ? $value->[-1] : undef",'deferred/first/free/integers'),
        ('count-kind',emitter,replacements[4]['new'],replacements[4]['old'],'ordinary/count/free/harray'),
        ('first-kind',emitter,replacements[5]['new'],replacements[5]['old'],'ordinary/first/free/harray'),
    ]
    plan = c.load('cases.json')
    saved = {path:c.read(path) for path in c.SOURCES}
    for name,path,before,after,case_id in tasks:
        assert c.decode(saved[path]['base64']).decode().count(before) == 1,name
        assert sum(case['id'] == case_id for case in plan['cases']) == 1,case_id
    c.write_new('faults-before.json.gz',dict(sources=saved,tasks=tasks,context=context.snapshot()))
    names = []
    for name,path,before,after,case_id in tasks:
        original = saved[path]
        text = c.decode(original['base64']).decode()
        assert text.count(before) == 1,(name,text.count(before))
        selected = dict(cases=[case for case in plan['cases'] if case['id'] == case_id])
        assert len(selected['cases']) == 1,case_id
        try:
            c.source(path).write_text(text.replace(before,after,1))
            c.source(path).chmod(original['mode'])
            supplied = context.snapshot()
            c.write_new('fault-'+name+'-inputs.json.gz',supplied)
            run = c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(selected).encode())
            stable = c.unchanged(supplied['inputs'])
            red = oracle.failures(run,selected)
            actual = loaded(run,supplied['inputs'])
            c.write_new('fault-'+name+'-observed.json.gz',dict(plan=selected,run=run,
                failures=red,loaded_sources=actual,inputs_unchanged=stable,mutant=c.read(path)))
        finally:
            c.source(path).write_bytes(c.decode(original['base64']))
            c.source(path).chmod(original['mode'])
        restored_inputs = context.snapshot()
        c.write_new('fault-'+name+'-restored-inputs.json.gz',restored_inputs)
        restored = c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(selected).encode())
        restored_loaded = loaded(restored,restored_inputs['inputs'])
        restored_stable = c.unchanged(restored_inputs['inputs'])
        exact = all(c.read(owner) == packet for owner,packet in saved.items())
        c.write_new('fault-'+name+'-restored.json.gz',dict(run=restored,
            loaded_sources=restored_loaded,inputs_unchanged=restored_stable,sources_restored=exact))
        assert stable and red and set(red) == {case_id}
        assert restored_stable and exact and not oracle.failures(restored,selected)
        names.append(name)
        print(name,'actual RED / exact restoration GREEN',flush=True)
    c.write_new('faults-result.json',dict(faults=names,sources_restored=True))


if __name__ == '__main__':
    main()
