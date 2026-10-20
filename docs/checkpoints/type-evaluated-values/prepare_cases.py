"""Author independent value-order expectations without refreshing the initial impact epoch."""
import json
import common as c

cases = json.loads((c.ROOT / (c.PREFIX + 'impact-cases.json')).read_bytes())
expected = {
    'array-literal': ['before', 'inside', 'inside'],
    'array-constructor': ['before', 'inside', 'inside'],
    'codeblock-arguments': ['before', 'inside'],
    'hash-literal-values': dict(first='before', call='inside', last='inside'),
    'hash-constructor-values': dict(first='before', call='inside', last='inside'),
    'hash-dynamic-key': {'before': 7},
    'nested-array': [['before', 'inside'], 'inside'],
    'eager-block': ['before', 'inside', 'inside'],
    'assignment-value': ['before', 'inside', 'inside'],
    'number-kind': [42, 3.5, 3.5],
    'boolean-kind': [False, True, True],
    'null-kind': [None, 'inside', 'inside'],
    'numeric-string-kind': ['007', 7, 7],
    'array-rebinding': [['old'], ['new'], ['new']],
    'harray-rebinding': [{'key': 'old'}, {'key': 'new'}, {'key': 'new'}],
    'callable-rebinding': ['old', 'new'],
    'array-mutation-question': [['old', 'new'], 'changed', ['old', 'new']],
    'repeated-side-effects': ['', 'a', 'a', 'ab', 'ab'],
    'rvalue-control': ['before', 'inside', 'inside'],
    'saved-binding-control': ['before', 'inside', 'inside'],
    'named-function-control': ['before', 'inside'],
    'temporary-like-user-binding': ['before', 'inside', 'inside'],
    'nested-codeblock-body': ['before', 'inside', 'inside'],
}
before = {case['id']: dict(case) for case in cases}
for case in cases:
    if case['id'] == 'boolean-kind':
        case['body'] = 'slot = false; change = {|next| slot = next; return(slot) }; return([slot, change(true), slot])'
    elif case['id'] == 'repeated-side-effects':
        case['body'] = 'state = ""; step = {|piece| state = cat(state,piece); return(state) }; return([state, step("a"), state, step("b"), state])'
    elif case['id'] == 'callable-rebinding':
        case['body'] = case['body'].replace('first = saved[0]; last = saved[2]; return([first(),last()])',
            'early_callback = saved[0]; late_callback = saved[2]; return([early_callback(),late_callback()])')
    case['expected'] = expected[case['id']]
assert len(cases) == len(expected) == len({case['id'] for case in cases})
path = 'tests/evaluated-values/cases.json'
(c.ROOT / path).parent.mkdir(parents=True, exist_ok=True)
c.write_new(path, dict(cases=cases, scope='Evaluated-value regressions. The array-mutation row retains '
    'one observed baseline alias behavior, not a general deep-copy claim. Boolean argument input avoids '
    'the separately owned literal-kind defect; cat state avoids the separately owned numeric body gap.'))
c.write_new(c.PREFIX + 'case-authority.json', dict(producer=c.read(c.PREFIX + 'prepare_cases.py'),
    helper=c.read(c.PREFIX + 'common.py'), initial_cases=c.read(c.PREFIX + 'impact-cases.json'),
    fixture=c.read(path), exact_initial=before,
    changed_questions=['boolean-kind', 'repeated-side-effects', 'callable-rebinding'],
    scope='Three distinct follow-ups keep original observations immutable: typed boolean argument '
          'instead of interpreted literal, cat-based order/once instead of unsupported num_add, and '
          'unambiguous callback binding names. Expected values derive from current-value evaluation, '
          'ADR0031 argument order, dynamic hash keys and explicitly retained unaffected controls.'))
print('Independent final evaluated-value cases authored:', len(cases))
