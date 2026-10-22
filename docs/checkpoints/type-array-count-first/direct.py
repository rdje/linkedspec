"""Keep thirteen passing suites and separately repair/recheck the sole stale source golden."""
import json
import re
import common as c
import context
import focused

AST = 't/actionir_ast_parser.t'


def validate(value):
    original = c.load('focused-run.json.gz')
    assert original['inputs_unchanged'] and original['tests']['returncode'] == 1
    assert value['inputs_unchanged'] and value['run']['returncode'] == 0
    assert not c.decode(value['run']['stderr_base64'])
    assert value['after'] == c.read(AST)
    inputs = c.load('focused-inputs.json.gz')['inputs']
    assert all(c.identity(path) == inputs[path] for path in c.SOURCES+['t/scalar_numeric_contract.t'])
    out = c.decode(original['tests']['stdout_base64'])
    for suite in focused.SUITES:
        if suite != AST:
            assert len(re.findall(rb'^'+re.escape(suite.encode())+rb'\s+\.{2,} ok$',out,re.M)) == 1,suite
    assert out.count(b'Failed 1/23 subtests') == 1
    assert b'Failed test:  13' in out
    match = re.search(rb'Files=(\d+), Tests=(\d+),',out)
    assert match and int(match[1]) == len(focused.SUITES)
    fresh = c.decode(value['run']['stdout_base64'])
    assert re.search(rb'Files=1, Tests=23,',fresh) and b'Result: PASS' in fresh
    stderr = c.decode(original['tests']['stderr_base64'])
    first,*remaining = stderr.splitlines()
    marker = b'# RECEIVER_COPY_OBSERVATIONS '
    assert first.startswith(marker)
    observed = json.loads(first[len(marker):])
    assert observed['live_error'] is None and observed['live'] == observed['standalone']
    assert observed['live_identity'] == observed['standalone_identity']
    assert set(observed['live_identity'].values()) == {1}
    assert all(not line.strip() or line.lstrip().startswith(b'#') for line in remaining)
    assert stderr.count(b"Failed test 'array append expression can feed an aggregate receiver chain'") == 1
    assert original['history']['returncode'] == original['scanner']['returncode'] == 0
    assert not c.decode(original['scanner']['stderr_base64'])
    history = json.loads(c.decode(original['history']['stdout_base64']))
    assert history['audit_controls']['governance_mutations_rejected'] == 650
    assert history['healthy_audit_guard'] == dict(original_log_attempts=0,tracked_write_attempts=0)
    return dict(suites=int(match[1]),tap=int(match[2]),historical_controls=650,
        scope='Thirteen suites pass in the original14-suite run; only the stale AST generated-source golden fails. Its exact one-literal correction independently passes all23 AST groups. Production and numeric-fixture source identities remain those of the original run. Original failed channels stay exact; no original full-run PASS is claimed.')


def main():
    c.write_new('ast-repair-inputs.json.gz',context.snapshot())
    before = c.read(AST)
    text = c.decode(before['base64']).decode()
    old = '}; defined($__ls_count) ? scalar(@{$__ls_count}) : 0 }},'
    new = "}; ref($__ls_count) eq 'ARRAY' ? scalar(@{$__ls_count}) : 0 }},"
    assert text.count(old) == 1
    c.source(AST).write_text(text.replace(old,new,1))
    c.source(AST).chmod(before['mode'])
    supplied = context.snapshot()
    c.write_new('ast-focused-inputs.json.gz',supplied)
    run = c.run(['bash','tools/project_data_run.sh','prove','-q','-Iperl',AST])
    value = dict(before=before,after=c.read(AST),run=run,inputs_unchanged=c.unchanged(supplied['inputs']),
        original=c.identity(c.PREFIX+'focused-run.json.gz'))
    c.write_new('focused-final.json.gz',value)
    print('Direct consumer proof:',json.dumps(validate(value),sort_keys=True))


if __name__ == '__main__':
    main()
