"""Read retained finite Count/copy observations; no runtime or writer replay."""
import copy
import gzip
import json
import hashlib
import tarfile
import subprocess
from pathlib import Path

HERE = Path(__file__).parent
BACKENDS = ('perl', 'rust', 'dart', 'julia', 'lua_puc', 'lua_luajit')
ROUTES = {name: ('native', 'fresh') if name == 'perl' else
          ('native', 'restored', 'plan', 'fresh') for name in BACKENDS}
TARGETS = json.loads((HERE / 'targets.json').read_text())


def strict_equal(actual, expected):
    if isinstance(actual, bool) or isinstance(expected, bool):
        return type(actual) is type(expected) and actual == expected
    if isinstance(actual, (int, float)) and isinstance(expected, (int, float)):
        return actual == expected
    if type(actual) is not type(expected):
        return False
    if isinstance(expected, list):
        return len(actual) == len(expected) and all(
            strict_equal(a, e) for a, e in zip(actual, expected))
    if isinstance(expected, dict):
        return actual.keys() == expected.keys() and all(
            strict_equal(actual[key], value) for key, value in expected.items())
    return actual == expected


def differences(actual, expected, path=()):
    if strict_equal(actual, expected):
        return []
    if isinstance(actual, list) and isinstance(expected, list) and len(actual) == len(expected):
        return [entry for index, (a, e) in enumerate(zip(actual, expected))
                for entry in differences(a, e, path + (index,))]
    return [{'path': list(path), 'expected': expected, 'actual': actual}]


def read_rows(path, marker):
    data = path.read_bytes() if path.exists() else gzip.decompress(Path(str(path) + '.gz').read_bytes())
    result = {}
    for line in data.decode().splitlines():
        if not line.startswith(marker):
            continue
        name, raw = line[len(marker):].split(' ', 1)
        assert name not in result, 'duplicate case: ' + name
        result[name] = json.loads(raw)
    return result


def collect():
    result = {backend: {} for backend in BACKENDS}
    for cohort in ('primary', 'logical'):
        prefix = HERE if cohort == 'primary' else HERE / 'logical'
        cases = json.loads((prefix / 'cases.json').read_text())
        ids = {row['id'] for row in cases}
        perl_path = HERE / 'perl-stdout.log' if cohort == 'primary' else HERE / 'perl-logical/stdout.log'
        perl_marker = 'COUNT_COPY_PERL ' if cohort == 'primary' else 'COUNT_COPY_PERL_LOGICAL '
        perl = read_rows(perl_path, perl_marker)
        assert perl.keys() == ids, 'Perl case coverage'
        for name, row in perl.items():
            assert row['native_callable'] and row['loaded'] and not row['warnings'], 'Perl setup'
            assert not any(row.get(key) for key in ('build_error', 'emission_error', 'load_error', 'descriptor_error'))
            meta = row['metadata']
            assert meta['language_agnostic_action_ir_ready'] == 1
            assert all(meta[key] == 0 for key in ('raw_perl_dependency_count', 'canonical_action_ir_fallback_count', 'unresolved_helper_count'))
            result['perl'][name] = {
                route: {'error': row[route + '_error']} if row[route + '_error'] else {'value': row[route]}
                for route in ROUTES['perl']}
        for backend, filename, marker in (
            ('rust', 'rust-native-stdout.log', 'COUNT_COPY_RUST '),
            ('dart', 'dart-native-stdout.log', 'COUNT_COPY_DART '),
            ('julia', 'julia-stdout.log', 'COUNT_COPY_JULIA '),
            ('lua_puc', 'lua-puc-stdout.log', 'COUNT_COPY_LUA '),
            ('lua_luajit', 'lua-luajit-stdout.log', 'COUNT_COPY_LUA '),
        ):
            rows = read_rows(prefix / filename, marker)
            assert rows.keys() == ids, backend + ' case coverage'
            for name, row in rows.items():
                assert not ('preparation_error' in row or 'compile_error' in row), (backend, name, row)
                normalized = {}
                for route, value in row.items():
                    normalized[route] = {'value': value['ok']} if 'ok' in value else value
                result[backend][name] = normalized
        for backend in ('rust', 'dart'):
            fresh = read_rows(prefix / (backend + '-fresh-stdout.log'), 'COUNT_COPY_' + backend.upper() + '_FRESH ')
            assert fresh.keys() == ids, backend + ' fresh coverage'
            for name, row in fresh.items():
                result[backend][name]['fresh'] = row
    return result


def owner(backend, name, delta):
    paths = {tuple(entry['path']) for entry in delta}
    if backend == 'perl':
        if name == 'rejection_through_copy' and paths <= {(0,), (1,)}:
            return '73.6.1'
        if name == 'repeated_count_after_copy' and paths == {(2,)}:
            return '73.6.1'
        if name in ('rejected_copy_logical', 'rejected_logical') and paths <= {(0,), (1,)}:
            return '73.6.6'
    if backend == 'rust':
        allowed = {'free_source_domains': {2, 4, 5, 6, 7, 8},
                   'receiver_source_domains': {2, 4, 5, 6, 7, 8},
                   'free_copied_domains': {1, 2, 3, 4}}
        if name in allowed and paths <= {(index,) for index in allowed[name]}:
            return '73.6.2'
    if name == 'receiver_source_domains' and paths <= {(7,), (8,)}:
        return {'dart': '73.6.3', 'julia': '73.6.4', 'lua_puc': '73.6.5', 'lua_luajit': '73.6.5'}.get(backend)
    return None


def assess(observed):
    gaps = []
    matched = 0
    for backend in BACKENDS:
        assert observed[backend].keys() == TARGETS.keys(), backend + ' complete authored coverage'
        for name, routes in observed[backend].items():
            assert routes.keys() == set(ROUTES[backend]), (backend, name, 'route coverage')
            target = TARGETS[name]
            for route, row in routes.items():
                if 'error_contains' in target:
                    assert 'error' in row and target['error_contains'] in json.dumps(row['error'], sort_keys=True), (backend, name, route, 'needed error')
                    matched += 1
                    continue
                assert 'value' in row and 'error' not in row, (backend, name, route, row)
                delta = differences(row['value'], target['value'])
                if not delta:
                    matched += 1
                    continue
                repair = owner(backend, name, delta)
                assert repair, (backend, name, route, 'unowned value/kind gap', delta)
                gaps.append({'backend': backend, 'case': name, 'route': route,
                             'owner': 'TYPE-REFERENCE-BOOK.1.2.23.3.' + repair, 'differences': delta})
    return {'matched_authored_routes': matched, 'known_gap_routes': gaps,
            'scope': 'Dated finite authored observations only; no complete family, context, isolation or portable admission.'}


def controls(observed):
    assert not strict_equal(False, 0) and not strict_equal([False], [0])
    assert strict_equal([0, False], [0.0, False])
    rejected = ['bool-number-distinction']
    for label in ('missing-case', 'missing-fresh-route', 'unowned-kind-change'):
        altered = copy.deepcopy(observed)
        if label == 'missing-case':
            del altered['rust']['count_copy_zero']
        elif label == 'missing-fresh-route':
            del altered['dart']['count_copy_zero']['fresh']
        else:
            altered['rust']['count_copy_zero']['native']['value'][0][0] = True
        try:
            assess(altered)
        except AssertionError:
            rejected.append(label)
        else:
            raise AssertionError('ineffective control: ' + label)
    return rejected


def check_workspace_custody(record):
    root = HERE.resolve().parents[2]
    for row in record['sealed_workspaces']:
        with tarfile.open(root / row['archive']) as archive:
            actual = {member.name: hashlib.sha256(archive.extractfile(member).read()).hexdigest()
                      for member in archive.getmembers() if member.isfile()}
        assert actual == row['files'], 'workspace file-body recovery'
    for row in record['first_run_input_equality']:
        with tarfile.open(root / row['archive']) as archive:
            raw = archive.extractfile(row['member']).read()
        assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'first consumed input identity'


def custody_controls(record):
    check_workspace_custody(record)
    rejected = []
    for label in ('missing-archived-file', 'wrong-archived-body-hash'):
        altered = copy.deepcopy(record)
        files = altered['sealed_workspaces'][0]['files']
        key = next(iter(files))
        if label == 'missing-archived-file':
            del files[key]
        else:
            files[key] = '0' * 64
        try:
            check_workspace_custody(altered)
        except AssertionError:
            rejected.append(label)
        else:
            raise AssertionError('ineffective custody control: ' + label)
    return rejected


def verify_inputs(index):
    root = HERE.resolve().parents[2]
    for name, expected in index['direct_evidence_inputs'].items():
        path = root / name
        assert not Path(name).is_absolute() and '..' not in Path(name).parts
        assert path.is_file() and not path.is_symlink()
        assert hashlib.sha256(path.read_bytes()).hexdigest() == expected, 'retained input identity: ' + name
    actual = subprocess.check_output(['git', 'rev-parse', index['activation_commit'] + '^{tree}'], cwd=root, text=True).strip()
    assert actual == index['activation_tree'], 'owned SDK activation tree'


if __name__ == '__main__':
    index_path = HERE / 'input-index.json'
    if index_path.exists():
        index = json.loads(index_path.read_text())
        verify_inputs(index)
        altered = copy.deepcopy(index)
        name = next(iter(altered['direct_evidence_inputs']))
        altered['direct_evidence_inputs'][name] = '0' * 64
        try:
            verify_inputs(altered)
        except AssertionError as failure:
            assert str(failure).startswith('retained input identity:')
        else:
            raise AssertionError('ineffective retained-input corruption control')
    actual = collect()
    result = assess(actual)
    result['rejected_controls'] = controls(actual)
    custody = json.loads((HERE / 'workspace-custody.json').read_text())
    result['custody_controls'] = custody_controls(custody)
    print(json.dumps(result, sort_keys=True, indent=2))
