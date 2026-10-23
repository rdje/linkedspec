"""Independent finite requested-value and established CLI-failure oracles."""
import json
import sys
import common as c
import inspect_native
import inspect_perl

SIGNED_CASES = [
    'read-last','read-first','read-before-last','read-dynamic','read-mixed',
    'write-last','write-first','write-dynamic','write-mixed',
    'callable-read','callable-write','callable-parameter-read','callable-copied-parameter-write',
]
RUNTIMES = ['perl','rust','dart','julia','puc','luajit']
CLI_FAILURE_CASES = ['write-fractional','write-string-negative-on-array']


def requested(route):
    plan = {row['id']:row for row in c.load('cases.json')['cases']}
    runtime,kind = route.split('/')
    if kind in ('get','generated'):
        assert runtime == 'perl'
        rows = {row['id']:row for row in inspect_perl.inspect()}
        observations = {name:rows[name]['routes']['native' if kind == 'get' else 'generated'] for name in SIGNED_CASES}
        values = {name:dict(ok=row['status']=='value' and not row['warnings'] and not row['stdout'],
            value=row['value'],code=row['code']) for name,row in observations.items()}
    else:
        assert kind == 'cli' and runtime in RUNTIMES
        rows = {row['id']:row for row in inspect_native.inspect(runtime)}
        values = {name:dict(ok=rows[name]['observed']['status']=='value',
            value=rows[name]['observed'].get('value'),exit=rows[name]['observed']['exit']) for name in SIGNED_CASES}
    failures = {}
    for name in SIGNED_CASES:
        wanted = plan[name]['requested_value']
        observed = values[name]
        if not observed['ok'] or json.dumps(observed['value'],sort_keys=True) != json.dumps(wanted,sort_keys=True):
            failures[name] = dict(expected=wanted,observed=observed)
    return dict(route=route,population=SIGNED_CASES,failures=failures,
        scope='Thirteen finite valid-position outputs from the director L+index rule; paired first/last/dynamic/mixed/callable/copy targets distinguish old behavior. No fractional/nonnumeric read, effect-order or invalid-write diagnostic identity is newly specified.')


def cli_failures(runtime):
    assert runtime in RUNTIMES
    rows = {row['id']:row for row in inspect_native.inspect(runtime)}
    failures = {}
    for name in CLI_FAILURE_CASES:
        actual = rows[name]['observed']
        if (actual['exit'],actual['stdout'],actual['stderr']) != (1,'','linkedspec: parser invocation failed\n'):
            failures[name] = actual
    return dict(runtime=runtime,population=CLI_FAILURE_CASES,failures=failures,
        scope='Existing frozen-v1 invalid selectors must follow the already published primary invocation-failure exit/stdout/stderr contract, independently of signed-array support.')


def main():
    assert len(sys.argv) == 3 and sys.argv[1] in ('requested','cli-failures')
    value = requested(sys.argv[2]) if sys.argv[1] == 'requested' else cli_failures(sys.argv[2])
    print(json.dumps(value,sort_keys=True))
    return int(bool(value['failures']))


if __name__ == '__main__':
    raise SystemExit(main())
