"""Run effective private-channel inverse controls only in a complete supplied copy."""
from pathlib import Path
import copy, importlib.util, json, subprocess, tempfile
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('inverse.py')
spec=importlib.util.spec_from_file_location('handoff_capture',PREFIX+'capture.py')
capture=importlib.util.module_from_spec(spec);spec.loader.exec_module(capture)
manifest=json.loads(Path(PREFIX+'after-inputs.json').read_bytes())
report=json.loads(Path(PREFIX+'after-observations.json').read_bytes())
original=ROOT/report['input_tree'];entries=manifest['entries']
capture.streams.verify_tree(original,entries)
scratch=ROOT/'.linkedspec-data/scratch/private-source-handoff'
tree=Path(tempfile.mkdtemp(prefix='inverse-',dir=scratch));assert tree.stat().st_dev==ROOT.stat().st_dev
for entry in entries:
    target=tree/entry['path'];target.parent.mkdir(parents=True,exist_ok=True)
    target.write_bytes((original/entry['path']).read_bytes());target.chmod(int(entry['mode'][-3:],8))
fixture=str(Path(PREFIX+'origin-fixture.t').relative_to(ROOT))
command=['bash','tools/project_data_run.sh','prove','-v','-Iperl',fixture]
base=capture.streams.verify_tree(tree,entries)
positive=subprocess.run(command,cwd=tree,env=capture.environment(0),capture_output=True)
assert positive.returncode==0
path=lambda name:'perl/LinkedSpec/ActionIR/'+name+'.pm'
mutants=[
 ('scanner-capture',path('Scanner'),'   LinkedSpec::ActionIR::SourceOrigins::_remember_selected_source_origins($events, $selected->{source_origins});\n','', 'selected original references survive both actual copies'),
 ('diagnostic-copy',path('Diagnostics'),'   LinkedSpec::ActionIR::SourceOrigins::_copy_source_origin($event, $events[-1]);\n','', 'selected original references survive both actual copies'),
 ('canonical-copy',path('CanonicalEvents/Core'),' LinkedSpec::ActionIR::SourceOrigins::_copy_source_origin($event, $canonical);\n','', 'selected original references survive both actual copies'),
 ('splitter-frames',path('CanonicalEvents'),' if (LinkedSpec::ActionIR::SourceOrigins::_is_active_for($code)) {',' if (0) {','synthetic events use exact canonical splitter frames'),
 ('helper-frame-borrow',path('CanonicalEvents'),'   unless $matched_helper;','   ;','helper queue matches do not invent missing scanner authority'),
 ('event-identity',path('SourceOrigins'),'  && Scalar::Util::refaddr($origin->{event}) == Scalar::Util::refaddr($event)\n','','source validation identity detached copies and ambiguity'),
 ('foreign-source',path('SourceOrigins'),'  && $_invocation->{source} eq $source\n','\n','foreign copied changed and opaque splitter results cannot borrow frames'),
 ('raw-slice',path('SourceOrigins'),'  && substr($origin->{source}, $start, $end - $start) eq $event->{raw}','', 'source validation identity detached copies and ambiguity'),
 ('ambiguity',path('SourceOrigins'),'  $previous->{ambiguous} = 1 if $previous->{start} != $start || $previous->{end} != $end;\n','','source validation identity detached copies and ambiguity'),
 ('strong-retention',path('SourceOrigins'),'  event => $event, raw => $event->{raw}, start => 0 + $start, end => 0 + $end,\n };','  event => $event, raw => $event->{raw}, start => 0 + $start, end => 0 + $end,\n };\n Scalar::Util::weaken($_invocation->{events}{$key}{event});','strong references prevent address reuse and scope releases them'),
 ('scope-restoration',path('SourceOrigins'),' local $_invocation = {source => $source, events => {}};',' $_invocation = {source => $source, events => {}};','nested scopes and errors restore enclosing authority'),
]
out={'complete':False,'revision':capture.REVISION,'producer_sha256':capture.streams.sha(Path(__file__).read_bytes()),'inputs_manifest_sha256':capture.streams.sha(Path(PREFIX+'after-inputs.json').read_bytes()),'baseline':{'exit':positive.returncode,'stdout':capture.streams.envelope(positive.stdout),'stderr':capture.streams.envelope(positive.stderr),'inputs_before':base,'inputs_after':capture.streams.verify_tree(tree,entries)},'controls':[],'scope':'Exact full regular after superset plus one declared source inverse at a time, in private supplied copies. Positive actual fixture runs first; every inverse must reach its named semantic assertion and complete TAP rather than fail import/syntax. No mutation is installed in production.'}
for name,relative,old,new,oracle in mutants:
    target=tree/relative;raw=target.read_bytes();text=raw.decode();assert text.count(old)==1,(name,'unique actual source seam')
    mutated=text.replace(old,new).encode();target.write_bytes(mutated)
    current=copy.deepcopy(entries)
    item=next(e for e in current if e['path']==relative);item.update(bytes=len(mutated),sha256=capture.streams.sha(mutated))
    before=capture.streams.verify_tree(tree,current)
    result=subprocess.run(command,cwd=tree,env=capture.environment(0),capture_output=True)
    assert result.returncode!=0 and ('not ok ').encode() in result.stdout and ('# Subtest: '+oracle).encode() in result.stdout
    assert ('Failed test \''+oracle+'\'').encode() in result.stderr,(name,'named distinguishing assertion')
    assert b'1..10\n' in result.stdout and b'BEGIN failed' not in result.stderr,(name,'complete executable fixture')
    out['controls'].append({'name':name,'path':relative,'original_sha256':capture.streams.sha(raw),'mutated_sha256':capture.streams.sha(mutated),'mutation':{'old':old,'new':new},'oracle':oracle,'command':command,'exit':result.returncode,'stdout':capture.streams.envelope(result.stdout),'stderr':capture.streams.envelope(result.stderr),'inputs_before':before,'inputs_after':capture.streams.verify_tree(tree,current)})
    target.write_bytes(raw);capture.streams.verify_tree(tree,entries)
    Path(PREFIX+'inverse.json').write_text(json.dumps(out,indent=2)+'\n');print(name,'effective RED',flush=True)
out['complete']=True
Path(PREFIX+'inverse.json').write_text(json.dumps(out,indent=2)+'\n')
print('All',len(mutants),'actual source inverse controls passed.')
