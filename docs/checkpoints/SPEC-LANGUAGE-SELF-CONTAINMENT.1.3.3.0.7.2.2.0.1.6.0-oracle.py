"""Author representative source intervals from retained literal family oracles."""
from pathlib import Path
import copy
import json

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('oracle.py')
BASE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.'
PACKAGES = [
    'LinkedSpec::ActionIR::StagedParseJob',
    'LinkedSpec::ActionIR::ProgressiveSpanDispatch',
    'LinkedSpec::ActionIR::Scanner::RecognitionTransactionRules',
    'LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules',
    'LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules',
    'LinkedSpec::ActionIR::Scanner::FlowRules',
    'LinkedSpec::ActionIR::Scanner::LegacyRules',
]


def load(suffix):
    return json.loads((ROOT / (BASE + suffix + '-cases.json')).read_bytes())


def author():
    dedicated = load('5.0')
    basic = load('1.2.0')
    pipeline = load('2.0')
    flow = load('3.0')
    legacy = load('4.6')
    selected = []
    for contract in ('staged_parse_job', 'progressive_span_dispatch', 'recognition_checkpoint'):
        case = next(c for c in dedicated['cases'] if c['id'] == contract)
        row = next(r for r in case['rows'] if r['contract'] == contract)
        selected.append((contract, row['expected_events'][0], '5.0', contract))
    for corpus, suffix, contract in ((basic, '1.2.0', 'my_declare_bare'),
                                     (pipeline, '2.0', 'scalar_assignment_operator')):
        row = next(c for c in corpus['contracts'] if c['id'] == contract)
        selected.append((contract, row['events'][0], suffix, contract))
    case = next(c for c in flow if c['id'] == 'if_flow')
    selected.append(('if_flow', case['expected']['if_flow'][0], '3.0', 'if_flow'))
    case = next(c for c in legacy if c['id'] == 'return_general')
    selected.append(('return_general', case['expected_events'][0], '4.6', 'return_general'))
    rows = []
    for package, (contract, original, suffix, case_id) in zip(PACKAGES, selected, strict=True):
        raw = original['raw']
        pieces = ['note("雪😀");\r\n', raw, '; \u2003', raw, ';\r\n']
        source = ''
        events = []
        for index, piece in enumerate(pieces):
            start = len(source)
            source += piece
            if index in (1, 3):
                events.append({'raw': raw, 'args': copy.deepcopy(original['args']),
                               'source_span': {'start': start, 'end': len(source)}})
        rows.append({'package': package, 'contract': contract, 'source': source,
                     'events': events, 'original': {'path': BASE + suffix + '-cases.json',
                                                   'case': case_id, 'event': 0}})
    return {'packages': PACKAGES, 'cases': rows,
            'scope': 'Seven original representative contracts, repeated literal statements with authored scalar intervals; all ordered nested pairs. Syntactic provenance, not executable membership or arbitrary callback admission.'}


if __name__ == '__main__':
    target = Path(PREFIX + 'cases.json')
    target.write_text(json.dumps(author(), indent=2, ensure_ascii=False) + '\n')
    print('Authored seven literal representatives from unchanged prior case oracles')
