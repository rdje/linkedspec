"""Read retained classifier sources and reconstruct bounded input/artifact roles."""
import argparse
import copy
import hashlib
import importlib.util
import json
from pathlib import Path, PurePosixPath
import posixpath
import re
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PRIOR = Path('docs/checkpoints/native-consumer-routes-2026-11-16')
ACTIVATION = '616714b225313e54f86a5c3595b9ed38dbe29551'
INSTRUMENTS = {str(BASE / name) for name in ('plan.json', 'capture.py', 'review.py', 'run_step.py')}


def sha(body):
    return hashlib.sha256(body).hexdigest()


def prior_sources():
    refs = json.loads((BASE / 'reused-inputs.json').read_bytes())
    for name, row in refs.items():
        path = Path(name)
        assert path.is_file() and not path.is_symlink()
        assert sha(path.read_bytes()) == row['sha256'] and stat.S_IMODE(path.stat().st_mode) == row['mode'], 'reused identity'
    spec = importlib.util.spec_from_file_location('retained_native_sources', PRIOR / 'review.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.recover()


def image(label):
    identities = json.loads((BASE / (label + '-identities.json')).read_bytes())
    sources = {}
    with tarfile.open(BASE / (label + '.tar.gz')) as archive:
        assert len(archive.getmembers()) == len(identities), 'image population'
        for member in archive:
            name = PurePosixPath(member.name)
            assert member.isfile() and not name.is_absolute() and '..' not in name.parts
            assert str(name) == member.name and member.name not in sources
            body = archive.extractfile(member).read()
            row = identities[member.name]
            assert len(body) == row['bytes'] and sha(body) == row['sha256'], 'image body'
            assert stat.S_IMODE(member.mode) == row['mode'], 'image mode'
            sources[member.name] = body
    assert set(sources) == set(identities)
    return sources, identities


def recover():
    sources, identities = prior_sources()
    for label in ('preparation', 'corpus'):
        extra, modes = image(label)
        assert not set(extra) & set(sources), 'overlapping source epoch'
        sources.update(extra)
        identities.update(modes)
    refs = json.loads((BASE / 'reused-inputs.json').read_bytes())
    tree = json.loads((BASE / 'activation-tree.json').read_bytes())
    assert tree['activation'] == ACTIVATION and tree['exit'] == 0 and tree['stderr_hex'] == ''
    bound = set()
    entries = bytes.fromhex(tree['stdout_hex']).split(b'\0')
    assert entries.pop() == b''
    for entry in entries:
        metadata, raw_name = entry.split(b'\t', 1)
        mode, kind, oid = metadata.split()
        name = raw_name.decode()
        assert name not in bound and kind == b'blob'
        body = sources[name] if name in sources else Path(name).read_bytes()
        row = identities[name] if name in identities else refs[name]
        assert hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest() == oid.decode(), 'activation body'
        assert (int(mode, 8) & 0o777) == row['mode'], 'activation mode'
        bound.add(name)
    assert bound == (set(sources) - INSTRUMENTS) | set(refs), 'activation population'
    return sources, identities


def masked(source):
    """Mask this bounded source's comments and Rust strings, preserving offsets."""
    pattern = r'//[^\n]*|/\*.*?\*/|r(?P<hash>\#+)?".*?"(?P=hash)|r".*?"|"(?:\\.|[^"\\])*"'
    return re.sub(pattern, lambda hit: ''.join('\n' if char == '\n' else ' ' for char in hit[0]), source, flags=re.S)


def functions(source):
    code = masked(source)
    found = {}
    for hit in re.finditer(r'\bfn\s+(\w+)\s*\(', code):
        start = code.index('{', hit.end())
        depth = 1
        end = start + 1
        while depth:
            assert end < len(code), 'bounded function end'
            depth += (code[end] == '{') - (code[end] == '}')
            end += 1
        assert hit[1] not in found, 'unique parent function'
        found[hit[1]] = dict(line=source.count('\n', 0, hit.start()) + 1, body=source[start:end])
    return code, found


def expand(sources):
    plan = json.loads(sources[str(BASE / 'plan.json')])
    manifest = json.loads(sources[plan['manifest']])
    assert manifest['format'] == 1 and manifest['case_count'] == len(manifest['cases']) == 105
    assert len(set(manifest['cases'])) == len(manifest['cases']), 'unique corpus cases'
    assert all(re.fullmatch(r'[A-Za-z0-9_]+', name) for name in manifest['cases']), 'safe captured case paths'
    return [str(PurePosixPath(plan['manifest']).parent / name / suffix)
        for name in manifest['cases'] for suffix in ('input.spec', 'input.txt', 'expected.json')]


def scan(sources):
    plan = json.loads(sources[str(BASE / 'plan.json')])
    assert plan['activation'] == ACTIVATION and plan['cwd'] == '.'
    name = plan['consumer']
    source = sources[name].decode()
    code, funcs = functions(source)
    parent_tests = re.findall(r'#\[test\]\s*fn\s+(\w+)\(', code)
    expected_tests = ['classify_all_generated_source_manifest_cases',
        'count_result_guards_in_independently_compiled_emitted_source', 'count_result_guard_native_trace']
    assert parent_tests == expected_tests, 'three executable parent tests'
    assert 'generated_case_matches_oracle' not in funcs and 'expected_result' not in funcs, 'child templates are not parent functions'
    assert 'const FULL_MANIFEST_CASE_COUNT: usize = 105;' in source
    manifest = json.loads(sources[plan['manifest']])
    targets = expand(sources)
    assert set(('format', 'case_count', 'cases')) <= set(manifest)
    assert 'let manifest: CorpusManifest = serde_json::from_str(&text)' in funcs['load_manifest']['body']
    assert 'Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/corpus")' in funcs['corpus_dir']['body']
    assert 'fs::read_to_string(path)' in funcs['read_utf8']['body']
    edges = [dict(target=plan['manifest'], role='runtime corpus manifest', route='corpus_dir/load_manifest/read_utf8')]
    prepare = funcs['prepare_case']['body']
    suffixes = re.findall(r'read_utf8\(&dir.join\("([^"]+)"\), "read"\)', prepare)
    assert suffixes == ['input.spec', 'input.txt', 'expected.json'], 'all corpus read suffixes'
    assert 'let compatibility_expected = json!([direct_expected.clone()]);' in prepare
    assert all(term in prepare for term in ('parse_spec_with_user_functions(&source)', 'validate(&parsed)',
        'compile(&parsed)', '.execute(&input)', '.execute_value(&input, &ExecutionOptions::new())', 'emit_rust_source_v2(&compiled, &identity)'))
    for target in targets:
        body = sources[target].decode('utf-8')
        if target.endswith('expected.json'):
            json.loads(body)
        edges.append(dict(target=target, case=PurePosixPath(target).parent.name,
            role='runtime corpus ' + PurePosixPath(target).name, route='prepare_case/read_utf8'))
    embeds = list(re.finditer(r'include_str!\(\s*"([^"\n]+)"\s*\)', source))
    assert len(embeds) == code.count('include_str!(') == 3, 'all direct fixture macros'
    count_rows = []
    for index, hit in enumerate(embeds):
        target = posixpath.normpath(str(PurePosixPath(name).parent / hit[1]))
        assert target in plan['count_fixtures']
        rows = json.loads(sources[target])
        assert isinstance(rows, list) and all(isinstance(row, dict) for row in rows)
        assert len({row['id'] for row in rows}) == len(rows)
        parent = expected_tests[1] if index < 2 else expected_tests[2]
        edges.append(dict(target=target, role='compile-time Count fixture', parent=parent,
            rows=len(rows), line=source.count('\n', 0, hit.start()) + 1))
        if index < 2:
            count_rows.extend(row['id'] for row in rows)
    assert len(count_rows) == len(set(count_rows)) == 17, 'combined Count population'
    assert all(re.fullmatch(r'[A-Za-z0-9_]+', row) for row in count_rows)
    trace = funcs[expected_tests[2]]['body']
    selected = re.search(r'for name in \[(.*?)\]', trace)[1]
    trace_names = re.findall(r'"([^"]+)"', selected)
    assert trace_names == ['free_guard_before_with', 'receiver_guard_before_with']
    first_rows = json.loads(sources[plan['count_fixtures'][0]])
    assert all(sum(row['id'] == chosen for row in first_rows) == 1 for chosen in trace_names)
    parser = sources[plan['grammar_owner']].decode()
    assert 'include_str!("../../../specs/user_function_definition.spec")' in parser
    edges.append(dict(target=plan['grammar'], role='compile-time embedded function grammar', route=plan['grammar_owner']))
    main = funcs[expected_tests[0]]['body']
    assert 'Ok(prepared) => prepared_cases.push((case_name.clone(), prepared))' in main
    assert 'project.write_cases(&prepared_cases)' in main
    assert 'if !compile_output.status.success()' in main
    assert 'run_output.status.success()' not in code
    assert 'line.split_once("HOST_RUN_PASS ")' in main and 'passed_host_cases.contains(case_name.as_str())' in main
    focused = funcs[expected_tests[1]]['body']
    assert 'cases.extend(source_owners)' in focused and 'for row in &cases' in focused
    assert 'output.status.success()' in focused
    assert 'TraceConfig::enabled(TraceLevel::DEBUG).with_trace_file(path.clone())' in trace
    assert 'fs::read_to_string(path)' in trace and '.cargo(' not in masked(trace)
    cargo = funcs['cargo']['body']
    assert all(term in cargo for term in ('Command::new("cargo")', '.arg("--offline")', '.arg("--quiet")',
        '.args(args)', '.env("CARGO_TARGET_DIR", self.root.join("target"))', '.current_dir(&self.root)', '.output()'))
    commands = []
    for parent in expected_tests:
        for hit in re.finditer(r'\.cargo\(&\[(.*?)\]\)', funcs[parent]['body'], re.S):
            argv = re.findall(r'"([^"\n]+)"', hit[1])
            guard = ('compile status required' if '--no-run' in argv else
                'run status required' if parent == expected_tests[1] else 'markers counted; run status diagnostic only; SESSION-STARTUP-READING.77 open')
            commands.append(dict(parent=parent, executable='cargo via PATH', args=['--offline', '--quiet'] + argv,
                cwd='${TempProject.root}', target_dir='${TempProject.root}/target', status=guard))
    assert len(commands) == 3
    new = funcs['new']['body']
    assert 'std::env::temp_dir().join(format!(' in new and 'Path::new(env!("CARGO_MANIFEST_DIR"))' in new
    assert 'linkedspec-runtime = {{ path = "{}" }}' in new and 'serde_json = "1"' in new
    assert 'fs::remove_dir_all(&self.root)' in funcs['drop']['body']
    fs_sites = [dict(api=hit[1], line=source.count('\n', 0, hit.start()) + 1)
        for hit in re.finditer(r'\bfs::(\w+)\s*\(', code)]
    assert set(row['api'] for row in fs_sites) == {'create_dir_all', 'write', 'read_to_string', 'remove_dir_all'}
    return dict(owner=plan['owner'], consumer=name, parent_tests=[dict(name=test, line=funcs[test]['line']) for test in parent_tests],
        generated_test_templates=['generated_case_matches_oracle', 'expected_result'], input_edges=edges,
        manifest_metadata={key: value for key, value in manifest.items() if key not in ('format', 'case_count', 'cases')},
        corpus_cases=manifest['cases'], count_rows=count_rows, trace_rows=trace_names, commands=commands, filesystem_sites=fs_sites,
        artifacts=[dict(kind='generated Cargo.toml', selection='each TempProject constructor', dependency='compile-time runtime manifest anchor plus serde_json version request'),
            dict(kind='generated corpus modules and src/lib.rs', selection='successfully prepared subset; never unconditional all105', child_tests='direct value, embedded plan validation and compatibility projection before marker'),
            dict(kind='generated Count modules and src/lib.rs', selection='combined17 fixture rows if all prior preparations succeed', child_tests='expected result or expected-error substring assertion'),
            dict(kind='Cargo target', selection='two Cargo-owning parent tests via shared helper', origin='actual cargo/dependency/cache/native resolution unobserved'),
            dict(kind='runtime trace write/readback', selection=trace_names, source='Engine.execute_with_trace output', parent=expected_tests[2], cargo=False)],
        temporary_root=dict(source='std::env::temp_dir plus pid/nanoseconds', wrapper='tools/run_cargo_local.sh and project_data_env.sh manage outer routing; actual historical environment unobserved', cleanup='TempProject Drop remove_dir_all; no cleanup executed by this reader'),
        limits='Source-resolved potential dependencies and role distinctions only. No Cargo/SDK, emitted bodies, all-case reads/preparation/writes/passes, actual child executable/dependency/cache/manifest anchor, transitive closure, source-origin/per-read/physical custody or new runtime admission. SESSION77 defect remains open; previous admissions remain historical.')


def historical(sources, identities, ledger):
    plan = json.loads(sources[str(BASE / 'plan.json')])
    root = str(PurePosixPath(plan['historical']).parent / 'root-inputs.tar.gz')
    packets = [row['files'] for row in json.loads(sources[plan['historical']]) if row['archive'] == root]
    assert len(packets) == 1
    names = {ledger['consumer'], plan['grammar_owner']} | {row['target'] for row in ledger['input_edges']}
    result = dict(matching=[], absent=[], changed=[])
    for name in sorted(names):
        current = dict(bytes=len(sources[name]), sha256=sha(sources[name]), mode=identities[name]['mode'])
        old = packets[0].get(name)
        if old is None:
            result['absent'].append(name)
        elif old == current:
            result['matching'].append(name)
        else:
            result['changed'].append(dict(path=name, historical=old, current=current))
    assert plan['grammar'] in result['matching'], 'dated grammar identity'
    result['limits'] = 'Dated logical metadata/body/mode comparison, not proof of earlier binary embedding, reads or execution.'
    return result


def controls(sources, identities, ledger):
    result = {}
    for label, field, predicate, replacement in [
        ('corpus-input-omitted', 'input_edges', lambda row: row['role'] == 'runtime corpus input.spec', None),
        ('compile-time-fixture-as-runtime', 'input_edges', lambda row: row['role'] == 'compile-time Count fixture', ('role', 'runtime file lookup')),
        ('embedded-grammar-as-file-read', 'input_edges', lambda row: row['role'] == 'compile-time embedded function grammar', ('role', 'runtime grammar file lookup')),
        ('child-template-as-parent', 'parent_tests', lambda row: row['name'] == 'classify_all_generated_source_manifest_cases', ('name', 'generated_case_matches_oracle')),
        ('failed-child-as-admitted', 'commands', lambda row: 'diagnostic only' in row['status'], ('status', 'run status required; admission complete')),
        ('focused-status-erased', 'commands', lambda row: row['status'] == 'run status required', ('status', 'status diagnostic only')),
        ('cargo-target-origin-erased', 'commands', lambda row: row['status'] == 'compile status required', ('target_dir', '${global Cargo target}')),
        ('all105-written-unconditionally', 'artifacts', lambda row: row['kind'] == 'generated corpus modules and src/lib.rs', ('selection', 'all105 unconditionally written')),
        ('trace-as-authored-fixture', 'artifacts', lambda row: row['kind'] == 'runtime trace write/readback', ('source', 'authored input fixture')),
    ]:
        changed = copy.deepcopy(ledger)
        selected = [i for i, row in enumerate(changed[field]) if predicate(row)]
        assert selected, 'control actual victim'
        victim = changed[field][selected[0]]
        before = copy.deepcopy(victim)
        if replacement is None:
            changed[field].pop(selected[0])
        else:
            key, value = replacement
            assert victim[key] != value, 'effective corruption'
            victim[key] = value
        try:
            assert changed == scan(sources), label
        except AssertionError as error:
            assert str(error) == label
            result[label] = dict(result='RED', actual_victim=before)
        else:
            raise AssertionError('control did not reject')
    plan = json.loads(sources[str(BASE / 'plan.json')])
    baseline = historical(sources, identities, ledger)
    for label, mutate in [('grammar-body-changed', 'body'), ('grammar-mode-changed', 'mode'), ('dated-grammar-hash-forged', 'historical')]:
        changed = dict(sources)
        modes = copy.deepcopy(identities)
        if mutate == 'body':
            changed[plan['grammar']] += b'\n'
        elif mutate == 'mode':
            modes[plan['grammar']]['mode'] ^= 0o100
        else:
            packets = json.loads(changed[plan['historical']])
            root = str(PurePosixPath(plan['historical']).parent / 'root-inputs.tar.gz')
            selected = [row for row in packets if row['archive'] == root]
            assert len(selected) == 1
            selected[0]['files'][plan['grammar']]['sha256'] = '0' * 64
            changed[plan['historical']] = json.dumps(packets).encode()
        try:
            assert historical(changed, modes, ledger) == baseline, label
        except AssertionError as error:
            assert str(error) in (label, 'dated grammar identity')
            result[label] = dict(result='RED', actual_victim=plan['grammar'])
        else:
            raise AssertionError('historical inverse did not reject')
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--current', action='store_true')
    args = parser.parse_args()
    sources, identities = recover()
    ledger = scan(sources)
    assert ledger == json.loads((BASE / 'loaders.json').read_bytes()), 'retained graph'
    current = 0
    if args.current:
        for name, body in sources.items():
            path = Path(name)
            assert path.is_file() and not path.is_symlink() and path.read_bytes() == body, 'current body'
            assert stat.S_IMODE(path.stat().st_mode) == identities[name]['mode'], 'current mode'
            current += 1
    result = dict(result='PASS', retained_inputs=len(sources), current_inputs=current,
        input_bindings=len(ledger['input_edges']), distinct_targets=len({row['target'] for row in ledger['input_edges']}),
        corpus_cases=len(ledger['corpus_cases']), count_rows=len(ledger['count_rows']), trace_rows=ledger['trace_rows'],
        parent_tests=len(ledger['parent_tests']), generated_test_templates=len(ledger['generated_test_templates']),
        command_templates=len(ledger['commands']), filesystem_sites=len(ledger['filesystem_sites']),
        controls=controls(sources, identities, ledger), historical=historical(sources, identities, ledger), limits=ledger['limits'])
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
