"""Independent source/header and CommonMark readers for captured metadata graphs."""
import re


def scalar(value):
    value = value.strip()
    if value.startswith('"'):
        value = value[1:]
    if value.endswith('"'):
        value = value[:-1]
    return value


def header(value):
    lines = value.decode().splitlines()
    if not lines or lines[0].strip() != '---':
        return {}
    fields, active = {}, None
    for line in lines[1:]:
        if line.strip() == '---':
            break
        key = re.match(r'^([A-Za-z_][A-Za-z0-9_]*):\s*(.*)$', line)
        item = re.match(r'^[ \t]+-[ \t]+(.*)$', line)
        if key:
            name, raw = key.groups()
            assert name not in fields, ('duplicate supplied header key', name)
            kind = 'block' if raw == '' else 'inline' if raw.startswith('[') and raw.endswith(']') else 'scalar'
            fields[name] = dict(kind=kind, raw=raw, items=[])
            active = name if kind == 'block' else None
        elif item and active is not None:
            fields[active]['items'].append(item[1])
    return fields


def answers(fields):
    value = fields.get('answers')
    if value is None:
        return []
    if value['kind'] == 'block':
        return [scalar(item) for item in value['items'] if scalar(item)]
    if value['kind'] == 'inline':
        return [scalar(item) for item in value['raw'][1:-1].split(',') if scalar(item)]
    return []


def sections(mapping):
    pieces = re.split(r'^### ([^\n]+)\n', mapping, flags=re.M)
    result = dict(zip(pieces[1::2], pieces[2::2]))
    assert len(result) == (len(pieces)-1)//2, 'unique generated fact sections'
    return result


def field_line(section, name):
    prefix = '- **' + name + ':** '
    lines = [line for line in section.splitlines() if line.startswith(prefix)]
    assert len(lines) <= 1
    return lines[0] if lines else None


def code_values(line, name):
    prefix = '- **' + name + ':** '
    assert line is not None and line.startswith(prefix), ('missing named metadata', name)
    text, cursor, values = line[len(prefix):], 0, []
    while cursor < len(text):
        opening = re.match(r'`+', text[cursor:])
        assert opening, ('metadata code opening', name)
        delimiter = opening[0]
        cursor += len(delimiter)
        closing = re.search(r'(?<!`)'+re.escape(delimiter)+r'(?!`)', text[cursor:])
        assert closing, ('metadata code closing', name)
        value = text[cursor:cursor+closing.start()]
        if value.startswith(' ') and value.endswith(' ') and value.strip(' '):
            value = value[1:-1]
        values.append(value)
        cursor += closing.end()
        if cursor < len(text):
            assert text[cursor:cursor+3] == ' · ', ('metadata item separator', name)
            cursor += 3
    return values


def verify_graph(inputs, mapping, decode):
    text = mapping.decode()
    rendered = sections(text)
    expected_questions, identifiers = [], set()
    fact_count, field_count, item_count = 0, 0, 0
    markdown = {path for path in inputs if path.startswith(('docs/knowledge/', 'docs/decisions/')) and path.endswith('.md')}
    assert len(markdown) == 1487, 'complete supplied Markdown graph'
    for path in sorted(markdown):
        fields = header(decode(inputs[path]['base64']))
        questions = answers(fields)
        if not questions:
            continue
        identifier = scalar(fields['id']['raw'])
        assert identifier not in identifiers and re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*', identifier)
        identifiers.add(identifier)
        fact_count += 1
        section = rendered[identifier]
        assert field_line(section, 'answers') == '- **answers:** ' + ' | '.join(questions)
        route = ''
        for name in ('evidence', 'reverify'):
            source = fields.get(name)
            line = field_line(section, name)
            if source is None:
                assert line is None
            elif source['kind'] == 'scalar':
                value = scalar(source['raw'])
                assert line == ('- **' + name + ':** `' + value + '`' if value else None), ('exact scalar metadata', path, name)
                if name == 'reverify' and value:
                    route = '`' + value + '`'
            else:
                # This complete current snapshot has block metadata only. Public
                # inline forms are covered independently by all30 native rows.
                assert source['kind'] == 'block', 'declared current field-shape population'
                values = [scalar(item) for item in source['items'] if scalar(item)]
                assert code_values(line, name) == values, ('authored metadata values/order/multiplicity', path, name)
                field_count += 1
                item_count += len(values)
                if name == 'reverify':
                    route = '[' + str(len(values)) + (' entry' if len(values) == 1 else ' entries') + '](#' + identifier + ')'
        date = scalar(fields.get('date', {}).get('raw', ''))
        for question in questions:
            line = '- "' + question + '" -> [' + identifier + '](' + path + ')'
            if date:
                line += ' · ' + date
            if route:
                line += ' · reverify: ' + route
            expected_questions.append(line)
    actual = [line for line in text.splitlines() if line.startswith('- "') and ' -> [' in line]
    assert set(rendered) == identifiers and fact_count == 1349
    assert actual == sorted(set(expected_questions), key=lambda value: value.encode()), 'complete question metadata and pointers'
    assert len(actual) == len(expected_questions) == 10455
    assert (field_count, item_count) == (248, 897)
    return dict(markdown=len(markdown), facts=fact_count, question_keys=len(actual), list_fields=field_count, list_items=item_count)
