"""Retain exact Legacy dispatch mechanisms and independently authored fixture cases."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0-'
PATH = 'perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm'
raw = (ROOT / PATH).read_bytes()
source = raw.decode()
dispatch = source.split('my %dispatch = (', 1)[1].split('\n );', 1)[0]
pairs = re.findall(r"'([^']+)' => \\&(_\w+)", dispatch)
assert len(pairs) == len(set(k for k, _ in pairs))
starts = list(re.finditer(r'^sub (\w+)\s*\{', source, re.M))
bodies = {m[1]: source[m.start():starts[i+1].start() if i+1 < len(starts) else len(source)]
          for i, m in enumerate(starts)}
SPECIAL = {
    'call': ('call(Done)', {'callee': 'Done'}),
    'push_single_arg': ('push(items)', {'source': 'items'}),
    'push_indexed_arg': ('push(items, 2)', {'source': 'items', 'index': '2'}),
    'push_target_arg': ('push(items, target)', {'source': 'items', 'target': 'target'}),
    'push_target_indexed_arg': ('push(items, target, 2)', {'source': 'items', 'target': 'target', 'index': '2'}),
    'push_scope_target_arg': ('push(scope, items, target)', {'scope': 'scope', 'source': 'items', 'target': 'target'}),
    'return_general': ('return( length(/a\\)b\\(/i) )', {'payload': 'length(/a\\)b\\(/i)'}),
    'return': ('return(Done,  nested(1) )', {'label': 'Done', 'arg': 'nested(1)'}),
    'capture_macro': ('$CAPTURE', {}),
    'capture_if_macro': ('CAPTURE_IF()', {}),
    'capture_until_boundary': ('capture_until_boundary("stop", end)', {'boundaries': ['stop', 'end']}),
    'input_slice': ('input_slice(1, nested("a,b"))', {})}
ALIASES = {
    'capture_take_slice': 'capture_take', 'capture_take_slice_len': 'capture_take_len',
    'start_capture_slice_from_mark': 'start_capture_slice_from',
    'capture_from_mark': 'capture_from', 'capture_len_from_mark': 'capture_len_from',
    'capture_take_from_mark': 'capture_take', 'capture_take_len_from_mark': 'capture_take_len_from',
    'capture_rest_from_mark': 'capture_rest_from', 'capture_rest_len_from_mark': 'capture_rest_len_from',
    'capture_take_rest_from_mark': 'capture_take_rest_from', 'capture_take_rest_len_from_mark': 'capture_take_rest_len_from',
    'capture_until_cursor_from_mark': 'capture_until_cursor_from',
    'capture_until_cursor_len_from_mark': 'capture_until_cursor_len_from',
    'capture_take_until_cursor_from_mark': 'capture_take_until_cursor_from',
    'capture_take_until_cursor_len_from_mark': 'capture_take_until_cursor_len_from',
    'capture_between_marks': 'capture_between', 'capture_len_between_marks': 'capture_len_between',
    'capture_take_between_marks': 'capture_take_between', 'capture_take_between_len_marks': 'capture_take_between_len'}
LABEL = {'capture', 'capture_if'}
INDEX = {'entry_group', 'match_group'}
NAME = {'entry_named', 'entry_has', 'match_named', 'match_has'}
BETWEEN = {'capture_between_marks', 'capture_len_between_marks', 'capture_take_between_marks',
           'capture_take_between_len_marks'}
MARK = set(ALIASES) - {'capture_take_slice', 'capture_take_slice_len'} - BETWEEN
MARK |= {'mark_here', 'mark_input_start', 'mark_input_end', 'mark_entry_start', 'mark_entry_end',
         'mark_match_start', 'mark_match_end', 'mark_capture_slice', 'clear_mark', 'mark_exists',
         'mark_pos', 'mark_line', 'mark_col'}
SPECIAL['mark_copy'] = ('mark_copy(first, second)', {'target': 'first', 'source': 'second'})

def fixture(contract):
    if contract in SPECIAL:
        return SPECIAL[contract]
    name = ALIASES.get(contract, contract)
    if contract in LABEL:
        return name + '(Done)', {'label': 'Done'}
    if contract in INDEX:
        return name + '(2)', {'index': '2'}
    if contract in NAME:
        return name + '(named)', {'name': 'named'}
    if contract in BETWEEN:
        return name + '(first, second)', {'start': 'first', 'end': 'second'}
    if contract in MARK:
        return name + '(edge)', {'mark': 'edge'}
    return name + '()', {}

families = {'call-return-push': [], 'anonymous-capture': [], 'named-capture': [],
            'mark-control': [], 'cursor-input': [], 'entry-match': []}
inventory = []
cases = []
for contract, handler in pairs:
    body = bodies[handler]
    if contract in {'call', 'return', 'return_general'} or contract.startswith('push_'):
        family = 'call-return-push'
    elif contract.startswith('mark_') or contract == 'clear_mark':
        family = 'mark-control'
    elif contract in ALIASES and contract not in {'capture_take_slice', 'capture_take_slice_len'}:
        family = 'named-capture'
    elif contract.startswith(('capture', 'start_capture')):
        family = 'anonymous-capture'
    elif contract.startswith(('entry_', 'match_')):
        family = 'entry-match'
    else:
        family = 'cursor-input'
    families[family].append(contract)
    inventory.append({'contract': contract, 'handler': handler, 'family': family,
                      'line': source[:source.index('sub ' + handler + ' {')].count('\n') + 1,
                      'regex_global_loops': len(re.findall(r'while\s*\([^\n]*=~[^\n]*/g', body)),
                      'event_constructors': len(re.findall(r'push\s+@events\s*,', body)),
                      'source_recorders': body.count('_record_scanned_source_event('),
                      'parser_callbacks': body.count('_parse_method_function_expr('),
                      'trim_callbacks': body.count('_trim_action_ir_value('),
                      'nested_scans': len(re.findall(r'_scan_contract_\w+\(', body))})
    literal, args = fixture(contract)
    # Cumulative authored fragments establish scalar coordinates independently
    # of regex matches or observed event raw strings.
    prefix = 'λ\r\n'
    separator = '; note(); '
    suffix = ';'
    action = prefix + literal + separator + literal + suffix
    positions = [[len(prefix), len(prefix) + len(literal)],
                 [len(prefix + literal + separator), len(prefix + literal + separator + literal)]]
    cases.append({'id': contract, 'family': family, 'contracts': [contract], 'action': action,
                  'expected_events': [{'raw': literal, 'args': args}, {'raw': literal, 'args': args}],
                  'original_spans': positions,
                  'toolbox': contract in {'call', 'return_general', 'return', 'capture_macro',
                                         'capture_until_boundary', 'capture_from_mark',
                                         'mark_copy', 'input_slice', 'entry_named', 'match_group'}})
cases += [
    {'id': 'call-recognition-exclusions', 'family': 'call-return-push', 'contracts': ['call'],
     'action': 'recognize_once(scope, call(Hidden)); observe_recognition(scope, call(Other)); call(Done)',
     'expected_events': [{'raw': 'call(Done)', 'args': {'callee': 'Done'}}],
     'original_spans': [[len('recognize_once(scope, call(Hidden)); observe_recognition(scope, call(Other)); '), len('recognize_once(scope, call(Hidden)); observe_recognition(scope, call(Other)); call(Done)')]], 'toolbox': False},
    {'id': 'push-literal-target-exclusions', 'family': 'call-return-push', 'contracts': ['push_target_arg'],
     'action': 'push(items, true); push(items, false); push(items, undef); push(items, target)',
     'expected_events': [{'raw': 'push(items, target)', 'args': {'source': 'items', 'target': 'target'}}],
     'original_spans': [[len('push(items, true); push(items, false); push(items, undef); '), len('push(items, true); push(items, false); push(items, undef); push(items, target)')]], 'toolbox': False},
    {'id': 'boundary-quoted-comma-original', 'family': 'anonymous-capture', 'contracts': ['capture_until_boundary'],
     'action': 'capture_until_boundary("a,b", end)',
     'expected_events': [{'raw': 'capture_until_boundary("a,b", end)',
                          'args': {'boundaries': ['"a', 'b"', 'end']}}],
     'intended_boundaries': ['a,b', 'end'], 'original_spans': [[0, len('capture_until_boundary("a,b", end)')]], 'toolbox': True}]
assert sum(len(v) for v in families.values()) == len(pairs)
report = {'owner': 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0',
          'path': PATH, 'sha256': hashlib.sha256(raw).hexdigest(), 'contracts': inventory,
          'families': families,
          'scope': 'Exact repository-owned source dispatch and textual mechanism census; fixture expected values and cumulative literal scalar spans are authored independently. Internal compatibility IDs are not public helper admission; runtime observations verify ownership and source population separately.'}
(ROOT / (PREFIX + 'inventory.json')).write_text(json.dumps(report, indent=2) + '\n')
(ROOT / (PREFIX + 'cases.json')).write_text(json.dumps(cases, indent=2, ensure_ascii=False) + '\n')
print(str(len(pairs)) + ' original dispatch contracts; ' + str({k: len(v) for k, v in families.items()}))
