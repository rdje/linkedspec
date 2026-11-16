"""Recover three Dart Array guard loader graphs without executing Dart."""
import argparse
import copy
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path, PurePosixPath
import re
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PRIOR = Path('docs/checkpoints/native-consumer-routes-2026-11-16')
ACTIVATION = '54f374727558365d616ce6a8539f9ddd02a8e88d'


def sha(body):
    return hashlib.sha256(body).hexdigest()


def recover():
    references = json.loads((BASE / 'reused-inputs.json').read_bytes())
    for name, row in references.items():
        path = Path(name)
        assert path.is_file() and not path.is_symlink()
        assert sha(path.read_bytes()) == row['sha256'] and stat.S_IMODE(path.stat().st_mode) == row['mode'], 'reused source identity'
    spec = importlib.util.spec_from_file_location('retained_native_routes', PRIOR / 'review.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    sources, identities = module.recover()
    extra = json.loads((BASE / 'identities.json').read_bytes())
    seen = set()
    with tarfile.open(BASE / 'inputs.tar.gz') as archive:
        assert len(archive.getmembers()) == len(extra), 'source population'
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and str(path) == member.name
            assert member.name not in seen and member.name not in sources, 'duplicate source'
            body = archive.extractfile(member).read(); row = extra[member.name]
            assert sha(body) == row['sha256'] and len(body) == row['bytes'], 'source body'
            assert stat.S_IMODE(member.mode) == row['mode'], 'source mode'
            sources[member.name] = body; identities[member.name] = row; seen.add(member.name)
    assert seen == set(extra), 'source namespace'
    tree = json.loads((BASE / 'activation-tree.json').read_bytes())
    assert tree['activation'] == ACTIVATION and tree['exit'] == 0 and tree['stderr_hex'] == ''
    bound = set()
    for entry in bytes.fromhex(tree['stdout_hex']).rstrip(b'\0').split(b'\0'):
        meta, raw_name = entry.split(b'\t', 1); mode, kind, oid = meta.split(); name = raw_name.decode()
        assert kind == b'blob' and name not in bound
        body = Path(name).read_bytes() if name in references else sources[name]
        row = references[name] if name in references else extra[name]
        assert hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest() == oid.decode(), 'activation Git body'
        assert (int(mode, 8) & 0o777) == row['mode'], 'activation Git mode'
        bound.add(name)
    new = {str(BASE / name) for name in ('plan.json', 'capture.py', 'review.py', 'run_step.py')}
    assert bound == set(references) | (set(extra) - new), 'activation Git population'
    return sources, identities


def match(source, pattern):
    hits = list(re.finditer(pattern, source, re.M))
    assert len(hits) == 1, 'unique loader expression:' + pattern
    hit = hits[0]
    return dict(line=source.count('\n', 0, hit.start()) + 1, expression=hit.group())


def reconstruct(sources):
    plan = json.loads(sources[str(BASE / 'plan.json')])
    assert plan['activation'] == ACTIVATION and plan['cwd'] == 'dart'
    grammar = plan['grammar']; constant = sources[plan['grammar_constant_owner']].decode()
    assert re.search(r"const userFunctionDefinitionSpecRelativePath\s*=\s*'" + re.escape(grammar) + r"';", constant), 'grammar constant'
    edges, support, captures = [], [], []
    for row in plan['consumers']:
        name = row['path']; source = sources[name].decode()
        assert 'final root = Directory.current.parent.uri;' in source, 'declared root expression'
        assert 'parserSpecSource: ' + row['grammar_argument'] + ',' in source, 'explicit grammar argument'
        for role in ('cases', 'profiles'):
            target = row[role]
            expression = match(source, r"root\.resolve\(\s*'" + re.escape(target) + r"',?\s*\)")
            assert target in sources
            edges.append(dict(consumer=name, target=target, role='fixture-' + role,
                route='File.fromUri(root.resolve(literal)).readAsStringSync; declared cwd dart', **expression))
        expression = match(source, r'File\.fromUri\(\s*root\.resolve\(userFunctionDefinitionSpecRelativePath\),?\s*\)\.readAsStringSync\(\)')
        edges.append(dict(consumer=name, target=grammar, role='explicit-grammar-read', **expression))
        if 'support' in row:
            target = row['support']; relative = '../tool/' + PurePosixPath(target).name
            expression = match(source, r"^import '" + re.escape(relative) + r"' as observation;$")
            body = sources[target].decode()
            assert ' main(' not in body and not re.search(r'\b(?:File|Directory|Process)\s*[.(]', body), 'observation support file/process loader'
            exports = re.findall(r'^\S+ (observe\w+)\(', body, re.M)
            assert exports, 'observation support export'
            support.append(dict(consumer=name, target=target, role='imported observation support', exports=exports, **expression))
            assert "Platform.environment['" + row['capture_environment'] + "']" in source
            expression = match(source, r"'\$\{Directory.current.parent.path\}/" + re.escape(row['capture_directory']) + r"/\$phase/\$id.json'")
            assert 'if (phase != null)' in source and 'if (target.existsSync())' in source
            for phase in ('before', 'private-old', 'private-fixed', 'direct'):
                assert "'" + phase + "'," in source
            write = source.index('target.writeAsStringSync(serialized);')
            read = source.index('retained = target.readAsStringSync();')
            compiled = source.index('final compiled = compileSpec(parsed);')
            assert write < read < compiled, 'capture write/read before compile'
            assert "if (retained != serialized)" in source
            captures.append(dict(consumer=name, target=row['capture_directory'] + '/${phase}/${id}.json',
                role='conditional one-shot parsed output then readback', environment=row['capture_environment'],
                condition='phase nonnull, allowed named phase, target absent', read_calls=1,
                limit='source parse precedes serialization; no before-all-SDK custody is implied', **expression))
    return dict(owner=plan['owner'], input_edges=edges, support_imports=support, optional_captures=captures,
        limits='Three named Dart Array normal sources, fixed cases/profiles, explicit grammar constant, two support imports and two conditional one-shot readback expressions. Static declared-cwd interpretation only; no Dart/SDK run, observed package/path resolution, full transitive/native/source-origin graph, population completeness or canonical admission. Earlier ordinary parsed-dump timing/error-field qualifications remain unchanged.')


def historical(sources, identities):
    plan = json.loads(sources[str(BASE / 'plan.json')]); bindings = []
    for row in plan['consumers']:
        packets = json.loads(sources[row['historical']])
        roots = [packet for packet in packets if packet['tag'] == 'root']
        assert len(roots) == 1, 'historical root packet'
        targets = [row['cases'], row['profiles'], plan['grammar']]
        if 'support' in row:
            targets.append(row['support'])
        for name in targets:
            expected = roots[0]['files'][name]
            actual = dict(bytes=len(sources[name]), sha256=sha(sources[name]), mode=identities[name]['mode'])
            assert expected == actual, 'historical direct input'
            bindings.append(dict(consumer=row['path'], target=name, packet=row['historical'], identity=actual))
    return bindings


def validate(sources, ledger):
    assert ledger == reconstruct(sources), 'loader ledger differs from source'


def controls(sources, identities, ledger):
    results = {}
    for label in ('fixture-missing', 'grammar-missing', 'support-as-suite', 'capture-as-fixture', 'duplicate', 'wrong-root'):
        changed = copy.deepcopy(ledger)
        if label == 'fixture-missing':
            changed['input_edges'].pop(0)
        elif label == 'grammar-missing':
            changed['input_edges'] = [r for r in changed['input_edges'] if r['role'] != 'explicit-grammar-read']
        elif label == 'support-as-suite':
            changed['support_imports'][0]['role'] = 'standalone regression suite'
        elif label == 'capture-as-fixture':
            changed['optional_captures'][0]['role'] = 'immutable fixture input'
        elif label == 'duplicate':
            changed['input_edges'].append(copy.deepcopy(changed['input_edges'][0]))
        else:
            changed['input_edges'][0]['target'] = 'dart/' + changed['input_edges'][0]['target']
        try:
            validate(sources, changed)
        except AssertionError as error:
            assert str(error) == 'loader ledger differs from source'
            results[label] = dict(result='RED', reason=str(error))
        else:
            raise AssertionError('ineffective source control:' + label)
    grammar = json.loads(sources[str(BASE / 'plan.json')])['grammar']
    for label in ('historical-body', 'historical-mode', 'historical-missing'):
        changed = dict(sources); modes = copy.deepcopy(identities)
        if label == 'historical-body':
            changed[grammar] += b' '
        elif label == 'historical-mode':
            modes[grammar]['mode'] ^= 0o100
        else:
            path = json.loads(sources[str(BASE / 'plan.json')])['consumers'][0]['historical']
            packets = json.loads(changed[path]); next(p for p in packets if p['tag'] == 'root')['files'].pop(grammar)
            changed[path] = json.dumps(packets).encode()
        try:
            historical(changed, modes)
        except (AssertionError, KeyError):
            results[label] = dict(result='RED', reason='independent historical input disagreement')
        else:
            raise AssertionError('ineffective historical control:' + label)
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('--current', action='store_true')
    args = parser.parse_args(); sources, identities = recover()
    ledger = json.loads((BASE / 'loaders.json').read_bytes()); validate(sources, ledger)
    bindings = historical(sources, identities)
    result = dict(result='PASS', consumers=3, fixture_grammar_edges=len(ledger['input_edges']),
        support_imports=len(ledger['support_imports']), optional_captures=len(ledger['optional_captures']),
        historical_bindings=len(bindings), historical_unique_targets=len({r['target'] for r in bindings}),
        controls=controls(sources, identities, ledger), reused_inputs=113, additional_inputs=len(identities)-113,
        limits=ledger['limits'])
    if args.current:
        for name, row in identities.items():
            path = Path(name)
            assert path.is_file() and not path.is_symlink()
            assert sha(path.read_bytes()) == row['sha256'] and stat.S_IMODE(path.stat().st_mode) == row['mode'], 'current source identity:' + name
        result['current_inputs'] = len(identities)
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
