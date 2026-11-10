"""Image admission, unchanged historical stages and fail-closed current drift."""
import copy
import gzip
import hashlib
import json
from historical_objective_images import ImageAdmissions, SuccessorImageAdmissions, AdditionalImageAdmissions

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


def successor_controls():
    latest='c'*40
    path='perl/Compiler.pm'
    current=dict(NEW);current[path]=b'later accepted compiler\n'
    class SuccessorGit(Git):
        successor_mode='100644'
        def __call__(self,*args):
            if args==('cat-file','-t',latest):return b'commit\n'
            if args[0]=='ls-tree' and args[2]==latest:
                name=args[-1];raw=current[name];blob=hashlib.sha1(raw).hexdigest();self.objects[blob]=raw
                return f'{self.successor_mode} blob {blob}\t{name}'.encode()+b'\0'
            return super().__call__(*args)
    data=dict(schema_version=1,owner='REPAIR.2',activation_commit=latest,images=[dict(
        path=path,historical_sha256=sha(OLD[path]),prior_revision=CURRENT,
        prior_sha256=sha(NEW[path]),current_sha256=sha(current[path]))])
    sources={name:{'sha256':sha(raw)} for name,raw in OLD.items()}
    def build(candidate=None,git=None,protected=()):
        git=git or SuccessorGit();raw=encoded(table());next_raw=encoded(data if candidate is None else candidate)
        return SuccessorImageAdmissions(ImageAdmissions(raw,sha(raw),git),
            ImageAdmissions(next_raw,sha(next_raw),git),protected=protected)
    images=build();rows=images.verify(sources,current.__getitem__)
    assert images.predecessor(path,current[path])==OLD[path]
    assert images.read_predecessor(path,current.__getitem__)==OLD[path]
    assert images.image(CURRENT,path,sha(NEW[path]))==NEW[path]
    assert images.data['activation_commit']==CURRENT and images.rows[path]['current_sha256']==sha(NEW[path])
    changed=next(row for row in rows if row['path']==path)
    assert changed['activation_commit']==latest and changed['current_sha256']==sha(current[path])
    assert changed['previous_current_sha256']==sha(NEW[path]) and changed['prior_sha256']==sha(OLD[path])
    assert next(row for row in rows if row['path']!=path)['activation_commit']==CURRENT
    assert images.falsify(sources,current.__getitem__)==sorted(OLD)
    for field,value,reason in (
        ('historical_sha256','0'*64,'historical boundary'),
        ('prior_revision',PRIOR,'predecessor image'),
        ('prior_sha256','0'*64,'predecessor image'),
        ('current_sha256',sha(NEW[path]),'redundant'),
        ('path','unrelated.pm','outside baseline')):
        bad=copy.deepcopy(data);bad['images'][0][field]=value
        rejected(lambda:build(bad),reason)
    rejected(lambda:build(protected=(path,)),'protected calibration')
    bad=copy.deepcopy(data);bad['activation_commit']='d'*40
    rejected(lambda:build(bad).verify(sources,current.__getitem__),'not a commit')
    invalid_git=SuccessorGit();invalid_git.successor_mode='120000'
    rejected(lambda:build(git=invalid_git).verify(sources,current.__getitem__),'not a regular')
    altered=dict(current);altered[path]+=b'unreviewed\n'
    rejected(lambda:images.verify(sources,altered.__getitem__),'unreviewed current source image: '+path)
    images.verify(sources,current.__getitem__)
    print('historical successor controls: PASS exact committed lineage, original predecessor stages, protected calibration, membership, mode, revision and current drift')


def additional_controls():
    path='dart/test/emitter.dart';prior=b'historical test\n';current=b'accepted later test\n'
    class AdditionalGit(Git):
        additional_mode='100644'
        def __call__(self,*args):
            if args[0]=='ls-tree' and args[-1]==path and args[2] in (PRIOR,CURRENT):
                raw=prior if args[2]==PRIOR else current;blob=hashlib.sha1(raw).hexdigest();self.objects[blob]=raw
                return f'{self.additional_mode} blob {blob}\t{path}'.encode()+b'\0'
            return super().__call__(*args)
    data=dict(schema_version=1,owner='REPAIR.3',activation_commit=CURRENT,images=[dict(
        path=path,historical_sha256=sha(prior),prior_revision=PRIOR,
        prior_sha256=sha(prior),current_sha256=sha(current))])
    def build(candidate=None,git=None):
        git=git or AdditionalGit();raw=encoded(table());extra=encoded(data if candidate is None else candidate)
        return AdditionalImageAdmissions(ImageAdmissions(raw,sha(raw),git),ImageAdmissions(extra,sha(extra),git))
    sources={name:dict(sha256=sha(raw)) for name,raw in OLD.items()};sources[path]=dict(sha256=sha(prior))
    actual=dict(NEW);actual[path]=current
    images=build();rows=images.verify(sources,actual.__getitem__)
    assert len(rows)==3 and images.predecessor(path,current)==prior
    assert images.read_predecessor(path,actual.__getitem__)==prior
    assert images.predecessor('perl/Compiler.pm',NEW['perl/Compiler.pm'])==OLD['perl/Compiler.pm']
    assert images.falsify(sources,actual.__getitem__)==sorted(sources)
    bad=copy.deepcopy(data);bad['images'][0]['prior_sha256']='0'*64
    rejected(lambda:build(bad),'predecessor is not historical')
    bad=copy.deepcopy(data);bad['images'][0]['path']='perl/Compiler.pm'
    rejected(lambda:build(bad),'already admitted')
    rejected(lambda:build().verify({name:row for name,row in sources.items() if name!=path},actual.__getitem__),'outside historical source population')
    git=AdditionalGit();git.additional_mode='120000'
    rejected(lambda:build(git=git).verify(sources,actual.__getitem__),'not a regular')
    wrong=dict(actual);wrong[path]+=b'unreviewed\n'
    rejected(lambda:images.verify(sources,wrong.__getitem__),'unreviewed current source image: '+path)
    images.verify(sources,actual.__getitem__)
    print('historical additional-image controls: PASS named membership, exact historical predecessor, committed modes and fail-closed current drift')


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
    successor_controls()
    additional_controls()

if __name__=='__main__':run()
