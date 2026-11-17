"""Readonly bounded literal-open recovery; application source never runs."""
import argparse
import copy
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path, PurePosixPath
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


def sha(body):
    return hashlib.sha256(body).hexdigest()


def validate(sources, identities):
    assert set(sources) == set(identities), 'input population'
    for name, body in sources.items():
        row = identities[name]
        assert len(body) == row['bytes'] and sha(body) == row['sha256'], 'input body'
        assert row['mode'] == row['archive_mode'], 'input mode'


def recover():
    sources, identities = {}, {}
    for label in ('instruments', 'targets'):
        rows = json.loads((BASE / (label + '-identities.json')).read_bytes())
        assert not set(rows) & set(identities)
        with tarfile.open(BASE / (label + '.tar.gz')) as archive:
            assert len(archive.getmembers()) == len(rows)
            for member in archive:
                path = PurePosixPath(member.name)
                assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in sources
                sources[member.name] = archive.extractfile(member).read()
                rows[member.name]['archive_mode'] = stat.S_IMODE(member.mode)
        identities.update(rows)
    plan = json.loads(sources[str(BASE / 'plan.json')])
    prior = Path(plan['prior'])
    old_ids = json.loads(sources[plan['old_identities']])
    request = json.loads(gzip.decompress(sources[str(prior / 'commands/consumers-stdin.gz')]))
    assert len(request['documents']) == len({r['path'] for r in request['documents']}) == 145
    for row in request['documents']:
        name, body = row['path'], row['source'].encode()
        assert name not in sources and row['sha256'] == sha(body) == old_ids[name]['sha256']
        sources[name] = body
        identities[name] = dict(bytes=len(body), sha256=sha(body), mode=old_ids[name]['mode'], archive_mode=old_ids[name]['mode'])
    validate(sources, identities)
    return sources, identities


def channel(label, name):
    return gzip.decompress((BASE / 'commands' / (label + '-' + name + '.gz')).read_bytes())


def edge_oracle(rows, expected):
    assert len(rows) == len(expected) and len({(r['parent'], r['ordinal']) for r in rows}) == len(rows), 'literal site population'
    for row, original in zip(rows, expected):
        assert (row['parent'], row['ordinal'], row['location'], row['expression']) == (
            original['parent'], original['ordinal'], original['location'], original['expression']), 'literal source site'
        assert row['path'] == original['path'] and row['source_path'] == original['source_path'], 'literal target path'
        assert row['mode'] == original['mode'], 'literal mode'
        assert row['role'] == original['role'], 'literal input output role'


def report(sources, identities):
    plan = json.loads(sources[str(BASE / 'plan.json')])
    prior = Path(plan['prior'])
    classifier_path = BASE / 'classify.py'
    assert classifier_path.read_bytes() == sources[str(classifier_path)], 'actual classifier body'
    spec = importlib.util.spec_from_file_location('frozen_literal_classifier', classifier_path)
    classifier = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(classifier)
    output = json.loads(gzip.decompress(sources[str(prior / 'commands/consumers-stdout.gz')]))
    assert output['ppi_version'] == plan['ppi_version'] and len(output['documents']) == 145
    for document in output['documents']:
        name = document['path']
        assert document['status'] == 'lexed-roundtrip' and document['source_sha256'] == sha(sources[name])
        for site in document['sites']:
            if site.get('word') == 'open':
                line = sources[name].decode().splitlines()[site['location'][0] - 1]
                assert 'open' in line, 'original source location'
    matched, remainder = classifier.inventory(output)
    edge_oracle(matched, matched)
    assert len(matched) + len(remainder) == sum(s.get('word') == 'open' for d in output['documents'] for s in d['sites']) == 191
    inputs = sorted({r['path'] for r in matched if r['role'] == 'literal-input-read'})
    outputs = sorted({r['path'] for r in matched if r['role'] == 'declared-output-write'})
    assert not set(inputs) & set(outputs), 'input output disjoint'
    target_ids = json.loads((BASE / 'targets-identities.json').read_bytes())
    assert set(target_ids) == set(inputs), 'literal input custody'
    fixed = {str(prior / n) for n in ('lexer.pl', 'commands/consumers-stdin.gz', 'commands/consumers-stdout.gz')}
    fixed |= {plan['old_identities'], 'tools/project_data_run.sh', 'tools/run_python_project_data.sh'}
    consumers = {d['path'] for d in output['documents']}
    expected_tree = consumers | set(inputs) | fixed
    assert json.loads((BASE / 'commands/activation-tree.json').read_bytes()) == dict(
        argv=['git', 'ls-tree', '-rz', plan['activation'], '--', *sorted(expected_tree)], cwd='.')
    assert (BASE / 'commands/activation-tree-exit.txt').read_text() == '0\n' and not channel('activation-tree', 'stderr')
    cells = channel('activation-tree', 'stdout').split(b'\0')
    assert cells.pop() == b''
    bound = set()
    for cell in cells:
        metadata, raw_name = cell.split(b'\t', 1)
        mode, kind, oid = metadata.split()
        name = raw_name.decode()
        assert name not in bound and kind == b'blob' and mode in (b'100644', b'100755')
        body = sources[name]
        assert hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest() == oid.decode(), 'activation body'
        assert int(mode, 8) & 0o777 == identities[name]['mode'], 'activation mode'
        bound.add(name)
    assert bound == expected_tree, 'activation population'
    specimens = json.loads(sources[str(BASE / 'specimens.json')])
    request = json.loads(channel('specimens', 'stdin'))
    assert request == dict(ppi_version=plan['ppi_version'], words=['open'], documents=[dict(
        path='specimen:' + r['id'], source=r['source'], sha256=sha(r['source'].encode())) for r in specimens])
    argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'PERL5OPT=', 'perl', str(prior / 'lexer.pl')]
    assert json.loads((BASE / 'commands/specimens.json').read_bytes()) == dict(argv=argv, cwd='.')
    assert (BASE / 'commands/specimens-exit.txt').read_text() == '0\n' and not channel('specimens', 'stderr')
    observed = json.loads(channel('specimens', 'stdout'))
    assert observed['ppi_version'] == plan['ppi_version']
    assert [d['path'] for d in observed['documents']] == ['specimen:' + s['id'] for s in specimens]
    specimen_rows = []
    for expected, document in zip(specimens, observed['documents']):
        assert document['status'] == 'lexed-roundtrip' and not document['unknown_tokens']
        assert document['source_sha256'] == sha(expected['source'].encode())
        actual, unresolved = classifier.inventory(dict(documents=[document]))
        reduced = [{k: r[k] for k in ('path', 'mode', 'role')} for r in actual]
        assert reduced == expected['expected'], 'independent specimen oracle'
        assert len(actual) + len(unresolved) == expected['open_words'], 'specimen open population'
        specimen_rows.append(dict(id=expected['id'], literal=reduced, unmatched=len(unresolved), result='PASS'))
    changed_source = specimens[0]['source'].replace("'<:raw'", "'>:raw'", 1)
    assert json.loads(channel('mode-promoted', 'stdin')) == dict(ppi_version=plan['ppi_version'], words=['open'], documents=[dict(
        path='specimen:read-write', source=changed_source, sha256=sha(changed_source.encode()))])
    assert json.loads((BASE / 'commands/mode-promoted.json').read_bytes()) == dict(argv=argv, cwd='.')
    assert (BASE / 'commands/mode-promoted-exit.txt').read_text() == '0\n' and not channel('mode-promoted', 'stderr')
    mode_observed = json.loads(channel('mode-promoted', 'stdout'))
    assert mode_observed['ppi_version'] == plan['ppi_version'] and len(mode_observed['documents']) == 1
    document = mode_observed['documents'][0]
    assert document['path'] == 'specimen:read-write' and document['source_sha256'] == sha(changed_source.encode())
    assert document['status'] == 'lexed-roundtrip' and not document['unknown_tokens']
    alternate, alternate_unmatched = classifier.inventory(mode_observed)
    alternate_rows = [{k: r[k] for k in ('path', 'mode', 'role')} for r in alternate]
    assert len(alternate_rows) == 2 and not alternate_unmatched and all(r['role'] == 'declared-output-write' for r in alternate_rows)
    assert alternate_rows != specimens[0]['expected'], 'actual changed-mode source must reject old read/write oracle'
    controls = {}
    def red(label, operation):
        try:
            operation()
        except AssertionError as error:
            assert str(error) == label, (label, str(error))
            controls[label] = 'RED'
        else:
            raise AssertionError('corruption accepted: ' + label)
    for label in ('literal site population', 'literal source site', 'literal target path', 'literal mode', 'literal input output role'):
        changed = copy.deepcopy(matched)
        if label == 'literal site population':
            changed.pop()
        elif label == 'literal source site':
            changed[0]['ordinal'] += 1
        elif label == 'literal target path':
            changed[0]['path'] = 'tests/WRONG.json'
        elif label == 'literal mode':
            changed[0]['mode'] = '>'
        else:
            next(r for r in changed if r['role'] == 'declared-output-write')['role'] = 'literal-input-read'
        red(label, lambda: edge_oracle(changed, matched))
    victim = inputs[0]
    for label in ('input population', 'input body', 'input mode'):
        bodies, ids = dict(sources), copy.deepcopy(identities)
        if label == 'input population':
            bodies.pop(victim)
        elif label == 'input body':
            bodies[victim] += b'\n'
        else:
            ids[victim]['mode'] ^= 0o100
        red(label, lambda: validate(bodies, ids))
    return dict(summary=dict(result='PASS', consumers=145, open_word_sites=191, literal_sites=len(matched),
        literal_input_sites=sum(r['role'] == 'literal-input-read' for r in matched), input_targets=len(inputs),
        declared_output_sites=sum(r['role'] == 'declared-output-write' for r in matched), output_paths=len(outputs),
        unmatched_open_sites=len(remainder), retained_inputs=len(sources), controlled_specimens=len(specimen_rows),
        controls=controls, actual_mode_control='RED at lexer exit0: changed <:raw to >:raw makes two outputs versus expected read/write',
        limits=plan['limits']), literal=matched, unmatched_open=remainder,
        input_targets=inputs, declared_outputs=outputs, specimens=specimen_rows,
        other_io='Full145 retained; non-open IO vocabulary, variable/scalar/constructed/helper/library/support/generated/interpolated routes remain named follow-ups. No complete direct input graph.')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--current', action='store_true')
    args = parser.parse_args()
    sources, identities = recover()
    result = report(sources, identities)
    assert result == json.loads((BASE / 'inventory.json').read_bytes()), 'retained literal inventory'
    if args.current:
        for name, body in sources.items():
            path = Path(name)
            assert not path.is_symlink() and path.read_bytes() == body and stat.S_IMODE(path.stat().st_mode) == identities[name]['mode'], 'current input'
    print(json.dumps(dict(**result['summary'], current_inputs=len(sources) if args.current else 0), indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
