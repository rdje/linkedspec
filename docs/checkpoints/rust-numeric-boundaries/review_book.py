"""Read-only review of actual numeric book inputs, outputs and controls."""
import importlib.util
import re
import common as c
import book_sources as plan
import book_outputs
from book_accept import asset, signature


def imported(name,path):
    spec=importlib.util.spec_from_file_location(name,c.ROOT/path)
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    return module


def check():
    search=imported('numeric_readonly_search','docs/checkpoints/type-deferred-indexed-writes/search_data.py')
    book=imported('numeric_readonly_book',plan.HELPER)
    saved=c.load('book6-containment.json.gz')
    old,new=saved['observed']['original'],saved['observed']['folded']
    compared=book_outputs.compare(old,new,search)
    assert compared['paths']==saved['verified_output_paths']
    assert compared['searcher_fallback']==saved['searcher_fallback']
    a,z=asset(old),asset(new)
    assert saved['generated_assets']==dict(before=a[0],after=z[0])
    original=search.decode_asset(a[1]);folded=search.decode_asset(z[1])
    documents=original['index']['documentStore']['docs']
    changed=[key for key in documents if documents[key]['body']!=folded['index']['documentStore']['docs'][key]['body']]
    assert changed==saved['changed_body_ids'] and len(changed)==4
    for key in changed:assert original['doc_urls'][int(key)].startswith('dsl/values-containers-and-flow-helpers.html#')
    before=c.decode(saved['inputs']['before'][plan.FLOW]['base64'])
    after=c.decode(saved['inputs']['folded'][plan.FLOW]['base64'])
    assert re.sub(rb'\s+',b'',before)==re.sub(rb'\s+',b'',after)
    semantic=saved['semantic_run'];assert semantic['returncode']==0
    bad=asset(semantic)
    assert search.canonical(bad[1])!=search.canonical(a[1])
    assert signature('dsl/values-containers-and-flow-helpers.html',semantic['outputs']['dsl/values-containers-and-flow-helpers.html'],bad[0])!=signature('dsl/values-containers-and-flow-helpers.html',old['outputs']['dsl/values-containers-and-flow-helpers.html'],a[0])
    assert search.canonical(saved['url_control'])!=search.canonical(a[1])
    runs=c.load('book6-runs.json.gz');plan.validate(book,runs['healthy'])
    assert runs['inputs_unchanged'] and set(runs['faults'])=={'heading','range','example'}
    for item in runs['faults'].values():
        assert item['run']['returncode']==0
        try:plan.validate(book,item['run'])
        except AssertionError:pass
        else:raise AssertionError('numeric rendered control admitted')
    scope=c.load('book7-scope.json.gz');plan.validate(book,scope['healthy'])
    phrase='Positive nested-write selectors and integer source metadata are checked against the host index bound.'
    assert phrase in c.decode(scope['healthy']['page_base64']).decode()
    assert phrase not in c.decode(scope['fault']['page_base64']).decode()
    final=c.load('book8-support.json.gz');plan.validate(book,final['healthy'])
    path='development/local-ci-and-regression.html'
    assert final['statement'] in c.decode(final['healthy']['outputs'][path]['base64']).decode()
    assert final['statement'] not in c.decode(final['fault']['outputs'][path]['base64']).decode()
    assert all(c.read(path)==packet for path,packet in final['after'].items())
    return dict(book_inputs=len(final['after']),outputs=len(new['outputs']),body_whitespace_changes=len(changed),source_denials=5,semantic_denials=2)


if __name__=='__main__':
    import json
    print(json.dumps(check(),sort_keys=True))
