use strict;
use warnings;
use LinkedSpec ();
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use IPC::Open2 qw(open2);

my $json = JSON::PP->new->canonical;
my $checkpoint = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.1-verification.json';
open my $fh, '<', $checkpoint or die $!;
my $historical = $json->decode(do { local $/; <$fh> });
close $fh or die $!;
my @rows;
for my $case (@{$historical->{original_controls}}) {
    my ($source, $input) = @{$case}{qw(source input)};
    my (%ctx, $dump, $value, $error, $stdout, $stderr);
    $stdout = $stderr = '';
    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx,
        dump_parser_source => 1, parser_source_ref => \$dump);
    my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
    {
        open my $out, '>', \$stdout or die $!;
        open my $err, '>', \$stderr or die $!;
        local *STDOUT = $out;
        local *STDERR = $err;
        my $ok = eval { $value = $parser->(\$input); 1 };
        $error = "$@" unless $ok;
    }
    die 'suppressed control error' if defined $ctx{last_error};
    my $emitted = LinkedSpec::emit_generated_source(\$source,
        source_identity => "$case->{id}.spec");
    my $pid = open2(my $child_out, my $child_in, $^X, '-Iperl',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.2-fresh.pl');
    print {$child_in} $json->encode({emitted => $emitted, input => $case->{input}});
    close $child_in or die $!;
    my $reply = do { local $/; <$child_out> };
    close $child_out or die $!;
    waitpid($pid, 0);
    die 'fresh control child failed' if $?;
    my $metadata = $descriptor->{spec}{Top}{meta}{action_rewriter};
    push @rows, {id => $case->{id}, source_sha256 => sha256_hex($source),
        dumped_sha256 => sha256_hex($dump), dumped_bytes => length($dump),
        emitted_sha256 => sha256_hex($emitted),
        metadata => {map {($_ => $metadata->{$_})} qw(language_agnostic_action_ir_ready
            canonical_action_ir_fallback_count raw_perl_dependency_count unresolved_helper_count)},
        native => {value => $value, error => $error, output => $stdout, stderr => $stderr},
        fresh => $json->decode($reply)};
}
print $json->encode(\@rows), "\n";
