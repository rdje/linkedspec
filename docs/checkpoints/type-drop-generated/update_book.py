"""Retain whole documentation before-images and publish worked drop examples."""
import json
import common as c

CHAPTER='docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
REFERENCE='docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'
FACT='docs/knowledge/terse-type-method-surface-inventory.md'
HEADING='### Removing keys in Perl'


def main():
    before={path:c.read(path) for path in (CHAPTER,REFERENCE,FACT)}
    chapter=c.decode(before[CHAPTER]['base64']).decode()
    old='''Loading generated Perl for `drop_keys(meta, "debug")` with one literal key
currently emits a scalar hash-slice compiler advisory, while returning the
correct harray. A caller that treats syntax warnings as fatal cannot load
that generated parser. This known compiler-diagnostic repair is pending.

'''
    assert chapter.count(old)==1
    chapter=chapter.replace(old,'',1)
    base={'kind':'node','debug':1,'stage':'parse'}
    kept={'kind':'node','stage':'parse'}
    cases=[dict(id='book/copy',expected=[base,kept],body='''meta = {"kind":"node","debug":1,"stage":"parse"};
cleaned = meta.drop_keys("debug");
return([meta,cleaned]);
'''),dict(id='book/splice',expected={'kind':'node'},body='''meta = {"kind":"node","debug":1,"stage":"parse"};
keys = ["debug","stage"];
return(drop_keys(meta,flat_array(keys)));
'''),dict(id='book/key-order',expected=[kept,'stage'],body='''meta = {"kind":"node","debug":1,"stage":"parse"};
drop_key = "debug";
other = {|| drop_key = "stage"; return("debug") };
cleaned = drop_keys(meta,drop_key,other());
return([cleaned,drop_key]);
''')]
    text=HEADING+'''

`drop_keys` returns a new harray. The source keeps its fields; missing keys and
repeated keys are harmless. Free-call and receiver forms accept the same keys.
One key loads quietly in generated Perl, including when the caller treats syntax
warnings as fatal.

This returns the original three-field harray followed by a copy containing only
`kind` and `stage`:

```text
'''+cases[0]['body']+'''```

Pass an explicit splice to expand an array of keys. This returns `{"kind":"node"}`:

```text
'''+cases[1]['body']+'''```

`flat_array([])` removes no keys; a one-element splice removes one. An ordinary
array argument stays one value. Each key operand is evaluated once, and its value
is captured before the next operand runs. Here both evaluated keys are `"debug"`,
even though the callback changes the binding to `"stage"`. The result is
`[{"kind":"node","stage":"parse"},"stage"]`:

```text
'''+cases[2]['body']+'''```

'''
    anchor='## Flow helpers\n'
    assert chapter.count(anchor)==1 and HEADING not in chapter
    chapter=chapter.replace(anchor,text+anchor,1)
    reference=c.decode(before[REFERENCE]['base64']).decode()
    anchor='## Hash helpers\n\nHash helpers return scalar information about an object or a new hash/array value derived from it.\n'
    addition='''
On Perl, `drop_keys(meta, "debug")` and `meta.drop_keys("debug")` leave `meta`
unchanged and return a copy. Use `flat_array(keys)` to expand an array of keys;
an empty splice removes none. Each key value is captured before the next key
operand runs. Scalar-key generated parsers also load with fatal syntax warnings.
See [Removing keys in Perl](values-containers-and-flow-helpers.md#removing-keys-in-perl)
for complete copy, splice and callback-order examples.
'''
    assert reference.count(anchor)==1
    reference=reference.replace(anchor,anchor+addition,1)
    fact=c.decode(before[FACT]['base64']).decode()
    fact=fact.replace('  - "does Perl drop_keys warn for a single literal key"\n',
        '  - "does Perl drop_keys warn for a single literal key"\n'
        '  - "why does Perl drop_keys ignore flat_array keys"\n'
        '  - "why can a later drop key callback change an earlier key"\n',1)
    fact=fact.replace('status: current bounded Perl value/numeric repairs; full operation inventory pending',
                      'status: bounded Perl value/numeric/drop repairs; full inventory pending',1)
    start=fact.index('evidence: ')
    end=fact.index('\n---',start)
    fact=fact[:start]+'''evidence: "TYPE-REFERENCE-BOOK.1.2.3-.6 retain accepted public epochs and producer/input custody. Drop6 owns list evaluation, warning/FATAL loading and exact historical recurrence; numeric5 owns scalar dispatch/snapshots."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/type-drop-generated/publish.py"'''+fact[end:]
    start=fact.index('Single-key drop_keys is quiet')
    fact=fact[:start]+'''Perl drop_keys materializes each key operand, lowers explicit flat splices and
typed shapes, then deletes a private key list from a copied harray. Scalar keys
load without the old slice advisory under normal/FATAL syntax profiles; a later
callback cannot change an earlier key. Source-kind execution errors and null-key
uninitialized diagnostics remain. No portable reference-key coercion is admitted.
The accepted failure, rejected shape/review preparations and actual fault controls
survive in docs/checkpoints/type-drop-generated/.

Numeric5 separately qualifies prior4's original retained-log context and adds a
complete-input accepted-source replay; observations are never refreshed silently.
Earlier value/Phase0 adjudications remain under type-evaluated-values/. Full old
card bytes survive at accepted203cde315; the July4 inventory at c053c9dcf and its
proposal capsule already listed substr and scalar/array/hash/number receivers.
Those dated, partly retired spellings guide navigation; current enumeration .1.2.1
follows aggregate7, before book mapping/layout. No complete per-type admission.
'''
    # Keep this bounded fact smaller while preserving its dated repair boundaries.
    fact=fact.replace('CodeblockRuntime delegates the admitted scalar numeric names and word/symbol\naliases to Numeric::scalar_helper_name/arity_is_valid/evaluate. Typed arguments\nretain their kinds; known invalid arity skips operand evaluation. Numeric receiver\nshapes and comparison terminals validate before receiver evaluation, including\nmixed chains. A separately saved comparison result may start another expression.\nMethodLowering rejects the same numeric shapes as complete undef expressions,\npreventing literal Perl fallthrough. Ordinary numeric lists snapshot each term.',
        'CodeblockRuntime uses Numeric::scalar_helper_name/arity_is_valid/evaluate for\nscalar names/aliases, preserving kinds and skipping invalid-arity effects. Numeric\nreceiver shapes/terminals validate before effects, including mixed chains. A saved\ncomparison may start a new expression. MethodLowering emits complete undef for\ninvalid shapes instead of Perl fallthrough; numeric lists snapshot each term.')
    after={CHAPTER:chapter.encode(),REFERENCE:reference.encode(),FACT:fact.encode()}
    c.write_new('doc-proposal.json.gz',dict(before=before,after={path:c.encode(raw) for path,raw in after.items()},
        examples=cases,producer=c.read(c.PREFIX+'update_book.py'),
        scope='Perl-scoped copy/splice/key-order examples; current diagnostic repair replaces the old pending warning. '
              'Bounded canonical fact retains scalar and still-open aggregate/boolean/Unicode/inventory limits.'))
    for path,raw in after.items():(c.ROOT/path).write_bytes(raw)
    with (c.ROOT/'tests/drop-generated/book-cases.json').open('x') as out:
        json.dump(dict(cases=cases),out,sort_keys=True,separators=(',',':'));out.write('\n')
    print('Book examples3 and bounded fact updated; fact bytes',len(before[FACT]['base64'])*3//4,'->',len(after[FACT]))


if __name__=='__main__':main()
