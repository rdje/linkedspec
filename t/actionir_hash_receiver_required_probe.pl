package HashReceiverRequiredProbe;
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

sub roles {return [qw(trim_action_ir_value parse_method_function_expr)]}
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
 my $state={input=>exists($options->{input}) ? $options->{input} : 'meta.sorted_keys()',
  trace=>[],events=>[],slots=>[],calls=>{},eligible=>[],parsed=>[],
  fatal=>bless({},'HashReceiverRequiredFatal')};
 my %deps;
 for my $role (@{roles()}) {
  $deps{$role}=sub {
   my $slot=\$_[0];
   my @same_slots=map {same($slot,$_)} @{$state->{slots}};
   push @{$state->{slots}},$slot;
   ++$state->{calls}{$role};
   push @{$state->{events}},$role;
   push @{$state->{trace}},{role=>$role,args=>[map {encoded($_)} @_],
    readonly=>[map {Internals::SvREADONLY($_) ? 1 : 0} @_],
    caller_slot=>same($slot,\$state->{input}),previous_slots=>\@same_slots,
    context=>!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',incoming_error=>$@};
   my $result;
   if ($role eq 'trim_action_ir_value') {
    $result=$_[0];
    $result=~s/^\s+|\s+$//g if defined($result);
    if ($options->{replace_parser} && $state->{calls}{$role}==1) {
     $deps{parse_method_function_expr}=$state->{replacement_parser};
    }
    $result=$options->{trim_result} if exists($options->{trim_result}) && $state->{calls}{$role}==1;
   } elsif (defined($_[0]) && $_[0]=~/^([a-z_]+)\((.*)\)$/s) {
    my ($method,$args)=($1,$2);
    $result={method=>$method,args=>length($args) ? [split /,\s*/,$args] : []};
    $result->{method}=$options->{method} if exists($options->{method});
    $result->{args}=$options->{args} if exists($options->{args});
    if ($options->{shared_call}) {
     $state->{shared_call} //= $result;
     $result=$state->{shared_call};
    }
    push @{$state->{parsed}},$result;
   }
   if ($role eq ($options->{role}//'')) {
    push @{$state->{eligible}},LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    $_[0].='!' if ($options->{outcome}//'') eq 'effect' && defined($_[0]);
    $@='successful hash receiver required callback';
    die $state->{fatal} if ($options->{outcome}//'') eq 'fatal';
    return undef if ($options->{outcome}//'') eq 'undefined';
    if ($state->{event} && $state->{calls}{$role}==1) {
     my $builder=LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
     LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder,'sorted_keys(meta)');
     LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
    }
   }
   return $result;
  };
 }
 $deps{bare_symbol_kind}=sub {
  ++$state->{optional_kind_calls};
  return exists($options->{kind}) ? $options->{kind} : 'hash';
 };
 $state->{replacement_parser}=sub {
  push @{$state->{events}},'replacement_parser';return {method=>'count_keys',args=>[]};
 };
 $state->{original}={%deps};
 delete $deps{$options->{missing}} if $options->{missing};
 $deps{$options->{noncode}}='not code' if $options->{noncode};
 return (\%deps,$state);
}
sub invoke_owner {
 my ($deps,$state)=@_;
 return LinkedSpec::ActionIR::MethodLowering::_normalize_hash_receiver_value_chain_expr($state->{input},$deps);
}
sub invoke {
 my ($options)=@_;
 my ($deps,$state)=setup($options);
 my ($value,$error,$success_error);
 eval {$@='incoming hash receiver required error';$value=invoke_owner($deps,$state);$success_error=$@;1} or $error=$@;
 return {name=>$options->{name},value=>encoded($value),trace=>$state->{trace},events=>$state->{events},
  calls=>$state->{calls},caller_after=>$state->{input},parsed_after=>encoded($state->{parsed}),
  parsed_same=>[map {my $current=$_;[map {same($current,$_)} @{$state->{parsed}}]} @{$state->{parsed}}],
  optional_kind_calls=>$state->{optional_kind_calls}||0,success_error=>$success_error,
  map=>{map {$_=>exists($deps->{$_}) ? ref($deps->{$_})||$deps->{$_} : 'absent'} sort keys %{$state->{original}}},
  map_expected=>{map {my $name=$_; $name=>
   $options->{missing} && $name eq $options->{missing} ? !exists($deps->{$name}) ? 1 : 0
   : $options->{noncode} && $name eq $options->{noncode} ? $deps->{$name} eq 'not code' ? 1 : 0
   : $options->{replace_parser} && $name eq 'parse_method_function_expr' ? same($deps->{$name},$state->{replacement_parser})
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
  ['no-dot','meta'],['empty-receiver','.sorted_keys()'],['empty-tail','meta.'],
  ['decimal-receiver','1.5.sorted_keys()'],['quoted-dot','"a.b".sorted_keys()'],
  ['nested-dot','hash("a.b", 1).sorted_keys()'],['malformed-call','meta.sorted_keys'],
  ['unknown-call','meta.unknown()'],['wrong-family','meta.abs()'],
  ['hash-chain','meta.set_key(a, 1).rename_key(a, b).drop_keys(c).pick_keys(b).merge_hash(other).count_keys()'],
  ['flat-copy','meta.flat_hash().copy().count_keys()'],['flat-excess','meta.flat_hash(1)'],
  ['terminal-chain','meta.count_keys().sorted_keys()'],['unknown-tail','meta.sorted_keys().unknown()'],
  ['keys-join','meta.sorted_keys().join_values("-")'],['join-missing','meta.sorted_keys().join_values()'],
  ['join-excess','meta.sorted_keys().join_values("-", "!")'],['values-sum','meta.sorted_values().sum()'],
  ['sum-excess','meta.sorted_values().sum(1)'],
  ['array-transform','meta.sorted_values().trim_each().uniq().count()'],
  ['array-generic','meta.sorted_keys().take(2).slice(0, 1).sorted()'],
  ['array-terminal-tail','meta.sorted_keys().count().sorted()'],
  ['array-wrong-family','meta.sorted_keys().set_key(a, 1)'],
  ['copy-known-hash','meta.copy()'],['copy-excess','meta.copy(1)'],
  ['copy-explicit-hash','hash(a, 1).copy()'],['copy-explicit-array','array([1]).copy()'],
  ['copy-hash-lookahead','other.copy().count_keys()'],['copy-array-lookahead','other.copy().sorted()'],
  ['walk-leaves','meta.walk_leaves(cb).count_keys()'],['map-leaves','meta.map_leaves(cb).sorted_keys()'],
  ['reduce-leaves','meta.reduce_leaves(cb)'],['reduce-terminal-tail','meta.reduce_leaves(cb).count_keys()'],
 );
 my @rows=map {{name=>$_->[0],input=>$_->[1]}} @cases;
 for my $role (@{roles()}) {
  push @rows,{name=>'missing-'.$role,missing=>$role};
  push @rows,{name=>'noncode-'.$role,noncode=>$role};
 }
 push @rows,{name=>'trim-result-'.$_->[0],trim_result=>$_->[1]} for ['undefined',undef],['empty',''],['zero','0'];
 push @rows,{name=>'parser-selected-before-trim',replace_parser=>1};
 push @rows,{name=>'parser-undefined-method',method=>undef};
 push @rows,{name=>'parser-missing-args',args=>undef};
 push @rows,{name=>'shared-returned-call',shared_call=>1,input=>'meta.pick_keys(a).drop_keys(b)'};
 push @rows,{name=>'copy-known-array',input=>'meta.copy()',kind=>'array'};
 push @rows,{name=>'copy-unknown-kind',input=>'meta.copy()',kind=>undef};
 push @rows,{name=>'copy-unknown-hash-lookahead',input=>'meta.copy().count_keys()',kind=>undef};
 push @rows,{name=>'copy-unknown-array-lookahead',input=>'meta.copy().sorted()',kind=>undef};
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
  my $outer=sub {invoke_owner($deps,$state)};
  LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer,$deps->{$role}] : [$outer],sub {
   my $captured=LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
   $result={role=>$role,known=>$known,value=>$captured->{value},eligible=>$state->{eligible},
    parent_packet=>LinkedSpec::ActionIR::SourceEmissions::_emission_for($captured,$outer,$event) ? 1 : 0,
    selected_calls=>$state->{calls}{$role},map_identity=>same($deps->{$role},$state->{original}{$role})};
  });
 });
 return $result;
}
sub public_cases {return (['hash-keys','return(hash("b", 2, "a", 1).sorted_keys().join_values(","))'],
 ['hash-value','return(hash("a", 1).set_key("b", 2).count_keys())'])}
sub observations {
 my @public=map {my ($name,$source)=@$_;my ($value,$error);
  eval {$value=LinkedSpec::call_spec_handler_subst('Top',$source);1} or $error=$@;
  {name=>$name,source=>$source,value=>$value,error=>$error}} public_cases();
 my $stderr=gensym;
 my $pid=open3(undef,my $stdout,$stderr,'perl','-Iperl','./t/actionir_hash_receiver_required_cold_probe.pl','observe');
 my $out=do {local $/;<$stdout>//''};
 my $err=do {local $/;<$stderr>//''};
 waitpid($pid,0);
 my $status=$? >> 8;
 return {callbacks=>[map {invoke($_)} @{callback_cases()}],branches=>[map {invoke($_)} @{branch_cases()}],
  authority=>[map {my $role=$_;map {authority($role,$_)} (0,1)} @{roles()}],public=>\@public,
  cold=>{command=>['perl','-Iperl','./t/actionir_hash_receiver_required_cold_probe.pl','observe'],
   returncode=>$status,stderr=>$err,stdout=>$out,value=>$status ? undef : JSON::PP->new->decode($out)}};
}
unless (caller) {
 die 'usage: hash receiver probe observe' unless @ARGV==1 && $ARGV[0] eq 'observe';
 print JSON::PP->new->canonical->encode(observations()),"\n";
}
1;
