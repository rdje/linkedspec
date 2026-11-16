"""Reconstruct ordinary Lua loaders without executing the package or test bodies."""
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
ACTIVATION = 'fb6f74f9842891394cba80e7ea05ab7016e41be3'
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


def loc(source, hit):
    return dict(line=source.count('\n', 0, hit.start()) + 1, expression=hit.group())


def literals(text):
    return [a or b for a, b in re.findall(r'"([^"\n]*)"|\x27([^\x27\n]*)\x27', text)]


def scan(sources):
    plan = json.loads(sources[str(BASE / 'plan.json')])
    assert plan['activation'] == ACTIVATION and plan['cwd'] == '.'
    covered = set(json.loads(sources[plan['earlier_lua']])['consumers'])
    native = json.loads((PRIOR / 'roles.json').read_bytes())['candidates']
    names = sorted(r['path'] for r in native if r['backend'] == 'lua' and r['path'] not in covered)
    assert names == plan['consumers']
    edges, sites, modules, captures, qualifications = [], [], [], [], []
    parser = sources[plan['grammar_owner']].decode()
    for token in ['parser or default_user_function_definition_parser(emitter)',
                  'spec_loader.spec_load_options({ cwd = module_directory(), search_roots = {}, trace = emitter })',
                  'if default_parser == nil then default_parser = build_default_parser(emitter) end']:
        assert token in parser, 'documented default grammar mechanism'
    for name in names:
        source = sources[name].decode()
        root = re.search(r'local input_root = os.getenv\("([A-Z_]+)"\) or ""', source)
        condition = ('${' + root[1] + '} or cwd; prefix must include its separator') if root else 'repository cwd'
        for hit in re.finditer(r'(?:loadfile|dofile)\(([^\n]*?)\)', source):
            value = re.sub(r'\s+', '', hit[1]); values = literals(value)
            assert len(values) == 1 and (value.startswith('input_root..') == bool(root)), 'bounded file-call expression'
            kind = hit.group().split('(', 1)[0]
            if kind == 'loadfile':
                assert source[hit.end():hit.end()+1] == ')' and source[hit.start()-7:hit.start()] == 'assert(', 'compile-only assert call'
            edges.append(dict(consumer=name, target=values[0], role='syntax compilation only' if kind == 'loadfile' else 'executed returned observation support',
                condition=condition, **loc(source, hit)))
        for hit in re.finditer(r'require\((["\x27])([^"\x27]+)\1\)', source):
            assert hit[2] == 'linkedspec', 'bounded module vocabulary'
            modules.append(dict(consumer=name, module=hit[2], role='package request; actual environment/cache resolution unobserved',
                prefix_changes_request=False, **loc(source, hit)))
        fixture_calls = re.findall(r'\bfixture\("([^"\n]+)"\)', source)
        loops = re.findall(r'for _,\s*name in ipairs\(\{(.*?)\}\)', source, re.S)
        loop_values = [v for body in loops for v in literals(body)]
        explicit = False
        for hit in re.finditer(r'io\.open\(([^\n]*?)\)', source):
            args = re.fullmatch(r'(.*),\s*(["\x27])([rw]b?)\2', hit[1]); assert args, 'bounded io.open arguments'
            expr, mode = args[1], args[3]; compact = re.sub(r'\s+', '', expr)
            values = literals(compact); targets = []; role = 'fixture read'; route = ''
            if mode.startswith('w'):
                role = 'optional generated output write'; route = 'capture helper/path expression'
            elif compact == 'path' and 'local function retained_input(' in source:
                role = 'optional generated output readback'; route = 'same locally written path'
            elif compact == 'path':
                assert "read('tests/fixtures/'..name..'.json')" in source
                targets = ['tests/fixtures/' + v + '.json' for v in loop_values]
                route = 'literal name loop -> read(path)'
            elif len(values) == 1 and compact in ('"'+values[0]+'"', "'"+values[0]+"'", 'input_root.."'+values[0]+'"'):
                targets = values; route = 'fixed literal' if not compact.startswith('input_root') else 'input-root prefix + fixed literal'
            elif compact in ('"tests/fixtures/"..name', 'input_root.."tests/fixtures/"..name'):
                targets = ['tests/fixtures/' + v for v in fixture_calls + loop_values]
                assert targets and len(set(targets)) == len(targets), 'finite fixture call/list vocabulary'
                route = 'fixture(name) literal calls/list' if 'local function fixture(' in source else 'literal name loop'
            else:
                raise AssertionError('uninterpreted io.open path:' + name + ':' + expr)
            site = dict(consumer=name, mode=mode, role=role, route=route, targets=targets, condition=condition, **loc(source, hit))
            sites.append(site)
            for target in targets:
                if target == plan['grammar']:
                    explicit = True; role = 'explicit grammar read'
                elif target.endswith('_excluded_ast.json'): role = 'AST-source fixture'
                elif target.endswith('_lua_ast.json'): role = 'AST-expected fixture'
                elif target.endswith(('_domain.json', '_profiles.json')): role = 'host domain/profile fixture'
                else: role = 'JSON fixture'
                edges.append(dict(consumer=name, target=target, role=role, route=route, condition=condition, mode=mode, **loc(source, hit)))
        calls = list(re.finditer(r'parse_spec_with_staged_user_function_definitions\(', source)); assert calls
        if not explicit:
            edges.append(dict(consumer=name, target=plan['grammar'], role='cached-default grammar dependency',
                condition='module-relative exact request and cache; actual resolution unobserved', **loc(source, calls[0])))
        flags = re.findall(r'os.getenv\("([A-Z_]+_CAPTURE)"\)', source)
        assert len(flags) <= 1
        if flags:
            flag = flags[0]
            if 'local function retained_input(' in source:
                assert 'if output == nil or output == "" then return body end' in source
                assert source.index('io.open(path, "wb")') < source.index('io.open(path, "rb")')
                assert 'assert(retained == body, "normal artifact readback drift")' in source
                assert source.index('local serialized = retained_input(') < source.index('local restored_spec = l.spec_ast.from_json(') < source.index('local compiled = l.compile_spec(')
                assert source.index('local emitted = retained_input(') < source.index('local parser = assert((loadstring or load)(emitted))()')
                assert 'owned capture path required' in source
                kind = 'write then one equal-byte readback; parsed before restore/compile and emitted before chunk load; parsing already happened'
                gate = 'nonempty env plus owned capture path pattern'
            elif flag == 'LINKEDSPEC_COUNT_GUARD_CAPTURE':
                assert 'os.getenv("' + flag + '") == "1"' in source
                kind = 'stdout observation only; no capture file'; gate = 'env exactly 1'
            elif flag == 'LINKEDSPEC_COUNT_SOURCE_CAPTURE':
                assert 'if capture then' in source
                assert source.index('local restored = l.compile_spec(') < source.index('io.open(capture ..') < source.index('local parser = assert((loadstring or load)(emitted))()')
                kind = 'two write-only outputs after compile/restore and before emitted chunk load'; gate = 'env present; empty Lua string is truthy'
            else:
                assert 'if output ~= nil and output ~= "" then' in source
                assert source.index('local restored = l.compile_spec(') < source.index('local function persist(') < source.index('local parser = assert((loadstring or load)(emitted))()')
                assert 'persist("emitted", ".lua", emitted)' in source and 'persist("parsed", ".json", json.encode(l.spec_ast.to_json(parsed)))' in source
                kind = 'two write-only outputs after compile/restore and before emitted chunk load'; gate = 'env nonempty'
            captures.append(dict(consumer=name, env=flag, role=kind, condition=gate))
        if name.endswith('/referenced_blind_targets_test.lua'):
            assert "local excluded=fixture.name=='blind_no_regex' or fixture.name=='marked_blind_target' or\n        fixture.name=='markerless_blind'" in source
            assert "if name~='referenced_blind_intermediate' and not excluded then" in source
            assert 'if not fixture.expected_builds then' in source and 'unqualified48.2.2.1' in source and 'under39.8.1' in source
            qualifications.append(dict(consumer=name, role='invalid-build compile-only branch; parent runtime exclusion and three coordinator runtime exclusions',
                excluded_parent='referenced_blind_intermediate', excluded_names=['blind_no_regex','marked_blind_target','markerless_blind'],
                owners=['TYPE-REFERENCE-BOOK.1.2.23.3.48.2.2.1','TYPE-REFERENCE-BOOK.1.2.23.3.39.8.1']))
    return dict(owner=plan['owner'], consumers=names, input_edges=edges, io_sites=sites, module_requests=modules,
        optional_captures=captures, execution_qualifications=qualifications,
        limits='Sixteen remaining named Lua sources and finite direct expressions only. Syntax compilation never selects or runs run.lua. Input-root prefix does not bind require resolution. No package/regression body execution, SDK outcome, transitive/native/origin/per-read or canonical admission. Historical root overlap is identity only; older output timing and all excluded/selection owners remain open.')


def historical(sources, identities, ledger):
    plan = json.loads(sources[str(BASE / 'plan.json')]); old = json.loads(sources[plan['historical']])
    overlap, absent = [], []
    for name in sorted(set(ledger['consumers']) | {r['target'] for r in ledger['input_edges']}):
        if name not in old:
            absent.append(name); continue
        assert old[name] == dict(bytes=len(sources[name]), sha256=sha(sources[name]), mode=identities[name]['mode']), 'historical overlap identity'
        overlap.append(name)
    return dict(matching=overlap, absent=absent, limits='Only older ledger overlap compared; absent does not prove an older selected read or defect, matching does not prove consumer execution.')


def controls(sources, identities, ledger):
    results = {}
    labels = ['consumer-missing','fixture-missing','grammar-missing','syntax-as-execution','support-as-suite','prefix-as-package-custody','readback-as-fixture','write-only-as-readback','empty-env-false','runtime-exclusions-erased','duplicate']
    for label in labels:
        altered = copy.deepcopy(ledger)
        if label == 'consumer-missing': altered['consumers'].pop()
        elif label == 'fixture-missing': altered['input_edges'] = [r for r in altered['input_edges'] if r['role'] != 'JSON fixture']
        elif label == 'grammar-missing': altered['input_edges'] = [r for r in altered['input_edges'] if r['role'] != 'cached-default grammar dependency']
        elif label == 'syntax-as-execution': next(r for r in altered['input_edges'] if r['role'] == 'syntax compilation only')['role'] = 'executed shared test driver'
        elif label == 'support-as-suite': next(r for r in altered['input_edges'] if r['role'] == 'executed returned observation support')['role'] = 'standalone suite'
        elif label == 'prefix-as-package-custody': altered['module_requests'][0]['prefix_changes_request'] = True
        elif label == 'readback-as-fixture': next(r for r in altered['io_sites'] if r['role'] == 'optional generated output readback')['role'] = 'immutable input'
        elif label == 'write-only-as-readback': next(r for r in altered['optional_captures'] if 'write-only' in r['role'])['role'] = 'write-before-readback'
        elif label == 'empty-env-false': next(r for r in altered['optional_captures'] if r['env'] == 'LINKEDSPEC_COUNT_SOURCE_CAPTURE')['condition'] = 'nonempty env'
        elif label == 'runtime-exclusions-erased': altered['execution_qualifications'] = []
        else: altered['input_edges'].append(copy.deepcopy(altered['input_edges'][0]))
        assert altered != ledger
        try: assert altered == scan(sources), 'source graph disagreement'
        except AssertionError as error:
            assert str(error) == 'source graph disagreement'; results[label] = 'RED'
        else: raise AssertionError('ineffective control:' + label)
    plan = json.loads(sources[str(BASE / 'plan.json')]); grammar = plan['grammar']
    for label in ['historical-body','historical-mode','historical-record']:
        altered = dict(sources); modes = copy.deepcopy(identities)
        if label == 'historical-body': altered[grammar] += b' '
        elif label == 'historical-mode': modes[grammar]['mode'] ^= 0o100
        else:
            packet = json.loads(altered[plan['historical']]); packet[grammar]['sha256'] = '0'*64
            altered[plan['historical']] = json.dumps(packet).encode()
        try: historical(altered, modes, ledger)
        except AssertionError as error:
            assert str(error) == 'historical overlap identity'; results[label] = 'RED'
        else: raise AssertionError('ineffective historical control')
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('--current', action='store_true'); args = parser.parse_args()
    sources, identities = recover(); ledger = json.loads((BASE / 'loaders.json').read_bytes())
    assert ledger == scan(sources), 'source graph disagreement'
    old = historical(sources, identities, ledger)
    result = dict(result='PASS', consumers=len(ledger['consumers']), io_sites=len(ledger['io_sites']),
        input_edges=len(ledger['input_edges']), unique_targets=len({r['target'] for r in ledger['input_edges']}),
        syntax_edges=sum(r['role']=='syntax compilation only' for r in ledger['input_edges']),
        support_edges=sum(r['role']=='executed returned observation support' for r in ledger['input_edges']),
        module_requests=len(ledger['module_requests']), optional_captures=len(ledger['optional_captures']),
        historical=old, controls=controls(sources, identities, ledger), retained_inputs=len(identities), reused_inputs=113, limits=ledger['limits'])
    if args.current:
        for name, row in identities.items():
            path = Path(name); assert path.is_file() and not path.is_symlink()
            assert sha(path.read_bytes()) == row['sha256'] and stat.S_IMODE(path.stat().st_mode) == row['mode'], 'current input:' + name
        result['current_inputs'] = len(identities)
    print(json.dumps(result, sort_keys=True))


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
    instruments = {str(BASE / name) for name in ('plan.json', 'capture.py', 'review.py', 'run_step.py', 'probe.py', 'toy_chunk.lua')}
    assert bound == set(references) | (extra_names - instruments), 'activation Git population'
    return sources, identities


if __name__ == '__main__': main()
