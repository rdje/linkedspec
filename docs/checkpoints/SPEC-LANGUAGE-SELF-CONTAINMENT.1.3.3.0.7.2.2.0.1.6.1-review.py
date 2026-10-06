"""Independently accept complete committed producer composition without overlays."""
from pathlib import Path, PurePosixPath
import copy
import importlib.util
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review.py')
REVISION = '56c8f38d12a799e4f4fb8c5b0cfe27690d27f1fc'
BASE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.'
PREVIOUS = BASE + '6.0-'
STREAM = BASE + '1.1.0-capture.py'
spec = importlib.util.spec_from_file_location('retained_composition_oracles', ROOT / (PREVIOUS + 'review.py'))
prior = importlib.util.module_from_spec(spec); spec.loader.exec_module(prior)
sha, decode, envelope = prior.sha, prior.decode, prior.envelope
TESTS, PLANS = prior.TESTS, prior.PLANS


def read(path):
    return json.loads((ROOT / path).read_bytes())


def commands():
    rows = prior.commands()
    return [(kind, seed, tail[:-1] + [BASE + '6.0-retry-probe.pl'] if kind == 'cross-family' else tail)
            for kind, seed, tail in rows]


def check_inputs(manifest):
    assert manifest['revision'] == REVISION and manifest['overlays'] == [], 'immutable boundary without overlays'
    expected, excluded = {}, []
    for row in filter(None, subprocess.check_output(['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT).split(b'\0')):
        metadata, path = row.split(b'\t', 1)
        mode, kind, oid, size = metadata.split()
        if kind == b'blob' and mode in (b'100644', b'100755'):
            expected[path.decode()] = (mode.decode(), oid.decode(), int(size))
        else:
            excluded.append({'path': path.decode(), 'mode': mode.decode(), 'kind': kind.decode()})
    entries = {entry['path']: entry for entry in manifest['entries']}
    assert len(entries) == len(manifest['entries']) and set(entries) == set(expected), 'complete unique input population'
    assert manifest['regular_git_inputs'] == len(expected), 'exact committed input count'
    assert manifest['excluded_metadata'] == excluded, 'exact black-box metadata exclusions'
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for path, (mode, oid, size) in expected.items():
            entry = entries[path]
            assert (entry['mode'], entry['oid'], entry['bytes']) == (mode, oid, size), 'exact immutable object and mode'
            process.stdin.write((oid + '\n').encode()); process.stdin.flush()
            assert process.stdout.readline().split() == [oid.encode(), b'blob', str(size).encode()], 'exact immutable blob header'
            raw = process.stdout.read(size)
            assert process.stdout.read(1) == b'\n', 'exact immutable blob framing'
            assert entry['sha256'] == sha(raw), 'exact immutable input bytes'
            assert not any(entry.get(key) for key in ('declared_authored_overlay', 'declared_fixture_overlay', 'declared_owner_delta')), 'no committed input replacement'
            if path.startswith(('perl/', 'specs/', 't/')):
                assert raw == (ROOT / path).read_bytes(), 'unchanged production and fixtures'
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0


def check_report(report, manifest, authored):
    assert report['complete'] is True and report['revision'] == REVISION, 'complete actual composition capture'
    tree = report.get('input_tree', '')
    assert (
        isinstance(tree, str)
        and tree.startswith('.linkedspec-data/scratch/all-producer-source-acceptance/committed-composition-')
        and not PurePosixPath(tree).is_absolute()
        and all(part not in ('.', '..') for part in PurePosixPath(tree).parts)
    ), 'repository-local immutable input tree'
    assert report['instrument_sha256'] == sha(Path(PREFIX + 'capture.py').read_bytes()), 'actual composition capture producer'
    assert report['stream_instrument_sha256'] == sha((ROOT / STREAM).read_bytes()), 'actual retained stream producer'
    expected = commands()
    assert [(row['kind'], row['seed']) for row in report['runs']] == [(kind, seed) for kind, seed, _ in expected], 'complete actual command population'
    previous = read(PREVIOUS + 'observations.json')
    corrected = read(PREVIOUS + 'retry-observations.json')
    channels = {}
    for row, (kind, seed, tail) in zip(report['runs'], expected, strict=True):
        assert row['command'] == ['bash', 'tools/project_data_run.sh'] + tail, 'actual declared observation command'
        assert row['exit'] == 0 and row.get('inputs_before') == row.get('inputs_after') == len(manifest['entries']), 'complete before after runtime guards'
        assert decode(row['stderr']) == b'', 'empty actual outer stderr'
        raw = decode(row['stdout'])
        if kind == 'fixtures': prior.check_tap(raw); continue
        document = json.loads(raw)
        if kind == 'cross-family': prior.check_cross(document, authored)
        else: prior.check_original(kind, document)
        old_report = corrected if kind == 'cross-family' else previous
        old = next(old for old in old_report['runs'] if old['kind'] == kind and old['seed'] == seed)
        assert raw == decode(old['stdout']), 'complete original family channel recurrence'
        channels.setdefault(kind, []).append(raw)
    assert all(len(set(rows)) == 1 for rows in channels.values()), 'complete three-seed channel equality'


def main():
    authored = read(PREVIOUS + 'cases.json')
    assert authored == prior.oracle.author(), 'unchanged independent representative oracle'
    manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    report = json.loads(Path(PREFIX + 'observations.json').read_bytes())
    check_inputs(manifest); check_report(report, manifest, authored)
    populations, contracts, method_frames = prior.measured_populations(report)
    old_measurement = read(PREVIOUS + 'verification.json')
    assert populations == old_measurement['original_populations'] and contracts == 174 and method_frames == 46, 'exact original independently measured population recurrence'
    document = json.loads(decode(report['runs'][0]['stdout']))
    controls = []
    def reject(name, target, mutation, validator, reason):
        changed = copy.deepcopy(target); mutation(changed)
        assert changed != target, 'effective corruption: ' + name
        try: validator(changed)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append({'name': name, 'observed': 'RED', 'reason': reason}); return
        raise AssertionError('accepted corruption: ' + name)
    validate = lambda value: prior.check_cross(value, authored)
    for index, pair in enumerate(document['pairs']):
        for field, mutate, reason in (
            ('outer origins', lambda row: row['result']['source_origins'].pop(), 'literal representative scalar origins'),
            ('outer reference', lambda row: row['identity'][0].update(constructed_event=False), 'actual returned constructor and origin identities'),
            ('caller error', lambda row: row.update(caller_error='lost'), 'actual caller error preservation'),
            ('recorder restoration', lambda row: row.update(outer_recorder_restored=False), 'real nested scan and outer recorder restoration'),
            ('inner origin', lambda row: row['nested']['result']['source_origins'].pop(), 'literal representative scalar origins'),
        ):
            reject(pair['outer'] + '/' + pair['inner'] + '/' + field, document,
                   lambda value, index=index, mutate=mutate: mutate(value['pairs'][index]['observation']), validate, reason)
    for index, pair in enumerate(document['fatal_pairs']):
        reject(pair['outer'] + '/fatal restoration', document, lambda value, index=index: value['fatal_pairs'][index]['observation'].update(outer_recorder_restored=False), validate, 'fatal nested outer recorder restoration')
        reject(pair['outer'] + '/actual fatal callback', document, lambda value, index=index: value['fatal_pairs'][index]['observation']['nested'].update(callback_count=0), validate, 'actual nested callback exception and recorder change')
    for index, case in enumerate(authored['cases']):
        for name, mutate, reason in (
            ('equal raw swapped scalar', lambda row: row['result']['source_origins'][1].update(source_span=row['result']['source_origins'][0]['source_span']), 'literal representative scalar origins'),
            ('cloned arguments', lambda row: row['identity'][0].update(constructed_args=False), 'actual returned constructor and origin identities'),
            ('lost returned array', lambda row: row.update(returned_array=False), 'actual first-defined returned-array identity'),
            ('dispatcher reorder', lambda row: row['visited'].reverse() if len(row['visited']) > 1 else row['visited'][0].update(defined=False), 'exact first-defined dispatcher order'),
            ('changed callback result', lambda row: row['calls'][0].update(result=['forged']), 'public private callback equality'),
        ):
            reject(case['contract'] + '/' + name, document, lambda value, index=index, mutate=mutate: mutate(value['base'][index]['private']), validate, reason)
    for name, mutation, reason in (
        ('lost nested pair', lambda value: value['pairs'].pop(), 'complete ordered nested pair population'),
        ('opaque invented origin', lambda value: value['opaque']['result']['source_origins'].append({}), 'opaque first-defined identity and no invented origins'),
        ('empty falls through', lambda value: value['empty']['visited'].append(1), 'empty first-defined stops and discards unselected records'),
        ('recorder leaks', lambda value: value.update(final_recorder_inactive=False), 'final recorder inactive'),
    ): reject(name, document, mutation, validate, reason)
    report_check = lambda value: check_report(value, manifest, authored)
    for name, mutation, reason in (
        ('capture incomplete', lambda value: value.update(complete=False), 'complete actual composition capture'),
        ('forged input tree', lambda value: value.update(input_tree='off-volume/forged'), 'repository-local immutable input tree'),
        ('lost command', lambda value: value['runs'].pop(), 'complete actual command population'),
        ('forged command', lambda value: value['runs'][0]['command'].append('forged'), 'actual declared observation command'),
        ('failed exit', lambda value: value['runs'][0].update(exit=1), 'complete before after runtime guards'),
        ('lost guard', lambda value: value['runs'][0].pop('inputs_after'), 'complete before after runtime guards'),
        ('forged capture', lambda value: value.update(instrument_sha256='0' * 64), 'actual composition capture producer'),
        ('forged stream', lambda value: value.update(stream_instrument_sha256='0' * 64), 'actual retained stream producer'),
        ('forged channel', lambda value: value['runs'][0]['stdout'].update(sha256='0' * 64), 'complete channel bytes'),
        ('outer stderr', lambda value: value['runs'][0].update(stderr=envelope(b'forged')), 'empty actual outer stderr'),
    ): reject(name, report, mutation, report_check, reason)
    tap = decode(report['runs'][3]['stdout'])
    reject('short positive TAP', report, lambda value: value['runs'][3].update(stdout=envelope(tap.replace(b'ok 191 - ', b'ok 192 - ', 1))), report_check, 'complete ordered positive TAP reach')
    reject('hidden nested TAP failure', report, lambda value: value['runs'][3].update(stdout=envelope(tap.replace(b'    ok 1 - ', b'    not ok 1 - ', 1))), report_check, 'no nested fixture failure')
    for kind in ('basic', 'pipeline', 'flow', 'legacy', 'dedicated'):
        index = next(i for i, row in enumerate(report['runs']) if row['kind'] == kind)
        def alter(value, index=index, kind=kind):
            row = value['runs'][index]; current = json.loads(decode(row['stdout']))
            if kind in ('basic', 'pipeline'): current['diagnostics']['forged_extra'] = True
            elif kind in ('flow', 'legacy'): current[0]['diagnostics']['forged_extra'] = True
            else: current['toolbox'][0]['descriptor']['forged_extra'] = True
            row['stdout'] = envelope(json.dumps(current).encode())
        reject(kind + '/changed full compiler channel', report, alter, report_check, 'complete original family channel recurrence')
    for name, mutation, reason in (
        ('lost committed member', lambda value: value['entries'].pop(0), 'complete unique input population'),
        ('extra runtime overlay', lambda value: value['overlays'].append('perl/forged.pm'), 'immutable boundary without overlays'),
        ('forged object bytes', lambda value: value['entries'][0].update(sha256='0' * 64), 'exact immutable input bytes'),
        ('forged executable mode', lambda value: value['entries'][0].update(mode='100755' if value['entries'][0]['mode'] == '100644' else '100644'), 'exact immutable object and mode'),
        ('lost black-box exclusion', lambda value: value['excluded_metadata'].pop(), 'exact black-box metadata exclusions'),
    ): reject(name, manifest, mutation, check_inputs, reason)

    result = {'complete': True, 'revision': REVISION, 'regular_git_inputs': manifest['regular_git_inputs'],
              'runtime_overlays': 0, 'commands': len(report['runs']), 'seeds': 3,
              'original_populations': populations, 'unique_selected_contract_ids': contracts,
              'selected_events_per_seed': sum(row['selected_events_per_seed'] for row in populations.values()),
              'selected_origins_per_seed': sum(row['selected_origins_per_seed'] for row in populations.values()),
              'method_expression_and_csv_frames_per_seed': method_frames,
              'cross_family_representatives': 7, 'nested_pairs_per_seed': 49,
              'off_diagonal_pairs_per_seed': 42, 'fatal_nested_routes_per_seed': 7,
              'representative_events_per_scan': 2, 'fixture_suites': len(TESTS), 'fixture_groups': sum(PLANS),
              'controls': controls, 'instrument_sha256': sha(Path(__file__).read_bytes()),
              'scope': 'Fresh complete committed Git superset without overlays or production/fixture replacements. Original independent five-corpus174-ID population retains436 events/origins per seed; exact complete previous selected producer/callback/compiler/origin channels recur. Actual nesting uses seven representatives/49 ordered pairs/seven caught fatal routes per seed, not all174 IDs or arbitrary callbacks. Original rejected instruments and historical adjudications stay unchanged. Physical source frames, selected origins and46 MethodExpr/CSV frames are distinct populations. Rendered teaching is not extra runtime execution. Exact staged canonical CI independently gates immutable private provenance parent closeout; this record does not publish canonical CI measurements. Quoted/comment executable membership and selected replacement remain separate.'}
    Path(PREFIX + 'verification.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: value for key, value in result.items() if key not in ('controls', 'original_populations')}))
    print(str(len(controls)) + ' effective reason-specific immutable acceptance evidence controls RED')


if __name__ == '__main__': main()
