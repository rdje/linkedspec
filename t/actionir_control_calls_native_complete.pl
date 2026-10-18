use strict;
use warnings;
use utf8;
use JSON::PP ();
use Scalar::Util qw(refaddr reftype);
use FindBin ();
use Cwd qw(abs_path);
use File::Spec ();
use LinkedSpec::ActionIR::ControlFlow ();
no warnings 'once';

my $cold = @ARGV && $ARGV[0] eq 'cold';
unless ($cold) {
 require LinkedSpec::ActionIR::SourceOrigins;
 require LinkedSpec::ActionIR::SourceEmissions;
}
my $json = JSON::PP->new->canonical->ascii;
my $root = abs_path($FindBin::Bin.'/..');
my %owners = (
 direct => \&LinkedSpec::ActionIR::ControlFlow::_lower_flow_branch_direct_control_flow_statement,
 rule => \&LinkedSpec::ActionIR::ControlFlow::_lower_flow_branch_single_statement,
);
my %builtin = (
 if => \&LinkedSpec::ActionIR::ControlFlow::_lower_if_flow_statement,
 elseif => \&LinkedSpec::ActionIR::ControlFlow::_lower_elseif_flow_statement,
 else => \&LinkedSpec::ActionIR::ControlFlow::_lower_else_flow_statement,
 endif => \&LinkedSpec::ActionIR::ControlFlow::_lower_endif_flow_statement,
 while => \&LinkedSpec::ActionIR::ControlFlow::_lower_while_flow_statement,
 switch => \&LinkedSpec::ActionIR::ControlFlow::_lower_switch_flow_statement,
 case => \&LinkedSpec::ActionIR::ControlFlow::_lower_case_flow_statement,
 default => \&LinkedSpec::ActionIR::ControlFlow::_lower_default_flow_statement,
 endcase => \&LinkedSpec::ActionIR::ControlFlow::_lower_endcase_flow_statement,
 endswitch => \&LinkedSpec::ActionIR::ControlFlow::_lower_endswitch_flow_statement,
);
my %builtin_names = map {('LinkedSpec::ActionIR::ControlFlow::_lower_'.$_.'_flow_statement') => $_}
 qw(if elseif else endif while switch case default endcase endswitch);
my @keys = qw(trim_action_ir_value parse_method_function_expr normalize_method_args_with_optional_scope
 lower_flow_composite_expr lower_method_value_expr split_action_ir_statements normalize_method_tag_expr extract_array_symbol_name);

{
 package ControlCallsNative::Rule;
 sub TIEHASH {my ($class, $storage, $state) = @_; return bless {storage => $storage, state => $state}, $class}
 sub FETCH {
  my ($self, $key) = @_;
  push @{$self->{state}{rule_reads}}, $key;
  if ($key eq 'apply' && $self->{state}{fetch_effect}) {
   my $before = $self->{state}{branch}{switch_counter};
   $self->{state}{branch}{switch_counter} += 100;
   push @{$self->{state}{fetch_observations}}, {before => $before, after => $self->{state}{branch}{switch_counter}};
  }
  return $self->{storage}{$key};
 }
 sub STORE {$_[0]{storage}{$_[1]} = $_[2]}
 sub EXISTS {exists $_[0]{storage}{$_[1]}}
 sub FIRSTKEY {my $self = shift; keys %{$self->{storage}}; each %{$self->{storage}}}
 sub NEXTKEY {each %{$_[0]{storage}}}
 sub SCALAR {scalar %{$_[0]{storage}}}
}
{
 package ControlCallsNative::Callable;
 use overload '&{}' => sub {$_[0]{callback}}, fallback => 1;
}
{
 package ControlCallsNative::Value;
 use overload '""' => sub {++$_[0]{coercions}; return $_[0]{text}}, fallback => 1;
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

sub observe {
 my ($label, $options) = @_;
 my $state = {ids => {}, calls => [], dependencies => [], authority => [], invocations => [],
  seen_builtin => {}, builtin_entries => [], held => [], rule_reads => [], candidates => [], effects => [], counts => {}, return_anchors => []};
 my $input = exists($options->{input}) ? $options->{input} : $options->{owner} eq 'direct' ? 'if(true)' : 'bare';
 my $fatal = bless {label => $label}, 'ControlCallsNative::Fatal';
 my $value_object = bless {text => 'outer', coercions => 0}, 'ControlCallsNative::Value';
 my $branch = {if_stack => [], switch_stack => [], switch_counter => 3, while_counter => 7, rewrite_rules => []};
 $branch->{if_stack} = [{implicit_close => 0, else_seen => 0, nested => {shared => 1}}]
  if $options->{owner} eq 'rule' || ($options->{method} || '') =~ /^(?:elif|elseif|else|endif)$/;
 $branch->{switch_stack} = [{switch_var => 'value', hit_var => 'hit', open_case => 1,
  default_seen => 0, nested => {shared => 1}}]
  if ($options->{method} || '') =~ /^(?:case|default|endcase|endswitch)$/;
 $state->{branch} = $branch;
 $state->{fetch_effect} = $options->{fetch_effect};
 my (%deps, %dep_names, %callback_names, @rule_stores);
 for my $key (@keys) {
  my $callback = sub {
   my $want = wantarray;
   my $incoming = $@;
   for my $depth (0 .. 30) {
    my @frame = caller($depth);
    last unless @frame;
    next unless exists $builtin_names{$frame[3] || ''};
    my $name = $builtin_names{$frame[3]};
    push @{$state->{builtin_entries}}, {name => $name, context => context($frame[5])}
     unless $state->{seen_builtin}{$name}++;
    last;
   }
   push @{$state->{dependencies}}, {key => $key, context => context($want),
    args => [map {snapshot($state, $_)} @_], incoming_error => snapshot($state, $incoming)};
   if ($key eq 'trim_action_ir_value') {
    my $value = $_[0];
    return $value unless defined($value) && !ref($value);
    $value =~ s/^\s+//o; $value =~ s/\s+$//o;
    return $value;
   }
   if ($key eq 'parse_method_function_expr') {
    require LinkedSpec::ActionIR::MethodExpr;
    return undef if defined($_[0]) && !ref($_[0]) && $_[0] =~ /\}\s*\z/s;
    return LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr($_[0]);
   }
   if ($key eq 'normalize_method_args_with_optional_scope') {
    return undef unless ref($_[0]) eq 'ARRAY' && @{$_[0]} >= $_[1] && (!defined($_[2]) || @{$_[0]} <= $_[2]);
    return $_[0];
   }
   if ($key eq 'lower_flow_composite_expr') {
    return 1 if defined($_[0]) && $_[0] eq 'true';
    return 0 if defined($_[0]) && $_[0] eq 'false';
    return $_[0];
   }
   return undef if $key eq 'lower_method_value_expr' || $key eq 'extract_array_symbol_name';
   return $_[0] if $key eq 'normalize_method_tag_expr';
   return defined($_[0]) && $_[0] !~ /^\s*\z/s ? [split /;/, $_[0]] : []
    if $key eq 'split_action_ir_statements';
   die "unhandled calls native dependency $key";
  };
  $deps{$key} = $callback;
  $dep_names{refaddr($callback)} = $key;
 }
 my $publish = sub {
  my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
  LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'outer');
  LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
 };
 my $make_callback;
 $make_callback = sub {
  my ($name, $generation, $result_kind) = @_;
  my $callback;
  $callback = sub {
   my $want = wantarray;
   my $incoming = $@;
   my $number = ++$state->{counts}{$name.'/'.$generation};
   push @{$state->{candidates}}, $_[1] if $options->{owner} eq 'rule';
   push @{$state->{held}}, \$_[0];
   push @{$state->{calls}}, {name => $name, generation => $generation, number => $number,
    context => context($want), args => [map {snapshot($state, $_)} @_],
    first_readonly => Internals::SvREADONLY($_[0]) ? 1 : 0,
    first_is_caller_slot => same(\$_[0], \$input), second_is_branch => same($_[1], $branch),
    third_is_deps => @_ > 2 ? same($_[2], \%deps) : undef, incoming_error => snapshot($state, $incoming)};
   unless ($cold) {
    my $call = $LinkedSpec::ActionIR::SourceEmissions::_call;
    push @{$state->{authority}}, {name => $name, generation => $generation, number => $number,
     context => context($want), actual_callback => ref($call) eq 'HASH' ? same($call->{callback}, $callback) : 0,
     eligible => LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0};
    $publish->() if $options->{publish};
   }
   $_[1]{switch_counter} += 10;
   $_[1]{while_counter} += 20;
   $_[1]{if_stack}[0]{changed} = $name if @{$_[1]{if_stack} || []};
   $_[1]{if_stack}[0]{nested}{shared}++ if @{$_[1]{if_stack} || []} && ref($_[1]{if_stack}[0]{nested}) eq 'HASH';
   my $effect = $options->{effect} || '';
   if ($effect eq 'mutate' || $name eq 'mutate-reject') {
    $_[0] .= '!';
    push @{$state->{effects}}, {name => $name, mutated => snapshot($state, $_[0])};
   }
   if ($effect eq 'replace' && !$generation && @rule_stores) {
    $rule_stores[0]{apply} = $make_callback->('replacement', 1, 'outer');
    push @{$state->{effects}}, {replaced => 1};
   }
   $@ = 'successful-'.$name if $effect eq 'error';
   die $fatal if $effect eq 'fatal' || $result_kind eq 'fatal';
   return undef if $result_kind eq 'undefined';
   return '' if $result_kind eq 'empty' || $name eq 'mutate-reject';
   return $_[0] if $result_kind eq 'same' || ($options->{repeat} && !$generation);
   return '0' if $result_kind eq 'zero';
   return [] if $result_kind eq 'array';
   return $value_object if $result_kind eq 'object';
   return ('outer', 'extra') if $result_kind eq 'list' && $want;
   return 'outer';
  };
  $callback_names{refaddr($callback)} = {name => $name, generation => $generation};
  return $callback;
 };
 my $actual = $make_callback->('target', 0, $options->{result} || 'outer');
 my $variant = $options->{variant} || 'code';
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::ControlFlow::calls_native_named = $actual;
 my $selected = $variant eq 'qualified' ? 'LinkedSpec::ActionIR::ControlFlow::calls_native_named'
  : $variant eq 'unqualified' ? 'calls_native_named'
  : $variant eq 'glob' ? \*LinkedSpec::ActionIR::ControlFlow::calls_native_named
  : $variant eq 'blessed-code' ? bless(sub {return $actual->(@_)}, 'ControlCallsNative::BlessedCode')
  : $variant eq 'callable' ? bless({callback => $actual}, 'ControlCallsNative::Callable')
  : $variant eq 'undefined' ? undef : $variant eq 'array' ? [] : $variant eq 'hash' ? {} : $actual;
 if ($options->{owner} eq 'rule') {
  push @rule_stores, {id => 'target-rule', apply => $selected};
  my $rule = $rule_stores[0];
  if ($options->{tied}) {
   my %tied;
   tie %tied, 'ControlCallsNative::Rule', $rule_stores[0], $state;
   $rule = \%tied;
  }
  $branch->{rewrite_rules} = [$rule];
  unshift @{$branch->{rewrite_rules}}, {id => 'mutate-reject', apply => $make_callback->('mutate-reject', 0, 'empty')}
   if $options->{reject_first};
  push @{$branch->{rewrite_rules}}, $rule if $options->{repeat};
  $branch->{rewrite_rules} = undef if $options->{no_rules};
 }
 my $before = {input => snapshot($state, $input), branch => snapshot($state, $branch),
  deps => snapshot($state, \%deps), selected => snapshot($state, $selected), fatal => snapshot($state, $fatal)};
 my $parent = sub {
  my $owner = $owners{$options->{owner}};
  if ($options->{context} eq 'list') {
   my @values = $owner->($input, $branch, \%deps);
   push @{$state->{return_anchors}}, grep {ref($_)} @values;
   $state->{result} = [map {snapshot($state, $_)} @values];
  } elsif ($options->{context} eq 'void') {
   $owner->($input, $branch, \%deps);
   $state->{result} = {context => 'void'};
  } else {
   my $value = $owner->($input, $branch, \%deps);
   push @{$state->{return_anchors}}, $value if ref($value);
   $state->{result} = snapshot($state, $value);
  }
  $state->{owner_error} = snapshot($state, $@);
  return 'outer';
 };
 my %builtin_refs = map {refaddr($builtin{$_}) => $_} sort keys %builtin;
 my $work = sub {
  unless ($cold) {
   $state->{event} = {raw => 'origin'};
   LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($state->{event},
    {event => $state->{event}, source => 'origin', source_span => {start => 0, end => 6}});
   LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($parent);
   LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($actual) if ($options->{grant} || '') eq 'actual';
   LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($builtin{if}) if ($options->{grant} || '') eq 'native';
  }
  my ($capture, $successful);
  my $ok = eval {
   $@ = 'caller-error';
   if ($cold) {$parent->()}
   else {$capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($parent)}
   $successful = snapshot($state, $@);
   1;
  };
  my $error = $@;
  $state->{fatal} = snapshot($state, $error) unless $ok;
  $state->{fatal_is_original} = !$ok && same($error, $fatal) ? 1 : 0;
  $state->{successful_error} = $successful if $ok;
  unless ($cold) {
   $state->{parent_packet} = $capture && $capture->{emission} ? 1 : 0;
   my $registry = $LinkedSpec::ActionIR::SourceEmissions::_producers;
   $state->{child_packets} = scalar grep {same($_->{callback}, $actual)} values %{$registry->{captures}};
  }
 };
 my $run = sub {
  if ($cold) {$work->(); return}
  my $invoke = \&LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency;
  local *LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency = sub {
   my $callback = shift;
   my $want = wantarray;
   my $address = ref($callback) ? refaddr($callback) : 0;
   my $focus = $callback_names{$address};
   my $name = $builtin_refs{$address};
   push @{$state->{invocations}}, {focus => $focus, builtin => $name, context => context($want)}
    if $focus || defined($name);
   return $invoke->($callback, @_);
  };
  LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('origin', sub {
   LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers([], $work);
  });
 };
 if ($options->{shadow}) {
  local *LinkedSpec::ActionIR::ControlFlow::_lower_if_flow_statement = $actual;
  $run->();
 } else {$run->()}
 return {label => $label, options => $options,
  native => {before => $before, result => $state->{result}, calls => $state->{calls},
   dependencies => $state->{dependencies}, builtin_entries => $state->{builtin_entries},
   held_slots => snapshot($state, $state->{held}), candidates => snapshot($state, $state->{candidates}),
   rule_reads => $state->{rule_reads}, rule_stores => snapshot($state, \@rule_stores),
   input_after => snapshot($state, $input), branch_after => snapshot($state, $branch),
   deps_after => snapshot($state, \%deps), selected_after => snapshot($state, $selected),
   value_object => snapshot($state, $value_object), effects => $state->{effects},
   ($options->{fetch_effect} ? (fetch_observations => $state->{fetch_observations}) : ()),
   owner_error => $state->{owner_error}, successful_error => $state->{successful_error},
   fatal => $state->{fatal}, fatal_is_original => $state->{fatal_is_original}},
  authority => {calls => $state->{authority}, invocations => $state->{invocations},
   parent_packet => $state->{parent_packet}, child_packets => $state->{child_packets}}};
}

my @rows;
my %labels;
sub record {
 my ($label, $options) = @_;
 die "duplicate native row $label" if $labels{$label}++;
 push @rows, observe($label, $options);
}
for my $context (qw(scalar list void)) {
 for my $pair ([if => 'if(true)'], [i => 'i(true)'], [elif => 'elif(true)'], [elseif => 'elseif(true)'],
  [else => 'else()'], [endif => 'endif()'], [while => 'while(false) {}'], [switch => 'switch("a")'],
  [case => 'case("a")'], [default => 'default()'], [endcase => 'endcase()'], [endswitch => 'endswitch()']) {
  record("builtin/$pair->[0]/$context", {owner => 'direct', method => $pair->[0], input => $pair->[1], context => $context});
 }
 for my $owner (qw(direct rule)) {
  for my $pair ([unicode => $owner eq 'direct' ? 'if("λ😀")' : 'λ😀'],
                [crlf => $owner eq 'direct' ? "if(\r\ntrue\r\n)" : "bare\r\n"]) {
   record("text/$owner/$pair->[0]/$context", {owner => $owner, shadow => $owner eq 'direct' ? 1 : 0,
    input => $pair->[1], context => $context, grant => 'actual', publish => 1});
  }
  for my $grant (qw(none actual native)) {
   record("authority/$owner/$grant/$context", {owner => $owner, shadow => $owner eq 'direct' ? 1 : 0,
    grant => $grant, context => $context, publish => 1});
  }
  for my $result (qw(undefined empty same zero array object list fatal)) {
   record("result/$owner/$result/$context", {owner => $owner, shadow => $owner eq 'direct' ? 1 : 0,
    result => $result, context => $context, grant => 'actual', publish => 1});
  }
  for my $effect (qw(mutate error fatal)) {
   record("effect/$owner/$effect/$context", {owner => $owner, shadow => $owner eq 'direct' ? 1 : 0,
    effect => $effect, context => $context, grant => 'actual', publish => 1});
  }
 }
 for my $variant (qw(code qualified unqualified glob blessed-code callable undefined array hash)) {
  for my $tied (0, 1) {
   record("selection/rule/$variant/$tied/$context", {owner => 'rule', variant => $variant, tied => $tied,
    context => $context, grant => 'actual', publish => 1});
  }
 }
 record("selection/rule/fetch-effect/$context", {owner => 'rule', context => $context,
  grant => 'actual', publish => 1, tied => 1, fetch_effect => 1});
 for my $case (qw(reject-first repeat-replace no-rules)) {
  record("ordering/rule/$case/$context", {owner => 'rule', context => $context, grant => 'actual', publish => 1,
   reject_first => $case eq 'reject-first' ? 1 : 0, repeat => $case eq 'repeat-replace' ? 1 : 0,
   effect => $case eq 'repeat-replace' ? 'replace' : '', no_rules => $case eq 'no-rules' ? 1 : 0, tied => 1});
 }
 for my $input (undef, '', ' ', 'bare', 'unknown(true)') {
  my $name = defined($input) ? length($input) ? $input : 'empty' : 'undefined';
  record("guard/direct/$name/$context", {owner => 'direct', input => $input, context => $context});
 }
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
