"""Retain an immutable current-source public run before classifying it."""
import argparse
import json
import re
import common as c
import context


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--epoch', required=True)
    args = parser.parse_args()
    assert re.fullmatch(r'[a-z0-9-]+', args.epoch)
    fixture = 'tests/drop-generated/cases.json'
    extras = [c.PREFIX+path.name for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    extras.append(fixture)
    snapshot = context.snapshot(extras)
    snapshot.update(plan=json.loads((c.ROOT/fixture).read_bytes()), source=c.read(c.SOURCE))
    c.write_new(args.epoch+'-inputs.json.gz', snapshot)
    result = c.run(['perl', '-Iperl', c.PREFIX+'probe.pl'], input=json.dumps(snapshot['plan']).encode())
    unchanged = c.unchanged(snapshot['inputs'])
    c.write_new(args.epoch+'-run.json.gz', dict(run=result, inputs_unchanged=unchanged))
    assert result['returncode'] == 0 and not c.decode(result['stderr_base64']) and unchanged
    rows = json.loads(c.decode(result['stdout_base64']))['rows']
    assert len(rows) == len(snapshot['plan']['cases'])
    print(args.epoch, ': retained', len(rows), 'public rows;', len(snapshot['inputs']), 'input identities')


if __name__ == '__main__':
    main()
