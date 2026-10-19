package LinkedSpec::PipelineCompositionAssertions;
use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr weaken);
use File::Basename ();
use File::Spec ();
use JSON::PP ();

sub same { return ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0 }
sub with_event {
 my ($work) = @_;
 LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('SOURCE', sub {
  LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers([], sub {
   LinkedSpec::ActionIR::SourceEmissions::_with_source_inputs(sub {
    my $event = {raw => 'SOURCE', kind => 'PROBE', contract_id => 'probe'};
    LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
     {event => $event, source => 'SOURCE', source_span => {start => 0, end => 6}});
    $work->($event)
   })
  })
 })
}
sub publish {
 my ($event, $text) = @_;
 my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
 LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, $text);
 return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder)
}

# These direct seams share one actual source/producer scope. An opaque child
# really publishes the equal text; an outer packet would expose inheritance.
for my $seam (qw(factory apply)) {
 with_event(sub {
  my ($event) = @_;
  my $opaque = sub { publish($event, 'same'); return 'same' };
  my $outer = sub {
   if ($seam eq 'factory') {
    my $factory = sub {
     $opaque->();
     return [{id => 'probe', lower => sub { 'unused' }}]
    };
    LinkedSpec::ActionIR::RewritePipeline::_build_action_rewrite_rules(
     'SameScope', {build_action_lowering_contracts => $factory});
   } else {
    my $rules = [{id => 'probe', apply => $opaque}];
    LinkedSpec::ActionIR::RewritePipeline::_lower_action_code_from_canonical_ir(
     'SameScope', 'SOURCE', $rules, {canonical_action_ir_events => [$event]});
   }
   return 'same'
  };
  LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($outer);
  my $capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
  is($capture->{value}, 'same', "$seam opaque nested publisher keeps its equal ordinary value");
  ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture, $outer, $event),
   "$seam opaque nested publisher cannot donate to the actual parent");
 });
}

for my $fail_at ('', qw(factory collect canonical apply find)) {
 with_event(sub {
  my ($outer_event) = @_;
  my $fatal = bless {}, 'LinkedSpec::PipelineCompositionAssertions::Fatal';
  my @weak_inner;
  my $outer = sub {
   my $outer_call = $LinkedSpec::ActionIR::SourceEmissions::_call;
   my $outer_producers = $LinkedSpec::ActionIR::SourceEmissions::_producers;
   my $outer_inputs = $LinkedSpec::ActionIR::SourceEmissions::_inputs;
   my $outer_token = LinkedSpec::ActionIR::SourceOrigins::_invocation_token();
   my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($outer_event);
   LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'outer');
   my $step = sub { die $fatal if $_[0] eq $fail_at };
   my $deps = {
    build_action_lowering_contracts => sub {
     for my $pair (
      [$LinkedSpec::ActionIR::SourceEmissions::_producers, $outer_producers, 'producer'],
      [$LinkedSpec::ActionIR::SourceEmissions::_inputs, $outer_inputs, 'input'],
      [LinkedSpec::ActionIR::SourceOrigins::_invocation_token(), $outer_token, 'source']) {
      ok(!same($pair->[0], $pair->[1]), "nested equal-source $pair->[2] scope is fresh $fail_at");
      push @weak_inner, $pair->[0];
      weaken($weak_inner[-1]);
     }
     $step->('factory');
     my $lower = sub { $step->('apply'); return 'inner' };
     LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($lower);
     return [{id => 'probe', lower => $lower}]
    },
    collect_action_helper_ir_nodes => sub { $step->('collect'); return {helper_action_ir_events => []} },
    build_canonical_action_ir_events => sub {
     $step->('canonical');
     return {canonical_action_ir_events => [{raw => 'SOURCE', kind => 'PROBE', contract_id => 'probe'}]}
    },
    find_unresolved_action_helpers => sub { $step->('find'); return {unresolved_helper_count => 0} },
   };
   my (@values, $error);
   eval { @values = LinkedSpec::ActionIR::RewritePipeline::_rewrite_action_code_with_diagnostics(
    'Nested', 'SOURCE', undef, $deps); 1 } or $error = $@;
   if (length $fail_at) { ok(same($error, $fatal), "nested fatal object identity $fail_at") }
   else { is($values[0], 'inner', 'nested actual successful result') }
   ok(same($LinkedSpec::ActionIR::SourceEmissions::_call, $outer_call), "nested actual outer call restores $fail_at");
   ok(same($LinkedSpec::ActionIR::SourceEmissions::_producers, $outer_producers), "nested producer registry restores $fail_at");
   ok(same($LinkedSpec::ActionIR::SourceEmissions::_inputs, $outer_inputs), "nested input registry restores $fail_at");
   ok(same(LinkedSpec::ActionIR::SourceOrigins::_invocation_token(), $outer_token), "nested source token restores $fail_at");
   ok(!grep(defined($_), @weak_inner), "nested completed registries release while parent stays live $fail_at");
   return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder)
  };
  LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($outer);
  my $capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
  is_deeply(LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture, $outer, $outer_event),
   {text => 'outer', fragments => [{kind => 'generated', output_span => {start => 0, end => 5}}], consumed => []},
   "nested success/fatal retains actual outer builder authority $fail_at");
 });
}

my $root = File::Spec->rel2abs(File::Basename::dirname(__FILE__).'/../../..');
my $script = "$root/docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/native-factory-probe.pl";
my $json;
{
 local $ENV{PERL5LIB} = '';
 local $ENV{PERL5OPT} = '';
 open my $child, '-|', $^X, '-I'.$root.'/perl', $script or die $!;
 local $/;
 $json = <$child>;
 close $child;
 is($?, 0, 'actual public Toolbox factory/canonical command succeeds');
}
my $observed = JSON::PP->new->utf8->decode($json);
ok(@{$observed->{canonical_calls}} > 0, 'actual public facade executes canonical callbacks');
for my $call (@{$observed->{canonical_calls}}) {
 for my $key (qw(actual_public_apply registered_actual producer_token input_token actual_origin)) {
  is($call->{$key}, 1, "actual public native $call->{contract} $key");
 }
}
is($observed->{scopes_restored}, 1, 'actual public native invocation releases scopes');
1;
