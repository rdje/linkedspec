"""Verify rejected candidate's guarded nested-helper mechanism and partial Phase0 limit."""
from pathlib import Path
import copy, importlib.util, json, subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('regression-review.py')
REL = str(Path(PREFIX).relative_to(ROOT))
spec = importlib.util.spec_from_file_location('interval_review', PREFIX + 'review.py')
review = importlib.util.module_from_spec(spec); spec.loader.exec_module(review)

def check(report):
    assert report['complete'] and report['revision'] == review.BASE
    assert report['producer_sha256'] == review.sha(review.read(REL + 'regression-capture.py'))
    assert report['original_manifest_sha256'] == review.sha(review.read(REL + 'corrected-before-inputs.json'))
    assert [r['epoch'] for r in report['runs']] == ['original', 'candidate'], 'actual complete epoch pair'
    original_entries = {e['path']: e for e in review.data('corrected-before-inputs')['entries']}
    packets = []
    for row in report['runs']:
        wanted = [REL + 'regression-cases.json', REL + 'regression-probe.pl']
        if row['epoch'] == 'candidate': wanted += [review.OWNER]
        assert row['overlays'] == wanted
        entries = {e['path']: e for e in row['supplied_entries']}
        assert len(entries) == len(row['supplied_entries']) and set(entries) == set(original_entries) | set(wanted)
        for path, item in entries.items():
            if path not in wanted:
                assert item == original_entries[path], 'exact original input graph'
            else:
                source = REL + 'pipeline-candidate.pm' if path == review.OWNER else path
                raw = review.read(source)
                assert item == dict(path=path, mode='100644', bytes=len(raw), sha256=review.sha(raw),
                                    overlay=True, recover_from=source), 'exact regression overlay'
        assert row['inputs_before'] == row['inputs_after'] == len(entries)
        assert row['command'] == ['bash', 'tools/project_data_run.sh', 'perl', '-Iperl', REL + 'regression-probe.pl', 'nonempty_guard']
        assert row['exit'] == 0 and not review.unpack(row['stderr'])
        packet = review.packet(row); packets.append(packet)
        case = json.loads(review.read(REL + 'regression-cases.json'))[0]
        assert packet['source'] == case['source'] and packet['action'] == case['action']
        assert packet['source_sha256'] == review.sha(case['source'].encode())
        assert packet['substitution'] == packet['unobserved_substitution']
        assert packet['native']['compile_exception'] is None and packet['fresh'] is not None
        assert packet['dump'] == packet['emitted']
        assert packet['fresh']['emitted_sha256'] == review.sha(packet['emitted'].encode())
    original, candidate = packets
    for key in ('ast', 'scans', 'collection', 'canonicalization'):
        assert original[key] == candidate[key], 'unchanged exact event/reference/argument inputs'
    assert original['native']['value'] == original['fresh']['value'] == [['a']]
    assert not original['native']['context_error'] and original['fresh']['exception'] is None
    assert candidate['native']['value'] is None and candidate['fresh']['value'] is None
    assert 'Undefined subroutine' in candidate['native']['context_error']['detail']
    assert '::capture_slice called' in candidate['native']['context_error']['detail']
    assert '::capture_slice called' in candidate['fresh']['exception']['detail']
    assert candidate['metadata']['unresolved_helper_count'] == 2
    assert candidate['metadata']['unresolved_helper_hits'] == {'capture_slice': 2}
    assert original['metadata']['unresolved_helper_count'] == 0
    review.check_mapping(candidate)
    queries = [q for q in candidate['mapped_spans'] if q['event']['contract_id'] == 'capture_slice']
    assert len(queries) == 2
    assert [q['original']['source_span'] for q in queries] == [{'start': 20, 'end': 35}, {'start': 57, 'end': 72}]
    assert all(q['result'] == {'position': -1, 'length': 15} for q in queries), 'actual nested intervals discarded'
    assert candidate['substitution'].count('capture_slice()') == 2, 'actual generated executable calls retained'
    assert len(candidate['actual_edits']) == 3
    assert [e['removed'] for e in candidate['actual_edits']] == [38, 34, 7], 'containing IF/PUSH/ENDIF edits execute first'
    source = review.read(REL + 'pipeline-candidate.pm').decode()
    assert source.count('  elsif ($edit->{position} < $end) {\n   return $missing;') == 1, 'reached consumed interval owner'
    return packets

report = review.data('regression'); check(report)
controls = []
for name, mutate in (
    ('lost-epoch', lambda r: r['runs'].pop()),
    ('wrong-original-native', lambda p: p['native'].update(value=None)),
    ('hidden-nested-candidate-error', lambda p: p['native'].update(context_error=None)),
    ('hidden-copied-executable-calls', lambda p: p.update(substitution='nothing', unobserved_substitution='nothing')),
    ('wrong-retained-nested-origin', lambda p: p['mapped_spans'][-1]['original']['source_span'].update(start=0)),
):
    candidate = copy.deepcopy(report)
    if name == 'lost-epoch': mutate(candidate)
    else:
        row = candidate['runs'][0 if name == 'wrong-original-native' else 1]
        packet = review.packet(row); mutate(packet)
        row['stdout'] = review.envelope((json.dumps(packet) + '\n').encode())
    try: check(candidate)
    except (AssertionError, KeyError, TypeError) as error:
        controls.append(dict(name=name, observed='RED', reason=str(error)))
    else: raise AssertionError('ineffective nested mechanism control ' + name)

phase0 = review.data('phase0-diagnostic')
channel = review.unpack(phase0['combined_output'])
assert phase0['complete_process'] and phase0['exit'] == 1
assert b'Failed 98/926 subtests' in channel and b'Parse errors: No plan found in TAP output' in channel
assert b'Result: FAIL' in channel and b'not ok 926 - pplugin_parser_smoke' in channel
assert b'Undefined subroutine &LinkedSpec::SpecEntry::entry_named called' in channel
assert phase0['candidate_sha256'] == review.sha(review.read(REL + 'pipeline-candidate.pm'))
assert phase0['phase0_harness_sha256'] == review.sha(review.read('t/phase0_regression.t'))
assert phase0['input_limit_owner'].endswith('.1.1.1'), 'unmeasured full-input leg has a repair owner'
assert review.read(review.OWNER) == subprocess.check_output(['git', 'show', review.BASE + ':' + review.OWNER], cwd=ROOT), 'production restored exactly'
result = dict(complete=True, producer_sha256=review.sha(Path(__file__).read_bytes()),
    guarded_epochs=2, healthy_original_route_values=2, failed_candidate_routes=2,
    discarded_nested_intervals=2, direct_candidate_consumer_failed_groups=1,
    partial_phase0_failed_groups=98, partial_phase0_observed_groups=926, phase0_complete_suite=False,
    controls=controls, scope='Guarded full regular Git copies independently reproduce the exact accepted original value and rejected candidate nested helper failure. Actual selected references/args/AST remain identical. Three outer edits consume two nested origins although generated executable calls remain; candidate known span lookup declines them. Root Phase0 is supplemental complete process output, aborting at926/no final plan; it is not a complete1035 proof or a guarded exact-input graph. All current production bytes match6fe; producer-bound nested/raw continuation repair remains P1 .1.1.1.')
Path(PREFIX + 'regression-verification.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
