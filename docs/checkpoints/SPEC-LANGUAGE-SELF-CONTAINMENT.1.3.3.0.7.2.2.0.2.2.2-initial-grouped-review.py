"""Grade actual grouped-pattern source authority and successful-value counterexamples."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import importlib.util
import json

ROOT = Path(__file__).resolve().parents[2]
PREFIX = str(Path(__file__).resolve()).removesuffix('grouped-review.py')
REVISION = '0f31461d696186775585e19355a0bc5c41849dfb'
STREAM = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
PARAMS = ('x,y', 'x,z', 'x,...y')
PATTERNS = ('/(set(counter,1)).*x/', '/(set(counter,1)),x/')


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


def action(params, pattern):
    return 'cb={|' + params + '| return(matches("setcounter,1,x", ' + pattern + ')) }; return(cb("ok","unused"))'


def check_primitive(rows):
    assert [(r['params'], r['pattern']) for r in rows] == [(p, q) for p in PARAMS for q in PATTERNS], 'authored grouped source population'
    for row in rows:
        source = action(row['params'], row['pattern']); start = source.index('set(counter,1)')
        assert row['action'] == source and row['contract'] == 'set_value', 'original grouped action/contract'
        assert row['expected_events'] == [] and row['expected_value'] == 1, 'independent data/value oracle'
        assert row['value'] == 1 and row['context_error'] is None, 'native value conceals membership defect'
        expected = 1 if row['params'] == 'x,y' else 0
        assert row['observed_events'] == (['set(counter,1)'] if expected else []), 'actual distinguishing primitive selection'
        assert row['original_origins'] == [{'raw': 'set(counter,1)',
            'span': {'start': start, 'end': start + 14}, 'selected': expected}], 'actual reference-bound primitive origin'
        slash = source.index('/'); end = slash + len(row['pattern'])
        assert slash < start < start + 14 < end, 'authored event belongs to grouped pattern data'
        assert row['helper_patterns'] == ([] if expected else [[slash, end]]), 'missing role distinguishes fixed operator suffix'
        assert any(a <= slash < end <= b for a, b in row['literal_ranges']) is bool(not expected), 'actual pattern-data range membership'
        assert 'LinkedSpec::CodeblockRuntime::invoke' in row['substitution'], 'original callable lowering remains active'


def check_returns(rows):
    patterns = ('/(return(fake)).*x/', '/(return(fake)),x/')
    assert [(r['params'], r['pattern']) for r in rows] == [(p, q) for p in PARAMS for q in patterns], 'authored return-family population'
    for row in rows:
        body = 'return(matches("returnfake,x", ' + row['pattern'] + '))'
        source = 'cb={|' + row['params'] + '| ' + body + ' }; return(cb("ok","unused"))'
        assert row['action'] == source and row['expected_returns'] == [body, 'return(cb("ok","unused"))'], 'authored return-source oracle'
        assert row['observed_returns'] == row['expected_returns'], 'return-family-only control passes'
        assert row['expected_value'] == row['value'] == 1 and row['context_error'] is None, 'return-family-only native control passes'


def check_public(rows):
    assert [(r['params'], r['pattern']) for r in rows] == [(p, q) for p in PARAMS for q in PATTERNS], 'original full public population'
    for row in rows:
        source = action(row['params'], row['pattern']); offset = 3 if row['params'] == 'x,...y' else 0
        assert row['action'] == source and row['source'] == 'Top:: I { ' + source + ' }', 'original public source'
        assert row['expected'] == row['native']['value'] == row['fresh']['value'] == 1, 'authored native/fresh value counterexample'
        assert row['errors'] == {} and row['native']['context_error'] is None and row['fresh']['exception'] is None, 'public routes remain successful'
        assert row['native']['stdout'] == row['native']['stderr'] == row['fresh']['stdout'] == row['fresh']['stderr'] == '', 'quiet original public channels'
        block = row['ast']; literal = block['statements'][0]['expr']['value']
        assert block['kind'] == 'action_block' and block['source'] == source and len(block['statements']) == 2, 'original full typed action AST'
        assert literal['kind'] == 'codeblock_literal', 'original callable literal kind'
        assert literal['signature']['positional_params'] == (['x'] if offset else row['params'].split(',')), 'original positional signature'
        assert literal['signature']['rest_param'] == ('y' if offset else None), 'original rest signature'
        regex = literal['body_ast']['statements'][0]['expr']['args'][0]['args'][1]
        assert regex['kind'] == 'regex' and regex['source'] == row['pattern'] and regex['pattern'] == row['pattern'][1:-1], 'original typed grouped regex data'
        expected = 1 if row['params'] == 'x,y' else 0
        origins = row['source_origins']; assert len(origins) == 4, 'complete real public compiler origin population'
        for origin in origins:
            span = origin['span']; assert source[span['start']:span['end']] == origin['raw'], 'original exact public source authority'
            assert origin['selected'] == (expected if origin['raw'] == 'set(counter,1)' else 1), 'real public selected occurrence'
        primitive = [o for o in origins if o['raw'] == 'set(counter,1)']
        assert len(primitive) == 1 and primitive[0]['span'] == {'start': 45 + offset, 'end': 59 + offset}, 'actual primitive scalar span'
        assert row['metadata']['helper_action_ir_hits'] == {'ASSIGN': 1 + expected, 'RETURN': 2}, 'extra public assignment counter'
        assert row['metadata']['canonical_action_ir_count'] == 3 + expected, 'extra public canonical event counter'
        assert row['metadata']['language_agnostic_action_ir_ready'] == 1, 'unchanged ready status is not membership acceptance'
        closer = 8 + offset
        assert row['signature_closer'] == {'start': closer, 'host_quote_end': len(source) + 2 if expected else None}, 'actual host quote suffix consumes the action tail'
        slash = source.index('/'); assert row['pattern_start'] == slash and row['numeric_slash_discriminator'] == 1, 'preserved grouped numeric discriminator'
        assert row['helper_patterns'] == ([] if expected else [[slash, slash + len(row['pattern'])]]), 'actual missing helper-pattern role'
        assert row['fresh']['emitted_sha256'] == sha(row['emitted'].encode()) and row['dump'], 'actual independently loaded emitted module'


def check_report(report, kind, count):
    assert report['complete'] is True and report['revision'] == REVISION, 'complete committed supplemental capture'
    capture_name = 'grouped-capture.py' if kind == 'grouped' else 'cause-capture.py'
    assert report['instrument_sha256'] == sha(Path(PREFIX + capture_name).read_bytes()), 'actual supplemental capture producer'
    assert report['stream_instrument_sha256'] == sha((ROOT / STREAM).read_bytes()), 'actual input/channel producer'
    assert report['input_manifest_sha256'] == sha(Path(PREFIX + 'inputs.json').read_bytes()), 'exact committed input manifest'
    manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    assert manifest['revision'] == REVISION and manifest['overlays'] == [], 'no production/test overlays'
    programs = ('return-grouped-probe.pl', 'grouped-probe.pl') if kind == 'grouped' else ('cause-probe.pl',)
    assert [(r['kind'], r['seed']) for r in report['runs']] == [(p, s) for p in programs for s in (0, 1, 42)], 'complete ordered supplemental commands'
    for run in report['runs']:
        assert run['exit'] == 0 and decode(run['stderr']) == b'', 'complete quiet supplemental execution'
        assert run['inputs_before'] == run['inputs_after'] == count, 'unchanged complete committed inputs'
        path = Path(PREFIX + run['kind']); relative = path.relative_to(ROOT).as_posix()
        assert run['producer'] == relative and run['producer_sha256'] == sha(path.read_bytes()), 'actual separately supplied read-only observer'
        assert run['command'] == ['bash', 'tools/project_data_run.sh', 'perl', '-Iperl',
            {'read_only_program_from_repository_root': relative}], 'portable actual program metadata'
        assert json.loads(decode(run['actual_command'])) == ['bash', 'tools/project_data_run.sh', 'perl', '-Iperl', str(path)], 'complete actual runtime argv'
        rows = json.loads(decode(run['stdout']))
        if run['kind'] == 'return-grouped-probe.pl': check_returns(rows)
        elif run['kind'] == 'grouped-probe.pl': check_primitive(rows)
        else: check_public(rows)


def change_row(report, key, value):
    run = report['runs'][0]; rows = json.loads(decode(run['stdout']))
    rows[0][key] = value; run['stdout'] = envelope(json.dumps(rows).encode())


def main():
    spec = importlib.util.spec_from_file_location('corrected_membership_reviewer', Path(PREFIX + 'review.py'))
    main_review = importlib.util.module_from_spec(spec); spec.loader.exec_module(main_review)
    manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes()); count = main_review.check_inputs(manifest)
    grouped = json.loads(Path(PREFIX + 'grouped-observations.json').read_bytes())
    public = json.loads(Path(PREFIX + 'cause-observations.json').read_bytes())
    check_report(grouped, 'grouped', count); check_report(public, 'cause', count)
    original_raw = gzip.decompress(Path(PREFIX + 'initial-grouped-observations.json.gz').read_bytes())
    original = json.loads(original_raw)
    assert original['complete'] and original['instrument_sha256'] == sha(Path(PREFIX + 'initial-grouped-capture.py').read_bytes()), 'exact original supplemental producer'
    for old, current in zip(original['runs'], grouped['runs']):
        assert (old['kind'], old['seed'], old['exit']) == (current['kind'], current['seed'], current['exit'])
        assert decode(old['stdout']) == decode(current['stdout']) and decode(old['stderr']) == decode(current['stderr']), 'all original supplemental channels unchanged'
        assert old['command'] == json.loads(decode(current['actual_command'])), 'original absolute runtime argv retained as encoded evidence'
    controls = []
    for name, mutate in (
        ('incomplete public capture', lambda r: r.update(complete=False)),
        ('missing public command', lambda r: r['runs'].pop()),
        ('lost full input guard', lambda r: r['runs'][0].update(inputs_after=0)),
        ('forged producer', lambda r: r.update(instrument_sha256='0' * 64)),
        ('forged channel', lambda r: r['runs'][0]['stdout'].update(sha256='0' * 64)),
        ('lost source authority', lambda r: change_row(r, 'action', 'changed source')),
        ('lost actual origins', lambda r: change_row(r, 'source_origins', [])),
        ('invented healthy assignment count', lambda r: change_row(r, 'metadata', {'helper_action_ir_hits': {'ASSIGN': 1, 'RETURN': 2}})),
        ('invented helper-pattern role', lambda r: change_row(r, 'helper_patterns', [[43, 64]])),
        ('changed host-quote cause', lambda r: change_row(r, 'signature_closer', {'start': 8, 'host_quote_end': None})),
        ('invented native failure', lambda r: change_row(r, 'native', {'value': None})),
        ('invented fresh failure', lambda r: change_row(r, 'fresh', {'value': None})),
    ):
        changed = copy.deepcopy(public); mutate(changed); assert changed != public, 'effective diagnostic corruption'
        try: check_report(changed, 'cause', count)
        except AssertionError as error: controls.append({'name': name, 'observed_red': str(error)})
        else: raise AssertionError('unrejected diagnostic corruption: ' + name)
    summary = {'complete': True, 'revision': REVISION, 'supplied_committed_inputs': count,
        'supplemental_commands': 9, 'primitive_source_seed_observations': 18,
        'selected_pattern_data_origins': 6, 'excluded_control_origins': 12,
        'passing_return_family_observations': 18, 'public_source_seed_pairs': 18,
        'successful_native_fresh_values': 36, 'public_assignment_counts': {'x,y': 2, 'x,z': 1, 'x,...y': 1},
        'membership_closed': False, 'controls': controls,
        'retained_original_bytes': len(original_raw), 'retained_original_sha256': sha(original_raw),
        'instrument_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'grouped-verification.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary, indent=2))


if __name__ == '__main__':
    main()
