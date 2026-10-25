"""Read-only independent review of the retained before-runtime observations."""
import hashlib
import json
import subprocess
import zlib
import common as c

ROUTES = {'native', 'spec_json', 'compiled_json', 'generated_plan'}


def decode_rows(run):
    marker = 'SIGNED_ARRAY_OBSERVATION '
    rows = []
    for line in c.decode(run['stdout_base64']).decode().splitlines():
        if marker in line:
            rows.append(json.JSONDecoder().raw_decode(line.split(marker, 1)[1])[0])
    return rows


def binary_identity(value):
    decoder = zlib.decompressobj(wbits=31)
    digest = hashlib.sha256()
    size = 0
    for part in value['parts']:
        assert c.identity(part['path']) == {key: part[key] for key in ('sha256', 'mode')}
        raw = decoder.decompress(c.source(part['path']).read_bytes())
        digest.update(raw)
        size += len(raw)
    raw = decoder.flush()
    digest.update(raw)
    size += len(raw)
    assert decoder.eof and not decoder.unused_data
    assert digest.hexdigest() == value['sha256'] and size == value['bytes']


def check():
    initial = c.load('before-inputs.json.gz')
    sources = initial['context']['sources']
    tree = subprocess.check_output(['git', 'ls-tree', '-r', '-z', c.BASE, '--', 'rust'], cwd=c.ROOT)
    original = {}
    for row in tree.split(b'\0'):
        if not row:
            continue
        metadata, path = row.split(b'\t', 1)
        mode, kind, oid = metadata.split()
        if kind == b'blob' and mode in (b'100644', b'100755'):
            original[path.decode()] = (mode, oid)
    assert set(original) == {path for path in sources if path.startswith('rust/')}
    for path, (mode, oid) in original.items():
        packet = sources[path]
        raw = c.decode(packet['base64'])
        assert c.sha(raw) == packet['sha256']
        actual = hashlib.sha1(b'blob ' + str(len(raw)).encode() + b'\0' + raw).hexdigest().encode()
        assert actual == oid
        assert bool(packet['mode'] & 0o111) == (mode == b'100755')
    assert c.load('before-build.json.gz')['returncode'] == 0
    native = c.load('before-runs.json.gz')
    assert native['inputs_unchanged'] and native['executable_unchanged']
    calibration = native['calibration']['run']
    assert calibration['returncode'] == 0 and not c.decode(calibration['stderr_base64'])
    assert json.loads(c.decode(calibration['stdout_base64'])) == [-2, 10, 10, 10, 10]
    binary_identity(c.load('before-binary.json')['artifact'])
    supplied = c.load('test-before-inputs.json.gz')
    for path in original:
        assert supplied['context']['sources'][path] == sources[path]
    assert c.load('test-before-build.json.gz')['returncode'] == 0
    packet = c.load('test-before-run.json.gz')
    assert packet['inputs_unchanged'] and packet['executable_unchanged']
    assert packet['run']['returncode'] == 101
    binary_identity(c.load('test-before-binary.json')['artifact'])
    fixture = json.loads(c.decode(supplied['fixture']['base64']))
    expected = {row['id']: row['expected'] for row in fixture['cases']}
    rows = decode_rows(packet['run'])
    pairs = {(row['id'], row['route']) for row in rows}
    assert len(rows) == len(pairs) and pairs == {(name, route) for name in expected for route in ROUTES}
    mismatches = []
    observer_differences = []
    for row in rows:
        actual, wanted = row['actual'], expected[row['id']]
        matches = actual == wanted if 'ok' in wanted else all(
            actual.get('error', {}).get(key) == value for key, value in wanted['error'].items())
        if not matches:
            mismatches.append(dict(id=row['id'], route=row['route']))
        if row['expected'] != wanted:
            observer_differences.append(dict(id=row['id'], route=row['route']))
            assert row['id'] == 'unsigned-magnitude-underflow'
            assert actual['error']['code'] == 'nested_write_segment_invalid'
            assert wanted['error']['code'] == 'nested_write_array_underflow'
    assert {row['id'] for row in observer_differences} == {'unsigned-magnitude-underflow'}
    assert len(observer_differences) == len(ROUTES)
    assert any(row['id'] == 'read-last' for row in mismatches)
    return dict(base=c.BASE, rust_git_images=len(original), cli_cases=len(native['rows']),
        test_cases=len(expected), observations=len(rows), mismatches=len(mismatches),
        passing_controls=len(rows) - len(mismatches), failing_pairs=mismatches,
        observer_differences=observer_differences,
        limits='Original 64-bit Rust before-runtime population. Large expected resolved_index is coarsened by the before observer JSON configuration; those four product mismatches are independently distinguished by wrong error code, not numeric-field precision. No repaired behavior, current source or general numeric admission is claimed.')


if __name__ == '__main__':
    print(json.dumps(check(), sort_keys=True))
