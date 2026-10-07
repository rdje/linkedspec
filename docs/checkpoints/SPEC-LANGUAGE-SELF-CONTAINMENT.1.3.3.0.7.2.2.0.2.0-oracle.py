"""Authored scalar intervals and existing lexical contracts, never scanner-derived."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('oracle.py')
REPRESENTATIVES = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.0-cases.json'


def author():
    rows = []

    def case(name, contract, pieces):
        source, events = '', []
        for piece in pieces:
            if isinstance(piece, str):
                source += piece
            else:
                raw, args = piece
                start = len(source)
                source += raw
                events.append({'raw': raw, 'args': args,
                               'source_span': {'start': start, 'end': len(source)}})
        rows.append({'id': name, 'contract': contract, 'source': source, 'events': events})

    def set_event(value):
        return (f'set(counter,{value})', {'target': 'counter', 'source': str(value)})

    def flow(value):
        return (f'if({value})', {'condition': value})

    case('interleaved_original_mapper', 'set_value',
         ['text="set(counter,1)"; ', set_event(2), '; ', set_event(1), '; return(counter)'])
    case('suppressed_original_return', 'return_general',
         [('return(\'return("x")\')', {'payload': '\'return("x")\''}),
          '; ', ('return("x")', {'payload': '"x"'})])
    case('double_quote', 'set_value', ['"set(counter,1)"; ', set_event(2)])
    case('single_quote', 'set_value', ["'set(counter,1)'; ", set_event(2)])
    case('escaped_double_quote', 'set_value',
         ['"quote\\\"; set(counter,1); slash\\\\"; ', set_event(2)])
    case('escaped_single_quote', 'set_value',
         ["'quote\\'; set(counter,1); slash\\\\'; ", set_event(2)])
    case('unicode_scalar_crlf', 'set_value',
         ['note("雪😀 set(counter,1)");\r\n\u2003', set_event(2), '; ', set_event(1)])
    case('quoted_comment_data', 'if_flow', ['"# if(true)"; ', flow('false')])
    case('backtick_payload_only_scanned', 'set_value',
         [chr(96) + 'set(counter,1)' + chr(96) + '; ', set_event(2)])
    for name, opener, closer in [
            ('q_pipe', 'q|', '|'), ('qq_pipe', 'qq|', '|'),
            ('q_braces', 'q{', '}'), ('qr_slash', 'qr/', '/'),
            ('m_slash', 'm/', '/'), ('q_angle', 'q<', '>')]:
        case(name, 'set_value', [opener + 'set(counter,1)' + closer + '; ', set_event(2)])
    case('host_substitution_segments', 'set_value',
         ['s{set(counter,1)}{set(counter,3)}; ', set_event(2)])
    case('host_translation_segments', 'set_value',
         ['tr/set(counter,1)/set(counter,3)/; ', set_event(2)])
    for name, source in [('literal_receiver', "' 雪 '.trim()"),
                         ('literal_helper_argument', "trim(' 雪 ')")]:
        case(name, 'value_drop_statement', [(source, {'expr': source})])
    case('quoted_flow_condition', 'if_flow',
         [('if("if(true)")', {'condition': '"if(true)"'})])
    case('helper_pattern', 'if_flow',
         ['return(matches("ifXtrue", /if(true)/)); ', flow('false')])
    case('grouped_helper_pattern', 'if_flow',
         ['return(matches("x", /(if(true)).*x/)); ', flow('false')])
    case('bare_regex_operand', 'if_flow',
         ['return(/if(true)/); ', flow('false')])
    case('numeric_slash_call_code_interval', 'if_flow',
         ['/(14,2); ', flow('true'), '; 14/cos'])
    for name in ('q', 'm', 'qr'):
        case('indexed_' + name + '_code_interval', 'if_flow',
             [name + '[', flow('true'), ']'])
    # Comment classification is separately owned. Its quotes must not swallow
    # the following line, and this private unit does not remove comment events.
    case('comment_unclosed_quote_keeps_next_line', 'if_flow', ['# "\n', flow('true')])
    case('comment_membership_still_deferred', 'if_flow',
         ['# ', flow('true'), '\n', flow('false')])
    for original in json.loads((ROOT / REPRESENTATIVES).read_bytes())['cases']:
        rows.append({'id': 'original_' + original['contract'],
                     'contract': original['contract'], 'source': original['source'],
                     'events': original['events']})
    return rows


if __name__ == '__main__':
    Path(PREFIX + 'cases.json').write_text(json.dumps(author(), ensure_ascii=False, indent=2) + '\n')
