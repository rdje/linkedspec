"""Falsify the final runtime with bounded actual source faults and exact restoration."""
import json
import common as c

def main():
 plan=json.loads((c.ROOT/'tests/numeric-codeblocks/indexed-writes.json').read_bytes())
 saved={p:c.read(p) for p in c.SOURCES}
 runtime=c.SOURCES[0];emitter=c.SOURCES[1]
 tasks=[
  ('caller-slot-inventory',c.SOURCES[2],"  map { $_ => 1 } grep { $__ls_current_bare_type_memory->{$_} eq 'scalar' }\n   keys %$__ls_current_bare_type_memory,\n",'', ['returned/caller-null']),
  ('function-slot-inventory',emitter,"sub _user_function_presence_targets {\n","sub _user_function_presence_targets {\n return _user_function_nested_write_targets($_[0]);\n", ['forwarded/compiled-null','forwarded/compiled-parameter-null']),
  ('dispatch',runtime," return _eval_nested_write($node, $ctx) if $kind eq 'assign_nested_access';",'', ['deferred/replace']),
  ('forwarded-slot-presence',runtime,'  } elsif (exists $binding_presence_by_slot{$binding}) {\n   $ctx->{presence}{$name} = $binding_presence_by_slot{$binding};\n','', ['forwarded/present-null']),
  ('scalar-presence',runtime,' ${_presence_ref($ctx, $name)} = 1;','', ['ordinary/null-prior-call','deferred/null-prior-call']),
  ('caller-presence',emitter,"sub _codeblock_runtime_presence_expr {\n","sub _codeblock_runtime_presence_expr {\n return '{}';\n", ['deferred/null-caller']),
  ('parameter-presence',runtime,'  my $parameter_present = 1;','  my $parameter_present = 0;', ['ordinary/null-parameter']),
  ('selector-kinds',runtime,'   kind_hint => $hint, source_span => $spans[$index] };',"   kind_hint => 'dynamic', source_span => $spans[$index] };", ['deferred/invalid/boolean']),
  ('snapshot-order',runtime,' my $rhs = _eval_expr($node->{value}, $ctx);',' my $early = $$binding;\n my $rhs = _eval_expr($node->{value}, $ctx);', ['deferred/same-binding-rhs']),
 ]
 reports={}
 for name,path,old,new,ids in tasks:
  original=c.decode(saved[path]['base64']).decode()
  assert original.count(old)==1,(name,original.count(old))
  faulty=original.replace(old,new,1)
  if name=='snapshot-order':
   needle='  $$binding, (defined($$binding) || $$present) ? 1 : 0, $base, \\@evaluated, $rhs);'
   assert faulty.count(needle)==1
   faulty=faulty.replace(needle,'  $early, (defined($early) || $$present) ? 1 : 0, $base, \\@evaluated, $rhs);',1)
  selected=dict(cases=[case for case in plan['cases'] if case['id'] in ids])
  assert len(selected['cases'])==len(ids)
  try:
   (c.ROOT/path).write_text(faulty)
   actual=c.read(path)
   red=c.observe(selected)
   failed=c.failures(red,selected)
  finally:(c.ROOT/path).write_bytes(c.decode(saved[path]['base64']))
  green=c.observe(selected)
  c.save('fault4-'+name+'.json.gz',dict(path=path,original=saved[path],fault=actual,plan=selected,red=red,green=green,failures=failed,producer=c.read(c.PREFIX+'faults4.py')))
  assert set(failed)==set(ids),(name,failed)
  assert not c.failures(green,selected)
  assert c.read(path)==saved[path]
  reports[name]=ids
 expected={'committed':{'x':[1]},'guard':{'class':'LinkedSpec::BindingRuntime::ReceiverMutationError','code':'receiver_mutation_reentrant','seen':'','tree':{'a':'A'}},'result':{'x':[2]}}
 healthy=c.run(['bash','tools/project_data_run.sh','perl','-Iperl',c.PREFIX+'seams.pl'])
 assert healthy['returncode']==0 and json.loads(c.decode(healthy['stdout_base64']))==expected
 original=c.decode(saved[runtime]['base64']).decode()
 start=original.index(' LinkedSpec::BindingRuntime::assert_receiver_writable(\n',original.index('sub _eval_nested_write'))
 end=original.index('\n my @evaluated;',start)
 guard=original[start:end]
 faults={'guard-order':original[:start]+original[end:]}
 marker=' my $rhs = _eval_expr($node->{value}, $ctx);'
 assert faults['guard-order'].count(marker)==1
 faults['guard-order']=faults['guard-order'].replace(marker,marker+'\n'+guard,1)
 faults['result-alias']=original.replace(' return $result\n}\n\nsub _scalar_text',' return $updated\n}\n\nsub _scalar_text',1)
 assert faults['result-alias']!=original
 for name,text in faults.items():
  try:
   (c.ROOT/runtime).write_text(text)
   actual=c.read(runtime)
   red=c.run(['bash','tools/project_data_run.sh','perl','-Iperl',c.PREFIX+'seams.pl'])
  finally:(c.ROOT/runtime).write_bytes(c.decode(saved[runtime]['base64']))
  green=c.run(['bash','tools/project_data_run.sh','perl','-Iperl',c.PREFIX+'seams.pl'])
  c.save('fault4-'+name+'.json.gz',dict(original=saved[runtime],fault=actual,red=red,green=green,healthy=healthy,expected=expected,producer=c.read(c.PREFIX+'faults4.py'),seam=c.read(c.PREFIX+'seams.pl')))
  assert red['returncode']==green['returncode']==0
  assert json.loads(c.decode(red['stdout_base64']))!=expected
  assert json.loads(c.decode(green['stdout_base64']))==expected
  assert c.read(runtime)==saved[runtime]
  reports[name]=['independent guard/effect/detachment seam']
 c.save('faults4.json',dict(faults=reports,restored=all(c.read(p)==packet for p,packet in saved.items())))
 print('Actual faults rejected and restored:',len(reports))
if __name__=='__main__':main()
