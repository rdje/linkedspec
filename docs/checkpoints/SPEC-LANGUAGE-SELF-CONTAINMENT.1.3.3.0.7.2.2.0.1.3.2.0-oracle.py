"""Author occurrence positions from original fragments, never observed parser text."""
import json
from pathlib import Path


def author():
    cases = []

    def add(name, method, pieces, leading='', trailing='', receiver=False):
        head = method + '('
        payload = ','.join(pieces)
        source = leading + head + payload + ')' + trailing
        start = len(leading) + len(head)
        arguments, slots = [], []
        for index, piece in enumerate(pieces):
            raw = piece.strip()
            left = len(piece) - len(piece.lstrip())
            slots.append({'slot': index, 'raw': piece, 'start': start, 'end': start + len(piece)})
            if raw:
                arguments.append({'raw': raw, 'start': start + left,
                                  'end': start + left + len(raw), 'slot': index})
            start += len(piece) + 1
        cases.append({'id': name, 'source': source, 'receiver': receiver, 'method': method,
                      'trimmed': source.strip(), 'payload': payload,
                      'payload_start': len(leading) + len(head),
                      'slots': slots, 'arguments': arguments})

    add('twins', 'switch', [' kind ', ' case("雪", case("雪")) ',
                           ' case("雪", case("雪")) ', ' default(default()) '], '\u2003\r\n', '\r\n\t')
    add('empty-slots', 'switch', ['', ' kind ', '  ', ' case("x") ', '', ' default() ', ''], '  ', '  ')
    add('quotes-braces-index', 'call', [' "a,b" ', " 'c,d' ", ' array(1,2) ',
                                      ' { say("雪,β") } ', ' tree[cat("a", "b")] '])
    add('pattern-context', 'matches', [' "x,雪" ', ' /(x),雪/imu '], '\u2003', '\r\n')
    add('receiver-pattern', 'filter_match', [' /(x),雪/imu '], '  ', ' ', True)
    add('numeric-slash', 'array', [' /(14,2) ', ' 14/cos '])
    add('zero-argument', 'default', [], ' \r\n', '\u2003')
    add('whitespace-only', 'default', [' \t\r\n '])
    add('repeated-ordinary', 'call', [' same ', 'same', ' same '])
    add('unicode-crlf', 'call', [' "雪" ', '\r\n case("β") \r\n', ' "😀" '], '\u2003', '\r\n')
    return cases


if __name__ == '__main__':
    Path(__file__.removesuffix('oracle.py') + 'cases.json').write_text(
        json.dumps(author(), ensure_ascii=False, indent=2) + '\n')
