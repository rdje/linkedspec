#!/usr/bin/env perl
# Fixed .86.5 context diagnosis; run through tools/project_data_run.sh.
use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::Validation ();
use LinkedSpec::ActionIR::MethodExpr ();
use JSON::PP ();
my $json = JSON::PP->new->canonical;

for my $case (
 ['bare',' I { out = /(14,2) }'],
 ['spaced',' I { out = /(14,2)   }'],
 ['semicolon',' I { out = /(14,2); }'],
 ['named',' I { out = div(14,2) }'],
 ['parenthesized',' I { out = (/(14,2)) }'],
 ['parenthesized_named',' I { out = (div(14,2)) }'],
 ['receiver',' I { out = /(14,2).floor() }'],
 ['next_member',' I { out = /(14,2) } /x/ E { return(out) }',1],
 ['next_named_slot',' I { out = /(14,2) } slot=/x/ E { return(out) }',1],
 ['nested_callable',' I { f = {|| return(/(14,2)) }; out = f() }'],
 ['nested_named_callable',' I { f = {|| return(div(14,2)) }; out = f() }'],
 ['complete_brace_pattern',' I { rx = /(x)}/; out = 7 }'],
 ['escaped_brace_pattern',' I { rx = /(x)\}/; out = 7 }'],
 ['helper_brace_pattern',' I { out = matches("x}", /(x)}/) }'],
 ['slash_in_quote',' I { out = /(14,2) } E { return("/") }',1],
) {
 my ($id, $fragment, $complete) = @$case;
 my $source = "Top::\n$fragment\n" . ($complete ? '' : " /x/ E { return(out) }\n");
 my %context;
 my $parser = eval { LinkedSpec::Get(\$source, runtime_ctx_ref => \%context) };
 my $build_error = "$@";
 my $input = 'x';
 my $value = $parser ? eval { $parser->(\$input) } : undef;
 my $runtime_error = "$@";
 # Preserve the public error payload while making a blessed detail JSON-safe.
 if (ref($context{last_error}) eq 'HASH' && ref($context{last_error}{detail})) {
  $context{last_error}{detail} = "$context{last_error}{detail}";
 }
 my $slash = index($fragment, '/');
 print $json->encode({
  id => $id,
  source => $source,
  value => $value,
  parser_ready => $parser ? 1 : 0,
  build_error => $build_error,
  runtime_error => $runtime_error,
  last_error => $context{last_error},
  fragment => $fragment,
  slash => $slash,
  fragment_length => length($fragment),
  slash_call => $slash < 0 ? undef
   : LinkedSpec::ActionIR::MethodExpr::_looks_like_slash_symbol_call_at($fragment, $slash),
  # This deliberately measures the shared context-free lexical result.
  # The structural scans below supply their own depth after the .86.5.1 repair.
  slash_end => $slash < 0 ? undef
   : LinkedSpec::Validation::_consume_slash_construct($fragment, $slash),
  edge_scan => LinkedSpec::Validation::_scan_rule_edges_in_fragment($fragment),
  lifecycle_close => LinkedSpec::Validation::_lifecycle_block_close_offset($fragment, 0),
  validation_view => LinkedSpec::Validation::_helper_pattern_validation_view($source),
 }), "\n";
}
