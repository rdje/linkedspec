"""Readonly recovery of named paths and source roles; never execute Perl tests."""
import argparse
import copy
import gzip
import hashlib
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
        assert sha(body) == row['sha256'] and len(body) == row['bytes'], 'input body'
        assert row['mode'] == row['archive_mode'], 'input mode'


def recover():
    identities = json.loads((BASE / 'identities.json').read_bytes())
    sources = {}
    with tarfile.open(BASE / 'inputs.tar.gz') as archive:
        assert len(archive.getmembers()) == len(identities)
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in sources
            sources[member.name] = archive.extractfile(member).read()
            identities[member.name]['archive_mode'] = stat.S_IMODE(member.mode)
    validate(sources, identities)
    return sources, identities


def channel(label, channel):
    return gzip.decompress((BASE / 'commands' / (label + '-' + channel + '.gz')).read_bytes())


def edge_oracle(entries, original, sources):
    assert len(entries) == 14 and len({(e['parent'], e['ordinal']) for e in entries}) == 14, 'include site population'
    assert len({e['target'] for e in entries}) == 14, 'include target population'
    assert [(e['parent'], e['ordinal'], e['location'], e['expression']) for e in entries] == original, 'include site identity'
    for entry in entries:
        target = entry['target']
        expression = entry['expression']
        basename = PurePosixPath(target).name
        assert target == 't/' + basename and ("'" + basename + "'" in expression or "'./" + target + "'" in expression), 'logical target path'
        assert entry['source_sha256'] == sha(sources[entry['parent']]), 'parent source identity'
        lines = sources[entry['parent']].decode().splitlines()
        actual = '\n'.join(lines[entry['location'][0] - 1:])
        assert actual.startswith(expression) or actual.lstrip().startswith(expression), 'source expression'
    return True


def role_oracle(rows):
    assert len(rows) == 15 and len({r['path'] for r in rows}) == 15, 'role population'
    for row in rows:
        name = row['path']
        expected = 'suite-with-caller-plan-guard' if name.endswith('.t') else (
            'nested-child-program' if name.endswith('_cold_probe.pl') else 'included-probe-library')
        assert row['role'] == expected, 'target role'
    return True


def historical_oracle(entries, ledger):
    assert len(ledger) == len(entries) == 11 and [
        (e['parent'], e['target'], e['location'][0], e['expression'].strip()) for e in entries] == [
        (e['parent'], e['target'], e['line'], e['expression'].strip()) for e in ledger], 'historical callable ledger'


def analyze(sources, identities):
    plan = json.loads(sources[str(BASE / 'plan.json')])
    entries = plan['entries']
    parents = sorted({e['parent'] for e in entries})
    targets = sorted({e['target'] for e in entries} | set(plan['context_targets']))
    prior = Path(plan['prior_census'])
    old_request = json.loads(gzip.decompress(sources[str(prior / 'commands/consumers-stdin.gz')]))
    old_output = json.loads(gzip.decompress(sources[str(prior / 'commands/consumers-stdout.gz')]))
    old_sources = {r['path']: r for r in old_request['documents']}
    original = []
    for document in old_output['documents']:
        sites = [s for s in document['sites'] if s.get('word') == 'do' and not s['context_hint'].startswith('inline do block')]
        if sites:
            assert document['path'] in parents
            name = document['path']
            assert old_sources[name]['source'].encode() == sources[name]
            assert document['source_sha256'] == old_sources[name]['sha256'] == sha(sources[name])
            original.extend((name, s['ordinal'], s['location'], s['statement_content']) for s in sites)
    edge_oracle(entries, original, sources)
    assert b'my $repo_root = dirname(dirname(File::Spec->rel2abs(__FILE__)));' in sources['t/callable_codeblock_literal_contract.t']
    old_ledger = json.loads(sources[plan['old_named_ledger']])
    callable_entries = [e for e in entries if e['parent'].endswith('callable_codeblock_literal_contract.t')]
    historical_oracle(callable_entries, old_ledger)
    old_ids = json.loads(sources[plan['old_source_identities']])
    for entry in callable_entries:
        name = entry['target']
        assert old_ids[name]['sha256'] == sha(sources[name]) and old_ids[name]['mode'] == identities[name]['mode'], 'historical target body'
    old_roles = {r['path']: r for r in json.loads(sources[plan['old_roles']])}
    parent_roles = [{k: old_roles[n][k] for k in ('path', 'role', 'route')} for n in parents]
    assert [r['route']['occurrences'] for r in parent_roles] == [2, 2, 1], 'historical direct source selections'
    for label in ('activation-tree', 'targets'):
        assert (BASE / 'commands' / (label + '-exit.txt')).read_text() == '0\n'
        assert channel(label, 'stderr') == b''
    tree = json.loads((BASE / 'commands/activation-tree.json').read_bytes())
    expected_tree = set(sources) - {str(BASE / n) for n in ('prepare_plan.py', 'plan.json', 'capture.py', 'review.py', 'record_review.py')}
    assert tree == dict(argv=['git', 'ls-tree', '-rz', plan['activation'], '--', *sorted(expected_tree)], cwd='.')
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
    assert bound == expected_tree
    argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'PERL5OPT=', 'perl', plan['lexer']]
    assert json.loads((BASE / 'commands/targets.json').read_bytes()) == dict(argv=argv, cwd='.')
    request = json.loads(channel('targets', 'stdin'))
    assert request == dict(ppi_version=plan['ppi_version'], words=plan['words'], documents=[
        dict(path=n, source=sources[n].decode(), sha256=sha(sources[n])) for n in targets]), 'actual target request'
    output = json.loads(channel('targets', 'stdout'))
    assert output['ppi_version'] == plan['ppi_version']
    assert [r['path'] for r in output['documents']] == targets
    rows = []
    for document in output['documents']:
        name = document['path']
        text = sources[name].decode()
        assert document['status'] == 'lexed-roundtrip' and document['roundtrip'] and not document['unknown_tokens']
        assert document['source_sha256'] == sha(sources[name])
        test_more = [i for i in document['includes'] if i['type'] == 'use' and i['module'] == 'Test::More']
        plans = [s for s in document['sites'] if s.get('word') == 'done_testing']
        if name.endswith('.t'):
            assert len(test_more) == len(plans) == 1
            assert plans[0]['statement_content'].strip() == 'done_testing() unless caller;'
            assert text.rstrip().endswith('done_testing() unless caller;\n1;')
            role = 'suite-with-caller-plan-guard'
            detail = 'Test::More imported; assertions remain in source; final plan suppressed when caller is present. Runtime execution not observed.'
        elif name.endswith('_cold_probe.pl'):
            assert not test_more and not plans and 'print JSON::PP->new->canonical->encode' in text
            role, detail = 'nested-child-program', 'Top-level JSON probe source; declared from cold() subprocess only; not launched here.'
        else:
            assert not test_more and not plans and 'unless (caller) {' in text and "eq 'observe'" in text.replace("eq'observe'", "eq 'observe'")
            package = 'ReceiverScalarCopyProbe' if 'receiver_scalar_copy_probe' in name else 'LegacyHashKindProbe'
            assert text.startswith('package ' + package + ';') and 'sub observations' in text and text.rstrip().endswith('1;')
            role, detail = 'included-probe-library', package + '; definitions used by parent; standalone observe JSON path guarded by unless(caller).'
        rows.append(dict(path=name, sha256=sha(sources[name]), role=role, detail=detail,
            test_more=[i['location'] for i in test_more], plan=[s['location'] for s in plans]))
    role_oracle(rows)
    legacy = sources['t/actionir_legacy_hash_kind_probe.pl'].decode()
    assert "my @command=('perl','-Iperl','t/actionir_legacy_hash_kind_cold_probe.pl');" in legacy
    assert "open my $pipe,'-|',@command" in legacy and 'cold=>cold()' in legacy
    scalar = sources['t/actionir_receiver_scalar_copy.t'].decode()
    assert 'die $@ || $! unless defined $legacy_loaded;' in scalar
    assert 'ReceiverScalarCopyProbe::observations()' in scalar and 'LegacyHashKindProbe::observations()' in scalar
    for e in entries:
        if e['target'].endswith('.t'):
            lines = sources[e['parent']].decode().splitlines()
            assert any(line.startswith('subtest ') for line in lines[max(0, e['location'][0] - 5):e['location'][0] - 1]), 'parent subtest scope'
    controls = {}
    def red(label, operation):
        try:
            operation()
        except AssertionError as error:
            assert str(error) == label, (label, str(error))
            controls[label] = 'RED'
        else:
            raise AssertionError('corruption accepted: ' + label)
    for label in ('include site population', 'logical target path', 'historical callable ledger', 'target role', 'input population', 'input body', 'input mode'):
        if label.startswith('include'):
            changed = copy.deepcopy(entries[:-1])
            red(label, lambda: edge_oracle(changed, original, sources))
        elif label == 'logical target path':
            changed = copy.deepcopy(entries)
            changed[0]['target'] = 't/WRONG.t'
            red(label, lambda: edge_oracle(changed, original, sources))
        elif label == 'historical callable ledger':
            red(label, lambda: historical_oracle(callable_entries, old_ledger[:-1]))
        elif label == 'target role':
            changed = copy.deepcopy(rows)
            next(r for r in changed if r['role'] == 'included-probe-library')['role'] = 'suite-with-caller-plan-guard'
            red(label, lambda: role_oracle(changed))
        else:
            bodies, ids = dict(sources), copy.deepcopy(identities)
            victim = 't/actionir_legacy_hash_kind_cold_probe.pl'
            if label == 'input population':
                bodies.pop(victim)
            elif label == 'input body':
                bodies[victim] += b'\n'
            else:
                ids[victim]['mode'] ^= 0o100
            red(label, lambda: validate(bodies, ids))
    duplicate = copy.deepcopy(entries)
    duplicate[-1] = copy.deepcopy(duplicate[0])
    try:
        edge_oracle(duplicate, original, sources)
    except AssertionError as error:
        assert str(error) == 'include site population'
        controls['duplicate include site'] = 'RED'
    else:
        raise AssertionError('duplicate include accepted')
    missing_prior = sorted(n for n in targets if n not in old_ids)
    return dict(summary=dict(result='PASS', include_sites=14, parents=3, logical_targets=14, suites=12,
        probe_libraries=2, nested_child_context=1, ppi_roundtrips=15, old_callable_ledger=11,
        retained_inputs=len(sources), controls=controls, limits=plan['limits']), entries=entries, targets=rows,
        parent_roles=parent_roles, prior_identity_absent=missing_prior,
        nested_process=dict(parent='t/actionir_legacy_hash_kind_probe.pl', function='cold', argv=['perl', '-Iperl', 't/actionir_legacy_hash_kind_cold_probe.pl'],
            scope='Declared source command reached through observations/cold; no actual launch, Perl resolution or native dependency closure.'))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--current', action='store_true')
    args = parser.parse_args()
    sources, identities = recover()
    result = analyze(sources, identities)
    assert result == json.loads((BASE / 'roles.json').read_bytes()), 'retained role report'
    if args.current:
        for name, body in sources.items():
            path = Path(name)
            assert not path.is_symlink() and path.read_bytes() == body and stat.S_IMODE(path.stat().st_mode) == identities[name]['mode'], 'current input'
    print(json.dumps(dict(**result['summary'], current_inputs=len(sources) if args.current else 0), indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
