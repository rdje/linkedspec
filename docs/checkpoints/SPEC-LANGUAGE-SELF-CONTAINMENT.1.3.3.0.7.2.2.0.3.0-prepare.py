"""Author occurrence intervals from literal segments, before measuring lowering."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('prepare.py')
A = 'out=matches("x", /x/)'
B = 'out=matches("x", /y/)'
D = "out=matches('x', /x/)"
S = 'set(counter,2)'


def fixture(name, pieces, expected, contract='scalar_assignment_operator'):
    action = ''; spans = []
    for role, text in pieces:
        start = len(action); action += text
        if role in ('literal_twin', 'real'):
            spans.append({'role': role, 'raw': text, 'start': start, 'end': len(action)})
    return {'id': name, 'segments': [{'role': role, 'text': text} for role, text in pieces],
            'action': action, 'source': 'Top:: I { ' + action + ' }', 'input': '',
            'contract': contract, 'spans': spans, 'expected_value': expected,
            'scope': 'Authored literal/value and original scalar occurrence oracle; baseline outcomes are unmeasured.'}


def main():
    plain = lambda text: ('plain', text)
    real = lambda text: ('real', text)
    literal = lambda text: ('literal_twin', text)
    cases = [
        fixture('quoted_before', [plain("quoted='"), literal(A), plain("'; "), real(A),
                                 plain('; return([quoted,out])')], [A, 1]),
        fixture('quoted_after', [real(A), plain("; quoted='"), literal(A),
                                plain("'; return([quoted,out])")], [A, 1]),
        fixture('interleaved_equal', [real(A), plain("; quoted='"), literal(A), plain("'; "),
                                     real(B), plain('; '), real(A),
                                     plain('; return([quoted,out])')], [A, 1]),
        fixture('distinct_twins', [plain("quoted='"), literal(B), plain("'; "), real(A),
                                  plain('; '), real(B), plain('; return([quoted,out])')], [B, 0]),
        fixture('double_quoted_before', [plain('quoted="'), literal(D), plain('"; '), real(D),
                                        plain('; return([quoted,out])')], [D, 1]),
        fixture('unicode_crlf', [plain("quoted='雪 "), literal(A), plain("';\r\n"), real(A),
                                plain('; return([quoted,out])')], ['雪 ' + A, 1]),
        fixture('generated_data', [plain("quoted=cat('"), literal(A), plain("'); "), real(A),
                                  plain('; return([quoted,out])')], [A, 1]),
        fixture('nested_if', [plain("if(true) { quoted='"), literal(A), plain("'; "), real(A),
                             plain('; return([quoted,out]) }')], [A, 1]),
        fixture('deferred_body', [plain("cb={|| quoted='"), literal(A), plain("'; "), real(A),
                                 plain('; return([quoted,out]) }; return(cb())')], [A, 1]),
        fixture('repeated_real', [real(A), plain('; '), real(A),
                                 plain('; return(out)')], 1),
        fixture('distinct_real', [real(A), plain('; '), real(B),
                                 plain('; return(out)')], 0),
        fixture('data_only', [plain("quoted='"), literal(A),
                             plain("'; return(quoted)")], A),
        fixture('set_before', [plain('quoted="'), literal(S), plain('"; '), real(S),
                              plain('; return([quoted,counter])')], [S, 2], 'set_value'),
        fixture('set_after', [real(S), plain('; quoted="'), literal(S),
                             plain('"; return([quoted,counter])')], [S, 2], 'set_value'),
    ]
    assert len(cases) == len({case['id'] for case in cases}) == 14
    for case in cases:
        assert case['action'] == ''.join(segment['text'] for segment in case['segments'])
        for span in case['spans']:
            assert case['action'][span['start']:span['end']] == span['raw']
    path = Path(PREFIX + 'cases.json'); assert not path.exists()
    path.write_text(json.dumps(cases, ensure_ascii=False, indent=2) + '\n')
    print('Authored', len(cases), 'literal segment/frame/value oracles')


if __name__ == '__main__':
    main()
