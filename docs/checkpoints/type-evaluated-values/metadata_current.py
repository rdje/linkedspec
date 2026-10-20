"""Derive the current graph population; reuse the unchanged metadata syntax reader."""
import metadata_oracle as m


def verify(inputs, mapping, decode):
    rendered = m.sections(mapping.decode())
    markdown = {path for path in inputs if path.startswith(('docs/knowledge/', 'docs/decisions/'))
                and path.endswith('.md')}
    expected, identifiers = [], set()
    fields_count = items_count = 0
    for path in sorted(markdown):
        header = m.header(decode(inputs[path]['base64']))
        questions = m.answers(header)
        if not questions:
            continue
        identifier = m.scalar(header['id']['raw'])
        assert identifier not in identifiers
        identifiers.add(identifier)
        section = rendered[identifier]
        assert m.field_line(section, 'answers') == '- **answers:** ' + ' | '.join(questions)
        route = ''
        for name in ('evidence', 'reverify'):
            source, line = header.get(name), m.field_line(section, name)
            if source is None:
                assert line is None
            elif source['kind'] == 'scalar':
                value = m.scalar(source['raw'])
                assert line == ('- **' + name + ':** `' + value + '`' if value else None)
                if name == 'reverify' and value:
                    route = '`' + value + '`'
            else:
                assert source['kind'] == 'block'
                values = [m.scalar(item) for item in source['items'] if m.scalar(item)]
                assert m.code_values(line, name) == values
                fields_count += 1
                items_count += len(values)
                if name == 'reverify':
                    route = '[' + str(len(values)) + (' entry' if len(values) == 1 else ' entries') + '](#' + identifier + ')'
        date = m.scalar(header.get('date', {}).get('raw', ''))
        for question in questions:
            line = '- "' + question + '" -> [' + identifier + '](' + path + ')'
            if date:
                line += ' · ' + date
            if route:
                line += ' · reverify: ' + route
            expected.append(line)
    actual = [line for line in mapping.decode().splitlines() if line.startswith('- "') and ' -> [' in line]
    assert set(rendered) == identifiers
    assert actual == sorted(set(expected), key=lambda value: value.encode())
    assert len(actual) == len(expected)
    assert (len(markdown), len(identifiers), fields_count, items_count) == (1487, 1349, 248, 897)
    return dict(markdown=len(markdown), facts=len(identifiers), question_keys=len(actual),
                list_fields=fields_count, list_items=items_count)
