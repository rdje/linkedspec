"""Independent Python integer/JSON oracle over retained actual Rust executions."""
import json
import common as c
import review_before as before

FOUR = before.ROUTES
SIX = FOUR | {'merged_native', 'emitted'}


def exact(value):
    if isinstance(value, dict):
        if set(value) == {'exact_integer'}:
            return int(value['exact_integer'])
        return {key: exact(item) for key, item in value.items()}
    if isinstance(value, list):
        return [exact(item) for item in value]
    return value


def matches(row, wanted):
    actual = row['actual']
    if 'ok' in wanted:
        return actual == wanted
    raw = actual.get('raw_error')
    if not isinstance(raw, str):
        return False
    for context in wanted.get('codeblock_contexts', []):
        prefix = "codeblock '" + context + "': "
        if not raw.startswith(prefix):
            return False
        raw = raw[len(prefix):]
    try:
        error = json.loads(raw)
    except ValueError:
        return False
    return isinstance(error, dict) and all(error.get(key) == value for key, value in wanted['error'].items())


def check(name, routes=SIX, passed=True):
    supplied = c.load('test-' + name + '-inputs.json.gz')
    for path, packet in supplied['context']['sources'].items():
        assert c.sha(c.decode(packet['base64'])) == packet['sha256'], path
    assert c.load('test-' + name + '-build.json.gz')['returncode'] == 0
    packet = c.load('test-' + name + '-run.json.gz')
    assert packet['inputs_unchanged'] and packet['executable_unchanged']
    assert packet['run']['returncode'] == (0 if passed else 101)
    before.binary_identity(c.load('test-' + name + '-binary.json')['artifact'])
    fixture = json.loads(c.decode(supplied['fixture']['base64']))
    population = [row for row in fixture['cases'] if row.get('pointer_width', 64) == 64]
    targets = {row['id']: exact(row['expected']) for row in population}
    rows = before.decode_rows(packet['run'])
    pairs = {(row['id'], row['route']) for row in rows}
    assert len(rows) == len(pairs) and pairs == {(key, route) for key in targets for route in routes}
    failed = [dict(id=row['id'], route=row['route']) for row in rows if not matches(row, targets[row['id']])]
    if passed:
        assert not failed, failed
    else:
        assert failed, 'actual runtime fault must differ from an independent target'
    output = c.decode(packet['run']['stdout_base64']).decode()
    sdk = []
    for line in output.splitlines():
        marker = 'SIGNED_ARRAY_JSON_BOUNDARY '
        if marker in line:
            item = json.JSONDecoder().raw_decode(line.split(marker, 1)[1])[0]
            assert item['source'] == item['encoded']
            sdk.append(item['source'])
    assert sorted(sdk) == sorted(['-4', '-9223372036854775805', '-18446744073709549565'])
    if 'emitted' in routes:
        children = c.load('test-' + name + '-emitted-binaries.json.gz')['executables']
        assert len(children) == 1
        before.binary_identity(children[0]['artifact'])
        assert children[0]['artifact']['sha256'] == children[0]['observed']['sha256']
        for marker in ['SIGNED_ARRAY_EMITTED_BUILD ', 'SIGNED_ARRAY_EMITTED_RUN ']:
            found = [json.JSONDecoder().raw_decode(line.split(marker, 1)[1])[0]
                for line in output.splitlines() if marker in line]
            assert len(found) == 1 and found[0]['status'] == 0
    return dict(epoch=name, cases=len(population), routes=sorted(routes), observations=len(rows),
        failures=failed, sdk_tokens=sdk,
        scope='Retained 64-bit runtime/test epochs. Python decodes exact raw JSON integers independently of the Rust generic Value projection. Expected error fields are the declared per-case subset; exact full Unicode payload and private state boundaries have separate retained tests. Not portable admission or arbitrary-precision DSL arithmetic.')


if __name__ == '__main__':
    import sys
    print(json.dumps(check(sys.argv[1] if len(sys.argv)>1 else 'after3'), sort_keys=True))
