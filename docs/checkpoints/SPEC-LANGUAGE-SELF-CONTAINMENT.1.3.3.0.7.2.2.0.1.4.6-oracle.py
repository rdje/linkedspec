"""Independent literal event/source and original Legacy authority oracle."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.6-'

def check(rows, cases, epoch):
    assert epoch in ("before", "after")
    owned = {"call", "push_single_arg", "push_indexed_arg", "push_target_arg", "push_target_indexed_arg", "push_scope_target_arg", "return_general", "return"}
    assert [r['id'] for r in rows] == [c['id'] for c in cases], 'complete original case order'
    assert len(rows) == 115, '112 contracts plus three controls'
    origins = events = 0
    for case, row in zip(cases, rows):
        assert row['action'] == case['action'], 'exact original source'
        assert row['failure'] is None and row['internal_stderr'] == '', 'successful Toolbox channels'
        assert row['internal_stdout'] == '', 'quiet actual probe channels'
        assert len(row['rows']) == 1, 'one exact dispatcher contract'
        result = row['rows'][0]
        assert result['contract'] == case['contracts'][0], 'original contract identity'
        assert result['public_events'] == result['private_result']['events'] == case['expected_events'], 'literal original events and arguments'
        assert result['public_calls'] == result['private_calls'], 'exact default callback sequence and results'
        expected_origins = []
        if case['contracts'][0] in owned or case['family'] in ('anonymous-capture','named-capture','mark-control','cursor-input') or (epoch == 'after' and case['family']=='entry-match'):
            for event, (start, end) in zip(case['expected_events'], case['original_spans']):
                expected_origins.append({'event': event, 'source': case['action'],
                                         'source_span': {'start': start, 'end': end}})
        assert result['private_result']['source_origins'] == expected_origins, 'exact original source origin population'
        assert len(result['identity']) == len(expected_origins), 'complete actual origin identities'
        assert all(i == {'origin_event': True, 'constructed_event': True, 'constructed_args': True}
                   for i in result['identity']), 'actual returned constructor argument references'
        for event, (start, end) in zip(case['expected_events'], case['original_spans']):
            assert case['action'][start:end] == event['raw'], 'independently authored scalar slice'
        if case['toolbox']:
            assert all(row[k] is not None for k in ('substitution', 'diagnostics', 'dump')), 'complete original public compiler channels'
        else:
            assert all(row[k] is None for k in ('substitution', 'diagnostics', 'dump')), 'explicit bounded compiler population'
        origins += len(expected_origins)
        events += len(case['expected_events'])
    assert (origins, events) == (163 if epoch == 'before' else 227, 227), 'original measured origin/event population'
    quoted = rows[-1]['rows'][0]['public_events'][0]['args']['boundaries']
    assert quoted == cases[-1]['intended_boundaries'], 'current repaired whole quoted labels retained'
    return origins, events
