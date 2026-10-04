"""Independently accept the fixed-input callback-source authority guard."""
from pathlib import Path
import copy
import importlib.util
import json
import re

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('guard-review.py')
GUARD = PREFIX + 'guard-'
spec = importlib.util.spec_from_file_location('review', PREFIX + 'review.py')
review = importlib.util.module_from_spec(spec); spec.loader.exec_module(review)
author = review.author
review.PROBE = str(Path(GUARD + 'probe.pl').relative_to(ROOT))
overrides = {review.SOURCES[0]: PREFIX + 'PrimitiveBasicRules-initial.pm',
             review.SOURCES[1]: PREFIX + 'ScannerCore-initial.pm'}
manifests = {mode: json.loads(Path(GUARD + mode + '-inputs.json').read_bytes()) for mode in ('before', 'after')}
reports = {mode: json.loads(Path(GUARD + mode + '.json').read_bytes()) for mode in ('before', 'after')}

def check(report, manifest):
    mode = manifest['mode']
    assert report['complete'] is True and report['mode'] == mode and report['revision'] == review.REVISION, 'complete exact guard report'
    assert report['instrument_sha256'] == author.digest(Path(GUARD + 'capture.py').read_bytes()), 'actual guard producer'
    assert report['stream_instrument_sha256'] == author.digest((ROOT / (review.PREVIOUS + 'capture.py')).read_bytes()), 'actual guard stream producer'
    assert [(row['kind'], row['seed']) for row in report['runs']] == [('fixture', 0), ('toolbox', 0), ('toolbox', 1), ('toolbox', 42)], 'exact guard run population'
    previous = None
    event = {'raw': 'my $other', 'args': {'declaration_type': 'scalar', 'names': ['other'], 'scope': 'my'}}
    origin = {'event': event, 'source': 'my $other;', 'source_span': {'start': 0, 'end': 9}}
    expected = {'source': 'my $input;', 'public': [event],
                'private': {'events': [event], 'source_origins': [origin] if mode == 'before' else []}}
    for row in report['runs']:
        assert row['inputs_before'] == row['inputs_after'] == len(manifest['entries']), 'actual guard input boundaries'
        raw = author.decode(row['stdout']); author.decode(row['stderr'])
        if row['kind'] == 'fixture':
            assert row['command'] == ['bash', 'tools/project_data_run.sh', 'prove', '-v', '-Iperl', review.TEST], 'actual guard fixture command'
            text = raw.decode()
            assert re.findall(r'^1\.\.(\d+)\s*$', text, re.M) == ['29'], 'complete guard fixture plan'
            assert [int(n) for n in re.findall(r'^(?:not )?ok (\d+)\b', text, re.M)] == list(range(1, 30)), 'complete ordered guard fixture reach'
            assert [int(n) for n in re.findall(r'^not ok (\d+)\b', text, re.M)] == ([29] if mode == 'before' else []), 'actual guard distinguishing RED'
            assert row['exit'] == (1 if mode == 'before' else 0), 'actual guard fixture exit'
            assert ('Result: FAIL' if mode == 'before' else 'Result: PASS') in text, 'actual guard fixture completion'
            if mode == 'after':
                assert 'All tests successful.' in text and not re.search(r'^\s*not ok\b', text, re.M), 'complete positive guard fixture'
        else:
            assert row['command'] == ['bash', 'tools/project_data_run.sh', 'perl', '-Iperl', review.PROBE], 'actual guard probe command'
            assert row['exit'] == 0 and author.decode(row['stderr']) == b'', 'complete guard probe exit'
            assert json.loads(raw) == expected, 'independent literal foreign-source oracle'
            assert previous is None or previous == raw, 'exact cross-seed guard channels'
            previous = raw

for mode in ('before', 'after'):
    review.manifest_check(manifests[mode], overrides if mode == 'before' else None, full_production_overlays=True)
    check(reports[mode], manifests[mode])
before = {entry['path']: entry for entry in manifests['before']['entries']}
after = {entry['path']: entry for entry in manifests['after']['entries']}
assert before.keys() == after.keys(), 'same complete guard membership'
assert all(before[path]['mode'] == after[path]['mode'] for path in before), 'same complete guard modes'
assert [path for path in sorted(before) if before[path]['sha256'] != after[path]['sha256']] == [review.SOURCES[1]], 'only private ScannerCore guard changes'
controls = []
for name, change, reason in (
        ('promote partial guard', lambda d: d.update(complete=False), 'complete exact guard report'),
        ('forge guard producer', lambda d: d.update(instrument_sha256='0' * 64), 'actual guard producer'),
        ('erase guard RED', lambda d: d['runs'][0].update(exit=0), 'actual guard fixture exit'),
        ('erase source boundary', lambda d: d['runs'][0].update(inputs_after=0), 'actual guard input boundaries'),
        ('forge probe stdout', lambda d: d['runs'][1]['stdout'].update(sha256='0' * 64), 'channel bytes')):
    candidate = copy.deepcopy(reports['before']); change(candidate)
    try:
        check(candidate, manifests['before'])
    except AssertionError as error:
        assert str(error) == reason, (name, str(error), reason)
        controls.append({'name': name, 'rejected': True, 'reason': reason})
    else:
        raise AssertionError('accepted corruption: ' + name)
result = {'git_inputs': 3811, 'supplied_inputs': len(before), 'fixture_groups': 29,
          'before_failed_groups': [29], 'after_failed_groups': [], 'probe_pairs': 3,
          'controls': controls, 'instrument_sha256': author.digest(Path(__file__).read_bytes()),
          'scope': 'Two complete fixed-input guard boundaries; before uses exact initial producers, after final guard. Only ScannerCore bytes differ; exploratory live probe is separate.'}
Path(GUARD + 'verification.json').write_text(json.dumps(result, indent=2) + '\n')
print('Fixed callback-source guard:29 groups RED1/GREEN0; three exact probe pairs; five reason-specific controls')
