"""Readonly finite Perl pipeline result/source/error/artifact recovery."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-pipeline-composition-perl-2026-11-10')
ACTIVATION = 'c34813f071403ae50580d785643957b6e0e3dd47'
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PRIVATE = '.linkedspec-data/scratch/array-pipeline-composition-perl/owner.pm'
SOURCE_FIXTURE = 'tests/fixtures/array_pipeline_source_isolation_perl_cases.json'
RESULT_FIXTURE = 'tests/fixtures/array_pipeline_result_guard_perl_cases.json'
HELPERS = ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match')
RECEIVERS = {h + '_receiver_hash_guard' for h in HELPERS}
VALUES = RECEIVERS | {h + '_free_hash_guard' for h in HELPERS}
VALUES |= {'trim_later_with', 'uniq_copy_later_with', 'lower_logical_later_with'}
NEEDED = 'needed_split_delimiter_receiver'
TARGETS = VALUES | {NEEDED}
META = dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0,
            canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])
PHASES = ('before', 'after', 'private_inverse', 'private_restored', 'direct')


def need(condition, reason):
    if not condition:
        raise AssertionError(reason)


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def safe(name):
    path = PurePosixPath(name)
    need(not path.is_absolute() and str(path) == name and '..' not in path.parts, 'unsafe-path')


def norm(value):
    if isinstance(value, str):
        return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value)
    if isinstance(value, list):
        return [norm(v) for v in value]
    if isinstance(value, dict):
        return {k: norm(v) for k, v in value.items()}
    return value


def same(a, b):
    return json.dumps(norm(a), sort_keys=True) == json.dumps(norm(b), sort_keys=True)


def projection(row):
    return {k: v for k, v in row.items() if k not in ('substitution', 'module_input', 'handler_input')}


def frames(raw, tag):
    rows = {}
    for line in raw.decode().splitlines():
        line = line.lstrip()
        if line.startswith('# '):
            line = line[2:]
        if line.startswith(tag + ' '):
            _, key, text = line.split(' ', 2)
            need(key not in rows, 'duplicate-frame')
            rows[key] = json.loads(text)
    return rows


def inputs(phase):
    directory = ROOT / BASE / phase
    identities = json.loads((directory / 'input-identities.json').read_bytes())
    result = {}
    with tarfile.open(directory / 'inputs-before-first-run.tar.gz') as archive:
        need(len(archive.getnames()) == len(set(archive.getnames()))
             and set(archive.getnames()) == set(identities), 'input-set')
        for member in archive:
            safe(member.name)
            need(member.isfile(), 'input-kind')
            raw = archive.extractfile(member).read()
            record = identities[member.name]
            need(len(raw) == record['bytes'] and digest(raw) == record['sha256']
                 and member.mode & 0o777 == record['mode'], 'input-identity')
            result[member.name] = dict(raw=raw, mode=record['mode'])
    return result


def epoch(phase):
    directory = ROOT / BASE / phase
    streams = {k: gzip.decompress((directory / (k + '.log.gz')).read_bytes()) for k in ('stdout', 'stderr')}
    combined = streams['stdout'] + streams['stderr']
    rows = frames(combined, 'ARRAY_PIPELINE_COMPOSITION_PERL')
    source_frames = frames(combined, 'ARRAY_PIPELINE_COMPOSITION_INPUT')
    bodies = {}
    for key, row in rows.items():
        bodies[key] = {}
        for field, kind in (('module_input', 'emitted'), ('handler_input', 'handler')):
            entry = row[field]
            if entry is not None:
                safe(entry['path'])
                need(PurePosixPath(entry['path']).parent == PurePosixPath(str(BASE / phase)), 'artifact-path')
                bodies[key][kind] = gzip.decompress((ROOT / entry['path']).read_bytes())
    images = []
    direct = []
    for line in streams['stderr'].decode().splitlines():
        if line.startswith('ARRAY_PIPELINE_COMPOSITION_OWNER_IMAGE '):
            images.append(json.loads(line.split(' ', 1)[1]))
        if line.startswith('ARRAY_PIPELINE_DIRECT_ARTIFACT '):
            record = json.loads(line.split(' ', 1)[1])
            safe(record['path'])
            need(PurePosixPath(record['path']).parent == PurePosixPath(str(BASE / phase)), 'direct-artifact-path')
            raw = gzip.decompress((ROOT / record['path']).read_bytes())
            need(len(raw) == record['bytes'] and digest(raw) == record['sha256'], 'direct-artifact-identity')
            direct.append(record)
    return dict(inputs=inputs(phase), streams=streams, rows=rows, frames=source_frames, bodies=bodies,
                images=images, direct=direct, exit=int((directory / 'exit.txt').read_text()),
                command=json.loads((directory / 'command.json').read_bytes()),
                activation=(directory / 'activation.txt').read_text().strip())


def recover():
    sealed = json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes())
    for name, record in sealed.items():
        safe(name)
        path = ROOT / name
        need(path.is_file() and not path.is_symlink(), 'sealed-kind')
        raw = path.read_bytes()
        need(len(raw) == record['bytes'] and digest(raw) == record['sha256']
             and path.stat().st_mode & 0o777 == record['mode'], 'sealed-identity')
    epochs = {phase: epoch(phase) for phase in PHASES}
    cases = json.loads(epochs['before']['inputs'][str(BASE / 'cases.json')]['raw'])
    profiles = json.loads(epochs['before']['inputs'][RESULT_FIXTURE]['raw'])
    old_path = 'docs/checkpoints/array-pipeline-source-perl-2026-11-10/preservation/stdout.log.gz'
    old_stream = gzip.decompress(subprocess.check_output(['git', 'show', ACTIVATION + ':' + old_path], cwd=ROOT))
    original = frames(old_stream, 'ARRAY_PIPELINE_PERL')
    prefix_stream = gzip.decompress((ROOT / BASE / 'prefix_intake/stdout.log.gz').read_bytes())
    prefix = frames(prefix_stream, 'ARRAY_PIPELINE_PERL')
    need(len(original) == 184 and len(prefix) == 60 and not original.keys() & prefix.keys(), 'original-records')
    original.update(prefix)
    git = {}
    for name in epochs['before']['inputs']:
        if name.startswith('perl/'):
            raw = subprocess.check_output(['git', 'show', ACTIVATION + ':' + name], cwd=ROOT)
            mode = int(subprocess.check_output(['git', 'ls-tree', ACTIVATION, '--', name], cwd=ROOT).split()[0], 8) & 0o777
            git[name] = dict(raw=raw, executable=bool(mode & 0o100))
    auxiliary = {}
    for phase in ('prefix_intake', 'ast_intake'):
        directory = ROOT / BASE / phase
        need((directory / 'exit.txt').read_text().strip() == '0', 'auxiliary-exit')
        need((directory / 'activation.txt').read_text().strip() == ACTIVATION, 'auxiliary-activation')
        auxiliary[phase] = inputs(phase)
    ast = [json.loads(line) for line in gzip.decompress((ROOT / BASE / 'ast_intake/stdout.log.gz').read_bytes()).decode().splitlines()]
    return dict(epochs=epochs, cases=cases, profiles=profiles, original=original, git=git,
                auxiliary=auxiliary, ast=ast)


def source_scope(old, new):
    text = new.decode()
    for start, end in (
        ('# Pure pipeline results are Arrays at their canonical ordinary arities.', '# Count keeps its numeric result'),
        ('  my $ordinary_array_pipeline_result_chain =', '  # Copy and collection results stay together;'),
        ('  my $initial_array_pipeline_prefix =', '  my $initial_collection_prefix ='),
    ):
        need(text.count(start) == 1, 'source-scope')
        begin = text.index(start)
        finish = text.index(end, begin)
        text = text[:begin] + text[finish:]
    need(text.count(' || $ordinary_array_pipeline_result_chain') == 5, 'source-scope')
    text = text.replace(' || $ordinary_array_pipeline_result_chain', '')
    line = '   && !$ordinary_array_pipeline_result_chain\n'
    need(text.count(line) == 1, 'source-scope')
    text = text.replace(line, '')
    need(text.count(' && !$ordinary_array_pipeline_result_chain') == 2, 'source-scope')
    text = text.replace(' && !$ordinary_array_pipeline_result_chain', '')
    need(text.count(' || $initial_array_pipeline_prefix') == 1, 'source-scope')
    text = text.replace(' || $initial_array_pipeline_prefix', '')
    need(text.encode() == old, 'source-scope')


def validate(model):
    data = model['epochs']
    before, after = data['before'], data['after']
    cases = {case['id']: case for case in model['cases']}
    profiles = {profile['case']['id']: profile for profile in model['profiles']}
    need(len(cases) == len(profiles) == 244 and len(TARGETS) == 18, 'population')
    need(list(cases) == list(profiles) and set(cases) == set(model['original']), 'case-set')
    for name, record in model['git'].items():
        actual = before['inputs'][name]
        need(actual['raw'] == record['raw'] and bool(actual['mode'] & 0o100) == record['executable'], 'activation-source')
        if name != OWNER:
            need(after['inputs'][name] == actual, 'unchanged-runtime')
        for auxiliary in model['auxiliary'].values():
            need(auxiliary[name] == actual, 'acquisition-runtime')
    source_scope(before['inputs'][OWNER]['raw'], after['inputs'][OWNER]['raw'])
    need(before['inputs'][OWNER]['mode'] == after['inputs'][OWNER]['mode'], 'source-mode')
    old_fixture = before['inputs'][SOURCE_FIXTURE]['raw']
    need(gzip.decompress((ROOT / BASE / 'source-normal-fixture-before.json.gz').read_bytes()) == old_fixture, 'fixture-original')
    aligned = json.loads(old_fixture)
    found = [p for p in aligned if p['case']['id'] == 'invalid_range_receiver_composed']
    need(len(found) == 1, 'fixture-scope')
    found[0]['expected_observation']['metadata'] = META
    aligned_raw = (json.dumps(aligned, indent=2, sort_keys=True) + '\n').encode()
    need(len(model['ast']) == 6, 'ast-population')
    need(model['ast'][2]['node']['receiver']['args'][1]['kind'] == 'regex'
         and model['ast'][3]['node']['calls'][0]['args'][0]['kind'] == 'regex'
         and model['ast'][5]['node']['calls'][0]['args'][0]['kind'] == 'block_value', 'ast-kinds')
    oracle = model['original']['receiver_needed_delimiter_terminal']
    for phase, epoch_ in data.items():
        need(epoch_['activation'] == ACTIVATION and epoch_['command']['cwd'] == '.', 'epoch-activation')
        need(epoch_['exit'] == (1 if phase in ('before', 'private_inverse') else 0), 'epoch-exit')
        need(epoch_['command']['argv'][:4] == ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB='], 'epoch-command')
        expected_fixture = old_fixture if phase in ('before', 'after') else aligned_raw
        need(epoch_['inputs'][SOURCE_FIXTURE]['raw'] == expected_fixture
             and epoch_['inputs'][SOURCE_FIXTURE]['mode'] == before['inputs'][SOURCE_FIXTURE]['mode'], 'fixture-scope')
        need(epoch_['inputs'][RESULT_FIXTURE] == before['inputs'][RESULT_FIXTURE], 'result-fixture')
        if phase == 'direct':
            for name, entry in after['inputs'].items():
                if name.startswith(('perl/', 'specs/', 'tests/fixtures/', 'tools/', 't/')) and name != SOURCE_FIXTURE:
                    need(epoch_['inputs'].get(name) == entry, 'direct-input')
            need(b'Tests=384,' in epoch_['streams']['stdout'] and b'Result: PASS' in epoch_['streams']['stdout'], 'direct-tap')
            need({r['kind'] for r in epoch_['direct']} == {'spec', 'pm', 'handler'}
                 and len({r['path'] for r in epoch_['direct']}) == len(epoch_['direct']), 'direct-artifacts')
            continue
        need(list(epoch_['rows']) == list(cases) and list(epoch_['frames']) == list(cases), 'frame-set')
        failed = set(re.findall(r'^not ok \d+ - (.+)$', epoch_['streams']['stdout'].decode(), re.M))
        need(failed == (TARGETS if phase in ('before', 'private_inverse') else set())
             and b'Tests=244,' in epoch_['streams']['stdout'], 'normal-tap')
        pairs = 0
        for key, row in epoch_['rows'].items():
            case, frame = cases[key], epoch_['frames'][key]
            seed = case.get('seed', 'empty')
            host = dict(main=['MAIN', 'TAIL', 'END'] if seed == 'main' else [],
                        outer=['OUTER', 'TAIL', 'END'] if seed == 'outer' else [])
            need(row['host_before'] == row['host_after'] == host, 'host-state')
            need(frame['source'] == case['source'], 'artifact-source')
            if row['loaded'] == 0:
                need(all(k not in row for k in ('fresh', 'fresh_error', 'fresh_cursor')), 'load-absence')
            for field, kind in (('module_input', 'emitted'), ('handler_input', 'handler')):
                entry = row[field]
                if entry is None:
                    need(frame[kind] is None and kind not in epoch_['bodies'][key], 'artifact-absence')
                else:
                    raw = epoch_['bodies'][key][kind]
                    need(raw == frame[kind].encode() and len(raw) == entry['bytes'] and digest(raw) == entry['sha256'], 'artifact-identity')
            pairs += bool(row['module_input'] is not None and row['handler_input'] is not None)
            if phase in ('before', 'private_inverse'):
                need(same(projection(row), projection(model['original'][key])), 'original-projection')
                if key in TARGETS:
                    stage = 'rule_handler_compile' if key in RECEIVERS | {NEEDED} else 'rule_handler_eval'
                    needle = 'syntax error' if stage.endswith('compile') else 'Not a HASH reference'
                    need(row['native_error']['stage'] == stage and needle in row['native_error']['detail'], 'original-target')
            elif key in VALUES:
                need(row['loaded'] == row['native_callable'] == 1 and row['load_error'] is None
                     and row['native_error'] is None and row['fresh_error'] is None, 'target-error')
                need(same(row['native'], case['expected']) and same(row['fresh'], case['expected']), 'target-values')
                need(row['metadata'] == META and row['warnings'] == [], 'target-metadata')
            elif key == NEEDED:
                need(same(projection(row), projection(oracle)), 'needed-error')
            else:
                actual = projection(row)
                original = projection(model['original'][key])
                if key == 'invalid_range_receiver_composed':
                    need(row['metadata'] == META, 'range-metadata')
                    actual = dict(actual, metadata=original['metadata'])
                if key.startswith('invalid_range_'):
                    need(row['native_error']['stage'] == 'rule_handler_compile'
                         and 'Invalid [] range' in row['native_error']['detail']
                         and 'Invalid [] range' in row['load_error'], 'regex-error')
                need(same(actual, original), 'preservation')
        need(pairs == 240, 'artifact-pairs')
        if phase.startswith('private_'):
            reference = before if phase == 'private_inverse' else after
            image = epoch_['inputs'][PRIVATE]
            need(image == reference['inputs'][OWNER] and epoch_['inputs'][OWNER] == after['inputs'][OWNER], 'private-input')
            need(epoch_['images'] == [dict(path=PRIVATE, bytes=len(image['raw']), sha256=digest(image['raw']))], 'private-owner')
            for key in cases:
                need(same(projection(epoch_['rows'][key]), projection(reference['rows'][key])), 'private-projection')
                need(epoch_['bodies'][key] == reference['bodies'][key], 'private-artifact')
    return True


model = recover()
validate(model)
key = 'trim_each_free_hash_guard'
controls = [
    ('restored-result-error', 'target-error', lambda m: m['epochs']['after']['rows'][key].update(native_error=m['epochs']['before']['rows'][key]['native_error'])),
    ('later-work-ran', 'target-values', lambda m: m['epochs']['after']['rows']['trim_later_with'].update(fresh=['wrong', 'KVW'])),
    ('masked-needed-error', 'needed-error', lambda m: m['epochs']['after']['rows'][NEEDED].update(native_error=None)),
    ('Bool-became-Number', 'preservation', lambda m: m['epochs']['after']['rows']['nested_scalar_kinds']['native'][0].__setitem__(0, 0)),
    ('prefix-policy-changed', 'preservation', lambda m: m['epochs']['after']['rows']['prefix_number_trim_each_main'].update(native=[None, ''])),
    ('host-mutated', 'host-state', lambda m: m['epochs']['after']['rows'][key]['host_after'].update(main=['changed'])),
    ('omitted-error-provenance', 'needed-error', lambda m: m['epochs']['after']['rows'][NEEDED]['native_error'].pop('handler_source_label')),
    ('invented-fresh-after-failed-load', 'load-absence', lambda m: m['epochs']['before']['rows']['trim_each_receiver_hash_guard'].update(fresh=None)),
    ('hidden-regex-error', 'regex-error', lambda m: m['epochs']['after']['rows']['invalid_range_receiver_composed']['native_error'].update(detail='syntax error')),
    ('changed-actual-artifact', 'artifact-identity', lambda m: m['epochs']['after']['bodies'][key].update(emitted=b'changed')),
    ('wrong-loaded-owner', 'private-owner', lambda m: m['epochs']['private_inverse']['images'][0].update(path=OWNER)),
    ('broader-source-change', 'source-scope', lambda m: m['epochs']['after']['inputs'][OWNER].update(raw=m['epochs']['after']['inputs'][OWNER]['raw'] + b'\n# drift\n')),
    ('missing-direct-fixture', 'fixture-scope', lambda m: m['epochs']['direct']['inputs'][SOURCE_FIXTURE].update(raw=b'[]\n')),
]
rejected = []
for name, reason, mutate in controls:
    altered = copy.deepcopy(model)
    mutate(altered)
    try:
        validate(altered)
    except AssertionError as error:
        need(str(error) == reason, 'wrong-control-reason:' + name + ':' + str(error))
        rejected.append(dict(name=name, reason=reason))
    else:
        raise AssertionError('ineffective-control:' + name)
print(json.dumps(dict(scope='Historical finite result/preservation proof; native/cache/transitive/toolchain and full admission remain separate.',
    result='PASS', groups=244, repaired_targets=18, preservation_controls=226,
    exact_preservation_projections=225, declared_descriptor_advances=1,
    actual_module_handler_pairs_per_normal=240, direct_groups=384,
    private_inverse='18 RED / 244 restored PASS', controls=rejected), indent=2))
