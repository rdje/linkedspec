"""Repair the invocation boundary after exact RED; inverse it and restore GREEN."""
import json
import subprocess
import common as c
import context
import baseline2

OLD = b'if ($parse_error) {\n'
NEW = b'if ($parse_error || $runtime_ctx{last_error}) {\n'


def oracle(phase,library=False):
    args = ['--library',phase] if library else [phase]
    return c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'oracle2.py']+args)


def collect(phase,full=False):
    epoch = context.snapshot()
    c.write_new(phase+'-inputs.json.gz',dict(context=epoch,
        producer=c.read(c.PREFIX+'repair.py'),oracle=c.read(c.PREFIX+'oracle2.py'),
        collector=c.read(c.PREFIX+'baseline2.py'),test=c.read('t/trace_cli.t')))
    value = {}
    if full:
        value['library'] = c.run(['bash','tools/project_data_run.sh','perl','-Iperl',c.PREFIX+'perl_probe.pl'],
            input=c.source(c.PREFIX+'cases2.json').read_bytes())
        print(phase+': public descriptor/Get/fresh complete',flush=True)
        value['cli'] = {}
        for case in c.load('cases2.json')['cases']:
            value['cli'][case['id']] = dict(quiet=baseline2.cli(case),routed=baseline2.cli(case,True))
            print(phase+': CLI '+case['id'],flush=True)
    value['permanent'] = c.run(['bash','tools/project_data_run.sh','prove','-Iperl','t/trace_cli.t'])
    value['inputs_unchanged'] = c.unchanged(epoch['inputs'])
    c.write_new(phase+'.json.gz',value)
    assert value['inputs_unchanged']
    return value


def main():
    epoch = context.snapshot()
    c.write_new('pre-repair-inputs.json.gz',dict(context=epoch,
        producer=c.read(c.PREFIX+'repair.py'),oracle=c.read(c.PREFIX+'oracle2.py')))
    checks = dict(cli=oracle('baseline2'),library=oracle('baseline2',True))
    checks['inputs_unchanged'] = c.unchanged(epoch['inputs'])
    c.write_new('pre-repair-checks.json.gz',checks)
    assert checks['inputs_unchanged']
    assert checks['cli']['returncode']==1 and not c.decode(checks['cli']['stderr_base64'])
    observed = json.loads(c.decode(checks['cli']['stdout_base64']))
    assert len(observed['failures'])==6
    assert {(row['id'],row['route']) for row in observed['failures']} == {
        (name,route) for name in ('fractional-write','callable-fractional-write','wrong-container')
        for route in ('quiet','routed')}
    assert checks['library']['returncode']==0 and not c.decode(checks['library']['stderr_base64'])
    assert c.load('baseline2.json.gz')['permanent']['returncode']==1
    path = c.source('bin/linkedspec')
    before = c.read('bin/linkedspec')
    raw = c.decode(before['base64'])
    accepted = subprocess.check_output(['git','show',c.BASE+':bin/linkedspec'],cwd=c.ROOT)
    assert accepted == raw and raw.count(OLD)==1 and NEW not in raw
    after = raw.replace(OLD,NEW,1)
    path.write_bytes(after)
    path.chmod(before['mode'])
    expected = c.read('bin/linkedspec')
    c.write_new('repair.json.gz',dict(before=before,after=expected,
        accepted_base=c.BASE,producer=c.read(c.PREFIX+'repair.py'),
        scope='One invocation predicate observes the already supplied runtime context as well as the immediately saved exception; no library/runtime/selector authority changes.'))
    green = collect('green',True)
    checks = dict(cli=oracle('green'),library=oracle('green',True))
    c.write_new('green-checks.json.gz',checks)
    assert green['permanent']['returncode']==0
    assert all(value['returncode']==0 and not c.decode(value['stderr_base64']) for value in checks.values())
    print('Full eleven-case/22-command GREEN; starting exact source inverse',flush=True)
    try:
        path.write_bytes(raw)
        path.chmod(before['mode'])
        inverse = collect('inverse')
        assert inverse['permanent']['returncode']==1
    finally:
        path.write_bytes(after)
        path.chmod(before['mode'])
    exact = c.read('bin/linkedspec') == expected
    assert exact
    restored = collect('restored')
    assert restored['permanent']['returncode']==0
    c.write_new('repair-completion.json.gz',dict(source_restored=exact,
        source=c.read('bin/linkedspec'),producer=c.read(c.PREFIX+'repair.py'),
        full_cases=11,distinct_sources=10,full_cli_observations=22,
        inverse_scope='Actual permanent trace/CLI consumer under exact old invocation predicate; restored consumer repeats the exact final source. The full native/fresh/CLI population is the separate green epoch.'))
    print('CLI reporting repair GREEN; actual permanent inverse RED and exact restoration GREEN',flush=True)


if __name__ == '__main__':
    main()
