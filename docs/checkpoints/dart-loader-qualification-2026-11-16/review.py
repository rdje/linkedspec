"""Read the retained Dart loader slice; never run its Dart consumers or capture."""
import argparse
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import stat
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
READ = re.compile(
    r"File\.fromUri\(\s*(?:root|Directory\.current\.parent\.uri)\.resolve\(\s*"
    r"('([^']*)'|userFunctionDefinitionSpecRelativePath)\s*,?\s*\)\s*,?\s*"
    r"\)\.readAsStringSync\(\)", re.S)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def relative(name):
    path = PurePosixPath(name)
    require(not path.is_absolute() and str(path) == name
            and all(part not in ('', '.', '..') for part in path.parts), 'unsafe path')
    return name


def recover():
    inputs = {}
    with tarfile.open(BASE / 'inputs.tar.gz') as archive:
        for member in archive:
            relative(member.name)
            require(member.isfile() and member.name not in inputs, 'archive member')
            inputs[member.name] = (archive.extractfile(member).read(), member.mode & 0o777)
    identities = json.loads((BASE / 'identities.json').read_bytes())
    require(inputs.keys() == identities.keys(), 'archive population')
    for name, (body, mode) in inputs.items():
        require(hashlib.sha256(body).hexdigest() == identities[name]['sha256'], 'input bytes')
        require(mode == identities[name]['mode'], 'input mode')
    command = json.loads(gzip.decompress((BASE / 'git-tree.json.gz').read_bytes()))
    require(command['argv'] == ['git', 'ls-tree', '-rz', 'HEAD', '--', *sorted(
        name for name in inputs if not name.startswith(str(BASE.relative_to(ROOT)) + '/'))], 'git argv')
    require(command['cwd'] == '.' and command['exit'] == 0 and command['stderr'] == '', 'git channels')
    tree = {}
    for cell in bytes.fromhex(command['stdout_hex']).split(b'\0'):
        if cell:
            header, name = cell.split(b'\t')
            mode, kind, blob = header.decode().split()
            require(kind == 'blob', 'git object kind')
            tree[name.decode()] = (mode, blob)
    require(tree.keys() == set(command['argv'][5:]), 'git input population')
    for name, (mode, blob) in tree.items():
        body, permissions = inputs[name]
        require(hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest() == blob,
                'git source body')
        require(mode == ('100755' if permissions & 0o111 else '100644'), 'git source mode')
    return inputs


def reconstruct(inputs, config):
    text = {name: body.decode() for name, (body, _) in inputs.items()}
    grammar = config['grammar']
    loader = text[config['loader']]
    # These are source contracts being interpreted, not a Dart parser or runtime oracle.
    require(re.search(r"const userFunctionDefinitionSpecRelativePath\s*=\s*'" + re.escape(grammar) + r"';", loader),
            'grammar constant')
    for expression in (
        'final parser = parserSpecSource == null',
        '? _defaultUserFunctionDefinitionAstParser(trace: trace)',
        'final cached = _defaultParser;', 'return cached;',
        '_readDefaultUserFunctionDefinitionSpecSource()',
        '_findRepoFile(userFunctionDefinitionSpecRelativePath)',
        'return file.readAsStringSync();',
        'Directory.current.absolute,\n    _scriptDirectory().absolute,',
        'final found = _findUpward(anchor, relativePath);',
        'if (candidate.existsSync()) {\n      return candidate;',
        'directory = parent;',
    ):
        require(expression in loader, 'default grammar source contract')
    rows = []
    consumers = config['consumers']
    require(len(consumers) == 6 and len({row['path'] for row in consumers}) == 6, 'six named consumers')
    for consumer in consumers:
        name = consumer['path']
        source = text[name]
        require(consumer['feature_owner'] in source.splitlines()[0], 'feature owner')
        require('parseSpecWithStagedUserFunctionDefinitions(' in source, 'function parser call')
        require(config['cwd'] == 'dart', 'cwd contract')
        for match in READ.finditer(source):
            argument = match[2] if match[2] is not None else grammar
            if '$extension' in argument:
                extensions = re.findall(r"fixture\('([^']+)'\)", source)
                require(extensions == ['spec', 'json'], 'fixture extension calls')
                targets = [argument.replace('$extension', extension) for extension in extensions]
            else:
                require('$' not in argument, 'unresolved input interpolation')
                targets = [argument]
            for target in targets:
                relative(target)
                require(target in inputs, 'unretained read input')
                rows.append(dict(consumer=name, feature_owner=consumer['feature_owner'],
                    target=target, role='grammar-input' if target == grammar else 'fixture-input',
                    source_line=source.count('\n', 0, match.start()) + 1,
                    source_expression=match[0], condition='ordinary main/test path; static, not executed'))
        route = consumer['grammar_route']
        if route == 'explicit':
            require('parserSpecSource:' in source and any(
                row['consumer'] == name and row['target'] == grammar for row in rows), 'explicit grammar')
        else:
            require(route == 'default-cached-upward-lookup' and 'parserSpecSource:' not in source,
                    'default grammar route')
            rows.append(dict(consumer=name, feature_owner=consumer['feature_owner'], target=grammar,
                role='grammar-input', source_line=source.count('\n', 0, source.index('parseSpecWithStagedUserFunctionDefinitions(')) + 1,
                source_expression='parseSpecWithStagedUserFunctionDefinitions(source)',
                condition='default parser cache miss; first existing upward cwd candidate, then script anchor; current resolution not observed'))
        require(source.count('readAsStringSync()') == len(list(READ.finditer(source)))
                + (1 if 'target.readAsStringSync()' in source else 0), 'unclassified direct read')
    callable_name = next(row['path'] for row in consumers if row['feature_owner'].endswith('.78.6.3'))
    callable_source = text[callable_name]
    require("import '../tool/callable_array_transform_observation.dart' as observation;" in callable_source,
            'support import')
    require('target.writeAsStringSync(serialized);\n    retained = target.readAsStringSync();' in callable_source,
            'read after write')
    require("Platform.environment['LINKEDSPEC_CALLABLE_TRANSFORM_DART_CAPTURE']" in callable_source
            and "'$phase'" not in callable_source
            and 'if (phase != null)' in callable_source
            and '.linkedspec-data/scratch/callable-transform-dart-normal/$phase/$id.json' in callable_source,
            'optional capture role')
    rows.append(dict(consumer=callable_name, target=config['callable_support'], role='support-import',
        source_expression="import '../tool/callable_array_transform_observation.dart' as observation;",
        condition='source-relative import, package dependencies not resolved'))
    rows.append(dict(consumer=callable_name,
        target='.linkedspec-data/scratch/callable-transform-dart-normal/$phase/$id.json',
        role='optional-capture-output-readback', source_expression='target.readAsStringSync()',
        condition='capture environment variable set; same invocation writes serialized first; dynamic phase/id/cwd'))
    return rows


def validate(inputs, config, rows):
    expected = reconstruct(inputs, config)
    require(rows == expected, 'loader ledger differs from source interpretation')
    prior = json.loads(inputs[config['prior_ledger']][0])
    require(prior['grammar'] == config['grammar'], 'prior grammar')
    # Independent, older command-specific inventory supplies the comparison population.
    for consumer, targets in prior['consumers'].items():
        actual = sorted(row['target'] for row in rows
                        if row['consumer'] == consumer and row['role'] == 'fixture-input')
        require(actual == sorted(targets), 'prior input ledger disagreement')
    name = next(row['path'] for row in config['consumers'] if row['feature_owner'].endswith('.78.6.3'))
    require(sorted(row['target'] for row in rows if row['consumer'] == name and row['role'] == 'fixture-input')
            == sorted(config['callable_inputs']), 'callable fixture boundary')
    require(config['callable_support'] in inputs, 'support body absent')
    return dict(result='PASS', consumers=len(config['consumers']),
        fixture_edges=sum(row['role'] == 'fixture-input' for row in rows),
        grammar_edges=sum(row['role'] == 'grammar-input' for row in rows),
        support_imports=sum(row['role'] == 'support-import' for row in rows),
        optional_output_readbacks=sum(row['role'] == 'optional-capture-output-readback' for row in rows),
        limits=config['limits'])


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--current', action='store_true', help='also compare current bytes/modes; does not recapture')
    args = parser.parse_args()
    inputs = recover()
    key = str(BASE.relative_to(ROOT)) + '/qualification.json'
    config = json.loads(inputs[key][0])
    require(config == json.loads((BASE / 'qualification.json').read_bytes()), 'qualification configuration drift')
    rows = json.loads((BASE / 'loaders.json').read_bytes())
    result = validate(inputs, config, rows)
    controls = {}

    def deny(label, altered_inputs, altered_config, altered_rows):
        try:
            validate(altered_inputs, altered_config, altered_rows)
        except (ValueError, KeyError) as error:
            controls[label] = dict(result='RED', reason=str(error))
        else:
            raise ValueError('ineffective control: ' + label)

    for label, role in [('missing-fixture', 'fixture-input'), ('missing-default-grammar', 'grammar-input'),
                        ('missing-support', 'support-import')]:
        changed = copy.deepcopy(rows)
        index = next(i for i, row in enumerate(changed) if row['role'] == role
                     and (label != 'missing-default-grammar' or 'cache miss' in row['condition']))
        changed.pop(index)
        deny(label, inputs, config, changed)
    changed = copy.deepcopy(rows)
    changed[0]['target'] = 'tests/fixtures/wrong.json'
    deny('wrong-constructed-path', inputs, config, changed)
    changed = copy.deepcopy(rows)
    changed[-1]['role'] = 'fixture-input'
    deny('output-promoted-to-fixture', inputs, config, changed)
    deny('duplicate-read', inputs, config, rows + [copy.deepcopy(rows[0])])
    changed_inputs = dict(inputs)
    changed_inputs[config['loader']] = (inputs[config['loader']][0].replace(
        b'Directory.current.absolute,\n    _scriptDirectory().absolute,',
        b'_scriptDirectory().absolute,\n    Directory.current.absolute,'), inputs[config['loader']][1])
    deny('reversed-default-anchor-precedence', changed_inputs, config, rows)
    changed = copy.deepcopy(config)
    changed['consumers'].pop()
    deny('omitted-consumer', inputs, changed, rows)
    result['controls'] = controls
    if args.current:
        for name, (body, mode) in inputs.items():
            path = ROOT / name
            require(not path.is_symlink() and path.resolve().is_relative_to(ROOT), 'current source boundary')
            info = path.stat()
            require(stat.S_ISREG(info.st_mode) and info.st_dev == ROOT.stat().st_dev, 'current source locality')
            require(path.read_bytes() == body and stat.S_IMODE(info.st_mode) == mode, 'current bytes/mode')
        result['current_inputs'] = len(inputs)
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
