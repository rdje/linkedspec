use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec ();
use JSON::PP ();
use Test::More;

use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();

sub slurp {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "Could not read '$path': $!";
 local $/;
 return <$fh>
}

sub semantic_ast {
 my ($value) = @_;
 return [map { semantic_ast($_) } @$value] if ref($value) eq 'ARRAY';
 if (ref($value) eq 'HASH') {
  return {
   map { $_ => semantic_ast($value->{$_}) }
   grep { $_ ne 'source' && $_ ne 'source_span' && $_ ne 'body_source' && $_ ne 'body_source_span' }
   sort keys %$value
  }
 }
 return $value
}

sub parse_statement_expr {
 my ($source) = @_;
 my $block = LinkedSpec::ActionIR::AST::parse_action_block($source);
 return $block->{statements}[0]{expr}
}

my $contract_path = File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'punctuation_light_zero_arg_contract.json',
);
my $json = JSON::PP->new->canonical(1)->allow_nonref(1);
my $contract = $json->decode(slurp($contract_path));

is(
 $contract->{contract_id},
 'linkedspec-punctuation-light-zero-arg-v1',
 'loads the adopted punctuation-light zero-argument contract',
);

subtest 'standalone aliases share typed statement ASTs' => sub {
 for my $case (@{$contract->{standalone_cases}}) {
  my $bare = semantic_ast(parse_statement_expr($case->{bare}));
  my $parenthesized = semantic_ast(parse_statement_expr($case->{parenthesized}));
  is_deeply($bare, $parenthesized, "$case->{id} bare and parenthesized statements share one AST");
  is($bare->{kind}, $case->{expected_ast}{kind}, "$case->{id} keeps the neutral node kind");
  is_deeply($bare->{args}, [], "$case->{id} supplies zero authored arguments");
 }

 my $value_next = LinkedSpec::ActionIR::AST::parse_action_expr('next');
 is($value_next->{kind}, 'variable', 'bare next outside a standalone statement remains a value read');
};

subtest 'terminal receiver aliases share typed fluent ASTs' => sub {
 for my $case (@{$contract->{receiver_cases}}) {
  my $bare = LinkedSpec::ActionIR::AST::parse_action_expr($case->{bare});
  my $parenthesized = LinkedSpec::ActionIR::AST::parse_action_expr($case->{parenthesized});
  is($bare->{kind}, 'fluent_chain', "$case->{id} bare terminal parses as a fluent chain");
  is_deeply(
   semantic_ast($bare),
   semantic_ast($parenthesized),
   "$case->{id} bare and parenthesized chains share one semantic AST",
  );
 }
};

subtest 'ordinary identifiers and excluded syntax do not broaden' => sub {
 for my $case (@{$contract->{retained_noncall_cases}}) {
  my $node = semantic_ast(LinkedSpec::ActionIR::AST::parse_action_expr($case->{source}));
  is_deeply($node, $case->{expected_ast}, "$case->{id} remains an ordinary value read");
 }

 my %expected_reason = (
  if_condition_without_call => 'unsupported_expression',
  while_condition_without_call => 'unsupported_expression',
  ordinary_helper_without_call => 'unsupported_expression',
  argument_call_without_parentheses => 'unsupported_expression',
  intermediate_generic_receiver => 'invalid_fluent_chain',
  receiver_trailing_block_without_call => 'invalid_fluent_chain',
 );
 for my $case (@{$contract->{invalid_syntax_cases}}) {
  my $node = LinkedSpec::ActionIR::AST::parse_action_expr($case->{source});
  is($node->{kind}, 'raw_perl', "$case->{id} remains outside typed ActionIR syntax");
  is($node->{reason}, $expected_reason{$case->{id}}, "$case->{id} keeps its existing parser reason");
 }
};

subtest 'zero-argument method resolution delegates unchanged' => sub {
 for my $case (@{$contract->{method_contract_cases}}) {
  my $bare = LinkedSpec::call_spec_handler_subst('Top', 'return('.$case->{bare}.')');
  my $parenthesized = LinkedSpec::call_spec_handler_subst('Top', 'return('.$case->{parenthesized}.')');
  is($bare, $parenthesized, "$case->{id} bare and parenthesized forms lower identically");
  if ($case->{expected_resolution} eq 'accepted') {
   unlike($bare, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER/, "$case->{id} is accepted by the existing contract");
  } else {
   like($bare, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER/, "$case->{id} keeps the existing zero-argument rejection");
  }
 }
};

subtest 'bare next is canonical rather than compatibility syntax' => sub {
 my $spec = <<'SPEC';
Top::&
 /a/ -> Top { next }
SPEC
 my $descriptor = LinkedSpec::Get(\$spec, return_descriptor => 1);
 ok(ref($descriptor) eq 'HASH', 'bare-next descriptor builds');
 my $meta = $descriptor->{spec}{Top}{meta}{action_rewriter};
 is($meta->{canonical_action_ir_fallback_count}, 0, 'bare next avoids canonical fallback');
 is($meta->{raw_perl_dependency_count}, 0, 'bare next avoids raw Perl dependency');
 is($meta->{unresolved_helper_count}, 0, 'bare next avoids unresolved-helper hits');
 is($meta->{compatibility_surface_count}, 0, 'bare next is no longer a compatibility surface');
 is_deeply($meta->{compatibility_surface_contract_ids}, [], 'bare next has no compatibility contract id');
 ok((grep { $_ eq 'NEXT' } @{$meta->{canonical_action_ir_nodes}}), 'bare next contributes canonical NEXT');
 is(
  LinkedSpec::call_spec_handler_subst('Top', 'next'),
  LinkedSpec::call_spec_handler_subst('Top', 'next()'),
  'bare and parenthesized next lower identically',
 );
};

subtest 'neutral future fixture executes live and from standalone generated source' => sub {
 my $fixture = $contract->{future_fixture};
 my %ctx;
 my $parser = LinkedSpec::Get(\$fixture->{spec_source}, runtime_ctx_ref => \%ctx);
 ok(ref($parser) eq 'CODE', 'punctuation-light future fixture compiles');
 my $input = $fixture->{input};
 my $result = $parser->(\$input);
 is_deeply($result, $fixture->{expected}, 'live Perl matches the exact neutral fixture');
 ok(!exists($ctx{last_error}), 'live fixture leaves structured runtime error clear');

 my $source = LinkedSpec::emit_generated_source(
  \$fixture->{spec_source},
  source_identity => 'punctuation-light-zero-arg.spec',
 );
 ok(defined($source) && length($source), 'future fixture emits standalone Perl source');
 unlike($source, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER/, 'generated source has no unsupported-helper residue');
 unlike($source, qr/\b(?:label|values)\.(?:trim|count)\b/, 'generated source has no bare receiver syntax residue');

 my $package = 'LinkedSpec::PunctuationLightZeroArgGenerated';
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
