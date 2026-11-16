"""Reconstruct Julia direct file and in-memory generated loader roles."""
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
ACTIVATION = '53a7df83a8019a800ff80dc64dce66746059b7e8'
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


def arguments(text):
    """Split the bounded source expressions without splitting nested calls/strings."""
    parts, depth, quoted, escaped, start = [], 0, False, False, 0
    for index, char in enumerate(text):
        if quoted:
            if escaped: escaped = False
            elif char == '\\': escaped = True
            elif char == '"': quoted = False
        elif char == '"': quoted = True
        elif char == '(': depth += 1
        elif char == ')': depth -= 1
        elif char == ',' and depth == 0:
            parts.append(text[start:index].strip()); start = index + 1
        assert depth >= 0
    assert depth == 0 and not quoted
    parts.append(text[start:].strip())
    return parts


def calls(source, name):
    for hit in re.finditer(r'(?<![\w.])' + re.escape(name) + r'\(', source):
        depth, quoted, escaped = 1, False, False
        for end in range(hit.end(), len(source)):
            char = source[end]
            if quoted:
                if escaped: escaped = False
                elif char == '\\': escaped = True
                elif char == '"': quoted = False
            elif char == '"': quoted = True
            elif char == '(': depth += 1
            elif char == ')': depth -= 1
            if depth == 0: break
        assert depth == 0, 'balanced source call'
        yield dict(position=hit.start(), line=source.count('\n',0,hit.start())+1,
            expression=source[hit.start():end+1], arguments=arguments(source[hit.end():end]))


def quoted(text):
    values = re.findall(r'"([^"\n]+)"', text)
    assert values and re.sub(r'"[^"\n]+"', '', text).strip(' ,\n\r\t') == '', 'literal tuple vocabulary'
    return values


def resolve(expression, aliases, variables):
    value = expression.strip()
    if value in variables: return variables[value]
    if value in aliases: return aliases[value]
    if value == 'dirname(dirname(@__DIR__))': return '.'
    if value == '@__DIR__': return 'julia/test'
    if re.fullmatch(r'"[^"$\n]*"', value): return json.loads(value)
    for function in ('normpath','joinpath'):
        if value.startswith(function+'(') and value.endswith(')'):
            values = [resolve(part, aliases, variables) for part in arguments(value[len(function)+1:-1])]
            return posixpath.normpath(posixpath.join(*values))
    match = re.fullmatch(r'(name|file)\s*\*\s*"(\.json)"', value)
    if match: return variables[match[1]] + match[2]
    raise AssertionError('uninterpreted path expression:' + value)


def scan(sources):
    plan = json.loads(sources[str(BASE/'plan.json')]); assert plan['activation'] == ACTIVATION and plan['cwd'] == '.'
    names = sorted(r['path'] for r in json.loads((PRIOR/'roles.json').read_bytes())['candidates'] if r['backend']=='julia')
    assert names == plan['consumers']
    parser = sources[plan['grammar_owner']].decode()
    for token in ['return lock(_DEFAULT_USER_FUNCTION_DEFINITION_AST_PARSER_LOCK) do',
                  'read(_user_function_definition_spec_path(), String)',
                  'for anchor in (@__DIR__, pwd())', 'directory = abspath(anchor)']:
        assert token in parser, 'documented cached source-first default grammar'
    edges, sites, generated, captures, qualifications = [], [], [], [], []
    for name in names:
        source = sources[name].decode(); aliases = {}; explicit = False
        for variable, expression in re.findall(r'(?m)^\s*(root|fixture_root|grammar_path) = ([^\n]+)', source):
            assert variable not in aliases, 'unique root/grammar alias'
            aliases[variable] = resolve(expression, aliases, {})
        loops = {}
        for variable, body in re.findall(r'for (name|file) in \((.*?)\)', source, re.S):
            assert variable not in loops, 'unique finite loop vocabulary'
            loops[variable] = quoted(body)
        file_calls = list(calls(source, 'read'))
        for call in file_calls:
            args = call['arguments']; assert len(args)==2 and args[1]=='String', 'bounded filesystem read signature'
            expr = args[0]; row = dict(consumer=name, **call)
            if expr == 'path':
                assert 'retained = read(path, String)' in source and 'write(path,' in source
                row.update(role='optional generated artifact readback', targets=[], condition='capture nonempty')
                sites.append(row); continue
            mentioned = [key for key in loops if re.search(r'\b'+key+r'\b',expr)]
            assert len(mentioned)<=1
            vocab = loops[mentioned[0]] if mentioned else [None]
            targets = [resolve(expr, aliases, {mentioned[0]:v} if mentioned else {}) for v in vocab]
            row.update(role='direct file read', targets=targets, condition='source-derived root aliases; no observed resolution')
            sites.append(row)
            for target in targets:
                assert not PurePosixPath(target).is_absolute() and '..' not in PurePosixPath(target).parts
                if target==plan['grammar']: role='explicit grammar read'; explicit=True
                elif target.endswith('_excluded_ast.json'): role='AST-source fixture'
                elif target.endswith('_julia_ast.json'): role='AST-expected fixture'
                elif target.endswith(('_domain.json','_profiles.json')): role='host domain/profile fixture'
                else: role='authored spec fixture' if target.endswith('.spec') else 'JSON fixture'
                edges.append(dict(consumer=name,target=target,role=role,line=call['line'],expression=call['expression']))
        for call in calls(source, 'include'):
            assert len(call['arguments'])==1
            target=resolve(call['arguments'][0], aliases, {})
            edges.append(dict(consumer=name,target=target,role='included observation support module',line=call['line'],expression=call['expression']))
        assert 'parse_spec_with_staged_user_function_definitions(' in source
        if not explicit:
            edges.append(dict(consumer=name,target=plan['grammar'],role='cached-default grammar dependency',
                condition='package source ancestors before pwd ancestors; locked cache; runtime resolution unobserved'))
        if 'Base.include_string(' in source:
            assert 'Module(gensym(' in source
            generated.append(dict(consumer=name,role='emitted bytes included into fresh Module in the same process; no fresh OS process or file input',
                expression=next(line.strip() for line in source.splitlines() if 'Base.include_string(' in line)))
        flags=re.findall(r'get\(ENV, "([A-Z_]+_CAPTURE)", ""\)',source); assert len(flags)<=1
        if flags:
            flag=flags[0]
            if 'retained = read(path, String)' in source:
                assert source.count('retained = read(path, String)')==2 and source.count('write(path,')==2
                assert source.index('write(path, serialized)') < source.index('retained == serialized || error(') < source.index('restored = from_json(') < source.index('compiled = compile_spec(parsed)')
                assert source.index('write(path, emitted)') < source.index('retained == emitted || error(') < source.index('Base.include_string(')
                assert 'isabspath(capture)' in source and 'islink(capture)' in source
                role='two write/equal-byte readbacks; parsed before restore/target compile, emitted before include_string; parsing already happened'
                condition='nonempty capture plus relative owned-path and symlink checks'
            elif flag=='LINKEDSPEC_COUNT_GUARD_CAPTURE':
                assert 'get(ENV, "LINKEDSPEC_COUNT_GUARD_CAPTURE", "") == "1"' in source
                role='stdout observation/trace only; no capture files'; condition='env exactly 1'
            else:
                assert 'if !isempty(capture)' in source
                assert 'write(joinpath(capture,' in source
                assert source.index('compiled = compile_spec(parsed)') < source.index('write(joinpath(capture,') < source.index('Base.include_string(')
                role='two write-only outputs after compile and AST restoration, before same-process include_string'
                condition='env nonempty'
            captures.append(dict(consumer=name,env=flag,role=role,condition=condition))
        if name.endswith('/referenced_blind_targets_test.jl'):
            assert 'if !fixture["expected_builds"]' in source
            assert 'if file == "referenced_blind_intermediate.json" ||' in source
            assert 'fixture["name"] in ("blind_no_regex", "marked_blind_target", "markerless_blind")' in source
            assert '48.2.2.1' in source and '39.8.1' in source
            qualifications.append(dict(consumer=name,role='invalid-build compile-only branch and named runtime exclusions',
                parent='referenced_blind_intermediate.json',names=['blind_no_regex','marked_blind_target','markerless_blind'],
                owners=['TYPE-REFERENCE-BOOK.1.2.23.3.48.2.2.1','TYPE-REFERENCE-BOOK.1.2.23.3.39.8.1']))
        if name.endswith('/rule_invocation_accumulators_test.jl'):
            assert 'fixture["name"] == "implicit_parent_no_tail" ?' in source
            assert 'Any[Any["x"], Any[]]' in source and '39.8.1' in source
            assert 'get(fixture, "julia_compatibility_expected", fixture["expected"])' in source
            qualifications.append(dict(consumer=name,role='preserved empty-iteration override and fixture Julia compatibility fallback',owner='TYPE-REFERENCE-BOOK.1.2.23.3.39.8.1 plus existing fixture binding authority'))
        if name.endswith('/count_source_fallback_test.jl'):
            assert 'get(row, "expected_nonperl", get(row, "expected", nothing))' in source
            qualifications.append(dict(consumer=name,role='existing non-Perl expected-value fallback; no portable-policy admission'))
    return dict(owner=plan['owner'],consumers=names,read_sites=sites,input_edges=edges,generated_modules=generated,
        optional_captures=captures,execution_qualifications=qualifications,
        limits='Twenty named Julia source consumers and finite direct read/include/grammar/generated-Module roles. No Julia/SDK execution, actual package/cache/path selection, full transitive/native/per-read graph, fresh OS process or canonical admission. Existing runtime exclusions/host expectation fallbacks and older capture timing remain explicit.')


def historical(sources,identities,ledger):
    plan=json.loads(sources[str(BASE/'plan.json')]); roots=[row['files'] for row in json.loads(sources[plan['historical']]) if row['tag']=='root']; assert len(roots)==1
    old=roots[0]; matched,absent=[],[]
    for name in sorted(set(ledger['consumers'])|{row['target'] for row in ledger['input_edges']}):
        if name not in old: absent.append(name); continue
        assert old[name]==dict(bytes=len(sources[name]),sha256=sha(sources[name]),mode=identities[name]['mode']), 'historical identity disagreement'
        matched.append(name)
    return dict(matching=matched,absent=absent,limits='Captured membership/absence supplies no old test execution or per-file read evidence.')


def controls(sources,identities,ledger):
    results={}
    for label in ['consumer-missing','fixture-missing','grammar-missing','support-as-suite','module-as-process','readback-as-fixture','write-only-as-readback','runtime-exclusion-erased','compatibility-as-portable','duplicate']:
        changed=copy.deepcopy(ledger)
        if label=='consumer-missing': changed['consumers'].pop()
        elif label=='fixture-missing': changed['input_edges']=[row for row in changed['input_edges'] if row['role']!='JSON fixture']
        elif label=='grammar-missing': changed['input_edges']=[row for row in changed['input_edges'] if row['role']!='cached-default grammar dependency']
        elif label=='support-as-suite': next(row for row in changed['input_edges'] if row['role']=='included observation support module')['role']='standalone suite'
        elif label=='module-as-process': changed['generated_modules'][0]['role']='fresh OS process'
        elif label=='readback-as-fixture': next(row for row in changed['read_sites'] if row['role']=='optional generated artifact readback')['role']='immutable fixture'
        elif label=='write-only-as-readback': next(row for row in changed['optional_captures'] if 'write-only' in row['role'])['role']='write then read'
        elif label=='runtime-exclusion-erased': changed['execution_qualifications'].pop(0)
        elif label=='compatibility-as-portable': changed['execution_qualifications']=[]
        else: changed['input_edges'].append(copy.deepcopy(changed['input_edges'][0]))
        assert changed!=ledger
        try: assert changed==scan(sources), 'source graph disagreement'
        except AssertionError as error:
            assert str(error)=='source graph disagreement'; results[label]='RED'
        else: raise AssertionError('ineffective graph control')
    plan=json.loads(sources[str(BASE/'plan.json')]);grammar=plan['grammar']
    for label in ['historical-body','historical-mode','historical-record']:
        changed=dict(sources);modes=copy.deepcopy(identities)
        if label=='historical-body':changed[grammar]+=b' '
        elif label=='historical-mode':modes[grammar]['mode']^=0o100
        else:
            packet=json.loads(changed[plan['historical']]);next(row for row in packet if row['tag']=='root')['files'][grammar]['sha256']='0'*64
            changed[plan['historical']]=json.dumps(packet).encode()
        try:historical(changed,modes,ledger)
        except AssertionError as error:
            assert str(error)=='historical identity disagreement';results[label]='RED'
        else:raise AssertionError('ineffective historical control')
    return results


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--current',action='store_true');args=parser.parse_args()
    sources,identities=recover();ledger=json.loads((BASE/'loaders.json').read_bytes());assert ledger==scan(sources)
    result=dict(result='PASS',consumers=len(ledger['consumers']),read_sites=len(ledger['read_sites']),input_edges=len(ledger['input_edges']),
        unique_targets=len({row['target'] for row in ledger['input_edges']}),generated_modules=len(ledger['generated_modules']),
        optional_captures=len(ledger['optional_captures']),execution_qualifications=len(ledger['execution_qualifications']),
        historical=historical(sources,identities,ledger),controls=controls(sources,identities,ledger),retained_inputs=len(identities),reused_inputs=113,limits=ledger['limits'])
    if args.current:
        for name,row in identities.items():
            path=Path(name);assert path.is_file() and not path.is_symlink()
            assert sha(path.read_bytes())==row['sha256'] and stat.S_IMODE(path.stat().st_mode)==row['mode'], 'current input:'+name
        result['current_inputs']=len(identities)
    print(json.dumps(result,sort_keys=True))


if __name__=='__main__':main()
