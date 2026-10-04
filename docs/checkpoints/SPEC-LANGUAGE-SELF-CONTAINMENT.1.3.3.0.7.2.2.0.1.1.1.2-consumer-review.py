"""Check full unchanged-consumer TAP at the fixed after-source boundary."""
from pathlib import Path
import copy
import importlib.util
import json
import re

ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('consumer-review.py')
spec=importlib.util.spec_from_file_location('review',PREFIX+'review.py')
review=importlib.util.module_from_spec(spec);spec.loader.exec_module(review)
author=review.author
PLAN=['t/phase0_regression.t','t/actionir_helper_source_provenance.t','t/actionir_basic_regex_source_provenance.t','t/actionir_ast_parser.t','t/actionir_raw_dependency_provenance.t','t/actionir_nested_block_source_spans.t','t/actionir_raw_dependency_compatibility.t','t/canonical_event_occurrence_order.t']


def check(report,manifest):
    assert report['revision']==review.REVISION and report['complete'] is True, 'complete exact consumer boundary'
    assert report['instrument_sha256']==author.digest(Path(PREFIX+'guarded-consumers.py').read_bytes()), 'actual consumer instrument'
    assert report['input_manifest_sha256']==author.digest(Path(PREFIX+'after-inputs.json').read_bytes()), 'actual consumer input manifest'
    assert report['observations_sha256']==author.digest(Path(PREFIX+'after.json').read_bytes()), 'actual consumer source observations'
    assert report['input_tree']==json.loads(Path(PREFIX+'after.json').read_bytes())['input_tree'], 'actual consumer input tree'
    assert report['stream_instrument_sha256']==author.digest((ROOT/'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py').read_bytes()), 'actual consumer stream instrument'
    assert [r['command'] for r in report['runs']]==[['bash','tools/project_data_run.sh','prove','-v','-Iperl',test] for test in PLAN], 'exact consumer population'
    counts=[]
    for row in report['runs']:
        assert row['inputs_before']==row['inputs_after']==len(manifest['entries']), 'consumer input guards'
        assert row['exit']==0, 'actual consumer exit'
        text=author.decode(row['stdout']).decode();author.decode(row['stderr'])
        assert not re.search(r'^\s*(?:not ok\b|Bail out!)',text,re.M), 'actual failing TAP'
        plans=re.findall(r'^1\.\.(\d+)\s*$',text,re.M)
        assert len(plans)==1 and int(plans[0])>0, 'complete positive TAP plan'
        count=int(plans[0])
        reached=[int(n) for n in re.findall(r'^ok (\d+)\b',text,re.M)]
        assert reached==list(range(1,count+1)), 'complete ordered TAP reach'
        assert 'All tests successful.' in text and 'Result: PASS' in text, 'prove final completion'
        counts.append(count)
    return counts


report=json.loads(Path(PREFIX+'guarded-consumers.json').read_bytes())
manifest=json.loads(Path(PREFIX+'after-inputs.json').read_bytes())
review.manifest_check(manifest)
counts=check(report,manifest)
controls=[]
for name,change,reason in [('omit suite',lambda d:d['runs'].pop(),'exact consumer population'),
                           ('promote partial',lambda d:d.update(complete=False),'complete exact consumer boundary'),
                           ('forge producer',lambda d:d.update(instrument_sha256='0'*64),'actual consumer instrument'),
                           ('forge source manifest',lambda d:d.update(input_manifest_sha256='0'*64),'actual consumer input manifest'),
                           ('forge source tree',lambda d:d.update(input_tree='wrong'),'actual consumer input tree'),
                           ('erase guard',lambda d:d['runs'][0].update(inputs_after=0),'consumer input guards'),
                           ('forge actual exit',lambda d:d['runs'][0].update(exit=1),'actual consumer exit'),
                           ('forge actual stream',lambda d:d['runs'][0]['stdout'].update(sha256='0'*64),'channel bytes')]:
    altered=copy.deepcopy(report);change(altered)
    try:check(altered,manifest)
    except AssertionError as error:
        assert str(error)==reason,(name,str(error),reason)
        controls.append({'name':name,'rejected':True,'reason':reason})
    else:raise AssertionError('accepted corruption: '+name)
result={'revision':review.REVISION,'suites':len(PLAN),'top_level_tests':sum(counts),'plans':dict(zip(PLAN,counts)),
        'controls':controls,'instrument_sha256':author.digest(Path(__file__).read_bytes())}
Path(PREFIX+'consumer-verification.json').write_text(json.dumps(result,indent=2)+'\n')
print(result['plans']);print(str(sum(counts))+' complete groups; eight reason-checked RED controls')
