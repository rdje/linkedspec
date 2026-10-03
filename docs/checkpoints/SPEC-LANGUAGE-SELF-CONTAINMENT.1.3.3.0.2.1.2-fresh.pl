use strict;
use warnings;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);

my $json = JSON::PP->new->canonical;
my $request = $json->decode(do { local $/; <STDIN> });
my $loaded = eval "package BridgeReconciliation::Fresh; $request->{emitted}\n1;";
die "fresh source failed to load: $@" unless $loaded;
my ($value, $error, $stdout, $stderr);
$stdout = $stderr = '';
{
    open my $out, '>', \$stdout or die $!;
    open my $err, '>', \$stderr or die $!;
    local *STDOUT = $out;
    local *STDERR = $err;
    my $input = $request->{input};
    my $ok = eval { $value = BridgeReconciliation::Fresh::Execute(\$input); 1 };
    $error = "$@" unless $ok;
}
print $json->encode({value => $value, error => $error, output => $stdout,
    stderr => $stderr, emitted_sha256 => sha256_hex($request->{emitted})}), "\n";
