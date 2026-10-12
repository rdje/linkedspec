use strict;
use warnings;
use utf8;
use JSON::PP ();
use Scalar::Util qw(refaddr reftype);
use FindBin ();
use Cwd qw(abs_path);
use File::Spec ();
use LinkedSpec::ActionIR::FlowExpr ();
# The diagnostic deliberately localizes a named callback and reads private state.
no warnings 'once';

{
 package FlowKindNative::Map;
 sub TIEHASH {
  my ($class, $storage, $first, $selected, $fetches) = @_;
  return bless {storage => $storage, first => $first, selected => $selected,
                fetches => $fetches, reads => 0}, $class;
 }
 sub FETCH {
  my ($self, $key) = @_;
  push @{$self->{fetches}}, $key;
  return ++$self->{reads} == 1 ? $self->{first} : $self->{selected}
   if $key eq 'bare_symbol_kind';
  return $self->{storage}{$key};
 }
 sub STORE { $_[0]{storage}{$_[1]} = $_[2] }
}
{
 package FlowKindNative::Callable;
 use overload '&{}' => sub { $_[0]{callback} }, fallback => 1;
}
{
 package FlowKindNative::Kind;
 use overload '""' => sub { ++$_[0]{coercions}; return $_[0]{text} }, fallback => 1;
}

my $cold = @ARGV && $ARGV[0] eq 'cold';
unless ($cold) {
 require LinkedSpec::ActionIR::SourceOrigins;
 require LinkedSpec::ActionIR::SourceEmissions;
}
my $json = JSON::PP->new->canonical->ascii;
my $root = abs_path($FindBin::Bin.'/..');
my @keys = qw(trim_action_ir_value extract_array_symbol_name extract_hash_symbol_name
 extract_scalar_symbol_name lower_method_value_expr lower_primitive_literal_expr
 lower_direct_nested_access_value_expr parse_method_function_expr
 normalize_method_args_with_optional_scope);

sub same {
 return ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0;
}
sub snapshot {
 my ($state, $value, $visiting) = @_;
 return $value unless ref($value);
 $visiting ||= {};
 my $address = refaddr($value);
 my $id = $state->{ids}{$address} //= 1 + scalar(keys %{$state->{ids}});
 my $result = {id => $id, type => ref($value)};
 return {%$result, cycle => 1} if $visiting->{$address};
 local $visiting->{$address} = 1;
 my $type = reftype($value) || '';
 $result->{items} = [map {snapshot($state, $_, $visiting)} @$value] if $type eq 'ARRAY';
 $result->{fields} = {map {$_ => snapshot($state, $value->{$_}, $visiting)} sort keys %$value}
  if $type eq 'HASH';
 return $result;
}

sub observe {
 my ($label, $options) = @_;
 my $container = $options->{container} || 'array';
 my $input = exists($options->{input}) ? $options->{input} : $container.'(item)';
 my $state = {ids => {}, fetches => [], calls => [], required => [], authority => [],
              effects => [], first_calls => 0, replacement_calls => 0};
 my $fatal = bless {label => $label}, 'FlowKindNative::Fatal';
 my $kind = exists($options->{kind}) ? $options->{kind} : 'scalar';
 $kind = bless {text => 'scalar', coercions => 0}, 'FlowKindNative::Kind'
  if ($options->{effect} || '') eq 'object';
 my ($deps, $actual, %storage);
 my $replacement = sub { ++$state->{replacement_calls}; return 'array' };
 $actual = sub {
  my $want = wantarray;
  my $incoming = $@;
  push @{$state->{calls}}, {
   args => [map {snapshot($state, $_)} @_],
   context => !defined($want) ? 'void' : $want ? 'list' : 'scalar',
   incoming_error => snapshot($state, $incoming),
   first_readonly => Internals::SvREADONLY($_[0]) ? 1 : 0,
   first_is_caller_slot => same(\$_[0], \$input),
  };
  unless ($cold) {
   my $call = $LinkedSpec::ActionIR::SourceEmissions::_call;
   push @{$state->{authority}}, {
    eligible => LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0,
    actual_callback => ref($call) eq 'HASH' ? same($call->{callback}, $actual) : 0,
   };
   my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
   LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'outer');
   LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
  }
  my $effect = $options->{effect} || '';
  if ($effect eq 'write') {
   my $ok = eval { $_[0] .= '!'; 1 };
   push @{$state->{effects}}, {write_ok => $ok ? 1 : 0,
    written => snapshot($state, $_[0]), error => $ok ? undef : $@};
  }
  $deps->{bare_symbol_kind} = $replacement if $effect eq 'replace-kind';
  $@ = 'successful-kind-error' if $effect eq 'error';
  die $fatal if $effect eq 'fatal';
  return $kind;
 };
 for my $key (@keys) {
  $storage{$key} = sub {
   push @{$state->{required}}, {key => $key, args => [map {snapshot($state, $_)} @_]};
   if ($key eq 'trim_action_ir_value') {
    $deps->{bare_symbol_kind} = $replacement if ($options->{effect} || '') eq 'replace-trim';
    return $_[0];
   }
   return $_[0] if $key eq 'normalize_method_args_with_optional_scope';
   return 'item' if $key eq 'extract_'.$container.'_symbol_name'
    && defined($_[0]) && $_[0] eq $container.'(item)';
   return 'LOWERED' if $key eq 'lower_method_value_expr';
   return undef;
  };
 }
 my $first = sub { ++$state->{first_calls}; return 'WRONG' };
 my $variant = $options->{variant} || 'code';
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::FlowExpr::flow_kind_named = $actual;
 my $selected = $variant eq 'qualified' ? 'LinkedSpec::ActionIR::FlowExpr::flow_kind_named'
  : $variant eq 'unqualified' ? 'flow_kind_named'
  : $variant eq 'glob' ? \*LinkedSpec::ActionIR::FlowExpr::flow_kind_named
  : $variant eq 'blessed-code' ? bless(sub { return $actual->(@_) }, 'FlowKindNative::BlessedCode')
  : $variant eq 'callable' ? bless({callback => $actual}, 'FlowKindNative::Callable')
  : $variant eq 'undefined' ? undef
  : $variant eq 'array' ? [] : $variant eq 'hash' ? {} : $actual;
 my $original_selected = $selected;
 $first = 'not CODE' if $variant eq 'first-bad';
 $first = undef if $variant eq 'missing';
 my %tied;
 if ($options->{tied}) {
  tie %tied, 'FlowKindNative::Map', \%storage, $first, $selected, $state->{fetches};
  $deps = \%tied;
 } else {
  $storage{bare_symbol_kind} = $variant eq 'first-bad' ? 'not CODE' : $selected;
  delete $storage{bare_symbol_kind} if $variant eq 'missing';
  $deps = \%storage;
 }
 my $original_map = $deps;
 my $parent = sub {
  if ($options->{context} eq 'list') {
   my @values = LinkedSpec::ActionIR::FlowExpr::_lower_is_empty_expr($input, $deps);
   $state->{result} = [map {snapshot($state, $_)} @values];
  } elsif ($options->{context} eq 'void') {
   LinkedSpec::ActionIR::FlowExpr::_lower_is_empty_expr($input, $deps);
   $state->{result} = {context => 'void'};
  } else {
   my $value = LinkedSpec::ActionIR::FlowExpr::_lower_is_empty_expr($input, $deps);
   $state->{result} = snapshot($state, $value);
  }
  $state->{owner_error} = snapshot($state, $@);
  return 'outer';
 };
 my $work = sub {
  unless ($cold) {
   $state->{event} = {raw => 'origin'};
   LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($state->{event},
    {event => $state->{event}, source => 'origin', source_span => {start => 0, end => 6}});
   LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($parent);
   LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($actual) if $options->{known};
  }
  my $capture;
  my $ok = eval {
   $@ = 'caller-error';
   if ($cold) { $parent->() }
   else { $capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($parent) }
   $state->{success_error} = snapshot($state, $@);
   1;
  };
  $state->{fatal} = snapshot($state, $@) unless $ok;
  $state->{fatal_is_original} = !$ok && same($@, $fatal) ? 1 : 0;
  unless ($cold) {
   $state->{parent_packet} = $capture && $capture->{emission} ? 1 : 0;
   my $registry = $LinkedSpec::ActionIR::SourceEmissions::_producers;
   $state->{child_packets} = scalar grep {same($_->{callback}, $actual)} values %{$registry->{captures}};
  }
 };
 if ($cold) { $work->() }
 else { LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('origin', sub {
  LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers([], $work);
 }) }
 return {label => $label, options => $options,
  native => {calls => $state->{calls}, required => $state->{required},
   result => $state->{result}, effects => $state->{effects},
   owner_error => $state->{owner_error}, success_error => $state->{success_error},
   fatal => $state->{fatal}, fatal_is_original => $state->{fatal_is_original},
   input_after => $input, kind_after => snapshot($state, $kind),
   fetches => $state->{fetches}, first_calls => $state->{first_calls},
   replacement_calls => $state->{replacement_calls}, map_reference_unchanged => same($deps, $original_map),
   selected_reference_unchanged => ref($selected) ? same($selected, $original_selected) : 1,
   stored_kind_is_actual => same($storage{bare_symbol_kind}, $actual),
   stored_kind_is_replacement => same($storage{bare_symbol_kind}, $replacement),
   stored_kind_shape => ref($storage{bare_symbol_kind}) ||
    (defined($storage{bare_symbol_kind}) ? 'scalar' : 'undefined')},
  authority => {calls => $state->{authority}, parent_packet => $state->{parent_packet},
   child_packets => $state->{child_packets}}};
}

my @rows;
for my $container (qw(array hash)) {
 for my $variant (qw(code qualified unqualified glob blessed-code callable undefined array hash first-bad missing)) {
  for my $context (qw(scalar list void)) {
   push @rows, observe("selection/$container/$variant/$context",
    {container => $container, variant => $variant, tied => 1, context => $context, known => 1});
  }
 }
 for my $variant (qw(code missing first-bad qualified blessed-code)) {
  for my $context (qw(scalar list void)) {
   push @rows, observe("plain/$container/$variant/$context",
    {container => $container, variant => $variant, context => $context, known => 1});
  }
 }
 for my $effect (qw(write replace-trim replace-kind error fatal object)) {
  for my $tied (0, 1) {
   push @rows, observe("effect/$container/$effect/$tied",
    {container => $container, effect => $effect, tied => $tied, context => 'scalar', known => 1});
  }
 }
 for my $kind (undef, '', '0', 'array', 'hash') {
  my $name = defined($kind) ? length($kind) ? $kind : 'empty' : 'undefined';
  push @rows, observe("result/$container/$name",
   {container => $container, kind => $kind, context => 'scalar'});
 }
 for my $known (0, 1) {
  push @rows, observe("authority/$container/$known",
   {container => $container, context => 'scalar', known => $known});
  push @rows, observe("child/$container/$known",
   {container => $container, context => 'scalar', known => $known, kind => 'outer'});
 }
}
for my $input (undef, '', ' ', 'item', '0', 'λ😀',
              map {($_.'(item, other)', $_.'(1)', $_.'('.$_.'(item))')} qw(array hash)) {
 my $name = defined($input) ? length($input) ? $input : 'empty' : 'undefined';
 push @rows, observe("guard/$name", {input => $input, tied => 1, context => 'scalar', known => 1});
}
my %loaded;
for my $path (values %INC) {
 next unless defined($path) && -f $path;
 my $absolute = abs_path($path);
 next unless index($absolute, $root.'/') == 0;
 $loaded{File::Spec->abs2rel($absolute, $root)} = 1;
}
print $json->encode({mode => $cold ? 'cold' : 'warm', rows => \@rows,
 loaded_project_modules => [sort keys %loaded], perl_version => "$^V",
 emission_loaded => exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0,
 trace_loaded => exists($INC{'LinkedSpec/Trace.pm'}) ? 1 : 0,
 toolchain_scope => 'System Perl and standard libraries reused read-only; no immutable portable toolchain claim.'}), "\n";
