package ArrayEndRequiredProbe;
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

sub roles {return [qw(trim_action_ir_value parse_method_function_expr extract_array_symbol_name)]}
sub same {ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0}
sub encoded {
 my ($value)=@_;
 return $value unless ref($value);
 return [map {encoded($_)} @$value] if ref($value) eq 'ARRAY';
 return {map {$_=>encoded($value->{$_})} sort keys %$value} if ref($value) eq 'HASH';
 return {type=>ref($value)};
}
sub setup {
 my ($options)=@_;
 my $state={input=>exists($options->{input}) ? $options->{input} : 'items.push_back(value)',
  trace=>[],events=>[],slots=>[],calls=>{},eligible=>[],parsed=>[],
  fatal=>bless({},'ArrayEndRequiredFatal')};
 my %deps;
 for my $role (@{roles()}) {
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
    parsed_argument_slot=>ref($parsed) eq 'HASH' && ref($parsed->{args}) eq 'ARRAY' && @{$parsed->{args}}
     ? same($slot,\$parsed->{args}[0]) : 0,
    context=>!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',incoming_error=>$@};
   my $result;
   if ($role eq 'trim_action_ir_value') {
    $result=$_[0];
    $result=~s/^\s+|\s+$//g if defined($result);
    if ($options->{replace_role} && $state->{calls}{$role}==1) {
     $deps{$options->{replace_role}}=$state->{replacement}{$options->{replace_role}};
    }
    $result=$options->{trim_result} if exists($options->{trim_result}) &&
     $state->{calls}{$role}==($options->{trim_result_at}//1);
   } elsif ($role eq 'extract_array_symbol_name') {
    $result=exists($options->{target}) ? $options->{target}
     : defined($_[0]) && $_[0]=~/^(?:array\s*\(\s*)?([A-Za-z_][A-Za-z0-9_]*)(?:\s*\))?$/ ? $1 : undef;
   } elsif (defined($_[0]) && $_[0]=~/^([a-z_]+)\((.*)\)$/s) {
    my ($method,$args)=($1,$2);
    $result={method=>$method,args=>length($args) ? [split /,\s*/,$args] : []};
    $result->{method}=$options->{method} if exists($options->{method});
    $result->{args}=$options->{args} if exists($options->{args});
    push @{$state->{parsed}},$result;
   }
   if ($role eq ($options->{role}//'')) {
    push @{$state->{eligible}},LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    my $active=!exists($options->{effect_at}) || $state->{calls}{$role}==$options->{effect_at};
    $_[0].='!' if $active && (($options->{outcome}//'') eq 'effect' || $options->{mutate}) && defined($_[0]);
    $@='successful array-end required callback';
    die $state->{fatal} if $active && ($options->{outcome}//'') eq 'fatal';
    return undef if $active && ($options->{outcome}//'') eq 'undefined';
    if ($state->{event} && $state->{calls}{$role}==1) {
     my $builder=LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
     LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder,
      JSON::PP->new->canonical->encode({method=>'push_back',receiver=>'items',target=>'items',value=>'value'}));
     LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
    }
   }
   return $result;
  };
 }
 $state->{replacement}={
  parse_method_function_expr=>sub {push @{$state->{events}},'replacement_parser';return {method=>'pop_front',args=>[]}},
  extract_array_symbol_name=>sub {push @{$state->{events}},'replacement_extractor';return 'other'},
 };
 $state->{original}={%deps};
 delete $deps{$options->{missing}} if $options->{missing};
 $deps{$options->{noncode}}='not code' if $options->{noncode};
 return (\%deps,$state);
}
sub invoke_owner {
 my ($deps,$state)=@_;
 return LinkedSpec::ActionIR::MethodLowering::_parse_array_end_mutation_method_statement($state->{input},$deps);
}
sub invoke {
 my ($options)=@_;
 my ($deps,$state)=setup($options);
 my ($value,$error,$success_error);
 eval {$@='incoming array-end required error';$value=invoke_owner($deps,$state);$success_error=$@;1} or $error=$@;
 return {name=>$options->{name},value=>encoded($value),trace=>$state->{trace},events=>$state->{events},
  calls=>$state->{calls},caller_after=>$state->{input},parsed_after=>encoded($state->{parsed}),
  success_error=>$success_error,
  map=>{map {$_=>exists($deps->{$_}) ? ref($deps->{$_})||$deps->{$_} : 'absent'} sort keys %{$state->{original}}},
  map_expected=>{map {my $name=$_; $name=>
   $options->{missing} && $name eq $options->{missing} ? !exists($deps->{$name}) ? 1 : 0
   : $options->{noncode} && $name eq $options->{noncode} ? $deps->{$name} eq 'not code' ? 1 : 0
   : $options->{replace_role} && $name eq $options->{replace_role} ? same($deps->{$name},$state->{replacement}{$name})
   : same($deps->{$name},$state->{original}{$name})} sort keys %{$state->{original}}},
  error=>ref($error) ? {type=>ref($error),same_fatal=>same($error,$state->{fatal})} : $error};
}
sub callback_cases {
 my @cases;
 for my $role (@{roles()}) {
  push @cases,{name=>$role.'-'.$_,role=>$role,outcome=>$_} for qw(string effect undefined fatal);
 }
 return \@cases;
}
sub branch_cases {
 my @cases=(
  ['undefined-input',undef],['empty-input',''],['whitespace-input','  '],['zero-input','0'],
  ['no-dot','items'],['empty-receiver','.push_back(value)'],['empty-tail','items.'],
  ['decimal-receiver','1.5.push_back(value)'],['quoted-receiver','"items".push_back(value)'],
  ['literal-array','[1].push_back(value)'],['legacy-array-selector','array(items).push_back(value)'],
  ['spaced-array-selector','array ( items ).push_back(value)'],
  ['malformed-call','items.push_back'],['unknown-call','items.unknown(value)'],
  ['push-back','items.push_back(value)'],['push-front','items.push_front(value)'],
  ['pop-back','items.pop_back()'],['pop-front','items.pop_front()'],
  ['push-missing','items.push_back()'],['push-excess','items.push_back(a, b)'],
  ['pop-excess','items.pop_back(value)'],['push-whitespace','items.push_back(   )'],
  ['push-zero','items.push_back(0)'],['extra-tail','items.push_back(value).count()'],
  ['receiver-dotted-nesting','array(items.dot).push_back(value)'],
 );
 my @rows=map {{name=>$_->[0],input=>$_->[1]}} @cases;
 for my $role (@{roles()}) {
  push @rows,{name=>'missing-'.$role,missing=>$role};
  push @rows,{name=>'noncode-'.$role,noncode=>$role};
  push @rows,{name=>'missing-undefined-input-'.$role,missing=>$role,input=>undef};
 }
 for my $at (1,5) {
  push @rows,{name=>'trim-result-'.$at.'-'.$_->[0],trim_result=>$_->[1],trim_result_at=>$at}
   for ['undefined',undef],['empty',''],['zero','0'];
 }
 for my $role (qw(parse_method_function_expr extract_array_symbol_name)) {
  push @rows,{name=>'replace-'.$role,replace_role=>$role};
 }
 push @rows,{name=>'parser-undefined-method',method=>undef};
 push @rows,{name=>'parser-missing-args',args=>undef};
 push @rows,{name=>'parser-pop-missing-args',input=>'items.pop_back()',args=>undef};
 for my $target (['undefined',undef],['empty',''],['zero','0'],['other','other']) {
  push @rows,{name=>'target-'.$target->[0],target=>$target->[1]};
  push @rows,{name=>'selector-target-'.$target->[0],target=>$target->[1],input=>'array(items).push_back(value)'};
 }
 push @rows,{name=>'extract-undefined-mutated',role=>'extract_array_symbol_name',outcome=>'undefined',mutate=>1};
 for my $outcome (qw(effect undefined fatal)) {
  push @rows,{name=>'payload-trim-'.$outcome,role=>'trim_action_ir_value',outcome=>$outcome,effect_at=>5};
 }
 return \@rows;
}
sub authority {
 my ($role,$known)=@_;
 my ($deps,$state)=setup({role=>$role,outcome=>'string'});
 my $result;
 LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same',sub {
  my $event={raw=>'same'};
  LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
   {event=>$event,source=>'same',source_span=>{start=>0,end=>4}});
  $state->{event}=$event;
  my $parsed;
  my $outer=sub {$parsed=invoke_owner($deps,$state);return JSON::PP->new->canonical->encode($parsed)};
  LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer,$deps->{$role}] : [$outer],sub {
   my $captured=LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
   $result={role=>$role,known=>$known,value=>$captured->{value},parsed=>encoded($parsed),eligible=>$state->{eligible},
    parent_packet=>LinkedSpec::ActionIR::SourceEmissions::_emission_for($captured,$outer,$event) ? 1 : 0,
    selected_calls=>$state->{calls}{$role},map_identity=>same($deps->{$role},$state->{original}{$role})};
  });
 });
 return $result;
}
sub public_cases {return map {[$_, 'items.'.$_.'('.(/^push_/ ? '"v"' : '').')']} qw(push_back push_front pop_back pop_front)}
sub observations {
 my @public=map {my ($name,$source)=@$_;my ($value,$error);
  eval {$value=LinkedSpec::call_spec_handler_subst('Top',$source);1} or $error=$@;
  {name=>$name,source=>$source,value=>$value,error=>$error}} public_cases();
 my $stderr=gensym;
 my $pid=open3(undef,my $stdout,$stderr,'perl','-Iperl','./t/actionir_array_end_required_cold_probe.pl','observe');
 my $out=do {local $/;<$stdout>//''};my $err=do {local $/;<$stderr>//''};waitpid($pid,0);my $status=$? >> 8;
 return {callbacks=>[map {invoke($_)} @{callback_cases()}],branches=>[map {invoke($_)} @{branch_cases()}],
  authority=>[map {my $role=$_;map {authority($role,$_)} (0,1)} @{roles()}],public=>\@public,
  cold=>{command=>['perl','-Iperl','./t/actionir_array_end_required_cold_probe.pl','observe'],
   returncode=>$status,stderr=>$err,stdout=>$out,value=>$status ? undef : JSON::PP->new->decode($out)}};
}
unless (caller) {
 die 'usage: array-end probe observe' unless @ARGV==1 && $ARGV[0] eq 'observe';
 print JSON::PP->new->canonical->encode(observations()),"\n";
}
1;
