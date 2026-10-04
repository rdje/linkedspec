use strict;
use warnings;
use LinkedSpec ();
use JSON::PP ();
use Encode qw(encode);
use Digest::SHA qw(sha256_hex);
use MIME::Base64 qw(encode_base64);
use File::Path qw(make_path);

my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-';
my $json = JSON::PP->new->canonical->utf8;
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
my $id = shift // die 'case required';
my @selected = grep { $_->{id} eq $id } @$cases;
die 'exactly one case required' unless @selected == 1;
my $case = $selected[0];
my $root = '.linkedspec-data/scratch/quoted-source-diagnosis';
make_path($root);
my $log = "$root/$id-$ENV{PERL_HASH_SEED}-$$.log";
LinkedSpec::configure_trace(trace_level => 'debug', trace_log_file => $log,
    trace_log_mode => 'route', trace_reset_log => 1, trace_topic_spacing => 0);
my $substitution = LinkedSpec::call_spec_handler_subst('Top', $case->{action});
LinkedSpec::configure_trace(trace_level => 'none');
open my $trace_file, '<:raw', $log or die $!;
my $trace = do { local $/; <$trace_file> };
close $trace_file or die $!;
print $json->encode({id => $id, source => $case->{source}, action => $case->{action},
    seed => $ENV{PERL_HASH_SEED}, perturb => $ENV{PERL_PERTURB_KEYS},
    substitution => $substitution,
    substitution_sha256 => sha256_hex(encode('UTF-8', $substitution)),
    trace_base64 => encode_base64($trace, ''), trace_sha256 => sha256_hex($trace), trace_bytes => length($trace)}), "\n";
