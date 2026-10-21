"""Retain pre-closure reader bytes before requiring the fresh pressure epoch."""
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c


def main():
    paths=[c.PREFIX+'admission/portable/verify.py',c.PREFIX+'publish_portable.py']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    path=paths[0]
    after[path]=after[path].replace('import json\n','import json\nimport re\n',1)
    needle="    return dict(third_inputs=10540,third_staged_images=10543,third_readonly_exit=0,"
    assert after[path].count(needle)==1
    addition='''    pressure_bytes=None
    if require_documents:
        pressure=c.load('admission/portable/pressure-run.json.gz')
        assert pressure['producer']==c.read(c.PREFIX+'admission/portable/pressure.py')
        assert pressure['inputs_unchanged'] and pressure['run']['returncode']==0
        report=c.decode(pressure['run']['stdout_base64'])
        match=re.search(rb'surface knowledge_cards files=(\\d+) lines=(\\d+) bytes=(\\d+)',report)
        assert match and int(match[1])==1350 and int(match[3])<=8388608
        pressure_bytes=int(match[3])
        assert pressure_bytes==sum(path.stat().st_size for path in (ROOT/'docs/knowledge').glob('*.md'))
        assert b'surface public_reference files=61 lines=49836 ' in report
        recover(c.load('admission/portable/pressure-inputs.json.gz'))
'''
    after[path]=after[path].replace(needle,addition+needle,1)
    after[path]=after[path].replace('physical_input_max_bytes=maximum,documents_closed=documents.exists())',
        'physical_input_max_bytes=maximum,documents_closed=documents.exists(),current_pressure_knowledge_bytes=pressure_bytes)',1)
    path=paths[1]
    needle="    claim['rederive']['result']+='all prior source epochs retained and generated backup residue0.'"
    assert after[path].count(needle)==1
    after[path]=after[path].replace(needle,needle+"\n    claim['rederive']['result']+=' Fresh portability pressure passes20 surfaces/62 routes/40 controls; current knowledge bytes'\n    claim['rederive']['result']+=str(result['portable']['current_pressure_knowledge_bytes'])+'/8388608. Earlier pressure figures retain their measured source epochs.'",1)
    for path,text in after.items():compile(text,path,'exec')
    c.write_new('admission/portable/reader-closure.json.gz',dict(before=before,
        after={path:c.encode(text.encode()) for path,text in after.items()},
        producer=c.read(c.PREFIX+'admission/portable/finish_reader.py'),
        scope='Retain the actual reader/provider versions used for pre-closure finalizer proof. '
              'Final default/capture additionally require the distinct fresh portability pressure '
              'epoch. Original reports remain historical and no observation is refreshed.'))
    for path,text in after.items():(ROOT/path).write_text(text)
    print('Final pressure reader bound; pre-closure versions retained whole')


if __name__=='__main__':main()
