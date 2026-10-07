"""Grade actual grouped-role RED/GREEN and unchanged default/public consumers."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import importlib.util
import json
import re
import stat
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = str(Path(__file__).resolve()).removesuffix('review.py')
REVISION = '78012b1e78bb114a41f54873f30ca63c421568c8'
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2-'
FIXTURE = 't/actionir_compiler_source_membership.t'
SOURCE = 'perl/LinkedSpec/ActionIR/SourceMembership.pm'
METHOD = 'perl/LinkedSpec/ActionIR/MethodExpr.pm'
PROBE = PREVIOUS + 'cause-probe.pl'
CASES = PREFIX.removeprefix(str(ROOT) + '/') + 'cases.json'
DEFAULT = PREFIX.removeprefix(str(ROOT) + '/') + 'default-probe.pl'
STREAM = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
GROUP = 'callable helper roles preserve grouped-pattern occurrence ownership'
INSERTION = b'''  # Compiler membership opts in to the splitter's exact unquoted {| pipes.
  # Genuine host quotes consume their payload before either pipe is reached.
  # Keep the default structural/operand query's lexical policy unchanged.
  if ($callable_signatures && $char eq '|') {
   if ($in_callable_signature) {
    $in_callable_signature = 0;
    next;
   }
   if ($pos > 0 && substr($text, $pos - 1, 1) eq '{') {
    $in_callable_signature = 1;
    next;
   }
  }
'''
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def decode(block):
    assert block['encoding'] == 'gzip-base64', 'complete channel encoding'
    raw = gzip.decompress(base64.b64decode(block['data'], validate=True))
    assert len(raw) == block['bytes'] and sha(raw) == block['sha256'], 'complete channel identity'
    return raw


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def read(path):
    return json.loads(Path(path).read_bytes())


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    value = importlib.util.module_from_spec(spec); spec.loader.exec_module(value)
    return value


def committed(path):
    return subprocess.check_output(['git', 'show', REVISION + ':' + path], cwd=ROOT)


def original_population():
    entries, excluded = {}, []
    listing = subprocess.check_output(['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT)
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for row in filter(None, listing.split(b'\0')):
            metadata, path = row.split(b'\t', 1)
            mode, kind, oid, size = metadata.split(); path = path.decode()
            if kind != b'blob' or mode not in (b'100644', b'100755'):
                excluded.append({'path': path, 'mode': mode.decode(), 'kind': kind.decode()}); continue
            process.stdin.write(oid + b'\n'); process.stdin.flush()
            assert process.stdout.readline().split() == [oid, b'blob', size]
            raw = process.stdout.read(int(size)); assert process.stdout.read(1) == b'\n'
            entries[path] = {'path': path, 'mode': mode.decode(), 'oid': oid.decode(),
                             'bytes': len(raw), 'sha256': sha(raw)}
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    return entries, excluded


def check_inputs(manifest, epoch, population):
    original, excluded = population
    assert manifest['epoch'] == epoch and manifest['revision'] == REVISION, 'exact immutable epoch/boundary'
    expected = copy.deepcopy(original); overlays = []
    supplies = [(FIXTURE, Path(PREFIX + 'fixture.t')), (CASES, ROOT / CASES), (DEFAULT, ROOT / DEFAULT)]
    if epoch == 'after': supplies += [(SOURCE, ROOT / SOURCE), (METHOD, ROOT / METHOD)]
    for path, supplied in supplies:
        raw = supplied.read_bytes()
        entry = {'path': path, 'mode': '100644', 'oid': None, 'bytes': len(raw), 'sha256': sha(raw),
                 'kind': 'replacement' if path in original else 'added', 'supplier': supplied.relative_to(ROOT).as_posix()}
        assert path not in original or entry['sha256'] != original[path]['sha256'], 'effective declared replacement'
        expected[path] = entry; overlays.append(entry)
    assert manifest['entries'] == sorted(expected.values(), key=lambda e: e['path']), 'exact complete supplied input population'
    assert manifest['overlays'] == overlays and manifest['excluded_metadata'] == excluded, 'sole declared overlays/exclusions'
    assert manifest['regular_git_inputs'] == len(expected), 'complete supplied input count'
    return len(expected)


def check_delta(method, source, fixture):
    old_signature = b'sub _helper_pattern_ranges {\n my ($text) = @_;\n'
    new_signature = b'sub _helper_pattern_ranges {\n my ($text, $callable_signatures) = @_;\n'
    assert method.count(new_signature) == method.count(INSERTION) == 1, 'exact opt-in helper traversal insertion'
    anchor = b' my $len = length($text);\n my $in_callable_signature = 0;\n'
    assert method.count(anchor) == 1, 'exact invocation-local opt-in state'
    inverse = method.replace(new_signature, old_signature, 1).replace(INSERTION, b'', 1)
    inverse = inverse.replace(anchor, b' my $len = length($text);\n', 1)
    assert inverse == committed(METHOD), 'sole MethodExpr opt-in delta'
    after = b'@{LinkedSpec::ActionIR::MethodExpr::_helper_pattern_ranges($source, 1)};'
    before = b'@{LinkedSpec::ActionIR::MethodExpr::_helper_pattern_ranges($source)};'
    assert source.count(after) == 1 and source.replace(after, before, 1) == committed(SOURCE), 'sole compiler helper-role call delta'
    start = fixture.index(("subtest '" + GROUP + "' => sub {\n").encode())
    assert fixture[:start].rstrip() + b'\n\ndone_testing();\n' == committed(FIXTURE), 'original40 compiler groups unchanged'
    assert fixture == Path(PREFIX + 'fixture.t').read_bytes(), 'common authored fixture identity'
    for path in subprocess.check_output(['git', 'ls-files', '-z', '--', 'perl', 't'], cwd=ROOT).decode().split('\0'):
        if not path: continue
        if path not in (METHOD, SOURCE, FIXTURE):
            assert (ROOT / path).read_bytes() == committed(path), 'unchanged original production/test: ' + path
        mode = subprocess.check_output(['git', 'ls-tree', REVISION, '--', path], cwd=ROOT).split()[0]
        assert bool((ROOT / path).stat().st_mode & stat.S_IXUSR) == (mode == b'100755'), 'unchanged Git executable mode'


def compiler_tap(raw, epoch, seed):
    text = raw.decode()
    baseline = json.loads(committed(PREVIOUS + 'observations.json'))
    old = decode(next(r for r in baseline['runs'] if r['kind'] == 'compiler-tap' and r['seed'] == seed)['stdout']).decode()
    names = re.findall(r'^ok (\d+) - (.+)$', old, re.M)
    groups = re.findall(r'^(?:not )?ok (\d+) - (.+)$', text, re.M)
    assert groups == names + [('41', GROUP)], 'complete original ordered groups plus authored regression'
    assert re.findall(r'^1\.\.(\d+)$', text, re.M) == ['41'], 'complete compiler plan'
    prefix, body = text.split('# Subtest: ' + GROUP + '\n', 1)
    assert re.findall(r'^ +(?:ok \d+ - .+|1\.\.\d+)$', prefix, re.M) == re.findall(
        r'^ +(?:ok \d+ - .+|1\.\.\d+)$', old, re.M), 'complete original nested assertion reach'
    rows = read(ROOT / CASES); assert len(rows) == 72, 'authored regression source population'
    assertions = re.findall(r'^    (?:not )?ok (\d+) - (.+)$', body, re.M)
    count = 903 if epoch == 'before' else 789
    assert [int(n) for n, _ in assertions] == list(range(1, count + 1)), 'complete authored assertion reach'
    assert re.findall(r'^    1\.\.(\d+)$', body, re.M) == [str(count)], 'complete authored nested plan'
    failures = re.findall(r'^    not ok \d+ - (.+)$', body, re.M)
    if epoch == 'before':
        bad = ['x,' + name + ':' + str(i) for name in ('y', 'tr', 's', 'q', 'qq', 'qx', 'qr', 'm') for i in (0, 1)]
        bad += [name for name in (r['id'] for r in rows) if name.startswith(('line:', 'quoted-header-prefix:', 'flags:',
            'split:', 'receiver-filter:', 'receiver-split-each:', 'regex-subst:', 'substr:', 'indexed-')) or name == 'all-pattern-data']
        bad_set = set(bad); assert len(bad_set) == 38, 'independent distinguishing source set'
        expected = [r['id'] + ' ' + suffix for r in rows if r['id'] in bad_set for suffix in (
            'retains independently authored compiler helper roles',
            'excludes actual pattern data and preserves genuine calls in order',
            'retains independently authored scalar occurrence authority')]
        assert failures == expected and len(failures) == 114, 'exact original source/role/occurrence RED'
        assert re.findall(r'^not ok \d+ - (.+)$', text, re.M) == [GROUP] and 'Result: FAIL' in text, 'actual original regression-only failure'
    else:
        assert not re.search(r'^\s*not ok ', text, re.M), 'all original and authored nested assertions pass'
        assert 'All tests successful.' in text and 'Result: PASS' in text, 'actual complete compiler GREEN'
    return {'groups': 41, 'source_rows': len(rows), 'assertions': count, 'failed_assertions': len(failures)}


def public(rows, epoch, original_rows):
    old = module('grouped_source_authority', ROOT / (PREVIOUS + 'grouped-review.py'))
    if epoch == 'before':
        old.check_public(rows)
        assert rows == original_rows, 'every original public channel recurs exactly'
        return
    assert len(rows) == len(original_rows) == 6, 'complete six-source public population'
    for row, before in zip(rows, original_rows):
        fixed = row['params'] == 'x,y'
        for key in ('params', 'pattern', 'action', 'source', 'expected', 'ast', 'native', 'errors',
                    'helper_patterns', 'signature_closer', 'pattern_start', 'numeric_slash_discriminator', 'substitution'):
            assert row[key] == before[key], 'unchanged original public channel: ' + key
        origins = copy.deepcopy(before['source_origins'])
        for origin in origins:
            if origin['raw'] == 'set(counter,1)': origin['selected'] = 0
        assert row['source_origins'] == origins, 'original real origins with only pattern-data exclusion'
        metadata = copy.deepcopy(before['metadata'])
        metadata['helper_action_ir_hits']['ASSIGN'] = 1
        metadata['canonical_action_ir_count'] = 3
        assert row['metadata'] == metadata, 'only false assignment/canonical event counters corrected'
        ranges = copy.deepcopy(before['literal_ranges'])
        if fixed:
            start = row['pattern_start']; end = start + len(row['pattern'])
            ranges.append({'start': start, 'end': end, 'text': row['pattern']})
            ranges.sort(key=lambda r: r['start'])
        assert row['literal_ranges'] == ranges, 'sole actual grouped pattern-data range correction'
        assert row['fresh']['value'] == 1 and row['fresh']['exception'] is None, 'original fresh value and error oracle'
        assert row['fresh']['stdout'] == row['fresh']['stderr'] == '', 'quiet independent fresh execution'
        assert row['fresh']['emitted_sha256'] == sha(row['emitted'].encode()), 'actual independently loaded emitted source'
        if not fixed:
            assert row == before, 'every healthy control public channel unchanged'


def tap(raw):
    text = raw.decode(); assert not re.search(r'^\s*not ok ', text, re.M), 'all consumer nested/top assertions pass'
    groups = re.findall(r'^ok (\d+) - (.+)$', text, re.M)
    plans = [int(n) for n in re.findall(r'^1\.\.(\d+)$', text, re.M)]
    assert len(groups) == sum(plans), 'complete consumer plan reach'
    assert 'All tests successful.' in text and 'Result: PASS' in text, 'actual complete consumer success'
    return {'groups': len(groups), 'plans': plans}


def check_report(report, epoch, count, capture, original_public, default_before):
    assert report['complete'] is True and report['revision'] == REVISION and report['epoch'] == epoch, 'complete actual epoch capture'
    assert report['instrument_sha256'] == sha(Path(PREFIX + 'capture.py').read_bytes()), 'actual capture producer'
    assert report['stream_instrument_sha256'] == sha(committed(STREAM)), 'original complete input/channel producer'
    tree = Path(report['input_tree'])
    assert not tree.is_absolute() and '..' not in tree.parts and str(tree).startswith('.linkedspec-data/scratch/compiler-grouped-membership/committed-'), 'portable same-volume immutable tree'
    expected = [('compiler-tap', s) for s in (0, 1, 42)] + [('public', s) for s in (0, 1, 42)] + [('default-query', 0)]
    if epoch == 'after': expected += [('consumers', 0)]
    assert [(r['kind'], r['seed']) for r in report['runs']] == expected, 'complete ordered actual command population'
    result = {'commands': len(expected), 'supplied_inputs': count}
    for run in report['runs']:
        assert run['inputs_before'] == run['inputs_after'] == count, 'unchanged complete supplied inputs'
        stdout, stderr = decode(run['stdout']), decode(run['stderr'])
        if run['kind'] == 'compiler-tap':
            tail = ['prove', '-v', '-Iperl', FIXTURE]
            assert run['exit'] == (1 if epoch == 'before' else 0), 'actual compiler RED/GREEN exit'
            result['compiler'] = compiler_tap(stdout, epoch, run['seed'])
            if epoch == 'after': assert stderr == b'', 'quiet corrected compiler'
        else:
            assert run['exit'] == 0 and stderr == b'', 'actual quiet public/default/consumer completion'
            if run['kind'] == 'public':
                tail = ['perl', '-Iperl', PROBE]
                public(json.loads(stdout), epoch, original_public[run['seed']])
            elif run['kind'] == 'default-query':
                tail = ['perl', '-Iperl', DEFAULT]
                rows = json.loads(stdout); cases = read(ROOT / CASES)
                assert [(r['id'], r['source']) for r in rows] == [(r['id'], r['source']) for r in cases], 'complete original default-query source population'
                assert all(r['default_helper_ranges'] == r['explicit_default_ranges'] for r in rows), 'explicit default option preserves original query'
                if epoch == 'after': assert stdout == default_before, 'every original default query/view/numeric/syntactic channel unchanged'
                result['default_query_sources'] = len(rows)
            else:
                tail = ['prove', '-v', '-Iperl'] + capture.TESTS
                consumers = tap(stdout)
                assert re.findall(r'^(t/\S+\.t) \.*\s*$', stdout.decode(), re.M) == capture.TESTS, 'complete ordered22 consumer files'
                assert len(consumers['plans']) == 22, 'all unchanged consumer plans'
                previous = json.loads(committed(PREVIOUS + 'observations.json'))
                original = decode(previous['runs'][-1]['stdout'])
                old = tap(original); assert consumers['plans'][:16] == old['plans'], 'all original16 consumer plans unchanged'
                old_groups = re.findall(r'^ok (\d+) - (.+)$', original.decode(), re.M)
                assert re.findall(r'^ok (\d+) - (.+)$', stdout.decode(), re.M)[:len(old_groups)] == old_groups, 'original1473 consumer groups/order exact'
                assert consumers['plans'][15] == 1035, 'full original Phase0 reach'
                result['consumers'] = consumers
        assert run['command'] == ['bash', 'tools/project_data_run.sh'] + tail, 'exact actual command routing'
    return result


def main():
    capture = module('grouped_membership_capture', PREFIX + 'capture.py')
    before, after = [read(PREFIX + epoch + '-observations.json') for epoch in ('before', 'after')]
    manifests = {epoch: read(PREFIX + epoch + '-inputs.json') for epoch in ('before', 'after')}
    population = original_population()
    counts = {epoch: check_inputs(manifest, epoch, population) for epoch, manifest in manifests.items()}
    check_delta((ROOT / METHOD).read_bytes(), (ROOT / SOURCE).read_bytes(), (ROOT / FIXTURE).read_bytes())
    original = json.loads(committed(PREVIOUS + 'cause-observations.json'))
    original_public = {r['seed']: json.loads(decode(r['stdout'])) for r in original['runs']}
    default_before = decode(next(r for r in before['runs'] if r['kind'] == 'default-query')['stdout'])
    epochs = {epoch: check_report(report, epoch, counts[epoch], capture, original_public, default_before)
        for epoch, report in (('before', before), ('after', after))}
    controls = []
    for name, mutate in (
        ('incomplete capture', lambda r: r.update(complete=False)),
        ('missing default command', lambda r: r['runs'].pop(6)),
        ('reordered commands', lambda r: r['runs'].reverse()),
        ('lost full input guard', lambda r: r['runs'][0].update(inputs_after=0)),
        ('forged producer', lambda r: r.update(instrument_sha256='0' * 64)),
        ('forged channel', lambda r: r['runs'][0]['stdout'].update(sha256='0' * 64)),
        ('failed corrected command', lambda r: r['runs'][0].update(exit=1)),
        ('lost original compiler assertion', lambda r: r['runs'][0].update(stdout=envelope(re.sub(
            br'(?m)^    ok 225 - .+\n', b'', decode(r['runs'][0]['stdout']), count=1)))),
        ('lost authored grouped assertion', lambda r: r['runs'][0].update(stdout=envelope(re.sub(
            br'(?m)^    ok 789 - .+\n', b'', decode(r['runs'][0]['stdout']), count=1)))),
        ('nested grouped failure', lambda r: r['runs'][0].update(stdout=envelope(decode(r['runs'][0]['stdout']).replace(
            b'    ok 789 - ', b'    not ok 789 - ', 1)))),
        ('lost actual origins', lambda r: change_public(r, 'source_origins', [])),
        ('changed typed AST', lambda r: change_public(r, 'ast', {})),
        ('retained false assignment counter', lambda r: change_public(r, 'metadata', original_public[0][0]['metadata'])),
        ('invented native failure', lambda r: change_public(r, 'native', {'value': None})),
        ('invented fresh failure', lambda r: change_public(r, 'fresh', {'value': None})),
        ('lost default query source', lambda r: r['runs'][6].update(stdout=envelope(b'[]'))),
        ('changed default structural view', lambda r: change_default(r)),
        ('truncated Phase0 reach', lambda r: r['runs'][-1].update(stdout=envelope(decode(r['runs'][-1]['stdout']).replace(b'1..1035', b'1..1034', 1)))),
    ):
        candidate = copy.deepcopy(after); mutate(candidate); assert candidate != after, 'effective evidence corruption'
        try: check_report(candidate, 'after', counts['after'], capture, original_public, default_before)
        except AssertionError as error: controls.append({'name': name, 'observed_red': str(error)})
        else: raise AssertionError('unrejected evidence corruption: ' + name)
    for name, mutate in (
        ('missing supplied input', lambda m: m['entries'].pop()),
        ('forged production input', lambda m: m['entries'][0].update(sha256='0' * 64)),
        ('lost declared overlay', lambda m: m['overlays'].pop()),
    ):
        candidate = copy.deepcopy(manifests['after']); mutate(candidate); assert candidate != manifests['after']
        try: check_inputs(candidate, 'after', population)
        except AssertionError as error: controls.append({'name': name, 'observed_red': str(error)})
        else: raise AssertionError('unrejected input corruption: ' + name)
    result = {'complete': True, 'revision': REVISION, 'controlled_seeds': [0, 1, 42],
        'epochs': epochs, 'public_sources': 6, 'public_source_seed_pairs': 18, 'successful_native_fresh_values': 36,
        'original40_groups_unchanged': True, 'default_query_sources': 72, 'controls': controls,
        'instrument_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'verification.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


def change_public(report, key, value):
    run = report['runs'][3]; rows = json.loads(decode(run['stdout']))
    rows[0][key] = value; run['stdout'] = envelope(json.dumps(rows).encode())


def change_default(report):
    run = report['runs'][6]; rows = json.loads(decode(run['stdout']))
    rows[0]['default_structural_view'] = 'changed structural view'
    run['stdout'] = envelope(json.dumps(rows).encode())


if __name__ == '__main__':
    main()
