use strict;
use warnings;
use LinkedSpec ();
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use File::Path qw(make_path);
my $json = JSON::PP->new->canonical;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0-';
open my $input, '<', $prefix . 'cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$input> });
close $input or die $!;
my $selected = shift // die 'case required';
my ($case) = grep { $_->{id} eq $selected } @$cases;
die 'unknown case' unless $case;
my ($action) = $case->{source} =~ /\bI\s*\{(.*)\}\s*$/s;
die 'action missing' unless defined $action;
my $directory = '.linkedspec-data/scratch/residual-event-order';
make_path($directory);
my $log = "$directory/$selected-$ENV{PERL_HASH_SEED}-$$.log";
LinkedSpec::configure_trace(trace_level => 'debug', trace_log_file => $log,
    trace_log_mode => 'route', trace_reset_log => 1, trace_topic_spacing => 0);
my $rewritten = LinkedSpec::call_spec_handler_subst('Top', $action);
LinkedSpec::configure_trace(trace_level => 'none');
open my $trace_file, '<', $log or die $!;
my $trace = do { local $/; <$trace_file> };
close $trace_file or die $!;
print $json->pretty->encode({id => $selected, source => $case->{source}, action => $action,
    seed => $ENV{PERL_HASH_SEED}, perturb => $ENV{PERL_PERTURB_KEYS},
    substitution => $rewritten, substitution_sha256 => sha256_hex($rewritten), trace => $trace});
