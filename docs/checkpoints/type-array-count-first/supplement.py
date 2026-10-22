"""Observe callable precedence and independent indexed-read/alias controls before repair."""
import json
from pathlib import Path
import common as c
import context


def plan():
    cases = []
    for helper in ('count','first'):
        for mode in ('ordinary','deferred'):
            setup = helper+' = {|value| return("shadow") }; items = [2,10,1]; '
            expr = helper+'(items)'
            body = setup+('cb = {|| return('+expr+') }; return(cb());' if mode == 'deferred' else 'return('+expr+');')
            cases.append(dict(id='binding/'+mode+'/'+helper,body=body))
            functions = 'fn '+helper+'(values) { return("registered") }\n'
            body = 'items = [2,10,1]; '+('cb = {|| return('+expr+') }; return(cb());' if mode == 'deferred' else 'return('+expr+');')
            cases.append(dict(id='registered/'+mode+'/'+helper,body=body,functions=functions))
    for mode in ('ordinary','capture-proxy','parameter-proxy'):
        setup = 'items = [[2,1],[]]; '
        if mode == 'ordinary':
            call = 'first(items)'
        elif mode == 'capture-proxy':
            setup += 'cb = {|| return(items[0]) }; '
            call = 'cb()'
        else:
            setup += 'cb = {|values| return(values[0]) }; '
            call = 'cb(items)'
        body = setup+'chosen = '+call+'; chosen[0] = 9; return([chosen,items]);'
        cases.append(dict(id='alias/'+mode,body=body))
    for mode in ('ordinary','deferred-index-proxy','deferred-first'):
        setup = 'maker = {|| return("picked") }; items = [maker]; '
        if mode == 'ordinary':
            call = 'first(items)'
        else:
            selector = 'items[0]' if mode == 'deferred-index-proxy' else 'first(items)'
            setup += 'cb = {|| return('+selector+') }; '
            call = 'cb()'
        cases.append(dict(id='callable/'+mode,body=setup+'chosen = '+call+'; return(chosen());'))
    return dict(cases=cases,scope='Observation only; existing indexed reads and registered callable priority distinguish helper behavior from boundary semantics.')


def main():
    selected = plan()
    c.write_new('supplement-cases.json',selected)
    supplied = context.snapshot()
    c.write_new('supplement-inputs.json.gz',supplied)
    run = c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(selected).encode())
    stable = c.unchanged(supplied['inputs'])
    c.write_new('supplement-observed.json.gz',dict(run=run,inputs_unchanged=stable))
    assert stable and run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    observed = json.loads(c.decode(run['stdout_base64']))
    loaded = {}
    for path in ['perl/LinkedSpec.pm']+c.SOURCES:
        key = path.removeprefix('perl/')
        assert Path(observed['inc'][key]).resolve() == c.ROOT/path
        loaded[path] = c.identity(path)
        assert loaded[path] == supplied['inputs'][path]
    c.write_new('supplement-result.json.gz',dict(cases=len(selected['cases']),loaded_sources=loaded,
        inputs_unchanged=stable,scope=selected['scope']))
    print('Pre-change supplements retained:',len(selected['cases']),'cases; source bytes and supplied inputs unchanged')


if __name__ == '__main__':
    main()
