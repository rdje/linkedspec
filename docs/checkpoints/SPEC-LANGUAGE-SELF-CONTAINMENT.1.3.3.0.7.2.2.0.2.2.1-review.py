"""Grade the exact signature correction, original RED and complete GREEN inputs."""
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
REVISION = '484fe128f945af9c53d82fe44f6498002dcfd771'
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2-'
FIXTURE = 't/actionir_compiler_source_membership.t'
SOURCE = 'perl/LinkedSpec/ActionIR/SourceMembership.pm'
PROBE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.1-probe.pl'
STREAM = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
GROUP = 'callable signature delimiters preserve original executable return origins'
INSERTION = b'''        # Match the splitter's exact unquoted {| signature delimiters. Host
        # quotes already consume their payload before either pipe is reached.
        # A final parameter named y, q, etc. must not claim the closing pipe.
        if ($char eq '|') {
            if ($in_callable_signature) {
                $in_callable_signature = 0;
                next;
            }
            if ($pos > 0 && substr($source, $pos - 1, 1) eq '{') {
                $in_callable_signature = 1;
                next;
            }
        }
'''


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def decode(block):
    assert block['encoding'] == 'gzip-base64', 'channel encoding'
    raw = gzip.decompress(base64.b64decode(block['data'], validate=True))
    assert len(raw) == block['bytes'] and sha(raw) == block['sha256'], 'complete channel identity'
    return raw


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    return module


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
    assert manifest['epoch'] == epoch and manifest['revision'] == REVISION, 'exact epoch/boundary'
    expected = copy.deepcopy(original); overlays = []
    supplies = [(FIXTURE, Path(PREFIX + 'fixture.t')), (PROBE, ROOT / PROBE)]
    if epoch == 'after':
        supplies.append((SOURCE, ROOT / SOURCE))
    for path, supplied in supplies:
        raw = supplied.read_bytes()
        entry = {'path': path, 'mode': '100644', 'oid': None, 'bytes': len(raw), 'sha256': sha(raw),
                 'kind': 'replacement' if path in original else 'added',
                 'supplier': supplied.relative_to(ROOT).as_posix()}
        assert path not in original or entry['sha256'] != original[path]['sha256'], 'effective declared replacement'
        expected[path] = entry; overlays.append(entry)
    assert manifest['entries'] == sorted(expected.values(), key=lambda e: e['path']), 'exact complete supplied input population'
    assert manifest['overlays'] == overlays and manifest['excluded_metadata'] == excluded, 'sole declared overlays and excluded metadata'
    assert manifest['regular_git_inputs'] == len(expected), 'complete input count'
    return len(expected)


def check_delta(module, fixture):
    state = b'    my $in_callable_signature = 0;\n'
    assert module.count(state) == module.count(INSERTION) == 1, 'exact signature precedence insertion'
    inverse = module.replace(state, b'', 1).replace(INSERTION, b'', 1)
    assert inverse == committed(SOURCE), 'sole production delta'
    start = fixture.index(("subtest '" + GROUP + "' => sub {\n").encode())
    assert fixture[:start] + b'done_testing();\n' == committed(FIXTURE), 'unchanged original compiler fixture'
    assert fixture == Path(PREFIX + 'fixture.t').read_bytes(), 'authored common fixture identity'
    for path in subprocess.check_output(['git', 'ls-files', '-z', '--', 'perl', 't'], cwd=ROOT).decode().split('\0'):
        if path and path not in (SOURCE, FIXTURE):
            assert (ROOT / path).read_bytes() == committed(path), 'unchanged direct production/test: ' + path
    for path in (SOURCE, FIXTURE):
        assert not ((ROOT / path).stat().st_mode & stat.S_IXUSR), 'unchanged Git executable mode'


def compiler_tap(raw, epoch):
    text = raw.decode()
    original = json.loads(committed(PREVIOUS + 'observations.json'))['runs'][0]
    original_text = decode(original['stdout']).decode()
    names = re.findall(r'^ok (\d+) - (.+)$', original_text, re.M)
    groups = re.findall(r'^(?:not )?ok (\d+) - (.+)$', text, re.M)
    assert groups == names + [('40', GROUP)], 'all original ordered groups plus authored group'
    assert re.findall(r'^1\.\.(\d+)$', text, re.M) == ['40'], 'exact full compiler plan'
    failures = re.findall(r'^\s*not ok (\d+) - (.+)$', text, re.M)
    prefix, header = text.split('# Subtest: ' + GROUP + '\n', 1)
    original_nested = re.findall(r'^ +(?:ok \d+ - .+|1\.\.\d+)$', original_text, re.M)
    assert re.findall(r'^ +(?:ok \d+ - .+|1\.\.\d+)$', prefix, re.M) == original_nested, 'complete original nested compiler reach'
    assertions = re.findall(r'^    (?:not )?ok (\d+) - (.+)$', header, re.M)
    expected_assertions = 165 if epoch == 'before' else 225
    assert [int(n) for n, _ in assertions] == list(range(1, expected_assertions + 1)), 'complete authored header assertion reach'
    if epoch == 'before':
        expected = ['x,' + name + ' preserves authored executable returns and excludes literal interiors'
                    for name in ('y', 'tr', 's', 'q', 'qq', 'qx', 'qr', 'm')]
        expected += [name + ' preserves authored executable returns and excludes literal interiors'
                     for name in ('quoted body data', 'pattern body data')]
        assert [name for _, name in failures] == expected + [GROUP], 'distinguishing ten original assertion failures'
        assert '    1..165\n' in text and 'Result: FAIL' in text, 'complete original nested RED reach'
    else:
        assert not failures and '    1..225\n' in text, 'all authored source/reference assertions pass'
        assert 'All tests successful.' in text and 'Result: PASS' in text, 'actual full compiler success'
    return {'groups': 40, 'header_rows': 27, 'header_assertions': 165 if epoch == 'before' else 225,
            'failed_assertions': len(failures) - 1 if epoch == 'before' else 0}


def public(rows, epoch, previous):
    if epoch == 'before':
        previous.check(rows)
        return
    assert [r['params'] for r in rows] == ['x,y', 'x,z', 'x,...y'], 'original public source population'
    for row, names, rest in zip(rows, [['x', 'y'], ['x', 'z'], ['x']], [None, None, 'y']):
        action = 'cb={|' + row['params'] + '| return(x) }; return(cb("ok","unused"))'
        assert row['action'] == action and row['source'] == 'Top:: I { ' + action + ' }', 'original public source'
        assert row['expected'] == 'ok' and row['errors'] == {}, 'public error channels'
        block = row['ast']; literal = block['statements'][0]['expr']['value']
        assert block['kind'] == 'action_block' and block['source'] == action and len(block['statements']) == 2, 'original block AST'
        assert literal['kind'] == 'codeblock_literal' and literal['body_source'] == ' return(x) ', 'original inert body'
        assert literal['signature']['positional_params'] == names and literal['signature']['rest_param'] == rest, 'original typed signature'
        assert row['source_origins'], 'actual producer origins'
        for origin in row['source_origins']:
            span = origin['span']
            assert action[span['start']:span['end']] == origin['raw'], 'original exact source authority'
            assert origin['selected'] == 1, 'real callable events remain selected'
        assert [o['raw'] for o in row['source_origins']] == [
            'return(x)', 'return(cb("ok","unused"))', 'cb={|' + row['params'] + '| return(x) }'], 'real event family/occurrence order'
        assert row['literal_ranges'] == [{'start': action.index('"ok"'), 'end': action.index('"ok"') + 4, 'text': '"ok"'},
                                        {'start': action.index('"unused"'), 'end': action.index('"unused"') + 8, 'text': '"unused"'}], 'only real quoted data ranges'
        assert row['native']['value'] == row['fresh']['value'] == 'ok', 'authored native/fresh value oracle'
        assert row['native']['context_error'] is None and row['fresh']['exception'] is None, 'native/fresh errors absent'
        assert row['native']['stdout'] == row['native']['stderr'] == row['fresh']['stdout'] == row['fresh']['stderr'] == '', 'quiet public routes'
        assert row['fresh']['emitted_sha256'] == sha(row['emitted'].encode()), 'actual freshly loaded generated source'
        assert row['dump'] and 'LinkedSpec::CodeblockRuntime::invoke' in row['substitution'], 'real public lowering'


def check_report(report, epoch, count, capture, previous):
    assert report['complete'] is True and report['revision'] == REVISION and report['epoch'] == epoch, 'complete epoch capture'
    assert report['instrument_sha256'] == sha(Path(PREFIX + 'capture.py').read_bytes()), 'actual capture producer'
    assert report['stream_instrument_sha256'] == sha(committed(STREAM)), 'original stream producer'
    tree = Path(report['input_tree'])
    assert not tree.is_absolute() and '..' not in tree.parts and str(tree).startswith('.linkedspec-data/scratch/compiler-signature-membership/committed-'), 'portable same-volume input tree'
    population = [('compiler-tap', s) for s in (0, 1, 42)] + [('public', s) for s in (0, 1, 42)]
    population += [('consumers' if epoch == 'after' else 'original-callable', 0)]
    assert [(r['kind'], r['seed']) for r in report['runs']] == population, 'complete ordered command population'
    result = {'commands': len(population), 'controlled_seeds': [0, 1, 42]}
    for run in report['runs']:
        assert run['inputs_before'] == run['inputs_after'] == count, 'complete unchanged input guards'
        stdout, stderr = decode(run['stdout']), decode(run['stderr'])
        if run['kind'] == 'compiler-tap':
            tail = ['prove', '-v', '-Iperl', FIXTURE]
            assert run['exit'] == (1 if epoch == 'before' else 0), 'actual compiler RED/GREEN exit'
            result['compiler'] = compiler_tap(stdout, epoch)
            if epoch == 'after': assert stderr == b'', 'quiet corrected compiler'
        elif run['kind'] == 'public':
            tail = ['perl', '-Iperl', PROBE]
            assert run['exit'] == 0 and stderr == b'', 'complete public observer'
            public(json.loads(stdout), epoch, previous)
        elif epoch == 'before':
            tail = ['prove', '-v', '-Iperl', 't/callable_codeblock_literal_contract.t']
            text = stdout.decode()
            assert run['exit'] == 1 and 'Non-zero exit status: 255' in text and 'No plan found' in text, 'actual original callable execution abort'
            assert 'ok 3 - x,y generated source loads' in text and 'x,y native invocation returns its first parameter' in text, 'loaded generated execution fails after native RED'
            assert 'just after 4' in stderr.decode(), 'complete original callable failed reach'
        else:
            tail = ['prove', '-v', '-Iperl'] + capture.TESTS
            assert run['exit'] == 0 and stderr == b'', 'quiet complete original consumers'
            text = stdout.decode()
            assert not re.search(r'^\s*not ok ', text, re.M) and 'All tests successful.' in text and 'Result: PASS' in text, 'all original consumer assertions pass'
            assert re.findall(r'^(t/\S+\.t) \.*\s*$', text, re.M) == capture.TESTS, 'exact ordered original consumers'
            old = json.loads(committed(PREVIOUS + 'observations.json'))['runs'][-1]
            old_text = decode(old['stdout']).decode()
            old_groups = re.findall(r'^ok (\d+) - (.+)$', old_text, re.M)
            old_plans = [int(n) for n in re.findall(r'^1\.\.(\d+)$', old_text, re.M)]
            groups = re.findall(r'^ok (\d+) - (.+)$', text, re.M)
            plans = [int(n) for n in re.findall(r'^1\.\.(\d+)$', text, re.M)]
            callable_names = re.findall(r"^subtest '([^']+)' => sub", committed('t/callable_codeblock_literal_contract.t').decode(), re.M)
            split = sum(old_plans[:-1]); callable_groups = [(str(i), n) for i, n in enumerate(callable_names, 1)]
            assert groups == old_groups[:split] + callable_groups + old_groups[split:], 'unchanged original consumer group order'
            assert plans == old_plans[:-1] + [len(callable_names)] + old_plans[-1:] and len(groups) == sum(plans), 'complete original consumer plans'
            result['consumers'] = {'files': len(plans), 'groups': len(groups), 'plans': plans}
        assert run['command'] == ['bash', 'tools/project_data_run.sh'] + tail, 'exact command routing'
    return result


def change_public(report, key, value):
    run = report['runs'][3]; rows = json.loads(decode(run['stdout']))
    rows[0][key] = value; run['stdout'] = envelope(json.dumps(rows).encode())


def main():
    capture = load_module('signature_capture', str(Path(PREFIX + 'capture.py').relative_to(ROOT)))
    previous = load_module('original_callable_review', PREVIOUS + 'callable-review.py')
    population = original_population()
    check_delta((ROOT / SOURCE).read_bytes(), (ROOT / FIXTURE).read_bytes())
    reports, manifests, summary = {}, {}, {'complete': True, 'revision': REVISION, 'epochs': {}, 'controls': []}
    for epoch in ('before', 'after'):
        manifest = json.loads(Path(PREFIX + epoch + '-inputs.json').read_bytes())
        report = json.loads(Path(PREFIX + epoch + '-observations.json').read_bytes())
        count = check_inputs(manifest, epoch, population)
        summary['epochs'][epoch] = dict(check_report(report, epoch, count, capture, previous), supplied_inputs=count)
        reports[epoch], manifests[epoch] = report, manifest
    for before, after in zip(reports['before']['runs'][3:6], reports['after']['runs'][3:6]):
        for old, new in zip(json.loads(decode(before['stdout'])), json.loads(decode(after['stdout']))):
            assert old['ast'] == new['ast'] and old['action'] == new['action'] and old['source'] == new['source'], 'exact unchanged original public AST/source'
            if old['params'] != 'x,y': assert old == new, 'all healthy original public channels unchanged'
    after = reports['after']; count = summary['epochs']['after']['supplied_inputs']
    for name, mutate in (
        ('incomplete capture', lambda r: r.update(complete=False)),
        ('missing command', lambda r: r['runs'].pop()),
        ('reordered commands', lambda r: r['runs'].reverse()),
        ('forged producer', lambda r: r.update(instrument_sha256='0' * 64)),
        ('lost input guard', lambda r: r['runs'][0].update(inputs_after=0)),
        ('nonzero compiler', lambda r: r['runs'][0].update(exit=1)),
        ('forged channel', lambda r: r['runs'][0]['stdout'].update(sha256='0' * 64)),
        ('nested failure', lambda r: r['runs'][0].update(stdout=envelope(decode(r['runs'][0]['stdout']).replace(b'    ok 1 - ', b'    not ok 1 - ', 1)))),
        ('lost header assertions', lambda r: r['runs'][0].update(stdout=envelope(decode(r['runs'][0]['stdout']).replace(b'    1..225\n', b'    1..224\n')))),
        ('truncated header assertion', lambda r: r['runs'][0].update(stdout=envelope(re.sub(
            br'(?m)^    ok 225 - .+\n', b'', decode(r['runs'][0]['stdout']), count=1)))),
        ('forged source', lambda r: change_public(r, 'action', 'changed')),
        ('forged AST', lambda r: change_public(r, 'ast', dict(
            json.loads(decode(r['runs'][3]['stdout']))[0]['ast'], kind='changed AST'))),
        ('lost actual origins', lambda r: change_public(r, 'source_origins', [])),
        ('forged value', lambda r: change_public(r, 'native', {'value': 'forged'})),
        ('forged fresh value', lambda r: change_public(r, 'fresh', {'value': 'forged'})),
        ('signature still masked', lambda r: change_public(r, 'literal_ranges', [{'start': 8, 'end': 48, 'text': 'forged'}])),
        ('lost Phase0 plan', lambda r: r['runs'][-1].update(stdout=envelope(decode(r['runs'][-1]['stdout']).replace(b'\n1..1035\n', b'\n1..1034\n')))),
    ):
        changed = copy.deepcopy(after); mutate(changed); assert changed != after, 'effective observation corruption'
        try: check_report(changed, 'after', count, capture, previous)
        except AssertionError as error: summary['controls'].append({'name': name, 'observed_red': str(error)})
        else: raise AssertionError('unrejected observation: ' + name)
    for name, mutate in (
        ('lost supplied input', lambda m: m['entries'].pop()),
        ('forged production hash', lambda m: next(e for e in m['entries'] if e['path'] == SOURCE).update(sha256='0' * 64)),
        ('unreported overlay', lambda m: m['overlays'].pop()),
    ):
        changed = copy.deepcopy(manifests['after']); mutate(changed); assert changed != manifests['after']
        try: check_inputs(changed, 'after', population)
        except AssertionError as error: summary['controls'].append({'name': name, 'observed_red': str(error)})
        else: raise AssertionError('unrejected inputs: ' + name)
    changed = (ROOT / SOURCE).read_bytes() + b'# unrelated production change\n'
    try: check_delta(changed, (ROOT / FIXTURE).read_bytes())
    except AssertionError as error: summary['controls'].append({'name': 'unrelated production delta', 'observed_red': str(error)})
    else: raise AssertionError('unrejected production delta')
    summary.update(public_source_seed_pairs=9, fresh_and_native_values=18,
                   original_value_red_pairs=3, instrument_sha256=sha(Path(__file__).read_bytes()))
    Path(PREFIX + 'verification.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary, indent=2))


if __name__ == '__main__':
    main()
