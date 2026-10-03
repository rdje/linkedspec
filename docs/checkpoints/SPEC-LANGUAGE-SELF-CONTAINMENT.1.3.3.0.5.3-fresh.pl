BEGIN {
 if (grep { $_ eq '--baseline' } @ARGV) {
  require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3-runtime-before.pm';
  $INC{'LinkedSpec/CodeblockRuntime.pm'} = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3-runtime-before.pm';
 }
}
use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(blessed reftype refaddr);
use Digest::SHA qw(sha256_hex);
require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm';

my $json = JSON::PP->new->canonical;
sub project {
    my ($value) = @_;
    return [map { project($_) } @$value] if (reftype($value) // '') eq 'ARRAY';
    return {map(($_ => project($value->{$_})), keys %$value),
        blessed($value) ? (observed_class => blessed($value)) : ()}
        if (reftype($value) // '') eq 'HASH';
    return $value;
}
my $request = $json->decode(do { local $/; <STDIN> });
my ($value, $failure, $stdout, $stderr);
my ($invocations, $actual_error);
$stdout = $stderr = '';
{
    open my $out, '>', \$stdout or die $!;
    open my $err, '>', \$stderr or die $!;
    local *STDOUT = $out;
    local *STDERR = $err;
    my $ok = eval {
        my $loaded = eval "package ValueControl::Fresh; $request->{emitted}\n1;";
        die $@ unless $loaded;
        my $input = '';
        ($invocations, $actual_error) = DeferredControl::Observe::execute(sub {
            my $ok = eval { $value = ValueControl::Fresh::Execute(\$input); 1 };
            $failure = $@ unless $ok;
        });
        1;
    };
    $failure = $@ unless $ok;
}
print $json->encode({value => project($value), exception => project($failure),
    stdout => $stdout, stderr => $stderr,
    invocations => $invocations, actual_error_identity => ref($actual_error) &&
        ref($failure) eq 'HASH' && ref($failure->{detail})
            ? refaddr($actual_error) == refaddr($failure->{detail}) ? 1 : 0 : undef,
    emitted_sha256 => sha256_hex($request->{emitted})}), "\n";
