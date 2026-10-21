"""Declare independent typed-value expectations before changing sort implementation."""
import common as c


def main():
    datasets = [
        ('integer', '[2,10,1]', [1, 10, 2]),
        ('decimal', '[2.5,10.25,-1.5,0]', [-1.5, 0, 10.25, 2.5]),
        ('string', '["2","10","1"]', ['1', '10', '2']),
        ('mixed', '[2,"10",1,"2",10]', [1, '10', 10, 2, '2']),
        ('null', '[2,undef,"0",0,""]', [None, '', '0', 0, 2]),
        ('boolean', '[true,false,1,0,"1","0"]', [False, 0, '0', True, 1, '1']),
        ('unicode', '["é","A","🦀","a"]', ['A', 'a', 'é', '🦀']),
        ('empty', '[]', []),
        ('singleton', '[7]', [7]),
    ]
    cases = []

    def add(case_id, body, expected):
        cases.append(dict(id=case_id, body=body, expected=expected))

    def returning(scope, setup, expression):
        if scope == 'ordinary':
            return setup + ' return(' + expression + ')'
        return setup + ' cb = {|| return(' + expression + ') }; return(cb())'

    def selected(scope, setup, expression):
        if scope == 'ordinary':
            return setup + ' out = ' + expression + ';'
        return setup + ' cb = {|| return(' + expression + ') }; out = cb();'

    for scope in ('ordinary', 'deferred'):
        for form in ('free', 'receiver'):
            expression = 'sorted(items)' if form == 'free' else 'items.sorted()'
            stem = scope + '/' + form + '/'
            for name, literal, expected in datasets:
                setup = 'items = ' + literal + ';'
                add(stem + 'direct/' + name, returning(scope, setup, expression), expected)
                if name in ('integer', 'decimal', 'mixed', 'null', 'boolean'):
                    add(stem + 'nested-array/' + name,
                        returning(scope, setup, '[' + expression + ']'), [expected])
                if name in ('integer', 'mixed'):
                    add(stem + 'nested-hash/' + name,
                        returning(scope, setup, '{"chosen":' + expression + '}'), {'chosen': expected})
                if name in ('integer', 'decimal', 'mixed', 'null', 'boolean', 'unicode'):
                    setup += ' keep = {|values| return(values) };'
                    add(stem + 'argument-copy/' + name,
                        returning(scope, setup, 'keep(' + expression + ')'), expected)
            setup = 'items = [2,10,1];'
            prefix = selected(scope, setup, expression)
            target = ' target = ["zero","one","two"]; target[index] = "changed";'
            add(stem + 'result-index', prefix + ' index = out[0];' + target + ' return([target,out,items])',
                [['zero', 'changed', 'two'], [1, 10, 2], [2, 10, 1]])
            add(stem + 'source-index', prefix + ' index = items[2];' + target + ' return([target,items])',
                [['zero', 'changed', 'two'], [2, 10, 1]])
            add(stem + 'source-copy', prefix +
                ' keep = {|values| return(values) }; return(keep(items))', [2, 10, 1])
            add(stem + 'result-independence', prefix + ' out[0] = 9; return([out,items])',
                [[9, 10, 2], [2, 10, 1]])
            string_prefix = selected(scope, 'items = ["2","10","1"];', expression)
            add(stem + 'string-key', string_prefix +
                ' index = out[0]; target = {"1":"old","2":"two"}; target[index] = "changed"; return(target)',
                {'1': 'changed', '2': 'two'})
            pipeline = 'take(sorted(items),2)' if form == 'free' else 'items.sorted().take(2)'
            add(stem + 'take-copy', selected(scope, setup, pipeline) +
                ' keep = {|values| return(values) }; return(keep(out))', [1, 10])
    prefix = 'Top: /x/\n I { push(Number); push(Number); push(Number); '
    suffix = ' }\nNumber: I { return(2) }\n'
    for name, body, expected in [
        ('argument-copy', 'keep = {|values| return(values) }; return(keep(sorted(Top)))', [2, 2, 2]),
        ('source-copy', 'out = sorted(Top); keep = {|values| return(values) }; return(keep(copy(Top)))', [2, 2, 2]),
        ('source-index', 'out = sorted(Top); values = copy(Top); index = values[0]; target = ["zero","one","two"]; target[index] = "changed"; return(target)', ['zero', 'one', 'changed']),
        ('literal-control', 'keep = {|values| return(values) }; return(keep(copy(Top)))', [2, 2, 2]),
    ]:
        cases.append(dict(id='implicit-accumulator/' + name, source=prefix + body + suffix, expected=expected))
    ids = [case['id'] for case in cases]
    assert len(ids) == len(set(ids))
    c.write_new('cases.json', dict(cases=cases,
        scope='Fixed Perl lexical-order and typed number/string/boolean/null values, container/argument copies, source/result numeric indexes, string keys, source/result independence, take continuations and implicit rule accumulators. Boolean literals are constructed outside deferred bodies; existing Boolean35 and reducer95 behavior is not reclassified.'))
    print('Fixed sort-kind plan declared:', len(cases), 'cases; expected values precede implementation')


if __name__ == '__main__':
    main()
