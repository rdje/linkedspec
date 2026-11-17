"""Readonly source-shape recovery; never execute the inspected Perl programs."""
import argparse
import copy
import gzip
import hashlib
import io
import json
from pathlib import Path
import stat
import tarfile
from collections import Counter

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PRIOR = Path('docs/checkpoints/perl-variable-literal-qualification-2026-11-17')


def sha(body):
    return hashlib.sha256(body).hexdigest()


def checked(name, row):
    path = Path(name)
    assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
    body = path.read_bytes()
    assert len(body) == row['bytes'] and sha(body) == row['sha256'], 'retained input bytes'
    assert stat.S_IMODE(path.stat().st_mode) == row['mode'], 'retained input mode'
    return body


def archive(body, identities):
    result = {}
    with tarfile.open(fileobj=io.BytesIO(body), mode='r:gz') as packed:
        for member in packed:
            assert member.isfile() and member.name not in result
            assert not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            value = packed.extractfile(member).read()
            row = identities[member.name]
            assert (len(value), sha(value), stat.S_IMODE(member.mode)) == (row['bytes'], row['sha256'], row['mode'])
            result[member.name] = (value, row['mode'])
    assert set(result) == set(identities), 'archive population'
    return result


def recover():
    references = json.loads((BASE / 'references.json').read_bytes())
    retained = {name: (checked(name, row), row['mode']) for name, row in references.items()}
    plan = json.loads(retained[str(PRIOR / 'plan.json')][0])
    request = json.loads(gzip.decompress(retained[plan['prior'] + '/commands/consumers-stdin.gz'][0]))
    original_ids = json.loads(retained['docs/checkpoints/perl-consumer-roles-2026-11-16/identities.json'][0])
    sources = {}
    for row in request['documents']:
        body = row['source'].encode()
        assert sha(body) == row['sha256'] == original_ids[row['path']]['sha256']
        sources[row['path']] = (body, original_ids[row['path']]['mode'])
    assert sorted(sources) == plan['original_consumers']
    named = archive(retained[plan['named'] + '/inputs.tar.gz'][0], json.loads(retained[plan['named'] + '/identities.json'][0]))
    for name in plan['named_context']:
        assert name not in sources or sources[name] == named[name]
        sources[name] = named[name]
    assert sorted(sources) == plan['sources']
    frozen = archive((BASE / 'before.tar.gz').read_bytes(), json.loads((BASE / 'before-identities.json').read_bytes()))
    for name, value in frozen.items():
        assert name not in retained or retained[name] == value
        retained[name] = value
        if name.endswith(('.py', '.pl')) and name.startswith(str(BASE) + '/'):
            assert (Path(name).read_bytes(), stat.S_IMODE(Path(name).stat().st_mode)) == value, 'frozen instrument'
    return plan, sources, retained


def oracle(expected, observed):
    if [d['path'] for d in observed['documents']] != ['specimen:' + d['id'] for d in expected]:
        return False
    return all(d['roundtrip'] and not d['unknown_tokens'] and
        [[s['word'], s['role']] for s in d['sites']] == e['expected']
        for e, d in zip(expected, observed['documents']))


def channel(label, suffix):
    return gzip.decompress((BASE / 'commands' / (label + '-' + suffix + '.gz')).read_bytes())


def site_contract(actual, expected):
    assert [d['path'] for d in actual['documents']] == [d['path'] for d in expected['documents']], 'document population'
    for current, old in zip(actual['documents'], expected['documents']):
        assert len(current['sites']) == len(old['sites']), 'site population'
        for site, prior in zip(current['sites'], old['sites']):
            assert (site['ordinal'], site['location'], site['raw'], site['statement']) == (
                prior['ordinal'], prior['location'], prior['raw'], prior['statement']), 'source site'
            assert site['role'] == prior['role'], 'source role'
            assert site.get('mode') == prior.get('mode'), 'open mode'
            assert site.get('operand') == prior.get('operand'), 'open operand'


def report(current=False):
    plan, sources, retained = recover()
    own = {name: value[0] for name, value in retained.items()}
    specimens = json.loads(own[str(BASE / 'specimens.json')])
    changed = specimens[0]['source'].replace('\\$output', '$output', 1)
    assert changed != specimens[0]['source']
    requests = {
        'specimens': [dict(path='specimen:' + r['id'], source=r['source'], sha256=sha(r['source'].encode())) for r in specimens],
        'reference-removed': [dict(path='specimen:' + specimens[0]['id'], source=changed, sha256=sha(changed.encode()))],
        'corpus': [dict(path=n, source=sources[n][0].decode(), sha256=sha(sources[n][0])) for n in plan['sources']],
    }
    observations = {}
    argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'PERL5OPT=', 'perl', str(BASE / 'lexer.pl')]
    for label, documents in requests.items():
        request = json.dumps(dict(ppi_version=plan['ppi_version'], documents=documents), ensure_ascii=False, sort_keys=True).encode()
        command = json.loads((BASE / 'commands' / (label + '.json')).read_bytes())
        assert command == dict(argv=argv, cwd='.', stdin_bytes=len(request), stdin_sha256=sha(request)), 'actual input request'
        assert (BASE / 'commands' / (label + '-exit.txt')).read_text() == '0\n' and not channel(label, 'stderr')
        observed = json.loads(channel(label, 'stdout'))
        assert observed['ppi_version'] == plan['ppi_version']
        assert [d['path'] for d in observed['documents']] == [d['path'] for d in documents]
        assert [d['source_sha256'] for d in observed['documents']] == [d['sha256'] for d in documents]
        assert all(d['roundtrip'] and not d['unknown_tokens'] for d in observed['documents']), 'source roundtrip'
        observations[label] = observed
    assert oracle(specimens, observations['specimens']), 'independent specimen expectations'
    assert not oracle([specimens[0]], observations['reference-removed']), 'actual changed-source RED'
    corpus = observations['corpus']
    documents = {d['path']: d for d in corpus['documents']}
    old = json.loads(gzip.decompress(own[plan['prior'] + '/commands/consumers-stdout.gz']))
    words = {'open', 'sysopen', 'read', 'sysread', 'readline', 'glob', 'opendir', 'readdir', 'readlink', 'pipe'}
    old_sites = 0
    for prior in old['documents']:
        expected = [(s['ordinal'], s['class'], s.get('raw_word', s.get('content')), s['location'])
            for s in prior['sites'] if s.get('word') in words or s['class'] == 'PPI::Token::QuoteLike::Readline']
        actual = [(s['ordinal'], s['class'], s['raw'], s['location']) for s in documents[prior['path']]['sites']]
        assert actual == expected, 'original census population'
        old_sites += len(expected)
    sites = [s for d in corpus['documents'] for s in d['sites']]
    roles = Counter(s['role'] for s in sites)
    non_open = [dict(parent=d['path'], **s) for d in corpus['documents'] for s in d['sites'] if s['word'] != 'open']
    # Independent historical literal qualification supplies the exact literal-site population.
    literal = json.loads(own['docs/checkpoints/perl-literal-open-qualification-2026-11-17/inventory.json'])
    expected_literals = {(s['parent'], s['ordinal']) for s in literal['literal']}
    actual_literals = {(d['path'], s['ordinal']) for d in corpus['documents'] for s in d['sites'] if s['role'].startswith('literal-')}
    assert actual_literals == expected_literals, 'literal sites unchanged'
    counts = Counter(s['word'] for s in sites)
    controls = {}
    for label, mutation in (
        ('document population', lambda x: x['documents'].pop()),
        ('site population', lambda x: next(d for d in x['documents'] if d['sites'])['sites'].pop()),
        ('source site', lambda x: next(s for d in x['documents'] for s in d['sites']).update(ordinal=-1)),
        ('source role', lambda x: next(s for d in x['documents'] for s in d['sites']).update(role='invented-file-read')),
        ('open mode', lambda x: next(s for d in x['documents'] for s in d['sites'] if 'mode' in s).update(mode='wrong')),
        ('open operand', lambda x: next(s for d in x['documents'] for s in d['sites'] if 'operand' in s).update(operand='wrong')),
    ):
        damaged = copy.deepcopy(corpus)
        mutation(damaged)
        try:
            site_contract(damaged, corpus)
        except AssertionError as error:
            assert str(error) == label
            controls[label] = 'RED'
        else:
            raise AssertionError('control survived: ' + label)
    if current:
        for name, (body, mode) in {**retained, **sources}.items():
            assert (Path(name).read_bytes(), stat.S_IMODE(Path(name).stat().st_mode)) == (body, mode), 'current input identity'
    return dict(result='PASS', source_documents=len(sources), sites=len(sites), original_sites=old_sites,
        words=dict(sorted(counts.items())), roles=dict(sorted(roles.items())), literal_sites=len(actual_literals),
        non_open=non_open, specimens=len(specimens), actual_changed_source='RED at lexer exit0: scalar reference removed',
        controls=controls, current_inputs=len({**retained, **sources}) if current else None)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--current', action='store_true')
    args = parser.parse_args()
    result = report(args.current)
    result.pop('non_open')
    print(json.dumps(result, sort_keys=True))
