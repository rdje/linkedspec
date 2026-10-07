"""Independent retained-channel, original-source, public value and RED reviewer."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review.py')
REVISION = '31395e440a38acec7a6712d470a90a90a6567863'
FIXTURE = 't/actionir_compiler_source_membership.t'
OWNERS = ['perl/LinkedSpec/ActionIR/Scanner.pm', 'perl/LinkedSpec/RuleIR/EmitContext.pm',
          'perl/LinkedSpec/ActionIR/SourceMembership.pm']
PUBLIC = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-'
TESTS = ['t/' + name + '.t' for name in (
    'actionir_executable_source_membership', 'actionir_helper_source_provenance',
    'actionir_ast_parser', 'canonical_event_occurrence_order',
    'actionir_pipeline_regex_source_provenance', 'actionir_pipeline_statement_source_provenance',
    'actionir_statement_source_frames', 'actionir_method_argument_source_frames',
    'actionir_nested_block_source_spans', 'trace_emit_context_bridge',
    'actionir_raw_dependency_metadata', 'actionir_raw_dependency_provenance',
    'actionir_raw_dependency_compatibility', 'generated_source_contract', 'phase0_regression')]
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def decode(block):
    assert block['encoding'] == 'gzip-base64', 'channel encoding'
    raw = gzip.decompress(base64.b64decode(block['data'], validate=True))
    assert len(raw) == block['bytes'] and sha(raw) == block['sha256'], 'complete channel identity'
    return raw


def check_inputs(manifest, mode, preliminary=False, final=False):
    assert manifest['revision'] == REVISION and manifest['mode'] == mode, 'immutable activation'
    expected = {}
    excluded = []
    for row in filter(None, subprocess.check_output(
            ['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT).split(b'\0')):
        metadata, path = row.split(b'\t', 1)
        git_mode, kind, oid, size = metadata.split()
        if kind == b'blob' and git_mode in (b'100644', b'100755'):
            expected[path.decode()] = (git_mode.decode(), oid.decode(), int(size))
        else:
            excluded.append({'path': path.decode(), 'mode': git_mode.decode(), 'kind': kind.decode()})
    overlay = [FIXTURE, str(Path(PREFIX).relative_to(ROOT)) +
               ('capture.py' if preliminary else 'final-capture.py' if final else 'retry-capture.py')]
    entries = {e['path']: e for e in manifest['entries']}
    assert len(entries) == len(manifest['entries']), 'unique inputs'
    assert set(entries) == set(expected) | set(overlay), 'complete supplied input population'
    assert manifest['overlays'] == overlay and manifest['excluded_metadata'] == excluded, 'exact overlays and exclusions'
    replacements = manifest['replacements']
    owners = OWNERS + (['t/phase0_regression.t'] if final else [])
    assert [r['path'] for r in replacements] == (owners if mode == 'after' else []), 'exact owner delta'
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for path, (git_mode, oid, size) in expected.items():
            process.stdin.write((oid + '\n').encode()); process.stdin.flush()
            assert process.stdout.readline().split() == [oid.encode(), b'blob', str(size).encode()], 'Git framing'
            original = process.stdout.read(size); assert process.stdout.read(1) == b'\n'
            entry = entries[path]
            assert (entry['mode'], entry['oid']) == (git_mode, oid), 'original mode/object identity'
            if mode == 'after' and path in owners:
                replacement = next(r for r in replacements if r['path'] == path)
                assert replacement['original'] == {'path': path, 'mode': git_mode, 'oid': oid,
                    'bytes': size, 'sha256': sha(original)}, 'original owner delta identity'
                raw = Path(PREFIX + 'failed-selector.pm').read_bytes() if not final and path == OWNERS[2] else (ROOT / path).read_bytes()
                assert entry == replacement['after'] and entry.get('replacement') is True, 'declared replacement entry'
            else:
                raw = original
                assert not entry.get('replacement'), 'no extra replacement'
            assert (entry['bytes'], entry['sha256']) == (len(raw), sha(raw)), 'input content identity'
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    for path in overlay:
        artifact = path
        if preliminary:
            artifact = PREFIX + ('initial-test.t' if path == FIXTURE else 'initial-capture.py')
        elif not final and path == FIXTURE:
            artifact = PREFIX + 'pre-regression-test.t'
        raw = Path(artifact).read_bytes() if preliminary or (not final and path == FIXTURE) else (ROOT / artifact).read_bytes()
        entry = entries[path]
        assert entry.get('authored_overlay') is True and 'oid' not in entry, 'new authored overlay'
        assert (entry['mode'], entry['bytes'], entry['sha256']) == ('100644', len(raw), sha(raw)), 'overlay content identity'
    return len(entries), len(expected)


def check_report(report, manifest, mode, preliminary=False, final=False):
    assert report['complete'] is True and report['mode'] == mode and report['revision'] == REVISION, 'complete actual capture'
    count, _ = check_inputs(manifest, mode, preliminary, final)
    instrument = PREFIX + ('initial-capture.py' if preliminary else 'final-capture.py' if final else 'retry-capture.py')
    assert report['instrument_sha256'] == sha(Path(instrument).read_bytes()), 'actual instrument identity'
    stream = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
    assert report['stream_instrument_sha256'] == sha((ROOT / stream).read_bytes()), 'stream guard identity'
    assert report['input_tree'].startswith('.linkedspec-data/scratch/compiler-source-membership/' + mode + '-'), 'local input tree'
    assert '..' not in Path(report['input_tree']).parts, 'portable input tree'
    source_cases = json.loads(subprocess.check_output(['git', 'show', REVISION + ':' + PUBLIC + 'cases.json'], cwd=ROOT))
    expected = [('compiler-tap', seed) for seed in (0, 1, 42)]
    if preliminary or mode == 'after':
        expected += [('public:' + c['id'], 0) for c in source_cases]
    expected += [('consumers', 0)]
    assert [(r['kind'], r['seed']) for r in report['runs']] == expected, 'complete ordered commands'
    result = {}
    for row in report['runs']:
        assert row['inputs_before'] == row['inputs_after'] == count, 'complete unchanged input guards'
        assert row['command'][:2] == ['bash', 'tools/project_data_run.sh'], 'project-data command routing'
        stdout, stderr = decode(row['stdout']), decode(row['stderr'])
        text = stdout.decode()
        if row['kind'] == 'compiler-tap':
            assert row['command'][2:] == ['prove', '-v', '-Iperl', FIXTURE], 'exact compiler test command'
            top = re.findall(r'^(?:not )?ok (\d+) - (.+)$', text, re.M)
            cases = json.loads((ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0-cases.json').read_bytes())
            names = [c['id'] for c in cases] + ['compiler bridge preserves callback and caller error contracts']
            if final:
                names += ['numeric slash newline preserves following host quotes']
            names += ['native and independently loaded generated parsers preserve quoted data']
            assert top == [(str(i), n) for i, n in enumerate(names, 1)], 'complete exact compiler test reach'
            assert re.findall(r'^1\.\.(\d+)$', text, re.M) == [str(len(names))], 'compiler test plan'
            failures = re.findall(r'^not ok \d+ - (.+)$', text, re.M)
            assert row['exit'] == int(mode == 'before'), 'actual distinguishing compiler exit'
            if mode == 'after':
                assert not re.search(r'^\s*not ok ', text, re.M) and stderr == b'', 'complete quiet compiler GREEN'
            else:
                assert failures == names, 'original unintegrated compiler RED population'
            result[(row['kind'], row['seed'])] = {'groups': len(names), 'failures': failures}
        elif row['kind'].startswith('public:'):
            name = row['kind'].removeprefix('public:')
            assert row['command'][2:] == ['perl', '-Iperl', PUBLIC + 'probe.pl', name], 'exact original public producer'
            assert row['exit'] == 0 and stderr == b'', 'complete quiet public command'
            doc = json.loads(stdout)
            case = next(c for c in source_cases if c['id'] == name)
            assert doc['id'] == name and doc['source'] == case['source'] and doc['action'] == case['action'], 'original authored source'
            assert doc['source_sha256'] == sha(case['source'].encode()), 'authored source identity'
            result[(row['kind'], row['seed'])] = doc
        else:
            assert row['command'][2:] == ['prove', '-v', '-Iperl'] + (TESTS[:-1] if preliminary else TESTS), 'exact direct consumer selection'
            failed_after = mode == 'after' and not final
            assert row['exit'] == int(failed_after), 'complete direct consumer command exit'
            if not failed_after:
                assert stderr == b'' and not re.search(r'^\s*not ok ', text, re.M), 'quiet complete consumer GREEN'
            plans = [int(n) for n in re.findall(r'^1\.\.(\d+)$', text, re.M)]
            top = re.findall(r'^(?:not )?ok \d+ - (.+)$', text, re.M)
            assert len(plans) == (14 if preliminary else 15) and len(top) == sum(plans), 'complete direct consumer reach'
            if failed_after:
                assert re.findall(r'^not ok \d+ - (.+)$', text, re.M) == [
                    'emit_context_scanner_deps_route_through_owner_default_map',
                    'multiline regex helper validation'], 'exact initial complete Phase0 failure population'
                assert 'Result: FAIL' in text and 'division newline compatibility' in stderr.decode(), 'actual compatibility RED'
            else:
                assert 'All tests successful.' in text and 'Result: PASS' in text, 'actual consumer PASS'
            result[(row['kind'], row['seed'])] = {'groups': len(top), 'plans': plans}
    return result


def check_public(before, after):
    cases = json.loads((ROOT / (PUBLIC + 'cases.json')).read_bytes())
    repaired, remaining, unassessed = [], [], []
    for case in cases:
        key = ('public:' + case['id'], 0)
        a, b = before[key], after[key]
        assert a['source'] == b['source'] and a['ast'] == b['ast'], 'unchanged original public source/AST'
        if 'expected' not in case:
            assert case['role'] in ('unsupported', 'raw'), 'original no-value-oracle scope'
            unassessed.append(case['id'])
            continue
        good = all(b[r]['value'] == case['expected'] and b[r]['exception'] is None
                   for r in ('native', 'fresh'))
        previous = all(a[r]['value'] == case['expected'] and a[r]['exception'] is None
                       for r in ('native', 'fresh'))
        if good and not previous:
            repaired.append(case['id'])
        if not good:
            remaining.append(case['id'])
    # These original value oracles predate the compiler repair, and both routes
    # must improve. Other raw/unsupported/comment/replacement results stay scoped.
    assert {'quoted_set', 'nested_data', 'regex_data'} <= set(repaired), 'original native/fresh value repairs'
    assert after[('public:sentinel_data', 0)]['metadata']['unresolved_helper_count'] > 0, 'diagnostic marker still separately owned'
    return {'public_cases': len(cases), 'repaired_native_fresh': repaired,
            'remaining_value_or_error': remaining, 'no_original_value_oracle': unassessed,
            'authored_value_oracles': len(cases) - len(unassessed)}


def main():
    reports = {k: json.loads(Path(PREFIX + k + '-observations.json').read_bytes())
               for k in ('initial-before', 'before', 'failed-after', 'final-after')}
    manifests = {k: json.loads(Path(PREFIX + k + '-inputs.json').read_bytes()) for k in reports}
    initial = check_report(reports['initial-before'], manifests['initial-before'], 'before', True)
    before = check_report(reports['before'], manifests['before'], 'before')
    failed = check_report(reports['failed-after'], manifests['failed-after'], 'after')
    after = check_report(reports['final-after'], manifests['final-after'], 'after', final=True)
    summary = check_public(initial, after)
    summary.update(compiler_groups=after[('compiler-tap', 0)]['groups'],
                   original_red_groups=before[('compiler-tap', 0)]['groups'], controlled_seeds=[0, 1, 42],
                   direct_consumers=after[('consumers', 0)],
                   original_phase0=before[('consumers', 0)],
                   retained_failed_after=failed[('consumers', 0)],
                   regular_git_inputs=check_inputs(manifests['final-after'], 'after', final=True)[1])
    controls = []
    variants = [
        ('incomplete-capture', lambda r: r.update(complete=False)),
        ('missing-command', lambda r: r['runs'].pop()),
        ('reordered-command', lambda r: r['runs'].reverse()),
        ('wrong-exit', lambda r: r['runs'][0].update(exit=1)),
        ('lost-input-guard', lambda r: r['runs'][0].update(inputs_after=0)),
        ('changed-channel-hash', lambda r: r['runs'][0]['stdout'].update(sha256='0' * 64)),
        ('changed-instrument', lambda r: r.update(instrument_sha256='0' * 64)),
    ]
    for name, mutate in variants:
        variant = copy.deepcopy(reports['final-after']); mutate(variant)
        assert variant != reports['final-after'], 'effective control'
        try:
            check_report(variant, manifests['final-after'], 'after', final=True)
        except AssertionError as error:
            controls.append({'name': name, 'observed_red': str(error)})
        else:
            raise AssertionError('unrejected evidence control: ' + name)
    summary['evidence_controls'] = controls
    summary['instrument_sha256'] = sha(Path(__file__).read_bytes())
    Path(PREFIX + 'verification.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary, indent=2))


if __name__ == '__main__':
    main()
