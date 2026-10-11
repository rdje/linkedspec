package DroppedTrimProbe;
use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use IPC::Open3 qw(open3);
use Symbol qw(gensym);
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

sub same { ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0 }
sub encoded {
 my ($value) = @_;
 return $value unless ref($value);
 return [map { encoded($_) } @$value] if ref($value) eq 'ARRAY';
 return {map { $_ => encoded($value->{$_}) } sort keys %$value} if ref($value) eq 'HASH';
 return {type => ref($value)};
}

{
 package DroppedTrimProbe::TrackedMap;
 sub TIEHASH { bless {storage => $_[1], fetches => $_[2], sequence => $_[3]}, $_[0] }
 sub FETCH {
  my ($self, $key) = @_;
  push @{$self->{fetches}}, $key;
  return @{$self->{sequence}} > 1 ? shift @{$self->{sequence}} : $self->{sequence}[0]
   if $key eq 'trim_action_ir_value';
  return $self->{storage}{$key};
 }
 sub STORE { $_[0]{storage}{$_[1]} = $_[2] }
}

sub setup {
 my ($options) = @_;
 my $state = {input => exists($options->{input}) ? $options->{input} : 'call(value)',
  trace => [], slots => [], events => [], fetches => [], eligible => [],
  fatal => bless({}, 'DroppedTrimFatal'), trim_reference => {trim => 'reference'}};
 my $record = sub {
  my ($role, $slot, $context, $incoming, $deps) = @_;
  push @{$state->{events}}, $role;
  push @{$state->{trace}}, {role => $role, args => [encoded($$slot)], context => $context,
   readonly => Internals::SvREADONLY($$slot) ? 1 : 0, incoming_error => $incoming,
   caller_slot => same($slot, \$state->{input}),
   input_reference => same($$slot, $state->{input}),
   trim_reference => same($$slot, $state->{trim_reference}),
   deps_reference => same($deps, $state->{deps}),
   previous_slots => [map { same($slot, $_) } @{$state->{slots}}]};
  push @{$state->{slots}}, $slot;
 };
 my %storage;
 $state->{record} = $record;
 $state->{replacement} = sub {
  $record->('replacement', \$_[0], !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', $@);
  return 'call(replaced)';
 };
 $state->{first} = sub { push @{$state->{events}}, 'wrong-first-reference'; return 'FIRST' };
 $state->{actual} = sub {
  $record->('trim', \$_[0], !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', $@);
  push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
  if (($options->{outcome} // '') eq 'effect') {
   $_[0] .= '!' unless ref($_[0]);
  }
  $storage{trim_action_ir_value} = $state->{replacement} if $options->{replace};
  $@ = 'successful dropped trim';
  die $state->{fatal} if ($options->{outcome} // '') eq 'fatal';
  return undef if ($options->{outcome} // '') eq 'undefined';
  return $state->{trim_reference} if ($options->{outcome} // '') eq 'reference';
  if ($state->{event}) {
   my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
   LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'do { LOWERED; undef }');
   LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
  }
  return $options->{trim} if exists($options->{trim});
  return 'call(value)' if ref($state->{input});
  my $value = $_[0];
  $value =~ s/^\s+|\s+$//g if defined($value);
  return $value;
 };
 $storage{trim_action_ir_value} = $state->{actual};
 $storage{unrelated} = sub { die 'unrelated dependency invoked' };
 $state->{unrelated} = $storage{unrelated};
 my $mode = $options->{deps} // 'ordinary';
 delete $storage{trim_action_ir_value} if $mode eq 'missing';
 $storage{trim_action_ir_value} = 'not code' if $mode eq 'string';
 $storage{trim_action_ir_value} = {} if $mode eq 'reference';
 $storage{trim_action_ir_value} = bless({}, 'NotTrimCode') if $mode eq 'blessed';
 my $deps = \%storage;
 if ($mode =~ /^tied/) {
  my %map;
  my $second = $mode eq 'tied-bad-second' ? 'not code' : $state->{actual};
  tie %map, 'DroppedTrimProbe::TrackedMap', \%storage, $state->{fetches}, [$state->{first}, $second];
  $deps = \%map;
 }
 $deps = undef if $mode eq 'undefined';
 $deps = [] if $mode eq 'array';
 $state->{deps} = $deps;
 $state->{storage} = \%storage;
 return ($deps, $state);
}

sub invoke_owner {
 my ($options, $deps, $state) = @_;
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_parse_method_value_ast_expr = sub {
  $state->{record}->('ast', \$_[0], !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', $@, $_[1]);
  return $options->{ast} if exists($options->{ast});
  return {kind => 'call'};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_first_unknown_value_call_name = sub {
  $state->{record}->('unknown', \$_[0], !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', $@, $_[1]);
  return $options->{unknown};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_unsupported_helper_expr = sub {
  $state->{record}->('unsupported', \$_[0], !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', $@);
  return 'UNSUPPORTED('.$_[0].')';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub {
  $state->{record}->('method', \$_[0], !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', $@, $_[1]);
  my $before = $_[0];
  $_[0] .= '!' if $options->{method_mutates};
  return $before if $options->{method_original};
  return $_[0] if $options->{method_equal};
  return $options->{lowered} if exists($options->{lowered});
  return 'LOWERED';
 };
 return LinkedSpec::ActionIR::MethodLowering::_lower_dropped_value_statement($state->{input}, $deps);
}

sub invoke {
 my ($options) = @_;
 my ($deps, $state) = setup($options);
 my ($value, $second, $error, $success_error);
 eval { $@ = 'incoming dropped trim'; $value = invoke_owner($options, $deps, $state); $success_error = $@; 1 }
  or $error = $@;
 $second = invoke_owner($options, $deps, $state) if $options->{replace};
 my $selected = $options->{replace} ? $state->{replacement} : $state->{actual};
 return {name => $options->{name}, value => encoded($value), second => encoded($second),
  events => $state->{events}, trace => $state->{trace}, fetches => $state->{fetches},
  slots_after => [map { encoded($$_) } @{$state->{slots}}],
  caller_after => encoded($state->{input}), success_error => $success_error,
  error => ref($error) ? {type => ref($error), same_fatal => same($error, $state->{fatal})} : $error,
  map_callback => same($state->{storage}{trim_action_ir_value}, $selected),
  unrelated_callback => same($state->{storage}{unrelated}, $state->{unrelated})};
}

sub callback_cases {
 return [{name => 'string'}, {name => 'effect', outcome => 'effect'},
  {name => 'undefined', outcome => 'undefined'}, {name => 'fatal', outcome => 'fatal'},
  {name => 'reference-return', outcome => 'reference'}, {name => 'reference-input', input => {input => 'reference'}}];
}
sub branch_cases {
 return [
  {name => 'undefined-input', input => undef}, {name => 'undefined-missing', input => undef, deps => 'missing'},
  {name => 'undefined-tied', input => undef, deps => 'tied'},
  {name => 'empty-input', input => ''}, {name => 'whitespace-input', input => '  '}, {name => 'zero-input', input => 0},
  (map { {name => 'deps-'.$_, deps => $_} } qw(missing string reference blessed undefined array)),
  {name => 'tied-selection', deps => 'tied'}, {name => 'tied-bad-second', deps => 'tied-bad-second'},
  {name => 'trim-undefined', trim => undef}, {name => 'trim-empty', trim => ''}, {name => 'trim-zero', trim => '0'},
  {name => 'ast-undefined', ast => undef}, {name => 'ast-array', ast => []},
  {name => 'ast-empty-hash', ast => {}}, {name => 'ast-raw', ast => {kind => 'raw_perl'}},
  {name => 'unknown-empty', unknown => ''}, {name => 'unknown-zero', unknown => '0'},
  {name => 'unknown-name', unknown => 'custom'},
  {name => 'lowered-undefined', lowered => undef}, {name => 'lowered-empty', lowered => ''},
  {name => 'lowered-zero', lowered => '0'}, {name => 'lowered-equal', lowered => 'call(value)'},
  {name => 'lowered-hash', lowered => ' {a => 1}'},
  {name => 'receiver-mutation', ast => {kind => 'receiver_mutation_chain'}},
  {name => 'method-mutated-original', method_mutates => 1, method_original => 1},
  {name => 'method-mutated-equal', method_mutates => 1, method_equal => 1},
  {name => 'map-replacement', replace => 1},
 ];
}

sub authority {
 my ($known) = @_;
 my $row;
 LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', sub {
  my $event = {raw => 'same'};
  LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
   {event => $event, source => 'same', source_span => {start => 0, end => 4}});
  my ($deps, $state) = setup({});
  $state->{event} = $event;
  my $outer = sub { invoke_owner({}, $deps, $state) };
  LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer, $state->{actual}] : [$outer], sub {
   my $capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
   $row = {known => $known, value => $capture->{value}, eligible => $state->{eligible},
    calls => [map { {args => $_->{args}, context => $_->{context}} } grep { $_->{role} eq 'trim' } @{$state->{trace}}],
    actual_map_identity => same($deps->{trim_action_ir_value}, $state->{actual}),
    parent_packet => LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture, $outer, $event) ? 1 : 0};
  });
 });
 return $row;
}

sub observations {
 my $stderr = gensym;
 my $pid = open3(undef, my $stdout, $stderr, 'perl', '-Iperl', './t/actionir_dropped_trim_cold_probe.pl', 'observe');
 my $out = do { local $/; <$stdout> // '' };
 my $err = do { local $/; <$stderr> // '' };
 waitpid($pid, 0);
 my $status = $? >> 8;
 return {callbacks => [map { invoke($_) } @{callback_cases()}], branches => [map { invoke($_) } @{branch_cases()}],
  authority => [map { authority($_) } (0, 1)], cold => {command => ['perl', '-Iperl', './t/actionir_dropped_trim_cold_probe.pl', 'observe'],
   returncode => $status, stdout => $out, stderr => $err, value => $status ? undef : JSON::PP->new->decode($out)}};
}

unless (caller) {
 die 'usage: dropped trim probe observe' unless @ARGV == 1 && $ARGV[0] eq 'observe';
 print JSON::PP->new->canonical->encode(observations()), "\n";
}
1;
