use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# Preserve these exact existing programs, including their compatibility status.
open my $file, '<', 'tests/numeric-codeblocks/signed-array-selectors.json' or die $!;
my $plan = do { local $/; JSON::PP->new->decode(<$file>) };
close $file;
my $json = JSON::PP->new->canonical;
my $sequence = 0;
for my $case (@{$plan->{cases}}) {
 next unless $case->{id} =~ m{\Acontrol/result_path_};
 subtest $case->{id} => sub {
  my $source = $case->{source};
  my %context;
  my $native = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = $case->{input} // 'x';
  my $actual = eval { $native->(\$input) };
  is("$@", '', 'native invocation has no thrown error');
  is($context{last_error}, undef, 'native invocation has no handler error');
  is($json->encode($actual), $json->encode($case->{expected}), 'native reader and consumer value preserved');
  my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'computed-callable-compat.spec');
  my $package = 'LinkedSpec::ComputedCallableCompat'.++$sequence;
  my $loaded = eval "package $package; $emitted; 1";
  ok($loaded, 'fresh parser compiles') or diag($@);
  if ($loaded) {
   my $input = $case->{input} // 'x';
   no strict 'refs';
   my $value = eval { &{$package.'::Execute'}(\$input) };
   is("$@", '', 'fresh invocation has no thrown error');
   is($json->encode($value), $json->encode($case->{expected}), 'fresh reader and consumer value preserved');
  }
  my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
  my $metadata = $descriptor->{spec}{Top}{meta}{action_rewriter};
  is($metadata->{raw_perl_dependency_count}, 1, 'existing raw marker is preserved');
 };
}
is($sequence, 4, 'all four frozen callable-result controls are selected');
done_testing() unless caller;
1;
