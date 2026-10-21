"""Retain a minimal Perl assignment/sort/clone cache-flag root-cause experiment."""
import json
import common as c
import context


def main():
    inputs = context.snapshot()
    c.write_new('decimal-inputs.json.gz', inputs)
    run = c.run(['perl', '-Iperl', c.PREFIX + 'decimal_probe.pl'])
    stable = c.unchanged(inputs['inputs'])
    c.write_new('decimal-observed.json.gz', dict(run=run, inputs_unchanged=stable))
    assert stable and run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    rows = json.loads(c.decode(run['stdout_base64']))['rows']
    assert len(rows) == 4
    for row in rows:
        assert row['before'] == row['input_flags']
        assert all(not flag['pOK'] and (flag['iOK'] or flag['nOK']) for flag in row['result_flags'])
    print(json.dumps(rows, indent=2))


if __name__ == '__main__':
    main()
