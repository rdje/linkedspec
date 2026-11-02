"""Image admission, unchanged historical stages and fail-closed current drift."""
import copy
import gzip
import hashlib
import json
from historical_objective_images import ImageAdmissions

CURRENT='a'*40
PRIOR='b'*40
OLD={'perl/Compiler.pm':b'old compiler\n','rust/src/engine.rs':b'old engine\n'}
NEW={'perl/Compiler.pm':b'new compiler\n','rust/src/engine.rs':b'new engine\n'}


def sha(raw):return hashlib.sha256(raw).hexdigest()


def encoded(value):return gzip.compress(json.dumps(value,sort_keys=True,separators=(',',':')).encode(),mtime=0)


def table():
    return dict(schema_version=1,owner='REPAIR.1',activation_commit=CURRENT,images=[
        dict(path=p,historical_sha256=sha(OLD[p]),prior_revision=PRIOR,prior_sha256=sha(OLD[p]),current_sha256=sha(NEW[p])) for p in sorted(OLD)])


class Git:
    def __init__(self):self.calls=[];self.mode='100644';self.kind='blob';self.missing=False;self.corrupt=False;self.objects={}
    def __call__(self,*args):
        self.calls.append(args)
        if args[:2]==('cat-file','-t'):return b'commit\n' if args[2] in (CURRENT,PRIOR) else b'tree\n'
        if args[0]=='ls-tree':
            _,_,revision,_,name=args
            if self.missing or revision not in (CURRENT,PRIOR):return b''
            raw=(NEW if revision==CURRENT else OLD)[name];blob=hashlib.sha1(raw).hexdigest();self.objects[blob]=raw
            return f'{self.mode} {self.kind} {blob}\t{name}'.encode()+b'\0'
        if args[:2]==('cat-file','blob'):
            return self.objects[args[2]]+(b'corrupt' if self.corrupt else b'')
        raise AssertionError(args)


def rejected(action,reason):
    try:action()
    except ValueError as error:assert reason in str(error),(reason,error)
    else:raise AssertionError('accepted invalid source admission: '+reason)


def run():
    data=table();raw=encoded(data);git=Git();images=ImageAdmissions(raw,sha(raw),git)
    sources={p:{'sha256':sha(OLD[p])} for p in OLD}
    result=images.verify(sources,NEW.__getitem__)
    assert len(result)==2 and images.predecessor('perl/Compiler.pm',NEW['perl/Compiler.pm'])==OLD['perl/Compiler.pm']
    assert images.predecessor('unrelated',b'unchanged')==b'unchanged'
    calls=len(git.calls);images.verify(sources,NEW.__getitem__);assert len(git.calls)==calls
    altered=dict(NEW);altered['perl/Compiler.pm']+=b'changed'
    rejected(lambda:images.verify(sources,altered.__getitem__),'unreviewed current source image')
    assert images.falsify(sources,NEW.__getitem__)==sorted(NEW)
    rejected(lambda:ImageAdmissions(raw,'0'*64,Git()),'input drift')
    cases=(
        ('schema_version','1','version'),('owner','UNOWNED','owner'),('activation_commit','x','revision'))
    for key,value,reason in cases:
        bad=copy.deepcopy(data);bad[key]=value;body=encoded(bad)
        rejected(lambda:ImageAdmissions(body,sha(body),Git()),reason)
    for change,reason in ((lambda d:d['images'].append(d['images'][0]),'duplicate'),
                          (lambda d:d['images'].reverse(),'order'),
                          (lambda d:d['images'][0].update(path='../outside'),'unsafe'),
                          (lambda d:d['images'][0].update(extra=1),'schema')):
        bad=copy.deepcopy(data);change(bad);body=encoded(bad)
        rejected(lambda:ImageAdmissions(body,sha(body),Git()),reason)
    rejected(lambda:images.verify({},NEW.__getitem__),'outside historical source population')
    wrong=copy.deepcopy(sources);wrong['perl/Compiler.pm']['sha256']='0'*64
    rejected(lambda:images.verify(wrong,NEW.__getitem__),'historical boundary mismatch')
    for attribute,value,reason in (('mode','120000','regular'),('kind','tree','regular'),('missing',True,'missing'),('corrupt',True,'committed source image mismatch')):
        fixture=Git();setattr(fixture,attribute,value)
        rejected(lambda:ImageAdmissions(raw,sha(raw),fixture).verify(sources,NEW.__getitem__),reason)
    bad=copy.deepcopy(data);bad['activation_commit']='c'*40;body=encoded(bad)
    rejected(lambda:ImageAdmissions(body,sha(body),Git()).verify(sources,NEW.__getitem__),'not a commit')
    print('historical image controls: PASS exact current/predecessor stages; immutable cache, current corruption, membership, revisions, modes, hashes and schema denials')

if __name__=='__main__':run()
