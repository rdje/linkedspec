"""Verify the complete second source epoch and the lossless fact consolidation."""
import gzip
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c


def check():
    saved=c.load('admission/collection/second.json.gz')
    assert saved['base']==c.BASE and len(saved['inputs'])==10522 and len(saved['images'])==10525
    assert saved['producer']==c.read(c.PREFIX+'admission/collection/preserve.py')
    assert json.loads(c.decode(saved['publication']['base64']))['record_base64']==saved['claim']['base64']
    assert json.loads(gzip.decompress(c.decode(saved['manifest']['base64'])))['inputs']==saved['inputs']
    assert c.decode(saved['readonly']['status']['base64']).strip()==b'0'
    assert b'10522 closed inputs;214/106 RED/7 faults;14/1948;book89/3' in c.decode(saved['readonly']['log']['base64'])
    assert c.decode(saved['canonical']['status']['base64']).strip()==b'143'
    assert b'surface knowledge_cards exceeds control: files 1351/1350' in c.decode(saved['canonical']['log']['base64'])
    assert saved['absence']['returncode']==1 and not c.decode(saved['absence']['stdout_base64'])
    base={}
    for row in subprocess.check_output(['git','ls-tree','-rz',c.BASE],cwd=ROOT).split(b'\0'):
        if row:
            metadata,name=row.split(b'\t',1);mode,kind,oid=metadata.decode().split()
            base[name.decode()]=dict(mode=mode,kind=kind,oid=oid)
    for path,image in saved['images'].items():
        identity={key:image[key] for key in ('sha256','mode')}
        if path in saved['before']:
            packet=saved['before'][path]
            assert c.sha(c.decode(packet['base64']))==packet['sha256']==image['sha256']
            assert packet['mode']==image['mode']
        elif base.get(path)!=image['git']:assert c.identity(path)==identity,path
        if path in saved['inputs']:assert saved['inputs'][path]==identity
    verified=saved['git_verification']
    assert verified['returncode']==0 and not c.decode(verified['stderr_base64'])
    assert c.decode(verified['stdout_base64']).decode().splitlines()==[
        saved['images'][path]['git']['oid'] for path in sorted(saved['images'])]
    merged=c.load('admission/collection/merge.json.gz')
    assert merged['producer']==c.read(c.PREFIX+'admission/collection/merge.py')
    assert not (ROOT/merged['removed']).exists()
    old=c.decode(merged['before'][merged['removed']]['base64']).decode()
    fact='docs/knowledge/terse-type-method-surface-inventory.md'
    current=(ROOT/fact).read_text()
    assert old.split('\n---\n',1)[1].strip() in current
    for question in re.findall(r'^  - (".*")$',old,re.M):assert '  - '+question+'\n' in current
    repack=c.load('admission/collection/repack.json.gz')
    assert repack['producer']==c.read(c.PREFIX+'admission/collection/repack.py')
    portable=c.load('admission/portable/prepare.json.gz')
    assert portable['before'][c.PREFIX+'context.py']['base64']==repack['after'][c.PREFIX+'context.py']
    final_path=ROOT/(c.PREFIX+'admission/portable/final-docs.json.gz')
    documents=c.load('admission/portable/final-docs.json.gz') if final_path.exists() else None
    def expected(path):
        value=repack['after'][path]
        if path in portable['after']:
            assert portable['before'][path]['base64']==value
            value=portable['after'][path]
        if documents is not None and path in documents['after']:
            assert documents['before'][path]['base64']==value
            value=documents['after'][path]
        return c.decode(value)
    assert current.encode()==expected(fact)
    assert repack['duplication_red']==dict(rejected=True,message='Immutable gzip inputs must not be embedded in future overrides')
    assert repack['duplicated_gzip_inputs']==114
    for path in ('DEVELOPMENT_NOTES.md','docs/history/development-notes/manifest.jsonl',c.PREFIX+'context.py'):
        assert (ROOT/path).read_bytes()==expected(path)
    assert not (ROOT/repack['removed']).exists()
    rejected=c.load('admission/collection/pressure-after.json.gz')
    assert rejected['producer']==c.read(c.PREFIX+'admission/collection/pressure.py')
    assert rejected['inputs_unchanged'] and rejected['run']['returncode']!=0
    assert b'engineering_notes current hot shard reached the mandatory 90% rollover boundary' in c.decode(rejected['run']['stderr_base64'])
    provisional=c.load('admission/collection/pressure-final-after.json.gz')
    assert provisional['producer']==c.read(c.PREFIX+'admission/collection/pressure_final.py')
    assert provisional['inputs_unchanged'] and provisional['run']['returncode']!=0
    assert b'surface engineering_notes exceeds control: files 49/48' in c.decode(provisional['run']['stderr_base64'])
    pressure=c.load('admission/collection/pressure-admit-after.json.gz')
    assert pressure['producer']==c.read(c.PREFIX+'admission/collection/pressure_admit.py')
    assert pressure['inputs_unchanged'] and pressure['run']['returncode']==0
    report=c.decode(pressure['run']['stdout_base64'])
    match=re.search(rb'surface knowledge_cards files=(\d+) lines=(\d+) bytes=(\d+)',report)
    assert match and int(match[1])==1350 and int(match[3])<=8388608
    assert b'surface public_reference files=61 lines=49836 ' in report
    for stem in ('pressure','pressure-final','pressure-admit'):
        snapshot=c.load('admission/collection/'+stem+'-inputs.json.gz')
        assert snapshot['base']==c.BASE
        for path,item in snapshot['inputs'].items():
            packet=snapshot.get('new_inputs',{}).get(path) or snapshot.get('overrides',{}).get(path)
            if packet is not None:
                assert c.sha(c.decode(packet['base64']))==packet['sha256']==item['sha256']
                assert packet['mode']==item['mode']
            elif c.identity(path)!=item:
                raw=subprocess.check_output(['git','show',c.BASE+':'+path],cwd=ROOT)
                assert c.sha(raw)==item['sha256'],path
    final=c.load('admission/collection/pressure-admit-inputs.json.gz')
    assert final['loaded_context_path']==c.PREFIX+'context.py'
    historical_context=final['loaded_context']
    assert historical_context['base64']==repack['after'][c.PREFIX+'context.py']
    assert c.sha(c.decode(historical_context['base64']))==historical_context['sha256']
    assert historical_context['mode']==repack['before'][c.PREFIX+'context.py']['mode']
    assert not any(path.endswith('.gz') for path in final['overrides'])
    old=c.load('admission/collection/pressure-inputs.json.gz')
    assert old['overrides'][c.PREFIX+'context.py']==repack['before'][c.PREFIX+'context.py']
    copies={path:packet for path,packet in old['overrides'].items() if path.endswith('.gz')}
    assert len(copies)==114
    for path,packet in copies.items():
        assert c.sha(c.decode(packet['base64']))==packet['sha256']==old['inputs'][path]['sha256']
        assert {key:packet[key] for key in ('sha256','mode')}==final['inputs'][path]==c.identity(path)
    return dict(second_inputs=10522,second_staged_images=10525,readonly_exit=0,
        failed_canonical_joined=143,knowledge_files=int(match[1]),knowledge_bytes=int(match[3]),
        public_reference_lines=49836,complete_finding_and_questions_preserved=True,
        observed_old_gzip_copies=114,current_gzip_overrides=0,
        admitted_snapshot_bytes=(ROOT/(c.PREFIX+'admission/collection/pressure-admit-inputs.json.gz')).stat().st_size)


if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
