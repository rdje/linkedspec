"""Exact committed image admissions; historical results never become fresh execution."""
import gzip
import hashlib
import json
from pathlib import PurePosixPath
import re


def require(ok,message):
    if not ok:raise ValueError(message)


def sha(raw):return hashlib.sha256(raw).hexdigest()


def strict_json(raw):
    def pairs(items):
        result={}
        for key,value in items:
            require(key not in result,'duplicate image admission key')
            result[key]=value
        return result
    return json.loads(raw,object_pairs_hook=pairs)


def safe_path(name):
    require(isinstance(name,str) and name and '\\' not in name and not any(ord(c)<32 for c in name),
            'unsafe image admission path')
    path=PurePosixPath(name)
    require(not path.is_absolute() and str(path)==name and not any(p in ('.','..','.git') for p in path.parts),
            'unsafe image admission path')
    return name


class ImageAdmissions:
    def __init__(self,raw,expected_sha256,git):
        require(sha(raw)==expected_sha256,'source image admission input drift')
        require(len(raw)<=131072,'source image admission bound')
        data=strict_json(gzip.decompress(raw))
        require(isinstance(data,dict) and set(data)=={'schema_version','owner','activation_commit','images'},
                'source image admission schema')
        require(type(data['schema_version']) is int and data['schema_version']==1,'source image admission version')
        require(isinstance(data['owner'],str) and re.fullmatch(r'[A-Z][A-Z0-9-]*(?:\.[0-9]+)+',data['owner']),
                'source image admission owner')
        require(isinstance(data['activation_commit'],str) and re.fullmatch(r'[0-9a-f]{40}',data['activation_commit']),
                'source image activation revision')
        require(isinstance(data['images'],list) and data['images'],'source image admission population')
        self.git=git;self.data=data;self.rows={};self.before={};self.current={};self.commit_types=set();self.images={}
        for row in data['images']:
            require(isinstance(row,dict) and set(row)=={'path','historical_sha256','prior_revision','prior_sha256','current_sha256'},
                    'source image member schema')
            name=safe_path(row['path'])
            require(name not in self.rows,'duplicate source image member')
            require(isinstance(row['prior_revision'],str) and re.fullmatch(r'[0-9a-f]{40}',row['prior_revision']),
                    'source image predecessor revision')
            for field in ('historical_sha256','prior_sha256','current_sha256'):
                require(isinstance(row[field],str) and re.fullmatch(r'[0-9a-f]{64}',row[field]),'source image digest')
            self.rows[name]=row
        require(list(self.rows)==sorted(self.rows),'source image member order')

    def image(self,revision,name,expected):
        key=(revision,name,expected)
        if key in self.images:return self.images[key]
        if revision not in self.commit_types:
            require(self.git('cat-file','-t',revision).strip()==b'commit','image revision is not a commit')
            self.commit_types.add(revision)
        raw=self.git('ls-tree','-z',revision,'--',name).split(b'\0')
        require(len(raw)==2 and raw[0],'source image is missing: '+name)
        header,actual=raw[0].split(b'\t',1)
        mode,kind,blob=header.decode().split()
        require(actual.decode()==name and mode in ('100644','100755') and kind=='blob',
                'source image is not a regular parent-repository file: '+name)
        result=self.git('cat-file','blob',blob)
        require(sha(result)==expected,'committed source image mismatch: '+name)
        self.images[key]=result
        return result

    def verify(self,sources,read):
        require(set(self.rows)<=set(sources),'source image outside historical source population')
        for name,row in self.rows.items():
            require(row['historical_sha256']==sources[name]['sha256'],'source image historical boundary mismatch: '+name)
            before=self.image(row['prior_revision'],name,row['prior_sha256'])
            current=self.image(self.data['activation_commit'],name,row['current_sha256'])
            require(sha(read(name))==row['current_sha256'],'unreviewed current source image: '+name)
            self.before[name]=before;self.current[name]=current
        return self.report()

    def predecessor(self,name,current):
        return self.before.get(name,current)

    def read_predecessor(self,name,read):
        return self.before[name] if name in self.before else read(name)

    def report(self):
        return [dict(row,owner=self.data['owner'],activation_commit=self.data['activation_commit'],
                     source_stage='exact committed current image; predecessor checks remain historical',
                     scope='Source identity admission only; original runtime executions/results unchanged; no fresh objective compatibility or feature promotion')
                for row in self.rows.values()]

    def falsify(self,sources,read):
        rejected=[]
        for name in self.rows:
            def corrupted(path):
                value=read(path)
                return value+b'\nUNREVIEWED_SOURCE_IMAGE\n' if path==name else value
            try:self.verify(sources,corrupted)
            except ValueError as error:
                require(str(error)=='unreviewed current source image: '+name,'unrelated image rejection')
                rejected.append(name)
            else:raise ValueError('source image corruption admitted: '+name)
        self.verify(sources,read)
        return rejected
