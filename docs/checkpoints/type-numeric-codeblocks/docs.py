"""Keep public numeric behavior and its canonical fact aligned with the candidate."""
import subprocess
import common as c

GUIDE = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
CATALOG = 'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'
PROGRAM = 'docs/linkedspec-book/src/architecture/structured-format-program.md'
FACT = 'docs/knowledge/terse-type-method-surface-inventory.md'


def main():
    before = {path: c.read(path) for path in (GUIDE, CATALOG, PROGRAM, FACT)}
    assert all(c.decode(item['base64']) == subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
               for path, item in before.items())
    text = c.decode(before[GUIDE]['base64']).decode()
    old = ('A direct `num_add` inside a deferred body currently raises the typed\n'
           '`unknown_helper` diagnostic even though ordinary numeric helper calls work.\n')
    assert text.count(old) == 1
    text = text.replace(old, 'Deferred numeric aggregate reducers, including array-form min/max and array\n'
        'reducer methods, still raise the typed `unknown_helper` diagnostic in Perl.\n', 1)
    heading = '### Callable values in with\n'
    section = '''### Scalar numeric helpers in codeblocks

Perl callable bodies support the scalar numeric helpers, their word and symbol
call aliases, and numeric receiver methods. Their argument and result rules are
the same as [numeric value helpers](value-container-flow-helper-reference.md#numeric-value-helpers):
comparisons return numeric `1`/`0`; invalid numeric input or arity returns `undef`.

Caller bindings are read at each invocation. This counter returns `[1,2,2]`:

```text
counter = 0;
cb = {||
  counter = num_add(counter,1);
  return(counter)
};
first = cb();
second = cb();
return([first,second,counter])
```

Number-returning receiver links compose inside a callback. This returns `18`:

```text
score = -3.2;
cb = {|| return(score.abs().ceil().add(2).mul(3)) };
out = cb();
return(out)
```

Each numeric operand retains its evaluated value before a later operand can
rebind its source slot. This returns `[5,9]`:

```text
value = 2;
change = {|| value = 9; return(3) };
out = num_add(value,change());
return([out,value])
```

The same rule covers scalar `num_mul`, `num_min` and `num_max`; explicit flat
splices keep their existing list behavior. It does not add recursive copying.
An invalid numeric call shape or comparison-terminal continuation yields `undef`
before the receiver or operands run. Comparison methods end their chain even
when the following method belongs to another family. Save a comparison result
in a binding to use it as the receiver of a separate expression.

Typed boolean parameters remain nonnumeric. Boolean literals evaluated inside
a Perl callback have the separate [kind limitation](#current-perl-limits) above.
Numeric array reducers remain outside this deferred scalar family. Unsupported
calls keep their typed `unknown_helper` cause; they are not quiet null results.

'''
    assert text.count(heading) == 1
    text = text.replace(heading, section + heading, 1)
    proposed = {GUIDE: text.encode()}

    text = c.decode(before[CATALOG]['base64']).decode()
    old = 'Numeric helpers keep arithmetic and reducers explicit. They return `undef` when required numeric operands are missing or not numeric-looking.'
    new = '''Under the scalar numeric contract, inputs are finite numbers or untrimmed decimal strings such as
`".5"`, `"-.5"` and `"007"`. Typed booleans, null, arrays, harrays and codeblocks
are invalid scalar numeric operands. Invalid input, arity, nonfinite results,
zero divisors, fractional modulo operands and inverted clamp bounds return `undef`.
Unary helpers take one operand; subtraction/division/modulo and comparisons take
two; clamp takes three; addition/multiplication/scalar min/max take at least two.
Comparisons return numeric `1`/`0`. Rounding uses halves away from zero; integer
modulo is `a - floor(a/b)*b`, with a nonzero result having the divisor's sign.
Array-form min/max and array reducers have their separate signatures below.'''
    assert text.count(old) == 1
    text = text.replace(old, new, 1)
    for name in ('abs', 'floor', 'ceil', 'round'):
        text = text.replace('| `num_' + name + '(value)` | scalar number |',
                            '| `num_' + name + '(value)` | scalar number or `undef` |', 1)
    text = text.replace('Two separately tracked boundaries remain:\n\n'
        '- A callable body such as `{|| return(div(14, 2)) }` or\n'
        '  `{|| return(/(14, 2)) }` fails with `unknown_helper` at runtime. Numeric callable\n'
        '  dispatch is tracked for repair under `SESSION-STARTUP-READING.87.3`.\n',
        'Perl callable bodies also execute the scalar names, word/symbol aliases and\n'
        'numeric receiver links described here. See the\n'
        '[callable examples](values-containers-and-flow-helpers.md#scalar-numeric-helpers-in-codeblocks)\n'
        'for caller effects, operand snapshots, terminal chains and the remaining\n'
        'boolean-literal and deferred aggregate limits. The separate grouping boundary remains:\n\n', 1)
    assert 'callables remain owned by startup87.3' not in text
    assert 'dispatch is tracked for repair under `SESSION-STARTUP-READING.87.3`' not in text
    text = text.replace('Comparison links (`eq`,\n`ne`, `gt`, `ge`, `lt`, `le`) return booleans and end the chain.',
                        'Comparison links (`eq`,\n`ne`, `gt`, `ge`, `lt`, `le`) return numeric `1`/`0` and end the chain.', 1)
    proposed[CATALOG] = text.encode()

    text = c.decode(before[PROGRAM]['base64']).decode()
    old = ('This repair covers typed attached while in the private Perl executor. Numeric helpers inside\n'
           'callables remain owned by startup87.3; the examples use supported matching/string helpers.\n')
    assert text.count(old) == 1
    text = text.replace(old, 'This repair covers typed attached while in the private Perl executor. Perl scalar\n'
        'numeric calls and receiver chains also execute in callable bodies; see the\n'
        '[numeric callable examples](../dsl/values-containers-and-flow-helpers.md#scalar-numeric-helpers-in-codeblocks).\n', 1)
    proposed[PROGRAM] = text.encode()

    original_fact = c.decode(before[FACT]['base64']).decode()
    header = original_fact[:original_fact.index('date:')]
    header += '  - "why can a later numeric operand change an earlier value"\n'
    header += '  - "can Perl numeric comparison receivers continue into cat"\n'
    fact = header + '''date: 2026-10-20
status: current bounded Perl value/numeric repairs; full operation inventory pending
tags: [spec-format-terse, method-chaining, receiver-dot, audit, mdbook, rust-parity]
evidence: "TYPE-REFERENCE-BOOK.1.2.3-.5 retain accepted-source public routes, saved-slot controls and exact producer/input records. Numeric5 owns dispatch, operand snapshots and receiver validation; its checkpoint discloses preparation epochs, original test-context qualification and separate repair owners."
reverify: "bash tools/project_data_run.sh prove -q -Iperl t/scalar_numeric_contract.t"
---

# Current value model and bounded Perl numeric execution

Bindings hold scalar, array, harray or codeblock. Integer/real notation does not
create namespaces. String, number, boolean and null remain distinct values;
numeric comparisons yield numeric1/0 and logical helpers yield booleans. False
normalizes to text "0" and can pass through generic with as false. The July4
terminal-boolean statement is dated.

Deferred codeblocks use current caller slots; eager blocks run immediately.
An array yielded by a callable can feed sorted(), without creating a distinct
codeblock method table. Scoped callable with is repaired by .1.2.4;
[[perl-generic-final-codeblock-normalization]] owns its vocabulary/frame mechanism.

Covered Perl constructors, dynamic hash keys, callable arguments and the four
variadic scalar numeric producers materialize operands before later siblings
run. MethodLowering::_materialize_list_operand_expr preserves explicit flat
splices and scalar kinds. This does not add arbitrary deep copying. The earlier
push question wrongly conflated late reads with reference mutation; saved-slot
controls and [[perl-uniform-binding-runtime]] establish copy-on-write binding
updates. Original rejected oracles/candidates and their limits remain retained.

CodeblockRuntime delegates the admitted scalar numeric names and word/symbol
aliases to Numeric::scalar_helper_name/arity_is_valid/evaluate. Typed arguments
retain their kinds; invalid arity skips operand evaluation. Numeric receiver
shapes and comparison terminals validate before receiver evaluation, including
mixed chains. A separately saved comparison result may start another expression.
MethodLowering rejects the same numeric shapes as complete undef expressions,
preventing literal Perl fallthrough. Ordinary numeric lists snapshot each term.

Deferred aggregate reducers and array min/max remain unknown_helper, owned by
TYPE-REFERENCE-BOOK.1.2.7 after generated-drop .1.2.6. Boolean body literals still
lose their kind under [[perl-codeblock-boolean-literal-kind-drift]] / startup35;
typed callback parameters preserve it. Unicode numeric coercion remains startup20.
No all-helper or cross-backend admission follows from this scalar repair.

Single-key drop_keys is quiet through descriptor/Get but generated loading warns
for delete @__ls_drop{"debug"}; a fatal syntax-warning caller rejects it. .1.2.6
owns that producer. Numeric5 qualifies the prior scoped-with retained test-log
context and adds a distinct complete-input accepted-source replay. No original
observation is silently refreshed and no warning discipline is weakened.

The complete old card is recoverable at accepted203cde315 and in the numeric
doc proposal. Earlier detailed value/Phase0 adjudications stay under
docs/checkpoints/type-evaluated-values/. The July4 method table, including later
retired spellings, survives at c053c9dcf and its proposal capsule. It already
listed substr and scalar/array/hash/number receiver families; use it as dated
navigation. Full current enumeration remains .1.2.1 after scalar5/drop6/aggregate7,
before book mapping/layout. Complete per-type reference coverage is not admitted.
'''
    assert len(fact.encode()) < len(c.decode(before[FACT]['base64']))
    proposed[FACT] = fact.encode()
    c.write_new('docs-proposals.json.gz', dict(before=before,
        after={path: c.encode(raw) for path, raw in proposed.items()},
        producer=c.read(c.PREFIX + 'docs.py'),
        scope='Full before/after public book and canonical fact. Existing anchors/examples stay; '
              'new numeric examples match separately retained contract cases. Old fact bytes remain whole.'))
    for path, raw in proposed.items():
        (c.ROOT / path).write_bytes(raw)
    print('Current numeric book/fact proposals applied; fact source bytes saved:', len(c.decode(before[FACT]['base64'])) - len(fact.encode()))


if __name__ == '__main__':
    main()
