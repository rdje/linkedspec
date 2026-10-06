"""Independently review the actual-root gate and precise mode-instrument correction."""
from pathlib import Path
import copy,importlib.util,json
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('component-review.py')
spec=importlib.util.spec_from_file_location('progressive_review',PREFIX+'review.py')
review=importlib.util.module_from_spec(spec);spec.loader.exec_module(review)
sha,decode=review.sha,review.decode
inputs=json.loads(Path(PREFIX+'component-inputs.json').read_bytes())
report=json.loads(Path(PREFIX+'component.json').read_bytes())
baseline=json.loads(Path(PREFIX+'before-inputs.json').read_bytes())
repair=json.loads(Path(PREFIX+'component-mode-repair.json').read_bytes())
review.check_component(report,inputs,baseline)
def check(value):
    assert value['instrument_sha256']==sha(Path(PREFIX+'component-mode-repair.py').read_bytes()), 'actual mode-repair producer'
    original=Path(PREFIX+'component-rejected-producer.py').read_bytes()
    current=Path(PREFIX+'component.py').read_bytes()
    assert value['before_sha256']==sha(original) and value['after_sha256']==sha(current), 'mode-repair producer identities'
    fixed=original.replace(b"    assert mode==int(original['mode'][-3:],8), 'original input mode'\n",b'')
    fixed=fixed.replace(b"row={'path':path,'mode':original['mode'],'oid':original['oid']",b"row={'path':path,'mode':original['mode'],'filesystem_mode':mode,'oid':original['oid']")
    fixed=fixed.replace(b"stat.S_IMODE(path.stat().st_mode)==int(item['mode'][-3:],8)",b"stat.S_IMODE(path.stat().st_mode)==item['filesystem_mode']")
    assert fixed==current and fixed!=original, 'exact three mode-recording guard edits'
    wanted=[{'path':e['path'],'git_mode':e['mode'],'filesystem_mode':e['filesystem_mode'],
             'executable_drift':bool(e['filesystem_mode']&0o111)!=bool(int(e['mode'][-3:],8)&0o111)}
            for e in inputs['entries'] if e['filesystem_mode']!=int(e['mode'][-3:],8)]
    assert len(wanted)==36 and value['mode_differences']==wanted and not any(e['executable_drift'] for e in wanted), 'independent complete actual-root mode census'
    assert value['command']==['bash','tools/run_python_project_data.sh',Path(PREFIX+'component.py').relative_to(ROOT).as_posix()], 'actual rejected producer command'
    assert value['exit']==1 and decode(value['stdout'])==b'' and b'AssertionError: original input mode' in decode(value['stderr']), 'actual original capture-instrument RED'
check(repair)
controls=[]
for name,mutation,reason in [
    ('omitted mode difference',lambda v:v['mode_differences'].pop(),'independent complete actual-root mode census'),
    ('forged old producer',lambda v:v.update(before_sha256='0'*64),'mode-repair producer identities'),
    ('hidden original instrument RED',lambda v:v.update(exit=0),'actual original capture-instrument RED'),
    ('forged repair producer',lambda v:v.update(instrument_sha256='0'*64),'actual mode-repair producer')]:
    bad=copy.deepcopy(repair);mutation(bad);assert bad!=repair
    try:check(bad)
    except AssertionError as error:
        assert str(error)==reason,(name,str(error),reason)
        controls.append({'name':name,'observed':'RED','reason':reason})
    else:raise AssertionError('accepted corruption: '+name)
result={'complete':True,'revision':review.REVISION,'actual_root_inputs':len(inputs['entries']),
        'byte_deltas':sum('actual_root_delta' in e for e in inputs['entries']),'mode_differences':len(repair['mode_differences']),
        'original_instrument_exit':repair['exit'],'component_exit':report['exit'],'controls':controls,
        'instrument_sha256':sha(Path(__file__).read_bytes()),'review_producer_sha256':sha(Path(PREFIX+'review.py').read_bytes()),
        'scope':'Actual-root component guard/input recovery and exact mode-instrument repair; changing filesystem permissions are a dated observation, not a repository defect or permission policy. Four effective evidence RED preserve the actual before/after producer and complete census.'}
Path(PREFIX+'component-verification.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
