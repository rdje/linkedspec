"""Classify actual source-image drift against the existing historical audit contract."""
from collections import OrderedDict
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[3]
PREFIX=Path(__file__).parent
BASE='0db5e9e87b7c1cfaf09936b9629974787038f5e3'
sys.path.insert(0,str(PREFIX))
from projection_replay import packet


def capture():
    destination=PREFIX/'objective-source-intake.json.gz'
    assert not destination.exists(),'intake is one-shot'
    spec=importlib.util.spec_from_file_location('original_objective_audit',ROOT/'tests/language-readiness/verify_objectives.py')
    audit=importlib.util.module_from_spec(spec);spec.loader.exec_module(audit)
    original_git=audit.git;cache=OrderedDict();cached=0
    def git(*args):
        nonlocal cached
        if args in cache:
            cache.move_to_end(args);return cache[args]
        raw=original_git(*args)
        if len(raw)<=32*1024*1024:
            while cache and cached+len(raw)>32*1024*1024:
                _,old=cache.popitem(last=False);cached-=len(old)
            cache[args]=raw;cached+=len(raw)
        return raw
    audit.git=git
    sources={};checkpoints={}
    for suffix in audit.MILESTONES:
        name=f'docs/checkpoints/{audit.PREFIX}{suffix}-verification.json'
        raw=(ROOT/name).read_bytes();record=json.loads(raw)
        revision=audit.producing_commit(name);checkpoints[name]=packet(raw)
        hashes=record['audit']['current_source_hashes'] if 'audit' in record else {r['path']:r['current'] for r in record['source_hash_comparisons']}
        for name,expected in hashes.items():sources[name]=dict(historical_sha256=expected,milestone=suffix,historical_revision=revision)
    def verifier(name):
        if name==audit.DART_SIGNED_SOURCE:return audit.verify_dart_signed_evolution
        if name in audit.RUST_NUMERIC_IMAGES:return audit.verify_rust_numeric_evolution
        if name==audit.RUST_SIGNED_SOURCE:return audit.verify_rust_signed_evolution
        return {'tools/run_ci_local.sh':audit.verify_governance_evolution,
                'tools/test_perl_project_data_storage.sh':audit.verify_perl_storage_evolution,
                't/phase0_regression.t':audit.verify_signature_regression_evolution,
                'perl/LinkedSpec/ActionIR/Contracts.pm':audit.verify_boundary_contract_evolution,
                'tools/check_public_aggregate_selector_surface.py':audit.verify_selector_governance_evolution}.get(name)
    result={};support_images={}
    for name,metadata in sources.items():
        current=(ROOT/name).read_bytes();actual=hashlib.sha256(current).hexdigest()
        if actual==metadata['historical_sha256'] or (name.startswith('docs/') and name.endswith('.md')):continue
        previous=git('show',metadata['historical_revision']+':'+name)
        assert hashlib.sha256(previous).hexdigest()==metadata['historical_sha256']
        fn=verifier(name);row=dict(metadata,current_sha256=actual,current=packet(current),prior=packet(previous),prior_revision=metadata['historical_revision'],tried=[])
        if fn:
            try:
                admitted=fn(name,current,metadata['historical_sha256'])
            except ValueError as error:row['current_rejection']=str(error)
            else:
                row['classification']='already_admitted';row['admission']=admitted;result[name]=row
                print(name,'already admitted',flush=True);continue
            for revision in git('log','--format=%H',BASE,'--',name).decode().splitlines():
                image=git('show',revision+':'+name);sha=hashlib.sha256(image).hexdigest()
                if any(item['sha256']==sha for item in row['tried']):continue
                try:
                    if name in audit.RUST_NUMERIC_IMAGES:
                        admitted=fn(name,image,metadata['historical_sha256'],read=lambda p:git('show',revision+':'+p))
                    else:admitted=fn(name,image,metadata['historical_sha256'])
                except (ValueError,subprocess.CalledProcessError) as error:
                    row['tried'].append(dict(revision=revision,sha256=sha,rejected=str(error)));continue
                row['tried'].append(dict(revision=revision,sha256=sha,admitted=True))
                row.update(prior=packet(image),prior_revision=revision,prior_admission=admitted)
                if name in audit.RUST_NUMERIC_IMAGES:
                    for path,expected in audit.RUST_NUMERIC_SUPPORT.items():
                        raw=git('show',revision+':'+path);assert hashlib.sha256(raw).hexdigest()==expected
                        support_images[path]=dict(revision=revision,sha256=expected,image=packet(raw))
                break
            else:raise ValueError('no preserved admitted predecessor found: '+name)
        row['classification']='ci_anchored_evolution' if name=='tools/run_ci_local.sh' else 'exact_source_image_required'
        if name!='tools/run_ci_local.sh':
            assert current==git('show',BASE+':'+name),'runtime source changed inside restoration: '+name
        row['history']=git('log','--format=%H %s',row['prior_revision']+'..'+BASE,'--',name).decode().splitlines()
        result[name]=row
        print(name,row['classification'],'prior',row['prior_revision'],flush=True)
    for path,row in support_images.items():row['current']=packet((ROOT/path).read_bytes())
    report=dict(base=BASE,sources=result,numeric_support=support_images,checkpoints=checkpoints,
                producer=packet(Path(__file__).read_bytes()),auditor=packet((ROOT/'tests/language-readiness/verify_objectives.py').read_bytes()),
                consumer=packet((ROOT/'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py').read_bytes()),
                canonical_failure=packet((ROOT/'.linkedspec-data/normal-hook-restoration/canonical-ci.log').read_bytes()),
                scope='Actual historical source/hash population, existing-admission classification and exact predecessor lookup. Historical runtime results are unchanged; no fresh runtime compatibility or exhaustive behavior claim.')
    destination.write_bytes(gzip.compress(json.dumps(report,sort_keys=True,separators=(',',':')).encode(),mtime=0))
    print('objective source intake retained',len(result),'raw differences',flush=True)

if __name__=='__main__':capture()
