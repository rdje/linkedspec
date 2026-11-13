"""Independently validate selected fields and actual distinguishing mutations."""
import copy
import gzip
import hashlib
import io
import json
import math
from pathlib import Path
import stat
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'analysis'
OUT.mkdir()
paths = [path for path in (BASE / 'epochs').rglob('*') if path.is_file()]
paths += [BASE / 'cases.json', BASE / 'intake/input-identities.json', BASE / 'intake/inputs-before-use.tar.gz',
    BASE / 'intake/old-sdk-identities.json', BASE / 'intake/old-sdk-sources.tar.gz', BASE / 'analyze.py']
input_rows = {}
for path in paths:
    assert not path.is_absolute() and '..' not in path.parts
    body = path.read_bytes()
    input_rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
(OUT / 'producer-before-use.py.gz').write_bytes(gzip.compress(Path(__file__).read_bytes(), mtime=0))
(OUT / 'input-identities.json').write_text(json.dumps(input_rows, indent=2, sort_keys=True) + '\n')


def require(valid, reason):
    if not valid:
        raise ValueError(reason)


def archive(path, identities):
    result = {}
    body = path if isinstance(path, bytes) else path.read_bytes()
    with tarfile.open(fileobj=io.BytesIO(body)) as packed:
        for member in packed:
            require(member.isfile() and member.name not in result, 'archive membership')
            body = packed.extractfile(member).read()
            row = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=member.mode)
            require(row == identities[member.name], 'archive bytes and mode')
            result[member.name] = body
    require(result.keys() == identities.keys(), 'archive population')
    return result


original_rows = json.loads((BASE / 'intake/input-identities.json').read_bytes())
sources = archive(BASE / 'intake/inputs-before-use.tar.gz', original_rows)
epoch_rows = json.loads((BASE / 'epochs/input-identities.json').read_bytes())
archive(BASE / 'epochs/inputs-before-use.tar.gz', epoch_rows)
old_rows = json.loads((BASE / 'intake/old-sdk-identities.json').read_bytes())
old_logical = archive(BASE / 'intake/old-sdk-sources.tar.gz', {
    name: {key: value for key, value in row.items() if key != 'git_oid'} for name, row in old_rows.items()})
materialized_rows = json.loads((BASE / 'epochs/old-materialized-identities.json').read_bytes())
materialized = archive(BASE / 'epochs/old-materialized-before-use.tar.gz', materialized_rows)
old_expected = dict(old_logical)
old_expected.update({name: body for name, body in sources.items() if name.startswith('specs/')})
prefix = '.linkedspec-data/raw-error-audit/old/'
require(materialized.keys() == {prefix + name for name in old_expected}, 'old SDK materialized population')
for name, body in old_expected.items():
    require(materialized[prefix + name] == body, 'old SDK materialized body')
for host in ('puc', 'luajit'):
    current_native_rows = json.loads((BASE / 'epochs' / (host + '-native-identities.json')).read_bytes())
    current_native = archive(BASE / 'epochs' / (host + '-native-before-use.tar.gz'), current_native_rows)
    original = 'docs/checkpoints/array-transform-callable-lua-2026-11-12/intake/' + host + '/'
    original_native_rows = json.loads(sources[original + 'native-identities.json'])
    original_native = archive(sources[original + 'native-before-first-run.tar.gz'], original_native_rows)
    require({Path(name).name: body for name, body in current_native.items()} ==
        {Path(name).name: body for name, body in original_native.items()}, 'opaque native product reuse')
command = ['git', 'ls-tree', '-rz', 'e0a1bb47571b75b800546c3d4522e0d2ca5f778c', '--', 'lua']
(OUT / 'population-command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
tree = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / ('population-' + channel + '.gz')).write_bytes(gzip.compress(getattr(tree, channel), mtime=0))
(OUT / 'population-exit.txt').write_text(str(tree.returncode) + '\n')
require(tree.returncode == 0 and tree.stderr == b'', 'actual Git population query')
git_rows = {}
for entry in tree.stdout.split(b'\0'):
    if entry:
        metadata, name = entry.split(b'\t', 1)
        mode, kind, oid = metadata.decode().split()
        require(kind == 'blob' and mode in ('100644', '100755'), 'Lua owned regular source')
        git_rows[name.decode()] = (int(mode, 8) & 0o777, oid)
owned = {name: body for name, body in sources.items() if name.startswith('lua/')}
def validate_sources(candidate, identities):
    require(candidate.keys() == git_rows.keys(), 'complete activation Lua source population')
    for name, body in candidate.items():
        oid = hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest()
        require((identities[name]['mode'], oid) == git_rows[name], 'actual Git source identity')
validate_sources(owned, original_rows)
consumers = [name for name, body in owned.items() if name.endswith('result_guard_composition_test.lua')
    and b'user_function_definition_ast_parser_from_spec_source' in body]
require(set(consumers) == {'lua/test/key_count_callable_result_guard_composition_test.lua',
    'lua/test/hash_value_result_guard_composition_test.lua',
    'lua/test/hash_view_result_guard_composition_test.lua',
    'lua/test/array_pipeline_result_guard_composition_test.lua',
    'lua/test/array_transform_result_guard_composition_test.lua',
    'lua/test/array_pipeline_callable_result_guard_composition_test.lua',
    'lua/test/array_transform_callable_result_guard_composition_test.lua',
    'lua/test/array_concat_open_arity_result_guard_composition_test.lua'}, 'selected callable consumer population')
require(owned['lua/test/callable_array_pipeline_observation.lua'] == owned['lua/test/callable_array_transform_observation.lua'], 'two published observers agree')
full_public = {name for name in consumers if b'callable_array_' in owned[name]}
require(len(full_public) == 3, 'three helper-based published projections')
partial = set(consumers) - full_public
expressions = []
for name in partial:
    require(b'error_json' not in owned[name], 'older named-field projection remains partial')
    expressions.append(next(line for line in owned[name].splitlines() if b'success and json.harray({value=value})' in line))
require(len(set(expressions)) == 1, 'five identical named-field projections')
population_controls = []
for label, reason in (('omitted-source', 'source population'), ('extra-source', 'source population'),
        ('changed-body', 'Git source identity'), ('changed-mode', 'Git source identity')):
    candidate, identities = dict(owned), copy.deepcopy(original_rows)
    name = sorted(owned)[0]
    if label == 'omitted-source': candidate.pop(name)
    elif label == 'extra-source': candidate['lua/unreviewed-extra.lua'] = b'extra'
    elif label == 'changed-body': candidate[name] += b'\nchanged'
    else: identities[name]['mode'] ^= 0o111
    try:
        validate_sources(candidate, identities)
    except ValueError as error:
        require(reason in str(error), 'source control rejected for unrelated reason')
        population_controls.append(dict(label=label, observed=str(error), rejected=True))
    else:
        raise ValueError('source control unexpectedly accepted: ' + label)


def decode(node):
    kind = node['kind']
    if kind in ('string', 'number', 'boolean'):
        value = node['value']
        valid = (kind == 'string' and isinstance(value, str)) or (kind == 'boolean' and isinstance(value, bool)) or (
            kind == 'number' and type(value) in (int, float) and math.isfinite(value))
        require(valid and set(node) == {'kind', 'value'}, 'raw scalar type')
        return node['value']
    require(kind == 'table' and set(node) == {'kind', 'fields'} and isinstance(node['fields'], list), 'selected raw value type')
    result = {}
    for entry in node['fields']:
        require(set(entry) == {'key', 'value'}, 'raw field entry')
        key = decode(entry['key'])
        require(type(key) in (str, int, float), 'raw field key')
        require(key not in result, 'duplicate raw field')
        result[key] = decode(entry['value'])
    return result


cases = {row['id']: row for row in json.loads((BASE / 'cases.json').read_bytes())}
observations = {}
for epoch in ('old', 'current'):
    for host in ('puc', 'luajit'):
        folder = BASE / 'epochs' / epoch / host
        require((folder / 'probe-exit.txt').read_text() == '0\n', 'actual probe exit')
        require(gzip.decompress((folder / 'probe-stderr.gz').read_bytes()) == b'', 'actual probe stderr')
        rows = {}
        for line in gzip.decompress((folder / 'probe-stdout.gz').read_bytes()).decode().splitlines():
            if line.startswith('RAW_ERROR_CASE '):
                _, name, value = line.split(' ', 2)
                require(name not in rows, 'duplicate case frame')
                rows[name] = json.loads(value)
        observations[(epoch, host)] = rows
        archive(folder / 'actual-parsed-emitted.tar.gz', json.loads((folder / 'artifact-identities.json').read_bytes()))


def scalar_paths(value, prefix=''):
    result = set()
    for name, item in value.items():
        path = prefix + str(name)
        if isinstance(item, dict):
            result.update(scalar_paths(item, path + '.'))
        else:
            result.add(path)
    return result


def validate(data):
    counters = dict(records=0, field_controls=0, prior_misses=0, named_native_misses=0)
    for rows in data.values():
        require(rows.keys() == cases.keys(), 'case population')
        for name, routes in rows.items():
            require(set(routes) == {'native', 'restored', 'plan', 'fresh'}, 'route population')
            binding = 'needed_source' in name or name == 'nested_binding'
            rule = 'Child' if name.startswith('nested_') else 'Value'
            top = 'Top' if name.startswith('nested_') else 'Value'
            helper = 'collect' if 'variadic' in name else 'pair'
            native_message = decode(routes['native']['observation']['fields'])['message']
            for route, record in routes.items():
                observed = record['observation']
                raw = decode(observed['fields'])
                native = route in ('native', 'restored')
                require(observed['runtime'] == native and observed['generated'] == (not native), 'route error channel')
                if native:
                    fields = {'message', 'diagnostic', 'code', 'identifier', 'expected_kind', 'actual_kind'} if binding else {
                        'message', 'diagnostic', 'code', 'stage', 'helper_name', 'rule_label', 'handler_source_label'}
                    require(set(raw) == fields, 'native outer fields')
                    require(raw['code'] == ('binding_kind_mismatch' if binding else 'user_function_arity_mismatch'), 'selected error family')
                    if binding:
                        require((raw['identifier'], raw['expected_kind'], raw['actual_kind']) == ('items', 'array', 'scalar'), 'binding fields')
                    else:
                        require((raw['stage'], raw['helper_name'], raw['rule_label'], raw['handler_source_label']) ==
                            ('user_function_call', helper, rule, 'lua_runtime:function:' + helper), 'function outer attribution')
                    diagnostic = raw['diagnostic']
                    require(set(diagnostic) == {'type', 'stage', 'owner_stage', 'summary', 'detail', 'top_rule', 'rule_label', 'handler_source_label'}, 'diagnostic field population')
                    require((diagnostic['top_rule'], diagnostic['rule_label']) == (top, rule), 'rule attribution')
                    require(diagnostic['detail'] == raw['message'] and diagnostic['type'] == 'runtime_parser'
                        and diagnostic['owner_stage'] == 'lua_runtime', 'diagnostic ownership')
                    require(observed['published'] == dict(message=raw['message'], diagnostic=diagnostic), 'published native projection')
                    ignored = {'identifier', 'expected_kind', 'actual_kind'} if binding else {'stage', 'rule_label', 'handler_source_label'}
                else:
                    expected = dict(code='generated_execution_failed', detail='RuntimeInterpreterException: ' + native_message,
                        handler_family='default', rule_label=rule, source_identity='raw-error-audit/' + name + '.spec',
                        stage='execute_generated', summary='Generated Lua parser execution failed', type='generated_source_error')
                    require(raw == expected, 'generated envelope fields')
                    require(observed['published'] == raw, 'published generated projection')
                    ignored = set()
                prior = json.loads(record['prior_observation'])
                require(prior['error_json'] == observed['published'] and prior['error'] == observed['text'], 'prior published observations')
                expected_controls = {(path, operation) for path in scalar_paths(raw) for operation in ('change', 'remove')}
                expected_controls.add(('audit_unpublished_marker', 'add'))
                actual_controls = {(row['path'], row['operation']) for row in record['mutations']}
                require(actual_controls == expected_controls and len(actual_controls) == len(record['mutations']), 'mutation population')
                for control in record['mutations']:
                    missed = control['path'] in ignored or control['path'] == 'audit_unpublished_marker'
                    require(control['raw_observer_changed'] is True, 'raw observer distinguishes control')
                    require(control['prior_observer_changed'] is (not missed), 'prior observer distinction')
                    counters['field_controls'] += 1
                    counters['prior_misses'] += int(missed)
                    counters['named_native_misses'] += int(native and control['path'] in ignored)
                counters['records'] += 1
    for host in ('puc', 'luajit'):
        require(data[('old', host)] == data[('current', host)], 'old/current exact preservation')
    return counters


result = validate(observations)
controls = []
target_case = 'own_needed_source_take_receiver'
def corrupt(label, reason, mutation):
    data = copy.deepcopy(observations)
    mutation(data[('current', 'puc')])
    try:
        validate(data)
    except ValueError as error:
        require(reason in str(error), 'counterfactual failed for an unrelated reason: ' + label)
        controls.append(dict(label=label, expected=reason, observed=str(error), rejected=True))
    else:
        raise ValueError('counterfactual unexpectedly accepted: ' + label)


def field(rows, name, value):
    entries = rows[target_case]['native']['observation']['fields']['fields']
    entry = next(item for item in entries if item['key']['value'] == name)
    entry['value']['value'] = value


corrupt('binding-value', 'binding fields', lambda rows: field(rows, 'expected_kind', 'harray'))
corrupt('missing-case', 'case population', lambda rows: rows.pop(target_case))
corrupt('missing-route', 'route population', lambda rows: rows[target_case].pop('fresh'))
corrupt('public-raw-promotion', 'published native projection', lambda rows: rows[target_case]['native']['observation']['published'].update(expected_kind='array'))
corrupt('missing-control', 'mutation population', lambda rows: rows[target_case]['native']['mutations'].pop())
corrupt('claimed-prior-coverage', 'prior observer distinction', lambda rows: next(item for item in rows[target_case]['native']['mutations'] if item['path'] == 'expected_kind' and item['operation'] == 'change').update(prior_observer_changed=True))
corrupt('lost-raw-detection', 'raw observer distinguishes control', lambda rows: rows[target_case]['native']['mutations'][0].update(raw_observer_changed=False))
corrupt('duplicate-raw-field', 'duplicate raw field', lambda rows: rows[target_case]['native']['observation']['fields']['fields'].append(copy.deepcopy(rows[target_case]['native']['observation']['fields']['fields'][0])))
profiles = {host: {name: {route: record['observation'] for route, record in routes.items()}
    for name, routes in observations[('old', host)].items()} for host in ('puc', 'luajit')}
(OUT / 'old-profiles.json').write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
result.update(consumers=sorted(consumers), full_public_consumers=sorted(full_public), partial_consumers=sorted(partial),
    activation_lua_files=len(owned), population_controls=population_controls, counterfactual_controls=controls,
    scope='Selected observed field names/values, eight authored cases and four route-specific channels; historical observers retain their original narrower scopes. No all-error/table-identity/native-toolchain completeness.')
for name, row in input_rows.items():
    path = Path(name)
    require(dict(bytes=path.stat().st_size, sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode)) == row, 'analysis inputs changed')
(OUT / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(result, sort_keys=True))
