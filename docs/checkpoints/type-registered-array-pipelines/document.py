"""Install the exact permanent plan and bounded user-facing contract examples."""
import json
import common as c

CHAPTER='docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
REFERENCE='docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'
FACT='docs/knowledge/terse-type-method-surface-inventory.md'
HEADING='### Registered array pipelines and length'
SPEC='fn select_items(items) { return(items.sorted().take(2)) }\nTop: /x/\n I { items = [2,10,1]; cb = {|| return(select_items(items)) }; return([select_items(items),cb(),items.sorted().take(2).length(),items]) }\n'
BODY='seen = ""; source = {|| seen = cat(seen,"s"); return([2,10,1]) }; cb = {|| return(source().sorted().take(2).length().abs()) }; return([cb(),seen]);\n'

def main():
    paths=[CHAPTER,REFERENCE,FACT,'t/scalar_numeric_contract.t']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(value['base64']).decode() for path,value in before.items()}
    old='Deferred `count` and `first` also execute; see [their selection contract](#counting-and-selecting-first-inside-perl-codeblocks). Deferred `.last()` remains unsupported. Registered `fn` receiver pipelines containing `sorted` also remain limited; use the callable forms below.'
    new='Deferred `count` and `first` also execute; see [their selection contract](#counting-and-selecting-first-inside-perl-codeblocks). Registered array pipelines and terminal `length` also work; see [the examples below](#registered-array-pipelines-and-length). Deferred `.last()` remains unsupported.'
    assert after[CHAPTER].count(old)==1
    after[CHAPTER]=after[CHAPTER].replace(old,new,1)
    section=HEADING+'\n\nOn Perl, registered functions can sort and take array parameters, local bindings and rest arguments. Selection returns a copy; empty or non-array inputs yield `[]`. This complete parser returns `[[1,10],[1,10],2,[2,10,1]]` for input `x`:\n\n```text\n'+SPEC+'```\n\n`length(value)` / `value.length()` measures a string or array. The receiver takes no arguments and ends its chain. Invalid arity or a continuation returns `undef` before receiver or argument effects, including inside deferred bodies. A free-call result can start a new chain: `length([2,10,1]).abs()` returns `3`. This action body returns `[null,""]`:\n\n```text\n'+BODY+'```\n\n'
    marker='### Counting and selecting first inside Perl codeblocks\n'
    assert after[CHAPTER].count(marker)==1
    after[CHAPTER]=after[CHAPTER].replace(marker,section+marker,1)
    old='| `length(value)` | scalar number or `undef` | measure scalar string length. |'
    new='| `length(value)` | scalar number or `undef` | measure string or array length; [Perl pipeline examples](values-containers-and-flow-helpers.md#registered-array-pipelines-and-length). |'
    assert after[REFERENCE].count(old)==1
    after[REFERENCE]=after[REFERENCE].replace(old,new,1)
    after['t/scalar_numeric_contract.t']=after['t/scalar_numeric_contract.t'].replace('pipelines sort-kinds count-first)', 'pipelines sort-kinds count-first registered-pipelines)',1)
    assert after['t/scalar_numeric_contract.t']!=c.decode(before['t/scalar_numeric_contract.t']['base64']).decode()
    fact=after[FACT]
    fact=fact.replace('  - "why do private count captures expect old defined guards"','  - "why do private count captures expect old defined guards"\n  - "why did registered sorted pipelines lose function parameters"',1)
    fact=fact.replace('tags: [spec-format-terse, method-chaining, receiver-dot, audit, mdbook, rust-parity]','tags: [spec-format-terse, method-chaining, mdbook]',1)
    fact=fact.replace('evidence: "Type epochs retained; count/first10 verified."','evidence: "Type checkpoints; pipelines11."',1)
    fact=fact.replace('Scalar/array/harray/codeblock bindings retain evaluated constructor/key/argument\nvalues; deferred bodies read caller slots; updates use copy-on-write.\nSee [[perl-generic-final-codeblock-normalization]].','Bindings retain evaluated constructor keys/values and arguments. Deferred reads\nuse caller slots; updates copy on write. [[perl-generic-final-codeblock-normalization]].',1)
    fact=fact.replace('Scalar/aggregate Numeric policies differ. Shape checks precede effects;\ncomparisons/reducers terminate. Aggregates take one array; receivers no operands.\nScalar min/max evaluates operands before rejection. Perl checks each decimal\nterm: empty sum0, othersundef; Rust filters differently. Reducer95:', 'Scalar/aggregate Numeric policies differ. Shapes precede effects; comparisons/\nreducers terminate. Aggregates take one array, receivers none. Scalar min/max\nevaluates before rejection. Perl checks each decimal: empty sum0, othersundef;\nRust filters differently. Reducer95:',1)
    fact=fact.replace('Deferred sorted/take have free/receiver forms. Lexical sort preserves copied\nnumeric/string kinds across clones/indexes; measure flags before Storable caches\nprivate iOK on floats.', 'Deferred sorted/take have free/receiver forms. Lexical sort retains numeric/string\nkinds through clones/indexes; measure flags before Storable caches float iOK.',1)
    fact=fact.replace('11 owns registered sorted/ordinary length,12 indexed writes,14 last.', 'Registered array chains keep DSL names through the existing composition bridge.\nlength is a no-arg terminal; bad shapes/continuations skip effects in both routes.\n12 owns indexed writes;14 last.',1)
    assert len(fact.encode())<=len(c.decode(before[FACT]['base64'])),(len(fact.encode()),len(c.decode(before[FACT]['base64'])))
    after[FACT]=fact
    c.write_new('document-before.json.gz',dict(before=before,after=after,producer=c.read(c.PREFIX+'document.py'),
        fact_delta=len(fact.encode())-len(c.decode(before[FACT]['base64']))))
    for path,text in after.items():
        c.source(path).write_text(text)
    fixture='tests/numeric-codeblocks/registered-pipelines.json'
    with (c.ROOT/fixture).open('x') as stream:
        json.dump(c.load('cases.json'),stream,sort_keys=True,separators=(',',':'))
        stream.write('\n')
    c.write_new('book-cases.json',dict(cases=[dict(id='book/registered',source=SPEC,expected=[[1,10],[1,10],2,[2,10,1]]),dict(id='book/terminal',body=BODY,expected=[None,''])]))
    c.write_new('documentation.json.gz',dict(after={p:c.read(p) for p in paths},fixture=c.read(fixture),
        book_line_delta=sum(after[p].count('\n')-c.decode(before[p]['base64']).count(b'\n') for p in (CHAPTER,REFERENCE))))
    print('Permanent plan and book examples installed; fact bytes contained')

if __name__=='__main__':main()
