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
 expand => \&LinkedSpec::ActionIR::ControlFlow::_expand_flow_branch_action_exprs,
);
my @keys = qw(trim_action_ir_value split_action_ir_statements);
my %required = (expand => [@keys]);
my %cases = (
 plain => {owner => 'expand', input => 'plain', parts => ['unused']},
 block => {owner => 'expand', input => '{ first; second }', parts => ['first', 'second']},
 empty_block => {owner => 'expand', input => '{}', parts => []},
 nested_block => {owner => 'expand', input => '{ { inner }; last }', parts => ['{ inner }', 'last']},
 unicode_block => {owner => 'expand', input => "{ λ😀; second }", parts => ["λ😀", 'second']},
 malformed_block => {owner => 'expand', input => '{ first } extra', parts => ['unused']},
 empty_input => {owner => 'expand', input => '', parts => ['unused']},
 undefined_input => {owner => 'expand', input => undef, parts => ['unused']},
 whitespace_input => {owner => 'expand', input => '   ', parts => ['unused']},
 split_undefined => {owner => 'expand', input => '{ first }', split_kind => 'undefined'},
 split_hash => {owner => 'expand', input => '{ first }', split_kind => 'hash'},
 split_zero => {owner => 'expand', input => '{ first }', split_kind => 'zero'},
 split_blessed_array => {owner => 'expand', input => '{ first }', parts => ['first'], split_kind => 'blessed'},
 zero_part => {owner => 'expand', input => '{ zero }', parts => ['0']},
 child_packet => {owner => 'expand', input => 'outer', parts => []},
);
my %routes = (expand => {map {$_ => 'block'} @keys});

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
 $result->{fields} = {map {$_ => snapshot($state, $value->{$_}, $visiting)} sort keys %$value} if $type eq 'HASH';
 return $result;
}
sub ordinary {
 my ($state, $key, $args) = @_;
 return $args->[0] if $key eq 'trim_action_ir_value';
 if ($key eq 'split_action_ir_statements') {
  my $kind = $state->{case}{split_kind} || '';
  return undef if $kind eq 'undefined';
  return {} if $kind eq 'hash';
  return '0' if $kind eq 'zero';
  bless $state->{args}, 'ControlExpansionNative::Statements' if $kind eq 'blessed';
  return $state->{args};
 }
 die "unhandled native probe callback $key";
}
sub observe {
 my ($label, $case_name, $options) = @_;
 my $case = $json->decode($json->encode($cases{$case_name}));
 my $state = {case => $case, input => $case->{input}, ids => {}, calls => [],
  authority => [], effects => [], counts => {}, args => $case->{parts} || []};
 $state->{input} = $options->{input} if exists $options->{input};
 $state->{call} = {method => $case->{method}, args => $state->{args}};
 $state->{fatal} = bless({label => $label}, 'ControlExpansionNative::Fatal');
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
   unless ($cold) {
    my $call = $LinkedSpec::ActionIR::SourceEmissions::_call;
    push @{$state->{authority}}, {key => $key, number => $number,
     eligible => LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0,
     actual_callback => ref($call) eq 'HASH' ? same($call->{callback}, $callbacks{$key}) : 0};
   }
   my $target = defined($options->{key}) && $options->{key} eq $key && $number == 1;
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
   if ($target && ($options->{effect} || '') eq 'replace_downstream') {
    $deps{split_action_ir_statements} = sub {
     push @{$state->{effects}}, {replacement => 'split_action_ir_statements'};
     return ['replacement'];
    };
    push @{$state->{effects}}, {replaced => 'split_action_ir_statements'};
   }
   $@ = 'successful-'.$key if $target && ($options->{effect} || '') eq 'error';
   die $state->{fatal} if $target && ($options->{effect} || '') eq 'fatal';
   return undef if $target && ($options->{effect} || '') eq 'undefined';
   return ordinary($state, $key, \@_);
  };
  $deps{$key} = $callbacks{$key};
 }
 $deps{unrelated} = sub { die 'unrelated ControlFlow dependency invoked' };
 delete $deps{$options->{missing}} if defined $options->{missing};
 $deps{$options->{bad}} = 'not CODE' if defined $options->{bad};
 my $before = {input => snapshot($state, $state->{input}), args => snapshot($state, $state->{args}),
               call => snapshot($state, $state->{call}), map => snapshot($state, \%deps)};
 my $parent = sub {
  if ($options->{context} eq 'list') {
   my @values = $owners{$case->{owner}}->($state->{input}, \%deps);
   $state->{result} = [map {snapshot($state, $_)} @values];
  } elsif ($options->{context} eq 'void') {
   $owners{$case->{owner}}->($state->{input}, \%deps);
   $state->{result} = {context => 'void'};
  } else {
   my $value = $owners{$case->{owner}}->($state->{input}, \%deps);
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
   effects => $state->{effects}, input_after => snapshot($state, $state->{input}),
   args_after => snapshot($state, $state->{args}), call_after => snapshot($state, $state->{call}),
   map_after => snapshot($state, \%deps), owner_error => $state->{owner_error},
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
for my $owner (sort keys %required) {
 for my $key (@{$required{$owner}}) {
  my $case = $routes{$owner}{$key};
  for my $effect (qw(mutate replace error fatal undefined)) {
   push @rows, observe("effect/$owner/$key/$effect", $case,
    {context => 'scalar', key => $key, effect => $effect});
  }
  for my $kind (qw(missing bad)) {
   push @rows, observe("validation/$owner/$key/$kind", $case,
    {context => 'scalar', $kind => $key, input => undef});
  }
  next if $cold;
  for my $known (0, 1) {
   for my $context (qw(scalar list void)) {
    push @rows, observe("authority/$owner/$key/$known/$context", $case,
     {context => $context, key => $key, known => $known, authority => 1});
   }
  }
 }
}
for my $owner (qw(expand)) {
 push @rows, observe("selection/$owner/replace-downstream", $routes{$owner}{trim_action_ir_value},
  {context => 'scalar', key => 'trim_action_ir_value', effect => 'replace_downstream'});
}
unless ($cold) {
 for my $known (0, 1) {
  push @rows, observe("retained-child/$known", 'child_packet',
   {context => 'scalar', key => 'trim_action_ir_value', known => $known, authority => 1});
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
