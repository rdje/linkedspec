"""Derive a source-bound call inventory from retained compiler observations."""
import base64
import collections
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0-'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
INPUTS = [MODULE, PREFIX + 'native.json', PREFIX + 'optree.json']
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def observation(path):
    row = json.loads((ROOT / path).read_bytes())
    assert row['returncode'] == 0 and row['unchanged']
    assert not base64.b64decode(row['stderr_base64'])
    assert row['inputs'][MODULE] == sha((ROOT / MODULE).read_bytes())
    return json.loads(base64.b64decode(row['stdout_base64']))


def derive():
    source = (ROOT / MODULE).read_text()
    lines = source.splitlines()
    native = observation(PREFIX + 'native.json')
    optree = observation(PREFIX + 'optree.json')
    cvs = {row['id']: row for row in optree['cvs']}
    headers = [(match.group(1), source[:match.start()].count('\n') + 1)
               for match in re.finditer(r'^sub\s+(\w+)\s*\{', source, re.M)]
    ranges = {name: (line, headers[i + 1][1] if i + 1 < len(headers) else len(lines) + 1)
              for i, (name, line) in enumerate(headers)}

    def binding(cv, index):
        pad = cv['pads'][index]
        # Installed core B::Deparse uses SVf_FAKE for inherited pad names.
        # This capture is specific to its recorded Perl v5.34.1 optree.
        if pad.get('flags', 0) & 16777216:
            assert cv['parent'] is not None
            return binding(cvs[cv['parent']], pad['parent_pad_index'])
        return cv, index

    def declaration(cv, index):
        name = cv['pads'][index]['name']
        introductions = [row['line'] for row in cv['introductions'] if row['pad_index'] == index]
        lo, hi = ranges[cv['id'].split('/')[0]]
        candidates = []
        for line in range(lo, hi):
            text = lines[line - 1]
            match = re.search(r'\bmy\s+(\([^)]*\)|\$\w+)', text)
            if match and re.search(re.escape(name) + r'\b', match.group(1)):
                candidates.append(line)
        assert candidates, (cv['id'], name)
        if introductions:
            line = min(candidates, key=lambda candidate: abs(candidate - introductions[0]))
        else:
            assert name == '$lowerer' and len(candidates) == 1
            line = candidates[0]
        return line, introductions

    def classify(cv, index, line):
        name = cv['pads'][index]['name']
        text = lines[line - 1]
        following = '\n'.join(lines[line - 1:line + 4])
        root = cv['id'].split('/')[0]
        if root == '_bind_emission_dependency':
            return 'boundary-cold-fallback'
        if name == '$require_dep':
            return 'local-required-resolver'
        if '$require_dep->' in text or '_bind_emission_dependency(' in following[:following.find(';') + 1]:
            return 'already-bound-dependency'
        if root == '_lower_dropped_value_statement' and name == '$trim_action_ir_value':
            return 'remaining-inline-required'
        if root in ('_extract_outer_brace_payload', '_split_receiver_dot_method_expr'):
            return 'remaining-formal-trim'
        if name == '$lowerer':
            return 'remaining-named-code-dispatch'
        if '$deps->{' in following and re.search(r'=\s*(?:\(ref\(|ref\()', text):
            if name == '$predicate':
                return 'remaining-predicate'
            if name in ('$bare_symbol_kind', '$base_bare_symbol_kind'):
                return 'remaining-optional-kind'
            if name in ('$lower_array_pipeline_expr', '$lower_assign_statement'):
                return 'remaining-optional-ast'
        assert re.search(r'=\s*sub\b', text) or re.search(r';\s*$', text), (cv['id'], name, text)
        return 'local-helper-closure'

    calls, bindings, all_ops = [], {}, collections.Counter()
    for cv in optree['cvs']:
        for call in cv['calls']:
            children = call['tree']['children']
            while len(children) == 1 and children[0]['op'] == 'null':
                children = children[0]['children']
            callee = children[-1]
            while callee['op'] in ('null', 'rv2cv') and len(callee.get('children', [])) == 1:
                callee = callee['children'][0]
            all_ops[callee['op']] += 1
            if callee['op'] in ('gv', 'method_named', 'method'):
                continue
            row = {'cv': cv['id'], 'path': call['path'], 'line': call['line'],
                   'source_line': lines[call['line'] - 1], 'callee_op': callee['op']}
            if callee['op'] == 'padsv':
                owner, index = binding(cv, callee['targ'])
                key = owner['id'] + ':pad:' + str(index)
                if key not in bindings:
                    line, introductions = declaration(owner, index)
                    bindings[key] = {'cv': owner['id'], 'pad_index': index,
                        'name': owner['pads'][index]['name'], 'declaration_line': line,
                        'declaration': lines[line - 1], 'introduction_lines': introductions,
                        'class': classify(owner, index, line)}
                row['binding'] = key
                row['name'] = bindings[key]['name']
                row['class'] = bindings[key]['class']
            elif callee['op'] == 'multideref':
                assert cv['id'] == '_codeblock_variable_call_candidate'
                row.update(name='$deps->{bare_symbol_kind}', **{'class': 'remaining-optional-kind'})
            elif callee['op'] == 'entersub':
                assert cv['id'] == '_lower_mutation_slot_value_expr'
                row.update(name='_bind_emission_dependency($lower_flow_composite_expr)',
                           **{'class': 'already-bound-direct'})
            else:
                raise AssertionError(('unclassified callee', cv['id'], callee))
            calls.append(row)
    compiled_variables = collections.Counter()
    for function in native['functions']:
        compiled_variables.update(re.findall(r'&\$(\w+)\s*\(', function['compiled_source']))
    raw_variables = collections.Counter(re.findall(r'\$(\w+)\s*->\s*\(', source))
    return {'source_sha256': sha(source.encode()), 'perl': optree['perl'],
        'source_functions': [name for name, _ in headers],
        'compiled_functions': [row['name'] for row in native['functions']],
        'compiled_cv_count': len(optree['cvs']), 'all_callee_ops': dict(sorted(all_ops.items())),
        'raw_variable_candidates': dict(sorted(raw_variables.items())),
        'deparsed_variable_calls': dict(sorted(compiled_variables.items())),
        'generated_string_excess': dict(sorted((raw_variables - compiled_variables).items())),
        'bindings': bindings, 'calls': calls,
        'classes': dict(sorted(collections.Counter(row['class'] for row in calls).items())),
        'limits': 'Static compiled syntax and lexical source classification at accepted91e972cfa0 only; not a transitive call graph or runtime admission. Named calls/method calls and literal local closures are separate helper/parent obligations. Optional array-normalizer bare_symbol_kind is selected but never invoked locally. Required resolver calls are local validation/binding, not injected invocation. Core B/Perl is the read-only OS toolchain, not a portable compiler-version census.'}


if __name__ == '__main__':
    target = ROOT / (PREFIX + 'inventory.json')
    assert not target.exists(), 'one-shot first derived inventory'
    result = derive()
    result['inputs'] = {path: sha((ROOT / path).read_bytes()) for path in INPUTS}
    result['producer_sha256'] = sha(Path(__file__).read_bytes())
    target.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'classes': result['classes'], 'bindings': len(result['bindings']),
                      'calls': len(result['calls'])}, sort_keys=True))
