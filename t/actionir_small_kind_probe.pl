package SmallKindProbe;
use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use IPC::Open3 qw(open3);
use Symbol qw(gensym);
use LinkedSpec::ActionIR::MethodLowering ();

sub same { ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0 }
sub context { !defined($_[0]) ? 'void' : $_[0] ? 'list' : 'scalar' }
{
 package SmallKindProbe::TrackedMap;
 sub TIEHASH { bless {storage => $_[1], fetches => $_[2], sequence => $_[3]}, $_[0] }
 sub FETCH {
  my ($self, $key) = @_;
  push @{$self->{fetches}}, $key;
  return @{$self->{sequence}} > 1 ? shift @{$self->{sequence}} : $self->{sequence}[0]
   if $key eq 'bare_symbol_kind';
  return $self->{storage}{$key};
 }
 sub STORE { $_[0]{storage}{$_[1]} = $_[2] }
}
{
 package SmallKindProbe::Result;
 use overload '""' => sub {
  my ($self) = @_;
  ++$self->{state}{coercions};
  die $self->{state}{fatal} if $self->{fatal};
  return $self->{text};
 }, fallback => 1;
}

sub setup {
 my ($owner, $options) = @_;
 my $state = {input => exists($options->{input}) ? $options->{input}
   : $owner eq 'infer' ? 'copy(item)' : $owner eq 'target' ? 'array(item)' : 'item',
  events => [], trace => [], fetches => [], eligible => [], coercions => 0,
  fatal => bless({}, 'SmallKindFatal'), args => ['item']};
 my %storage;
 my $record = sub {
  my ($role, $slot, $want, $incoming) = @_;
  push @{$state->{events}}, $role;
  push @{$state->{trace}}, {role => $role,
   args => [ref($$slot) ? {type => ref($$slot), actual_args => same($$slot, $state->{args})} : $$slot],
   context => context($want), incoming_error => ref($incoming) ? {type => ref($incoming)} : $incoming,
   readonly => Internals::SvREADONLY($$slot) ? 1 : 0,
   caller_slot => same($slot, \$state->{input})};
 };
 $state->{replacement} = sub {
  $record->('replacement', \$_[0], wantarray, $@);
  return $options->{replacement_kind} // 'hash';
 };
 $state->{first} = sub { push @{$state->{events}}, 'wrong-first'; return 'WRONG' };
 $state->{returned} = bless({text => $owner eq 'infer' ? 'array' : 'scalar', state => $state,
  fatal => ($options->{outcome} // '') eq 'coercion-fatal'}, 'SmallKindProbe::Result');
 $state->{actual} = sub {
  $record->('kind', \$_[0], wantarray, $@);
  push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0
   if defined &LinkedSpec::ActionIR::SourceEmissions::_eligible_call;
  if (($options->{outcome} // '') eq 'effect') {
   eval { $_[0] .= '!'; 1 } or $state->{write_error} = $@;
  }
  $storage{bare_symbol_kind} = $state->{replacement} if $options->{replace};
  $@ = 'successful small kind';
  die $state->{fatal} if ($options->{outcome} // '') eq 'fatal';
  return undef if ($options->{outcome} // '') eq 'undefined';
  return $state->{returned} if ($options->{outcome} // '') =~ /^(?:reference|coercion-fatal)$/;
  if ($state->{event}) {
   my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
   LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, $state->{emission_text});
   LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
  }
  return $options->{kind} if exists($options->{kind});
  return $owner eq 'infer' ? 'array' : 'scalar';
 };
 $storage{bare_symbol_kind} = $state->{actual};
 $storage{trim_action_ir_value} = sub {
  $record->('trim', \$_[0], wantarray, $@);
  $storage{bare_symbol_kind} = $state->{replacement} if $options->{replace_in_trim};
  return $options->{trim} if exists($options->{trim});
  return $_[0];
 };
 $storage{parse_method_function_expr} = sub {
  $record->('parse', \$_[0], wantarray, $@);
  return $options->{parsed} if exists($options->{parsed});
  if ($options->{recursive}) {
   return {method => 'flat', args => ['copy(item)']} if $_[0] eq 'flat-source';
   return {method => 'copy', args => ['copy(item)']} if $_[0] eq 'nested-source';
  }
  return undef unless defined($_[0]) && $_[0] eq 'copy(item)';
  return {method => $options->{method} // 'copy', args => $state->{args}};
 };
 $storage{normalize_method_args_with_optional_scope} = sub {
  $record->('normalize', \$_[0], wantarray, $@);
  return $options->{normalized} if exists($options->{normalized});
  return $_[0];
 };
 $storage{unrelated} = sub { die 'unrelated small kind dependency invoked' };
 $state->{unrelated} = $storage{unrelated};
 $state->{args} = $options->{args} if exists($options->{args});
 for my $key (qw(__user_function_scalar_value_names __user_function_parameter_kinds)) {
  $storage{$key} = $options->{$key} if exists($options->{$key});
 }
 my $mode = $options->{deps} // 'ordinary';
 delete $storage{bare_symbol_kind} if $mode eq 'missing';
 $storage{bare_symbol_kind} = $options->{bad_kind} if $mode eq 'bad';
 my $deps = \%storage;
 if ($mode =~ /^tied/) {
  my @sequence = $mode eq 'tied-first-bad' ? ('not code')
   : ($state->{first}, $mode eq 'tied-second-bad' ? 'not code' : $state->{actual});
  my %map;
  tie %map, 'SmallKindProbe::TrackedMap', \%storage, $state->{fetches}, \@sequence;
  $deps = \%map;
 }
 $state->{storage} = \%storage;
 $deps = $options->{deps_value} if exists($options->{deps_value});
 $state->{deps} = $deps;
 return $state;
}

sub owner {
 my ($name, $state, $options) = @_;
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_infer_direct_shape_literal_kind = sub {
  push @{$state->{events}}, 'direct-shape';
  return $options->{direct_kind};
 };
 return LinkedSpec::ActionIR::MethodLowering::_infer_assignment_source_container_kind($state->{input}, $state->{deps})
  if $name eq 'infer';
 return LinkedSpec::ActionIR::MethodLowering::_uniform_binding_target_symbol($state->{input},
  exists($options->{container}) ? $options->{container} : 'array', $state->{deps}) if $name eq 'target';
 return LinkedSpec::ActionIR::MethodLowering::_codeblock_variable_call_candidate($state->{deps}, $state->{input})
  if $name eq 'candidate';
 die 'unknown small kind owner';
}

sub observe {
 my ($name, $owner, $options) = @_;
 my $state = setup($owner, $options);
 my ($value, $error, $success_error, $second);
 eval { $@ = 'incoming small kind'; $value = owner($owner, $state, $options); $success_error = $@; 1 }
  or $error = $@;
 if ($options->{replace} && !$error) {
  eval { $second = owner($owner, $state, $options); 1 } or $error = $@;
 }
 return {name => $name, owner => $owner, caller_after => $state->{input}, value => ref($value)
   ? {type => ref($value), same_actual => same($value, $state->{returned})} : $value,
  error => ref($error) ? {type => ref($error), same_fatal => same($error, $state->{fatal})} : $error,
  success_error => $success_error, second => $second, events => $state->{events}, trace => $state->{trace},
  fetches => $state->{fetches}, eligible => $state->{eligible}, write_error => $state->{write_error},
  coercions => $state->{coercions}, args_after => $state->{args},
  deps_shape => ref($state->{deps}) || (defined($state->{deps}) ? 'scalar' : 'undefined'),
  map_actual => ref($state->{deps}) eq 'HASH' ? same($state->{storage}{bare_symbol_kind},
   $options->{replace} || $options->{replace_in_trim} ? $state->{replacement} : $state->{actual}) : undef,
  unrelated => same($state->{storage}{unrelated}, $state->{unrelated})};
}

my @owners = qw(infer target candidate);
if (@ARGV && $ARGV[0] eq 'cold-observe') {
 my $before = $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'} ? 1 : 0;
 my @rows;
 for my $owner (@owners) {
  push @rows, observe($owner.'/'.$_, $owner, {outcome => $_}) for qw(string effect fatal);
 }
 print JSON::PP->new->canonical->encode({loaded_before => $before,
  loaded_after => $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'} ? 1 : 0, rows => \@rows}), "\n";
 exit 0;
}
die 'use observe or cold-observe' unless @ARGV && $ARGV[0] eq 'observe';
require LinkedSpec::ActionIR::SourceOrigins;
require LinkedSpec::ActionIR::SourceEmissions;
my (@callbacks, @branches, @authority);
for my $owner (@owners) {
 push @callbacks, observe($owner.'/'.$_, $owner, {outcome => $_})
  for qw(string effect undefined fatal reference coercion-fatal);
 my @cases = (
  ['missing', {deps => 'missing'}],
  ['kind-undefined', {deps => 'bad', bad_kind => undef}],
  ['kind-string', {deps => 'bad', bad_kind => 'not code'}],
  ['kind-reference', {deps => 'bad', bad_kind => {}}],
  ['kind-blessed', {deps => 'bad', bad_kind => bless({}, 'NotSmallKindCode')}],
  ['tied-selection', {deps => 'tied-selection'}],
  ['tied-first-bad', {deps => 'tied-first-bad'}],
  ['tied-second-bad', {deps => 'tied-second-bad'}],
  ['map-replacement', {replace => 1}],
  ['result-empty', {kind => ''}], ['result-zero', {kind => '0'}],
  ['result-array', {kind => 'array'}], ['result-hash', {kind => 'hash'}],
  ['result-scalar', {kind => 'scalar'}], ['result-unknown', {kind => 'unknown'}],
  ['input-undefined', {input => undef}], ['input-empty', {input => ''}],
  ['input-zero', {input => '0'}], ['input-invalid', {input => 'bad input'}],
  ['deps-undefined', {deps_value => undef}], ['deps-string', {deps_value => 'not map'}],
  ['deps-array', {deps_value => []}], ['deps-blessed', {deps_value => bless({}, 'NotSmallKindMap')}],
 );
 if ($owner eq 'infer') {
  push @cases,
   ['selection-before-trim', {replace_in_trim => 1}],
   ['direct-shape', {direct_kind => 'hash'}], ['trim-undefined', {trim => undef}],
   ['trim-empty', {trim => ''}], ['trim-zero', {trim => '0'}],
   ['parsed-undefined', {parsed => undef}], ['parsed-zero', {parsed => 0}],
   ['method-array', {method => 'sorted'}], ['method-hash', {method => 'entry_map'}],
   ['method-unknown', {method => 'unknown'}], ['normalized-undefined', {normalized => undef}],
   ['normalized-empty', {normalized => []}], ['copy-array', {args => ['array(x)']}],
   ['copy-hash', {args => ['hash(x)']}], ['copy-complex', {args => ['complex value']}],
   ['flat-recursive', {input => 'flat-source', recursive => 1}],
   ['copy-recursive', {input => 'nested-source', recursive => 1}],
   ['recursive-replacement', {input => 'flat-source', recursive => 1, replace_in_trim => 1}];
 } elsif ($owner eq 'target') {
  push @cases, ['bare-name', {input => 'item'}], ['wrong-container', {input => 'hash(item)'}],
   ['container-undefined', {container => undef}], ['container-empty', {container => ''}],
   ['spaced-name', {input => 'array ( item )'}], ['compound-target', {input => 'array(item.other)'}];
 } else {
  push @cases,
   ['function-name-present', {__user_function_scalar_value_names => {item => 1}}],
   ['function-name-false', {__user_function_scalar_value_names => {item => 0}}],
   ['function-name-absent', {__user_function_scalar_value_names => {}}],
   ['function-name-bad-shape', {__user_function_scalar_value_names => []}],
   ['parameter-codeblock', {__user_function_parameter_kinds => {item => 'codeblock'}}],
   ['parameter-scalar', {__user_function_parameter_kinds => {item => 'scalar'}}],
   ['parameter-zero', {__user_function_parameter_kinds => {item => '0'}}],
   ['parameter-absent', {__user_function_parameter_kinds => {}}],
   ['parameter-bad-shape', {__user_function_parameter_kinds => []}],
   ['function-before-parameter', {__user_function_scalar_value_names => {},
      __user_function_parameter_kinds => {item => 'codeblock'}}],
   ['early-name-tied', {deps => 'tied-second-bad', __user_function_scalar_value_names => {item => 1}}],
   ['early-parameter-tied', {deps => 'tied-second-bad', __user_function_parameter_kinds => {item => 'codeblock'}}];
 }
 push @branches, observe($owner.'/'.$_->[0], $owner, $_->[1]) for @cases;
 for my $known (0, 1) {
  LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', sub {
   my $event = {raw => 'same'};
   LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
    {event => $event, source => 'same', source_span => {start => 0, end => 4}});
   my $state = setup($owner, {});
   $state->{event} = $event;
   $state->{emission_text} = $owner eq 'infer' ? 'array' : $owner eq 'target' ? 'item' : '1';
   my $outer = sub { return owner($owner, $state, {}) };
   LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers(
    $known ? [$outer, $state->{actual}] : [$outer], sub {
     my $result = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
     push @authority, {owner => $owner, known => $known, value => $result->{value},
      eligible => $state->{eligible}, events => $state->{events}, trace => $state->{trace},
      actual_map_identity => same($state->{storage}{bare_symbol_kind}, $state->{actual}),
      parent_packet => LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event) ? 1 : 0};
    });
  });
 }
}
my $err_handle = gensym;
my $pid = open3(undef, my $out_handle, $err_handle, 'perl', '-Iperl', './t/actionir_small_kind_probe.pl', 'cold-observe');
my $out = do { local $/; <$out_handle> // '' };
my $err = do { local $/; <$err_handle> // '' };
waitpid($pid, 0);
my $cold = {returncode => $? >> 8, stderr => $err, value => length($out) ? JSON::PP->new->decode($out) : undef};
print JSON::PP->new->canonical->encode({callbacks => \@callbacks, branches => \@branches,
 authority => \@authority, cold => $cold}), "\n";
