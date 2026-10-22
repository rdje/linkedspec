"""Document the verified Perl selection contract with five executable action bodies."""
import common as c
import context

CHAPTER = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
REFERENCE = 'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'


def main():
    assert not c.load('candidate1-run.json.gz')['failures']
    cases = [
        dict(id='selection-pipeline', body='''items = [2,10,1];
cb = {|| return([items.sorted().take(2).count(),items.sorted().take(2).first()]) };
return([cb(),items]);''', expected=[[2,1],[2,10,1]]),
        dict(id='selection-copy', body='''items = [[2,1],[]];
cb = {|values| return(values.first()) }; chosen = cb(items);
chosen[0] = 9; return([chosen,items]);''', expected=[[9,1],[[2,1],[]]]),
        dict(id='selection-terminal', body='''items = [2,10,1];
cb = {|| return([items.count().abs(),count(items).abs(),items.first().cat("!"),first(items).cat("!")]) };
return(cb());''', expected=[None,3,None,'2!']),
        dict(id='selection-effects', body='''seen = ""; items = [2,10,1];
tap = {|value| seen = cat(seen,"r"); return(value) };
cb = {|| return(tap(items).count().abs()) };
return([cb(),seen]);''', expected=[None,'']),
        dict(id='selection-callable', body='''maker = {|| return("picked") }; items = [maker];
cb = {|| return(first(items)) }; chosen = cb(); return(chosen());''', expected='picked'),
    ]
    before = {path:c.read(path) for path in (CHAPTER,REFERENCE)}
    c.write_new('book-change-inputs.json.gz', context.snapshot())
    text = c.decode(before[CHAPTER]['base64']).decode()
    old = 'Other array helpers have separate availability limits: deferred `.count()`, `.first()`, and `.last()` are not yet supported.'
    assert text.count(old) == 1
    text = text.replace(old,'Deferred `count` and `first` also execute; see [their selection contract](#counting-and-selecting-first-inside-perl-codeblocks). Deferred `.last()` remains unsupported.',1)
    section = '''### Counting and selecting first inside Perl codeblocks

`count(values)` / `values.count()` returns the array length. `first(values)` / `values.first()` returns the stored first element. Empty or non-array values yield `0` for count and `undef` for first, including harray inputs. Free calls take exactly one argument; receiver calls take none. Invalid arity returns `undef` before evaluating any receiver or arguments.

Both helpers work in deferred bodies. This returns `[[2,1],[2,10,1]]`, preserving the source:

```text
'''+cases[0]['body']+'''
```

First preserves numbers, strings (including `"0"` and `""`), false, null, arrays, harrays and callable records. Existing invocation copying keeps the caller's array intact; this returns `[[9,1],[[2,1],[]]]`:

```text
'''+cases[1]['body']+'''
```

Receiver count/first terminate a fluent chain. A continuation returns `undef`. A free-call result can start a new chain, or save a receiver result and operate on that binding separately. This returns `[null,3,null,"2!"]`:

```text
'''+cases[2]['body']+'''
```

Invalid receiver continuations skip receiver and operand effects. This returns `[null,""]`; a valid `tap(items).count()` would evaluate tap once:

```text
'''+cases[3]['body']+'''
```

Selecting a codeblock preserves its callable behavior. This returns `"picked"`:

```text
'''+cases[4]['body']+'''
```

Regenerate saved Perl parser source after upgrading. Registered-function and other backend availability follow their separately documented limits.

'''
    marker = '### Sorting and taking inside Perl codeblocks\n'
    assert text.count(marker) == 1
    text = text.replace(marker,section+marker,1)
    c.source(CHAPTER).write_text(text)
    ref = c.decode(before[REFERENCE]['base64']).decode()
    marker = 'Sorting also preserves numeric and string scalar kinds through codeblock copies; see the [typed copy examples](values-containers-and-flow-helpers.md#scalar-kinds-after-sorting).'
    assert ref.count(marker) == 1
    c.source(REFERENCE).write_text(ref.replace(marker,marker+'\nFor Perl callable `count`/`first`, see the [worked selection, terminal and effect examples](values-containers-and-flow-helpers.md#counting-and-selecting-first-inside-perl-codeblocks).',1))
    for path,packet in before.items():
        c.source(path).chmod(packet['mode'])
    c.write_new('book-cases.json',dict(cases=cases))
    proof = c.source('docs/checkpoints/type-sort-copy-kinds/doc_proof.py').read_text()
    proof = proof.replace('### Sorting and taking inside Perl codeblocks','### Counting and selecting first inside Perl codeblocks')
    proof = proof.replace('#### Scalar kinds after sorting','### Counting and selecting first inside Perl codeblocks')
    proof = proof.replace('sorting-and-taking-inside-perl-codeblocks','counting-and-selecting-first-inside-perl-codeblocks')
    proof = proof.replace('scalar-kinds-after-sorting','counting-and-selecting-first-inside-perl-codeblocks')
    proof = proof.replace("assert 'id=\"counting-and-selecting-first-inside-perl-codeblocks\"' in page\n",
        "assert 'id=\"counting-and-selecting-first-inside-perl-codeblocks\"' in page, 'Missing count/first heading anchor'\n")
    proof = proof.replace('Missing scalar-kind heading anchor','Missing count/first heading anchor')
    with (c.ROOT/c.PREFIX/'doc_proof.py').open('x') as output:
        output.write(proof)
    c.write_new('book-change.json.gz',dict(before=before,after={path:c.read(path) for path in before},
        producer=c.read(c.PREFIX+'update_book.py'), proof=c.read(c.PREFIX+'doc_proof.py'),
        scope='Five literal executable examples and complete book/anchor controls follow the verified232-case runtime. Last14, registered pipeline11 and indexed-write12 stay separately owned.'))
    print('Book updated: five executable bodies and precise selection limits')


if __name__ == '__main__':
    main()
