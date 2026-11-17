"""Readonly recovery of bounded adjacent variable/open bindings."""
import argparse
import copy
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import stat

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
spec = importlib.util.spec_from_file_location('variable_source_library', BASE / 'sources.py')
library = importlib.util.module_from_spec(spec)
spec.loader.exec_module(library)


def recover():
    before = library.archive((BASE / 'before.tar.gz').read_bytes(), json.loads((BASE / 'before-identities.json').read_bytes()))
    for name, (body, mode) in before.items():
        if name.startswith(str(BASE) + '/') and name.endswith(('.py', '.pl')):
            path = Path(name)
            assert path.read_bytes() == body and stat.S_IMODE(path.stat().st_mode) == mode, 'frozen instrument'
    plan = json.loads(before[str(BASE / 'plan.json')][0])
    sources, retained = library.reused(json.loads(before[str(BASE / 'reused-inputs.json')][0]), plan)
    targets = library.archive((BASE / 'targets.tar.gz').read_bytes(), json.loads((BASE / 'targets-identities.json').read_bytes()))
    result = {}
    for group in (before, sources, retained, targets):
        for name, value in group.items():
            assert name not in result or result[name] == value
            result[name] = value
    identities = {name: dict(bytes=len(value[0]), sha256=library.sha(value[0]), mode=value[1]) for name, value in result.items()}
    return {name: value[0] for name, value in result.items()}, identities


def specimen_oracle(specimens, output):
    rows = []
    if [r['path'] for r in output['documents']] != ['specimen:' + r['id'] for r in specimens]:
        return dict(result='RED', reason='specimen population')
    for expected, document in zip(specimens, output['documents']):
        actual = [{k: site['binding'][k] for k in ('path', 'symbol', 'mode', 'role')}
            for site in document['sites'] if site['matched']]
        healthy = document['roundtrip'] and not document['unknown_tokens'] and actual == expected['expected']
        healthy = healthy and len(document['sites']) == expected['open_words']
        rows.append(dict(id=expected['id'], expected=expected['expected'], actual=actual,
            open_words=len(document['sites']), result='PASS' if healthy else 'RED'))
    return dict(result='PASS' if all(r['result'] == 'PASS' for r in rows) else 'RED', specimens=rows)


def channel(label, name):
    return gzip.decompress((BASE / 'commands' / (label + '-' + name + '.gz')).read_bytes())


def validate_inputs(sources, identities):
    assert set(sources) == set(identities), 'input population'
    for name, body in sources.items():
        row = identities[name]
        assert len(body) == row['bytes'] and library.sha(body) == row['sha256'], 'input body'


def binding_oracle(rows, original):
    assert len(rows) == len(original) and len({(r['parent'], r['ordinal']) for r in rows}) == len(rows), 'binding population'
    for row, expected in zip(rows, original):
        assert (row['parent'], row['ordinal'], row['location'], row['declaration']) == (
            expected['parent'], expected['ordinal'], expected['location'], expected['declaration']), 'binding source site'
        assert row['path'] == expected['path'], 'binding target path'
        assert row['mode'] == expected['mode'], 'binding mode'
        assert row['role'] == expected['role'], 'binding input output role'


def report(sources, identities):
    plan = json.loads(sources[str(BASE / 'plan.json')])
    specimens = json.loads(sources[str(BASE / 'specimens.json')])
    argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'PERL5OPT=', 'perl', str(BASE / 'lexer.pl')]
    changed = specimens[0]['source'].replace('open my $fh', "$path='tests/changed.json'; open my $fh", 1)
    requests = {
        'specimens': [dict(path='specimen:' + r['id'], source=r['source'], sha256=library.sha(r['source'].encode())) for r in specimens],
        'intervening-write': [dict(path='specimen:adjacent-read-write', source=changed, sha256=library.sha(changed.encode()))],
        'corpus': [dict(path=n, source=sources[n].decode(), sha256=library.sha(sources[n])) for n in plan['sources']],
    }
    observations = {}
    for label, documents in requests.items():
        assert json.loads((BASE / 'commands' / (label + '.json')).read_bytes()) == dict(argv=argv, cwd='.')
        assert (BASE / 'commands' / (label + '-exit.txt')).read_text() == '0\n' and not channel(label, 'stderr')
        assert json.loads(channel(label, 'stdin')) == dict(ppi_version=plan['ppi_version'], documents=documents), 'actual source request'
        observed = json.loads(channel(label, 'stdout'))
        assert observed['ppi_version'] == plan['ppi_version']
        assert [r['path'] for r in observed['documents']] == [r['path'] for r in documents]
        assert [r['source_sha256'] for r in observed['documents']] == [r['sha256'] for r in documents]
        assert all(r['roundtrip'] and not r['unknown_tokens'] for r in observed['documents']), 'lexical roundtrip'
        observations[label] = observed
    healthy = specimen_oracle(specimens, observations['specimens'])
    red_source = specimen_oracle([specimens[0]], observations['intervening-write'])
    assert healthy['result'] == 'PASS' and red_source['result'] == 'RED'
    documents = {r['path']: r for r in observations['corpus']['documents']}
    assert len(documents) == 159
    old = json.loads(gzip.decompress(sources[str(Path(plan['prior']) / 'commands/consumers-stdout.gz')]))
    old_open = 0
    for document in old['documents']:
        expected = [(s['ordinal'], s['raw_word'], s['location'], s['statement_content'])
            for s in document['sites'] if s.get('word') == 'open']
        actual = [(s['ordinal'], s['raw_word'], s['location'], s['statement']) for s in documents[document['path']]['sites']]
        assert actual == expected, 'original open population and source sites'
        old_open += len(expected)
    assert old_open == 191
    matched, unmatched = [], []
    for name in plan['sources']:
        document = documents[name]
        for site in document['sites']:
            row = dict(parent=name, ordinal=site['ordinal'], location=site['location'], statement=site['statement'])
            if site['matched']:
                found = dict(**row, **site['binding'])
                lines = sources[name].decode().splitlines()
                declaration = chr(10).join(lines[found['declaration_location'][0] - 1:])
                assert declaration.lstrip().startswith(found['declaration'].lstrip()), 'actual initializer source'
                matched.append(found)
            else:
                unmatched.append(dict(**row, reason=site['unmatched_reason']))
    binding_oracle(matched, matched)
    input_paths = sorted({r['path'] for r in matched if r['role'] == 'declared-input-read'})
    output_paths = sorted({r['path'] for r in matched if r['role'] == 'declared-output-write'})
    assert set(json.loads((BASE / 'targets-identities.json').read_bytes())) == set(input_paths), 'input target custody'
    baseline = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-native.json'
    baseline_rows = [r for r in matched if r['path'] == baseline]
    assert len(baseline_rows) == 1
    row = baseline_rows[0]
    assert row['parent'] == 't/actionir_receiver_scalar_copy.t' and row['symbol'] == '$legacy_native_path' and row['mode'] == '<'
    parent_source = sources[row['parent']].decode()
    assert 'MIME::Base64::decode_base64($legacy_capture->{stdout_base64})' in parent_source
    assert 'LegacyHashKindProbe::observations()' in parent_source and 'unless defined $legacy_loaded;' in parent_source
    capture = json.loads(sources[baseline])
    assert 'returncode' in capture and 'stdout_base64' in capture
    role = dict(path=baseline, role='historical-comparison-baseline',
        reason='Parent reads stored JSON and decodes stored stdout for comparison with observation functions. Metadata is an old input, never a new successful runtime observation.',
        limits='No baseline producer replay or new execution verdict; original native/first-use custody remains4.2/SESSION5.')
    roles = {r['path']: r for r in json.loads(sources['docs/checkpoints/perl-consumer-roles-2026-11-16/roles.json'])}
    parent_role = {key: roles[row['parent']][key] for key in ('path', 'role', 'route')}
    assert parent_role['route']['occurrences'] == 2
    references = json.loads(sources[str(BASE / 'reused-inputs.json')])
    expected_tree = set(plan['sources']) | set(references) | set(input_paths) | {'tools/project_data_run.sh', 'tools/run_python_project_data.sh'}
    assert json.loads((BASE / 'commands/activation-tree.json').read_bytes()) == dict(argv=[
        'git', 'ls-tree', '-rz', plan['activation'], '--', *sorted(expected_tree)], cwd='.')
    assert (BASE / 'commands/activation-tree-exit.txt').read_text() == '0\n' and not channel('activation-tree', 'stderr')
    cells = channel('activation-tree', 'stdout').split(bytes([0]))
    assert cells.pop() == b''
    bound = set()
    for cell in cells:
        metadata, raw_name = cell.split(bytes([9]), 1)
        mode, kind, oid = metadata.split()
        name = raw_name.decode()
        assert name not in bound and kind == b'blob' and mode in (b'100644', b'100755')
        body = sources[name]
        assert hashlib.sha1(b'blob ' + str(len(body)).encode() + bytes([0]) + body).hexdigest() == oid.decode(), 'activation body'
        assert int(mode, 8) & 0o777 == identities[name]['mode'], 'activation mode'
        bound.add(name)
    assert bound == expected_tree
    controls = {}
    for label in ('binding population', 'binding source site', 'binding target path', 'binding mode', 'binding input output role'):
        altered = copy.deepcopy(matched)
        if label == 'binding population':
            altered.pop()
        elif label == 'binding source site':
            altered[0]['ordinal'] += 1
        elif label == 'binding target path':
            altered[0]['path'] = 'docs/WRONG.json'
        elif label == 'binding mode':
            altered[0]['mode'] = '>'
        else:
            altered[0]['role'] = 'declared-output-write'
        try:
            binding_oracle(altered, matched)
        except AssertionError as error:
            assert str(error) == label
            controls[label] = 'RED'
        else:
            raise AssertionError('binding corruption accepted')
    for label in ('input population', 'input body'):
        altered = dict(sources)
        if label == 'input population':
            altered.pop(baseline)
        else:
            altered[baseline] += bytes([10])
        try:
            validate_inputs(altered, identities)
        except AssertionError as error:
            assert str(error) == label
            controls[label] = 'RED'
        else:
            raise AssertionError('input corruption accepted')
    return dict(summary=dict(result='PASS', source_documents=159, original_sources=145, named_sources_added=14,
        original_open_sites=191, total_open_sites=sum(len(r['sites']) for r in documents.values()),
        bindings=len(matched), input_targets=len(input_paths), output_paths=len(output_paths), unmatched_open_sites=len(unmatched),
        controlled_specimens=len(specimens), actual_changed_source='RED at lexer exit0: intervening assignment removes the first adjacent binding while retaining the output binding',
        retained_inputs=len(sources), reused_artifacts=len(references), controls=controls, limits=plan['limits']),
        bindings=matched, unmatched=unmatched, historical_baseline=role, parent_source_role=parent_role,
        specimens=healthy, changed_source=red_source,
        remaining='All unmatched/non-open/nonadjacent/constructed/helper/library/process/generated/interpolated and full semantic/native routes remain otherIO2/helper2/generated-inline/broader reconciliation; no full input graph.')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--current', action='store_true')
    args = parser.parse_args()
    sources, identities = recover()
    validate_inputs(sources, identities)
    result = report(sources, identities)
    assert result == json.loads((BASE / 'inventory.json').read_bytes()), 'retained variable inventory'
    if args.current:
        for name, body in sources.items():
            path = Path(name)
            assert not path.is_symlink() and path.read_bytes() == body and stat.S_IMODE(path.stat().st_mode) == identities[name]['mode'], 'current input body/mode'
    print(json.dumps(dict(**result['summary'], current_inputs=len(sources) if args.current else 0), indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
