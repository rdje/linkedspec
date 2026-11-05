"""Read-only recovery of complete public observations and actual input modules.

The supplemental writer captured raw channels before its JSON-only summary
parser failed. Recover exactly one identity-checked JSON frame, keep all raw
diagnostics, and resolve historical physical paths as opaque provenance only.
"""
import copy
import gzip
import json
from pathlib import Path, PurePosixPath
import tarfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path('docs/checkpoints/length-selection-2026-11-05')
INITIAL = ('length_compatible', 'length_free_guard', 'length_receiver_guard',
           'key_count_compatible', 'key_count_free_guard', 'key_count_receiver_guard')
INITIAL_EXPECTED = ([5, 5, None, 0], [None, None, ''], [None, 'S'],
                    [2, 2, 0], [None, None, ''], [None, 'S'])


def same(a, b):
    return json.dumps(a, sort_keys=True) == json.dumps(b, sort_keys=True)


def frames(raw):
    found = []
    for line in raw.splitlines():
        try:
            value = json.loads(line)
        except (ValueError, UnicodeDecodeError):
            continue
        if isinstance(value, list) and value and all(
                isinstance(row, dict) and 'id' in row and 'metadata' in row for row in value):
            found.append(value)
    assert len(found) == 1, 'structured frame identity'
    return found[0]


def validate(rows, ids, modules):
    assert [row['id'] for row in rows] == list(ids), 'row population/order'
    for row in rows:
        assert row['native_callable'] == row['loaded'] == 1
        assert not row['warnings']
        assert not any(row.get(key) for key in
                       ('descriptor_error', 'native_build_error', 'emission_error', 'load_error'))
        assert row['metadata'] == dict(language_agnostic_action_ir_ready=1,
            raw_perl_dependency_count=0, canonical_action_ir_fallback_count=0,
            unresolved_helper_count=0)
        assert same(row['native'], row['fresh']), 'native/fresh observed values'
        assert row['native_cursor'] == row['fresh_cursor'] == 0
        if row.get('module_retained_before_load'):
            assert modules[row['id']].decode() == row['emitted_before_load'], 'actual pre-load module'


def main():
    initial = frames(gzip.decompress((ROOT / HERE / 'stdout.json.gz').read_bytes()))
    fixtures = json.loads((ROOT / HERE / 'supplement.json').read_text())
    supplement = ROOT / HERE / 'supplement'
    raw = gzip.decompress((supplement / 'stdout.json.gz').read_bytes())
    rows = frames(raw)
    argv = json.loads(gzip.decompress((supplement / 'command.raw.json.gz').read_bytes()))
    suffix = str(HERE / 'probe.pl')
    assert argv[6].endswith(suffix)
    old_prefix = argv[6][:-len(suffix)]
    modules = {}
    for row in rows:
        captured = row['module_retained_before_load']
        assert captured.startswith(old_prefix)
        relative = PurePosixPath(captured[len(old_prefix):])
        assert not relative.is_absolute() and '..' not in relative.parts
        modules[row['id']] = gzip.decompress((ROOT / relative).read_bytes())
    # Old absolute tar names are preserved raw; consumers use logical root paths.
    with tarfile.open(supplement / 'before-first-get.tar.gz') as archive:
        for member in archive.getmembers():
            name = member.name
            physical_prefix = old_prefix.lstrip('/')
            logical = name[len(physical_prefix):] if name.startswith(physical_prefix) else name
            path = PurePosixPath(logical)
            assert not path.is_absolute() and '..' not in path.parts
            if logical in (str(HERE / 'probe.pl'), str(HERE / 'supplement.json'),
                           str(HERE / 'acquire_supplement.py')):
                assert archive.extractfile(member).read() == (ROOT / path).read_bytes()
    validate(initial, INITIAL, {})
    validate(rows, [row['id'] for row in fixtures], modules)
    for fixture, row in zip(fixtures, rows):
        assert row['body'] == fixture['body']
        assert row['source'] == fixture.get('source', 'Value:: I {' + fixture['body'] + '}')
    rejected = []
    for name in ('missing-row', 'not-ready', 'changed-module'):
        changed = copy.deepcopy(rows)
        changed_modules = dict(modules)
        if name == 'missing-row': changed.pop()
        elif name == 'not-ready': changed[0]['metadata']['language_agnostic_action_ir_ready'] = 0
        else: changed_modules[rows[0]['id']] += b' altered'
        try:
            validate(changed, [row['id'] for row in fixtures], changed_modules)
        except AssertionError:
            rejected.append(name)
        else:
            raise AssertionError('ineffective recovery control: ' + name)
    outcomes = []
    for row, expected in zip(initial, INITIAL_EXPECTED):
        outcomes.append(dict(id=row['id'], matches_target=same(row['native'], expected)))
    for row, fixture in zip(rows, fixtures):
        if fixture.get('expected_error'):
            matches = all(fixture['expected_error'] in json.dumps(row[route + '_error'])
                          for route in ('native', 'fresh'))
        else:
            matches = same(row['native'], fixture['expected'])
        outcomes.append(dict(id=row['id'], matches_target=matches))
    frozen = json.loads((ROOT / 'tests/fixtures/length_result_guard_cases.json').read_text())
    selected = initial[:3] + rows
    assert [r['id'] for r in selected] == [r['id'] for r in frozen]
    assert [r['source'] for r in selected] == [r['source'] for r in frozen]
    for row, target in zip(selected, frozen):
        expected = target.get('expected', target.get('perl_expected'))
        if row['id'] == 'needed_source_error':
            assert target['expected_error'] == 'binding_kind_mismatch'
        else:
            original = (INITIAL_EXPECTED[INITIAL.index(row['id'])] if row['id'] in INITIAL
                        else next(f['expected'] for f in fixtures if f['id'] == row['id']))
            assert same(expected, original), 'frozen target drift'
    for prefix in ('seed', 'module-seed'):
        result = json.loads((ROOT / HERE / (prefix + '-stdout.json')).read_text())
        seeded = result['rows'] if isinstance(result, dict) else result
        assert [r['seed'] for r in seeded] == ['empty', 'outer', 'main']
        assert [r['value'] for r in seeded] == [dict(k=1), dict(k=1), dict(k=1, main='MAIN')]
        assert all(not r['warnings'] and not r['error'] for r in seeded)
        assert (ROOT / HERE / (prefix + '-stderr.log')).read_bytes() == b''
        if prefix == 'module-seed':
            assert [r['main_host'] for r in seeded] == [{}, {}, dict(main='MAIN')]
    carrier = gzip.decompress((ROOT / HERE / 'seed-carrier.pl.gz').read_bytes()).decode()
    public = json.loads((ROOT / HERE / 'seed-stdout.json').read_text())['lowered']
    assert carrier == 'package LinkedSpec::LengthSeedPublic; no strict; sub Run { ' + public + ' }'
    print(json.dumps(dict(result='PASS', outcomes=outcomes, rejected_controls=rejected,
        raw_diagnostics_preserved=True, module_bytes_match_actual_evaluated_strings=True,
        limits='Finite authored observations. Initial emitted strings persisted after execution; supplemental module bytes precede fresh load. Raw physical provenance stays opaque; no native/transitive closure or independent-process isolation.'), sort_keys=True))


if __name__ == '__main__':
    main()
