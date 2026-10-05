"""Author a mixed BasicRules oracle from literal segments, never observed events."""
from pathlib import Path
import json

PREFIX = __file__.removesuffix('oracle.py')
REGEX = [
    ('assign_call_my', 'my $cx = call(Done)', {'target': '$cx', 'callee': 'Done', 'scope': 'my'}),
    ('assign_call', '$ex = call(Done)', {'target': '$ex', 'callee': 'Done', 'scope': 'existing'}),
    ('push_child_call_indexed_builtin', 'push @ix, call(Done)->[2]', {'target': 'ix', 'callee': 'Done', 'index': '2'}),
    ('push_child_call_builtin', 'push @px, call(Done)', {'target': 'px', 'callee': 'Done'}),
    ('return_call', 'return call(Done)', {'callee': 'Done', 'context': 'return'}),
    ('entry_slot', 'entry_slot( )', {}),
    ('gap_span', 'gap_span()', {}),
    ('gap_text', 'gap_text( )', {}),
    ('gap_kind', 'gap_kind()', {}),
]
STATEMENT = [
    ('return_bare', 'return 7', {'payload': '7'}),
    ('exit_bare', 'exit 7', {'payload': '7'}),
    ('linecount_prefix_newline_matches', r'my @lines = substr($$STRING, 0, $IPOS) =~ /\n/g', {'target': 'lines', 'upto': '$IPOS'}),
    ('print_capture_substr', r'print "<" . substr($$STRING, $IPOS, $LSPOS - $IPOS - 1) . ">\n"', {'source': 'capture_substr'}),
    ('my_declare_bare', 'my $dx', {'declaration_type': 'scalar', 'names': ['dx'], 'scope': 'my'}),
    ('assign_match_my', 'my $mx = $CAPTURE', {'target': 'mx', 'source': 'CAPTURE', 'scope': 'my'}),
    ('destructure_imatch_list_my', 'my ($ax, $bx) = @IMATCH_LIST', {'targets': ['ax', 'bx'], 'source': 'IMATCH_LIST', 'scope': 'my'}),
    ('regex_subst_assignment', '$sx =~ s/a/b/g', {'target': 'sx', 'pattern': '/a/', 'replacement': '/b/', 'flags': 'g', 'scope': None}),
    ('next_bare', 'next LOOP', {}),
    ('ref_field_assign', 'my $fx = $node->{key}[0]', {'target': 'fx', 'source': 'node', 'path': '{key}[0]', 'scope': 'my'}),
    ('position_tracking', '$tx = pos($$STRING)', {'category': 'position_tracking'}),
]


def author():
    action, statements = '', []
    events = {name: [] for name, _, _ in REGEX + STATEMENT}

    def append(text):
        nonlocal action
        start = len(action)
        action += text
        return {'start': start, 'end': len(action)}

    def statement(text):
        span = append(text)
        statements.append({'raw': text, 'source_span': span})
        return span

    statement('# 雪')
    append('\r\n \t')
    quoted_start = len(action)
    append('note="雪;')
    for contract, raw, args in REGEX:
        events[contract].append({'raw': raw, 'args': args, 'source_span': append(raw)})
        append(';')
    append('"')
    statements.append({'raw': action[quoted_start:], 'source_span': {'start': quoted_start, 'end': len(action)}})
    append(';\r\n\t')
    for sequence in (REGEX + STATEMENT, list(reversed(REGEX + STATEMENT))):
        for contract, raw, args in sequence:
            span = statement(raw)
            events[contract].append({'raw': raw, 'args': args, 'source_span': span})
            append(';\r\n\u2003')
        if sequence == REGEX + STATEMENT:
            statement('# β')
            append('\r\n\t')
    return {'action': action, 'statements': statements,
            'contracts': [{'id': name, 'family': 'regex' if name in {r[0] for r in REGEX} else 'statement',
                           'events': events[name]} for name, _, _ in REGEX + STATEMENT]}


if __name__ == '__main__':
    data = author()
    Path(PREFIX + 'cases.json').write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
    print('Authored twenty contracts, ' + str(len(data['statements'])) + ' statements and '
          + str(sum(len(c['events']) for c in data['contracts'])) + ' selected occurrences')
