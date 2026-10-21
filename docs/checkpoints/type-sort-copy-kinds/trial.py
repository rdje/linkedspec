"""Exercise the published implicit accumulator before selecting its regression cases."""
import json
import common as c
import context


def main():
    prefix = 'Top: /x/\n I { push(Number); push(Number); push(Number); '
    suffix = ' }\nNumber: I { return(2) }\n'
    plan = dict(cases=[
        dict(id='legacy/raw', source=prefix + 'return(sorted(Top))' + suffix, expected=[2, 2, 2]),
        dict(id='legacy/argument-copy', source=prefix +
            'keep = {|values| return(values) }; return(keep(sorted(Top)))' + suffix, expected=[2, 2, 2]),
    ])
    c.write_new('trial-cases.json', plan)
    supplied = context.snapshot()
    c.write_new('trial-inputs.json.gz', supplied)
    run = c.run(['perl', '-Iperl', 'docs/checkpoints/type-array-pipelines/probe.pl'], input=json.dumps(plan).encode())
    stable = c.unchanged(supplied['inputs'])
    c.write_new('trial-run.json.gz', dict(run=run, inputs_unchanged=stable))
    assert stable and run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    for row in json.loads(c.decode(run['stdout_base64']))['rows']:
        print(json.dumps({key: row[key] for key in ('id', 'descriptor')}, sort_keys=True))
        for route in ('native', 'generated'):
            value = row[route]
            print(row['id'], route, json.dumps({key: value.get(key) for key in ('completed', 'value', 'exception', 'last_error')}, sort_keys=True))
        for line in (row['native'].get('dump') or '').splitlines():
            if '[sort {' in line:
                print('Observed generated sort:', line[:1800])


if __name__ == '__main__':
    main()
