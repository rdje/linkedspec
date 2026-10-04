use strict;
use warnings;
use JSON::PP ();
BEGIN {
 if ($ENV{LINKEDSPEC_SPAN_ORIGINAL}) {
  require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-EmitContext.pm';
  $INC{'LinkedSpec/RuleIR/EmitContext.pm'} = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-EmitContext.pm';
  require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-Diagnostics.pm';
  $INC{'LinkedSpec/ActionIR/Diagnostics.pm'} = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-Diagnostics.pm';
 }
}
use Scalar::Util qw(blessed reftype);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::BootstrapSpec ();
use LinkedSpec::RuleIR ();

my $source = "Top::\n -> MoveTop\n\nMoveTop: /foo/ /bar/ \@mark(body_start)\n";
my ($ok, $parsed, $error) = LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$source);
die $error unless $ok;
my ($entry) = grep { ref($_) eq 'ARRAY' && ref($_->[0]) eq 'ARRAY' && $_->[0][1] eq 'MoveTop' } @$parsed;
my $rule = LinkedSpec::RuleIR::_collect_rule_ir($entry);
my $action = $rule->{code_blocks}{LECODE}[0];
my $ast = LinkedSpec::ActionIR::AST::parse_action_block($action);
my @raw;
my $visit;
$visit = sub {
 my ($x) = @_;
 if (ref($x) eq 'ARRAY') { $visit->($_) for @$x; return }
 return unless ref($x) eq 'HASH';
 if (($x->{kind} // '') eq 'raw_perl') {
  my ($a, $b) = @{$x->{source_span}}{qw(start end)};
  push @raw, {%$x, action_slice => substr($action, $a, $b - $a)};
 }
 $visit->($x->{$_}) for sort keys %$x;
};
$visit->($ast);
undef $visit;
my (%context, $dump);
my $descriptor = eval { LinkedSpec::Get(\$source, return_descriptor=>1, dump_parser_source=>1,
 runtime_ctx_ref=>\%context, parser_source_ref=>\$dump) };
my $exception = "$@";
sub project {
 my ($x)=@_;
 return [map { project($_) } @$x] if (reftype($x)//'') eq 'ARRAY';
 return {map(($_=>project($x->{$_})),keys %$x),blessed($x)?(observed_class=>blessed($x)):()}
  if (reftype($x)//'') eq 'HASH';
 return $x;
}
my %meta = ref($descriptor) eq 'HASH' ? map { $_ => $descriptor->{spec}{$_}{meta}{action_rewriter} } keys %{$descriptor->{spec}} : ();
print JSON::PP->new->canonical(1)->utf8(1)->encode({source=>$source, action=>$action, ast=>$ast,
 raw_nodes=>\@raw, descriptor_kind=>ref($descriptor), exception=>$exception, dump=>$dump,
 context_error=>project($context{last_error}), metadata=>project(\%meta)}), "\n";
