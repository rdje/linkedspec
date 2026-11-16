"""Verify retained preparation and integrity controls; no SDK or writer replay."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent


def validate(report, sources, expected_paths, selected):
    rows = report['rows']
    paths = [row['path'] for row in rows]
    assert len(paths) == len(set(paths)) and set(paths) == expected_paths, 'consumer population'
    for row in rows:
        assert hashlib.sha256(sources[row['path']]).hexdigest() == row['sha256'], 'consumer source identity'
        assert type(row['required']) is bool and type(row['review_candidate']) is bool, 'proposal shape'
        if row['backend'] == 'perl':
            expected = 'direct-unconditional-perl-selector' if row['path'] in selected else 'no-direct-unconditional-perl-selector'
            assert row['declared_route'] == expected, 'Perl route observation'
        assert all(path in report['artifact_candidates'] for path in row['literal_tracked_references']), 'candidate path identity'
        lines = sources[row['path']].decode('utf-8', 'surrogateescape').splitlines()
        assert all(site['source'] == lines[site['line'] - 1] for site in row['loader_sites']), 'potential source location'


def main():
    spec = importlib.util.spec_from_file_location('retained_discovery_reader', BASE / 'review.py')
    reader = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(reader)
    report, sources, metadata = reader.read_evidence()
    assert subprocess.check_output(['git', 'ls-tree', '-rz', report['activation']]) == reader.channel('git-tree', 'stdout')
    expected_paths = set(reader.channel('git-universe', 'stdout').decode().rstrip('\0').split('\0'))
    expected_paths = {name for name in expected_paths if not name.startswith('rust/') or name.count('/') == 3}
    selected = {event['path'] for event in reader.events(reader.channel('perl-selector', 'stdout')) if event['kind'] == 'selected_test'}
    expected_paths.update(selected)
    validate(report, sources, expected_paths, selected)
    first = json.loads(gzip.decompress((BASE / 'launches/review-first/stdout.gz').read_bytes()))
    final = json.loads(gzip.decompress((BASE / 'launches/review-final/stdout.gz').read_bytes()))
    assert first == final and first['consumers'] == len(report['rows'])
    assert first['required'] == sum(row['required'] for row in report['rows'])
    omissions = sorted(row['path'] for row in report['rows'] if row['required'] and row['backend'] == 'perl' and row['path'] not in selected)
    assert first['direct_perl_omissions'] == omissions, 'recorded proposal epoch'
    mutations = []
    for label in ('missing-consumer', 'duplicate-consumer', 'source-byte', 'route', 'outside-candidate'):
        changed = dict(report, rows=list(report['rows']))
        if label == 'missing-consumer':
            changed['rows'].pop()
        elif label == 'duplicate-consumer':
            changed['rows'].append(changed['rows'][0])
        else:
            index = next(index for index, row in enumerate(changed['rows']) if row['backend'] == 'perl')
            row = dict(changed['rows'][index])
            changed['rows'][index] = row
            if label == 'source-byte':
                row['sha256'] = '0' * 64
            elif label == 'route':
                row['declared_route'] = 'invented-execution'
            else:
                row['literal_tracked_references'] = row['literal_tracked_references'] + ['../outside']
        try:
            validate(changed, sources, expected_paths, selected)
        except AssertionError as error:
            assert str(error) in ('consumer population', 'consumer source identity', 'Perl route observation', 'candidate path identity')
            mutations.append(label)
        else:
            raise AssertionError('ineffective preparation control:' + label)
    controls = json.loads((BASE / 'controls.json').read_bytes())
    assert [row['name'] for row in controls['rejected']] == ['disabled-prove', 'duplicate-prove', 'disabled-syntax', 'missing-private-suite', 'missing-private-helper']
    expected_events = reader.expected_events(sources['tools/run_ci_local.sh'].decode())
    for control in controls['rejected']:
        prefix = BASE / 'controls' / control['name']
        assert prefix.with_name(prefix.name + '-exit.txt').read_text() == '0\n'
        assert gzip.decompress(prefix.with_name(prefix.name + '-stderr.gz').read_bytes()) == b''
        assert reader.events(gzip.decompress(prefix.with_name(prefix.name + '-stdout.gz').read_bytes())) != expected_events
    archive = reader.plan_archive(metadata)
    print(json.dumps(dict(result='PASS', consumers=len(report['rows']), producer_proposals=first['required'],
        proposal_perl_omissions=len(omissions), integrity_controls=mutations,
        selector_controls=[row['name'] for row in controls['rejected']], archive=archive,
        scope='Filename universe, captured classifier proposals and actual stubbed Bash arguments only. Ownership, actual loaders, automatic backend discovery and runtime/canonical execution remain unqualified.'), sort_keys=True))


if __name__ == '__main__':
    main()
