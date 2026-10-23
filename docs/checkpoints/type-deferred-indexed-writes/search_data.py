"""Decode the observed mdBook data wrapper; compare only prose whitespace canonically."""
import json
import re
import common as c

PREFIX = "window.search = Object.assign(window.search, JSON.parse('"
SUFFIX = "'));"


def decode_asset(asset):
    text = c.decode(asset['base64']).decode()
    assert c.sha(c.decode(asset['base64'])) == asset['sha256']
    assert text.startswith(PREFIX) and text.rstrip().endswith(SUFFIX)
    body = text.rstrip()[len(PREFIX):-len(SUFFIX)]
    output = []
    i = 0
    escapes = {'b':'\b','f':'\f','n':'\n','r':'\r','t':'\t','v':'\v','0':'\0',
               "'":"'",'"':'"','\\':'\\','/':'/'}
    while i < len(body):
        char = body[i]
        i += 1
        if char != '\\':
            assert char not in "'\r\n", 'unexpected JS literal delimiter'
            output.append(char)
            continue
        char = body[i]
        i += 1
        if char in escapes:
            output.append(escapes[char])
        elif char in ('u', 'x'):
            width = 4 if char == 'u' else 2
            digits = body[i:i+width]
            assert len(digits) == width and re.fullmatch('[0-9a-fA-F]+', digits)
            output.append(chr(int(digits, 16)))
            i += width
        else:
            raise AssertionError(('unexpected JS escape', char))
    decoded = ''.join(output)
    decoded = re.sub('[\ud800-\udbff][\udc00-\udfff]',
                     lambda match: chr(0x10000 + (ord(match[0][0])-0xd800)*1024
                                       + ord(match[0][1])-0xdc00), decoded)
    return json.loads(decoded)


def canonical(asset):
    value = decode_asset(asset)
    documents = value['index']['documentStore']['docs']
    assert isinstance(documents, dict)
    for document in documents.values():
        assert isinstance(document['body'], str)
        document['body'] = re.sub(r'[ \t\r\n\f]+', ' ', document['body'])
    return value


def corrupt_url(asset):
    value = decode_asset(asset)
    original = value['doc_urls'][0]
    value['doc_urls'][0] += '-corrupt'
    serialized = json.dumps(value, ensure_ascii=True, separators=(',', ':'))
    literal = serialized.replace('\\', '\\\\').replace("'", "\\'")
    raw = (PREFIX + literal + SUFFIX + '\n').encode()
    changed = {**asset, 'base64':c.encode(raw), 'sha256':c.sha(raw)}
    assert decode_asset(changed) == value
    assert value['doc_urls'][0] != original
    return changed
