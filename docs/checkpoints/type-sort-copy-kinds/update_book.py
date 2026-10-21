"""Replace the reproduced kind caveat with executable number/string copy examples."""
import json
import common as c
import context

CHAPTER = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
REFERENCE = 'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'


def main():
    candidate = c.load('candidate1-run.json.gz')
    assert candidate['inputs_unchanged'] and not candidate['failures']
    new_cases = [
        dict(id='kind-number-copy', body='''items = [2,10,1];
keep = {|values| return([values]) };
saved = keep(items.sorted());
index = saved[0][0];
target = ["zero","one","two"];
target[index] = "changed";
return([saved,target,items]);''', expected=[[[1, 10, 2]], ['zero', 'changed', 'two'], [2, 10, 1]]),
        dict(id='kind-string-copy', body='''items = ["2","10","1"];
keep = {|values| return([values]) };
saved = keep(items.sorted());
key = saved[0][0];
target = {"1":"old"};
target[key] = "changed";
return([saved,target,items]);''', expected=[[['1', '10', '2']], {'1': 'changed'}, ['2', '10', '1']]),
    ]
    old_cases = json.loads(c.source('docs/checkpoints/type-array-pipelines/book-cases.json').read_bytes())['cases']
    plan = dict(cases=old_cases + new_cases)
    before = {path: c.read(path) for path in (CHAPTER, REFERENCE)}
    text = c.decode(before[CHAPTER]['base64']).decode()
    old = 'Numeric-looking selected terms retain existing scalar-kind caveats; use numeric\narithmetic before using a selected term as a numeric write index.'
    assert text.count(old) == 1
    prose = '''
#### Scalar kinds after sorting

Sorting preserves each element's scalar kind through codeblock arguments and
returned containers. Numbers stay numbers; numeric-looking strings stay strings.
The selected numeric value below remains a valid array-write index. This returns
`[[[1,10,2]],["zero","changed","two"],[2,10,1]]`:

```text
''' + new_cases[0]['body'] + '''
```

For string inputs, the selected `"1"` remains an harray key. This returns
`[[["1","10","2"]],{"1":"changed"},["2","10","1"]]`:

```text
''' + new_cases[1]['body'] + '''
```

Regenerate saved Perl parser source after upgrading to use this sorting behavior.
'''
    after = {CHAPTER: text.replace(old, prose.strip(), 1)}
    text = c.decode(before[REFERENCE]['base64']).decode()
    marker = 'Perl callable bodies also support `sorted` and `take`, including their receiver forms and reducer continuations. See the [worked sorting and selection examples](values-containers-and-flow-helpers.md#sorting-and-taking-inside-perl-codeblocks) for count rules, copies, evaluation order and remaining callable limits.'
    assert text.count(marker) == 1
    text = text.replace(marker, marker + '\nSorting also preserves numeric and string scalar kinds through codeblock copies; see the [typed copy examples](values-containers-and-flow-helpers.md#scalar-kinds-after-sorting).', 1)
    after[REFERENCE] = text
    supplied = context.snapshot()
    c.write_new('book-change-inputs.json.gz', supplied)
    c.write_new('book-cases.json', plan)
    for path, value in after.items():
        (c.ROOT / path).write_text(value)
        (c.ROOT / path).chmod(before[path]['mode'])
    c.write_new('book-change.json.gz', dict(producer=c.read(c.PREFIX + 'update_book.py'),
        before=before, after={path: c.read(path) for path in before},
        cases=c.read(c.PREFIX + 'book-cases.json'),
        scope='Runtime candidate passes the fixed116 cases before replacing the old numeric-sort caveat. Three earlier worked bodies remain exact; two new number/string copy/index examples and saved-parser regeneration guidance describe the current Perl behavior. No complete operation or cross-backend admission.'))
    print('Book follows verified candidate:', len(plan['cases']), 'worked bodies; numeric/string copies and parser regeneration documented')


if __name__ == '__main__':
    main()
