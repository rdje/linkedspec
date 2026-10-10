use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr weaken);
use JSON::PP ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::Contracts ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my $label = 'FactoryFixture';
my $source = 'opaque_literal';
my $defaults = LinkedSpec::ActionIR::Contracts::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my $deps = {map { $_ => sub { return undef } } keys %$defaults};
$deps->{bare_symbol_kind} = sub { return undef };
my @factories = (
 ['LinkedSpec::ActionIR::Contracts', '_build_call_and_dispatch_contracts'],
 ['LinkedSpec::ActionIR::Contracts', '_build_recursive_observation_contracts'],
 ['LinkedSpec::ActionIR::Contracts', '_build_inter_match_gap_contracts'],
 ['LinkedSpec::ActionIR::Contracts', '_build_recognition_transaction_contracts'],
 ['LinkedSpec::ActionIR::StagedParseJob', 'build_contracts'],
 ['LinkedSpec::ActionIR::ProgressiveSpanDispatch', 'build_contracts'],
 ['LinkedSpec::ActionIR::Contracts', '_build_return_contracts'],
 ['LinkedSpec::ActionIR::Contracts', '_build_capture_and_cursor_contracts'],
 ['LinkedSpec::ActionIR::Contracts', '_build_passthrough_ir_contracts'],
 ['LinkedSpec::ActionIR::Contracts', '_build_assignment_and_regex_contracts'],
 ['LinkedSpec::ActionIR::Contracts', '_build_array_pipeline_contracts'],
 ['LinkedSpec::ActionIR::Contracts', '_build_dropped_value_contracts'],
 ['LinkedSpec::ActionIR::Contracts', '_build_flow_control_contracts'],
 ['LinkedSpec::ActionIR::Contracts', '_build_emit_and_declare_contracts'],
);
sub catalogue { LinkedSpec::ActionIR::Contracts::build_action_lowering_contracts($label, $deps) }
sub producers { LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers(@_) }
sub capture { LinkedSpec::ActionIR::SourceEmissions::_capture_emission(@_) }
sub source_scope { LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source, $_[0]) }
sub event {
 my $event = {raw => $source};
 LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
  {event => $event, source => $source, source_span => {start => 0, end => length($source)}});
 return $event
}
sub emit {
 my ($event) = @_;
 my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
 LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, $source);
 return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder)
}

sub observations {
 my (%identities, @catalogues, @live_catalogues);
 my $next = 0;
 for (1..2) {
  my $contracts = catalogue();
  push @live_catalogues, $contracts;
  my @rows;
  for my $contract (@$contracts) {
   my %metadata;
   for my $key (sort keys %$contract) {
    my $value = $contract->{$key};
    if (ref($value) eq 'CODE') {
     my $address = refaddr($value);
     $identities{$address} //= ++$next;
     $metadata{$key} = {callback_identity => $identities{$address}};
    } elsif (ref($value) eq 'Regexp') { $metadata{$key} = "$value" }
    else { $metadata{$key} = $value }
   }
   my $arg = $source;
   my $ctx = {event => {raw => $source}};
   my $value = $contract->{lower}->($arg, $ctx);
   push @rows, {metadata => \%metadata, value => $value, arg => $arg};
  }
  push @catalogues, \@rows;
 }
 return \@catalogues
}

# Existing constructor APIs only: capture the same full ordinary catalogues on
# original/current source. Native callback reuse patterns are normalized by
# first-seen actual identity across both live returned catalogues.
if (@ARGV && $ARGV[0] eq 'observe') {
 print JSON::PP->new->canonical->encode(observations()), "\n";
 exit 0
}

source_scope(sub {
 producers([], sub {
  my (@snapshots, @registered);
  my $native_register = \&LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer;
  my $native_factory_return = \&LinkedSpec::ActionIR::Contracts::_register_native_contracts;
  no warnings 'redefine';
  local *LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer = sub {
   push @registered, $_[0]; return $native_register->(@_)
  };
  local *LinkedSpec::ActionIR::Contracts::_register_native_contracts = sub {
   my ($array) = @_;
   my @hashes = map { refaddr($_) } @$array;
   my @callbacks = map { refaddr($_->{lower}) } @$array;
   my $returned = $native_factory_return->(@_);
   push @snapshots, [refaddr($array) == refaddr($returned) ? 1 : 0,
    [@hashes], [map { refaddr($_) } @$returned],
    [@callbacks], [map { refaddr($_->{lower}) } @$returned]];
   return $returned
  };
  my $contracts = catalogue();
  is(scalar @snapshots, 12, 'all twelve local literal-return seams execute exactly once');
  for my $index (0..11) {
   my $row = $snapshots[$index] // [undef, [], [], [], []];
   is($row->[0], 1, "local seam $index returns the actual array");
   is_deeply($row->[2], $row->[1], "local seam $index preserves actual public contract hashes");
   is_deeply($row->[4], $row->[3], "local seam $index preserves actual public lower references");
  }
  is_deeply([map { refaddr($_) } @registered], [map { refaddr($_->{lower}) } @$contracts],
   'complete construction order registers each actual returned callback once');
  my $eligibility = \&LinkedSpec::ActionIR::SourceEmissions::_eligible_call;
  my @seen;
  local *LinkedSpec::ActionIR::SourceEmissions::_eligible_call = sub {
   my $eligible = $eligibility->(); push @seen, $eligible ? 1 : 0; return $eligible
  };
  for my $contract (@$contracts) {
   @seen = ();
   my $result = capture($contract->{lower}, $source, {event => {raw => $source}});
   is($result->{value}, $source, "$contract->{id} ordinary callback value remains native");
   is($seen[-1], 1, "$contract->{id} actual returned callback is selected in its producer scope");
  }
 });
});

for my $factory (@factories) {
 my ($package, $method) = @$factory;
 my $name = $package.'::'.$method;
 source_scope(sub {
  my $event = event();
  my $opaque = sub { emit($event); return $source };
  my $fake = [{id => 'copied_native_name', lower => $opaque}];
  no strict 'refs';
  no warnings 'redefine';
  local *{$name} = sub { return $fake };
  producers([], sub {
   my $contracts = catalogue();
   my ($returned) = grep { $_->{id} eq 'copied_native_name' } @$contracts;
   is(refaddr($returned), refaddr($fake->[0]), "$name substituted factory keeps its actual returned hash");
   is(refaddr($returned->{lower}), refaddr($opaque), "$name substituted factory keeps its actual public callback");
   my $result = capture($returned->{lower});
   is($result->{value}, $source, "$name substituted factory ordinary value survives");
   ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $opaque, $event),
    "$name substituted factory cannot register its opaque callback");
  });
 });
}

source_scope(sub {
 my $weak;
 producers([], sub {
  my $contracts = catalogue();
  my ($contract) = grep { $_->{id} eq 'push_single_arg' } @$contracts;
  $weak = $contract->{lower}; weaken($weak);
  undef $contract; undef $contracts;
  ok(defined($weak), 'producer scope retains actual lexical factory callback while eligible');
 });
 ok(!defined($weak), 'producer scope exit releases actual lexical factory callback');
});

source_scope(sub {
 producers([], sub {
  my $contracts = catalogue();
  my ($contract) = grep { $_->{id} eq 'call' } @$contracts;
  my $callback = $contract->{lower};
  my $eligible = \&LinkedSpec::ActionIR::SourceEmissions::_eligible_call;
  my @seen;
  no warnings 'redefine';
  local *LinkedSpec::ActionIR::SourceEmissions::_eligible_call = sub {
   my $value = $eligible->(); push @seen, $value ? 1 : 0; return $value
  };
  source_scope(sub { @seen = (); capture($callback, $source); is($seen[-1], 0, 'nested equal source cannot borrow constructor registration') });
  producers([], sub { @seen = (); capture($callback, $source); is($seen[-1], 0, 'nested producer cannot borrow constructor registration') });
  @seen = (); capture($callback, $source);
  is($seen[-1], 1, 'nested scope exit restores actual enclosing constructor selection');
 });
});

done_testing;
