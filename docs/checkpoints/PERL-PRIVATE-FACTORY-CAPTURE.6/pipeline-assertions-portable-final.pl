use strict;
use warnings;
use utf8;
use Test::More;
use File::Basename ();
use JSON::PP ();
use MIME::Base64 ();

my $pipeline_proof_dir = File::Basename::dirname(__FILE__);
require "$pipeline_proof_dir/pipeline-probe.pl";
require "$pipeline_proof_dir/pipeline-extra-probe.pl";
my $read_native = sub {
 my ($name) = @_;
 open my $input, '<:raw', "$pipeline_proof_dir/$name" or die $!;
 local $/;
 my $record = JSON::PP->new->decode(<$input>);
 return JSON::PP->new->utf8->decode(MIME::Base64::decode_base64($record->{stdout_base64}))
};
my $native_pipeline_rows = $read_native->('native-before.json');
my $pipeline_rows = LinkedSpec::PipelineCaptureProbe::observations();
is(scalar @$pipeline_rows, 96, 'pipeline complete native context/outcome population');
for my $index (0 .. $#$pipeline_rows) {
 my $row = $pipeline_rows->[$index];
 my $ordinary = $row->{ordinary};
 my $label = join '/', $index, @$ordinary{qw(context supplied outcome fail_at mutate)};
 is_deeply($ordinary, $native_pipeline_rows->[$index]{ordinary},
  "pipeline native values aliases ordering identities and error channels $label");
 is($row->{scopes_released}, 1, "pipeline completed/fatal scope release $label");
 for my $call (@{$row->{private}}) {
  my $role = $call->{role};
  if ($role eq 'arguments') {
   if (!$ordinary->{mutate}) {
    is_deeply($call->{descriptions}, [
     {source => 'cat("λ😀", ,"λ😀")', raw => '"λ😀"', source_span => {start => 4, end => 8}},
     {source => 'cat("λ😀", ,"λ😀")', raw => '"λ😀"', source_span => {start => 11, end => 15}},
    ], "pipeline actual native arguments select authored Unicode occurrences $label");
   }
   next;
  }
  is($call->{source_active}, 1, "pipeline original source active $role $label");
  is($call->{producers_match}, 1, "pipeline producer source scope $role $label");
  is($call->{inputs_match}, 1, "pipeline input source scope $role $label");
  is($call->{actual_callback}, 1, "pipeline actual callback boundary $role $label");
 }
 my @completed_apply = grep { $_->{role} eq 'apply' } @{$row->{captures}};
 my $apply_completed = grep { $_->[0] eq 'apply' } @{$ordinary->{trace}};
 $apply_completed = 0 if $ordinary->{fail_at} eq 'apply';
 my $publishes = $apply_completed && !$ordinary->{supplied} && !$ordinary->{mutate}
  && $ordinary->{outcome} !~ /\A(?:undefined|empty|same|zero|reference)\z/;
 is_deeply(@completed_apply ? $completed_apply[0]{packet} : undef, $publishes ? {
  text => 'LOWERED', fragments => [{kind => 'generated', output_span => {start => 0, end => 7}}],
  consumed => [],
 } : undef, "pipeline actual registered factory output versus opaque supplied apply $label");
 my @expected_completed = map { $_->[0] } @{$ordinary->{trace}};
 pop @expected_completed if length($ordinary->{fail_at});
 is_deeply([map { $_->{role} } @{$row->{captures}}], \@expected_completed,
  "pipeline retains every actual completed scalar capture $label");
}
my $native_extra_rows = $read_native->('native-prove-context-before.json');
# Raw historical errors remain immutable. Project only their one known owned
# module filename into the actual current load context; actual errors, source
# membership and original native line numbers must still compare exactly.
require Cwd;
require File::Spec;
my $loaded_pipeline = $INC{'LinkedSpec/ActionIR/RewritePipeline.pm'};
my $owned_pipeline = "$pipeline_proof_dir/../../../perl/LinkedSpec/ActionIR/RewritePipeline.pm";
is(Cwd::abs_path($loaded_pipeline), Cwd::abs_path($owned_pipeline),
 'native diagnostic module is the actual current owned source');
open my $context_input, '<:raw', "$pipeline_proof_dir/native-prove-context-before.json" or die $!;
my $context_record;
{ local $/; $context_record = JSON::PP->new->decode(<$context_input>) }
close $context_input or die $!;
my $historical_pipeline = substr($context_record->{command}[1], 2).'/LinkedSpec/ActionIR/RewritePipeline.pm';
for my $case (@$native_extra_rows) {
 next unless defined $case->{error};
 my $count = $case->{error} =~ s/\Q$historical_pipeline\E/$loaded_pipeline/g;
 is($count, 1, "native expected filename projects exactly once $case->{kind}");
}
my $extra_rows = LinkedSpec::PipelineExtraProbe::observations();
is_deeply($extra_rows, $native_extra_rows,
 'pipeline native tied lookup non-CODE dispatch exact diagnostics and immediate callback release');
ok(!defined($LinkedSpec::ActionIR::SourceEmissions::_producers), 'pipeline producer scope restores outside invocation');
ok(!defined($LinkedSpec::ActionIR::SourceEmissions::_inputs), 'pipeline input scope restores outside invocation');
ok(!defined($LinkedSpec::ActionIR::SourceEmissions::_call), 'pipeline callback scope restores outside invocation');
ok(!defined(LinkedSpec::ActionIR::SourceOrigins::_invocation_token()), 'pipeline original source scope restores outside invocation');
1;
