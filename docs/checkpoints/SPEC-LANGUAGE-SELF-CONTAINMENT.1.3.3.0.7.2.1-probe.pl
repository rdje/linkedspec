use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use JSON::PP ();
use Encode qw(encode);
use Scalar::Util qw(blessed reftype refaddr);
use Digest::SHA qw(sha256_hex);
use IPC::Open2 qw(open2);
require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm';

my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-';
my $json = JSON::PP->new->canonical->utf8;
sub digest { return sha256_hex(encode('UTF-8', $_[0])) }
sub project {
    my ($value) = @_;
    return [map { project($_) } @$value] if (reftype($value) // '') eq 'ARRAY';
    return {map(($_ => project($value->{$_})), keys %$value),
        blessed($value) ? (observed_class => blessed($value)) : ()}
        if (reftype($value) // '') eq 'HASH';
    return "$value" if ref($value);
    return $value;
}
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
my $id = shift // die 'case required';
my @selected = grep { $_->{id} eq $id } @$cases;
die 'exactly one case required' unless @selected == 1;
my $case = $selected[0];
my ($source, $action) = @{$case}{qw(source action)};
my (%ctx, $dump, $value, $failure, $stdout, $stderr, $emitted, $descriptor, $ast, $substitution);
my ($invocations, $actual_error);
$stdout = $stderr = '';
{
    open my $out, '>', \$stdout or die $!;
    open my $err, '>', \$stderr or die $!;
    local *STDOUT = $out;
    local *STDERR = $err;
    my $ok = eval {
        $ast = LinkedSpec::ActionIR::AST::parse_action_block($action);
        $substitution = LinkedSpec::call_spec_handler_subst('Top', $action);
        my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx,
            dump_parser_source => 1, parser_source_ref => \$dump);
        $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
        ($invocations, $actual_error) = DeferredControl::Observe::execute(sub {
            my $input = $case->{input} // '';
            my $ran = eval { $value = $parser->(\$input); 1 };
            $failure = $@ unless $ran;
        });
        $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => "$id.spec");
        1;
    };
    $failure = $@ unless $ok;
}
my $fresh;
if (defined $emitted) {
    my $pid = open2(my $child_out, my $child_in, $^X, '-Iperl', $prefix.'fresh.pl');
    binmode $child_in, ':raw';
    binmode $child_out, ':raw';
    print {$child_in} $json->encode({emitted => $emitted, input => $case->{input}});
    close $child_in or die $!;
    my $reply = do { local $/; <$child_out> };
    close $child_out or die $!;
    waitpid($pid, 0);
    die 'fresh observer failed' if $?;
    $fresh = $json->decode($reply);
}
my $meta = $descriptor ? $descriptor->{spec}{Top}{meta}{action_rewriter} : undef;
print $json->pretty->encode({id => $id, source => $source, source_sha256 => digest($source),
    action => $action, ast => project($ast), substitution => $substitution,
    substitution_sha256 => defined($substitution) ? digest($substitution) : undef,
    dump => $dump, emitted => $emitted,
    emitted_sha256 => defined($emitted) ? digest($emitted) : undef,
    seed => $ENV{PERL_HASH_SEED}, perturb => $ENV{PERL_PERTURB_KEYS},
    native => {value => project($value), exception => project($failure),
        context_error => project($ctx{last_error}), stdout => $stdout, stderr => $stderr,
        invocations => $invocations, actual_error_identity => ref($actual_error) &&
            ref($ctx{last_error}{detail}) ? refaddr($actual_error) == refaddr($ctx{last_error}{detail}) ? 1 : 0 : undef},
    fresh => $fresh, metadata => project($meta)});
