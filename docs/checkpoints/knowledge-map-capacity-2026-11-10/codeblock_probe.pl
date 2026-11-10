use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();

open my $fh, '<:raw', 'capability_conformance/callable_codeblock_contract.json' or die $!;
my $contract = JSON::PP->new->decode(do { local $/; <$fh> });
close $fh or die $!;
my $fixture = $contract->{fixture};
my $source = $fixture->{spec_source};
my (%ctx, $dump, $native, $exception);
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx,
    dump_parser_source => 1, parser_source_ref => \$dump);
if ($parser) {
    my $input = $fixture->{input};
    eval { $native = $parser->(\$input); 1 } or $exception = "$@";
}
my $generated = LinkedSpec::emit_generated_source(\$source,
    source_identity => 'callable-codeblock-fixture.spec');
my $loaded = eval "package CanonicalCodeblockProbe; $generated; 1";
my $load_error = "$@";
my ($fresh, $fresh_error);
if ($loaded) {
    my $input = $fixture->{input};
    eval { $fresh = CanonicalCodeblockProbe::Execute(\$input); 1 } or $fresh_error = "$@";
}
my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
my %metadata;
for my $rule (sort keys %{$descriptor->{spec}}) {
    my $rewriter = $descriptor->{spec}{$rule}{meta}{action_rewriter} || {};
    $metadata{$rule} = { map { $_ => $rewriter->{$_} }
        grep { exists $rewriter->{$_} } qw(canonical_action_ir_nodes actionir_ready raw_perl_fallback_count unresolved_action_ir_count) };
}
print JSON::PP->new->canonical->allow_nonref->encode({
    source => $source, input => $fixture->{input}, expected => $fixture->{expected},
    parser_built => $parser ? 1 : 0, native => $native, native_exception => $exception,
    native_error => $ctx{last_error}, generated => $generated, dumped => $dump,
    loaded => $loaded ? 1 : 0, load_error => $load_error,
    fresh => $fresh, fresh_error => $fresh_error, metadata => \%metadata,
}), "\n";
