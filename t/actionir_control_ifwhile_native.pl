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
 if => \&LinkedSpec::ActionIR::ControlFlow::_lower_if_flow_statement,
 elseif => \&LinkedSpec::ActionIR::ControlFlow::_lower_elseif_flow_statement,
 else => \&LinkedSpec::ActionIR::ControlFlow::_lower_else_flow_statement,
 endif => \&LinkedSpec::ActionIR::ControlFlow::_lower_endif_flow_statement,
 inline => \&LinkedSpec::ActionIR::ControlFlow::_lower_inline_if_branch_expr,
 while => \&LinkedSpec::ActionIR::ControlFlow::_lower_while_flow_statement,
);
my @keys = qw(trim_action_ir_value parse_method_function_expr normalize_method_args_with_optional_scope lower_flow_composite_expr lower_method_value_expr split_action_ir_statements normalize_method_tag_expr extract_array_symbol_name);
my %required = (
 if => [qw(parse_method_function_expr normalize_method_args_with_optional_scope)],
 map {$_ => ['normalize_method_args_with_optional_scope']} qw(elseif else endif inline while),
);
my $marker = [{else_seen => 0, implicit_close => 0, body_carrier => 'marker', nested => {shared => 1}}];
my %cases = (
 if_marker => {owner => 'if', input => 'if(true)'},
 if_i => {owner => 'if', input => 'i(false)'},
 if_when => {owner => 'if', input => 'when(true)'},
 if_empty => {owner => 'if', input => 'if()'},
 if_inline => {owner => 'if', input => 'if(true, bare)'},
 if_inline_bypass => {owner => 'if', input => 'if(true, print("x"))'},
 if_inline_clauses => {owner => 'if', input => 'if(true, bare, elseif(false, print("second")), else(print("last")))'},
 if_action_after_else => {owner => 'if', input => 'if(true, else(print("a")), print("b"))'},
 if_branch_after_else => {owner => 'if', input => 'if(true, else(print("a")), elseif(false, print("b")))'},
 if_attached => {owner => 'if', input => 'if(true) { bare }', decline_attached => 1},
 if_parser_accepts_attached => {owner => 'if', input => 'if(true) { bare }'},
 if_attached_conflict => {owner => 'if', input => 'if(true, print("a")) { bare }', decline_attached => 1},
 if_bad_action => {owner => 'if', input => 'if(true) { if(false) }', decline_attached => 1},
 if_copy_normalizer => {owner => 'if', input => 'if(true, bare)', normalizer_copy => 1},
 if_tied_parser => {owner => 'if', input => 'if(true, bare)', tied => 'parse_method_function_expr'},
 if_tied_normalizer => {owner => 'if', input => 'if(true, bare, elseif(false, bare))', tied => 'normalize_method_args_with_optional_scope'},
 if_unicode => {owner => 'if', input => 'if(cat("λ😀"), bare)'},
 if_typed => {owner => 'if', input => {kind => 'control_if', keyword => 'if', source => 'poison',
  condition => {kind => 'boolean', value => 1, source => 'poison'},
  body => {kind => 'action_block', source => 'poison', statements => []}},
  decline_attached => 1, split_empty => 1},
 elseif_marker => {owner => 'elseif', input => 'elseif(false)', stack => $marker},
 elseif_elif => {owner => 'elseif', input => 'elif(true)', stack => $marker},
 elseif_empty_stack => {owner => 'elseif', input => 'elseif(true)'},
 elseif_after_else => {owner => 'elseif', input => 'elseif(true)', stack => [{else_seen => 1}]},
 elseif_attached => {owner => 'elseif', input => 'elseif(true) { bare }', stack => $marker, decline_attached => 1},
 elseif_bad_action => {owner => 'elseif', input => 'elseif(true) { if(false) }', stack => $marker, decline_attached => 1},
 elseif_bad_arity => {owner => 'elseif', input => 'elseif(true, false)', stack => $marker},
 else_marker => {owner => 'else', input => 'else()', stack => $marker},
 else_bare => {owner => 'else', input => 'else', stack => $marker},
 else_attached => {owner => 'else', input => 'else { bare }', stack => $marker, decline_attached => 1},
 else_nested_stack => {owner => 'else', input => 'else { bare }', stack => [{outer => 1}, @$marker], decline_attached => 1},
 else_bad_action => {owner => 'else', input => 'else { if(false) }', stack => $marker, decline_attached => 1},
 else_after_else => {owner => 'else', input => 'else()', stack => [{else_seen => 1}]},
 else_empty_stack => {owner => 'else', input => 'else()'},
 else_bad_arity => {owner => 'else', input => 'else(extra)', stack => $marker},
 else_typed => {owner => 'else', input => {kind => 'control_else', keyword => 'otherwise', source => 'poison',
  body => {kind => 'action_block', statements => []}}, stack => $marker, decline_attached => 1, split_empty => 1},
 endif_marker => {owner => 'endif', input => 'endif()', stack => $marker},
 endif_bare => {owner => 'endif', input => 'endif', stack => $marker},
 endif_empty_stack => {owner => 'endif', input => 'endif()'},
 endif_attached => {owner => 'endif', input => 'endif() { bare }', stack => $marker, decline_attached => 1},
 endif_attached_carrier => {owner => 'endif', input => 'endif()', stack => [{body_carrier => 'attached', implicit_close => 1}]},
 endif_else_seen => {owner => 'endif', input => 'endif()', stack => [{else_seen => 1, body_carrier => 'marker'}]},
 endif_bad_arity => {owner => 'endif', input => 'endif(extra)', stack => $marker},
 inline_elseif => {owner => 'inline', input => 'elseif(true)'},
 inline_elif_bypass => {owner => 'inline', input => 'elif(true, print("x"))'},
 inline_normalized_actions => {owner => 'inline', input => 'elseif(true, bare)'},
 inline_else => {owner => 'inline', input => 'else()'},
 inline_else_actions => {owner => 'inline', input => 'else(print("x"), bare)'},
 inline_unknown => {owner => 'inline', input => 'case("x")'},
 inline_attached_elseif => {owner => 'inline', input => 'elseif(true) {}', decline_attached => 1, split_empty => 1},
 inline_attached_conflict => {owner => 'inline', input => 'elseif(true, print("x")) { bare }', decline_attached => 1},
 inline_else_attached => {owner => 'inline', input => 'else() { bare }', decline_attached => 1},
 inline_else_conflict => {owner => 'inline', input => 'else(print("x")) { bare }', decline_attached => 1},
 inline_typed_else => {owner => 'inline', input => {kind => 'control_else', keyword => 'otherwise',
  body => {kind => 'action_block', statements => []}}, decline_attached => 1, split_empty => 1},
 while_attached => {owner => 'while', input => 'while(false) { bare }', decline_attached => 1},
 while_plain => {owner => 'while', input => 'while(true)'},
 while_empty => {owner => 'while', input => 'while(false) {}', decline_attached => 1, split_empty => 1},
 while_space_declines => {owner => 'while', input => 'while(false) {   }', decline_attached => 1},
 while_space_empty_split => {owner => 'while', input => 'while(false) {   }', decline_attached => 1, split_empty => 1},
 while_bad_arity => {owner => 'while', input => 'while(a, b) { bare }', decline_attached => 1},
 while_condition_declines => {owner => 'while', input => 'while(unknown) { bare }', decline_attached => 1, lower_declines => 1},
 while_bad_action => {owner => 'while', input => 'while(false) { if(true) }', decline_attached => 1},
 while_nested => {owner => 'while', input => 'while(false) { while(false) {} }', decline_attached => 1, split_empty => 1},
 while_typed => {owner => 'while', input => {kind => 'control_while', source => 'poison',
  condition => {kind => 'boolean', value => 0}, body => {kind => 'action_block', statements => []}},
  decline_attached => 1, split_empty => 1},
);
for my $owner (sort keys %owners) {
 for my $entry ([undefined => undef], [empty => ''], [zero => '0'], [wrong_method => 'other(true)']) {
  $cases{$owner.'_'.$entry->[0]} = {owner => $owner, input => $entry->[1], stack => $marker};
 }
}
my %routes = (
 if => {parse_method_function_expr => ['if_inline', 2], normalize_method_args_with_optional_scope => ['if_marker', 1]},
 elseif => {normalize_method_args_with_optional_scope => ['elseif_marker', 1]},
 else => {normalize_method_args_with_optional_scope => ['else_marker', 1]},
 endif => {normalize_method_args_with_optional_scope => ['endif_marker', 1]},
 inline => {normalize_method_args_with_optional_scope => ['inline_elseif', 1]},
 while => {normalize_method_args_with_optional_scope => ['while_attached', 1]},
);

{
 package ControlIfWhileNative::Deps;
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
 $result->{fields} = {map {$_ => snapshot($state, $value->{$_}, $visiting)} sort keys %$value} if $type eq 'HASH';
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
 return undef if $key eq 'lower_method_value_expr' || $key eq 'extract_array_symbol_name';
 if ($key eq 'split_action_ir_statements') {
  return [] if $state->{case}{split_empty} && defined($value) && $value =~ /^\s*\z/s;
  return [split /;/, $value];
 }
 return $value if $key eq 'normalize_method_tag_expr';
 die "unhandled if/while native callback $key";
}
sub observe {
 my ($label, $case_name, $options) = @_;
 my $case = $json->decode($json->encode($cases{$case_name}));
 my $state = {case => $case, input => $case->{input}, ids => {}, calls => [], authority => [],
  effects => [], counts => {}, held => [], returns => [], return_refs => [], parsed_calls => [], map_reads => []};
 $state->{input} = $options->{input} if exists $options->{input};
 $state->{fatal} = bless({label => $label}, 'ControlIfWhileNative::Fatal');
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
   unless ($cold || ($key ne 'parse_method_function_expr' && $key ne 'normalize_method_args_with_optional_scope')) {
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
 $deps{unrelated} = sub {die 'unrelated if/while dependency invoked'};
 delete $deps{$options->{missing}} if defined $options->{missing};
 $deps{$options->{bad}} = 'not CODE' if defined $options->{bad};
 my $branch = {if_stack => $case->{stack} || [], switch_stack => [],
  switch_counter => 3, while_counter => 7, rewrite_rules => []};
 my $before = {input => snapshot($state, $state->{input}), fatal_anchor => snapshot($state, $state->{fatal}),
  map => snapshot($state, \%deps), branch => snapshot($state, $branch)};
 if ($case->{tied}) {
  my %original = %deps;
  tie %deps, 'ControlIfWhileNative::Deps', $state, \%original, $case->{tied}, $make_callback->($case->{tied}, 1);
 }
 my $parent = sub {
  if ($options->{context} eq 'list') {
   my @values = $owners{$case->{owner}}->($state->{input}, $branch, \%deps);
   $state->{result} = [map {snapshot($state, $_)} @values];
  } elsif ($options->{context} eq 'void') {
   $owners{$case->{owner}}->($state->{input}, $branch, \%deps);
   $state->{result} = {context => 'void'};
  } else {
   my $value = $owners{$case->{owner}}->($state->{input}, $branch, \%deps);
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
 toolchain_scope => 'System Perl/stdlib reused read-only. Parser delegates to parent MethodExpr; injected normalizer checks min/max and retains its actual array, except the explicit copy case. Injected semicolon splitter treats whitespace as empty only in named cases; these are dependency probes, not facade DSL execution claims.'}), "\n";
