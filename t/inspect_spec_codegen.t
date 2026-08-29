#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use File::Spec;
use FindBin qw($Bin);
use IPC::Open3;
use Symbol qw(gensym);

my $repo_root = File::Spec->rel2abs(File::Spec->catdir($Bin, '..'));
my $tool = File::Spec->catfile($repo_root, 'tools', 'inspect_spec_codegen.pl');

sub _slurp {
 my ($path) = @_;
 open my $fh, '<', $path or die "cannot read '$path': $!";
 local $/;
 my $content = <$fh>;
 close $fh;
 return defined($content) ? $content : ''
}

sub _run_inspector {
 my (@snippets) = @_;
 my @args = map { ('--snippet', $_) } @snippets;
 my $stderr = gensym;
 my $pid = open3(
  undef,
  my $stdout,
  $stderr,
  $^X,
  $tool,
  '--label',
  'Top',
  @args,
 );
 local $/;
 my $out = <$stdout>;
 my $err = <$stderr>;
 waitpid($pid, 0);
 return ($? >> 8, defined($out) ? $out : '', defined($err) ? $err : '')
}

subtest 'inspector calls the current explicit owner packages' => sub {
 my $source = _slurp($tool);

 like(
  $source,
  qr/^use LinkedSpec::BootstrapSpec::Core \(\);$/m,
  'bootstrap grammar owner is loaded explicitly',
 );
 like(
  $source,
  qr/^use LinkedSpec::RuleIR::EmitContext \(\);$/m,
  'ActionIR emit-context owner is loaded explicitly',
 );
 is(
  scalar(() = $source =~ /LinkedSpec::BootstrapSpec::Core::_render_method_call_chain\(/g),
  2,
  'both fluent-chain routes call the bootstrap owner directly',
 );
 is(
  scalar(() = $source =~ /LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics\(/g),
  1,
  'the lowering route calls the emit-context owner directly',
 );
 unlike(
  $source,
  qr/LinkedSpec::_(?:render_method_call_chain|rewrite_action_code_with_diagnostics)\(/,
  'the thin facade cannot silently regain inspector ownership',
 );
};

my @snippets = (
 'return(copy(items))',
 'I { x = 1; return(x) }',
 'I.lowercase_each(parts).filter_match(uniq(uppercase_each(parts)), /^[A-Z_]+$/)',
 '/a/ -> Top .lowercase_each(parts).filter_match(uniq(uppercase_each(parts)), /^[A-Z_]+$/)',
 '/a/ -> Top { return(retv) }',
);
my ($status, $stdout, $stderr) = _run_inspector(@snippets);

subtest 'all documented snippet forms execute without plugin dispatch' => sub {
 is($status, 0, 'the multi-form inspector invocation exits successfully');
 is($stderr, '', 'the successful inspection emits no stderr');
 unlike($stdout, qr/Unknown plugin|STATUS: parse_error/, 'no facade AUTOLOAD or snippet parse failure appears');

 my @cases = $stdout =~ /(=== CASE \d+ ===\n.*?)(?=^=== CASE \d+ ===\n|\z)/msg;
 is(scalar(@cases), 5, 'the four documented categories produce all five block/chain cases');

 like($cases[0], qr/^KIND: raw_expr$/m, 'raw helper input is classified');
 like($cases[0], qr/^GENERATED_PERL:\nreturn do \{/m, 'raw helper input prints generated Perl');
 like($cases[0], qr/^CANONICAL_IR_NODES: RETURN$/m, 'raw helper input prints canonical IR');

 like($cases[1], qr/^KIND: lifecycle_block$/m, 'lifecycle block input is classified');
 like($cases[1], qr/^GENERATED_PERL:\n\$x = 1; return \$x$/m, 'lifecycle block prints generated Perl');
 like($cases[1], qr/^CANONICAL_IR_NODES: ASSIGN, RETURN$/m, 'lifecycle block prints canonical IR');

 like($cases[2], qr/^KIND: lifecycle_chain$/m, 'lifecycle chain input is classified');
 like($cases[2], qr/^NORMALIZED_HELPER_CODE:\nlowercase_each\(Top,parts\); filter_match\(Top,/m,
  'lifecycle chain prints owner-rendered helper code');
 like($cases[2], qr/^CANONICAL_IR_NODES: FILTER_MATCH, MAP_LOWERCASE, MAP_UPPERCASE, UNIQ, VALUE_DROP$/m,
  'lifecycle chain prints canonical IR');

 like($cases[3], qr/^KIND: edge_chain$/m, 'action-edge chain input is classified');
 like($cases[3], qr/^NORMALIZED_HELPER_CODE:\nlowercase_each\(Top,parts\); filter_match\(Top,/m,
  'action-edge chain prints owner-rendered helper code');
 like($cases[3], qr/^CANONICAL_IR_NODES: FILTER_MATCH, MAP_LOWERCASE, MAP_UPPERCASE, UNIQ, VALUE_DROP$/m,
  'action-edge chain prints canonical IR');

 like($cases[4], qr/^KIND: edge_block$/m, 'action-edge block input is classified');
 like($cases[4], qr/^GENERATED_PERL:\nreturn \$retv$/m, 'action-edge block prints generated Perl');
 like($cases[4], qr/^CANONICAL_IR_NODES: RETURN$/m, 'action-edge block prints canonical IR');

 for my $index (0 .. $#cases) {
  like($cases[$index], qr/^RAW_PERL_FALLBACK_COUNT: 0$/m, 'case '.($index + 1).' has no raw fallback');
  like($cases[$index], qr/^UNRESOLVED_HELPER_COUNT: 0$/m, 'case '.($index + 1).' has no unresolved helper');
 }
};

done_testing();
