"""Publish bounded callable sorted/take examples and preserve exact before images."""
import json
import common as c

CHAPTER='docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'

def main():
    reference='docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'
    paths=[CHAPTER,reference]
    before={p:c.read(p) for p in paths}
    text=c.decode(before[CHAPTER]['base64']).decode()
    old='''The six numeric aggregate reducers execute inside Perl codeblocks. General array pipelines remain separate: `items.sorted().take(2).sum()` inside a deferred body
currently raises `unknown_helper` at `sorted`. Prepare the array outside the body and pass it in until that owned pipeline repair is complete.
'''
    new='''The six numeric aggregate reducers and `sorted`/`take` execute inside Perl codeblocks. See the worked [selection examples](#sorting-and-taking-inside-perl-codeblocks).
Other array helpers have separate availability limits: deferred `.count()` and `.first()` are not yet supported. Registered `fn` bodies containing `sorted` also remain limited; use the callable forms below.
'''
    assert text.count(old)==1;text=text.replace(old,new,1)
    bodies=[
        ('items = [3,1,8];\ncb = {|| return(items.sorted().take(2).sum()) };\nreturn([cb(),items]);',[4,[3,1,8]]),
        ('cb = {|values| return(values.sorted().take()) };\nreturn(cb(["b","a","c"]));',['a']),
        ('items = ["a","b","c"];\ncb = {|values| return(take(values,2)) };\nchosen = cb(items); chosen[0] = "changed";\nreturn([chosen,items]);',[['changed','b'],['a','b','c']]),
    ]
    section='''### Sorting and taking inside Perl codeblocks

`sorted(values)` returns a lexical sorted copy; `values.sorted()` is the receiver form.
For numbers `[2,10,1]`, lexical order is `[1,10,2]`. This is not numeric sorting.
`take(values,count)` and `values.take(count)` return a new array containing the first
`count` elements. Omitting the count selects one element. Neither operation reorders
or replaces the source binding.

Here are complete action bodies for `Top: /x/` with `I { ... }`. The first returns
`[4,[3,1,8]]`: the reducer consumes the first two sorted values and the input stays intact.

```text
'''+bodies[0][0]+'''
```

The default count selects `"a"` and returns `["a"]`:

```text
'''+bodies[1][0]+'''
```

Changing the selected array leaves the argument intact. This returns
`[["changed","b"],["a","b","c"]]`:

```text
'''+bodies[2][0]+'''
```

On Perl, an empty or non-array source produces `[]`. A supplied `take` count must
match the existing integer spelling rule: decimal integers and integer strings
such as `"2"` work; negative, fractional, null and nonnumeric counts select nothing.
A count larger than the input returns all its elements. For a non-array source,
the count expression is skipped. Otherwise source and count run once, in that order.
These are Perl rules; they do not establish cross-backend count normalization.

`sorted` requires one free-call argument and zero receiver arguments. `take`
requires one or two free-call arguments and at most one receiver argument. Invalid
shapes return `undef` before operands run. Array reducers terminate a receiver
chain: `items.sorted().take(2).sum()` works; adding `.abs()` returns `undef` before
the receiver or count runs. A separately returned scalar can begin another chain.
Numeric-looking selected terms retain existing scalar-kind caveats; use numeric
arithmetic before using a selected term as a numeric write index.

'''
    marker='## Per-rule default accumulator\n';assert text.count(marker)==1
    text=text.replace(marker,section+marker,1)
    after={CHAPTER:text}
    text=c.decode(before[reference]['base64']).decode()
    marker='## Hash helpers\n';assert text.count(marker)==1
    text=text.replace(marker,'Perl callable bodies also support `sorted` and `take`, including their receiver forms and reducer continuations. See the [worked sorting and selection examples](values-containers-and-flow-helpers.md#sorting-and-taking-inside-perl-codeblocks) for count rules, copies, evaluation order and remaining callable limits.\n\n'+marker,1)
    after[reference]=text
    c.write_new('book-cases.json',dict(cases=[dict(id='book/'+str(index+1),body=body,expected=value) for index,(body,value) in enumerate(bodies)]))
    c.write_new('docs-change.json.gz',dict(before=before,after={p:c.encode(t.encode()) for p,t in after.items()},producer=c.read(c.PREFIX+'docs.py')))
    for p,t in after.items():(c.ROOT/p).write_text(t)

if __name__=='__main__':main()
