"""Seven coherent artifact denials with complete supplied inputs and restoration."""
import base64, gzip, hashlib, json, os, re, stat, subprocess, sys, tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0/'
TARGET=ROOT/(PREFIX+'evidence-final.json')
sha=lambda b:hashlib.sha256(b).hexdigest()
encode=lambda b:base64.b64encode(b).decode()
decode=lambda s:base64.b64decode(s,validate=True)
dump=lambda x:(json.dumps(x,indent=2)+'\n').encode()
pack=lambda x:gzip.compress(json.dumps(x,sort_keys=True,separators=(',',':')).encode(),mtime=0)
assert sys.argv[1:] in ([],['--capture'])
if not sys.argv[1:]:
    r=json.loads(TARGET.read_bytes());assert r['result']=='PASS' and r['producer_sha256']==sha(Path(__file__).read_bytes())
    for p,i in r['inputs'].items():
        assert sha((ROOT/p).read_bytes())==i['sha256'] and stat.S_IMODE((ROOT/p).stat().st_mode)==i['mode'], ('original evidence input',p)
    data=(ROOT/(PREFIX+'evidence-final-data.json.gz')).read_bytes();assert sha(data)==r['data_sha256']
    rows=json.loads(gzip.decompress(data));assert len(rows)==7 and r['rows']==[{k:x[k] for k in ['name','reason']} for x in rows]
    for x in rows:
        assert x['denial']['returncode']!=0 and x['reason'].encode() in decode(x['denial']['stderr_base64'])
        assert x['restoration']['returncode']==0 and not decode(x['restoration']['stderr_base64'])
        assert x['mutations'] and all(sha(decode(i['bytes_base64']))==i['sha256'] for i in x['mutations'].values())
    print('ControlFlow expansion artifacts PASS: seven coherent deeper denials and exact source restorations')
    raise SystemExit(0)
assert not TARGET.exists()
paths={p.relative_to(ROOT).as_posix() for p in (ROOT/PREFIX).iterdir() if p.is_file() and p.name not in ['evidence.json','evidence-data.json.gz','compat.json','publish.py','review.json','review.json']}
for name in ['after-native-inputs.json.gz','consumers-inputs.json.gz']:
    paths.update(json.loads(gzip.decompress((ROOT/(PREFIX+name)).read_bytes())))
k=json.loads(gzip.decompress((ROOT/(PREFIX+'knowledge-inputs.json.gz')).read_bytes()))
paths.update(p for p in k['current'] if p not in k['original'])
paths.update(json.loads((ROOT/(PREFIX+'knowledge.json')).read_bytes())['changed_cards'])
paths.update(json.loads((ROOT/(PREFIX+'book-review-final.json')).read_bytes())['source_inputs'])
paths.update(json.loads((ROOT/(PREFIX+'validation.json')).read_bytes())['sources'])
paths.update(PREFIX+'repair01/'+n for n in ('capture.py','capture.json','inputs.json.gz'))
paths.update(['docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-match-alias.py','docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-match-alias.json','t/perl_match_alias_writability_probe.pl','docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.0.json','doctrine/readme_stability/routes.jsonl'])
# compat.json is deliberately excluded: preflight does not read supplemental
# standard evidence. Full review owns its independently completed final record.
identities={p:{'sha256':sha((ROOT/p).read_bytes()),'mode':stat.S_IMODE((ROOT/p).stat().st_mode)} for p in sorted(paths)}
files={p:(ROOT/p).read_bytes() for p in identities};rows=[]
with tempfile.TemporaryDirectory(prefix='control-expansion-evidence-',dir=os.environ['TMPDIR']) as directory:
    root=Path(directory);assert root.stat().st_dev==ROOT.stat().st_dev
    for p,b in files.items():
        dest=root/p;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(b);dest.chmod(identities[p]['mode'])
    env=dict(os.environ,GIT_DIR=str(ROOT/'.git'),GIT_WORK_TREE=str(root))
    def check():
        cmd=['python3',PREFIX+'review-final.py','--preflight']
        p=subprocess.run(cmd,cwd=root,env=env,capture_output=True)
        return {'command':cmd,'returncode':p.returncode,'stdout_base64':encode(p.stdout),'stderr_base64':encode(p.stderr)}
    baseline=check();assert baseline['returncode']==0 and not decode(baseline['stderr_base64']),baseline
    def exercise(name,reason,changed):
        for p,b in changed.items():
            dest=root/p;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(b)
        denial=check()
        try:assert denial['returncode']!=0 and reason.encode() in decode(denial['stderr_base64']),(name,denial)
        finally:
            for p in changed:
                if p in files:(root/p).write_bytes(files[p]);(root/p).chmod(identities[p]['mode'])
                else:(root/p).unlink()
        restoration=check()
        rows.append({'name':name,'reason':reason,'denial':denial,'restoration':restoration,'mutations':{p:{'sha256':sha(b),'bytes_base64':encode(b)} for p,b in changed.items()}})
        (ROOT/(PREFIX+'evidence-final-data.json.gz')).write_bytes(pack(rows))
        assert restoration['returncode']==0 and not decode(restoration['stderr_base64']),('exact restoration',name)
    data=json.loads(gzip.decompress(files[PREFIX+'after-native-data.json.gz']))
    for index in [1,2]:
        selected=next(r for r in data[index]['observation']['rows'] if r['label']=='authority/expand/split_action_ir_statements/1/scalar')
        assert selected['authority']['parent_packet']==0
        selected['authority']['parent_packet']=1
        data[index]['stdout_base64']=encode((json.dumps(data[index]['observation'],sort_keys=True,separators=(',',':'))+'\n').encode())
    b=pack(data);meta=json.loads(files[PREFIX+'after-native.json']);meta['data_sha256']=sha(b)
    exercise('coherent-parent-donation','no enclosing packet donation',{PREFIX+'after-native-data.json.gz':b,PREFIX+'after-native.json':dump(meta)})
    data=json.loads(gzip.decompress(files[PREFIX+'faults-data.json.gz']))
    inverse=data[0];inverse['failures'].pop(0)
    ch=inverse['channels'][1];ch['stdout_base64']=encode(decode(ch['stdout_base64']).replace(b'not ok ',b'ok ',1))
    b=pack(data);meta=json.loads(files[PREFIX+'faults.json']);meta['data_sha256']=sha(b);meta['variants'][0]['failures']=81
    exercise('hidden-original-inverse','exact inverse original82',{PREFIX+'faults-data.json.gz':b,PREFIX+'faults-reached.json.gz':b,PREFIX+'faults.json':dump(meta)})
    p=PREFIX+'before-PERL-PRIVATE-FACTORY-CAPTURE.5.0.json';data=json.loads(files[p])
    data['claims'][0]['statement']='X'+data['claims'][0]['statement'][1:]
    b=dump(data);meta=json.loads(files[PREFIX+'preservation.json']);meta['selected'][0].update(sha256=sha(b),bytes=len(b))
    exercise('whole-accepted-publication','whole accepted publication custody',{p:b,PREFIX+'preservation.json':dump(meta)})
    data=json.loads(gzip.decompress(files[PREFIX+'consumers-channels.json.gz']));out=decode(data['stdout_base64'])
    match=re.search(rb'^([^\s]+\.t)[ \t]+\.{2,}[ \t]*$',out,re.M);assert match
    data['stdout_base64']=encode(out[:match.start(1)]+b'forged.t'+out[match.end(1):]);b=pack(data)
    meta=json.loads(files[PREFIX+'consumers.json']);meta['channels_sha256']=sha(b)
    exercise('forged-consumer-header','complete accepted consumer command/header population',{PREFIX+'consumers-channels.json.gz':b,PREFIX+'consumers.json':dump(meta)})
    envelope=json.loads(files[PREFIX+'book-final.json']);data=json.loads(gzip.decompress(decode(envelope['data'])))
    row=data['rows'][0];row['target_html_base64']=encode(decode(row['target_html_base64']).replace(b'ControlFlow branch expansion dependencies',b''));row['target_marker_present']=False
    b=dump(data);envelope.update(bytes=len(b),sha256=sha(b),data=encode(gzip.compress(b,mtime=0)))
    exercise('missing-rendered-default-teaching','wrong ControlFlow expansion rendered teaching oracle',{PREFIX+'book-final.json':dump(envelope)})
    envelope=json.loads(files[PREFIX+'book-final.json']);data=json.loads(gzip.decompress(decode(envelope['data'])))
    row=data['rows'][0];html=decode(row['target_html_base64']);assert b'undefined/empty trim result' in html
    row['target_html_base64']=encode(html.replace(b'undefined/empty trim result',b'whitespace input',1))
    b=dump(data);envelope.update(bytes=len(b),sha256=sha(b),data=encode(gzip.compress(b,mtime=0)))
    exercise('coherent-wrong-whitespace-teaching','wrong whitespace teaching oracle',{PREFIX+'book-final.json':dump(envelope)})
    data=json.loads(gzip.decompress(files[PREFIX+'after-native-inputs.json.gz']))
    source='perl/LinkedSpec/ActionIR/ControlFlow.pm';substitute='perl/LinkedSpec/ActionIR/ControlFlow.shadow.pm';item=data.pop(source);data[substitute]=item;b=pack(data)
    meta=json.loads(files[PREFIX+'after-native.json']);meta['inputs'][substitute]=meta['inputs'].pop(source);meta['capsule_sha256']=sha(b)
    exercise('same-bytes-wrong-runtime-path','complete native runtime namespace',{PREFIX+'after-native-inputs.json.gz':b,PREFIX+'after-native.json':dump(meta),substitute:decode(item['bytes_base64'])})
    for p,i in identities.items():assert sha((root/p).read_bytes())==i['sha256'] and stat.S_IMODE((root/p).stat().st_mode)==i['mode'], ('exact declared source restoration',p)
    extras=[p.relative_to(root).as_posix() for p in root.rglob('*') if p.is_file() and p.relative_to(root).as_posix() not in identities]
    assert all(p.startswith('.linkedspec-data/') for p in extras), ('only managed wrapper outputs are allowed',extras)
assert all((ROOT/p).read_bytes()==b for p,b in files.items()), 'live source bytes unchanged'
r={'result':'PASS','producer_sha256':sha(Path(__file__).read_bytes()),'inputs':identities,'data_sha256':sha((ROOT/(PREFIX+'evidence-final-data.json.gz')).read_bytes()),'baseline':baseline,'rows':[{k:x[k] for k in ['name','reason']} for x in rows],'managed_wrapper_outputs':extras,'scope':'Six actual semantic artifact denials after coherent immediate rehashes, complete declared supplied source bytes/modes and exact restorations. Read only owning Git objects/index through GIT_DIR/GIT_WORK_TREE; create no Git repository. Complete mutations and raw denial/restoration channels are retained. Wrappers may create only managed same-volume project-data outputs; live sources remain unchanged. Supplemental compat.json is not read by preflight and is deliberately outside this inventory; full review independently owns the completed standard record. No new runtime observation or broad admission.'}
TARGET.write_bytes(dump(r))
print('ControlFlow expansion artifacts PASS: seven coherent deeper denials and exact source restorations')
