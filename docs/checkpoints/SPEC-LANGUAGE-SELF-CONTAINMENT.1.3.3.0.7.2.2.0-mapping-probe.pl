use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::RuleIR::EmitContext ();
use JSON::PP ();
use Encode qw(encode);
use Digest::SHA qw(sha256_hex);

my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0-';
my $json = JSON::PP->new->canonical->utf8;
open my $file, '<:raw', $prefix.'mapping-cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
my @rows;
for my $case (@$cases) {
    my $ast = LinkedSpec::ActionIR::AST::parse_action_block($case->{action});
    my ($substitution, $diag) = LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics('Top', $case->{action}, undef);
    my $facade = LinkedSpec::call_spec_handler_subst('Top', $case->{action});
    die 'facade substitution differs' unless $facade eq $substitution;
    push @rows, {id => $case->{id}, source => $case->{source}, action => $case->{action},
        source_sha256 => sha256_hex(encode('UTF-8', $case->{source})), ast => $ast,
        substitution => $substitution, diagnostics => $diag};
}
print $json->pretty->encode({seed => $ENV{PERL_HASH_SEED}, perturb => $ENV{PERL_PERTURB_KEYS}, cases => \@rows});
