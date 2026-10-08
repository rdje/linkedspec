"""Run effective mapped-replacement inverse controls only in a complete supplied copy."""
from pathlib import Path
import copy, importlib.util, json, subprocess, tempfile
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('inverse.py')
spec=importlib.util.spec_from_file_location('handoff_capture',PREFIX+'corrected-capture.py')
capture=importlib.util.module_from_spec(spec);spec.loader.exec_module(capture)
manifest=json.loads(Path(PREFIX+'corrected-after-inputs.json').read_bytes())
report=json.loads(Path(PREFIX+'corrected-after-observations.json').read_bytes())
recovery_spec=importlib.util.spec_from_file_location('candidate_recovery',PREFIX+'recover.py')
recovery=importlib.util.module_from_spec(recovery_spec);recovery_spec.loader.exec_module(recovery)
original=recovery.recover(manifest);entries=manifest['entries']
capture.streams.verify_tree(original,entries)
scratch=ROOT/'.linkedspec-data/scratch/mapped-replacement'
tree=Path(tempfile.mkdtemp(prefix='inverse-',dir=scratch));assert tree.stat().st_dev==ROOT.stat().st_dev
for entry in entries:
    target=tree/entry['path'];target.parent.mkdir(parents=True,exist_ok=True)
    target.write_bytes((original/entry['path']).read_bytes());target.chmod(int(entry['mode'][-3:],8))
fixture=str(Path(PREFIX+'corrected-replacement-fixture.t').relative_to(ROOT))
command=['bash','tools/project_data_run.sh','prove','-v','-Iperl',fixture]
base=capture.streams.verify_tree(tree,entries)
positive=subprocess.run(command,cwd=tree,env=capture.environment(0),capture_output=True)
assert positive.returncode==0
path=lambda name:'perl/LinkedSpec/ActionIR/'+name+'.pm'
mutants=[('original-authority', 'perl/LinkedSpec/ActionIR/RewritePipeline.pm', ' my $origin = _event_source_origin($map, $event);', ' my $origin = undef;', 'quoted twin after earlier expansion'), ('edit-ledger', 'perl/LinkedSpec/ActionIR/RewritePipeline.pm', ' _record_source_edit($map, $position, $removed, length($replacement));', ' # source inverse: omit actual edit record', 'quoted twin after earlier expansion'), ('actual-edit-order', 'perl/LinkedSpec/ActionIR/RewritePipeline.pm', ' for my $edit (@{$map->{edits}}) {', ' for my $edit (reverse @{$map->{edits}}) {', 'implicit LF CRLF and Unicode source offsets'), ('consumed-authority', 'perl/LinkedSpec/ActionIR/RewritePipeline.pm', '  elsif ($edit->{position} < $end) {\n   return $missing;', '  elsif ($edit->{position} < $end) {\n   $start = index($rewritten, $event->{raw}); $end = $start + length($event->{raw});', 'already consumed original intervals cannot replace generated data twice'), ('start-boundary', 'perl/LinkedSpec/ActionIR/RewritePipeline.pm', '  if ($edit->{position} + $edit->{removed} <= $start) {', '  if ($edit->{position} + $edit->{removed} < $start) {', 'actual edit translation validates original raw and decline paths'), ('end-boundary', 'perl/LinkedSpec/ActionIR/RewritePipeline.pm', '  elsif ($edit->{position} < $end) {', '  elsif ($edit->{position} <= $end) {', 'edits after an interval and at its end leave it unchanged'), ('current-raw', 'perl/LinkedSpec/ActionIR/RewritePipeline.pm', '\n  && substr($rewritten, $start, $end - $start) eq $event->{raw}', '', 'actual edit translation validates original raw and decline paths'), ('foreign-source', 'perl/LinkedSpec/ActionIR/RewritePipeline.pm', ' return undef unless $origin && $origin->{source} eq $map->{source};', ' return undef unless $origin;', 'actual edit translation validates original raw and decline paths'), ('pending-end', 'perl/LinkedSpec/ActionIR/RewritePipeline.pm', ' my $insert_pos = _mapped_pending_position($source_map, $previous_lowered->{rewritten_end});', ' my $insert_pos = $previous_lowered->{rewritten_end};', 'nonmonotone family order rebases the pending terminator'), ('closure-original-occurrence', 'perl/LinkedSpec/ActionIR/RewritePipeline.pm', ' my $mapped = _mapped_event_span($source_map, $$rewritten_ref, $event);', ' my $mapped = undef;', 'implicit closure insertion uses the actual source occurrence'), ('opaque-fallback', 'perl/LinkedSpec/ActionIR/RewritePipeline.pm', ' return undef unless $origin;', ' return {position => -1, length => 0} unless $origin;', 'opaque direct callers retain the original fallback and exact error'), ('private-callback-context', 'perl/LinkedSpec/ActionIR/RewritePipeline.pm', '  trace_label => $label,\n };', '  trace_label => $label,\n  source_map => $source_map,\n };', 'quoted twin after earlier expansion')]

out={'complete':False,'revision':capture.REVISION,'producer_sha256':capture.streams.sha(Path(__file__).read_bytes()),'inputs_manifest_sha256':capture.streams.sha(Path(PREFIX+'corrected-after-inputs.json').read_bytes()),'baseline':{'exit':positive.returncode,'stdout':capture.streams.envelope(positive.stdout),'stderr':capture.streams.envelope(positive.stderr),'inputs_before':base,'inputs_after':capture.streams.verify_tree(tree,entries)},'controls':[],'scope':'Exact full regular after superset plus one declared source inverse at a time, in private supplied copies. Positive actual fixture runs first; every inverse must reach its named semantic assertion and complete TAP rather than fail import/syntax. No mutation is installed in production.'}
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
