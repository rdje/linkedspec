"""Recover a bounded PPI census without executing any LinkedSpec test source."""
import argparse
from collections import Counter
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path, PurePosixPath
import stat
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PRIOR = Path('docs/checkpoints/perl-consumer-roles-2026-11-16')


def sha(body):
    return hashlib.sha256(body).hexdigest()


def prior_sources():
    references = json.loads((BASE / 'reused-inputs.json').read_bytes())
    for name, row in references.items():
        path = Path(name)
        assert not path.is_symlink() and sha(path.read_bytes()) == row['sha256']
        assert stat.S_IMODE(path.stat().st_mode) == row['mode']
    spec = importlib.util.spec_from_file_location('original_perl_source_epoch', PRIOR / 'review.py')
    original = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(original)
    recovered = original.recover()
    return ({name: row[0] for name, row in recovered.items()}, {name: row[1] for name, row in recovered.items()})


def preparation():
    identities = json.loads((BASE / 'preparation-identities.json').read_bytes())
    sources = {}
    with tarfile.open(BASE / 'preparation.tar.gz') as archive:
        assert len(archive.getmembers()) == len(identities)
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in sources
            body = archive.extractfile(member).read()
            row = identities[member.name]
            assert len(body) == row['bytes'] and sha(body) == row['sha256'], 'preparation body'
            assert stat.S_IMODE(member.mode) == row['mode'], 'preparation mode'
            sources[member.name] = body
    assert set(sources) == set(identities)
    return sources, identities


def recover():
    extra, identities = preparation()
    plan = json.loads(extra[str(BASE / 'plan.json')])
    all_prior, prior_modes = prior_sources()
    roles = json.loads(extra[plan['prior_roles']])
    assert sorted(row['path'] for row in roles) == plan['consumers'] and len(roles) == 145
    sources = {name: all_prior[name] for name in plan['consumers']}
    assert not set(extra) & set(sources)
    for name, body in sources.items():
        identities[name] = dict(bytes=len(body), sha256=sha(body), mode=prior_modes[name])
    sources.update(extra)
    references = json.loads((BASE / 'reused-inputs.json').read_bytes())
    command = json.loads((BASE / 'commands/activation-tree.json').read_bytes())
    expected = set(plan['consumers']) | set(plan['fixed_inputs']) | set(references)
    assert command == dict(argv=['git', 'ls-tree', '-rz', plan['activation'], '--', *sorted(expected)], cwd='.')
    assert (BASE / 'commands/activation-tree-exit.txt').read_text() == '0\n'
    assert gzip.decompress((BASE / 'commands/activation-tree-stderr.gz').read_bytes()) == b''
    cells = gzip.decompress((BASE / 'commands/activation-tree-stdout.gz').read_bytes()).split(b'\0')
    assert cells.pop() == b''
    bound = set()
    for cell in cells:
        metadata, raw_name = cell.split(b'\t', 1)
        mode, kind, oid = metadata.split()
        name = raw_name.decode()
        assert kind == b'blob' and mode in (b'100644', b'100755') and name not in bound
        body = sources[name] if name in sources else Path(name).read_bytes()
        row = identities[name] if name in identities else references[name]
        assert hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest() == oid.decode(), 'activation body'
        assert (int(mode, 8) & 0o777) == row['mode'], 'activation mode'
        bound.add(name)
    assert bound == expected, 'activation population'
    return sources, identities


def specimen_oracle(specimens, result):
    actual = result['documents']
    assert [row['path'] for row in actual] == ['specimen:' + row['id'] for row in specimens]
    rows = []
    for expected, document in zip(specimens, actual):
        words = Counter(row['word'] for row in document.get('sites', []) if 'word' in row)
        found = dict(word_counts=dict(words), includes=len(document.get('includes', [])),
            heredocs=len(document.get('heredocs', [])), quote_io=sum('word' not in row for row in document.get('sites', [])))
        wanted = {key: expected[key] for key in found}
        healthy = document['status'] == 'lexed-roundtrip' and found == wanted
        rows.append(dict(id=expected['id'], actual=found, expected=wanted, result='PASS' if healthy else 'RED'))
    return dict(result='PASS' if all(row['result'] == 'PASS' for row in rows) else 'RED', cases=rows)


def channel(label, name):
    return gzip.decompress((BASE / 'commands' / (label + '-' + name + '.gz')).read_bytes())


def report(sources, identities):
    plan = json.loads(sources[str(BASE / 'plan.json')])
    specimens = json.loads(sources[str(BASE / 'specimens.json')])
    argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'PERL5OPT=', 'perl', str(BASE / 'lexer.pl')]
    expected_documents = {
        'specimens': [dict(path='specimen:' + row['id'], source=row['source'], sha256=sha(row['source'].encode())) for row in specimens],
        'consumers': [dict(path=name, source=sources[name].decode('utf-8'), sha256=sha(sources[name])) for name in plan['consumers']],
    }
    quoted = next(row for row in specimens if row['id'] == 'quoted-only')
    promoted = quoted['source'] + "open my $added, '<', 'added.json';\n"
    expected_documents['quote-promoted'] = [dict(path='specimen:quoted-only', source=promoted, sha256=sha(promoted.encode()))]
    observations = {}
    for label, documents in expected_documents.items():
        assert json.loads((BASE / 'commands' / (label + '.json')).read_bytes()) == dict(argv=argv, cwd='.')
        assert (BASE / 'commands' / (label + '-exit.txt')).read_text() == '0\n'
        request = json.loads(channel(label, 'stdin'))
        assert request == dict(ppi_version=plan['ppi_version'], words=plan['words'], documents=documents), 'actual consumed request'
        output = json.loads(channel(label, 'stdout'))
        assert output['ppi_version'] == plan['ppi_version']
        assert [row['path'] for row in output['documents']] == [row['path'] for row in documents], 'output population/order'
        assert [row['source_sha256'] for row in output['documents']] == [row['sha256'] for row in documents], 'observed source identity'
        for row in output['documents']:
            if row['status'] == 'constructor-refused':
                continue
            assert sum(row['token_classes'].values()) == row['token_count'], 'token-class population'
            ordinals = [site['ordinal'] for site in row['sites']]
            assert len(ordinals) == len(set(ordinals)) and all(0 <= index < row['token_count'] for index in ordinals), 'site token identity'
        observations[label] = output
    healthy = specimen_oracle(specimens, observations['specimens'])
    assert healthy['result'] == 'PASS'
    promoted_result = specimen_oracle([quoted], observations['quote-promoted'])
    assert promoted_result['result'] == 'RED'
    sentinel = next(row['source'] for row in specimens if row['id'] == 'mixed-sentinel')
    assert channel('compiler-sentinel', 'stdin') == sentinel.encode()
    assert json.loads((BASE / 'commands/compiler-sentinel.json').read_bytes()) == dict(argv=[
        'bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'PERL5OPT=', 'perl', '-c'], cwd='.')
    compiler_exit = int((BASE / 'commands/compiler-sentinel-exit.txt').read_text())
    assert compiler_exit != 0 and b'EXECUTION_SENTINEL' in channel('compiler-sentinel', 'stderr')
    rows = observations['consumers']['documents']
    qualified = [row['path'] for row in rows if row['status'] == 'lexed-roundtrip']
    unresolved = [dict(path=row['path'], status=row['status'], unknown_tokens=row.get('unknown_tokens', []),
        exception=row.get('exception')) for row in rows if row['status'] != 'lexed-roundtrip']
    summaries, io, includes, process, helpers, nested = [], [], [], [], [], []
    totals = Counter()
    for row in rows:
        if row['status'] != 'lexed-roundtrip':
            continue
        name = row['path']
        words = Counter(site['word'] for site in row['sites'] if 'word' in site)
        totals.update(words)
        classes = Counter(site['class'] for site in row['sites'] if 'word' not in site)
        summaries.append(dict(path=name, token_count=row['token_count'], word_sites=dict(sorted(words.items())),
            quote_io_sites=dict(sorted(classes.items())), include_statements=len(row['includes']),
            heredocs=len(row['heredocs']), non_word_mentions=len(row['non_word_mentions']), helper_candidates=len(row['helper_candidates'])))
        if any(words[word] for word in ('open', 'sysopen', 'read', 'sysread', 'readline', 'glob', 'opendir', 'readdir')) or classes.get('PPI::Token::QuoteLike::Readline'):
            io.append(name)
        if any(site.get('word') == 'do' and site['context_hint'] != 'inline do block, not a file-include expression' for site in row['sites']):
            includes.append(name)
        if any(words[word] for word in ('eval', 'system', 'exec', 'fork', 'pipe', 'readpipe')) or any('Command' in key or 'Backtick' in key for key in classes):
            process.append(name)
        if row['helper_candidates']:
            helpers.append(name)
        if row['heredocs'] or row['non_word_mentions']:
            nested.append(name)
    return dict(owner=plan['owner'], activation=plan['activation'], ppi_version=plan['ppi_version'], consumers=plan['consumers'],
        qualified=qualified, needs_qualification=unresolved, summaries=summaries, lexical_word_totals=dict(sorted(totals.items())),
        populations=dict(io_word_or_readline_candidates=io, nonblock_do_candidates=includes,
            eval_or_process_candidates=process, named_helper_candidates=helpers, non_word_or_heredoc_contexts=nested),
        controls=dict(healthy_specimens=healthy, quote_promoted=promoted_result,
            compiler_sentinel=dict(result='RED', actual_exit=compiler_exit,
                distinction='Actual Perl compilation executes BEGIN and rejects the sentinel; PPI lexing the same controlled source succeeds without executing it. No LinkedSpec test source is compiled.')),
        stderr_bytes={label: len(channel(label, 'stderr')) for label in expected_documents},
        limits=plan['limits'] + ' Population lists overlap and are lexical follow-up candidates, never counts of reached runtime IO or resolved target edges. PPI/runtime/library/native/toolchain/outer-first-use/per-read/physical closure remains4.2/SESSION5.')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--current', action='store_true')
    parser.add_argument('--relex', action='store_true')
    args = parser.parse_args()
    sources, identities = recover()
    result = report(sources, identities)
    assert result == json.loads((BASE / 'census.json').read_bytes()), 'retained census'
    if args.current:
        for name, body in sources.items():
            path = Path(name)
            assert path.is_file() and not path.is_symlink() and path.read_bytes() == body, 'current body'
            assert stat.S_IMODE(path.stat().st_mode) == identities[name]['mode'], 'current mode'
    if args.relex:
        assert (BASE / 'lexer.pl').read_bytes() == sources[str(BASE / 'lexer.pl')]
        for label in ('specimens', 'quote-promoted', 'consumers'):
            command = json.loads((BASE / 'commands' / (label + '.json')).read_bytes())
            child = subprocess.run(command['argv'], input=channel(label, 'stdin'), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            assert child.returncode == 0 and child.stdout == channel(label, 'stdout') and child.stderr == channel(label, 'stderr'), 'readonly relex identity'
    print(json.dumps(dict(result='PASS', consumers=len(result['consumers']), qualified=len(result['qualified']),
        needs_qualification=result['needs_qualification'], lexical_word_totals=result['lexical_word_totals'],
        population_counts={key: len(value) for key, value in result['populations'].items()},
        controls=result['controls'], stderr_bytes=result['stderr_bytes'], current_inputs=len(sources) if args.current else 0,
        retained_inputs=len(sources), relex=args.relex, limits=result['limits']), indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
