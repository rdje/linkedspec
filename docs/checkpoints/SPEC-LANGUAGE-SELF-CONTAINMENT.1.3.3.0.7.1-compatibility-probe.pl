use strict;
use warnings;
BEGIN {
 if ($ENV{LINKEDSPEC_COMPAT_ORIGINAL}) {
  require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-span-Parser.pm'; $INC{'LinkedSpec/ActionIR/AST/Parser.pm'} = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-span-Parser.pm';
  require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-span-RuleIR.pm'; $INC{'LinkedSpec/RuleIR.pm'} = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-span-RuleIR.pm';
  require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-EmitContext.pm'; $INC{'LinkedSpec/RuleIR/EmitContext.pm'} = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-EmitContext.pm';
  require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-Diagnostics.pm'; $INC{'LinkedSpec/ActionIR/Diagnostics.pm'} = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-Diagnostics.pm';
 }
 if ($ENV{LINKEDSPEC_COMPAT_BEFORE}) {
  require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-compat-RawDependencies.pm'; $INC{'LinkedSpec/ActionIR/RawDependencies.pm'} = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-compat-RawDependencies.pm';
 }
}

use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::RuleIR::EmitContext ();
use JSON::PP ();
use Scalar::Util qw(reftype blessed);

my $json = JSON::PP->new->canonical->pretty->utf8;
my $request = $json->decode(do { local $/; <STDIN> });
my $warmup = 'Top:: I { return("warmup") }';
LinkedSpec::Get(\$warmup, return_descriptor => 1);
my $original = \&LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics;
my (@units, $descriptor, $failure, $stdout, $stderr, %context);
$stdout = $stderr = '';
sub project {
    my ($value) = @_;
    return [map { project($_) } @$value] if (reftype($value) // '') eq 'ARRAY';
    return {map(($_ => project($value->{$_})), keys %$value)}
        if (reftype($value) // '') eq 'HASH';
    return "$value" if ref($value);
    return $value;
}
{
    open my $out, '>', \$stdout or die $!;
    open my $err, '>', \$stderr or die $!;
    local *STDOUT = $out;
    local *STDERR = $err;
    no warnings 'redefine';
    local *LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics = sub {
        my ($label, $source) = @_;
        my ($ast, $ast_error);
        {
            local $@;
            my $ok = eval { $ast = LinkedSpec::ActionIR::AST::parse_action_block($source); 1 };
            $ast_error = "$@" unless $ok;
        }
        my @result = $original->(@_);
        push @units, {label => $label, source => $source, ast => project($ast),
            ast_error => $ast_error, rewritten => $result[0], diagnostics => project($result[1])};
        return @result;
    };
    my $ok = eval {
        $descriptor = LinkedSpec::Get(\$request->{source}, return_descriptor => 1, runtime_ctx_ref => \%context);
        1;
    };
    $failure = "$@" unless $ok;
}
my %metadata;
if (ref($descriptor) eq 'HASH') {
    for my $label (sort keys %{$descriptor->{spec} || {}}) {
        $metadata{$label} = project($descriptor->{spec}{$label}{meta}{action_rewriter});
    }
}
print $json->encode({id => $request->{id}, source => $request->{source},
    path => $request->{path}, units => \@units, metadata => \%metadata,
    descriptor_kind => ref($descriptor) || q{}, context_error => project($context{last_error}),
    input_route => q{Get_source_ref},
    functions => project($descriptor ? $descriptor->{functions} : undef),
    exception => $failure, stdout => $stdout, stderr => $stderr,
    limits => 'Get exact decoded source-reference descriptor only; original-source observation wrapper calls the unchanged compiler; no named-resolution, execution or admitted new syntax.'});
