"""Recover eleven Lua candidates' direct input expressions; no SDK execution."""
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
HISTORICAL = 'docs/checkpoints/lua-raw-error-observation-2026-11-13/normal/input-identities.json'
GRAMMAR = 'specs/user_function_definition.spec'
RAW = 'lua/test/raw_error_observation_test.lua'
GAP = 'lua/test/gap_ls_selected_cursor_test.lua'


def sha(body):
    return hashlib.sha256(body).hexdigest()


def recover():
    references = json.loads((BASE / 'reused-inputs.json').read_bytes())
    for name, row in references.items():
        path = Path(name)
        assert not path.is_symlink() and path.is_file()
        assert sha(path.read_bytes()) == row['sha256'] and stat.S_IMODE(path.stat().st_mode) == row['mode'], 'reused input identity'
    spec = importlib.util.spec_from_file_location('retained_native_routes', PRIOR / 'review.py')
    prior = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(prior)
    sources, identities = prior.recover()
    extra = json.loads((BASE / 'identities.json').read_bytes())
    recovered = set()
    with tarfile.open(BASE / 'inputs.tar.gz') as archive:
        assert len(archive.getmembers()) == len(extra), 'additional source population'
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and str(path) == member.name
            assert member.name not in recovered and member.name not in sources, 'duplicate source'
            body = archive.extractfile(member).read(); row = extra[member.name]
            assert sha(body) == row['sha256'] and len(body) == row['bytes'], 'additional source body'
            assert stat.S_IMODE(member.mode) == row['mode'], 'additional source mode'
            sources[member.name] = body; identities[member.name] = row
            recovered.add(member.name)
    assert recovered == set(extra), 'additional source namespace'
    tree = json.loads((BASE / 'activation-tree.json').read_bytes())
    assert tree['exit'] == 0 and tree['stderr_hex'] == '' and tree['activation'] == '341f488d36b15cb39069db32a74e3dc5d82a70d8'
    bound = set()
    for record in bytes.fromhex(tree['stdout_hex']).rstrip(b'\0').split(b'\0'):
        metadata, raw_name = record.split(b'\t', 1)
        mode, kind, oid = metadata.split(); name = raw_name.decode()
        assert kind == b'blob' and name not in bound
        body = Path(name).read_bytes() if name in references else sources[name]
        assert hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest() == oid.decode(), 'activation Git source'
        row = references[name] if name in references else extra[name]
        assert (int(mode, 8) & 0o777) == row['mode'], 'activation Git mode'
        bound.add(name)
    instruments = {str(BASE / name) for name in ('capture.py', 'review.py', 'run_step.py')}
    assert bound == set(references) | (set(extra) - instruments), 'activation source population'
    return sources, identities


def candidates():
    rows = json.loads((PRIOR / 'roles.json').read_bytes())['candidates']
    return [row['path'] for row in rows if row['backend'] == 'lua' and row['route'].startswith('no direct')]


def line(source, pattern):
    hits = [dict(line=index, expression=value) for index, value in enumerate(source.splitlines(), 1)
            if re.search(pattern, value)]
    assert len(hits) == 1, 'unique loader expression:' + pattern
    return hits[0]


def reconstruct(sources):
    names = candidates()
    edges, supports, captures = [], [], []
    for name in names:
        source = sources[name].decode()
        if name not in (RAW, GAP):
            target = name.removesuffix('_test.lua') + '_cases.json'
            expression = line(source, r'(?:io\.open|\bread)\(\s*\x27' + re.escape(target) + r'\x27')
            edges.append(dict(consumer=name, target=target, role='fixture-read', route='fixed literal', **expression))
        elif name == GAP:
            assert "for _, path in ipairs({" in source and "local file = assert(io.open(path, 'rb'))" in source
            for target in ('dart/test/fixtures/gap_ls_cursor.json', 'dart/test/fixtures/gap_ls_broad_carrier.json'):
                expression = line(source, '^  \x27' + re.escape(target) + '\x27,$')
                edges.append(dict(consumer=name, target=target, role='fixture-read', route='literal list -> path -> io.open rb', **expression))
        else:
            for target, role in [('tests/fixtures/lua_raw_error_observation_cases.json', 'fixture-read'),
                                 ('tests/fixtures/lua_raw_error_observation_profiles.json', 'fixture-read'),
                                 (GRAMMAR, 'explicit-grammar-read')]:
                expression = line(source, r'\bread\("' + re.escape(target) + r'"\)')
                edges.append(dict(consumer=name, target=target, role=role, route='fixed read helper -> io.open rb', **expression))
            for target in ('lua/test/raw_error_observation.lua', 'lua/test/callable_array_transform_observation.lua'):
                expression = line(source, r'^local \w+ = dofile\("' + re.escape(target) + r'"\)$')
                exports = re.findall(r'^function M\.(\w+)\(', sources[target].decode(), re.M)
                assert exports and sources[target].decode().rstrip().endswith('return M')
                assert not re.search(r'\b(?:dofile|loadfile|io\.open)\s*\(', sources[target].decode()), 'support further file loader'
                supports.append(dict(consumer=name, target=target, role='returned observation support module', exports=exports, **expression))
            assert 'if output == nil or output == "" then return body end' in source
            assert 'assert(read(path) == body, "actual normal input readback")\n  return read(path)' in source
            assert source.index('local file = assert(io.open(path, "wb"))') < source.index('assert(read(path) == body')
            for suffix in ('parsed.json', 'emitted.lua'):
                expression = line(source, r'persist\(row\.id \.\. "\.' + re.escape(suffix) + '"')
                captures.append(dict(consumer=name, target='${LINKEDSPEC_RAW_ERROR_CAPTURE}/${row.id}.' + suffix,
                    role='optional output then readback', condition='capture environment nonempty and accepted path pattern',
                    read_calls_per_persist=2, **expression))
        if name != RAW:
            expression = line(source, r'ls\.parse_spec_with_staged_user_function_definitions\((?:fixture|row)\.source\)')
            edges.append(dict(consumer=name, target=GRAMMAR, role='cached-default-grammar-dependency',
                route='module-relative exact spec request; no observed runtime lookup', **expression))
        assert sources[name].decode().startswith('-- TYPE-REFERENCE-BOOK.'), 'suite owner source'
    parser = sources['lua/src/linkedspec/user_function_definition_parser.lua'].decode()
    for required in ['parser = require_parser(parser or default_user_function_definition_parser(emitter))',
                     'spec_loader.path_spec_request(bundled_spec_relative_path())',
                     'spec_loader.spec_load_options({ cwd = module_directory(), search_roots = {}, trace = emitter })',
                     'if default_parser == nil then default_parser = build_default_parser(emitter) end',
                     'table.concat({ "..", "..", "..", "specs", M.USER_FUNCTION_DEFINITION_SPEC_ID }, HOST_SEPARATOR)']:
        assert required in parser, 'default grammar source mechanism'
    nullable = sources['lua/test/null_return_and_observation_test.lua'].decode()
    assert "if fixture.name == 'return__blind_le' then" in nullable and 'PHASE AUTHORITY DEFERRED' in nullable
    for edge in edges:
        assert edge['target'] in sources, 'unretained direct input'
    return dict(consumers=names, input_edges=edges, support_modules=supports, optional_capture_families=captures,
        dormant_boundary='nullable return__blind_le retains its explicit phase-authority exclusion; no fresh execution or dormancy removal',
        limits='Eleven named Lua suite sources and their interpreted direct fixture/grammar/support/output-readback expressions only. No SDK execution, actual grammar cache/path selection, transitive package/native resolution, complete input graph, canonical selection, full population or admission. Remaining discovery/independent semantic adjudication stays with parent1; native/source-origin/physical custody remains4.2/SESSION5.')


def historical(sources, identities):
    old = json.loads(sources[HISTORICAL])
    names = [RAW, 'lua/test/raw_error_observation.lua', 'lua/test/callable_array_transform_observation.lua',
             'tests/fixtures/lua_raw_error_observation_cases.json', 'tests/fixtures/lua_raw_error_observation_profiles.json', GRAMMAR]
    for name in names:
        assert old[name] == dict(bytes=len(sources[name]), sha256=sha(sources[name]), mode=identities[name]['mode']), 'historical direct input'
    return names


def validate(sources, ledger):
    assert ledger == reconstruct(sources), 'loader ledger differs from source'


def controls(sources, identities, ledger):
    results = {}
    for label in ('fixture-missing', 'list-member-missing', 'default-grammar-missing', 'support-as-suite', 'output-as-fixture', 'duplicate', 'profile-target'):
        changed = copy.deepcopy(ledger)
        if label == 'fixture-missing':
            changed['input_edges'].pop(0)
        elif label == 'list-member-missing':
            changed['input_edges'] = [row for row in changed['input_edges'] if row['target'] != 'dart/test/fixtures/gap_ls_broad_carrier.json']
        elif label == 'default-grammar-missing':
            changed['input_edges'] = [row for row in changed['input_edges'] if row['role'] != 'cached-default-grammar-dependency']
        elif label == 'support-as-suite':
            changed['support_modules'][0]['role'] = 'standalone regression suite'
        elif label == 'output-as-fixture':
            changed['optional_capture_families'][0]['role'] = 'immutable fixture input'
        elif label == 'duplicate':
            changed['input_edges'].append(copy.deepcopy(changed['input_edges'][0]))
        else:
            next(row for row in changed['input_edges'] if row['target'].endswith('_profiles.json'))['target'] = GRAMMAR
        try:
            validate(sources, changed)
        except AssertionError as error:
            assert str(error) == 'loader ledger differs from source'
            results[label] = dict(result='RED', reason=str(error))
        else:
            raise AssertionError('ineffective loader control:' + label)
    for label in ('historical-body', 'historical-mode', 'historical-missing'):
        changed = dict(sources); modes = copy.deepcopy(identities)
        if label == 'historical-body':
            changed[GRAMMAR] += b' '
        elif label == 'historical-mode':
            modes[GRAMMAR]['mode'] ^= 0o100
        else:
            old = json.loads(changed[HISTORICAL]); old.pop(GRAMMAR)
            changed[HISTORICAL] = json.dumps(old).encode()
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
    result = dict(result='PASS', consumers=len(ledger['consumers']), input_edges=len(ledger['input_edges']),
        unique_direct_targets=len({row['target'] for row in ledger['input_edges']}), support_modules=len(ledger['support_modules']),
        optional_capture_families=len(ledger['optional_capture_families']), historical_inputs=len(historical(sources, identities)),
        controls=controls(sources, identities, ledger), reused_source_inputs=113, additional_source_inputs=len(identities)-113,
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
