"""Independently check complete actual direct-consumer reach and failed selection."""
from pathlib import Path
import copy
import base64
import gzip
import importlib.util
import json
import re

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('consumer-review.py')
spec = importlib.util.spec_from_file_location('oracle',PREFIX+'review.py')
oracle = importlib.util.module_from_spec(spec);spec.loader.exec_module(oracle)
PLAN = ['t/actionir_helper_source_provenance.t','t/actionir_basic_regex_source_provenance.t','t/actionir_ast_parser.t','t/actionir_raw_dependency_provenance.t']


def tap(row):
    text = oracle.decode(row['stdout']).decode()
    oracle.decode(row['stderr'])
    assert row['exit'] == 0, 'consumer exit'
    assert not re.search(r'^\s*(?:not ok\b|Bail out!)',text,re.M), 'failing TAP'
    plans = re.findall(r'^1\.\.(\d+)\s*$',text,re.M)
    assert len(plans) == 1 and int(plans[0]) > 0, 'positive complete TAP plan'
    count = int(plans[0])
    reached = [int(n) for n in re.findall(r'^ok (\d+)\b',text,re.M)]
    assert reached == list(range(1,count+1)), 'ordered complete TAP reach'
    assert 'All tests successful.' in text and 'Result: PASS' in text, 'prove final markers'
    return count


def check(report,inputs):
    assert report['complete'] is True and report['revision'] == oracle.REVISION, 'complete consumer boundary'
    assert report['instrument_sha256'] == oracle.digest(Path(PREFIX+'consumers.py').read_bytes()), 'actual consumer instrument'
    assert [r['command'] for r in report['runs']] == [['bash','tools/project_data_run.sh','prove','-v','-Iperl',suite] for suite in PLAN], 'exact consumer selection'
    assert all(r['inputs_before'] == r['inputs_after'] == len(inputs['entries']) for r in report['runs']), 'consumer input guards'
    return [tap(r) for r in report['runs']]


inputs = json.loads(Path(PREFIX+'inputs.json').read_bytes())
report = json.loads(Path(PREFIX+'consumers.json').read_bytes())
counts = check(report,inputs)
failed = json.loads(Path(PREFIX+'consumers-initial.json').read_bytes())
assert failed['complete'] is False and len(failed['runs']) == 3, 'preserved failed selection'
assert failed['instrument_sha256'] == oracle.digest(Path(PREFIX+'consumers-initial.py').read_bytes()), 'actual failed instrument'
assert [tap(r) for r in failed['runs'][:2]] == counts[:2], 'actual earlier passing selection'
last = failed['runs'][-1]
assert last['command'][-1] == 't/actionir_ast_contracts.t' and last['exit'] == 2, 'actual missing suite'
assert oracle.decode(last['stdout']) == b'', 'actual failed stdout'
assert b'Cannot detect source' in oracle.decode(last['stderr']) and b't/actionir_ast_contracts.t' in oracle.decode(last['stderr']), 'actual selection failure reason'
def change_tap(report, transform):
    raw = transform(oracle.decode(report['runs'][0]['stdout']).decode()).encode()
    report['runs'][0]['stdout'] = {'encoding':'gzip-base64','bytes':len(raw),'sha256':oracle.digest(raw),'data':base64.b64encode(gzip.compress(raw,mtime=0)).decode()}


controls = []
for name, change, reason in [
 ('drop suite',lambda d:d['runs'].pop(),'exact consumer selection'),
 ('promote partial',lambda d:d.update(complete=False),'complete consumer boundary'),
 ('forge producer',lambda d:d.update(instrument_sha256='0'*64),'actual consumer instrument'),
 ('omit input guard',lambda d:d['runs'][0].update(inputs_after=0),'consumer input guards'),
 ('forge exit',lambda d:d['runs'][0].update(exit=1),'consumer exit'),
 ('forge channel',lambda d:d['runs'][0]['stdout'].update(sha256='0'*64),'channel bytes'),
 ('failed nested TAP',lambda d:change_tap(d,lambda t:re.sub(r'^(\s*)ok ',r'\1not ok ',t,count=1,flags=re.M)),'failing TAP'),
 ('truncate top-level reach',lambda d:change_tap(d,lambda t:re.sub(r'^ok 1\b[^\n]*\n','',t,count=1,flags=re.M)),'ordered complete TAP reach'),
 ('erase prove completion',lambda d:change_tap(d,lambda t:t.replace('Result: PASS','Result: UNKNOWN')),'prove final markers'),
]:
    altered = copy.deepcopy(report);change(altered)
    try:
        check(altered,inputs)
    except AssertionError as error:
        assert str(error) == reason,(name,str(error),reason)
        controls.append({'name':name,'rejected':True,'reason':reason})
    else:
        raise AssertionError('accepted corruption: '+name)
result = {'revision':oracle.REVISION,'suites':len(counts),'plans':dict(zip(PLAN,counts)),'top_level_tests':sum(counts),'controls':controls,'failed_selection_preserved':True,'instrument_sha256':oracle.digest(Path(__file__).read_bytes())}
Path(PREFIX+'consumer-verification.json').write_text(json.dumps(result,indent=2)+'\n')
print(result['plans']);print(str(sum(counts))+' complete groups; '+str(len(controls))+' reason-checked RED controls')
