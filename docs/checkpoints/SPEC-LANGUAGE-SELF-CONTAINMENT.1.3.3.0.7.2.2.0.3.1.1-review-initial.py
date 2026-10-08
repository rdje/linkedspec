"""Recover supplied inputs and distinguish original occurrences from generated text."""
from pathlib import Path
import base64, copy, gzip, hashlib, json, subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review.py')
BASE = '6feff5d40a7e0554425314c120d7ce2b73586a49'
REL = str(Path(PREFIX).relative_to(ROOT))
OWNER = 'perl/LinkedSpec/ActionIR/RewritePipeline.pm'
STREAM = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
RED = {'quoted_before', 'interleaved_equal', 'distinct_twins', 'double_quoted_before',
       'unicode_crlf', 'generated_data', 'set_before', 'lf_quoted_before',
       'crlf_quoted_before', 'lf_generated_data', 'lf_interleaved_equal'}

def sha(raw): return hashlib.sha256(raw).hexdigest()
def read(path): return (ROOT / path).read_bytes()
def data(suffix): return json.loads(Path(PREFIX + suffix + '.json').read_bytes())
def git(*args): return subprocess.check_output(['git', *args], cwd=ROOT)
def unpack(item):
    assert item['encoding'] == 'gzip-base64', 'complete channel encoding'
    raw = gzip.decompress(base64.b64decode(item['data'], validate=True))
    assert len(raw) == item['bytes'] and sha(raw) == item['sha256'], 'complete channel identity'
    return raw
def envelope(raw):
    return dict(encoding='gzip-base64', bytes=len(raw), sha256=sha(raw),
                data=base64.b64encode(gzip.compress(raw, mtime=0)).decode())

def original_inputs():
    entries = {}
    for row in filter(None, git('ls-tree', '-rlz', BASE).split(b'\0')):
        meta, path = row.split(b'\t', 1); mode, kind, oid, size = meta.split()
        if kind == b'blob' and mode in (b'100644', b'100755'):
            entries[path.decode()] = dict(path=path.decode(), mode=mode.decode(), oid=oid.decode(), bytes=int(size))
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for entry in entries.values():
            process.stdin.write((entry['oid'] + '\n').encode()); process.stdin.flush()
            assert process.stdout.readline().split() == [entry['oid'].encode(), b'blob', str(entry['bytes']).encode()]
            raw = process.stdout.read(entry['bytes'])
            assert len(raw) == entry['bytes'] and process.stdout.read(1) == b'\n'
            entry['sha256'] = sha(raw)
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    return entries

BASE_INPUTS = original_inputs()

def verify_graph(manifest, epoch, corrected):
    assert manifest['revision'] == BASE and manifest['regular_git_inputs'] == len(BASE_INPUTS)
    prefix = REL + ('corrected-' if corrected else '')
    overlays = [prefix + suffix for suffix in ('cases.json', 'probe.pl', 'replacement-fixture.t')]
    if epoch == 'after': overlays += [OWNER]
    assert manifest['overlays'] == overlays, 'exact production and authored overlays'
    entries = {e['path']: e for e in manifest['entries']}
    assert len(entries) == len(manifest['entries']) and set(entries) == set(BASE_INPUTS) | set(overlays), 'complete regular graph'
    for path, item in entries.items():
        if path not in overlays:
            assert item == BASE_INPUTS[path], 'exact original Git input ' + path
        else:
            raw = read(REL + 'pipeline-candidate.pm' if path == OWNER else path)
            assert item == dict(path=path, mode=BASE_INPUTS.get(path, {}).get('mode', '100644'),
                                bytes=len(raw), sha256=sha(raw), overlay=True), 'recoverable overlay ' + path
    return len(entries)

TESTS = ['t/' + name + '.t' for name in ('actionir_ast_parser', 'canonical_event_occurrence_order',
    'actionir_nested_block_source_spans', 'actionir_compiler_source_membership',
    'actionir_executable_source_membership', 'trace_emit_context_bridge')]
TESTS += ['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0-origin-fixture.t']

def verify_runs(report, manifest, epoch, corrected):
    assert report['complete'] and report['revision'] == BASE, 'complete epoch'
    prefix = REL + ('corrected-' if corrected else '')
    assert report['instrument_sha256'] == sha(read(prefix + 'capture.py'))
    assert report['stream_instrument_sha256'] == sha(read(STREAM))
    cases = json.loads(read(prefix + 'cases.json'))
    expected = [('mapped-replacement-tap', 0)]
    expected += [('public:' + c['id'], s) for s in (0, 1, 42) for c in cases]
    expected += [('consumers', 0)]
    assert [(r['kind'], r['seed']) for r in report['runs']] == expected, 'complete ordered command population'
    for row in report['runs']:
        assert row['inputs_before'] == row['inputs_after'] == len(manifest['entries']), 'whole supplied input guards'
        out, err = unpack(row['stdout']), unpack(row['stderr'])
        command = ['bash', 'tools/project_data_run.sh']
        if row['kind'].startswith('public:'):
            assert row['command'] == command + ['perl', '-Iperl', prefix + 'probe.pl', row['kind'][7:]]
            assert row['exit'] == 0 and not err, 'complete public outer channels'
        elif row['kind'] == 'mapped-replacement-tap':
            assert row['command'] == command + ['prove', '-v', '-Iperl', prefix + 'replacement-fixture.t']
            assert row['exit'] == (1 if epoch == 'before' else 0) and b'1..10\n' in out
            assert b'Failed tests:  1-9' in out if epoch == 'before' else b'Tests=10' in out and b'Result: PASS' in out
        else:
            assert row['command'] == command + ['prove', '-v', '-Iperl'] + TESTS
            assert row['exit'] == (0 if epoch == 'before' else 1) and b'Files=7, Tests=154' in out
            if epoch == 'before': assert b'Result: PASS' in out
            else:
                assert b'Result: FAIL' in out and b'Failed test:  22' in out
                assert b'raw compatibility return payloads keep the narrow typed helper fallback' in err
    return {(r['kind'], r['seed']): r for r in report['runs']}

def original_character_labels(source, edits):
    # Independent oracle: each original scalar retains a unique label. Inserted
    # and replacement scalars have no original identity. Contiguous surviving
    # labels, rather than the production offset arithmetic, locate an interval.
    labels = list(range(len(source)))
    for edit in edits:
        pos, removed, inserted = (edit[k] for k in ('position', 'removed', 'inserted'))
        assert all(type(v) is int and v >= 0 for v in (pos, removed, inserted))
        assert pos + removed <= len(labels), 'actual edit current bounds'
        labels[pos:pos + removed] = [None] * inserted
    return labels

def check_mapping(packet):
    count = 0
    for query in packet['mapped_spans']:
        origin, mapping, result = (query[k] for k in ('original', 'map', 'result'))
        if origin is None or origin['source'] != mapping['source']:
            assert result is None, 'unknown origin preserves compatibility fallback'
            continue
        start, end = (origin['source_span'][k] for k in ('start', 'end'))
        assert 0 <= start < end <= len(origin['source'])
        assert origin['source'][start:end] == origin['raw'] == query['event']['raw'], 'actual original raw authority'
        labels = original_character_labels(mapping['source'], mapping['edits'])
        assert len(labels) == mapping['length'] == len(query['rewritten']), 'current source-map length'
        wanted = list(range(start, end)); position = -1
        if start in labels:
            candidate = labels.index(start)
            if labels[candidate:candidate + len(wanted)] == wanted and query['rewritten'][candidate:candidate + len(wanted)] == origin['raw']:
                position = candidate
        assert result == {'position': position, 'length': end - start}, 'independent original-character interval oracle'
        count += 1
    for edit in packet['actual_edits']:
        before, after, pos, removed, replacement = (edit[k] for k in ('before', 'after', 'position', 'removed', 'replacement'))
        assert 0 <= pos <= pos + removed <= len(before)
        assert after == before[:pos] + replacement + before[pos + removed:], 'actual substr producer and complete current text'
        mapping = edit['map_after']
        assert mapping['source'] == edit['original_source']
        assert mapping['edits'][-1] == dict(position=pos, removed=removed, inserted=len(replacement)), 'actual edit recorded exactly once'
        assert len(original_character_labels(mapping['source'], mapping['edits'])) == mapping['length'] == len(after)
    return count

def packet(row): return json.loads(unpack(row['stdout']))

def check_public(before, after, cases):
    queries = 0
    for case in cases:
        for seed in (0, 1, 42):
            key = ('public:' + case['id'], seed); left, right = packet(before[key]), packet(after[key])
            for value in (left, right):
                assert value['id'] == case['id'] and value['seed'] == str(seed)
                assert value['source'] == case['source'] and value['action'] == case['action']
                assert value['source_sha256'] == sha(case['source'].encode()), 'exact authored source bytes'
                assert value['substitution'] == value['unobserved_substitution'], 'same-facade observer equivalence'
                assert value['native']['compile_exception'] is None and value['fresh'] is not None, 'complete actual execution routes'
                assert value['dump'] == value['emitted'], 'dump and emitted source agreement'
                assert value['fresh']['emitted_sha256'] == sha(value['emitted'].encode()), 'fresh actual emitted input'
            for field in ('ast', 'scans', 'collection', 'canonicalization'):
                assert left[field] == right[field], 'unchanged source/typed/ref/argument/family topology ' + field
            # No public occurrence or mapping fields are introduced. Original
            # canonical/helper/raw dependency packets remain byte-valued equal;
            # text-derived unresolved diagnostics legitimately reflect new code.
            for field in left['diagnostics']:
                if not field.startswith('unresolved_'):
                    assert left['diagnostics'][field] == right['diagnostics'][field], 'unchanged diagnostic producer ' + field
            for events in (right['diagnostics']['canonical_action_ir_events'], right['diagnostics']['helper_action_ir_events']):
                assert all(not {'source_span', 'source_origins', 'source_map'} & set(e) for e in events), 'private origin only'
            assert right['native']['value'] == right['fresh']['value'] == case['expected_value'], 'independent authored native/fresh value and literal oracle'
            assert not any(right['native'][f] for f in ('exception', 'context_error', 'stdout', 'stderr'))
            assert right['fresh']['exception'] is None and right['fresh']['actual_error_identity'] is None
            assert right['fresh']['stdout'] == right['fresh']['stderr'] == '' and right['fresh']['invocations'] == []
            if case['id'] in RED:
                assert left['native']['value'] is None and left['fresh']['value'] is None
                assert left['native']['context_error'] and left['fresh']['exception'], 'distinguishing original route RED'
                needle = 'Undefined subroutine' if case['id'] == 'set_before' else "Can't modify constant item"
                assert needle in left['native']['context_error']['detail']
                error = left['fresh']['exception']
                assert needle in (error['detail'] if isinstance(error, dict) else error)
            else:
                for field in ('substitution', 'owner_substitution', 'dump', 'emitted', 'metadata', 'native', 'fresh', 'diagnostics'):
                    assert left[field] == right[field], 'complete unchanged healthy route ' + field
            assert not left['mapped_spans'] and not left['actual_edits'], 'original production has no new map helpers'
            queries += check_mapping(right)
            if case['id'] == 'quoted_before':
                raw = case['spans'][0]['raw']
                lookups = [e for e in left['lookups'] if e['raw'] == raw]
                assert [e['position'] for e in lookups] == [32, 11], 'actual original/rewritten wrong-twin RED'
                found = [e for e in right['mapped_spans'] if e['event']['raw'] == raw]
                assert len(found) == 1 and found[0]['original']['source_span'] == {'start': 32, 'end': 53}
                assert found[0]['result'] == {'position': 35, 'length': 21}, 'actual mapped original real occurrence'
                assert found[0]['rewritten'][11:32] == raw, 'preserved translated literal twin'
    return queries

def verify_prior(candidate, original):
    restored = copy.deepcopy(candidate); d = restored['claims'][0]['durability']
    assert d['mode'] == 'historical' and d['revision'] == BASE, 'original exact owning claim boundary'
    d['mode'] = 'live'; del d['revision']
    assert restored == original, 'prior claim mode/revision only; no historical hash refresh'

def main():
    graphs = {}
    for corrected in (False, True):
        for epoch in ('before', 'after'):
            name = ('corrected-' if corrected else '') + epoch
            manifest, report = data(name + '-inputs'), data(name + '-observations')
            verify_graph(manifest, epoch, corrected)
            graphs[name] = verify_runs(report, manifest, epoch, corrected)
    cases = json.loads(read(REL + 'corrected-cases.json'))
    queries = check_public(graphs['corrected-before'], graphs['corrected-after'], cases)
    initial = json.loads(read(REL + 'cases.json'))
    assert [c for c in cases if c['id'] not in ('generated_data', 'lf_generated_data')] == [c for c in initial if c['id'] not in ('generated_data', 'lf_generated_data')]
    for epoch in ('before', 'after'):
        for seed in (0, 1, 42):
            original = packet(graphs[epoch][('public:deferred_body', seed)])
            assert 'observer changed actual substitution' in original['native']['compile_exception']
            assert original['fresh'] is None, 'retained initial guard is not execution acceptance'
            for name in ('generated_data', 'lf_generated_data'):
                original = packet(graphs[epoch][('public:' + name, seed)])
                assert original['native']['value'] == original['fresh']['value'] == [None, 1], 'retained invalid one-argument source result'
    corrections = data('corrections')
    assert corrections['complete'] and corrections['unchanged_source_oracles'] == 16
    for suffix, digest in corrections['inputs'].items(): assert sha(read(REL + suffix)) == digest
    assert read(REL + 'replacement-fixture.t') == read(REL + 'corrected-replacement-fixture.t'), 'same authored interval fixture'
    inverse = data('inverse'); assert inverse['complete'] and len(inverse['controls']) == 12
    assert inverse['producer_sha256'] == sha(read(REL + 'inverse.py'))
    assert inverse['inputs_manifest_sha256'] == sha(read(REL + 'corrected-after-inputs.json'))
    assert inverse['baseline']['exit'] == 0 and b'Result: PASS' in unpack(inverse['baseline']['stdout'])
    unpack(inverse['baseline']['stderr'])
    for item in inverse['controls']:
        raw = read(REL + 'pipeline-candidate.pm' if item['path'] == OWNER else item['path']); assert sha(raw) == item['original_sha256']
        old, new = item['mutation']['old'], item['mutation']['new']; assert raw.decode().count(old) == 1
        assert sha(raw.decode().replace(old, new).encode()) == item['mutated_sha256']
        assert item['exit'] != 0 and b'1..10\n' in unpack(item['stdout'])
        assert ("Failed test '" + item['oracle'] + "'").encode() in unpack(item['stderr']), 'effective semantic production inverse'
        assert item['inputs_before'] == item['inputs_after'] == len(data('corrected-after-inputs')['entries'])
    activation = data('activation'); original = json.loads(git('show', BASE + ':' + activation['prior_path']))
    prior = json.loads(read(activation['prior_path'])); verify_prior(prior, original)
    assert activation['inputs_verified'] == len(original['claims'][0]['durability']['inputs']) == 127
    assert activation['original_sha256'] == sha(git('show', BASE + ':' + activation['prior_path']))
    assert activation['frozen_sha256'] == sha(read(activation['prior_path']))
    for item in original['claims'][0]['durability']['inputs']: assert sha(git('show', BASE + ':' + item['path'])) == item['sha256']
    controls = []
    def reject(name, callback):
        try: callback()
        except (AssertionError, KeyError, ValueError) as error:
            controls.append(dict(name=name, observed='RED', reason=str(error))); return
        raise AssertionError('ineffective evidence control ' + name)
    manifest = data('corrected-after-inputs')
    changed = copy.deepcopy(manifest); changed['entries'].pop()
    reject('missing-original-input', lambda: verify_graph(changed, 'after', True))
    changed = copy.deepcopy(manifest); next(e for e in changed['entries'] if e['path'] == OWNER)['sha256'] = '0' * 64
    reject('forged-current-producer', lambda: verify_graph(changed, 'after', True))
    report = data('corrected-after-observations'); changed_report = copy.deepcopy(report); changed_report['runs'].pop()
    reject('omitted-consumer-result', lambda: verify_runs(changed_report, manifest, 'after', True))
    channel = copy.deepcopy(report['runs'][1]['stdout']); channel['sha256'] = '0' * 64
    reject('forged-complete-channel', lambda: unpack(channel))
    for name, mutate in (
        ('validly-rehashed-wrong-value', lambda p: p['native'].update(value=['corrupted', 1])),
        ('validly-rehashed-wrong-event-reference', lambda p: p['canonicalization'][0].update(canonical_id=-1)),
        ('validly-rehashed-wrong-current-interval', lambda p: p['mapped_spans'][1]['result'].update(position=11)),
        ('validly-rehashed-lost-edit', lambda p: p['mapped_spans'][1]['map']['edits'].clear()),
        ('validly-rehashed-changed-actual-edit', lambda p: p['actual_edits'][0].update(after='changed')),
        ('validly-rehashed-foreign-original', lambda p: p['mapped_spans'][1]['original'].update(source='foreign')),
    ):
        changed = copy.deepcopy(graphs['corrected-after']); key = ('public:quoted_before', 0)
        value = packet(changed[key]); mutate(value); changed[key]['stdout'] = envelope((json.dumps(value) + '\n').encode())
        reject(name, lambda: check_public(graphs['corrected-before'], changed, cases))
    changed = copy.deepcopy(prior); changed['claims'][0]['durability']['revision'] = git('rev-parse', BASE + '^1').decode().strip()
    reject('wrong-original-boundary', lambda: verify_prior(changed, original))
    changed = copy.deepcopy(prior); changed['claims'][0]['durability']['inputs'][0]['sha256'] = '0' * 64
    reject('refreshed-original-hash', lambda: verify_prior(changed, original))
    result = dict(complete=True, revision=BASE, producer_sha256=sha(Path(__file__).read_bytes()),
        original_regular_inputs=len(BASE_INPUTS), supplied_graphs=4, corrected_public_pairs=54,
        repaired_source_seed_pairs=33, unchanged_source_seed_pairs=21,
        native_fresh_values=108, independently_mapped_queries=queries, fixture_red_groups=9,
        fixture_green_groups=10, consumer_groups_each_epoch=154, original_consumer_pass_groups=154, candidate_consumer_pass_groups=153, source_inverse_controls=12,
        original_guard_inputs_verified=127, evidence_controls=controls,
        scope='Four full regular Git supplied supersets recover exact original metadata/hashes plus explicit three authored overlays and only one after production owner. Original flawed facade guard and invalid cat channels remain complete and separate. Corrected same-facade accepted-source population establishes33 repaired and21 unchanged source/seed pairs,108 native/fresh values; original source/AST/selected refs/args/copies/family/raw packets remain exact. Healthy generated/value/error/effect/diagnostic packets remain exact without normalization. Original character-label survival independently validates actual mapped spans and all actual edit substr results. Candidate is rejected: one of154 direct consumer groups fails raw compatibility nested capture lowering; guarded nonempty-guard Toolbox execution distinguishes unresolved2 host calls; Phase0 aborts at926 with98 failures and no final plan. Production is restored exactly to Base6fe. This is bounded diagnosis, not repair, readiness/diagnostic-origin, arbitrary grammar, other backend, recurring CI or canonical admission; OS/tool standard dependencies readonly, project data local.')
    Path(PREFIX + 'verification.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))

if __name__ == '__main__': main()
