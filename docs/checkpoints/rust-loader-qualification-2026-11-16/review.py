"""Reconstruct Rust compile-time and conditional filesystem input roles."""
import argparse
import copy
import gzip
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
ACTIVATION = 'beab9517fe9ee05d54709153922282cc3bbac535'
def sha(body):
    return hashlib.sha256(body).hexdigest()


def prior_sources():
    references = json.loads((BASE / 'reused-inputs.json').read_bytes())
    for name, row in references.items():
        path = Path(name)
        assert path.is_file() and not path.is_symlink()
        assert sha(path.read_bytes()) == row['sha256'] and stat.S_IMODE(path.stat().st_mode) == row['mode'], 'reused source identity'
    spec = importlib.util.spec_from_file_location('retained_native_epoch', PRIOR / 'review.py')
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    return module.recover()


def image(label):
    identities = json.loads((BASE / (label + '-identities.json')).read_bytes()); sources = {}
    with tarfile.open(BASE / (label + '.tar.gz')) as archive:
        assert len(archive.getmembers()) == len(identities), 'image population'
        for member in archive:
            name = PurePosixPath(member.name)
            assert member.isfile() and not name.is_absolute() and '..' not in name.parts and str(name) == member.name
            assert member.name not in sources
            body = archive.extractfile(member).read(); row = identities[member.name]
            assert len(body) == row['bytes'] and sha(body) == row['sha256'], 'image body'
            assert stat.S_IMODE(member.mode) == row['mode'], 'image mode'
            sources[member.name] = body
    assert set(sources) == set(identities)
    return sources, identities


def recover():
    sources, identities = prior_sources()
    extra_names = set()
    for label in ('preparation', 'fixtures'):
        extra, modes = image(label)
        assert not set(extra) & set(sources), 'duplicate source epoch path'
        extra_names.update(extra); sources.update(extra); identities.update(modes)
    references = json.loads((BASE / 'reused-inputs.json').read_bytes())
    tree = json.loads((BASE / 'activation-tree.json').read_bytes())
    assert tree['activation'] == ACTIVATION and tree['exit'] == 0 and tree['stderr_hex'] == ''
    bound = set()
    for entry in bytes.fromhex(tree['stdout_hex']).rstrip(b'\0').split(b'\0'):
        meta, raw_name = entry.split(b'\t', 1); mode, kind, oid = meta.split(); name = raw_name.decode()
        assert kind == b'blob' and name not in bound
        body = Path(name).read_bytes() if name in references else sources[name]
        row = references[name] if name in references else identities[name]
        assert hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest() == oid.decode(), 'activation Git body'
        assert (int(mode, 8) & 0o777) == row['mode'], 'activation Git mode'
        bound.add(name)
    instruments = {str(BASE / name) for name in ('plan.json', 'capture.py', 'review.py', 'run_step.py')}
    assert bound == set(references) | (extra_names - instruments), 'activation Git population'
    return sources, identities


def location(source, hit):
    return dict(line=source.count('\n', 0, hit.start()) + 1, expression=hit.group())


def branch(source, hit):
    """Recover one bounded Rust block while ignoring braces inside strings."""
    start = hit.end() - 1
    assert source[start] == '{'
    depth, quoted, escaped = 1, False, False
    for end in range(start + 1, len(source)):
        char = source[end]
        if quoted:
            if escaped:
                escaped = False
            elif char == '\\':
                escaped = True
            elif char == '"':
                quoted = False
        elif char == '"':
            quoted = True
        elif char == '{':
            depth += 1
        elif char == '}':
            depth -= 1
        if depth == 0:
            return source[start + 1:end], end + 1
    raise AssertionError('unterminated bounded capture branch')


def scan(sources):
    plan = json.loads(sources[str(BASE / 'plan.json')])
    assert plan['activation'] == ACTIVATION and plan['cwd'] == '.'
    population = sorted(row['path'] for row in json.loads((PRIOR / 'roles.json').read_bytes())['candidates']
        if row['backend'] == 'rust' and not row['path'].endswith('generated_source_full_manifest_classifier.rs'))
    assert population == plan['consumers']
    parser = sources[plan['grammar_owner']].decode()
    assert 'include_str!("../../../specs/user_function_definition.spec")' in parser
    assert 'let nodes = parse_user_function_definition_asts(source)?;' in parser
    assert 'let parser_spec = parse_spec(USER_FUNCTION_DEFINITION_SPEC)' in parser
    edges, filesystem, captures, outputs, flags, emitted, qualifiers, selectors = [], [], [], [], [], [], [], []
    for name in population:
        source = sources[name].decode()
        embeds = list(re.finditer(r'include_str!\(\s*"([^"\n]+)"\s*\)', source))
        assert len(embeds) == source.count('include_str!(') and embeds, 'all direct embeds are literal'
        for hit in embeds:
            target = posixpath.normpath(str(PurePosixPath(name).parent / hit[1]))
            assert not PurePosixPath(target).is_absolute() and '..' not in PurePosixPath(target).parts
            if target.endswith('_excluded_ast.json'):
                role = 'compile-time AST-source fixture'
            elif target.endswith('_rust_ast.json'):
                role = 'compile-time AST-expected fixture'
            elif target.endswith(('_domain.json', '_profiles.json')):
                role = 'compile-time host domain/profile fixture'
            else:
                role = 'compile-time JSON fixture'
            edges.append(dict(consumer=name, target=target, role=role, **location(source, hit)))
        assert 'parse_spec_with_user_functions(source)' in source
        edges.append(dict(consumer=name, target=plan['grammar'], role='compile-time embedded grammar dependency',
            route=plan['grammar_owner'] + ' USER_FUNCTION_DEFINITION_SPEC; no runtime grammar file read or actual binary identity proof'))
        for hit in re.finditer(r'std::fs::(\w+)\([^\n]*', source):
            assert hit[1] in ('write', 'read_to_string', 'create_dir_all'), 'bounded filesystem API vocabulary'
            filesystem.append(dict(consumer=name, api=hit[1], **location(source, hit)))
        capture_ranges, output_ranges = [], []
        for hit in re.finditer(r'if let Ok\(folder\) = std::env::var\("([A-Z_]+)"\) \{', source):
            body, end = branch(source, hit)
            assert 'std::fs::create_dir_all(&inputs)' in body
            assert 'std::fs::write(&target,' in body and 'std::fs::read_to_string(target)' in body
            assert 'matches!(part, std::path::Component::Normal(_))' in body
            assert 'assert!(!target.exists(),' in body
            prefix = re.search(r'folder.starts_with\("([^"\n]+)"\)', body)
            folder = re.search(r'let inputs = path.join\("([^"\n]+)"\);', body)
            assert prefix and folder and 'format!("{label}.json")' in body
            if folder[1] == 'normal-parsed':
                assert 'let body = serde_json::to_string(&parsed)' in body
                assert 'assert_eq!(std::fs::read_to_string(target).unwrap(), body);' in body
                assert source.index('validate(&parsed)') > end
                assert source.index('let parsed = parse_spec_with_user_functions(source)') < hit.start()
                role = 'write/equality readback of already-parsed AST serialization; parsed object remains validation/compile input'
                consumed_by = 'equality assertion only; no parsed-object restoration from this readback'
                timing = 'after parsing, before validation and target compilation'
            else:
                assert folder[1] == 'normal-inputs'
                assert 'std::fs::write(&target, &serialized)' in body
                assert 'assert_eq!(retained.as_bytes(), serialized.as_bytes());' in body
                assert source.index('let compiled = compile(&parsed)') < hit.start()
                assert source.index('let restored: CompiledSpec = serde_json::from_str(&retained)') > end
                assert re.search(r'execute_generated_parser_v2\(\s*&serialized,', source)
                role = 'equal compiled serialization write/readback feeds restored CompiledSpec deserialization'
                consumed_by = 'restored route; plan call still names original serialized string'
                timing = 'after target compilation, before restored CompiledSpec deserialization'
            captures.append(dict(consumer=name, env=hit[1], target='${' + hit[1] + '}/' + folder[1] + '/${label}.json',
                role=role, consumed_by=consumed_by, timing=timing, lexical_prefix=prefix[1],
                condition='Unicode env lookup succeeds, lexical prefix/normal components pass and target absent; no physical/source-origin credit',
                line=source.count('\n', 0, hit.start()) + 1, branch=body))
            capture_ranges.append((hit.start(), end))
        for hit in re.finditer(r'if std::env::var_os\("([A-Z_]+)"\).is_some\(\) \{', source):
            body, end = branch(source, hit)
            assert 'env!("CARGO_MANIFEST_DIR")' in body
            target = re.search(r'\.join\(\s*"([^"\n]+)"\s*,?\s*\)', body)
            assert target and 'std::fs::write(path, serde_json::to_vec_pretty(&observations)' in body
            assert re.match(r'\s*assert!\(failures.is_empty\(\)', source[end:]), 'failure assertion remains outside intake output branch'
            resolved = posixpath.normpath('rust/linkedspec-runtime/' + target[1])
            assert resolved.startswith('.linkedspec-data/verification/')
            outputs.append(dict(consumer=name, env=hit[1], target=resolved,
                role='write-only observation JSON after row loop; output is not a producer input',
                condition='OS env value present, including empty/non-Unicode; failure assertion still applies',
                anchor='compile-time CARGO_MANIFEST_DIR plus literal suffix; actual old binary anchor unobserved',
                line=source.count('\n', 0, hit.start()) + 1, branch=body))
            output_ranges.append((hit.start(), end))
        for hit in re.finditer(r'std::env::(var|var_os)\("([A-Z_]+)"\)', source):
            if any(start <= hit.start() < end for start, end in capture_ranges):
                role = 'optional serialized artifact capture'
            elif any(start <= hit.start() < end for start, end in output_ranges):
                role = 'optional write-only observation output'
            else:
                assert name.endswith('/blind_postcall_results.rs') and hit[1] == 'var_os'
                assert 'if expected.get("error_record").is_some()' in source
                assert 'RUST_BLIND_POSTCALL_TRACE_BEGIN' in source
                role = 'stdout trace for error_record cases when intake env is present'
            flags.append(dict(consumer=name, api=hit[1], env=hit[2], role=role, **location(source, hit)))
        if 'emit_rust_source_v2(' in source:
            for hit in re.finditer(r'emit_rust_source_v2\([^\n]*', source):
                emitted.append(dict(consumer=name, role='emitted source string/validation or observation; no compiled-host execution observed here', **location(source, hit)))
        assert 'Command::' not in source and 'std::process::' not in source, 'no direct host-process launch in bounded consumers'
        if '.find(|case| case["id"] == label)' in source:
            selectors.append(dict(consumer=name, role='helper selects fixture row by caller label; no all-row execution inference',
                expression='.find(|case| case["id"] == label)'))
        if name.endswith('/referenced_blind_intermediate.rs'):
            assert 'Engine::' not in source and 'emit_rust_source_v2(&compiled,' in source
            qualifiers.append(dict(consumer=name, role='original source tests compiler/emitter ownership without runtime execution',
                repair_owner='TYPE-REFERENCE-BOOK.1.2.23.3.48.2.2.1'))
        elif name.endswith('/referenced_blind_intermediate_qualified.rs'):
            assert 'if pipeline.is_ok() != fixture["expected_builds"].as_bool().unwrap()' in source
            assert 'observations.push(json!({"name": name, "build_error": error}));\n                continue;' in source
            qualifiers.append(dict(consumer=name, role='failed-build branch records observation and skips runtime; unexpected build status still fails'))
    return dict(owner=plan['owner'], consumers=population, input_edges=edges, filesystem_sites=filesystem,
        optional_readbacks=captures, observation_outputs=outputs, environment_sites=flags,
        emitted_source_roles=emitted, row_selectors=selectors, execution_qualifications=qualifiers,
        limits='Twenty-one ordinary Rust source consumers outside the separately owned generated-manifest classifier. Direct compile-time fixture/grammar references and conditional filesystem/trace/emitted-string roles only. No Cargo/SDK run, actual old binary embedded bytes/manifest anchor, full transitive/native/per-read/source-origin graph, all-row test execution or admission. Capture equality and actual downstream readback consumption retain separate scopes.')


def historical(sources, identities, ledger):
    plan = json.loads(sources[str(BASE / 'plan.json')])
    roots = [row['files'] for row in json.loads(sources[plan['historical']]) if row['tag'] == 'root']
    assert len(roots) == 1
    matched, absent, changed = [], [], []
    names = set(ledger['consumers']) | {row['target'] for row in ledger['input_edges']} | {plan['grammar_owner']}
    for name in sorted(names):
        current = dict(bytes=len(sources[name]), sha256=sha(sources[name]), mode=identities[name]['mode'])
        old = roots[0].get(name)
        if old is None:
            absent.append(name)
        elif old == current:
            matched.append(name)
        else:
            changed.append(dict(path=name, historical=old, current=current))
    assert plan['grammar'] in matched, 'independent bundled grammar identity'
    return dict(matching=matched, absent=absent, changed=changed,
        limits='Older metadata versus current retained logical bodies/modes. Dated differences are explicit; membership is not old binary/read/execution custody.')


def controls(sources, identities, ledger):
    results = {}
    for label, field, predicate, operation in [
        ('embedded-fixture-missing', 'input_edges', lambda row: row['role'] == 'compile-time JSON fixture', 'remove'),
        ('embedded-grammar-as-runtime-read', 'input_edges', lambda row: row['role'] == 'compile-time embedded grammar dependency', 'runtime file lookup'),
        ('parsed-readback-as-compile-input', 'optional_readbacks', lambda row: 'already-parsed AST' in row['role'], 'parsed compiler input'),
        ('compiled-readback-as-plan-input', 'optional_readbacks', lambda row: 'CompiledSpec deserialization' in row['role'], 'all plan inputs read back'),
        ('observation-as-input', 'observation_outputs', lambda row: True, 'producer input'),
        ('emitted-as-host-execution', 'emitted_source_roles', lambda row: True, 'fresh compiled OS host'),
        ('compiler-only-as-runtime', 'execution_qualifications', lambda row: 'without runtime' in row['role'], 'runtime suite'),
        ('selector-as-all-rows', 'row_selectors', lambda row: True, 'all rows executed'),
    ]:
        changed = copy.deepcopy(ledger)
        index = next(index for index, row in enumerate(changed[field]) if predicate(row))
        victim = copy.deepcopy(changed[field][index])
        assert predicate(victim)
        if operation == 'remove':
            changed[field].pop(index)
        else:
            changed[field][index]['role'] = operation
        assert changed != ledger
        try:
            assert changed == scan(sources), 'source graph disagreement'
        except AssertionError as error:
            assert str(error) == 'source graph disagreement'
            results[label] = dict(result='RED', field=field, actual_victim=victim)
        else:
            raise AssertionError('ineffective role control')
    plan = json.loads(sources[str(BASE / 'plan.json')])
    grammar = plan['grammar']
    for label in ('historical-body', 'historical-mode', 'historical-record'):
        changed = dict(sources)
        modes = copy.deepcopy(identities)
        if label == 'historical-body':
            changed[grammar] += b' '
        elif label == 'historical-mode':
            modes[grammar]['mode'] ^= 0o100
        else:
            packet = json.loads(changed[plan['historical']])
            next(row for row in packet if row['tag'] == 'root')['files'][grammar]['sha256'] = '0' * 64
            changed[plan['historical']] = json.dumps(packet).encode()
        try:
            historical(changed, modes, ledger)
        except AssertionError as error:
            assert str(error) == 'independent bundled grammar identity'
            results[label] = dict(result='RED', actual_victim=grammar)
        else:
            raise AssertionError('ineffective historical control')
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--current', action='store_true')
    args = parser.parse_args()
    sources, identities = recover()
    ledger = json.loads((BASE / 'loaders.json').read_bytes())
    assert ledger == scan(sources)
    result = dict(result='PASS', consumers=len(ledger['consumers']), input_edges=len(ledger['input_edges']),
        unique_targets=len({row['target'] for row in ledger['input_edges']}), filesystem_sites=len(ledger['filesystem_sites']),
        optional_readbacks=len(ledger['optional_readbacks']), observation_outputs=len(ledger['observation_outputs']),
        environment_sites=len(ledger['environment_sites']), emitted_source_roles=len(ledger['emitted_source_roles']),
        row_selectors=len(ledger['row_selectors']), execution_qualifications=len(ledger['execution_qualifications']),
        historical=historical(sources, identities, ledger), controls=controls(sources, identities, ledger),
        retained_inputs=len(identities), reused_inputs=113, limits=ledger['limits'])
    if args.current:
        for name, row in identities.items():
            path = Path(name)
            assert path.is_file() and not path.is_symlink()
            assert sha(path.read_bytes()) == row['sha256'] and stat.S_IMODE(path.stat().st_mode) == row['mode'], 'current input:' + name
        result['current_inputs'] = len(identities)
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
