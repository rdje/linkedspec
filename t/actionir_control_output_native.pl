use strict;
use warnings;
use utf8;
use JSON::PP ();
use Scalar::Util qw(refaddr reftype);
use FindBin ();
use Cwd qw(abs_path);
use File::Spec ();
use LinkedSpec::ActionIR::ControlFlow ();

my $cold = @ARGV && $ARGV[0] eq 'cold';
unless ($cold) {
 require LinkedSpec::ActionIR::SourceOrigins;
 require LinkedSpec::ActionIR::SourceEmissions;
}
my $json = JSON::PP->new->canonical->ascii;
my $root = abs_path($FindBin::Bin.'/..');
my %owners = (
 say => \&LinkedSpec::ActionIR::ControlFlow::_lower_say_statement,
 print => \&LinkedSpec::ActionIR::ControlFlow::_lower_print_statement,
 print_each => \&LinkedSpec::ActionIR::ControlFlow::_lower_print_each_statement,
 exit_now => \&LinkedSpec::ActionIR::ControlFlow::_lower_exit_now_statement,
);
my @keys = qw(trim_action_ir_value parse_method_function_expr normalize_method_args_with_optional_scope lower_flow_composite_expr lower_method_value_expr split_action_ir_statements normalize_method_tag_expr extract_array_symbol_name bare_symbol_kind);
my %required = map {$_ => ['parse_method_function_expr']} keys %owners;
$required{print_each} = [qw(parse_method_function_expr trim_action_ir_value extract_array_symbol_name)];
my %cases = (
 say_one => {owner => 'say', input => 'say(outer)'},
 say_many => {owner => 'say', input => 'say("a", outer, false, 0)'},
 say_arity_zero => {owner => 'say', input => 'say()'},
 say_unicode => {owner => 'say', input => 'say("λ😀")', rule_label => "R\\'λ😀"},
 say_legacy => {owner => 'say', input => 'say(outer)', legacy => 1},
 say_no_label => {owner => 'say', input => 'say(outer)', rule_label => undef},
 say_ref_label => {owner => 'say', input => 'say(outer)', rule_label => {label => 'ignored'}},
 say_tied_parser => {owner => 'say', input => 'say(outer)', tied => 'parse_method_function_expr'},
 say_declined_value => {owner => 'say', input => 'say(unknown)', lower_declines => 1},
 print_one => {owner => 'print', input => 'print(outer)'},
 print_many => {owner => 'print', input => 'print("a", outer)'},
 print_arity_zero => {owner => 'print', input => 'print()'},
 print_legacy => {owner => 'print', input => 'print(outer)', legacy => 1},
 print_tied_parser => {owner => 'print', input => 'print(outer)', tied => 'parse_method_function_expr'},
 print_declined_value => {owner => 'print', input => 'print(unknown)', lower_declines => 1},
 print_each_symbol => {owner => 'print_each', input => 'print_each(outer, "p")'},
 print_each_suffix => {owner => 'print_each', input => 'print_each(items, "p", "s")'},
 print_each_literal => {owner => 'print_each', input => 'print_each([1,2], "p")'},
 print_each_scalar_kind => {owner => 'print_each', input => 'print_each(outer, "p")', kind => 'scalar'},
 print_each_legacy => {owner => 'print_each', input => 'print_each(outer, "p")', legacy => 1},
 print_each_arity_zero => {owner => 'print_each', input => 'print_each()'},
 print_each_arity_one => {owner => 'print_each', input => 'print_each(items)'},
 print_each_arity_four => {owner => 'print_each', input => 'print_each(items, "p", "s", "extra")'},
 print_each_declined_value => {owner => 'print_each', input => 'print_each([1,2], "p")', lower_declines => 1},
 print_each_tied_parser => {owner => 'print_each', input => 'print_each(outer, "p")', tied => 'parse_method_function_expr'},
 print_each_tied_trim => {owner => 'print_each', input => 'print_each(outer, "p")', tied => 'trim_action_ir_value'},
 print_each_tied_extract => {owner => 'print_each', input => 'print_each(outer, "p")', tied => 'extract_array_symbol_name'},
 exit_now_default => {owner => 'exit_now', input => 'exit_now()'},
 exit_now_zero => {owner => 'exit_now', input => 'exit_now(0)'},
 exit_now_status => {owner => 'exit_now', input => 'exit_now(23)'},
 exit_now_arity_two => {owner => 'exit_now', input => 'exit_now(1,2)'},
 exit_now_legacy => {owner => 'exit_now', input => 'exit_now(0)', legacy => 1},
 exit_now_tied_parser => {owner => 'exit_now', input => 'exit_now(23)', tied => 'parse_method_function_expr'},
 exit_now_declined_status => {owner => 'exit_now', input => 'exit_now(unknown)', lower_declines => 1},
);
for my $owner (sort keys %owners) {
 for my $entry ([undefined => undef], [empty => ''], [zero => '0'], [wrong_method => 'other(true)']) {
  die 'duplicate native case '.$owner.'_'.$entry->[0] if exists $cases{$owner.'_'.$entry->[0]};
  $cases{$owner.'_'.$entry->[0]} = {owner => $owner, input => $entry->[1]};
 }
}
my %route_names = (say => 'say_one', print => 'print_one', print_each => 'print_each_symbol', exit_now => 'exit_now_status');
my %routes = map {my $owner = $_; $owner => {map {$_ => [$route_names{$owner}, 1]} @{$required{$owner}}}} keys %owners;

{
 package ControlOutputNative::Deps;
 sub TIEHASH {my ($class, $state, $original, $target, $replacement) = @_; return bless {state => $state, original => $original, target => $target, replacement => $replacement, reads => 0}, $class}
 sub FETCH {
  my ($self, $key) = @_;
  push @{$self->{state}{map_reads}}, $key;
  return ++$self->{reads} == 1 ? $self->{original}{$key} : $self->{replacement} if $key eq $self->{target};
  return $self->{original}{$key};
 }
 sub EXISTS {return exists $_[0]{original}{$_[1]}}
}

sub context {return !defined($_[0]) ? 'void' : $_[0] ? 'list' : 'scalar'}
sub same {return ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0}
sub snapshot {
 my ($state, $value, $visiting) = @_;
 return $value unless ref $value;
 $visiting ||= {};
 my $address = refaddr($value);
 my $id = $state->{ids}{$address} //= 1 + scalar(keys %{$state->{ids}});
 my $result = {id => $id, type => ref($value)};
 return {%$result, cycle => 1} if $visiting->{$address};
 local $visiting->{$address} = 1;
 my $type = reftype($value) || '';
 $result->{items} = [map {snapshot($state, $_, $visiting)} @$value] if $type eq 'ARRAY';
 $result->{value} = snapshot($state, $$value, $visiting) if $type eq 'SCALAR' || $type eq 'REF';
 if ($type eq 'HASH') {
  if (tied %$value) {$result->{tied} = ref(tied %$value)}
  else {$result->{fields} = {map {$_ => snapshot($state, $value->{$_}, $visiting)} sort keys %$value}}
 }
 return $result;
}
sub ordinary {
 my ($state, $key, $args) = @_;
 my $value = $args->[0];
 if ($key eq 'trim_action_ir_value') {
  return $value unless defined($value) && !ref($value);
  $value =~ s/^\s+//o; $value =~ s/\s+$//o;
  return $value;
 }
 if ($key eq 'parse_method_function_expr') {
  return undef if $state->{case}{decline_attached} && defined($value) && !ref($value) && $value =~ /\}\s*\z/s;
  require LinkedSpec::ActionIR::MethodExpr;
  return LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr($value);
 }
 if ($key eq 'normalize_method_args_with_optional_scope') {
  return undef unless ref($value) eq 'ARRAY';
  return undef if @$value < $args->[1] || (defined($args->[2]) && @$value > $args->[2]);
  return $state->{case}{normalizer_copy} ? [@$value] : $value;
 }
 if ($key eq 'lower_flow_composite_expr') {
  return undef if $state->{case}{lower_declines};
  return 1 if defined($value) && $value eq 'true';
  return 0 if defined($value) && $value eq 'false';
  return $value;
 }
 return undef if $key eq 'lower_method_value_expr';
 if ($key eq 'extract_array_symbol_name') {return defined($value) && !ref($value) && $value =~ /^[A-Za-z_][A-Za-z0-9_]*$/ ? $value : undef}
 return $state->{case}{kind} // 'array' if $key eq 'bare_symbol_kind';
 if ($key eq 'split_action_ir_statements') {
  return [] if $state->{case}{split_empty} && defined($value) && $value =~ /^\s*\z/s;
  return [split /;/, $value];
 }
 return $value if $key eq 'normalize_method_tag_expr';
 die "unhandled output native callback $key";
}
sub observe {
 my ($label, $case_name, $options) = @_;
 my $case = $json->decode($json->encode($cases{$case_name}));
 my $state = {case => $case, input => $case->{input}, ids => {}, calls => [], authority => [],
  effects => [], counts => {}, held => [], returns => [], return_refs => [], parsed_calls => [], map_reads => []};
 $state->{input} = $options->{input} if exists $options->{input};
 $state->{fatal} = bless({label => $label}, 'ControlOutputNative::Fatal');
 my (%deps, %callbacks);
 my $publish = sub {
  my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
  LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'outer');
  LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
 };
 my $make_callback;
 $make_callback = sub {
  my ($key, $generation) = @_;
  my $callback;
  $callback = sub {
   my $want = wantarray;
   my $incoming = $@;
   my $number = ++$state->{counts}{$key};
   my ($array_reference, $array_cell, $element_cell) = (0, 0, 0);
   if (@_) {
    for my $call (@{$state->{parsed_calls}}) {
     next unless ref($call->{args}) eq 'ARRAY';
     $array_reference ||= same($_[0], $call->{args});
     $array_cell ||= same(\$_[0], \$call->{args});
     for my $index (0 .. $#{$call->{args}}) {
      $element_cell ||= same(\$_[0], \$call->{args}[$index]);
     }
    }
   }
   push @{$state->{calls}}, {key => $key, generation => $generation, number => $number, context => context($want),
    args => [map {snapshot($state, $_)} @_], incoming_error => snapshot($state, $incoming),
    first_readonly => @_ ? (Internals::SvREADONLY($_[0]) ? 1 : 0) : undef,
    first_is_caller_slot => @_ ? same(\$_[0], \$state->{input}) : 0,
    first_is_parser_array => $array_reference, first_is_parser_array_cell => $array_cell,
    first_is_parser_element_cell => $element_cell};
   push @{$state->{held}}, {key => $key, generation => $generation, number => $number, slot => \$_[0]} if @_;
   unless ($cold || ($key ne 'parse_method_function_expr' && $key ne 'trim_action_ir_value' && $key ne 'extract_array_symbol_name')) {
    my $call = $LinkedSpec::ActionIR::SourceEmissions::_call;
    push @{$state->{authority}}, {key => $key, generation => $generation, number => $number,
     eligible => LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0,
     actual_callback => ref($call) eq 'HASH' ? same($call->{callback}, $callback) : 0};
   }
   my $target = defined($options->{key}) && $options->{key} eq $key && $number == ($options->{number} // 1);
   $publish->() if $target && $options->{authority};
   if ($target && ($options->{effect} || '') eq 'mutate') {
    if (ref($_[0]) eq 'ARRAY') {push @{$_[0]}, 'extra'}
    elsif (defined($_[0]) && !ref($_[0])) {$_[0] .= '!'}
    push @{$state->{effects}}, {key => $key, after => snapshot($state, $_[0])};
   }
   if ($target && ($options->{effect} || '') eq 'rebind') {
    $_[0] = ref($_[0]) eq 'ARRAY' ? ['rebound'] : 'rebound';
    push @{$state->{effects}}, {key => $key, rebound => snapshot($state, $_[0])};
   }
   if ($target && ($options->{effect} || '') eq 'replace') {
    $deps{$key} = $make_callback->($key, 1);
    push @{$state->{effects}}, {replaced => $key};
   }
   $@ = 'successful-'.$key if $target && ($options->{effect} || '') eq 'error';
   die $state->{fatal} if $target && ($options->{effect} || '') eq 'fatal';
   return undef if $target && ($options->{effect} || '') eq 'undefined';
   my $value = ordinary($state, $key, \@_);
   push @{$state->{parsed_calls}}, $value if $key eq 'parse_method_function_expr' && ref($value) eq 'HASH';
   push @{$state->{return_refs}}, $value if ref($value);
   push @{$state->{returns}}, {key => $key, generation => $generation, number => $number, value => snapshot($state, $value)};
   return $value;
  };
  return $callback;
 };
 for my $key (@keys) {$deps{$key} = $callbacks{$key} = $make_callback->($key, 0)}
 $deps{unrelated} = sub {die 'unrelated output dependency invoked'};
 delete $deps{$options->{missing}} if defined $options->{missing};
 $deps{$options->{bad}} = 'not CODE' if defined $options->{bad};
 $state->{rule_label} = exists($case->{rule_label}) ? $case->{rule_label} : 'OutputRule';
 my $branch = {rule_label => $state->{rule_label}, legacy => $case->{legacy} ? 1 : 0};
 my $before = {input => snapshot($state, $state->{input}), fatal_anchor => snapshot($state, $state->{fatal}),
  map => snapshot($state, \%deps), branch => snapshot($state, $branch)};
 if ($case->{tied}) {
  my %original = %deps;
  tie %deps, 'ControlOutputNative::Deps', $state, \%original, $case->{tied}, $make_callback->($case->{tied}, 1);
 }
 my $lower = sub {
  return $owners{$case->{owner}}->($state->{input}, \%deps) if $case->{legacy};
  return $owners{$case->{owner}}->($state->{input}, $state->{rule_label}, \%deps);
 };
 my $parent = sub {
  if ($options->{context} eq 'list') {
   my @values = $lower->();
   $state->{result} = [map {snapshot($state, $_)} @values];
  } elsif ($options->{context} eq 'void') {
   $lower->();
   $state->{result} = {context => 'void'};
  } else {
   my $value = $lower->();
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
   LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($publish);
   LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($callbacks{$options->{key}}) if $options->{known};
  }
  my ($capture, $successful);
  my $ok = eval {
   $@ = 'caller-error';
   if ($cold) {$parent->()}
   else {$capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($parent)}
   $successful = snapshot($state, $@);
   1;
  };
  my $thrown = $@;
  unless ($ok) {
   $state->{fatal_result} = snapshot($state, $thrown);
   $state->{fatal_is_original} = same($thrown, $state->{fatal});
  }
  $state->{successful_error} = $successful if $ok;
  unless ($cold) {
   $state->{parent_packet} = $capture && $capture->{emission} ? 1 : 0;
   my $registry = $LinkedSpec::ActionIR::SourceEmissions::_producers;
   $state->{child_packets} = scalar grep {same($_->{callback}, $callbacks{$options->{key} // ''})} values %{$registry->{captures}};
  }
 };
 if ($cold) {$work->()}
 else {LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('origin', sub {
  LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers([], $work);
 })}
 return {label => $label, case => $case_name, options => $options,
  native => {before => $before, result => $state->{result}, calls => $state->{calls}, effects => $state->{effects},
   held_slots => snapshot($state, $state->{held}), callback_returns => $state->{returns},
   returned_references => snapshot($state, $state->{return_refs}), parsed_calls => snapshot($state, $state->{parsed_calls}),
   input_after => snapshot($state, $state->{input}), branch_after => snapshot($state, $branch),
   map_after => snapshot($state, $case->{tied} ? {tied => 1} : \%deps), map_reads => $state->{map_reads},
   owner_error => $state->{owner_error}, successful_error => $state->{successful_error},
   fatal => $state->{fatal_result}, fatal_is_original => $state->{fatal_is_original}},
  authority => {calls => $state->{authority}, parent_packet => $state->{parent_packet}, child_packets => $state->{child_packets}}};
}

my @rows;
for my $name (sort keys %cases) {
 for my $context (qw(scalar list void)) {push @rows, observe("ordinary/$name/$context", $name, {context => $context})}
}
for my $owner (sort keys %required) {
 for my $key (@{$required{$owner}}) {
  my ($case, $number) = @{$routes{$owner}{$key}};
  for my $effect (qw(mutate rebind replace error fatal undefined)) {
   push @rows, observe("effect/$owner/$key/$number/$effect", $case, {context => 'scalar', key => $key, number => $number, effect => $effect});
  }
  for my $kind (qw(missing bad)) {
   push @rows, observe("validation/$owner/$key/$kind", $case, {context => 'scalar', $kind => $key, input => undef});
  }
  next if $cold;
  for my $known (0, 1) {
   for my $context (qw(scalar list void)) {
    push @rows, observe("authority/$owner/$key/$number/$known/$context", $case,
     {context => $context, key => $key, number => $number, known => $known, authority => 1});
   }
  }
 }
}
my @loaded;
for my $path (values %INC) {
 next unless defined($path) && -f $path;
 my $absolute = abs_path($path);
 next unless index($absolute, $root.'/') == 0;
 push @loaded, File::Spec->abs2rel($absolute, $root);
}
my %loaded = map {$_ => 1} @loaded;
print $json->encode({mode => $cold ? 'cold' : 'warm', rows => \@rows,
 loaded_project_modules => [sort keys %loaded], perl_version => "$^V",
 emission_loaded => exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0,
 trace_loaded => exists($INC{'LinkedSpec/Trace.pm'}) ? 1 : 0,
 toolchain_scope => 'System Perl/stdlib reused read-only. Parser delegates to parent MethodExpr. Extractor recognizes bare identifiers; optional kind is controlled and remains separately owned. Tied dependency maps are identified without enumeration to avoid observer FETCH effects. These are lowering probes, not facade DSL execution claims.'}), "\n";
