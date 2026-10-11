"""Read-only independent compiler population and lexical-binding review."""
import base64
import collections
import hashlib
import importlib.util
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0-'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
BASE = '91e972cfa0d214784b0172828f7baa378c25f23e'
sha = lambda raw: hashlib.sha256(raw).hexdigest()

# Independent, source-reviewed exact ingress sites; lines are compiler COP lines.
REMAINING = {
    ('_lower_dropped_value_statement', 2066, '$trim_action_ir_value'): ('remaining-inline-required', 2060),
    ('_infer_assignment_source_container_kind', 272, '$bare_symbol_kind'): ('remaining-optional-kind', 242),
    ('_uniform_binding_target_symbol', 1292, '$bare_symbol_kind'): ('remaining-optional-kind', 1289),
    ('_codeblock_variable_call_candidate', 1509, '$deps->{bare_symbol_kind}'): ('remaining-optional-kind', None),
    ('_lower_method_value_expr', 2550, '$base_bare_symbol_kind'): ('remaining-optional-kind', 2544),
    ('_lower_method_value_expr', 3850, '$bare_symbol_kind'): ('remaining-optional-kind', 3847),
    ('_lower_source_slot_bare_scalar_read_expr', 6883, '$bare_symbol_kind'): ('remaining-optional-kind', 6867),
    ('_lower_assign_statement', 7156, '$bare_symbol_kind'): ('remaining-optional-kind', 7153),
    ('_lower_ast_block_side_effect_statement', 743, '$lower_array_pipeline_expr'): ('remaining-optional-ast', 741),
    ('_lower_ast_call_statement', 2170, '$lower_assign_statement'): ('remaining-optional-ast', 2167),
    ('_receiver_mutation_target_is_tracked', 939, '$predicate'): ('remaining-predicate', 938),
    ('_nested_write_target_is_tracked', 1268, '$predicate'): ('remaining-predicate', 1267),
    ('_extract_outer_brace_payload', 316, '$trim_action_ir_value'): ('remaining-formal-trim', 314),
    ('_split_receiver_dot_method_expr', 7306, '$trim_action_ir_value'): ('remaining-formal-trim', 7304),
    ('_split_receiver_dot_method_expr', 7341, '$trim_action_ir_value'): ('remaining-formal-trim', 7304),
    ('_split_receiver_dot_method_expr', 7342, '$trim_action_ir_value'): ('remaining-formal-trim', 7304),
    ('_lower_block_side_effect_statement', 694, '$lowerer'): ('remaining-named-code-dispatch', 686),
}


def audit(source, deparsed, optree, inventory):
    lines = source.splitlines()
    functions = re.findall(r'^sub\s+(\w+)\s*\{', source, re.M)
    assert len(functions) == 108 and len(set(functions)) == 108, 'source function population'
    assert set(functions) == {row['name'] for row in deparsed['functions']}, 'compiled function population'
    cvs = {row['id']: row for row in optree['cvs']}
    assert len(cvs) == 218 and sum(row['parent'] is None for row in cvs.values()) == 108, 'compiled CV population'
    observed, names, kinds = {}, collections.Counter(), collections.Counter()
    for cv in cvs.values():
        for call in cv['calls']:
            node = call['tree']['children'][-1]
            while node['op'] in ('null', 'rv2cv'):
                node = node['children'][-1]
            if node['op'] == 'entersub':
                assert cv['id'] == '_lower_mutation_slot_value_expr' and call['line'] == 6951
                observed[(cv['id'], call['path'])] = (6951,
                    '_bind_emission_dependency($lower_flow_composite_expr)', None)
                kinds['entersub'] += 1
                continue
            # A null rv2cv wrapper may enclose a returned CODE entersub.
            if node['op'] == 'gv':
                kinds['gv'] += 1
                continue
            if node['op'] in ('method_named', 'method'):
                kinds[node['op']] += 1
                continue
            key = (cv['id'], call['path'])
            if node['op'] == 'padsv':
                kinds['padsv'] += 1
                name = cv['pads'][node['targ']]['name']
                names[(cv['id'].split('/')[0], name[1:])] += 1
                owner, index = cv, node['targ']
                while owner['pads'][index].get('flags', 0) & 16777216:
                    index = owner['pads'][index]['parent_pad_index']
                    owner = cvs[owner['parent']]
                observed[key] = (call['line'], name, owner['id'] + ':pad:' + str(index))
            elif cv['id'] == '_codeblock_variable_call_candidate':
                kinds['multideref'] += 1
                observed[key] = (call['line'], '$deps->{bare_symbol_kind}', None)
            elif cv['id'] == '_lower_mutation_slot_value_expr':
                # The independent traversal above descends through the nested
                # returned-CODE call; its outer call is identified by source.
                raise AssertionError('returned CODE call was misclassified')
            else:
                raise AssertionError(('unknown native invocation', key, node['op']))
    expected_names = collections.Counter()
    for row in deparsed['functions']:
        expected_names.update((row['name'], name) for name in re.findall(r'&\$(\w+)\s*\(', row['compiled_source']))
    assert names == expected_names and sum(names.values()) == 810, 'independent deparsed/optree variable population'
    assert len(observed) == 812, 'dynamic invocation population'
    recorded = {(row['cv'], row['path']): row for row in inventory['calls']}
    assert len(recorded) == len(inventory['calls']) and set(recorded) == set(observed), 'complete invocation membership'
    remaining = {}
    for key, (line, name, binding) in observed.items():
        row = recorded[key]
        assert (row['line'], row['name'], row.get('binding')) == (line, name, binding), 'lexical binding identity'
        assert row['source_line'] == lines[line - 1], 'native source location'
        if row['class'].startswith('remaining-'):
            identity = (row['cv'].split('/')[0], line, name)
            decl = inventory['bindings'][binding]['declaration_line'] if binding else None
            assert identity not in remaining
            remaining[identity] = (row['class'], decl)
    assert remaining == REMAINING, 'remaining ingress families and lexical declarations'
    used = {binding for _, _, binding in observed.values() if binding is not None}
    assert used == set(inventory['bindings']) and len(used) == 207, 'complete binding population'
    headers = [(m.group(1), source[:m.start()].count('\n') + 1) for m in re.finditer(r'^sub\s+(\w+)\s*\{', source, re.M)]
    ranges = {name: (line, headers[i + 1][1] if i + 1 < len(headers) else len(lines) + 1)
              for i, (name, line) in enumerate(headers)}
    for key, binding in inventory['bindings'].items():
        line, name, category = binding['declaration_line'], binding['name'], binding['class']
        assert binding['declaration'] == lines[line - 1] and name in lines[line - 1], 'declaration source identity'
        lo, hi = ranges[binding['cv'].split('/')[0]]
        text = '\n'.join(lines[lo - 1:hi - 1])
        if category == 'local-helper-closure':
            assert re.search(re.escape(name) + r'\s*=\s*sub\b', text), 'literal local closure origin'
        elif category == 'local-required-resolver':
            intro = binding['introduction_lines'][0]
            body = '\n'.join(lines[line - 1:intro])
            assert 'return _bind_emission_dependency($cb);' in body, 'required resolver binding return'
            assert "unless ref($cb) eq 'CODE'" in body, 'required validation preserved'
        elif category == 'already-bound-dependency':
            intro = binding['introduction_lines'][0]
            body = '\n'.join(lines[line - 1:intro])
            assert '$require_dep->' in body or '_bind_emission_dependency(' in body, 'bound callback origin'
        elif not category.startswith('remaining-'):
            assert category == 'boundary-cold-fallback' and binding['cv'] == '_bind_emission_dependency'
    actual_classes = collections.Counter(row['class'] for row in inventory['calls'])
    assert dict(actual_classes) == inventory['classes'], 'class totals derived from members'
    assert actual_classes == collections.Counter({'already-bound-dependency': 359, 'already-bound-direct': 1,
        'boundary-cold-fallback': 1, 'local-helper-closure': 338, 'local-required-resolver': 96,
        'remaining-formal-trim': 4, 'remaining-inline-required': 1, 'remaining-named-code-dispatch': 1,
        'remaining-optional-ast': 2, 'remaining-optional-kind': 7, 'remaining-predicate': 2}), 'class population'
    raw_names = collections.Counter(re.findall(r'\$(\w+)\s*->\s*\(', source))
    compiled_names = collections.Counter(name for (_, name), count in names.items() for _ in range(count))
    assert sum(raw_names.values()) == 823 and raw_names - compiled_names == collections.Counter({
        '__ls_push_handler': 1, '__ls_hash_tree_walk': 2, '__ls_array_tree_walk': 2,
        '__ls_hash_tree_map': 2, '__ls_array_tree_map': 2,
        '__ls_hash_tree_reduce': 2, '__ls_array_tree_reduce': 2}), 'generated strings excluded by compiler'
    assert not deparsed['source_emissions_loaded'] and not optree['source_emissions_loaded'], 'cold syntax observation'
    return {'functions': 108, 'cvs': 218, 'variable_calls': 810, 'dynamic_calls': 812,
            'bindings': 207, 'remaining_sites': 17, 'classes': dict(sorted(actual_classes.items()))}


def main(capture):
    inventory_raw = (ROOT / (PREFIX + 'inventory.json')).read_bytes()
    inventory = json.loads(inventory_raw)
    native_rows = {}
    supplied = set()
    for label in ('native', 'optree', 'gap'):
        path = PREFIX + label + '.json'
        row = json.loads((ROOT / path).read_bytes())
        assert row['base'] == BASE and row['returncode'] == 0 and row['unchanged']
        assert not base64.b64decode(row['stderr_base64'], validate=True)
        assert row['producer_sha256'] == sha((ROOT / (PREFIX + label + '-capture.py')).read_bytes())
        assert len(row['inputs']) == 212
        for p, digest in row['inputs'].items():
            assert sha((ROOT / p).read_bytes()) == digest, 'native supplied input identity: ' + p
            supplied.add(p)
        native_rows[label] = json.loads(base64.b64decode(row['stdout_base64'], validate=True))
    result = audit((ROOT / MODULE).read_text(), native_rows['native'], native_rows['optree'], inventory)
    assert inventory['inputs'] == {p: sha((ROOT / p).read_bytes()) for p in (MODULE, PREFIX + 'native.json', PREFIX + 'optree.json')}
    assert inventory['producer_sha256'] == sha((ROOT / (PREFIX + 'inventory.py')).read_bytes())
    spec = importlib.util.spec_from_file_location('inventory_producer', ROOT / (PREFIX + 'inventory.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    expected = module.derive()
    assert {k: v for k, v in inventory.items() if k not in ('inputs', 'producer_sha256')} == expected, 'actual producer recurrence'
    report = {'result': 'PASS', 'summary': result, 'native_input_union': len(supplied),
        'producer_sha256': sha(Path(__file__).read_bytes()), 'inventory_sha256': sha(inventory_raw)}
    target = ROOT / (PREFIX + 'review.json')
    if capture:
        assert not target.exists(), 'one-shot review'
        target.write_text(json.dumps(report, indent=2) + '\n')
    else:
        assert json.loads(target.read_bytes()) == report
    print('Independent inventory review PASS108 functions/218 CVs/812 CODE calls/207 bindings/17 remaining sites')


if __name__ == '__main__':
    assert sys.argv[1:] in ([], ['--capture'])
    main(bool(sys.argv[1:]))
