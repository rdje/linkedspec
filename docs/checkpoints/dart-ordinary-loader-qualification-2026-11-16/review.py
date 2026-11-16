"""Reconstruct ordinary Dart read sites, expanded inputs and named exclusions."""
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
ACTIVATION = 'ea23e100a021c7561b133de0d98b2d27919350d2'
URI_READ = re.compile(r"File\.fromUri\(\s*(?P<root>root|Directory\.current\.parent\.uri)\.resolve\(\s*(?P<arg>'[^']+'|fixture|userFunctionDefinitionSpecRelativePath)\s*,?\s*\)\s*,?\s*\)\.readAsStringSync\(\)")
FILE_READ = re.compile(r"File\(\s*'(?P<arg>[^']+)'\s*,?\s*\)\.readAsStringSync\(\)")


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


def quoted_list(body):
    values = re.findall(r"'([^']+)'", body)
    assert values and re.sub(r"'[^']+'", '', body).strip(' ,\n\r\t') == '', 'literal list vocabulary'
    return values


def before_loop(source, position, variable, typed=False):
    pattern = r'for \(final ' + variable + (r' in <String>\[' if typed else r' in \[') + r'(?P<body>.*?)\]\)'
    loops = [m for m in re.finditer(pattern, source, re.S) if m.start() < position]
    assert loops, 'read has a preceding named literal loop'
    return quoted_list(loops[-1]['body'])


def location(source, hit):
    return dict(line=source.count('\n', 0, hit.start()) + 1, expression=hit.group())


def fixture_role(target):
    if target.endswith('_excluded_ast.json'):
        return 'AST-source fixture'
    if target.endswith('_dart_ast.json'):
        return 'AST-expected fixture'
    if target.endswith('_dart_domain.json') or target.endswith('_dart_profiles.json'):
        return 'Dart domain/profile fixture'
    return 'authored spec fixture' if target.endswith('.spec') else 'JSON fixture'


def scan(sources):
    plan = json.loads(sources[str(BASE / 'plan.json')])
    assert plan['activation'] == ACTIVATION and plan['cwd'] == 'dart'
    native = json.loads((PRIOR / 'roles.json').read_bytes())['candidates']
    covered = {r['path'] for key in ('earlier_dart', 'recent_dart') for r in json.loads(sources[plan[key]])['consumers']}
    population = sorted(r['path'] for r in native if r['backend'] == 'dart' and r['path'] not in covered and r['path'] != 'dart/test/source_emitter_test.dart')
    assert plan['consumers'] == population, 'remaining named population'
    grammar = plan['grammar']; library = sources[plan['grammar_owner']].decode()
    assert re.search(r"const userFunctionDefinitionSpecRelativePath\s*=\s*'" + re.escape(grammar) + r"';", library)
    assert 'final file = _findRepoFile(userFunctionDefinitionSpecRelativePath);' in library
    assert 'return _defaultParser = UserFunctionDefinitionAstParser.fromSpecSource(' in library
    edges, sites, qualifiers, inline = [], [], [], []
    for name in population:
        source = sources[name].decode(); accounted = set()
        explicit = 'parserSpecSource:' in source
        calls = list(re.finditer(r'parseSpecWithStagedUserFunctionDefinitions\(', source))
        assert calls, 'supporting grammar API call'
        if 'root.resolve(' in source:
            assert 'final root = Directory.current.parent.uri;' in source, 'root alias binding'
        for hit in sorted([*URI_READ.finditer(source), *FILE_READ.finditer(source)], key=lambda m: m.start()):
            method = source.index('.readAsStringSync()', hit.start(), hit.end())
            assert method not in accounted, 'duplicate read-site interpretation'
            accounted.add(method)
            arg = hit['arg']; targets = []; route = ''
            if hit.re is URI_READ:
                if arg == 'userFunctionDefinitionSpecRelativePath':
                    assert explicit
                    sites.append(dict(consumer=name, role='explicit grammar read site', **location(source, hit)))
                    continue
                if arg == 'fixture':
                    targets = before_loop(source, hit.start(), 'fixture', True)
                    route = 'literal loop -> root.resolve(fixture)'
                else:
                    target = arg[1:-1]
                    if '$extension' in target:
                        assert 'String fixture(String extension) => File.fromUri(' in source
                        extensions = re.findall(r"fixture\('(spec|json)'\)", source)
                        assert extensions == ['spec', 'json'], 'suffix call vocabulary'
                        targets = [target.replace('$extension', suffix) for suffix in extensions]
                        route = 'fixture(spec/json) suffix expansion'
                    else:
                        assert '$' not in target
                        targets = [target]; route = 'fixed root-relative URI'
            else:
                if '$target' in arg:
                    stems = before_loop(source, hit.start(), 'target')
                    targets = [arg.replace('$target', stem) for stem in stems]
                    route = 'literal stem loop -> File template'
                elif '$name' in arg:
                    assert 'fixtures(String name) =>' in source
                    stems = re.findall(r"fixtures\('([a-z_]+)'\)", source)
                    assert stems and len(stems) == len(set(stems)), 'named fixture helper calls'
                    targets = [arg.replace('$name', stem) for stem in stems]
                    route = 'literal fixtures(name) calls -> File template'
                else:
                    assert '$' not in arg
                    targets = [arg]; route = 'fixed cwd-relative File'
                targets = [posixpath.normpath('dart/' + target) for target in targets]
            sites.append(dict(consumer=name, role='fixture read site', route=route, expanded_targets=targets, **location(source, hit)))
            for target in targets:
                path = PurePosixPath(target)
                assert not path.is_absolute() and '..' not in path.parts and '$' not in target
                edges.append(dict(consumer=name, target=target, role=fixture_role(target), route=route, **location(source, hit)))
        actual = {m.start() for m in re.finditer(r'\.readAsStringSync\(\)', source)}
        assert accounted == actual, 'all named read sites accounted:' + name
        edges.append(dict(consumer=name, target=grammar, role='explicit grammar dependency' if explicit else 'cached-default grammar dependency',
            route='explicit File read' if explicit else 'documented cached upward lookup; runtime selection unobserved',
            call_lines=[source.count('\n', 0, hit.start()) + 1 for hit in calls]))
        if name.endswith('/referenced_blind_intermediate_test.dart'):
            hit = re.search(r"if \(\{(?P<items>[^}]+)\}\.contains\(name\)\) \{\s*return;\s*\}", source, re.S)
            assert hit
            selected = quoted_list(hit['items'])
            assert selected == ['blind_no_regex', 'marked_blind_target', 'markerless_blind']
            qualifiers.append(dict(consumer=name, role='three named runtime exclusions', names=selected,
                owner='TYPE-REFERENCE-BOOK.1.2.23.3.39.8.1', **location(source, hit)))
        if name.endswith('/rule_invocation_accumulators_test.dart'):
            hit = re.search(r"final expected = row\['name'\] == 'implicit_parent_no_tail'.*?: row\['expected'\];", source, re.S)
            assert hit and '39.8.1' in source
            qualifiers.append(dict(consumer=name, role='preserved ordinary blind expected-value override',
                owner='TYPE-REFERENCE-BOOK.1.2.23.3.39.8.1', **location(source, hit)))
        if name.endswith(('/pure_blind_targets_test.dart', '/referenced_blind_intermediate_test.dart')):
            assert "if (row['expected_builds'] != true)" in source
            qualifiers.append(dict(consumer=name, role='invalid-build branch is compile-only; no runtime coverage inferred',
                expression="if (row['expected_builds'] != true)", owner='existing fixture/build authority'))
        for hit in re.finditer(r"jsonDecode\(\s*r'''(?P<body>.*?)'''", source, re.S):
            payload = json.loads(hit['body'])
            assert isinstance(payload, list) and all(row.get('observation_only') is True for row in payload)
            inline.append(dict(consumer=name, role='inline policy observations; not file inputs', ids=[row['id'] for row in payload], **location(source, hit)))
    assert '39.8.1' in sources[plan['policy_fact']].decode()
    return dict(owner=plan['owner'], consumers=population, read_sites=sites, input_edges=edges,
        execution_qualifications=qualifiers, inline_observations=inline,
        limits='Sixteen remaining named ordinary Dart source consumers, their explicit read sites/finite literal expansions and consumer-level explicit/default grammar dependencies. Source-only declared cwd dart; no SDK execution, observed cache/path/module/native resolution or complete transitive/per-read graph. Existing39.8.1 runtime exclusions, preserved expected-value override, compile-only branches and AST/inline policy roles remain qualified. Generated-package/corpus source_emitter_test stays separately owned2; full population/admission remains open.')


def historical(sources, identities, ledger):
    plan = json.loads(sources[str(BASE / 'plan.json')])
    roots = [p['files'] for p in json.loads(sources[plan['historical']]) if p['tag'] == 'root']
    assert len(roots) == 1
    bindings = []
    for edge in ledger['input_edges']:
        name = edge['target']; actual = dict(bytes=len(sources[name]), sha256=sha(sources[name]), mode=identities[name]['mode'])
        assert roots[0][name] == actual, 'historical input body/mode'
        bindings.append(dict(consumer=edge['consumer'], target=name))
    return bindings


def validate(sources, ledger):
    assert ledger == scan(sources), 'loader graph differs from source'


def controls(sources, identities, ledger):
    results = {}
    for label in ('consumer-missing', 'fixture-missing', 'expanded-spec-missing', 'default-grammar-missing', 'read-site-missing', 'runtime-exclusion-erased', 'override-portable', 'inline-as-file', 'duplicate'):
        changed = copy.deepcopy(ledger)
        if label == 'consumer-missing': changed['consumers'].pop()
        elif label == 'fixture-missing': changed['input_edges'].pop(0)
        elif label == 'expanded-spec-missing': changed['input_edges'] = [r for r in changed['input_edges'] if not r['target'].endswith('computed_selection_values.spec')]
        elif label == 'default-grammar-missing': changed['input_edges'] = [r for r in changed['input_edges'] if r['role'] != 'cached-default grammar dependency']
        elif label == 'read-site-missing': changed['read_sites'].pop()
        elif label == 'runtime-exclusion-erased': changed['execution_qualifications'] = [r for r in changed['execution_qualifications'] if r['role'] != 'three named runtime exclusions']
        elif label == 'override-portable': next(r for r in changed['execution_qualifications'] if 'override' in r['role'])['role'] = 'portable expected values'
        elif label == 'inline-as-file': changed['inline_observations'][0]['role'] = 'external fixture'
        else: changed['input_edges'].append(copy.deepcopy(changed['input_edges'][0]))
        try: validate(sources, changed)
        except AssertionError as error:
            assert str(error) == 'loader graph differs from source'
            results[label] = dict(result='RED', reason=str(error))
        else: raise AssertionError('ineffective graph control:' + label)
    grammar = json.loads(sources[str(BASE / 'plan.json')])['grammar']
    for label in ('historical-body', 'historical-mode', 'historical-missing'):
        changed = dict(sources); modes = copy.deepcopy(identities)
        if label == 'historical-body': changed[grammar] += b' '
        elif label == 'historical-mode': modes[grammar]['mode'] ^= 0o100
        else:
            path = json.loads(sources[str(BASE / 'plan.json')])['historical']; data = json.loads(changed[path])
            next(p for p in data if p['tag'] == 'root')['files'].pop(grammar); changed[path] = json.dumps(data).encode()
        try: historical(changed, modes, ledger)
        except (AssertionError, KeyError): results[label] = dict(result='RED', reason='independent historical input disagreement')
        else: raise AssertionError('ineffective historical control:' + label)
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('--current', action='store_true')
    args = parser.parse_args(); sources, identities = recover()
    ledger = json.loads((BASE / 'loaders.json').read_bytes()); validate(sources, ledger)
    bindings = historical(sources, identities, ledger)
    result = dict(result='PASS', consumers=len(ledger['consumers']), read_sites=len(ledger['read_sites']),
        input_edges=len(ledger['input_edges']), unique_targets=len({r['target'] for r in ledger['input_edges']}),
        historical_bindings=len(bindings), execution_qualifications=len(ledger['execution_qualifications']),
        inline_observation_rows=sum(len(row['ids']) for row in ledger['inline_observations']),
        controls=controls(sources, identities, ledger), retained_inputs=len(identities), reused_inputs=113, limits=ledger['limits'])
    if args.current:
        for name, row in identities.items():
            path = Path(name)
            assert path.is_file() and not path.is_symlink()
            assert sha(path.read_bytes()) == row['sha256'] and stat.S_IMODE(path.stat().st_mode) == row['mode'], 'current source identity:' + name
        result['current_inputs'] = len(identities)
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__': main()
