"""Retain rendered-neutral containment and the supplied numeric book update."""
import copy
import html
import importlib.util
import re
import common as c

FLOW='docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
DEV='docs/linkedspec-book/src/development/local-ci-and-regression.md'
HELPER='docs/checkpoints/signed-array-rust/book.py'
CONTENT='''### Rust numeric transport

Rust numeric values use binary64 precision. Large finite values keep that value through JSON output and serialized/generated parsers; this does not provide arbitrary-precision integer arithmetic.

Whole values within signed64 or unsigned64 bounds use exact integer JSON tokens. Wider finite values use floating JSON. Rust preserves negative zero in JSON, while scalar text spells it `0`. This parser demonstrates wide values beside an ordinary integer:

```text
Top: /x/
 I { return([100000000000000000000,-100000000000000000000,42]) }
```

For input `x`, the result contains the numeric values `1e20`, `-1e20` and `42`. Decimal versus exponent notation does not change those values. Numeric text consumers also preserve the value:

```text
Top: /x/
 I { value=100000000000000000000; return([trim(value),length(value),hash(value,7)]) }
```

On Rust this returns `["100000000000000000000",21,{"100000000000000000000":7}]`. The hash constructor converts its key to text; numeric bracket selectors address arrays. Existing index positions and source metadata must fit the host index type; an out-of-range integer rejects rather than becoming the largest index.

Embedding a nonfinite Rust numeric value produces JSON null. The portable `cat` spelling contract remains distinct from this numeric transport behavior.
'''
EXAMPLES=[
    'Top: /x/\n I { return([100000000000000000000,-100000000000000000000,42]) }',
    'Top: /x/\n I { value=100000000000000000000; return([trim(value),length(value),hash(value,7)]) }',
]


def changed(packets,path,old,new):
    result=copy.deepcopy(packets)
    raw=c.decode(result[path]['base64'])
    assert raw.count(old)==1
    raw=raw.replace(old,new,1)
    result[path].update(base64=c.encode(raw),sha256=c.sha(raw))
    return result


def validate(book,run):
    assert run['returncode']==0,'book render'
    page=html.unescape(c.decode(run['page_base64']).decode())
    assert 'Rust numeric transport' in page,'numeric heading'
    assert 'Whole values within signed64 or unsigned64 bounds use exact integer JSON tokens.' in page,'numeric range policy'
    assert 'Rust preserves negative zero in JSON' in page,'signed zero policy'
    parsed=book.Code();parsed.feed(page)
    assert all(parsed.blocks.count(source)==1 for source in EXAMPLES),'exact numeric examples'
    for anchor in ('signed-array-selectors-in-perl','signed-array-selectors-in-perl-and-rust'):
        assert 'id="'+anchor+'"' in page,'existing signed-selector fragment'


def main():
    spec=importlib.util.spec_from_file_location('numeric_book_surface',c.ROOT/HELPER)
    book=importlib.util.module_from_spec(spec);spec.loader.exec_module(book)
    before=book.inputs()
    c.save('book-before-inputs.json.gz',dict(inputs=before,producer=c.read(c.PREFIX+'book_sources.py'),
        helper=c.read(HELPER),common=c.read(c.PREFIX+'common.py'),
        scope='Whole tracked book configuration/source/recursive includes. Only the sealed pure input/render/Code functions are reused; no predecessor capture writer runs. Installed mdBook/OS are read-only prerequisites.'))
    old_render=book.render(before)
    assert old_render['returncode']==0
    original=c.decode(before[FLOW]['base64']).decode()
    lines=original.splitlines(keepends=True)
    compact=[];inside=False;removed=0
    for index,line in enumerate(lines):
        if line.startswith('```'):
            inside=not inside
        if (not inside and line=='\n' and index+1<len(lines)
                and re.match(r'#{2,6} ',lines[index+1]) and removed<24):
            removed+=1
            continue
        compact.append(line)
    assert removed==24
    compact=''.join(compact)
    folded=changed(before,FLOW,original.encode(),compact.encode())
    folded_render=book.render(folded)
    same=folded_render['returncode']==0 and folded_render['page_base64']==old_render['page_base64']
    c.save('book-containment.json.gz',dict(before=before,after=folded,removed=removed,
        original_render=old_render,folded_render=folded_render,selected_page_byte_identical=same,
        limits='Exact affected DSL page comparison only; no equality claim for unretained other output files.'))
    assert same,'containment must preserve actual rendered page before source writes'
    anchor='\n### Evaluated values and later side effects\n'
    assert compact.count(anchor)==1
    updated=compact.replace(anchor,'\n'+CONTENT+anchor,1)
    assert len(updated.splitlines())<=len(original.splitlines()),'unchanged book line budget'
    (c.ROOT/FLOW).write_text(updated)
    development=c.source(DEV).read_text()
    old='Rust signed-selector admission permits only the exact reviewed before/after runtime source pair.'
    new=('Rust numeric admission permits only the exact reviewed Cargo feature and engine source images, '
         'retaining the signed-selector source pair as a checked predecessor.')
    assert development.count(old)==1
    (c.ROOT/DEV).write_text(development.replace(old,new,1))
    supplied=book.inputs()
    healthy=book.render(supplied);validate(book,healthy)
    faults={}
    variants={
        'heading':changed(supplied,FLOW,b'### Rust numeric transport',b'### Changed numeric heading'),
        'range':changed(supplied,FLOW,b'Whole values within signed64 or unsigned64 bounds use exact integer JSON tokens.',b'Whole values always clamp to signed64 JSON.'),
        'example':changed(supplied,FLOW,EXAMPLES[0].encode(),EXAMPLES[0].replace('-100000000000000000000','100000000000000000000').encode()),
    }
    for name,packets in variants.items():
        run=book.render(packets)
        assert run['returncode']==0
        try:
            validate(book,run)
        except AssertionError as error:
            reason=str(error)
        else:
            raise AssertionError('rendered book source fault admitted: '+name)
        faults[name]=dict(run=run,reason=reason,changed_input=packets[FLOW])
    stable=all(c.read(path)==packet for path,packet in supplied.items())
    c.save('book-after-inputs.json.gz',dict(inputs=supplied,examples=EXAMPLES,
        source_lines_before=len(original.splitlines()),source_lines_after=len(updated.splitlines())))
    c.save('book-runs.json.gz',dict(healthy=healthy,faults=faults,inputs_unchanged=stable,
        limits='Rendering and source denials only; exact CLI execution of these two examples is separately required.'))
    assert stable
    print('Supplied numeric book/three source denials pass;24 neutral separators removed within unchanged line budget.')


if __name__ == '__main__':
    main()
