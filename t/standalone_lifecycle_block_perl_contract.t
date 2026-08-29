use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec ();
use JSON::PP ();
use Test::More;

use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::BootstrapSpec ();
use LinkedSpec::Validation ();

sub slurp {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "Could not read '$path': $!";
 local $/;
 return <$fh>
}

sub bootstrap_top {
 my ($source, $label) = @_;
 my ($ok, $parsed, $error) = LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$source);
 ok($ok, "$label bootstrap parses") or diag($error // 'bootstrap parse failed without detail');
 return unless $ok;
 my ($top) = grep {
  ref($_) eq 'ARRAY'
   && ref($_->[0]) eq 'ARRAY'
   && ($_->[0][1] // '') eq 'Top'
 } @$parsed;
 ok($top, "$label retains Top bootstrap entry");
 return $top
}

sub semantic_bootstrap_projection {
 my ($top) = @_;
 return [map {
  ref($_) eq 'ARRAY' ? [@$_[0, 1]] : $_
 } @$top]
}

sub lifecycle_entries {
 my ($top) = @_;
 return grep { ref($_) eq 'ARRAY' && ($_->[0] // '') eq 'ICODE' } @$top
}

sub compile_live {
 my ($source, $label) = @_;
 my %runtime_ctx;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%runtime_ctx);
 ok(ref($parser) eq 'CODE', "$label compiles live")
  or diag(JSON::PP->new->canonical(1)->encode($runtime_ctx{last_error} // {}));
 return $parser
}

my $contract_path = File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'standalone_lifecycle_block_contract.json',
);
my $json = JSON::PP->new->canonical(1)->allow_nonref(1);
my $contract = $json->decode(slurp($contract_path));

is(
 $contract->{contract_id},
 'linkedspec-standalone-lifecycle-block-v1',
 'loads the adopted standalone lifecycle block contract',
);

subtest 'placement twins normalize directly to the same I entry' => sub {
 for my $case (@{$contract->{placement_twins}}) {
  ok(
   LinkedSpec::Validation::validate_dsl_syntax(\$case->{explicit}, {}),
   "$case->{id} explicit source validates",
  );
  ok(
   LinkedSpec::Validation::validate_dsl_syntax(\$case->{shorthand}, {}),
   "$case->{id} shorthand source validates",
  );

  my $explicit = bootstrap_top($case->{explicit}, "$case->{id} explicit");
  my $shorthand = bootstrap_top($case->{shorthand}, "$case->{id} shorthand");
  next unless $explicit && $shorthand;

  is_deeply(
   semantic_bootstrap_projection($shorthand),
   semantic_bootstrap_projection($explicit),
   "$case->{id} preserves exact body position and semantic bootstrap shape",
  );

  my @explicit_i = lifecycle_entries($explicit);
  my @shorthand_i = lifecycle_entries($shorthand);
  is(scalar(@explicit_i), 1, "$case->{id} explicit source has one I entry");
  is(scalar(@shorthand_i), 1, "$case->{id} shorthand has one I entry");
  next unless @explicit_i == 1 && @shorthand_i == 1;

  is($shorthand_i[0][1], $case->{interior}, "$case->{id} preserves the explicit-twin interior");
  is($explicit_i[0][2]{marker}, 'I', "$case->{id} explicit metadata retains marker I");
  is($shorthand_i[0][2]{marker}, 'I', "$case->{id} shorthand metadata normalizes to marker I");
  is($explicit_i[0][2]{source_form}, 'explicit', "$case->{id} retains explicit provenance");
  is($shorthand_i[0][2]{source_form}, 'bare', "$case->{id} retains shorthand provenance");
  is($explicit_i[0][2]{line}, $case->{opening_line}, "$case->{id} explicit opening line is exact");
  is($shorthand_i[0][2]{line}, $case->{opening_line}, "$case->{id} shorthand opening line is exact");
  is(
   $explicit_i[0][2]{source},
   'I {' . $case->{interior} . '}',
   "$case->{id} explicit block source starts at its marker",
  );
  is(
   $shorthand_i[0][2]{source},
   '{' . $case->{interior} . '}',
   "$case->{id} shorthand block source starts at its brace",
  );

  is_deeply(
   LinkedSpec::ActionIR::AST::parse_action_block($shorthand_i[0][1]),
   LinkedSpec::ActionIR::AST::parse_action_block($explicit_i[0][1]),
   "$case->{id} preserves the explicit twin's ActionIR and interior spans",
  );
 }
};

subtest 'multiline provenance, nested braces, and quoted braces remain exact' => sub {
 my $fixture = $contract->{provenance_twin};
 my $explicit = bootstrap_top($fixture->{explicit}, 'multiline explicit');
 my $shorthand = bootstrap_top($fixture->{shorthand}, 'multiline shorthand');
 my ($explicit_i) = lifecycle_entries($explicit);
 my ($shorthand_i) = lifecycle_entries($shorthand);

 is($explicit_i->[2]{source}, $fixture->{explicit_block_source}, 'explicit multiline source is exact');
 is($shorthand_i->[2]{source}, $fixture->{shorthand_block_source}, 'shorthand multiline source is exact');
 is($explicit_i->[2]{line}, $fixture->{opening_line}, 'explicit multiline opening line is exact');
 is($shorthand_i->[2]{line}, $fixture->{opening_line}, 'shorthand multiline opening line is exact');
 is($shorthand_i->[1], $explicit_i->[1], 'nested and quoted brace interior matches explicit twin');
 is_deeply(
  LinkedSpec::ActionIR::AST::parse_action_block($shorthand_i->[1]),
  LinkedSpec::ActionIR::AST::parse_action_block($explicit_i->[1]),
  'multiline shorthand and explicit twin have identical ActionIR spans',
 );
};

subtest 'explicit and shorthand duplicates execute in authored order' => sub {
 for my $case (@{$contract->{duplicate_cases}}) {
  my $parser = compile_live($case->{source}, $case->{id});
  next unless $parser;
  my $input = $contract->{duplicate_input};
  is(
   $parser->(\$input),
   $contract->{duplicate_expected},
   "$case->{id} returns the authored two-block result",
  );

  my $top = bootstrap_top($case->{source}, "$case->{id} order");
  my @i = lifecycle_entries($top);
  is(scalar(@i), 2, "$case->{id} retains two lifecycle entries");
  is_deeply(
   [map { $_->[1] } @i],
   [' set(out, "first") ', ' return(cat(out, "-second")) '],
   "$case->{id} retains authored block order",
  );
 }
};

subtest 'earlier brace owners do not broaden into lifecycle shorthand' => sub {
 my %expected_bootstrap_type = (
  action_edge_block => 'ACODE',
  blind_edge_block => 'BCODE',
  bare_edge_block => 'BARE_EDGE',
  callable_block => 'ACODE',
  nested_lifecycle_block => 'ICODE',
 );

 for my $case (@{$contract->{ownership_cases}}) {
  my $parser = compile_live($case->{source}, $case->{id});
  next if $case->{id} eq 'function_body';
  my $top = bootstrap_top($case->{source}, "$case->{id} ownership");
  next unless $top;
  my @i = lifecycle_entries($top);
  my $expected_i = $case->{id} eq 'nested_lifecycle_block' ? 1 : 0;
  is(scalar(@i), $expected_i, "$case->{id} has no accidental standalone lifecycle entry");
  ok(
   grep({ ref($_) eq 'ARRAY' && ($_->[0] // '') eq $expected_bootstrap_type{$case->{id}} } @$top),
   "$case->{id} retains its earlier bootstrap owner",
  );
 }
};

subtest 'malformed shorthand and explicit twins fail at the same boundary' => sub {
 for my $case (@{$contract->{malformed_twins}}) {
  my @errors;
  for my $form (qw(explicit shorthand)) {
   my $source = $case->{$form};
   my %runtime_ctx;
   my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1, runtime_ctx_ref => \%runtime_ctx);
   ok(!defined($descriptor), "$case->{id} $form rejects");
   my $error = $runtime_ctx{last_error} // {};
   is($error->{summary}, $case->{perl_summary}, "$case->{id} $form reports the expected summary");
   is($error->{stage}, 'validate_dsl_syntax', "$case->{id} $form rejects during DSL validation");
   is($error->{rule_label}, 'Top', "$case->{id} $form identifies the owning rule");
   like($error->{detail} // '', qr/line 2:/i, "$case->{id} $form reports the opening line");
   push @errors, $error;
  }
  is($errors[1]{summary}, $errors[0]{summary}, "$case->{id} twin summaries match");
  is($errors[1]{stage}, $errors[0]{stage}, "$case->{id} twin stages match");
  is($errors[1]{rule_label}, $errors[0]{rule_label}, "$case->{id} twin fields match");
 }
};

subtest 'mixed fixture survives standalone generated Perl source' => sub {
 my ($case) = grep { $_->{id} eq $contract->{generated_fixture_case} } @{$contract->{duplicate_cases}};
 ok($case, 'generated fixture case resolves from the neutral contract');
 return unless $case;

 my $source = LinkedSpec::emit_generated_source(
  \$case->{source},
  source_identity => 'standalone-lifecycle-block.spec',
 );
 ok(defined($source) && length($source), 'mixed fixture emits standalone Perl source');
 my $package = 'LinkedSpec::StandaloneLifecycleBlockGenerated';
 my $loaded = eval "package $package; $source; 1";
 ok($loaded, 'standalone generated Perl source loads') or diag($@);
 return unless $loaded;

 no strict 'refs';
 my $input = $contract->{duplicate_input};
 my $result = &{"${package}::Execute"}(\$input);
 is($result, $contract->{duplicate_expected}, 'standalone generated Perl preserves mixed authored order');
};

done_testing();
