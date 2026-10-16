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
 single => \&LinkedSpec::ActionIR::ControlFlow::_lower_flow_branch_single_statement,
);
my @keys = qw(trim_action_ir_value parse_method_function_expr normalize_method_args_with_optional_scope lower_flow_composite_expr lower_method_value_expr split_action_ir_statements normalize_method_tag_expr extract_array_symbol_name);
my %required = (single => ['trim_action_ir_value']);
my %cases = (
 plain => {owner => 'single', input => 'bare'},
 spaced => {owner => 'single', input => '  bare  '},
 undefined_input => {owner => 'single', input => undef},
 empty_input => {owner => 'single', input => ''},
 whitespace => {owner => 'single', input => '   '},
 identity_whitespace => {owner => 'single', input => '   ', trim_identity => 1},
 zero => {owner => 'single', input => '0'},
 unicode => {owner => 'single', input => 'λ😀'},
 no_rules => {owner => 'single', input => 'bare', rules => 'undefined'},
 nonarray_rules => {owner => 'single', input => 'bare', rules => 'hash'},
 implicit_closures => {owner => 'single', input => 'bare', stack => [{implicit_close => 0}, {implicit_close => 1}, {implicit_close => 1}]},
 continuation => {owner => 'single', input => 'else', stack => [{implicit_close => 1}]},
 marker_if => {owner => 'single', input => 'if(true)'},
 attached_if => {owner => 'single', input => 'if(true) { bare }', decline_attached => 1},
 marker_endif => {owner => 'single', input => 'endif', stack => [{implicit_close => 0}]},
 typed_if => {owner => 'single', input => {kind => 'control_if', keyword => 'if', source => 'poison',
  condition => {kind => 'boolean', value => 1}, body => {kind => 'action_block', statements => []}}, decline_attached => 1},
 rule_accept => {owner => 'single', input => 'bare', rules => 'accept'},
 rule_reject_then_accept => {owner => 'single', input => 'bare', rules => 'reject_accept', stack => [{implicit_close => 0, nested => {shared => 1}}]},
 rule_rejects => {owner => 'single', input => 'bare', rules => 'rejects'},
 rule_zero => {owner => 'single', input => 'bare', rules => 'zero'},
 prefixed_rule => {owner => 'single', input => 'bare', rules => 'accept', stack => [{implicit_close => 1}]},
 rule_fatal => {owner => 'single', input => 'bare', rules => 'fatal'},
 tied_selection => {owner => 'single', input => 'bare', tied => 1},
 retained_child => {owner => 'single', input => 'outer'},
);
my %routes = (single => {trim_action_ir_value => 'plain'});

{
 package ControlSingleNative::Deps;
 sub TIEHASH { my ($class, $state, $original, $replacement) = @_; return bless {state => $state, original => $original, replacement => $replacement, reads => 0}, $class }
 sub FETCH {
  my ($self, $key) = @_;
  push @{$self->{state}{map_reads}}, $key;
  return ++$self->{reads} == 1 ? $self->{original}{$key} : $self->{replacement}
   if $key eq 'trim_action_ir_value';
  return $self->{original}{$key};
 }
 sub EXISTS { return exists $_[0]{original}{$_[1]} }
}

sub context { return !defined($_[0]) ? 'void' : $_[0] ? 'list' : 'scalar' }
sub same { return ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0 }
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
 if ($key eq 'trim_action_ir_value') {
  my $value = $args->[0];
  return $value if $state->{case}{trim_identity} || !defined($value) || ref($value);
  $value =~ s/^\s+//o;
  $value =~ s/\s+$//o;
  return $value;
 }
 if ($key eq 'parse_method_function_expr') {
  return undef if $state->{case}{decline_attached} && defined($args->[0]) && !ref($args->[0]) && $args->[0] =~ /\}\s*\z/s;
  require LinkedSpec::ActionIR::MethodExpr;
  return LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr($args->[0]);
 }
 if ($key eq 'normalize_method_args_with_optional_scope') {
  return undef unless ref($args->[0]) eq 'ARRAY' && @{$args->[0]} >= $args->[1];
  return $args->[0];
 }
 if ($key eq 'lower_flow_composite_expr') {
  return 1 if defined($args->[0]) && $args->[0] eq 'true';
  return 0 if defined($args->[0]) && $args->[0] eq 'false';
  return $args->[0];
 }
 return undef if $key eq 'lower_method_value_expr';
 return [split /;/, $args->[0]] if $key eq 'split_action_ir_statements';
 return $args->[0] if $key eq 'normalize_method_tag_expr';
 return undef if $key eq 'extract_array_symbol_name';
 die "unhandled native probe callback $key";
}

sub observe {
 my ($label, $case_name, $options) = @_;
 my $case = $json->decode($json->encode($cases{$case_name}));
 my $state = {case => $case, input => $case->{input}, ids => {}, calls => [],
  authority => [], effects => [], counts => {}, held => [], returns => [], return_refs => [], rule_calls => [], map_reads => [], candidates => [], args => $case->{parts} || []};
 $state->{input} = $options->{input} if exists $options->{input};
 $state->{call} = {method => $case->{method}, args => $state->{args}};
 $state->{fatal} = bless({label => $label}, 'ControlSingleNative::Fatal');
 my (%deps, %callbacks);
 my $publish = sub {
  my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
  LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'outer');
  LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
 };
 for my $key (@keys) {
  $callbacks{$key} = sub {
   my $want = wantarray;
   my $incoming = $@;
   my $number = ++$state->{counts}{$key};
   push @{$state->{calls}}, {key => $key, number => $number, context => context($want),
    args => [map {snapshot($state, $_)} @_], incoming_error => snapshot($state, $incoming),
    first_readonly => @_ ? (Internals::SvREADONLY($_[0]) ? 1 : 0) : undef,
    first_is_caller_slot => @_ ? same(\$_[0], \$state->{input}) : 0,
    first_is_argument_array => @_ ? same($_[0], $state->{args}) : 0};
   push @{$state->{held}}, {key => $key, number => $number, slot => \$_[0]} if @_;
   unless ($cold || $key ne 'trim_action_ir_value' || $number != 1) {
    my $call = $LinkedSpec::ActionIR::SourceEmissions::_call;
    push @{$state->{authority}}, {key => $key, number => $number,
     eligible => LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0,
     actual_callback => ref($call) eq 'HASH' ? same($call->{callback}, $callbacks{$key}) : 0};
   }
   my $target = defined($options->{key}) && $options->{key} eq $key && $number == ($options->{number} // 1);
   $publish->() if $target && $options->{authority};
   if ($target && ($options->{effect} || '') eq 'mutate') {
    if (ref($_[0]) eq 'ARRAY') { push @{$_[0]}, 'extra' }
    elsif (defined($_[0]) && !ref($_[0])) { $_[0] .= '!' }
    push @{$state->{effects}}, {key => $key, after => snapshot($state, $_[0])};
   }
   if ($target && ($options->{effect} || '') eq 'replace') {
    $deps{$key} = sub { push @{$state->{effects}}, {replacement => $key}; return ordinary($state, $key, \@_) };
    push @{$state->{effects}}, {replaced => $key};
   }
   $@ = 'successful-'.$key if $target && ($options->{effect} || '') eq 'error';
   die $state->{fatal} if $target && ($options->{effect} || '') eq 'fatal';
   return undef if $target && ($options->{effect} || '') eq 'undefined';
   my $value = ordinary($state, $key, \@_);
   push @{$state->{return_refs}}, $value if ref($value);
   push @{$state->{returns}}, {key => $key, number => $number, value => snapshot($state, $value)};
   return $value;
  };
  $deps{$key} = $callbacks{$key};
 }
 $deps{unrelated} = sub { die 'unrelated ControlFlow dependency invoked' };
 $state->{unrelated} = $deps{unrelated};
 delete $deps{$options->{missing}} if defined $options->{missing};
 $deps{$options->{bad}} = 'not CODE' if defined $options->{bad};
 my $branch = {if_stack => $case->{stack} || [], switch_stack => [{case_open => 0}],
  switch_counter => 3, while_counter => 7, rewrite_rules => []};
 my $rule_kind = $case->{rules} || '';
 my $make_rule = sub {
  my ($name, $result) = @_;
  return {id => $name, apply => sub {
   my $incoming = $@;
   push @{$state->{candidates}}, $_[1];
   push @{$state->{rule_calls}}, {name => $name, context => context(wantarray),
    expr => snapshot($state, $_[0]), slot => snapshot($state, \$_[0]),
    candidate_before => snapshot($state, $_[1]), incoming_error => snapshot($state, $incoming)};
   $_[1]{switch_counter} += 10;
   $_[1]{while_counter} += 20;
   $_[1]{if_stack}[0]{changed} = $name if @{$_[1]{if_stack}};
   $_[1]{if_stack}[0]{nested}{shared}++ if @{$_[1]{if_stack}} && ref($_[1]{if_stack}[0]{nested}) eq 'HASH';
   die $state->{fatal} if $result eq 'fatal';
   return undef if $result eq 'undefined';
   return '' if $result eq 'empty';
   return $_[0] if $result eq 'same';
   return '0' if $result eq 'zero';
   return 'accepted';
  }};
 };
 if ($rule_kind eq 'undefined') { $branch->{rewrite_rules} = undef }
 elsif ($rule_kind eq 'hash') { $branch->{rewrite_rules} = {} }
 elsif ($rule_kind eq 'accept') { $branch->{rewrite_rules} = [$make_rule->('accept', 'accept')] }
 elsif ($rule_kind eq 'reject_accept') { $branch->{rewrite_rules} = [$make_rule->('reject', 'same'), $make_rule->('accept', 'accept')] }
 elsif ($rule_kind eq 'rejects') { $branch->{rewrite_rules} = [map {$make_rule->($_, $_)} qw(undefined empty same)] }
 elsif ($rule_kind eq 'zero') { $branch->{rewrite_rules} = [$make_rule->('zero', 'zero')] }
 elsif ($rule_kind eq 'fatal') { $branch->{rewrite_rules} = [$make_rule->('fatal', 'fatal')] }
 my $before = {input => snapshot($state, $state->{input}), args => snapshot($state, $state->{args}),
  call => snapshot($state, $state->{call}), map => snapshot($state, \%deps), branch => snapshot($state, $branch)};
 if ($case->{tied}) {
  my %original = %deps;
  my $replacement = sub {push @{$state->{effects}}, {replacement => 'tied-trim'}; return ordinary($state, 'trim_action_ir_value', \@_)};
  tie %deps, 'ControlSingleNative::Deps', $state, \%original, $replacement;
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
   LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($callbacks{$options->{key}})
    if $options->{known};
  }
  my ($capture, $successful);
  my $ok = eval {
   $@ = 'caller-error';
   if ($cold) { $parent->() }
   else { $capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($parent) }
   $successful = snapshot($state, $@);
   1;
  };
  $state->{fatal_result} = snapshot($state, $@) unless $ok;
  $state->{successful_error} = $successful if $ok;
  unless ($cold) {
   $state->{parent_packet} = $capture && $capture->{emission} ? 1 : 0;
   my $registry = $LinkedSpec::ActionIR::SourceEmissions::_producers;
   $state->{child_packets} = scalar grep {
    same($_->{callback}, $callbacks{$options->{key} // ''})
   } values %{$registry->{captures}};
  }
 };
 if ($cold) { $work->() }
 else { LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('origin', sub {
  LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers([], $work);
 }) }
 return {label => $label, case => $case_name, options => $options,
  native => {before => $before, result => $state->{result}, calls => $state->{calls},
   effects => $state->{effects}, held_slots => snapshot($state, $state->{held} || []),
   callback_returns => $state->{returns} || [], returned_references => snapshot($state, $state->{return_refs} || []),
   input_after => snapshot($state, $state->{input}),
   args_after => snapshot($state, $state->{args}), call_after => snapshot($state, $state->{call}),
   map_after => snapshot($state, $case->{tied} ? {tied => 1} : \%deps),
   branch_after => snapshot($state, $branch), rule_calls => $state->{rule_calls},
   retained_candidates => snapshot($state, $state->{candidates}), map_reads => $state->{map_reads}, owner_error => $state->{owner_error},
   successful_error => $state->{successful_error}, fatal => $state->{fatal_result}},
  authority => {calls => $state->{authority}, parent_packet => $state->{parent_packet},
                child_packets => $state->{child_packets}}};
}

my @rows;
for my $name (sort keys %cases) {
 for my $context (qw(scalar list void)) {
  push @rows, observe("ordinary/$name/$context", $name, {context => $context});
 }
}
for my $effect (qw(mutate replace error fatal undefined)) {
 push @rows, observe("effect/single/trim_action_ir_value/1/$effect", 'plain',
  {context => 'scalar', key => 'trim_action_ir_value', number => 1, effect => $effect});
}
for my $kind (qw(missing bad)) {
 push @rows, observe("validation/single/trim_action_ir_value/$kind", 'plain',
  {context => 'scalar', $kind => 'trim_action_ir_value', input => undef});
}
unless ($cold) {
 for my $known (0, 1) {
  for my $context (qw(scalar list void)) {
   push @rows, observe("authority/single/trim_action_ir_value/1/$known/$context", 'retained_child',
    {context => $context, key => 'trim_action_ir_value', number => 1, known => $known, authority => 1});
  }
  push @rows, observe("retained-child/$known", 'retained_child',
   {context => 'scalar', key => 'trim_action_ir_value', number => 1, known => $known, authority => 1});
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
 toolchain_scope => 'System Perl and standard libraries reused read-only; no immutable portable toolchain claim.'}), "\n";
