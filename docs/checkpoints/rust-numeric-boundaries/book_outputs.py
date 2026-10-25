"""Compare every actual output, including the searcher's verified fallback URI."""
import re
import common as c
from book_accept import asset, signature


def compare(old,new,search):
    old_name,old_asset=asset(old);new_name,new_asset=asset(new)
    assert search.canonical(old_asset)==search.canonical(new_asset)
    paths=set(old['outputs'])-{old_name}
    assert paths==set(new['outputs'])-{new_name}
    fallbacks=[]
    for path in sorted(paths):
        before,current=old['outputs'][path],new['outputs'][path]
        assert before['mode']==current['mode']
        if path.endswith('.html'):
            assert signature(path,before,old_name)==signature(path,current,new_name),path
        elif before!=current:
            assert re.fullmatch(r'searcher-[a-f0-9]{8}\.js',path),path
            a,z=c.decode(before['base64']),c.decode(current['base64'])
            old_ref=("path_to_root + '"+old_name+"',").encode()
            new_ref=("path_to_root + '"+new_name+"',").encode()
            assert a.count(old_ref)==z.count(new_ref)==1
            assert a.replace(old_ref,new_ref,1)==z,'only the proven fallback URI may change'
            fallbacks.append(dict(path=path,before=old_ref.decode(),after=new_ref.decode()))
    assert len(fallbacks)==1
    return dict(paths=sorted(paths),searcher_fallback=fallbacks[0])
