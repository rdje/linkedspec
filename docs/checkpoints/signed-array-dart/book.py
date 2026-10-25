"""Supplied complete-book Dart update, actual renders and source denials."""
import copy
import html
from html.parser import HTMLParser
import importlib.util
from types import SimpleNamespace
import common as c

FLOW='docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
DEV='docs/linkedspec-book/src/development/local-ci-and-regression.md'
LEGACY='docs/checkpoints/signed-array-rust/book.py'
RENDER='docs/checkpoints/rust-numeric-boundaries/book_render.py'
POLICY='Dart admits actual integer negative selectors; negative floating values such as `-1.0` and numeric strings keep their previous read behavior, and floating write selectors remain invalid.'
ADMISSION='Dart signed-selector admission separately binds its exact reviewed whole interpreter image from clean activation; unregistered images reject, while historical runtime results and every Rust admission remain unchanged.'
EXAMPLES={
    'examples/negative-array-current-perl.spec':[30,[10,20,30]],
    'examples/negative-array-current-callable-perl.spec':[30,[10,20,30]],
    'examples/negative-array-write-perl.spec':[30,[10,99,30]],
    'examples/negative-array-write-callable-perl.spec':{'rows':[[1],[99,3]]},
}


def load(name,path):
    spec=importlib.util.spec_from_file_location(name,c.ROOT/path)
    result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result)
    return result


def helpers():
    legacy=load('signed_dart_book_inputs',LEGACY)
    legacy.c=SimpleNamespace(ROOT=c.ROOT,source=c.file,read=c.read,decode=c.decode,encode=c.encode,sha=c.sha)
    render=load('signed_dart_book_render',RENDER)
    return legacy,render


def changed(packets,path,before,after):
    result=copy.deepcopy(packets)
    raw=c.decode(result[path]['base64']);assert raw.count(before)==1,before
    raw=raw.replace(before,after,1)
    result[path].update(base64=c.encode(raw),sha256=c.sha(raw))
    return result


def validate(legacy,run,packets):
    assert run['returncode']==0,'book render'
    page=c.decode(run['page_base64']).decode();plain=html.unescape(page)
    assert 'Signed array selectors in Perl, Rust and Dart' in plain,'Dart heading'
    assert 'The extension is available on Perl, Rust and Dart' in plain,'Dart admission scope'
    class Text(HTMLParser):
        def __init__(self):super().__init__(convert_charrefs=True);self.parts=[]
        def handle_data(self,value):self.parts.append(value)
    visible=Text();visible.feed(page)
    assert POLICY.replace('`','') in ''.join(visible.parts),'Dart integer/coercion scope'
    assert '| Dart ordinary/callable read | `30` |' in c.decode(packets[FLOW]['base64']).decode(),'Dart result row'
    for anchor in ('signed-array-selectors-in-perl','signed-array-selectors-in-perl-and-rust',
                   'signed-array-selectors-in-perl-rust-and-dart'):
        assert 'id="'+anchor+'"' in page,'preserved fragment '+anchor
    code=legacy.Code();code.feed(page)
    examples=c.load('fixture-inputs.json.gz')['examples']
    for path in EXAMPLES:
        assert code.blocks.count(c.decode(examples[path]['base64']).decode().rstrip('\n'))==1,'exact example '+path
    development=html.unescape(c.decode(run['outputs']['development/local-ci-and-regression.html']['base64']).decode())
    assert ADMISSION in development,'Dart historical admission statement'
    assert 'not yet admitted portably' in plain,'portable limit'


def main():
    legacy,renderer=helpers()
    before=legacy.inputs()
    c.save('book-before-inputs.json.gz',dict(inputs=before,
        producers={path:c.read(path) for path in [c.PREFIX+'book.py',c.PREFIX+'common.py',LEGACY,RENDER]},
        scope='Whole tracked source/configuration and recursive includes before book changes. '
            'Only sealed pure input/render/HTML parsing helpers are reused; no old capture writer runs.'))
    original=c.decode(before[FLOW]['base64']).decode()
    updated=original
    replacements={
        'Perl and Rust native and independently emitted execution implement tail-relative reads and writes':
            'Perl, Rust and Dart native and independently emitted execution implement tail-relative reads and writes',
        'Other backend implementations and portable admission remain separately owned.':
            'Julia/Lua implementations and portable admission remain separately owned.',
        '#### Signed array selectors in Perl and Rust':
            '<a id="signed-array-selectors-in-perl-and-rust"></a>\n#### Signed array selectors in Perl, Rust and Dart',
        'The extension is available on Perl and Rust;':
            'The extension is available on Perl, Rust and Dart;',
        '| Dart, Julia, PUC Lua and LuaJIT | `null` |':
            '| Dart ordinary/callable read | `30` |\n| Julia, PUC Lua and LuaJIT | `null` |',
        'Dart and Lua/Julia rows retain the dated transition observations until their backend slices land. Perl and Rust negative writes replace existing array entries.':
            'Lua/Julia rows retain the dated transition observations until their backend slices land. Perl, Rust and Dart negative writes replace existing array entries.',
        'The ordinary example runs on Perl and Rust and returns':
            'The ordinary example runs on Perl, Rust and Dart and returns',
        'Perl and Rust implement the following rule from':
            'Perl, Rust and Dart implement the following rule from',
        'This extension does not expand the numeric range or admit portable coercions.':
            POLICY+' This extension does not expand the numeric range or admit portable coercions.',
    }
    for old,new in replacements.items():
        assert updated.count(old)==1,old
        updated=updated.replace(old,new,1)
    assert len(updated.splitlines())==len(original.splitlines())+2
    c.file(FLOW).write_text(updated)
    development=c.decode(before[DEV]['base64']).decode()
    old='Fresh Rust nesting, context and lossless/child compatibility runs independently; this does not establish portable signed-selector coverage.'
    assert development.count(old)==1
    development=development.replace(old,ADMISSION+' Fresh Rust and Dart nesting, context and lossless/child compatibility runs independently; this does not establish portable signed-selector coverage.',1)
    c.file(DEV).write_text(development)
    supplied=legacy.inputs()
    healthy=renderer.render(supplied);validate(legacy,healthy,supplied)
    variants={
        'heading':changed(supplied,FLOW,b'#### Signed array selectors in Perl, Rust and Dart',
            b'#### Signed array selectors in Perl and Rust'),
        'coercion':changed(supplied,FLOW,POLICY.encode(),b'Dart accepts every negative numeric selector.'),
        'example':changed(supplied,next(iter(EXAMPLES)),b'[10,20,30]',b'[10,20,40]'),
        'admission':changed(supplied,DEV,ADMISSION.encode(),b'Any Dart source image is admitted.'),
    }
    faults={}
    for name,packets in variants.items():
        run=renderer.render(packets);assert run['returncode']==0
        try:validate(legacy,run,packets)
        except AssertionError as error:reason=str(error)
        else:raise AssertionError('book mutation admitted: '+name)
        faults[name]=dict(reason=reason,changed_inputs={path:packet for path,packet in packets.items()
            if packet!=supplied[path]},run=run)
    stable=all(c.read(path)==packet for path,packet in supplied.items())
    c.save('book-after-inputs.json.gz',dict(inputs=supplied,source_line_delta=2,examples=EXAMPLES))
    c.save('book-runs.json.gz',dict(healthy=healthy,faults=faults,inputs_unchanged=stable,
        scope='Actual complete output custody, exact examples, preserved fragments, Dart integer scope and '
            'historical-admission statement; four supplied source denials. No rendered-neutral edit '
            'or budget increase is needed. Actual examples execute in public/emitted/CLI captures.'))
    assert stable
    print('Dart book:',len(supplied),'inputs;',len(healthy['outputs']),'outputs; four source denials.')


if __name__=='__main__':main()
