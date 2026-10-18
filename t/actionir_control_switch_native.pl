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
 switch => \&LinkedSpec::ActionIR::ControlFlow::_lower_switch_flow_statement,
 case => \&LinkedSpec::ActionIR::ControlFlow::_lower_case_flow_statement,
 default => \&LinkedSpec::ActionIR::ControlFlow::_lower_default_flow_statement,
 endcase => \&LinkedSpec::ActionIR::ControlFlow::_lower_endcase_flow_statement,
 endswitch => \&LinkedSpec::ActionIR::ControlFlow::_lower_endswitch_flow_statement,
 inline => sub {LinkedSpec::ActionIR::ControlFlow::_lower_inline_switch_branch_expr($_[0], 'value', 'hit', $_[1], $_[1]{inline_state}, $_[2])},
);
my @keys = qw(trim_action_ir_value parse_method_function_expr normalize_method_args_with_optional_scope lower_flow_composite_expr lower_method_value_expr split_action_ir_statements normalize_method_tag_expr extract_array_symbol_name);
my %required = map {$_ => ['normalize_method_args_with_optional_scope']} keys %owners;
my $marker = [{switch_var => 'value', hit_var => 'hit', open_case => 0, default_seen => 0, nested => {shared => 1}}];
my $open = [{%{$marker->[0]}, open_case => 1}];
my $seen = [{%{$marker->[0]}, default_seen => 1}];
my %cases = (
 switch_marker => {owner => 'switch', input => 'switch("a")'},
 switch_empty_arity => {owner => 'switch', input => 'switch()'},
 switch_inline => {owner => 'switch', input => 'switch("a", case("a", bare), default(print("last")))'},
 switch_inline_default_first => {owner => 'switch', input => 'switch("a", default(bare), case("a", bare))'},
 switch_inline_duplicate_default => {owner => 'switch', input => 'switch("a", default(bare), default(bare))'},
 switch_bad_branch => {owner => 'switch', input => 'switch("a", other(bare))'},
 switch_attached => {owner => 'switch', input => 'switch("a") { case("a"); bare; default(); bare }', decline_attached => 1},
 switch_attached_empty => {owner => 'switch', input => 'switch("a") {}', decline_attached => 1, split_empty => 1},
 switch_attached_conflict => {owner => 'switch', input => 'switch("a", case("a", bare)) { bare }', decline_attached => 1},
 switch_bad_action => {owner => 'switch', input => 'switch("a") { if(true) }', decline_attached => 1},
 switch_nested => {owner => 'switch', input => 'switch("a") { switch("b") {}; case("a") {} }', decline_attached => 1, split_empty => 1},
 switch_tied => {owner => 'switch', input => 'switch("a")', tied => 'normalize_method_args_with_optional_scope'},
 switch_copy_normalizer => {owner => 'switch', input => 'switch("a")', normalizer_copy => 1},
 switch_unicode => {owner => 'switch', input => 'switch("λ😀")'},
 case_marker => {owner => 'case', input => 'case("a")', stack => $marker},
 case_regex => {owner => 'case', input => 'case(/a+/)', stack => $marker},
 case_bare_tag => {owner => 'case', input => 'case(tag)', stack => $marker},
 case_open => {owner => 'case', input => 'case("a")', stack => $open},
 case_attached => {owner => 'case', input => 'case("a") { bare }', stack => $open, decline_attached => 1},
 case_bad_action => {owner => 'case', input => 'case("a") { if(true) }', stack => $open, decline_attached => 1},
 case_after_default => {owner => 'case', input => 'case("a")', stack => $seen},
 case_missing_stack => {owner => 'case', input => 'case("a")'},
 case_bad_arity => {owner => 'case', input => 'case()' , stack => $marker},
 case_extra_arity => {owner => 'case', input => 'case("a", bare)', stack => $marker},
 case_tied => {owner => 'case', input => 'case("a")', stack => $marker, tied => 'normalize_method_args_with_optional_scope'},
 default_marker => {owner => 'default', input => 'default()', stack => $marker},
 default_bare => {owner => 'default', input => 'default', stack => $open},
 default_attached => {owner => 'default', input => 'default { bare }', stack => $open, decline_attached => 1},
 default_bad_action => {owner => 'default', input => 'default { if(true) }', stack => $open, decline_attached => 1},
 default_duplicate => {owner => 'default', input => 'default()', stack => $seen},
 default_missing_stack => {owner => 'default', input => 'default()'},
 default_bad_arity => {owner => 'default', input => 'default(extra)', stack => $marker},
 endcase_open => {owner => 'endcase', input => 'endcase()', stack => $open},
 endcase_bare => {owner => 'endcase', input => 'endcase', stack => $open},
 endcase_closed => {owner => 'endcase', input => 'endcase()', stack => $marker},
 endcase_missing_stack => {owner => 'endcase', input => 'endcase()'},
 endcase_attached => {owner => 'endcase', input => 'endcase() { bare }', stack => $open, decline_attached => 1},
 endcase_bad_arity => {owner => 'endcase', input => 'endcase(extra)', stack => $open},
 endswitch_open => {owner => 'endswitch', input => 'endswitch()', stack => $open},
 endswitch_closed => {owner => 'endswitch', input => 'endswitch()', stack => $marker},
 endswitch_bare => {owner => 'endswitch', input => 'endswitch', stack => $marker},
 endswitch_nested => {owner => 'endswitch', input => 'endswitch()', stack => [@$marker, @$open]},
 endswitch_missing_stack => {owner => 'endswitch', input => 'endswitch()'},
 endswitch_attached => {owner => 'endswitch', input => 'endswitch() { bare }', stack => $open, decline_attached => 1},
 endswitch_bad_arity => {owner => 'endswitch', input => 'endswitch(extra)', stack => $marker},
 inline_case => {owner => 'inline', input => 'case("a", bare)'},
 inline_case_empty => {owner => 'inline', input => 'case("a")'},
 inline_case_regex => {owner => 'inline', input => 'case(/a+/, bare)'},
 inline_case_after_default => {owner => 'inline', input => 'case("a", bare)', inline_state => {default_seen => 1}},
 inline_case_attached => {owner => 'inline', input => 'case("a") { bare }', decline_attached => 1},
 inline_case_conflict => {owner => 'inline', input => 'case("a", bare) { bare }', decline_attached => 1},
 inline_case_bad_arity => {owner => 'inline', input => 'case()'},
 inline_default => {owner => 'inline', input => 'default(bare)'},
 inline_default_empty => {owner => 'inline', input => 'default()'},
 inline_default_duplicate => {owner => 'inline', input => 'default(bare)', inline_state => {default_seen => 1}},
 inline_default_attached => {owner => 'inline', input => 'default() { bare }', decline_attached => 1},
 inline_default_conflict => {owner => 'inline', input => 'default(bare) { bare }', decline_attached => 1},
 inline_default_bad_action => {owner => 'inline', input => 'default() { if(true) }', decline_attached => 1},
 inline_other => {owner => 'inline', input => 'other("a")'},
);
for my $owner (sort keys %owners) {
 for my $entry ([undefined => undef], [empty => ''], [zero => '0'], [wrong_method => 'other(true)']) {
  die 'duplicate native case '.$owner.'_'.$entry->[0] if exists $cases{$owner.'_'.$entry->[0]};
  $cases{$owner.'_'.$entry->[0]} = {owner => $owner, input => $entry->[1], stack => $marker};
 }
}
my %route_names = (switch => 'switch_marker', case => 'case_marker', default => 'default_marker',
 endcase => 'endcase_open', endswitch => 'endswitch_open', inline => 'inline_case');
my %routes = map {$_ => {normalize_method_args_with_optional_scope => [$route_names{$_}, 1]}} keys %owners;

{
 package ControlSwitchNative::Deps;
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
 die "unhandled switch native callback $key";
}
sub observe {
 my ($label, $case_name, $options) = @_;
 my $case = $json->decode($json->encode($cases{$case_name}));
 my $state = {case => $case, input => $case->{input}, ids => {}, calls => [], authority => [],
  effects => [], counts => {}, held => [], returns => [], return_refs => [], parsed_calls => [], map_reads => []};
 $state->{input} = $options->{input} if exists $options->{input};
 $state->{fatal} = bless({label => $label}, 'ControlSwitchNative::Fatal');
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
   unless ($cold || $key ne 'normalize_method_args_with_optional_scope') {
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
 $deps{unrelated} = sub {die 'unrelated switch dependency invoked'};
 delete $deps{$options->{missing}} if defined $options->{missing};
 $deps{$options->{bad}} = 'not CODE' if defined $options->{bad};
 my $branch = {if_stack => [], switch_stack => $case->{stack} || [], inline_state => $case->{inline_state} || {default_seen => 0},
  switch_counter => 3, while_counter => 7, rewrite_rules => []};
 my $before = {input => snapshot($state, $state->{input}), fatal_anchor => snapshot($state, $state->{fatal}),
  map => snapshot($state, \%deps), branch => snapshot($state, $branch)};
 if ($case->{tied}) {
  my %original = %deps;
  tie %deps, 'ControlSwitchNative::Deps', $state, \%original, $case->{tied}, $make_callback->($case->{tied}, 1);
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
