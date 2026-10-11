package PackageFlowProbe;
use strict;
use warnings;
no warnings 'once';
use JSON::PP ();
use Scalar::Util qw(refaddr);
use IPC::Open3 qw(open3);
use Symbol qw(gensym);
use LinkedSpec ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

sub same {ref($_[0]) && ref($_[1]) && refaddr($_[0])==refaddr($_[1]) ? 1 : 0}
sub encoded {
 my ($value)=@_;
 return $value unless ref($value);
 return [map {encoded($_)} @$value] if ref($value) eq 'ARRAY';
 return {map {$_=>encoded($value->{$_})} sort keys %$value} if ref($value) eq 'HASH';
 return {type=>ref($value)};
}
sub setup {
 my ($options)=@_;
 my $state={input=>exists($options->{input}) ? $options->{input} : 'and(true,false)',
  events=>[],trace=>[],slots=>[],eligible=>[],fatal=>bless({},'PackageFlowFatal'),calls=>{}};
 my $record=sub {
  my ($role,$slot,$context,$incoming)=@_;
  ++$state->{calls}{$role};push @{$state->{events}},$role;
  push @{$state->{trace}},{role=>$role,args=>[encoded($$slot)],context=>$context,
   readonly=>Internals::SvREADONLY($$slot) ? 1 : 0,incoming_error=>$incoming,
   caller_slot=>same($slot,\$state->{input}),
   previous_slots=>[map {same($slot,$_)} @{$state->{slots}}]};
  push @{$state->{slots}},$slot;
 };
 my %deps;
 for my $role (qw(trim_action_ir_value lower_primitive_literal_expr lower_flow_composite_expr)) {
  $deps{$role}=sub {
   $record->($role,\$_[0],!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',$@);
   if ($role eq 'trim_action_ir_value') {
    return $options->{trim} if exists($options->{trim});
    my $value=$_[0];$value=~s/^\s+|\s+$//g if defined($value);return $value;
   }
   return $options->{primitive} if $role eq 'lower_primitive_literal_expr';
   return 'MAP_FLOW';
  };
 }
 $state->{replacement}=sub {push @{$state->{events}},'replacement';return 'REPLACEMENT'};
 $state->{actual}=sub {
  $record->('package',\$_[0],!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',$@);
  push @{$state->{eligible}},LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
  my $original=$_[0];
  $_[0].='!' if $options->{mutate} || ($options->{outcome}//'') eq 'effect';
  $LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr=$state->{replacement} if $options->{replace};
  $@='successful package-flow callback';
  die $state->{fatal} if ($options->{outcome}//'') eq 'fatal';
  return undef if ($options->{outcome}//'') eq 'undefined';
  if ($state->{event}) {
   my $builder=LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
   LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder,'FLOW');
   LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
  }
  return $original if $options->{original};
  return $_[0] if $options->{equal};
  return $options->{flow} if exists($options->{flow});
  return 'FLOW';
 };
 $state->{record}=$record;$state->{original}={%deps};
 return (\%deps,$state);
}
sub invoke_owner {
 my ($options,$deps,$state)=@_;
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr=sub {
  $state->{record}->('bare',\$_[0],!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',$@);
  return $options->{bare};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr=sub {
  $state->{record}->('method',\$_[0],!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',$@);
  return exists($options->{method}) ? $options->{method} : 'METHOD';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_retired_colon_scalar_slot_expr=sub {return 'COLON('.$_[0].')'};
 return LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr($state->{input},$deps);
}
sub invoke {
 my ($options)=@_;my ($deps,$state)=setup($options);
 my ($value,$error,$success_error,$package_expected,$second);
 my $outside=$LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr;
 {
  local $LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr=
   exists($options->{package}) ? $options->{package} : $state->{actual};
  eval {$@='incoming package-flow error';$value=invoke_owner($options,$deps,$state);$success_error=$@;1} or $error=$@;
  if ($options->{replace}) {$second=invoke_owner($options,$deps,$state)}
  my $selected=exists($options->{package}) ? $options->{package} : $options->{replace} ? $state->{replacement} : $state->{actual};
  $package_expected=ref($selected) ? same($LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr,$selected)
   : defined($selected) ? defined($LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr)
    && $LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr eq $selected ? 1 : 0
   : !defined($LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr) ? 1 : 0;
 }
 return {name=>$options->{name},value=>encoded($value),second=>encoded($second),
  events=>$state->{events},trace=>$state->{trace},slots_after=>[map {encoded($$_)} @{$state->{slots}}],
  caller_after=>$state->{input},calls=>$state->{calls},success_error=>$success_error,
  result_identity=>ref($value) ? (grep {same($value,$options->{$_})} qw(flow method primitive bare)) ? 1 : 0 : undef,
  error=>ref($error) ? {type=>ref($error),same_fatal=>same($error,$state->{fatal})} : $error,
  map_expected=>{map {$_=>same($deps->{$_},$state->{original}{$_})} sort keys %$deps},
  package_expected=>$package_expected,
  restored=>ref($outside) ? same($outside,$LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr)
   : defined($outside) ? $outside eq ($LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr//'') ? 1 : 0
   : !defined($LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr) ? 1 : 0};
}
sub callback_cases {return [map {{name=>$_,outcome=>$_}} qw(string effect undefined fatal)]}
sub branch_cases {
 return [
  {name=>'undefined-input',input=>undef},{name=>'empty-input',input=>''},{name=>'whitespace-input',input=>'  '},
  {name=>'zero-input',input=>'0'},{name=>'identifier',input=>'name'},{name=>'colon',input=>':name'},
  {name=>'trim-undefined',trim=>undef},{name=>'trim-empty',trim=>''},{name=>'trim-zero',trim=>'0'},
  {name=>'bare-empty',bare=>''},{name=>'bare-zero',bare=>'0'},{name=>'bare-reference',bare=>{bare=>1}},
  {name=>'primitive-empty',primitive=>''},{name=>'primitive-zero',primitive=>'0'},
  {name=>'primitive-reference',primitive=>{primitive=>1}},
  {name=>'package-absent',package=>undef},{name=>'package-string',package=>'not code'},
  {name=>'package-reference',package=>{}},{name=>'package-blessed',package=>bless({},'NotFlowCode')},
  {name=>'flow-empty',flow=>''},{name=>'flow-zero',flow=>'0'},{name=>'flow-reference',flow=>{flow=>1}},
  {name=>'flow-equal',equal=>1},{name=>'flow-undefined',outcome=>'undefined'},
  {name=>'mutated-original',mutate=>1,original=>1},{name=>'mutated-equal',mutate=>1,equal=>1},
  {name=>'mutated-undefined',mutate=>1,outcome=>'undefined'},
  {name=>'fallback-undefined',mutate=>1,outcome=>'undefined',method=>undef},
  {name=>'fallback-empty',method=>'',equal=>1},{name=>'fallback-zero',method=>'0',equal=>1},
  {name=>'fallback-reference',method=>{method=>1},equal=>1},{name=>'package-replacement',replace=>1},
 ];
}
sub authority {
 my ($known)=@_;my $row;
 LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same',sub {
  my $event={raw=>'same'};
  LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
   {event=>$event,source=>'same',source_span=>{start=>0,end=>4}});
  my ($deps,$state)=setup({});$state->{event}=$event;
  local $LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr=$state->{actual};
  my $outer=sub {invoke_owner({},$deps,$state)};
  LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer,$state->{actual}] : [$outer],sub {
   my $capture=LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
   $row={known=>$known,value=>$capture->{value},eligible=>$state->{eligible},
    parent_packet=>LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture,$outer,$event) ? 1 : 0,
    package_identity=>same($LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr,$state->{actual}),
    map_identity=>same($deps->{lower_flow_composite_expr},$state->{original}{lower_flow_composite_expr}),
    calls=>$state->{calls}};
  });
 });
 return $row;
}
sub public_rows {
 my (@rows,@calls);
 my $outside=$LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr;
 for my $override (0,1) {
  my ($value,$error);
  {
   local $LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr=$override ? sub {
    push @calls,{args=>[@_],context=>!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar'};
    return 'FLOW_OVERRIDE';
   } : $outside;
   eval {$value=LinkedSpec::call_spec_handler_subst('Top','items += and(true,false)');1} or $error=$@;
  }
  push @rows,{override=>$override,value=>$value,error=>$error};
 }
 return {rows=>\@rows,calls=>\@calls};
}
sub observations {
 my $stderr=gensym;
 my $pid=open3(undef,my $stdout,$stderr,'perl','-Iperl','./t/actionir_package_flow_cold_probe.pl','observe');
 my $out=do {local $/;<$stdout>//''};my $err=do {local $/;<$stderr>//''};waitpid($pid,0);
 my $status=$? >> 8;
 return {callbacks=>[map {invoke($_)} @{callback_cases()}],branches=>[map {invoke($_)} @{branch_cases()}],
  authority=>[map {authority($_)} (0,1)],public=>public_rows(),
  cold=>{command=>['perl','-Iperl','./t/actionir_package_flow_cold_probe.pl','observe'],
   returncode=>$status,stdout=>$out,stderr=>$err,value=>$status ? undef : JSON::PP->new->decode($out)}};
}
unless (caller) {
 die 'usage: package-flow probe observe' unless @ARGV==1 && $ARGV[0] eq 'observe';
 print JSON::PP->new->canonical->encode(observations()),"\n";
}
1;
