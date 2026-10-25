"""Render, contain and update the book without selecting a new size budget."""
import copy
from html.parser import HTMLParser
import importlib.util
import re
import common as c
import book_sources as plan


class Visible(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.tokens=[]
        self.literal=0
    def handle_starttag(self,tag,attrs):
        self.tokens.append(('start',tag,attrs))
        if tag in ('pre','code','script','style'):self.literal+=1
    def handle_endtag(self,tag):
        self.tokens.append(('end',tag))
        if tag in ('pre','code','script','style'):self.literal-=1
    def handle_data(self,data):
        self.tokens.append(('text',data if self.literal else re.sub(r'\s+',' ',data)))


def visible(run):
    parser=Visible();parser.feed(c.decode(run['page_base64']).decode())
    assert parser.literal==0
    return parser.tokens


def compact_prose(text):
    result=[];block=[];inside=False;removed=0
    def flush():
        nonlocal removed
        allowed=(len(block)>1 and all(line.strip() and not line[0].isspace()
            and not line.startswith(('#','|','>','<','-','+','*','```'))
            and not re.match(r'\d+[.)] ',line)
            and not line.rstrip('\n').endswith(('  ','\\')) for line in block))
        if allowed:
            result.append(' '.join(line.rstrip('\n') for line in block)+'\n')
            removed+=len(block)-1
        else:result.extend(block)
        block.clear()
    for line in text.splitlines(keepends=True):
        if line.startswith('```'):
            flush();result.append(line);inside=not inside
        elif inside:
            result.append(line)
        elif line=='\n':
            flush();result.append(line)
        else:block.append(line)
    flush()
    return ''.join(result),removed


def main():
    helper=plan.HELPER
    spec=importlib.util.spec_from_file_location('numeric_book_render',c.ROOT/helper)
    book=importlib.util.module_from_spec(spec);spec.loader.exec_module(book)
    before=book.inputs()
    original=c.decode(before[plan.FLOW]['base64']).decode()
    compact,removed=compact_prose(original)
    c.save('book2-before-inputs.json.gz',dict(inputs=before,
        producers={name:c.read(name) for name in [helper,c.PREFIX+'book_sources.py',
            c.PREFIX+'book_update.py',c.PREFIX+'common.py']},
        first_proposal_inputs=c.load('book-before-inputs.json.gz'),
        first_proposal_failure=c.read('.linkedspec-data/verification/numeric55-book.log'),
        first_proposal_unchanged=before==c.load('book-before-inputs.json.gz')['inputs'],
        qualification='The first producer assumed24 blank heading separators; only12 '
            'are available. It failed before writing any source. Retain its source, '
            'whole inputs and actual failure; it supplies no containment credit. '
            'Use actual prose soft-wrap containment and compare complete HTML tokens, '
            'normalizing ordinary whitespace while preserving code/script/style bytes.'))
    assert removed>=24,'enough real soft-wrap lines must exist'
    original_render=book.render(before)
    folded=plan.changed(before,plan.FLOW,original.encode(),compact.encode())
    folded_render=book.render(folded)
    assert original_render['returncode']==folded_render['returncode']==0
    same=visible(original_render)==visible(folded_render)
    semantic=plan.changed(folded,plan.FLOW,b'Perl retains each evaluated array element',
        b'Perl discards each evaluated array element')
    semantic_render=book.render(semantic)
    assert semantic_render['returncode']==0
    denied=visible(original_render)!=visible(semantic_render)
    c.save('book2-containment.json.gz',dict(before=before,folded=folded,
        removed=removed,original_render=original_render,folded_render=folded_render,
        visible_tokens_equal=same,actual_page_bytes_equal=
            original_render['page_base64']==folded_render['page_base64'],
        semantic_fault=semantic[plan.FLOW],semantic_render=semantic_render,
        semantic_change_rejected=denied,
        limits='Complete affected-page HTML token equality with ordinary whitespace '
            'normalization; code/script/style contents stay literal. No byte-equality '
            'claim for changed prose wrapping or other unretained output pages.'))
    assert same and denied
    anchor='\n### Evaluated values and later side effects\n'
    assert compact.count(anchor)==1
    updated=compact.replace(anchor,'\n'+plan.CONTENT+anchor,1)
    assert len(updated.splitlines())<=len(original.splitlines())
    (c.ROOT/plan.FLOW).write_text(updated)
    development=c.source(plan.DEV).read_text()
    old='Rust signed-selector admission permits only the exact reviewed before/after runtime source pair.'
    new=('Rust numeric admission permits only the exact reviewed Cargo feature and engine source images, '
        'retaining the signed-selector source pair as a checked predecessor.')
    assert development.count(old)==1
    (c.ROOT/plan.DEV).write_text(development.replace(old,new,1))
    supplied=book.inputs()
    healthy=book.render(supplied);plan.validate(book,healthy)
    variants={
        'heading':plan.changed(supplied,plan.FLOW,b'### Rust numeric transport',b'### Changed numeric heading'),
        'range':plan.changed(supplied,plan.FLOW,b'Whole values within signed64 or unsigned64 bounds use exact integer JSON tokens.',b'Whole values always clamp to signed64 JSON.'),
        'example':plan.changed(supplied,plan.FLOW,plan.EXAMPLES[0].encode(),plan.EXAMPLES[0].replace('-100000000000000000000','100000000000000000000').encode()),
    }
    faults={}
    for name,packets in variants.items():
        run=book.render(packets);assert run['returncode']==0
        try:plan.validate(book,run)
        except AssertionError as error:reason=str(error)
        else:raise AssertionError('rendered numeric fault admitted: '+name)
        faults[name]=dict(run=run,reason=reason,input=packets[plan.FLOW])
    stable=all(c.read(path)==packet for path,packet in supplied.items())
    c.save('book2-after-inputs.json.gz',dict(inputs=supplied,examples=plan.EXAMPLES,
        source_lines_before=len(original.splitlines()),source_lines_after=len(updated.splitlines())))
    c.save('book2-runs.json.gz',dict(healthy=healthy,faults=faults,inputs_unchanged=stable,
        limits='Actual supplied rendering and source denials. Exact execution of both '
            'rendered numeric examples remains separately required before acceptance.'))
    assert stable
    print('Numeric book PASS: actual neutral prose containment, rendered policy/examples/aliases and three source denials; unchanged line budget.')


if __name__ == '__main__':
    main()
