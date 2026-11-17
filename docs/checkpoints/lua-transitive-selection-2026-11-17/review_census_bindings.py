"""Independently bind every census path/mode/object to the actual activation tree."""
import copy
import gzip
import importlib.util
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


def table(raw):
    result = {}
    for cell in raw.split(b'\0'):
        if cell:
            metadata, path = cell.split(b'\t', 1)
            mode, kind, oid = metadata.split()
            if kind == b'blob' and mode in (b'100644', b'100755'):
                result[path.decode()] = (int(mode, 8) & 0o777, oid.decode())
    return result


def compare(rows, expected):
    assert len(rows) == len(expected), 'census population'
    actual = {}
    for row in rows:
        assert row['path'] not in actual, 'census duplicate'
        actual[row['path']] = (row['mode'], row['oid'])
    assert actual == expected, 'census path/mode/object binding'


def main():
    spec = importlib.util.spec_from_file_location('original_census_sources', BASE / 'review.py')
    original = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(original)
    sources, identities = original.recover()
    plan = json.loads(sources[str(BASE / 'plan.json')])
    argv = ['git', 'ls-tree', '-rz', plan['activation'], '--', *plan['roots']]
    actual = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    assert actual.returncode == 0 and not actual.stderr
    retained = gzip.decompress((BASE / 'commands/tree-stdout.gz').read_bytes())
    assert actual.stdout == retained, 'actual retained activation tree'
    expected = table(retained)
    census = json.loads((BASE / 'census.json').read_bytes())
    compare(census['blob_reads'], expected)
    fixed = table(gzip.decompress((BASE / 'commands/fixed-tree-stdout.gz').read_bytes()))
    assert fixed == {name: (identities[name]['mode'], identities[name]['oid']) for name in fixed}
    wanted = ['git', 'grep', '-l', '-z', '-F']
    for name in plan['candidates']:
        wanted.extend(['-e', Path(name).name])
    wanted.extend([plan['activation'], '--', *plan['roots']])
    assert json.loads((BASE / 'commands/named-reference-files.json').read_bytes()) == dict(argv=wanted, cwd='.')
    assert (BASE / 'commands/named-reference-files-exit.txt').read_text() == '1\n'
    assert gzip.decompress((BASE / 'commands/named-reference-files-stdout.gz').read_bytes()) == b''
    assert gzip.decompress((BASE / 'commands/named-reference-files-stderr.gz').read_bytes()) == b''
    controls = {}
    for label in ('object', 'mode', 'population'):
        rows = copy.deepcopy(census['blob_reads'])
        if label == 'object':
            rows[0]['oid'] = '0' * 40
        elif label == 'mode':
            rows[0]['mode'] ^= 0o100
        else:
            rows.pop()
        try:
            compare(rows, expected)
        except AssertionError as error:
            assert str(error) == ('census population' if label == 'population' else 'census path/mode/object binding')
            controls[label] = 'RED'
        else:
            raise AssertionError('census binding corruption accepted')
    print(json.dumps(dict(result='PASS', census_bindings=len(expected), fixed_source_bindings=len(fixed), controls=controls,
        limits='Logical path/mode/object population and actual original literal-query arguments/channels only. No complete computed graph, native/per-read/physical or missing original reader first-use closure.'), sort_keys=True))


if __name__ == '__main__':
    main()
