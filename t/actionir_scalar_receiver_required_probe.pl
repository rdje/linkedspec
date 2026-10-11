package ScalarReceiverRequiredProbe;
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

sub families {return [qw(number string)]}
sub input_for {return $_[0] eq 'number' ? 'score.abs()' : 'raw.trim()'}
sub value_for {return $_[0] eq 'number' ? 'num_abs(score)' : 'trim(raw)'}
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
 my $state={family=>$options->{family}, input=>exists($options->{input}) ? $options->{input} : input_for($options->{family}),
  options=>$options, trace=>[], events=>[], slots=>[], calls=>{}, eligible=>[], parsed=>[],
  fatal=>bless({},'ScalarReceiverRequiredFatal')};
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
    if (exists($options->{trim_result}) && $state->{calls}{$role}==1) {
     $result=$options->{trim_result};
    }
   } else {
    if (defined($_[0]) && $_[0]=~/^([a-z_]+)\((.*)\)$/s) {
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
   }
   if ($role eq ($options->{role}//'')) {
    push @{$state->{eligible}},LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    $_[0].='!' if ($options->{outcome}//'') eq 'effect' && defined($_[0]);
    $@='successful scalar receiver required callback';
    die $state->{fatal} if ($options->{outcome}//'') eq 'fatal';
    return undef if ($options->{outcome}//'') eq 'undefined';
    if ($state->{event} && $state->{calls}{$role}==1) {
     my $builder=LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
     LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder,value_for($state->{family}));
     LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
    }
   }
   return $result;
  };
 }
 $deps{bare_symbol_kind}=sub {++$state->{optional_kind_calls};return 'hash'};
 $state->{replacement_parser}=sub {push @{$state->{events}},'replacement_parser';return {method=>'count',args=>[]}};
 $state->{original}={%deps};
 delete $deps{$options->{missing}} if $options->{missing};
 $deps{$options->{noncode}}='not code' if $options->{noncode};
 return (\%deps,$state);
}
sub invoke_owner {
 my ($deps,$state)=@_;
 return $state->{family} eq 'number'
  ? LinkedSpec::ActionIR::MethodLowering::_normalize_number_receiver_value_chain_expr($state->{input},$deps)
  : LinkedSpec::ActionIR::MethodLowering::_normalize_string_receiver_value_chain_expr($state->{input},$deps);
}
sub invoke {
 my ($options)=@_;
 my ($deps,$state)=setup($options);
 my ($value,$error,$success_error);
 eval {$@='incoming scalar receiver required error';$value=invoke_owner($deps,$state);$success_error=$@;1} or $error=$@;
 return {name=>$options->{name},family=>$state->{family},value=>encoded($value),trace=>$state->{trace},events=>$state->{events},
  calls=>$state->{calls},caller_after=>$state->{input},parsed_after=>encoded($state->{parsed}),
  parsed_same=>[map {my $current=$_; [map {same($current,$_)} @{$state->{parsed}}]} @{$state->{parsed}}],
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
 for my $family (@{families()}) {
  for my $role (@{roles()}) {
   for my $outcome (qw(string effect undefined fatal)) {
    push @cases,{name=>$family.'-'.$role.'-'.$outcome,family=>$family,role=>$role,outcome=>$outcome};
   }
  }
 }
 return \@cases;
}
sub branch_cases {
 my @rows;
 for my $family (@{families()}) {
  my $method=$family eq 'number' ? 'abs' : 'trim';
  my @cases=(
   ['undefined-input',undef],['empty-input',''],['whitespace-input','  '],['zero-input','0'],
   ['no-dot','item'],['empty-receiver','.'.$method.'()'],['empty-tail','item.'],
   ['decimal-receiver','1.5.'.$method.'()'],['quoted-dot','"a.b".'.$method.'()'],
   ['nested-dot','scalar(item).'.$method.'()'],['malformed-call','item.'.$method],
   ['unknown-call','item.unknown()'],['wrong-family','item.sorted()'],
  );
  if ($family eq 'number') {
   push @cases,
    ['numeric-chain','score.abs().floor().ceil().round().add(1, 2).mul(2).sub(1).div(2).mod(3).clamp(0, 9).min(8).max(2)'],
    ['unary-excess','score.abs(1)'],['binary-missing','score.sub()'],['binary-excess','score.div(1, 2)'],
    ['clamp-missing','score.clamp(1)'],['clamp-excess','score.clamp(1, 2, 3)'],['variadic-missing','score.add()'],
    ['comparison','score.abs().gt(2)'],['terminal-chain','score.eq(1).abs()'],
    ['unknown-tail','score.abs().unknown()'];
  } else {
   push @cases,
    ['string-chain','raw.trim().lowercase().uppercase().cat("a", "b").substr(1, 2).coalesce_nonempty("x")'],
    ['unary-excess','raw.trim(1)'],['cat-missing','raw.cat()'],['length','raw.length()'],
    ['terminal-chain','raw.length().trim()'],['unknown-tail','raw.trim().unknown()'],
    ['split-join','raw.split(":").join_values("-")'],['join-missing','raw.split(":").join_values()'],
    ['join-excess','raw.split(":").join_values("-", "!")'],['split-sum','raw.split(":").sum()'],
    ['sum-excess','raw.split(":").sum(1)'],['split-transform','raw.split(":").trim_each().uniq().count()'],
    ['array-generic','raw.split(":").take(2).slice(0, 1).sorted()'],
    ['array-terminal-tail','raw.split(":").count().trim()'],['array-wrong-family','raw.split(":").abs()'];
  }
  push @rows,map {{name=>$family.'-'.$_->[0],family=>$family,input=>$_->[1]}} @cases;
  for my $role (@{roles()}) {
   push @rows,{name=>$family.'-missing-'.$role,family=>$family,missing=>$role};
   push @rows,{name=>$family.'-noncode-'.$role,family=>$family,noncode=>$role};
  }
  push @rows,{name=>$family.'-trim-result-'.$_->[0],family=>$family,trim_result=>$_->[1]}
   for ['undefined',undef],['empty',''],['zero','0'];
  push @rows,{name=>$family.'-parser-selected-before-trim',family=>$family,replace_parser=>1};
  push @rows,{name=>$family.'-parser-undefined-method',family=>$family,method=>undef};
  push @rows,{name=>$family.'-parser-missing-args',family=>$family,args=>undef};
  push @rows,{name=>$family.'-shared-returned-call',family=>$family,shared_call=>1,
   input=>$family eq 'number' ? 'score.abs().floor()' : 'raw.trim().lowercase()'};
 }
 return \@rows;
}
sub authority {
 my ($family,$role,$known)=@_;
 my ($deps,$state)=setup({family=>$family,role=>$role,outcome=>'string'});
 my $result;
 LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same',sub {
  my $event={raw=>'same'};
  LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
   {event=>$event,source=>'same',source_span=>{start=>0,end=>4}});
  $state->{event}=$event;
  my $outer=sub {invoke_owner($deps,$state)};
  LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer,$deps->{$role}] : [$outer],sub {
   my $captured=LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
   $result={family=>$family,role=>$role,known=>$known,value=>$captured->{value},eligible=>$state->{eligible},
    parent_packet=>LinkedSpec::ActionIR::SourceEmissions::_emission_for($captured,$outer,$event) ? 1 : 0,
    selected_calls=>$state->{calls}{$role},map_identity=>same($deps->{$role},$state->{original}{$role})};
  });
 });
 return $result;
}
sub public_cases {return (['number-decimal','return(3.5.floor().add(1))'],
 ['number-terminal','return(5.abs().gt(2))'],['string-transform','return(" A ".trim().lowercase())'],
 ['string-array','return("a:b".split(":").join_values("-"))'])}
sub observations {
 my @public=map {my ($name,$source)=@$_;my ($value,$error);
  eval {$value=LinkedSpec::call_spec_handler_subst('Top',$source);1} or $error=$@;
  {name=>$name,source=>$source,value=>$value,error=>$error}} public_cases();
 my $stderr=gensym;
 my $pid=open3(undef,my $stdout,$stderr,'perl','-Iperl','./t/actionir_scalar_receiver_required_cold_probe.pl','observe');
 my $out=do {local $/;<$stdout>//''};
 my $err=do {local $/;<$stderr>//''};
 waitpid($pid,0);
 my $status=$? >> 8;
 return {callbacks=>[map {invoke($_)} @{callback_cases()}],branches=>[map {invoke($_)} @{branch_cases()}],
  authority=>[map {my $family=$_;map {my $role=$_;map {authority($family,$role,$_)} (0,1)} @{roles()}} @{families()}],public=>\@public,
  cold=>{command=>['perl','-Iperl','./t/actionir_scalar_receiver_required_cold_probe.pl','observe'],
   returncode=>$status,stderr=>$err,stdout=>$out,value=>$status ? undef : JSON::PP->new->decode($out)}};
}
unless (caller) {
 die 'usage: scalar receiver probe observe' unless @ARGV==1 && $ARGV[0] eq 'observe';
 print JSON::PP->new->canonical->encode(observations()),"\n";
}
1;
