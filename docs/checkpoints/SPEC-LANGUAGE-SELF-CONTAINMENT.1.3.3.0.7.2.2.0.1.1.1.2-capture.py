"""Run source-fixed before/after frame tests and Toolbox inspection channels."""
from pathlib import Path
import argparse
import importlib.util
import json
import os
import stat
import subprocess
import tempfile

ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('capture.py')
REVISION='aef9e551c7e563985c79c53fcba574ee5df8d509'
PREVIOUS='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-'
spec=importlib.util.spec_from_file_location('streams',ROOT/(PREVIOUS+'capture.py'))
streams=importlib.util.module_from_spec(spec);spec.loader.exec_module(streams)
SOURCES=['perl/LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm','perl/LinkedSpec/ActionIR/ScannerCore.pm']
TEST='t/actionir_basic_statement_source_provenance.t'
PROBE=Path(PREFIX+'probe.pl').relative_to(ROOT).as_posix()


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--mode',choices=('before','after'),required=True);args=parser.parse_args()
    rows=subprocess.check_output(['git','ls-tree','-rlz',REVISION],cwd=ROOT)
    entries,excluded=[],[]
    for row in filter(None,rows.split(b'\0')):
        meta,path=row.split(b'\t',1);mode,kind,oid,size=meta.split()
        if kind!=b'blob' or mode not in (b'100644',b'100755'):
            excluded.append({'path':path.decode(),'mode':mode.decode(),'kind':kind.decode()});continue
        entries.append({'path':path.decode(),'mode':mode.decode(),'oid':oid.decode(),'bytes':int(size)})
    scratch=ROOT/'.linkedspec-data/scratch/basic-statement-provenance';scratch.mkdir(parents=True,exist_ok=True)
    tree=Path(tempfile.mkdtemp(prefix=args.mode+'-frames-',dir=scratch));assert tree.stat().st_dev==ROOT.stat().st_dev
    process=subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
    try:
        for entry in entries:
            process.stdin.write((entry['oid']+'\n').encode());process.stdin.flush()
            assert process.stdout.readline().split()==[entry['oid'].encode(),b'blob',str(entry['bytes']).encode()]
            raw=process.stdout.read(entry['bytes']);assert process.stdout.read(1)==b'\n'
            target=tree/entry['path'];target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(raw);target.chmod(int(entry['mode'][-3:],8))
            entry['sha256']=streams.sha(raw)
    finally:
        process.stdin.close();process.stdout.close();assert process.wait()==0
    overlays=[TEST,PROBE]+(SOURCES if args.mode=='after' else [])
    for path in overlays:
        raw=(ROOT/path).read_bytes();target=tree/path;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(raw);target.chmod(0o644)
        old=next((e for e in entries if e['path']==path),None)
        if old:
            entries.remove(old)
        entry={'path':path,'mode':'100644','bytes':len(raw),'sha256':streams.sha(raw),'overlay':True}
        if old:entry['original_git_input']=old
        entries.append(entry)
    manifest={'revision':REVISION,'mode':args.mode,'entries':entries,'excluded_metadata':excluded,
              'scope':'Conservative complete regular parent Git source superset. Exact test/probe overlays in both runs; only PrimitiveBasicRules/ScannerCore production overlays after. Gitlinks/non-regular metadata excluded without payload reads.'}
    Path(PREFIX+args.mode+'-inputs.json').write_text(json.dumps(manifest,indent=2)+'\n')
    report={'revision':REVISION,'mode':args.mode,'input_tree':tree.relative_to(ROOT).as_posix(),'complete':False,'runs':[],
            'instrument_sha256':streams.sha(Path(__file__).read_bytes()),'stream_instrument_sha256':streams.sha((ROOT/(PREVIOUS+'capture.py')).read_bytes())}
    env={k:v for k,v in os.environ.items() if k not in {'TMPDIR','TMP','TEMP','CARGO_HOME','CARGO_TARGET_DIR','PUB_CACHE','JULIA_DEPOT_PATH','PYTHONPYCACHEPREFIX','MDBOOK_BUILD__BUILD_DIR'} and not k.startswith('LINKEDSPEC_')}
    env.update(PERL5LIB='',PERL5OPT='',PERL_HASH_SEED='0',PERL_PERTURB_KEYS='2')
    commands=[('fixture',0,['prove','-v','-Iperl',TEST])]+[('toolbox',seed,['perl','-Iperl',PROBE]) for seed in (0,1,42)]
    for kind,seed,tail in commands:
        env['PERL_HASH_SEED']=str(seed)
        before=streams.verify_tree(tree,entries)
        command=['bash','tools/project_data_run.sh']+tail
        result=subprocess.run(command,cwd=tree,env=env,capture_output=True)
        row={'kind':kind,'seed':seed,'command':command,'exit':result.returncode,'stdout':streams.envelope(result.stdout),'stderr':streams.envelope(result.stderr),'inputs_before':before}
        report['runs'].append(row);Path(PREFIX+args.mode+'.json').write_text(json.dumps(report,indent=2)+'\n')
        row['inputs_after']=streams.verify_tree(tree,entries)
        Path(PREFIX+args.mode+'.json').write_text(json.dumps(report,indent=2)+'\n')
        if kind=='toolbox':assert result.returncode==0 and len(json.loads(result.stdout)['rows'])==22
        else:assert (result.returncode==0) if args.mode=='after' else (result.returncode!=0)
        print(args.mode+' '+kind+' seed'+str(seed)+' actual exit'+str(result.returncode),flush=True)
    assert report['instrument_sha256']==streams.sha(Path(__file__).read_bytes())
    report['complete']=True;Path(PREFIX+args.mode+'.json').write_text(json.dumps(report,indent=2)+'\n')


if __name__=='__main__':main()
