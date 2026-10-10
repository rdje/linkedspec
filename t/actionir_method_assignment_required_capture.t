use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my %owners = (assign => '_lower_assign_statement', scalar => '_lower_scalar_assignment_operator_statement',
 append => '_lower_array_append_operator_statement');
my @roles = qw(extract_scalar_symbol_name extract_array_symbol_name extract_hash_symbol_name
 lower_assignment_source_expr lower_declare_initializer_expr trim_action_ir_value);
my @targets = (['assign','trim_action_ir_value','scalar'], ['assign','extract_scalar_symbol_name','scalar'],
 ['assign','extract_array_symbol_name','array'], ['assign','extract_hash_symbol_name','hash'],
 ['assign','lower_assignment_source_expr','scalar'], ['assign','lower_declare_initializer_expr','array'],
 ['assign','lower_declare_initializer_expr','hash'], ['scalar','trim_action_ir_value','fallback'],
 ['append','trim_action_ir_value','fallback']);
sub same {ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0}
sub encoded {
 my ($value) = @_;
 return $value unless ref($value);
 return {type => 'HASH', marker => $value->{marker}} if ref($value) eq 'HASH';
 return {type => ref($value)};
}
sub setup {
 my ($which,$role,$route,$outcome,$options) = @_;
 $options ||= {};
 my $state = {which=>$which,role=>$role,route=>$route,outcome=>$outcome,options=>$options,
  input=>exists($options->{input}) ? $options->{input} : $which eq 'scalar' ? 'counter = payload' : 'items += payload',
  target=>exists($options->{target}) ? $options->{target} : 'legacy target',
  source=>exists($options->{source}) ? $options->{source} : 'source payload',
  trace=>[],helpers=>[],events=>[],eligible=>[],slots=>[],calls=>0,reference=>{marker=>'actual-result'}};
 my $fatal = bless {}, 'MethodAssignmentRequiredFatal';
 my %deps;
 for my $name (@roles) {
  $deps{$name} = sub {
   my @readonly = map {Internals::SvREADONLY($_) ? 1 : 0} @_;
   my @args = map {encoded($_)} @_;
   my $context = !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar';
   push @{$state->{events}},$name;
   $state->{first_trim_slot} ||= \$_[0] if $name eq 'trim_action_ir_value';
   $state->{last_trim_slot} = \$_[0] if $name eq 'trim_action_ir_value';
   push @{$state->{slots}},[map {\$_} @_];
   push @{$state->{trace}},{role=>$name,args=>\@args,readonly=>\@readonly,context=>$context,error=>$@,
    original_input_slot=>same(\$_[0],\$state->{input}),original_target_slot=>same(\$_[0],\$state->{target}),
    original_source_slot=>same(\$_[0],\$state->{source}),same_first_trim_slot=>same(\$_[0],$state->{first_trim_slot})};
   my $result;
   if ($name eq 'trim_action_ir_value') {
    $result = exists($options->{trim}) ? $options->{trim}
     : exists($options->{second_trim}) && @{$state->{trace}} > 1 && $which ne 'assign' ? $options->{second_trim} : $_[0];
   } elsif ($name =~ /^extract_(scalar|array|hash)_symbol_name$/) {
    my $kind=$1;
    $result = exists($options->{$name}) ? $options->{$name} : $kind eq $route ? uc($kind).'_SLOT' : undef;
   } elsif ($name eq 'lower_assignment_source_expr') {
    $result = $options->{source_reference} ? $state->{reference} : exists($options->{source_result}) ? $options->{source_result} : 'VALUE';
   } else {
    $result = exists($options->{initializer}) ? $options->{initializer} : 'INIT';
   }
   if ($name eq $role) {
    ++$state->{calls};
    $_[0] .= '!' if @_ && defined($_[0]) && !ref($_[0]) && !$readonly[0];
    $_[1] .= '!' if $name eq 'lower_declare_initializer_expr' && @_ > 1 && !$readonly[1];
    $@='successful assignment required callback';
    push @{$state->{eligible}},LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    die $fatal if $outcome eq 'fatal';
    return undef if $outcome eq 'undefined';
    if ($state->{event} && $state->{calls} == 1) {
     my $builder=LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
     LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder,$state->{publication});
     LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
    }
   }
   return $result;
  };
 }
 $deps{bare_symbol_kind}=sub {
  push @{$state->{events}},'kind';
  push @{$state->{helpers}},{name=>'kind',args=>[map {encoded($_)} @_],same_first_trim_slot=>same(\$_[0],$state->{first_trim_slot})};
  my $result=$options->{kind};
  $_[0].='!' if $options->{kind_mutation};
  return $result;
 };
 $deps{bare_symbol_kind}=undef if $options->{kind_noncode};
 $state->{original}={%deps};
 return (\%deps,$state,$fatal);
}
sub owner {
 my ($deps,$state)=@_;
 my $options=$state->{options};
 my $helper=sub {
  my ($name,$args,$map)=@_;
  push @{$state->{events}},$name;
  my $row={name=>$name,args=>[map {encoded($_)} @$args]};
  $row->{actual_map}=same($map,$deps) if defined $map;
  push @{$state->{helpers}},$row;
 };
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_retired_colon_scalar_slot_expr=sub {
  $helper->('retired',[@_]); return 'RETIRED';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_value_binding_source_expr=sub {
  $helper->('binding',[@_],$_[1]);
  $state->{helpers}[-1]{same_last_trim_slot}=same(\$_[0],$state->{last_trim_slot});
  return $state->{reference} if $options->{binding_reference};
  return exists($options->{binding}) ? $options->{binding} : 'BOUND';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_tracked_scalar_assignment_expr=sub {
  $helper->('tracked',[@_],$_[2]);
  return $_[1] if $options->{tracked_echo};
  return exists($options->{tracked}) ? $options->{tracked} : 'TRACKED';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_parse_method_value_ast_expr=sub {
  $helper->('ast-value',[@_],$_[1]); return {marker=>'controlled-ast'};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_assignment_operator_statement=sub {
  $helper->('ast-assignment',[@_],$_[1]);
  return $state->{reference} if $options->{ast_reference};
  return $options->{ast};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr=sub {
  $helper->('mutation',[@_],$_[1]);
  $state->{helpers}[-1]{same_last_trim_slot}=same(\$_[0],$state->{last_trim_slot});
  return exists($options->{mutation}) ? $options->{mutation} : 'MUTATION';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_array_push_expr=sub {
  $helper->('push',[@_]); return exists($options->{push}) ? $options->{push} : 'PUSH';
 };
 return LinkedSpec::ActionIR::MethodLowering::_lower_assign_statement($state->{target},$state->{source},$deps) if $state->{which} eq 'assign';
 return LinkedSpec::ActionIR::MethodLowering::_lower_scalar_assignment_operator_statement($state->{input},$deps) if $state->{which} eq 'scalar';
 return LinkedSpec::ActionIR::MethodLowering::_lower_array_append_operator_statement($state->{input},$deps);
}
sub branch_cases {
 my @cases;
 my @binding=qw(trim_action_ir_value binding tracked);
 push @cases, ['assign-retired','assign','none',{target=>':counter'},'RETIRED',[qw(trim_action_ir_value retired)]];
 push @cases, ['assign-bare','assign','none',{target=>'counter'},'TRACKED',\@binding];
 for my $value ('', '0', undef) {
  my $nonempty=defined($value) && length($value);
  push @cases, ['assign-binding-'.($value//'undefined'),'assign','none',{target=>'counter',binding=>$value},
   $nonempty?'TRACKED':undef,$nonempty?\@binding:[qw(trim_action_ir_value binding)]];
 }
 push @cases, ['assign-binding-reference','assign','none',{target=>'counter',binding_reference=>1,tracked_echo=>1},
  {type=>'HASH',marker=>'actual-result'},\@binding];
 for my $wrapper ('array','hash') {
  push @cases, ["assign-$wrapper-held",'assign','none',{target=>"$wrapper(counter)",kind=>'scalar',kind_mutation=>1},
   'TRACKED',[qw(trim_action_ir_value kind binding tracked)]];
  for my $kind (undef,'array') {
   push @cases, ["assign-$wrapper-kind-".($kind//'undefined'),'assign','none',{target=>"$wrapper(counter)",kind=>$kind},undef,
    [qw(trim_action_ir_value kind extract_scalar_symbol_name extract_array_symbol_name extract_hash_symbol_name)]];
  }
  push @cases, ["assign-$wrapper-noncode-kind",'assign','none',{target=>"$wrapper(counter)",kind_noncode=>1},undef,
   [qw(trim_action_ir_value extract_scalar_symbol_name extract_array_symbol_name extract_hash_symbol_name)]];
 }
 push @cases, ['assign-unsupported','assign','none',{},undef,
  [qw(trim_action_ir_value extract_scalar_symbol_name extract_array_symbol_name extract_hash_symbol_name)]];
 for my $target (undef,'','0') {
  push @cases, ['assign-target-'.($target//'undefined'),'assign','scalar',{target=>$target},'TRACKED',
   [qw(trim_action_ir_value extract_scalar_symbol_name lower_assignment_source_expr tracked)]];
 }
 for my $route ('scalar','array','hash') {
  my @events=('trim_action_ir_value','extract_scalar_symbol_name');
  push @events,'extract_array_symbol_name' if $route ne 'scalar';
  push @events,'extract_hash_symbol_name' if $route eq 'hash';
  my $role=$route eq 'scalar'?'lower_assignment_source_expr':'lower_declare_initializer_expr';
  for my $value ('', '0', undef) {
   my $options={$route eq 'scalar'?'source_result':'initializer'=>$value};
   my $expected=!defined($value)?undef:$route eq 'scalar'?'TRACKED':($route eq 'array'?'@ARRAY_SLOT = ':'%HASH_SLOT = ').$value;
   push @cases, ["assign-$route-value-".($value//'undefined'),'assign',$route,$options,$expected,
    [@events,$role,defined($value) && $route eq 'scalar'?'tracked':()]];
  }
 }
 push @cases, ['assign-source-reference','assign','scalar',{source_reference=>1,tracked_echo=>1},
  {type=>'HASH',marker=>'actual-result'},[qw(trim_action_ir_value extract_scalar_symbol_name lower_assignment_source_expr tracked)]];
 for my $which ('scalar','append') {
  my $tail=$which eq 'scalar'?'TRACKED':'PUSH';
  my @ast=qw(trim_action_ir_value ast-value ast-assignment);
  my @full=(@ast,'trim_action_ir_value',$which eq 'scalar'?'binding':'mutation',$which eq 'scalar'?'tracked':'push');
  for my $input (undef,'','not an assignment',$which eq 'scalar'?'x == y':'x = y',$which eq 'scalar'?'x => y':'x + y') {
   push @cases, ["$which-input-".($input//'undefined'),$which,'fallback',{input=>$input},undef,
    defined($input) && length($input)?\@ast:['trim_action_ir_value']];
  }
  for my $ast ('FAST','0','') {
   push @cases, ["$which-ast-$ast",$which,'fallback',{ast=>$ast},length($ast)?$ast:$tail,length($ast)?\@ast:\@full];
  }
  push @cases, ["$which-ast-reference",$which,'fallback',{ast_reference=>1},{type=>'HASH',marker=>'actual-result'},\@ast];
  for my $value ('', '0', undef) {
   my $nonempty=defined($value) && length($value);
   push @cases, ["$which-rhs-".($value//'undefined'),$which,'fallback',{second_trim=>$value},$nonempty?$tail:undef,
    $nonempty?\@full:[@ast,'trim_action_ir_value']];
   my $helper=$which eq 'scalar'?'binding':'mutation';
   push @cases, ["$which-$helper-".($value//'undefined'),$which,'fallback',{$helper=>$value},$nonempty?$tail:undef,
    $nonempty?\@full:[@ast,'trim_action_ir_value',$helper]];
  }
  push @cases, ["$which-final-undefined",$which,'fallback',{$which eq 'scalar'?'tracked':'push'=>undef},undef,\@full];
 }
 return \@cases;
}
sub public_cases {
 return (['set','set(counter, 1)',undef],['scalar','counter = 1',undef],['append','items += 1',undef],
  ['array-selector','set(array(items), 1)',"aggregate_selector_removed surface=array identifier=items replacement=items\n"],
  ['hash-selector','set(hash(meta), 1)',"aggregate_selector_removed surface=hash identifier=meta replacement=meta\n"]);
}
sub observations {
 my @public=map {my ($case,$source)=@$_;my ($value,$error);
  eval {$value=LinkedSpec::call_spec_handler_subst('Top',$source);1} or $error=$@;
  {case=>$case,source=>$source,value=>$value,error=>$error}} public_cases();
 return {callbacks=>[map {my ($which,$role,$route)=@$_;map {invoke($which,$role,$route,$_)} qw(string undefined fatal)} @targets],
  branches=>[map {{case=>$_->[0],%{invoke($_->[1],'none',$_->[2],'string',$_->[3])}}} @{branch_cases()}],public=>\@public};
}
if (@ARGV && $ARGV[0] eq 'observe') {print JSON::PP->new->canonical->encode(observations()),"\n";exit 0}
for my $target (@targets) {
 my ($which,$role,$route)=@$target;
 my $name="$owners{$which}/$role/$route";
 for my $outcome (qw(string undefined fatal)) {
  my $row=invoke($which,$role,$route,$outcome);
  my $label="$name/$outcome";
  is($row->{calls},$which ne 'assign' && $outcome eq 'string'?2:1,"$label native invocation count");
  ok($row->{map_identity},"$label actual public callback references survive");
  my @calls=grep {$_->{role} eq $role} @{$row->{trace}};
  for my $i (0..$#calls) {
   my $call=$calls[$i];
   is($call->{context},'scalar',"$label/$i required scalar context stays native");
   is($call->{error},$i?'successful assignment required callback':'incoming assignment required error',"$label/$i native incoming error");
   is_deeply($call->{readonly},$role eq 'lower_declare_initializer_expr'?[1,0]:[0],"$label/$i readonly kind and writable source");
   is($call->{original_input_slot},0,"$label/$i input is a local copy");
   is($call->{original_target_slot},0,"$label/$i target is a local copy");
   is($call->{original_source_slot},0,"$label/$i source is a local copy");
   is($call->{same_first_trim_slot},$which eq 'assign' && $role =~ /^(?:trim|extract)_/ || $which ne 'assign' && !$i ?1:0,
    "$label/$i shared target slot or distinct RHS slot");
  }
  is($row->{input_after},$which eq 'scalar'?'counter = payload':'items += payload',"$label caller input survives");
  is($row->{target_after},'legacy target',"$label caller target survives");
  is($row->{source_after},'source payload',"$label caller source survives");
  if ($outcome eq 'fatal') {
   is_deeply($row->{error},{type=>'MethodAssignmentRequiredFatal',same_fatal=>1},"$label fatal object retains actual identity");
  } else {
   is($row->{error},undef,"$label bounded native route completes");
   is($row->{success_error},'successful assignment required callback',"$label successful error effect survives");
   my $expected=$outcome eq 'undefined' && $role ne 'trim_action_ir_value'?undef
    :$outcome eq 'undefined' && $which ne 'assign'?undef:$which eq 'scalar'?'TRACKED':$which eq 'append'?'PUSH'
    :$route eq 'scalar'?'TRACKED':$route eq 'array'?'@ARRAY_SLOT = INIT':'%HASH_SLOT = INIT';
   is($row->{value},$expected,"$label ordinary result stays native");
   if ($which ne 'assign' && $outcome eq 'string') {
    my ($helper)=grep {$_->{name} eq ($which eq 'scalar'?'binding':'mutation')} @{$row->{helpers}};
    is($helper->{same_last_trim_slot},1,"$label RHS helper receives actual second trim slot");
    is_deeply($row->{slots_after},[[''.($which eq 'scalar'?'counter = payload!':'items += payload!')],['payload']],
     "$label first mutation survives while RHS trim assignment replaces its mutation");
   }
   if ($role eq 'lower_declare_initializer_expr') {
    is_deeply($row->{slots_after}[-1],[$route,'source payload!'],"$label literal kind stays readonly and source mutation remains local");
   }
  }
 }
 my $baseline=invoke($which,$role,$route,'string');
 for my $known (0,1) {
  LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same',sub {
   my $event={raw=>'same'};
   LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,{event=>$event,source=>'same',source_span=>{start=>0,end=>4}});
   my ($deps,$state)=setup($which,$role,$route,'string');
   $state->{event}=$event;$state->{publication}=$baseline->{value};
   my $outer=sub {return owner($deps,$state)};
   LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known?[$outer,$deps->{$role}]:[$outer],sub {
    my $result=LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
    is($result->{value},$baseline->{value},"$name/$known ordinary value survives");
    ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result,$outer,$event),"$name/$known required dependency cannot donate nested publication");
    is_deeply($state->{eligible},[($known) x $baseline->{calls}],"$name/$known actual callback has its own identity boundary");
    is($state->{calls},$baseline->{calls},"$name/$known actual effect count survives");
    is(refaddr($deps->{$role}),refaddr($state->{original}{$role}),"$name/$known public callback stays actual");
   });
  });
 }
}
for my $which ('assign','scalar','append') {
 my @required=$which eq 'assign'?@roles:('trim_action_ir_value');
 for my $role (@required) {
  for my $bad (undef,'not code') {
   my ($deps,$state)=setup($which,'none','scalar','string');
   $deps->{$role}=$bad;
   my $error;eval {owner($deps,$state);1} or $error=$@;
   like($error,qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$role\E'/,
    "$owners{$which}/$role required diagnostic retains native selection");
   is_deeply($state->{events},[],"$owners{$which}/$role eager validation stops before callbacks and helpers");
  }
 }
 my ($deps,$state)=setup($which,'none','scalar','string');
 $_=undef for values %$deps;
 my $error;eval {owner($deps,$state);1} or $error=$@;
 like($error,qr/missing dependency callback '\Q$required[0]\E'/,"$owners{$which} retains first missing required role");
}
my $rows=observations();
my $cases=branch_cases();
for my $i (0..$#$cases) {
 my ($label,$which,$route,$options,$expected,$events)=@{$cases->[$i]};
 my $row=$rows->{branches}[$i];
 is_deeply($row->{value},$expected,"$label keeps bounded native value");
 is_deeply($row->{events},$events,"$label exact guard and fallback order");
 ok($row->{map_identity},"$label actual callback references survive");
 is($row->{error},undef,"$label bounded branch completes");
 is($row->{reference_identity},$label =~ /reference$/?1:0,"$label direct reference identity");
 for my $helper (@{$row->{helpers}}) {is($helper->{actual_map},1,"$label actual helper map") if exists $helper->{actual_map}}
 if ($label =~ /-held$/) {
  my ($kind)=grep {$_->{name} eq 'kind'} @{$row->{helpers}};
  my ($tracked)=grep {$_->{name} eq 'tracked'} @{$row->{helpers}};
  is($kind->{same_first_trim_slot},0,"$label optional kind gets its distinct captured name slot");
  is($tracked->{args}[0],'counter!',"$label optional kind mutation reaches tracked local name");
 }
}
my @public=public_cases();
for my $i (0..$#public) {
 my ($name,$source,$error)=@{$public[$i]};
 my $row=$rows->{public}[$i];
 is($row->{error},$error,"$name actual public Toolbox diagnostic");
 if (defined $error) {is($row->{value},undef,"$name rejected selector has no generated value")}
 else {ok(defined($row->{value}) && length($row->{value}),"$name actual public Toolbox produces lowering")}
}
done_testing;
sub invoke {
 my ($which,$role,$route,$outcome,$options)=@_;
 my ($deps,$state,$fatal)=setup(@_);
 my ($value,$error,$success_error);
 eval {$@='incoming assignment required error';$value=owner($deps,$state);$success_error=$@;1} or $error=$@;
 my $map_identity=!grep {!same($deps->{$_},$state->{original}{$_}) && (defined($deps->{$_}) || defined($state->{original}{$_}))} keys %{$state->{original}};
 return {owner=>$which,role=>$role,route=>$route,outcome=>$outcome,value=>encoded($value),calls=>$state->{calls},
  trace=>$state->{trace},events=>$state->{events},helpers=>$state->{helpers},input_after=>$state->{input},
  target_after=>$state->{target},source_after=>$state->{source},map_identity=>$map_identity ? 1 : 0,
  slots_after=>[map {[map {encoded($$_)} @$_]} @{$state->{slots}}],
  reference_identity=>same($value,$state->{reference}),success_error=>$success_error,
  error=>ref($error) ? {type=>ref($error),same_fatal=>same($error,$fatal)} : $error};
}
