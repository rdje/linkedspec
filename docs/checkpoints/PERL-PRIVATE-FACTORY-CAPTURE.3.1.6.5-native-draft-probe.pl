package HashIndexRequiredProbe;
use strict;
use warnings;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use IPC::Open3 qw(open3);
use Symbol qw(gensym);
use LinkedSpec ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

sub roles { return [['parser','trim_action_ir_value'],['lowerer','trim_action_ir_value'],['lowerer','lower_scalar_access_key_expr']] }
sub same { ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0 }
sub encoded {
 my ($value)=@_;
 return $value unless ref($value);
 return [map {encoded($_)} @$value] if ref($value) eq 'ARRAY';
 return {map {$_=>encoded($value->{$_})} sort keys %$value} if ref($value) eq 'HASH';
 return {type=>ref($value)};
}
sub setup {
 my ($options)=@_;
 my $state={input=>exists($options->{input}) ? $options->{input} : 'meta[key] = value',
  trace=>[],events=>[],slots=>[],calls=>{},eligible=>[],parsed=>[],ast_nodes=>[],helpers=>[],
  fatal=>bless({},'HashIndexRequiredFatal')};
 my %deps;
 for my $role (qw(trim_action_ir_value lower_scalar_access_key_expr)) {
  $deps{$role}=sub {
   my $slot=\$_[0];
   my @same_slots=map {same($slot,$_)} @{$state->{slots}};
   push @{$state->{slots}},$slot;
   ++$state->{calls}{$role};
   push @{$state->{events}},$role;
   my $parsed=$state->{parsed}[-1];
   push @{$state->{trace}},{role=>$role,args=>[map {encoded($_)} @_],
    readonly=>[map {Internals::SvREADONLY($_) ? 1 : 0} @_],
    caller_slot=>same($slot,\$state->{input}),previous_slots=>\@same_slots,
    parsed_key_slot=>ref($parsed) eq 'HASH' ? same($slot,\$parsed->{key}) : 0,
    context=>!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',incoming_error=>$@};
   my $result=$role eq 'trim_action_ir_value' ? $_[0] : 'KEY('.($_[0]//'').')';
   $result=~s/^\s+|\s+$//g if $role eq 'trim_action_ir_value' && defined($result);
   if ($role eq 'trim_action_ir_value') {
    if ($options->{replace_role} && $state->{calls}{$role}==1) {
     $deps{$options->{replace_role}}=$state->{replacement}{$options->{replace_role}};
    }
    $result=$options->{trim_result} if exists($options->{trim_result}) &&
     $state->{calls}{$role}==($options->{trim_result_at}//1);
   } else {
    $result=$options->{key_result} if exists($options->{key_result});
   }
   if ($role eq ($options->{role}//'')) {
    push @{$state->{eligible}},LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    my $active=$state->{calls}{$role}==($options->{effect_at}//1);
    $_[0].='!' if $active && (($options->{outcome}//'') eq 'effect' || $options->{mutate}) && defined($_[0]);
    $@='successful hash-index required callback';
    die $state->{fatal} if $active && ($options->{outcome}//'') eq 'fatal';
    return undef if $active && ($options->{outcome}//'') eq 'undefined';
    if ($state->{event} && $state->{calls}{$role}==1) {
     my $builder=LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
     LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder,
      ($options->{owner}//'parser') eq 'parser'
       ? JSON::PP->new->canonical->encode({target=>'meta',key=>'key',value=>'value'})
       : 'SET(meta,KEY(key),VALUE(value))');
     LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
    }
   }
   return $result;
  };
 }
 $state->{replacement}={
  trim_action_ir_value=>sub {push @{$state->{events}},'replacement_trim';return $_[0]},
  lower_scalar_access_key_expr=>sub {push @{$state->{events}},'replacement_key';return 'REPLACED_KEY'},
 };
 $state->{original}={%deps};
 delete $deps{$options->{missing}} if $options->{missing};
 $deps{$options->{noncode}}='not code' if $options->{noncode};
 return (\%deps,$state);
}
sub invoke_owner {
 my ($options,$deps,$state)=@_;
 my $parser=\&LinkedSpec::ActionIR::MethodLowering::_parse_hash_index_assignment_operator_statement;
 return $parser->($state->{input},$deps) if ($options->{owner}//'parser') eq 'parser';
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_parse_method_value_ast_expr=sub {
  push @{$state->{events}},'ast_parse';
  my $node={id=>1+@{$state->{ast_nodes}},source=>$_[0]};
  push @{$state->{ast_nodes}},$node;
  return $node;
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_assignment_operator_statement=sub {
  my $kind=$_[2];
  push @{$state->{events}},$kind;
  push @{$state->{helpers}},{helper=>$kind,node=>encoded($_[0]),
   actual_ast_node=>same($_[0],$state->{ast_nodes}[-1])};
  return $options->{$kind eq 'assign_hash_index' ? 'ast_hash' : 'ast_nested'};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_parse_hash_index_assignment_operator_statement=sub {
  push @{$state->{events}},'legacy_parse';
  my $value=exists($options->{parsed_override}) ? $options->{parsed_override} : $parser->(@_);
  push @{$state->{parsed}},$value;
  return $value;
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr=sub {
  my $parsed=$state->{parsed}[-1];
  push @{$state->{events}},'payload';
  push @{$state->{helpers}},{helper=>'payload',args=>[map {encoded($_)} @_[0]],
   parsed_value_slot=>ref($parsed) eq 'HASH' ? same(\$_[0],\$parsed->{value}) : 0};
  $_[0].='!' if $options->{payload_mutate} && defined($_[0]);
  return exists($options->{payload_result}) ? $options->{payload_result} : 'VALUE('.($_[0]//'').')';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_hash_index_set_expr=sub {
  push @{$state->{events}},'assemble';
  push @{$state->{helpers}},{helper=>'assemble',args=>[map {encoded($_)} @_ ]};
  return exists($options->{assembly_result}) ? $options->{assembly_result} : 'SET('.join(',',@_).')';
 };
 return LinkedSpec::ActionIR::MethodLowering::_lower_hash_index_assignment_operator_statement($state->{input},$deps);
}
sub invoke {
 my ($options)=@_;
 my ($deps,$state)=setup($options);
 my ($value,$error,$success_error);
 eval {$@='incoming hash-index required error';$value=invoke_owner($options,$deps,$state);$success_error=$@;1} or $error=$@;
 return {name=>$options->{name},value=>encoded($value),trace=>$state->{trace},events=>$state->{events},
  calls=>$state->{calls},caller_after=>$state->{input},parsed_after=>encoded($state->{parsed}),
  ast_nodes=>encoded($state->{ast_nodes}),helpers=>$state->{helpers},success_error=>$success_error,
  result_identity=>ref($value) ? (grep {same($value,$options->{$_})} qw(ast_hash ast_nested assembly_result)) ? 1 : 0 : undef,
  map_expected=>{map {my $name=$_; $name=>
   $options->{missing} && $name eq $options->{missing} ? !exists($deps->{$name}) ? 1 : 0
   : $options->{noncode} && $name eq $options->{noncode} ? $deps->{$name} eq 'not code' ? 1 : 0
   : $options->{replace_role} && $name eq $options->{replace_role} ? same($deps->{$name},$state->{replacement}{$name})
   : same($deps->{$name},$state->{original}{$name})} sort keys %{$state->{original}}},
  error=>ref($error) ? {type=>ref($error),same_fatal=>same($error,$state->{fatal})} : $error};
}
sub callback_cases {
 my @cases;
 for my $pair (@{roles()}) {
  my ($owner,$role)=@$pair;
  push @cases,{name=>join('-', $owner,$role,$_),owner=>$owner,role=>$role,outcome=>$_} for qw(string effect undefined fatal);
 }
 return \@cases;
}
sub branch_cases {
 my @rows;
 for my $owner (qw(parser lowerer)) {
  push @rows,map {{name=>$owner.'-'.$_->[0],owner=>$owner,input=>$_->[1]}}
   ['undefined-input',undef],['empty-input',''],['whitespace-input','  '],['zero-input','0'],
   ['ordinary','meta[key] = value'],['target-space','meta [ key ] = value'],
   ['nested-key','meta[fn([key], {"x": "y]"})] = value'],
   ['single-quote',"meta['a\\\'b]'] = value"],['double-quote','meta["a\\"b]"] = value'],
   ['invalid-target','1meta[key] = value'],['no-bracket','meta = value'],
   ['unclosed-bracket','meta[key = value'],['unclosed-quote','meta["key] = value'],
   ['equality','meta[key] == value'],['arrow','meta[key] => value'],
   ['missing-value','meta[key] ='],['empty-key','meta[] = value'],['zero-key-value','meta[0] = 0'];
  for my $role ($owner eq 'parser' ? ('trim_action_ir_value') : ('lower_scalar_access_key_expr','trim_action_ir_value')) {
   push @rows,{name=>$owner.'-missing-'.$role,owner=>$owner,missing=>$role};
   push @rows,{name=>$owner.'-noncode-'.$role,owner=>$owner,noncode=>$role};
   push @rows,{name=>$owner.'-missing-undefined-'.$role,owner=>$owner,missing=>$role,input=>undef};
  }
  for my $at ($owner eq 'parser' ? (1,2,3) : (1,3,4)) {
   push @rows,map {{name=>join('-', $owner,'trim-result',$at,$_->[0]),owner=>$owner,
    trim_result=>$_->[1],trim_result_at=>$at}} ['undefined',undef],['empty',''],['zero','0'];
  }
  push @rows,{name=>$owner.'-replace-trim',owner=>$owner,replace_role=>'trim_action_ir_value'};
  for my $outcome (qw(effect undefined fatal)) {
   push @rows,{name=>$owner.'-rhs-trim-'.$outcome,owner=>$owner,role=>'trim_action_ir_value',
    outcome=>$outcome,effect_at=>$owner eq 'parser' ? 2 : 3};
  }
 }
 push @rows,{name=>'lowerer-missing-both',owner=>'lowerer',missing=>'lower_scalar_access_key_expr',noncode=>'trim_action_ir_value'};
 push @rows,{name=>'lowerer-replace-key',owner=>'lowerer',replace_role=>'lower_scalar_access_key_expr'};
 for my $kind (qw(ast_hash ast_nested key_result payload_result assembly_result)) {
  push @rows,map {{name=>'lowerer-'.$kind.'-'.$_->[0],owner=>'lowerer',$kind=>$_->[1]}}
   ['undefined',undef],['empty',''],['zero','0'],['reference',{sentinel=>$kind}];
 }
 push @rows,{name=>'lowerer-payload-mutation',owner=>'lowerer',payload_mutate=>1};
 push @rows,{name=>'lowerer-parser-undefined',owner=>'lowerer',parsed_override=>undef};
 push @rows,{name=>'lowerer-parser-zero',owner=>'lowerer',parsed_override=>'0'};
 return \@rows;
}
sub authority {
 my ($owner,$role,$known)=@_;
 my $options={owner=>$owner,role=>$role,outcome=>'string'};
 my ($deps,$state)=setup($options);
 my $result;
 LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same',sub {
  my $event={raw=>'same'};
  LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
   {event=>$event,source=>'same',source_span=>{start=>0,end=>4}});
  $state->{event}=$event;
  my $ordinary;
  my $outer=sub {$ordinary=invoke_owner($options,$deps,$state);
   return $owner eq 'parser' ? JSON::PP->new->canonical->encode($ordinary) : $ordinary};
  LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer,$deps->{$role}] : [$outer],sub {
   my $captured=LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
   $result={owner=>$owner,role=>$role,known=>$known,value=>$captured->{value},ordinary=>encoded($ordinary),
    eligible=>$state->{eligible},parent_packet=>LinkedSpec::ActionIR::SourceEmissions::_emission_for($captured,$outer,$event) ? 1 : 0,
    selected_calls=>$state->{calls}{$role},map_identity=>same($deps->{$role},$state->{original}{$role})};
  });
 });
 return $result;
}
sub public_cases { return ('meta[key] = value','meta["stage"] = value','meta[key] = "v"') }
sub observations {
 my @public=map {my $source=$_;my ($value,$error);
  eval {$value=LinkedSpec::call_spec_handler_subst('Top',$source);1} or $error=$@;
  {source=>$source,value=>$value,error=>$error}} public_cases();
 my $stderr=gensym;
 my $pid=open3(undef,my $stdout,$stderr,'perl','-Iperl','./t/actionir_hash_index_required_cold_probe.pl','observe');
 my $out=do {local $/;<$stdout>//''};my $err=do {local $/;<$stderr>//''};waitpid($pid,0);my $status=$? >> 8;
 return {callbacks=>[map {invoke($_)} @{callback_cases()}],branches=>[map {invoke($_)} @{branch_cases()}],
  authority=>[map {my ($owner,$role)=@$_;map {authority($owner,$role,$_)} (0,1)} @{roles()}],public=>\@public,
  cold=>{command=>['perl','-Iperl','./t/actionir_hash_index_required_cold_probe.pl','observe'],
   returncode=>$status,stderr=>$err,stdout=>$out,value=>$status ? undef : JSON::PP->new->decode($out)}};
}
unless (caller) {
 die 'usage: hash-index probe observe' unless @ARGV==1 && $ARGV[0] eq 'observe';
 print JSON::PP->new->canonical->encode(observations()),"\n";
}
1;
