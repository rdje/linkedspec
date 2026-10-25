"""Admit containment only after verifying the actual generated search payloads."""
import copy
import importlib.util
import posixpath
import re
import common as c
import book_render as render
import book_sources as plan
from book_update import visible
from book_outputs import compare as verified_outputs

SEARCH='docs/checkpoints/type-deferred-indexed-writes/search_data.py'


def imported(name,path):
    spec=importlib.util.spec_from_file_location(name,c.ROOT/path)
    result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result)
    return result


def asset(run):
    names=[name for name in run['outputs'] if re.fullmatch(r'searchindex-[a-f0-9]{8}\.js',name)]
    assert len(names)==1
    return names[0],run['outputs'][names[0]]


def signature(path,item,name):
    raw=c.decode(item['base64'])
    pattern=rb'window\.path_to_searchindex_js = "([^"]+)";'
    refs=list(re.finditer(pattern,raw))
    if refs:
        assert len(refs)==1
        reference=refs[0].group(1).decode()
        assert posixpath.normpath(posixpath.join(posixpath.dirname(path),reference))==name
        raw=raw[:refs[0].start(1)]+b'<verified-search-index>'+raw[refs[0].end(1):]
    return visible(dict(page_base64=c.encode(raw)))


def main():
    search=imported('numeric_verified_search',SEARCH)
    book=imported('numeric_verified_book',plan.HELPER)
    inputs=c.load('book4-probe-inputs.json.gz')
    observed=c.load('book4-probe-runs.json.gz')
    old,new=observed['original'],observed['folded']
    assert old['returncode']==new['returncode']==0
    old_name,old_asset=asset(old);new_name,new_asset=asset(new)
    assert search.canonical(old_asset)==search.canonical(new_asset),'full search payload semantics'
    a,z=search.decode_asset(old_asset),search.decode_asset(new_asset)
    documents=a['index']['documentStore']['docs'];after=z['index']['documentStore']['docs']
    changed=[key for key in documents if documents[key]['body']!=after[key]['body']]
    assert all(a['doc_urls'][int(key)].startswith(render.HTML+'#') for key in changed)
    comparison=verified_outputs(old,new,search)
    paths=comparison['paths']
    assert search.canonical(search.corrupt_url(new_asset))!=search.canonical(old_asset)
    semantic=plan.changed(inputs['folded'],plan.FLOW,b'Perl retains each evaluated array element',
        b'Perl discards each evaluated array element')
    semantic_run=render.render(semantic);assert semantic_run['returncode']==0
    semantic_name,semantic_asset=asset(semantic_run)
    assert search.canonical(semantic_asset)!=search.canonical(old_asset)
    assert signature(render.HTML,semantic_run['outputs'][render.HTML],semantic_name)!=signature(
        render.HTML,old['outputs'][render.HTML],old_name)
    c.save('book6-containment.json.gz',dict(inputs=inputs,observed=observed,
        producers={name:c.read(name) for name in [SEARCH,plan.HELPER,c.PREFIX+'book_accept2.py',c.PREFIX+'book_accept.py',c.PREFIX+'book_outputs.py',
            c.PREFIX+'book_render.py',c.PREFIX+'book_update.py',c.PREFIX+'book_sources.py',
            c.PREFIX+'common.py']},
        generated_assets=dict(before=old_name,after=new_name),changed_body_ids=changed,
        verified_output_paths=paths,searcher_fallback=comparison['searcher_fallback'],
        strict_fallback_rejection=c.read('.linkedspec-data/verification/numeric55-book5.log'),semantic_input=semantic[plan.FLOW],
        semantic_run=semantic_run,url_control=search.corrupt_url(new_asset),
        scope='Actual complete90-file old/folded outputs. Verify the complete decoded '
            'search object with only document-body whitespace normalized; all other '
            'fields, URLs, term indexes and actual page references remain checked; the '
            'searcher JS changes only its exact verified fallback URI. '
            'Then compare HTML tokens with only those proven search references '
            'projected, preserving literal code/script/style. A real changed prose '
            'render and a changed decoded URL both reject. Earlier strict selected-'
            'page rejection stays retained; no wildcard asset or output equality claim.'))
    assert all(c.read(path)==packet for path,packet in inputs['before'].items())
    compact=c.decode(inputs['folded'][plan.FLOW]['base64']).decode()
    anchor='\n### Evaluated values and later side effects\n';assert compact.count(anchor)==1
    updated=compact.replace(anchor,'\n'+plan.CONTENT+anchor,1)
    original=c.decode(inputs['before'][plan.FLOW]['base64']).decode()
    assert len(updated.splitlines())<=len(original.splitlines())
    development=c.source(plan.DEV).read_text()
    prior='Rust signed-selector admission permits only the exact reviewed before/after runtime source pair.'
    admission=('Rust numeric admission permits only the exact reviewed Cargo feature and engine source images, '
        'retaining the signed-selector source pair as a checked predecessor.')
    assert development.count(prior)==1
    (c.ROOT/plan.FLOW).write_text(updated)
    (c.ROOT/plan.DEV).write_text(development.replace(prior,admission,1))
    supplied=book.inputs();healthy=render.render(supplied);plan.validate(book,healthy)
    development_page=c.decode(healthy['outputs']['development/local-ci-and-regression.html']['base64']).decode()
    assert admission in development_page
    variants={
        'heading':plan.changed(supplied,plan.FLOW,b'### Rust numeric transport',b'### Changed numeric heading'),
        'range':plan.changed(supplied,plan.FLOW,b'Whole values within signed64 or unsigned64 bounds use exact integer JSON tokens.',b'Whole values always clamp to signed64 JSON.'),
        'example':plan.changed(supplied,plan.FLOW,plan.EXAMPLES[0].encode(),plan.EXAMPLES[0].replace('-100000000000000000000','100000000000000000000').encode()),
    }
    faults={}
    for name,packets in variants.items():
        run=render.render(packets);assert run['returncode']==0
        try:plan.validate(book,run)
        except AssertionError as error:reason=str(error)
        else:raise AssertionError('rendered numeric fault admitted: '+name)
        faults[name]=dict(run=run,reason=reason,input=packets[plan.FLOW])
    stable=all(c.read(path)==packet for path,packet in supplied.items())
    c.save('book6-after-inputs.json.gz',dict(inputs=supplied,examples=plan.EXAMPLES,
        source_lines_before=len(original.splitlines()),source_lines_after=len(updated.splitlines())))
    c.save('book6-runs.json.gz',dict(healthy=healthy,faults=faults,inputs_unchanged=stable,
        limits='Book rendering/admission only; exact CLI execution remains separately required.'))
    assert stable
    print('Book admitted:90 complete output files,',len(changed),
        'body-whitespace changes, two semantic/URL denials and three numeric source denials; net source lines -1.')


if __name__ == '__main__':
    main()
