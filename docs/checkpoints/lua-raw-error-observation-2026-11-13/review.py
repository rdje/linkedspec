"""Readonly historical recovery; no SDK, capture, analyzer or old writer replay."""
import copy
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent


def require(valid, reason):
    if not valid:
        raise ValueError(reason)


def read(name):
    return (BASE / name).read_bytes()


def unpack(name, identity_name):
    identities = json.loads(read(identity_name))
    result = {}
    with tarfile.open(fileobj=io.BytesIO(read(name))) as archive:
        for member in archive:
            require(member.isfile() and member.name not in result, 'archive membership')
            body = archive.extractfile(member).read()
            actual = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=member.mode)
            require(actual == identities[member.name], 'archive identity')
            result[member.name] = body
    require(result.keys() == identities.keys(), 'archive population')
    return result


def frames(name, prefix):
    result = {}
    for line in gzip.decompress(read(name)).decode().splitlines():
        if line.startswith(prefix + ' '):
            _, identifier, body = line.split(' ', 2)
            require(identifier not in result, 'duplicate frame')
            result[identifier] = json.loads(body)
    return result


def fields(node):
    if node['kind'] != 'table':
        return node['value']
    result = {}
    for entry in node['fields']:
        key = fields(entry['key'])
        require(key not in result, 'duplicate field')
        result[key] = fields(entry['value'])
    return result


def paths(value, prefix=''):
    result = set()
    for name, item in value.items():
        path = prefix + str(name)
        if isinstance(item, dict): result.update(paths(item, path + '.'))
        else: result.add(path)
    return result


def validate(model):
    totals = dict(records=0, field_controls=0, prior_misses=0, named_native_misses=0)
    for epoch in ('old', 'current'):
        for host in ('puc', 'luajit'):
            rows = model['epochs'][epoch][host]
            require(set(rows) == model['cases'], 'case population')
            for name, routes in rows.items():
                require(set(routes) == {'native', 'restored', 'plan', 'fresh'}, 'route population')
                binding = 'needed_source' in name or name == 'nested_binding'
                for route, record in routes.items():
                    raw = fields(record['observation']['fields'])
                    native = route in ('native', 'restored')
                    if native:
                        expected = {'actual_kind', 'code', 'diagnostic', 'expected_kind', 'identifier', 'message'} if binding else {
                            'code', 'diagnostic', 'handler_source_label', 'helper_name', 'message', 'rule_label', 'stage'}
                        require(set(raw) == expected, 'native field population')
                        if binding:
                            require((raw['identifier'], raw['expected_kind'], raw['actual_kind']) == ('items', 'array', 'scalar'), 'binding values')
                        published = record['observation']['published']
                        require(published == dict(message=raw['message'], diagnostic=raw['diagnostic']), 'native published projection')
                        ignored = {'identifier', 'expected_kind', 'actual_kind'} if binding else {'stage', 'rule_label', 'handler_source_label'}
                    else:
                        require(set(raw) == {'code', 'detail', 'handler_family', 'rule_label', 'source_identity', 'stage', 'summary', 'type'}, 'generated field population')
                        require(record['observation']['published'] == raw, 'generated published projection')
                        ignored = set()
                    expected_controls = {(path, operation) for path in paths(raw) for operation in ('change', 'remove')}
                    expected_controls.add(('audit_unpublished_marker', 'add'))
                    actual = {(item['path'], item['operation']) for item in record['mutations']}
                    require(actual == expected_controls and len(actual) == len(record['mutations']), 'field control population')
                    for item in record['mutations']:
                        missed = item['path'] in ignored or item['path'] == 'audit_unpublished_marker'
                        require(item['raw_observer_changed'] is True, 'raw field distinction')
                        require(item['prior_observer_changed'] is (not missed), 'prior field limitation')
                        totals['field_controls'] += 1
                        totals['prior_misses'] += int(missed)
                        totals['named_native_misses'] += int(native and item['path'] in ignored)
                    totals['records'] += 1
    for host in ('puc', 'luajit'):
        require(model['epochs']['old'][host] == model['epochs']['current'][host], 'old current observations')
        expected = {name: {route: row['observation'] for route, row in routes.items()}
            for name, routes in model['epochs']['old'][host].items()}
        require(model['normals'][host] == expected, 'recurring old baseline')
        require(model['legacy'][host]['exit'] == 1 and b'raw-field oracle: projection misses expected_kind' in model['legacy'][host]['stderr'], 'specific legacy RED')
        require(model['raw'][host]['exit'] == 0 and model['raw'][host]['stderr'] == b'', 'raw GREEN')
        require(model['raw'][host]['stdout'].count(b'RAW_FIELD_ORACLE raw ') == 2
            and b'expected_kind true' in model['raw'][host]['stdout'] and b'rule_label true' in model['raw'][host]['stdout'], 'two raw field oracles')
    require(all(totals[key] == model['analysis'][key] for key in totals), 'independent derived totals')
    return totals


def main():
    for name, row in json.loads(read('sealed-identities.json')).items():
        path = BASE / name
        body = path.read_bytes()
        require(dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777) == row, 'sealed source or artifact')
    unpack('intake/inputs-before-use.tar.gz', 'intake/input-identities.json')
    unpack('epochs/inputs-before-use.tar.gz', 'epochs/input-identities.json')
    unpack('epochs/old-materialized-before-use.tar.gz', 'epochs/old-materialized-identities.json')
    normal_inputs = unpack('normal/inputs-before-use.tar.gz', 'normal/input-identities.json')
    require(normal_inputs['tests/fixtures/lua_raw_error_observation_cases.json'] == read('cases.json'), 'exact source-only fixture')
    require(normal_inputs['tests/fixtures/lua_raw_error_observation_profiles.json'] == read('analysis/old-profiles.json'), 'exact old profile fixture')
    model = dict(cases={row['id'] for row in json.loads(read('cases.json'))}, epochs={}, normals={}, legacy={}, raw={}, analysis=json.loads(read('analysis/result.json')))
    for host in ('puc', 'luajit'):
        unpack('epochs/' + host + '-native-before-use.tar.gz', 'epochs/' + host + '-native-identities.json')
        for epoch in ('old', 'current'):
            model['epochs'].setdefault(epoch, {})[host] = frames('epochs/' + epoch + '/' + host + '/probe-stdout.gz', 'RAW_ERROR_CASE')
            folder = 'epochs/' + epoch + '/' + host + '/'
            require(read(folder + 'probe-exit.txt') == b'0\n' and gzip.decompress(read(folder + 'probe-stderr.gz')) == b'', 'actual SDK channel')
            artifacts = unpack(folder + 'actual-parsed-emitted.tar.gz', folder + 'artifact-identities.json')
            require(len(artifacts) == 2 * len(model['cases']), 'complete SDK artifacts')
        model['normals'][host] = frames('normal/' + host + '/normal-stdout.gz', 'RAW_ERROR_NORMAL')
        folder = 'normal/' + host + '/'
        require(read(folder + 'normal-exit.txt') == b'0\n' and gzip.decompress(read(folder + 'normal-stderr.gz')) == b'', 'actual recurring channel')
        require(b'RAW_ERROR_NORMAL_SUMMARY 128 checks PASS\n' in gzip.decompress(read(folder + 'normal-stdout.gz')), 'actual recurring checks')
        require(len(unpack(folder + 'actual-parsed-emitted.tar.gz', folder + 'artifact-identities.json')) == 16, 'complete recurring artifacts')
        for mode in ('legacy', 'raw'):
            folder = 'oracles/' + host + '/' + mode + '/'
            model[mode][host] = dict(exit=int(read(folder + 'oracle-exit.txt')),
                stdout=gzip.decompress(read(folder + 'oracle-stdout.gz')), stderr=gzip.decompress(read(folder + 'oracle-stderr.gz')))
            require(len(unpack(folder + 'actual-parsed.tar.gz', folder + 'artifact-identities.json')) == (1 if mode == 'legacy' else 2), 'actual oracle artifacts')
    totals = validate(model)
    rejected = []
    target = 'own_needed_source_take_receiver'
    controls = [
        ('omit-case', 'case population', lambda m: m['epochs']['current']['puc'].pop(target)),
        ('omit-route', 'route population', lambda m: m['epochs']['current']['puc'][target].pop('fresh')),
        ('erase-field-control', 'field control population', lambda m: m['epochs']['current']['puc'][target]['native']['mutations'].pop()),
        ('claim-prior-coverage', 'prior field limitation', lambda m: next(item for item in m['epochs']['current']['puc'][target]['native']['mutations'] if item['path'] == 'expected_kind').update(prior_observer_changed=True)),
        ('erase-raw-detection', 'raw field distinction', lambda m: m['epochs']['current']['puc'][target]['native']['mutations'][0].update(raw_observer_changed=False)),
        ('erase-normal-case', 'recurring old baseline', lambda m: m['normals']['puc'].pop(target)),
        ('erase-original-RED', 'specific legacy RED', lambda m: m['legacy']['puc'].update(exit=0)),
        ('unrelated-legacy-error', 'specific legacy RED', lambda m: m['legacy']['puc'].update(stderr=b'unrelated module load error')),
        ('erase-raw-GREEN', 'raw GREEN', lambda m: m['raw']['puc'].update(exit=1)),
        ('change-derived-count', 'independent derived totals', lambda m: m['analysis'].update(named_native_misses=0)),
    ]
    for label, reason, mutate in controls:
        changed = copy.deepcopy(model)
        mutate(changed)
        try:
            validate(changed)
        except ValueError as error:
            require(str(error) == reason, 'unrelated historical rejection: ' + label)
            rejected.append(label)
        else:
            raise ValueError('ineffective historical control: ' + label)
    print(json.dumps(dict(result='PASS', **totals, rejected_controls=rejected,
        scope='Historical finite field/route observations, retained direct inputs/modes and actual RED/GREEN channels; no SDK replay/current freshness/full native closure.')))


if __name__ == '__main__':
    main()
