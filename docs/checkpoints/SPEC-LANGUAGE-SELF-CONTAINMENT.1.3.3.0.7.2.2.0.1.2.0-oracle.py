"""Author a mixed pipeline oracle from literal segments, never observed events."""
from pathlib import Path
import json

PREFIX = __file__.removesuffix('oracle.py')
REGEX = [
    ('push', "push(items, '雪')", {'target': 'items', 'value': "'雪'"}),
    ('set_value', "set(value, '雪')", {'target': 'value', 'source': "'雪'"}),
    ('regex_subst', "regex_subst(value, /a/, '雪', g)", {'scope': None, 'target': 'value', 'pattern': '/a/', 'replacement': "'雪'", 'flags': 'g'}),
    ('split_array', "split(items, input, ',')", {'target': 'items', 'source': None, 'delimiter': '/\\,/' }),
    ('split_each', "split_each(items, ',')", {'target': 'items', 'delimiter': '/\\,/' }),
    ('trim_each', 'trim_each(items)', {'target': 'items'}),
    ('filter_nonempty', 'filter_nonempty(items)', {'target': 'items'}),
    ('lowercase_each', 'lowercase_each(items)', {'target': 'items'}),
    ('uppercase_each', 'uppercase_each(items)', {'target': 'items'}),
    ('uniq_array', 'uniq(items)', {'target': 'items'}),
    ('filter_match', 'filter_match(items, /a/)', {'target': 'items', 'pattern': '/a/'}),
]
STATEMENT = [
    ('print_foreach_iterable', 'print $_ foreach(@items)', {'iterable': 'items'}),
    ('split_trim_filter_assignment', r'my @parts = grep { length($_) } map { my $v = $_; $v =~ s/^ +//g; $v } split /,/, $input', {'target': 'parts', 'source': 'input', 'delimiter': '/,/', 'transforms': ['split', 'trim_each', 'filter_nonempty'], 'scope': 'my'}),
    ('scalar_assignment_operator', "value = '雪'", {'target': 'value', 'source': "'雪'"}),
    ('array_append_operator', "items += '雪'", {'target': 'items', 'value': "'雪'"}),
    ('array_end_mutation_method', "items.push_back('雪')", {'target': 'items', 'method': 'push_back', 'value': "'雪'"}),
    ('hash_index_assignment_operator', "tree['key'] = '雪'", {'target': 'tree', 'key': "'key'", 'value': "'雪'"}),
    ('hash_index_assignment_operator', "tree['key'][0] = '雪'", {'target': 'tree', 'path_segment_count': 2, 'value': "'雪'"}),
    ('set_key_statement', "set_key(tree, 'key', '雪')", {'target': 'tree', 'key': "'key'", 'value': "'雪'"}),
    ('value_drop_statement', "trim(' 雪 ')", {'expr': "trim(' 雪 ')"}),
    ('value_drop_statement', "' 雪 '.trim()", {'expr': "' 雪 '.trim()"}),
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
    append('print "雪;')
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
            if contract in {r[0] for r in REGEX[3:]}:
                events['value_drop_statement'].append({'raw': raw, 'args': {'expr': raw}, 'source_span': span})
            append(';\r\n\u2003')
        if sequence == REGEX + STATEMENT:
            statement('# β')
            append('\r\n\t')
    return {'action': action, 'statements': statements,
            'contracts': [{'id': name, 'family': 'regex' if name in {r[0] for r in REGEX} else 'statement',
                           'events': events[name]} for name in dict.fromkeys(name for name, _, _ in REGEX + STATEMENT)]}


if __name__ == '__main__':
    data = author()
    Path(PREFIX + 'cases.json').write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
    print('Authored nineteen contracts, ' + str(len(data['statements'])) + ' statements and '
          + str(sum(len(c['events']) for c in data['contracts'])) + ' selected occurrences')
