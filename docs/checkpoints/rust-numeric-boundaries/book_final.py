"""Use actual available containment and retain both rejected size assumptions."""
import importlib.util
import re
import common as c
import book_sources as plan
from book_update import compact_prose, visible


def main():
    spec=importlib.util.spec_from_file_location('numeric_final_book_render',c.ROOT/plan.HELPER)
    book=importlib.util.module_from_spec(spec);spec.loader.exec_module(book)
    before=book.inputs()
    original=c.decode(before[plan.FLOW]['base64']).decode()
    compact,soft=compact_prose(original)
    lines=compact.splitlines(keepends=True);kept=[];inside=False;blank=0
    for index,line in enumerate(lines):
        if line.startswith('```'):inside=not inside
        if (not inside and line=='\n' and index+1<len(lines)
                and re.match(r'#{2,6} ',lines[index+1])):
            blank+=1
            continue
        kept.append(line)
    compact=''.join(kept)
    anchor='\n### Evaluated values and later side effects\n'
    assert compact.count(anchor)==1
    updated=compact.replace(anchor,'\n'+plan.CONTENT+anchor,1)
    assert len(updated.splitlines())<=len(original.splitlines())
    c.save('book3-before-inputs.json.gz',dict(inputs=before,
        producers={name:c.read(name) for name in [plan.HELPER,c.PREFIX+'book_sources.py',
            c.PREFIX+'book_update.py',c.PREFIX+'book_final.py',c.PREFIX+'common.py']},
        rejected_proposals={name:c.load(name) for name in
            ['book-before-inputs.json.gz','book2-before-inputs.json.gz']},
        rejected_logs={name:c.read('.linkedspec-data/verification/'+name) for name in
            ['numeric55-book.log','numeric55-book2.log']},
        qualification='Both prior producers fail before root source writes: each '
            'requires24 lines from a single containment kind, while actual available '
            'population is12 heading separators plus11 prose soft-wrap lines. Use '
            'the actual combined23 and derive the final line delta; no budget raise '
            'or unobserved containment credit.'))
    old_render=book.render(before)
    folded=plan.changed(before,plan.FLOW,original.encode(),compact.encode())
    folded_render=book.render(folded)
    assert old_render['returncode']==folded_render['returncode']==0
    same=visible(old_render)==visible(folded_render)
    semantic=plan.changed(folded,plan.FLOW,b'Perl retains each evaluated array element',
        b'Perl discards each evaluated array element')
    semantic_render=book.render(semantic);assert semantic_render['returncode']==0
    denied=visible(old_render)!=visible(semantic_render)
    c.save('book3-containment.json.gz',dict(before=before,folded=folded,soft=soft,blank=blank,
        original_render=old_render,folded_render=folded_render,visible_tokens_equal=same,
        actual_page_bytes_equal=old_render['page_base64']==folded_render['page_base64'],
        semantic_fault=semantic[plan.FLOW],semantic_render=semantic_render,
        semantic_change_rejected=denied,
        limits='Complete affected-page token equality normalizes ordinary whitespace '
            'but keeps code/script/style literal. Other output pages are not retained '
            'or claimed byte-identical.'))
    assert same and denied
    development=c.source(plan.DEV).read_text()
    old='Rust signed-selector admission permits only the exact reviewed before/after runtime source pair.'
    new=('Rust numeric admission permits only the exact reviewed Cargo feature and engine source images, '
        'retaining the signed-selector source pair as a checked predecessor.')
    assert development.count(old)==1
    (c.ROOT/plan.FLOW).write_text(updated)
    (c.ROOT/plan.DEV).write_text(development.replace(old,new,1))
    supplied=book.inputs();healthy=book.render(supplied);plan.validate(book,healthy)
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
    c.save('book3-after-inputs.json.gz',dict(inputs=supplied,examples=plan.EXAMPLES,
        source_lines_before=len(original.splitlines()),source_lines_after=len(updated.splitlines())))
    c.save('book3-runs.json.gz',dict(healthy=healthy,faults=faults,inputs_unchanged=stable,
        limits='Rendering and source denials only. Exact execution of both numeric '
            'examples remains required separately.'))
    assert stable
    print('Numeric book PASS: actual23-line neutral containment and22 inserted lines; policy/examples/aliases and three source denials pass.')


if __name__ == '__main__':
    main()
