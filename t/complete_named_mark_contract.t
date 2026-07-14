use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec ();
use JSON::PP ();
use Test::More;

use LinkedSpec ();

sub slurp {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "Could not read '$path': $!";
 local $/;
 return <$fh>
}

my $contract_path = File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'complete_named_mark_contract.json',
);
my $json = JSON::PP->new->canonical(1)->allow_nonref(1);
my $contract = $json->decode(slurp($contract_path));

is(
 $contract->{contract_id},
 'linkedspec-complete-named-mark-v1',
 'loads the adopted complete named-mark contract',
);

subtest 'all seven helpers lower canonically with symbolic bare names' => sub {
 for my $helper (@{$contract->{helpers}}) {
  my $name = $helper->{name};
  my $lowered = LinkedSpec::call_spec_handler_subst('Child', "$name(probe)");
  unlike($lowered, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER/, "$name is a supported Perl helper");
  like($lowered, qr/\Q'Child'\E/, "$name is scoped to the current rule label");
  like($lowered, qr/\Q'probe'\E/, "$name preserves the bare mark name symbolically");
 }
};

subtest 'neutral fixture executes live and from standalone generated source' => sub {
 my $fixture = $contract->{fixture};
 my %ctx;
 my $parser = LinkedSpec::Get(\$fixture->{spec_source}, runtime_ctx_ref => \%ctx);
 ok(ref($parser) eq 'CODE', 'complete named-mark fixture compiles');
 my $input = $fixture->{input};
 my $result = $parser->(\$input);
 is_deeply($result, $fixture->{expected}, 'live Perl matches the exact Unicode and rule-local fixture');
 ok(!exists($ctx{last_error}), 'live fixture leaves structured runtime error clear');

 my $source = LinkedSpec::emit_generated_source(
  \$fixture->{spec_source},
  source_identity => 'complete-named-mark.spec',
 );
 ok(defined($source) && length($source), 'fixture emits standalone Perl source');
 unlike($source, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER/, 'generated source has no unsupported-helper residue');

 my $package = 'LinkedSpec::CompleteNamedMarkGenerated';
 my $loaded = eval "package $package; $source; 1";
 ok($loaded, 'standalone generated source loads') or diag($@);
 if ($loaded) {
  no strict 'refs';
  $input = $fixture->{input};
  my $generated_result;
  my $execute_ok = eval {
   $generated_result = &{"${package}::Execute"}(\$input);
   1;
  };
  ok($execute_ok, 'standalone generated execution completes') or diag($@);
  is_deeply($generated_result, $fixture->{expected}, 'standalone generated execution matches the fixture')
   if $execute_ok;
 }
};

done_testing();
