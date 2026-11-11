"""Independent historical reader; no SDK, capture, or fixture-writer imports."""
import copy
import gzip
import hashlib
import io
import json
from pathlib import Path
import re
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(ROOT)
OLD = 'docs/checkpoints/array-transform-callable-perl-2026-11-11'
ACTIVATION = '09bad87aa19304486f836cf6dff44b499a8ea5ec'
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PRIVATE = '.linkedspec-data/scratch/callable-transform-result-perl/owner.pm'
NORMAL = 't/array_transform_callable_result_guard_composition.t'
FIXTURE = 'tests/fixtures/array_transform_callable_result_guard_perl_cases.json'
COMPAT = {'initial_number_composed', 'initial_null_composed', 'initial_hash_composed'}
READY = dict(canonical_action_ir_fallback_count=0, language_agnostic_action_ir_ready=1,
    raw_perl_dependency_count=0, unresolved_helper_count=0, unresolved_helpers=[])
PREFIX = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=']
PHASES = ('intake', 'before', 'after', 'after_qualified', 'private_old', 'private_current')
DIRECT = ('array_transform_result_guard_composition', 'array_pipeline_callable_result_guard_composition')
DIRECT_FIXTURES = ('tests/fixtures/array_transform_result_guard_cases.json',
    'tests/fixtures/array_transform_result_guard_perl_profiles.json',
    'tests/fixtures/array_transform_result_guard_perl_prefix_profiles.json',
    'tests/fixtures/array_pipeline_callable_result_guard_perl_cases.json')


def need(condition, reason):
    if not condition:
        raise AssertionError(reason)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def equal(left, right):
    return wire(left) == wire(right)


def normalized(value):
    if isinstance(value, dict):
        return {key: normalized(item) for key, item in value.items()}
    if isinstance(value, list):
        return [normalized(item) for item in value]
    return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value) if isinstance(value, str) else value


def projection(row):
    return normalized({key: item for key, item in row.items() if key not in ('substitution', 'module_input', 'handler_input')})


def read_archive(path, identities):
    images = {}
    with tarfile.open(path) as archive:
        for member in archive:
            name = member.name
            need(member.isfile() and name not in images and not Path(name).is_absolute() and '..' not in Path(name).parts, 'archive member')
            raw = archive.extractfile(member).read()
            row = identities[name]
            need(len(raw) == row['bytes'] and sha(raw) == row['sha256'] and member.mode & 0o777 == row['mode'], 'archive identity')
            images[name] = (raw, member.mode & 0o777)
    need(set(images) == set(identities), 'archive membership')
    return images


class History:
    def __init__(self):
        paths = ['perl', 'specs', OLD, 'tools/project_data_run.sh', 'tools/project_data_env.sh',
            'tools/run_python_project_data.sh', 'docs/checkpoints/array-pipeline-callable-result-perl-2026-11-11/direct_runner_qualified.pl']
        paths += ['t/' + name + '.t' for name in DIRECT] + list(DIRECT_FIXTURES)
        tree = subprocess.check_output(['git', 'ls-tree', '-r', '-z', ACTIVATION, '--'] + paths)
        entries = []
        for item in tree.split(b'\0'):
            if not item:
                continue
            header, name = item.split(b'\t', 1)
            mode, kind, oid = header.split()
            need(kind == b'blob' and mode in (b'100644', b'100755'), 'historical regular file')
            entries.append((name.decode(), int(mode, 8) & 0o777, oid.decode()))
        objects = list(dict.fromkeys(item[2] for item in entries))
        result = subprocess.run(['git', 'cat-file', '--batch'], input=('\n'.join(objects) + '\n').encode(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        need(result.returncode == 0 and not result.stderr, 'historical object recovery')
        blobs, offset = {}, 0
        for oid in objects:
            end = result.stdout.index(b'\n', offset)
            returned, kind, size = result.stdout[offset:end].split()
            need(returned.decode() == oid and kind == b'blob', 'historical object identity')
            offset = end + 1
            blobs[oid] = result.stdout[offset:offset + int(size)]
            offset += int(size)
            need(result.stdout[offset:offset + 1] == b'\n', 'historical object framing')
            offset += 1
        need(offset == len(result.stdout), 'historical object tail')
        self.files = {name: (blobs[oid], mode) for name, mode, oid in entries}
        self.sdk = {name: value for name, value in self.files.items() if name.startswith(('perl/', 'specs/'))}

    def json(self, name):
        return json.loads(self.files[name][0])


def expected_owner(history):
    old = history.files[OWNER][0].decode()
    start = '''  my $ordinary_array_transform_result_chain = (_ordinary_array_transform_result_call($receiver, 0)
    || (@$calls > 1 && ($receiver->{kind} // '') ne 'raw_perl'
     && !(($receiver->{kind} // '') eq 'call'
       && _user_function_definition_for_name($deps, $receiver->{name}))'''
    changed = '''  # Valid function sources reuse the terminal transform producer; wrong fixed
  # or variadic signatures keep their existing unresolved rejection path.
  my $array_transform_receiver_signature_valid = 1;
  if (@$calls > 1 && _ordinary_array_transform_result_call($calls->[0], 1)
      && ($receiver->{kind} // '') eq 'call') {
   my $definition = _user_function_definition_for_name($deps, $receiver->{name});
   if (ref($definition) eq 'HASH') {
    my $signature = _user_function_call_signature($definition);
    my $args = $receiver->{args} || [];
    $array_transform_receiver_signature_valid = ref($signature) eq 'HASH' && ref($args) eq 'ARRAY'
     && @$args >= $signature->{min_arity}
     && (!defined($signature->{max_arity}) || @$args <= $signature->{max_arity});
   }
  }
  my $ordinary_array_transform_result_chain = (_ordinary_array_transform_result_call($receiver, 0)
    || (@$calls > 1 && ($receiver->{kind} // '') ne 'raw_perl'
     && $array_transform_receiver_signature_valid'''
    need(old.count(start) == 1, 'bounded owner origin')
    return old.replace(start, changed).encode()


def sdk_origin(images, history, current):
    names = {name for name in images if name.startswith(('perl/', 'specs/'))}
    need(names == set(history.sdk), 'SDK membership')
    for name in names:
        expected = (current, history.sdk[name][1]) if name == OWNER else history.sdk[name]
        need(images[name][0] == expected[0], 'SDK origin')
        need(bool(images[name][1] & 0o111) == bool(expected[1] & 0o111), 'SDK executable class')


def products(rows, inputs, cases, phase):
    need(set(rows) == set(inputs) == set(cases), 'question population')
    for key, row in rows.items():
        need(inputs[key]['source'] == cases[key]['source'], 'authored source')
        for field, kind in (('module_input', 'emitted'), ('handler_input', 'handler')):
            artifact = row[field]
            need(isinstance(artifact, dict), 'artifact presence')
            path = Path(artifact['path'])
            need(not path.is_absolute() and '..' not in path.parts and path.parent == REL / phase, 'artifact path')
            need(path.is_file() and not path.is_symlink() and path.resolve().is_relative_to(BASE), 'artifact ownership')
            raw = gzip.decompress(path.read_bytes())
            need(len(raw) == artifact['bytes'] and sha(raw) == artifact['sha256'], 'artifact bytes')
            need(inputs[key][kind] == (len(raw), sha(raw)), 'artifact input binding')


def read_epoch(phase, cases, history, current):
    directory = BASE / phase
    ids = json.loads((directory / 'input-identities.json').read_bytes())
    images = read_archive(directory / 'inputs-before-sdk.tar.gz', ids)
    sdk_origin(images, history, history.files[OWNER][0] if phase in ('intake', 'before') else current)
    need((directory / 'activation.txt').read_text().strip() == ACTIVATION, 'activation')
    for tag in ('version', 'run'):
        command = json.loads((directory / (tag + '-command.json')).read_bytes())
        expected = PREFIX + ['perl', '-V']
        if tag == 'run':
            if phase == 'intake':
                expected = PREFIX + ['perl', '-Iperl', str(REL / 'observer.pl'), str(REL / 'cases.json'), str(REL / phase)]
            else:
                expected = PREFIX + ['LINKEDSPEC_CALLABLE_TRANSFORM_RESULT_CAPTURE=' + str(REL / phase), 'perl', '-Iperl']
                if phase.startswith('private_'):
                    expected += [str(REL / 'private_runner.pl'), PRIVATE]
                expected += [NORMAL]
        need(command == dict(argv=expected, cwd='.'), 'physical command')
        code = int((directory / (tag + '-exit.txt')).read_text())
        expected_code = {'before': 43, 'after': 3, 'private_old': 46}.get(phase, 0) if tag == 'run' else 0
        need(code == expected_code, 'actual exit')
    rows, inputs = {}, {}
    channel = 'stdout' if phase == 'intake' else 'stderr'
    with gzip.open(directory / ('run-' + channel + '.log.gz'), 'rt') as stream:
        for line in stream:
            if phase == 'intake':
                row = re.fullmatch(r'ARRAY_TRANSFORM_CALLABLE_PERL_PERL (\w+) (.*)\n?', line)
                source = re.fullmatch(r'ARRAY_TRANSFORM_CALLABLE_PERL_INPUT (\w+) (.*)\n?', line)
            else:
                row = re.fullmatch(r'\s*# CALLABLE_ARRAY_TRANSFORM_RESULT_ROW (\w+) (.*)\n?', line)
                source = re.fullmatch(r'CALLABLE_ARRAY_TRANSFORM_RESULT_INPUT (\w+) (.*)\n?', line)
            if row:
                need(row[1] not in rows, 'duplicate row')
                rows[row[1]] = json.loads(row[2])
            if source:
                need(source[1] not in inputs, 'duplicate input')
                value = json.loads(source[2])
                inputs[source[1]] = dict(source=value['source'], **{kind: (len(value[kind].encode()), sha(value[kind].encode())) for kind in ('emitted', 'handler')})
    products(rows, inputs, cases, phase)
    if phase != 'intake':
        tap = gzip.decompress((directory / 'run-stdout.log.gz').read_bytes()).decode()
        need(re.search(r'^1\.\.312$', tap, re.M) is not None, 'complete TAP reach')
        failed = set(re.findall(r'^not ok \d+ - (\w+)', tap, re.M))
    else:
        failed = set()
    receipt = None
    if phase.startswith('private_'):
        raw = gzip.decompress((directory / 'run-stderr.log.gz').read_bytes()).decode()
        records = re.findall(r'^CALLABLE_ARRAY_TRANSFORM_RESULT_OWNER (.*)$', raw, re.M)
        need(len(records) == 1, 'loaded owner receipt')
        receipt = json.loads(records[0])
        owner = history.files[OWNER][0] if phase == 'private_old' else current
        declared = json.loads(images[str(REL / 'owner-images.json')][0])['images']['old' if phase == 'private_old' else 'current']
        need(images[PRIVATE] == (owner, declared['mode']), 'private source input')
        owner_receipt(receipt, owner)
    return dict(rows=rows, inputs=inputs, images=images, failed=failed, receipt=receipt)


def owner_receipt(receipt, body):
    need(receipt == dict(path=PRIVATE, bytes=len(body), sha256=sha(body)), 'loaded owner receipt')


def expected_cases(history):
    original = history.json(OLD + '/cases.json') + history.json(OLD + '/terminal-cases.json')
    current = json.loads((BASE / 'cases.json').read_bytes())
    need(equal(current[:288], original), 'original questions')
    extra = current[288:]
    expected = {'take': (['b'], 'SN'), 'take_last': (['c'], 'SN'), 'drop_front': (['a', 'c'], 'SN'),
        'drop_back': (['b', 'a'], 'SN'), 'slice': (['a'], 'SNC'), 'sorted': (['a', 'b', 'c'], 'S'),
        'reversed': (['c', 'a', 'b'], 'S'), 'concat_arrays': (['b', 'a', 'c', 'd'], 'ST')}
    need(len(extra) == 24 and len({case['id'] for case in current}) == 312, 'question population')
    seen = set()
    for case in extra:
        method, form = case['method'], case['form']
        need(method in expected and form in ('free_terminal', 'receiver_terminal', 'receiver_composed'), 'positive producer role')
        need((method, form) not in seen, 'positive producer population')
        seen.add((method, form))
        value, order = expected[method]
        need(equal(case['expected'], [None if form == 'receiver_composed' else value, order]), 'positive producer intent')
        source = 'supply({order=cat(order,"S");["b","a","c"]})'
        count = '{order=cat(order,"N");1}'
        args = [] if method in ('sorted', 'reversed') else [count]
        if method == 'slice':
            args.append('{order=cat(order,"C");1}')
        if method == 'concat_arrays':
            args = ['{order=cat(order,"T");["d"]}']
        expression = method + '(' + ','.join([source] + args) + ')' if form == 'free_terminal' else source + '.' + method + '(' + ','.join(args) + ')'
        if form == 'receiver_composed':
            expression += '.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).copy().and({order=cat(order,"D");true}).with(){order=cat(order,"W");return("ran")}'
        body = 'order="";out=' + expression + ';return([out,order])'
        need(case['body'] == body and case['source'] == 'fn supply(seed) {return(seed)}\n\nValue:: I {' + body + '}\n', 'positive source origin')
        need(case['id'] == 'positive_' + method + '_' + form and case['rule'] == 'Value' and case['input'] == 'x', 'positive source identity')
    return {case['id']: case for case in current}


def target_intents(history, cases):
    policy = history.json(OLD + '/policy-contract.json')
    targets = copy.deepcopy(policy['targets'])
    for key, case in cases.items():
        if key.startswith('positive_') and case['form'] == 'receiver_composed':
            targets[key] = dict(kind='value', value=case['expected'])
    need(len(targets) == 43 and len(policy['targets']) == 35, 'supported target population')
    return policy, targets


def desired_rows(baseline, targets):
    expected = {key: projection(row) for key, row in baseline.items()}
    for key in COMPAT:
        need(expected[key]['metadata'] == dict(READY, language_agnostic_action_ir_ready=0, unresolved_helper_count=1, unresolved_helpers=['with']), 'compatibility origin')
        expected[key]['metadata'] = READY
    for key, intent in targets.items():
        if intent['kind'] == 'needed-error':
            oracle = key + '_terminal_probe' if key.startswith('own_') else key.replace('_composed', '_terminal')
            expected[key] = projection(baseline[oracle])
            expected[key]['metadata'] = READY
        else:
            expected[key] = dict(metadata=READY, substitution_error=baseline[key]['substitution_error'],
                descriptor_error=None, emission_error=None, build_error=None, native_callable=1,
                loaded=1, load_error=None, native=intent['value'], fresh=intent['value'],
                native_error=None, fresh_error=None, native_cursor=0, fresh_cursor=0, warnings=[])
    return expected


def semantics(rows, expected, targets):
    need(set(rows) == set(expected), 'question population')
    for key, row in rows.items():
        if key in targets:
            need(equal(row['metadata'], READY), 'target readiness')
            reason = 'complete needed error' if targets[key]['kind'] == 'needed-error' else 'target value/effects'
        else:
            reason = 'compatibility payload/readiness' if key in COMPAT else 'protected observation'
        need(equal(projection(row), expected[key]), reason)


def direct(history, current):
    directory = BASE / 'direct'
    ids = json.loads((directory / 'input-identities.json').read_bytes())
    images = read_archive(directory / 'inputs-before-sdk.tar.gz', ids)
    sdk_origin(images, history, current)
    required = set(DIRECT_FIXTURES) | {'t/' + name + '.t' for name in DIRECT} | {NORMAL, FIXTURE}
    need(required <= set(images), 'direct fixture closure')
    for name in required - {NORMAL, FIXTURE}:
        need(images[name][0] == history.files[name][0], 'direct original consumer')
        need(bool(images[name][1] & 0o111) == bool(history.files[name][1] & 0o111), 'direct executable class')
    template = history.files['docs/checkpoints/array-pipeline-callable-result-perl-2026-11-11/direct_runner_qualified.pl'][0].decode()
    replacements = [
        ("($test eq 't/array_pipeline_value_contract.t' || $test eq 't/variadic_user_function_contract.t' || $test eq 't/array_pipeline_result_guard_composition.t' || $test eq 't/array_pipeline_callable_arity.t')", "($test eq 't/array_transform_result_guard_composition.t' || $test eq 't/array_pipeline_callable_result_guard_composition.t')"),
        ('LINKEDSPEC_CALLABLE_PIPELINE_RESULT_CAPTURE', 'LINKEDSPEC_CALLABLE_TRANSFORM_DIRECT_CAPTURE'),
        ('docs/checkpoints/array-pipeline-callable-result-perl-2026-11-11/direct_qualified', str(REL / 'direct')),
        ('CALLABLE_PIPELINE_RESULT_DIRECT_ARTIFACT', 'CALLABLE_ARRAY_TRANSFORM_DIRECT_ARTIFACT')]
    for old, new in replacements:
        need(template.count(old) == 1, 'direct recorder origin')
        template = template.replace(old, new)
    need(images[str(REL / 'direct_runner.pl')][0] == template.encode(), 'direct recorder origin')
    counts, artifacts = {}, {}
    commands = {
        'syntax-owner': PREFIX + ['perl', '-Iperl', '-c', OWNER],
        'syntax-normal': PREFIX + ['perl', '-Iperl', '-c', NORMAL],
    }
    for name in DIRECT:
        commands[name] = PREFIX + ['LINKEDSPEC_CALLABLE_TRANSFORM_DIRECT_CAPTURE=' + str(REL / 'direct'),
            'perl', '-Iperl', str(REL / 'direct_runner.pl'), 't/' + name + '.t']
    for tag, argv in commands.items():
        need(json.loads((directory / (tag + '-command.json')).read_bytes()) == dict(argv=argv, cwd='.'), 'direct command')
        need((directory / (tag + '-exit.txt')).read_text().strip() == '0', 'direct exit')
        stdout = gzip.decompress((directory / (tag + '-stdout.log.gz')).read_bytes()).decode()
        stderr = gzip.decompress((directory / (tag + '-stderr.log.gz')).read_bytes()).decode()
        if tag in DIRECT:
            plan = re.findall(r'^1\.\.(\d+)$', stdout, re.M)
            need(len(plan) == 1 and not re.search(r'^not ok ', stdout, re.M), 'direct TAP reach')
            counts[tag] = int(plan[0])
        for line in stderr.splitlines():
            if not line.startswith('CALLABLE_ARRAY_TRANSFORM_DIRECT_ARTIFACT '):
                continue
            item = json.loads(line.split(' ', 1)[1])
            path = Path(item['path'])
            need(path.parent == REL / 'direct' and item['path'] not in artifacts, 'direct artifact ownership')
            raw = gzip.decompress(path.read_bytes())
            need(len(raw) == item['bytes'] and sha(raw) == item['sha256'], 'direct artifact bytes')
            artifacts[item['path']] = item
    need(bool(artifacts), 'direct artifacts')
    return dict(groups=counts, artifact_count=len(artifacts), images=images, artifacts=artifacts)
