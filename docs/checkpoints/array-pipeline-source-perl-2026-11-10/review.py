"""Readonly source-isolation, loaded-owner and preservation recovery."""
import copy
from collections import Counter
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-pipeline-source-perl-2026-11-10')
ACTIVATION = 'fe4906fb0bdac1ff7dc4f33728862cd6d47cf79d'
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PRIVATE = '.linkedspec-data/scratch/array-pipeline-source-perl/owner.pm'
HELPERS = ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match')
COMPOSITION = {h + suffix for h in HELPERS for suffix in ('_free_hash_guard', '_receiver_hash_guard')}
COMPOSITION |= {'trim_later_with', 'uniq_copy_later_with', 'lower_logical_later_with', 'needed_split_delimiter_receiver'}
PHASES = ('before', 'after', 'private_inverse', 'private_restored_qualified', 'preservation', 'direct_qualified')


def need(condition, reason):
    if not condition:
        raise AssertionError(reason)


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def safe(name):
    p = PurePosixPath(name)
    need(not p.is_absolute() and str(p) == name and '..' not in p.parts, 'unsafe-path')


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
            _, key, value = line.split(' ', 2)
            need(key not in rows, 'duplicate-frame')
            rows[key] = json.loads(value)
    return rows


def inputs(phase):
    directory = ROOT / BASE / phase
    identities = json.loads((directory / 'input-identities.json').read_bytes())
    result = {}
    with tarfile.open(directory / 'inputs-before-first-run.tar.gz') as archive:
        need(len(archive.getnames()) == len(set(archive.getnames())), 'duplicate-input')
        need(set(archive.getnames()) == set(identities), 'input-set')
        for member in archive:
            safe(member.name)
            need(member.isfile(), 'input-kind')
            raw = archive.extractfile(member).read()
            row = identities[member.name]
            need(len(raw) == row['bytes'] and digest(raw) == row['sha256']
                 and member.mode & 0o777 == row['mode'], 'input-identity')
            result[member.name] = dict(raw=raw, mode=row['mode'])
    return result


def epoch(phase):
    directory = ROOT / BASE / phase
    streams = {k: gzip.decompress((directory / (k + '.log.gz')).read_bytes()) for k in ('stdout', 'stderr')}
    tag = 'ARRAY_PIPELINE_PERL' if phase == 'preservation' else 'ARRAY_PIPELINE_SOURCE_PERL'
    input_tag = 'ARRAY_PIPELINE_INPUT' if phase == 'preservation' else 'ARRAY_PIPELINE_SOURCE_INPUT'
    rows = frames(streams['stdout'] + streams['stderr'], tag)
    artifacts = frames(streams['stdout'] + streams['stderr'], input_tag)
    image = []
    direct_artifacts = []
    for line in streams['stderr'].decode().splitlines():
        if line.startswith('ARRAY_PIPELINE_SOURCE_OWNER_IMAGE '):
            image.append(json.loads(line.split(' ', 1)[1]))
        if line.startswith('ARRAY_PIPELINE_DIRECT_ARTIFACT '):
            record = json.loads(line.split(' ', 1)[1])
            safe(record['path'])
            need(PurePosixPath(record['path']).parent == PurePosixPath(str(BASE / phase)), 'direct-artifact-path')
            raw = gzip.decompress((ROOT / record['path']).read_bytes())
            need(len(raw) == record['bytes'] and digest(raw) == record['sha256'], 'direct-artifact-identity')
            direct_artifacts.append(record)
    bodies = {}
    if not phase.startswith('direct'):
        for key, row in rows.items():
            bodies[key] = {}
            for field, kind in (('module_input', 'emitted'), ('handler_input', 'handler')):
                entry = row[field]
                if entry is not None:
                    safe(entry['path'])
                    need(PurePosixPath(entry['path']).parent == PurePosixPath(str(BASE / phase)), 'artifact-path')
                    bodies[key][kind] = gzip.decompress((ROOT / entry['path']).read_bytes())
    return dict(inputs=inputs(phase), rows=rows, frames=artifacts, bodies=bodies,
                streams=streams, images=image, direct_artifacts=direct_artifacts,
                exit=int((directory / 'exit.txt').read_text()),
                command=json.loads((directory / 'command.json').read_bytes()),
                activation=(directory / 'activation.txt').read_text().strip())


def recover():
    sealed = json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes())
    for name, row in sealed.items():
        safe(name)
        path = ROOT / name
        need(path.is_file() and not path.is_symlink(), 'sealed-kind')
        raw = path.read_bytes()
        need(len(raw) == row['bytes'] and digest(raw) == row['sha256']
             and path.stat().st_mode & 0o777 == row['mode'], 'sealed-identity')
    templates = json.loads((ROOT / BASE / 'template-identities.json').read_bytes())
    recovered = {}
    for name, row in templates.items():
        raw = gzip.decompress((ROOT / row['retained']).read_bytes())
        need(len(raw) == row['bytes'] and digest(raw) == row['sha256'], 'template-identity')
        recovered[name.rsplit('/', 1)[-1] if '/stdout.' not in name else name.split('/')[-2]] = raw
    prior = {}
    prior_frames = {}
    for phase in ('preflight', 'delimiter_controls'):
        raw = gzip.decompress(recovered[phase])
        prior.update(frames(raw, 'ARRAY_PIPELINE_PERL'))
        prior_frames.update(frames(raw, 'ARRAY_PIPELINE_INPUT'))
    cases = json.loads(recovered['cases.json']) + json.loads(recovered['delimiter-cases.json'])
    need(json.loads((ROOT / BASE / 'cases.json').read_bytes()) == cases, 'case-source')
    epochs = {p: epoch(p) for p in PHASES}
    rejected_epoch = epoch('private_restored')
    rejected_direct = epoch('direct')
    qualification = json.loads((ROOT / BASE / 'restored-capture-qualification.json').read_bytes())
    need(qualification['outer_exit'] == 1 and qualification['sdk_exit'] == 0
         and qualification['selected_phase'] == 'private_restored_qualified', 'qualification-record')
    need(b'AssertionError' in gzip.decompress((ROOT / BASE / 'restored-capture-drift.log.gz').read_bytes()), 'qualification-failure')
    producer = str(BASE / 'capture.py')
    need(digest(rejected_epoch['inputs'][producer]['raw']) == qualification['original_producer_sha256']
         and rejected_epoch['inputs'][producer] != epochs['private_restored_qualified']['inputs'][producer], 'qualification-producer')
    direct_qualification = json.loads((ROOT / BASE / 'direct-wrapper-qualification.json').read_bytes())
    need(direct_qualification['sdk_exit'] == direct_qualification['outer_exit'] == rejected_direct['exit'] == 1
         and direct_qualification['selected_phase'] == 'direct_qualified', 'direct-qualification')
    need(b'No plan found in TAP output' in rejected_direct['streams']['stdout']
         and b'All 6 subtests passed' in rejected_direct['streams']['stdout']
         and b'Tests=195,' in rejected_direct['streams']['stdout']
         and not re.search(rb'^not ok ', rejected_direct['streams']['stdout'], re.M), 'direct-original-failure')
    git_inputs = {}
    for name, entry in epochs['before']['inputs'].items():
        if name.startswith('perl/'):
            raw = subprocess.check_output(['git', 'show', ACTIVATION + ':' + name], cwd=ROOT)
            mode = subprocess.check_output(['git', 'ls-tree', ACTIVATION, '--', name], cwd=ROOT).split()[0]
            git_inputs[name] = dict(raw=raw, mode=int(mode, 8) & 0o777)
    return dict(cases=cases, prior=prior, prior_frames=prior_frames, epochs=epochs, git=git_inputs,
                rejected_epoch=rejected_epoch, rejected_direct=rejected_direct)


def validate(model):
    cases = {c['id']: c for c in model['cases']}
    prior = model['prior']
    normal_ids = [k for k in cases if k not in COMPOSITION]
    source_ids = {k for k, c in cases.items() if c.get('host_literal') and c.get('seed') == 'main'}
    need(len(cases) == 184 and len(normal_ids) == 166 and len(source_ids) == 14, 'population')
    need(set(prior) == set(cases), 'prior-set')
    epochs = model['epochs']
    before, after = epochs['before'], epochs['after']
    for name, entry in model['git'].items():
        need(before['inputs'].get(name) == entry, 'activation-source')
    old = before['inputs'][OWNER]['raw']
    needle = b"  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {"
    replacement = b"  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re\n    && !_method_value_is_numeric_literal($target_expr, $deps)) {"
    start = old.index(b' my $lower_array_value_source_expr = sub {')
    expected = old[:start] + old[start:].replace(needle, replacement, 1)
    need(expected != old and after['inputs'][OWNER]['raw'] == expected, 'source-scope')
    need(after['inputs'][OWNER]['mode'] == before['inputs'][OWNER]['mode'], 'source-mode')
    for name, entry in before['inputs'].items():
        if name.startswith(('perl/', 'specs/', 'tests/fixtures/', 'tools/', 't/')) and name != OWNER:
            need(after['inputs'].get(name) == entry, 'preserved-input')
    for phase, data in epochs.items():
        need(data['activation'] == ACTIVATION, 'epoch-activation')
        need(data['exit'] == (1 if phase in ('before', 'private_inverse') else 0), 'epoch-exit')
        need(data['command']['cwd'] == '.' and data['command']['argv'][:4] ==
             ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB='], 'epoch-command')
        if phase.startswith('direct'):
            for name, entry in after['inputs'].items():
                if name.startswith(('perl/', 'specs/', 'tests/fixtures/', 'tools/', 't/')):
                    need(data['inputs'].get(name) == entry, 'direct-input')
            need(b'Tests=195,' in data['streams']['stdout'] and b'Result: PASS' in data['streams']['stdout'], 'direct-tap')
            need({r['kind'] for r in data['direct_artifacts']} == {'spec', 'pm', 'handler'}, 'direct-artifact-scope')
            need(len({r['path'] for r in data['direct_artifacts']}) == len(data['direct_artifacts']), 'direct-artifact-duplicates')
            continue
        ids = list(cases) if phase == 'preservation' else normal_ids
        need(list(data['rows']) == ids and list(data['frames']) == ids, 'frame-set')
        if phase != 'preservation':
            failed = set(re.findall(r'^not ok \d+ - (.+)$', data['streams']['stdout'].decode(), re.M))
            need(failed == (source_ids if phase in ('before', 'private_inverse') else set()), 'normal-tap')
            need(b'Tests=166,' in data['streams']['stdout'], 'normal-count')
        for key in ids:
            row, case, frame = data['rows'][key], cases[key], data['frames'][key]
            seed = case.get('seed', 'empty')
            host = dict(main=['MAIN', 'TAIL', 'END'] if seed == 'main' else [],
                        outer=['OUTER', 'TAIL', 'END'] if seed == 'outer' else [])
            need(row['host_before'] == row['host_after'] == host, 'host-state')
            need(frame['source'] == case['source'], 'artifact-source')
            for field, kind in (('module_input', 'emitted'), ('handler_input', 'handler')):
                entry = row[field]
                if entry is None:
                    need(frame[kind] is None and kind not in data['bodies'][key], 'artifact-absence')
                else:
                    raw = data['bodies'][key][kind]
                    need(raw == frame[kind].encode() and len(raw) == entry['bytes'] and digest(raw) == entry['sha256'], 'artifact-identity')
            if key in source_ids:
                values = (['main', 'tail', 'end'] if 'lowercase_each' in key else ['MAIN', 'TAIL', 'END'])
                if phase in ('before', 'private_inverse'):
                    need(same(row['native'], values) and same(row['fresh'], values), 'source-original')
                else:
                    need(same(row['native'], []) and same(row['fresh'], []), 'source-repaired')
                    need('my $__ls_array_value_source = 3;' in row['substitution']
                         and '[@3]' not in row['substitution'], 'source-mechanism')
                expected_row = copy.deepcopy(prior[key])
                if phase not in ('before', 'private_inverse'):
                    expected_row.update(native=[], fresh=[])
                need(same(projection(row), projection(expected_row)), 'source-profile')
            else:
                need(same(projection(row), projection(prior[key])),
                     'composition-profile' if key in COMPOSITION else 'healthy-profile')
            if phase == 'preservation' and (key in COMPOSITION or key in list(cases)[:36]):
                for kind in ('emitted', 'handler'):
                    need(data['bodies'][key].get(kind) == model['prior_frames'][key][kind].encode(), 'composition-artifact')
        if phase.startswith('private_'):
            reference = before if phase == 'private_inverse' else after
            entry = data['inputs'][PRIVATE]
            need(entry == reference['inputs'][OWNER], 'private-input')
            need(data['images'] == [dict(path=PRIVATE, bytes=len(entry['raw']), sha256=digest(entry['raw']))], 'private-owner')
            need(data['inputs'][OWNER] == after['inputs'][OWNER], 'checkout-owner')
            for key in normal_ids:
                need(same(projection(data['rows'][key]), projection(reference['rows'][key])), 'private-profile')
                need(data['bodies'][key] == reference['bodies'][key], 'private-artifact')
    original = model['rejected_epoch']
    qualified = epochs['private_restored_qualified']
    need(original['exit'] == 0 and original['images'] == qualified['images'], 'rejected-sdk-result')
    for name, entry in original['inputs'].items():
        if name.startswith(('perl/', 'specs/', 'tests/fixtures/', 'tools/', 't/')) or name == PRIVATE:
            need(qualified['inputs'].get(name) == entry, 'rejected-sdk-input')
    need(same({k: projection(v) for k, v in original['rows'].items()},
              {k: projection(v) for k, v in qualified['rows'].items()})
         and original['bodies'] == qualified['bodies'], 'rejected-sdk-preservation')
    old_direct, new_direct = model['rejected_direct'], epochs['direct_qualified']
    for name, entry in old_direct['inputs'].items():
        if name.startswith(('perl/', 'specs/', 'tests/fixtures/', 'tools/', 't/')):
            need(new_direct['inputs'].get(name) == entry, 'direct-test-preservation')
    def identities(data):
        return Counter((r['kind'], r['bytes'], r['sha256']) for r in data['direct_artifacts'])
    need(identities(old_direct) == identities(new_direct), 'direct-artifact-preservation')
    return len(source_ids)


model = recover()
validate(model)
source_key = 'initial_number_trim_each_free_host_main'
error_key = next(c['id'] for c in model['cases'] if c.get('expected_error') and c['id'] not in COMPOSITION)
controls = [
    ('hidden-original-read', 'source-original', lambda m: m['epochs']['before']['rows'][source_key].update(native=[])),
    ('restored-host-read', 'source-repaired', lambda m: m['epochs']['after']['rows'][source_key].update(native=['MAIN'])),
    ('host-mutation', 'host-state', lambda m: m['epochs']['after']['rows'][source_key]['host_after'].update(main=[])),
    ('omitted-error-provenance', 'healthy-profile', lambda m: m['epochs']['after']['rows'][error_key]['native_error'].pop('handler_source_label')),
    ('Bool-became-Number', 'healthy-profile', lambda m: m['epochs']['after']['rows']['nested_scalar_kinds']['native'][0].__setitem__(0, 0)),
    ('masked-composition-error', 'composition-profile', lambda m: m['epochs']['preservation']['rows']['trim_each_free_hash_guard'].update(native_error=None)),
    ('wrong-loaded-owner', 'private-owner', lambda m: m['epochs']['private_inverse']['images'][0].update(path=OWNER)),
    ('broader-source-change', 'source-scope', lambda m: m['epochs']['after']['inputs'][OWNER].update(raw=m['epochs']['after']['inputs'][OWNER]['raw'] + b'\n# drift\n')),
    ('changed-actual-artifact', 'artifact-identity', lambda m: m['epochs']['after']['bodies'][source_key].update(emitted=b'changed')),
    ('missing-direct-fixture', 'direct-input', lambda m: m['epochs']['direct_qualified']['inputs'].pop('tests/fixtures/array_transform_result_guard_perl_profiles.json')),
]
rejected = []
for name, reason, mutate in controls:
    damaged = copy.deepcopy(model)
    mutate(damaged)
    try:
        validate(damaged)
    except AssertionError as error:
        need(str(error) == reason, 'wrong-control-reason:' + name + ':' + str(error))
        rejected.append(dict(name=name, reason=reason))
    else:
        raise AssertionError('ineffective-control:' + name)
print(json.dumps(dict(scope='Historical bounded source repair; full native/cache/transitive/toolchain and general admission remain separate.',
    source='PASS', normal_groups=166, original_failures=14, preserved_groups=152,
    preservation_programs=184, unchanged_composition_targets=18, direct_groups=195,
    private_inverse='14 RED / 166 restored PASS', controls=rejected), indent=2))
