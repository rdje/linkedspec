use strict;
use warnings;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();

my ($cases_path, $phase0_path) = @ARGV;
sub read_file {
    open my $fh, '<:raw', $_[0] or die $!;
    my $raw = do {local $/; <$fh>};
    close $fh or die $!;
    return $raw;
}
my $json = JSON::PP->new->canonical;
my $cases = $json->decode(read_file($cases_path));
my $phase0 = read_file($phase0_path);
my ($helper) = $phase0 =~ /(sub evaluate_lowered_json \{.*?)(?=\nsub discover_specs \{)/s;
die "missing original execution helper\n" unless defined $helper;
eval $helper; die $@ if $@;
my @rows;
for my $case (@$cases) {
    my $source = eval $case->{lowering};
    die $@ if $@;
    die "empty lowering\n" unless defined $source && length $source;
    my $program = sprintf($case->{program_template}, $source);
    my $observed = evaluate_lowered_json($program, $case->{setup});
    push @rows, {line=>$case->{line}, source=>$source, program=>$program, observed=>$observed,
                wrong_value=>evaluate_lowered_json('return undef;', $case->{setup}),
                warning=>evaluate_lowered_json('warn "oracle-control\\n"; '.$program, $case->{setup})};
}
print $json->encode({rows=>\@rows,
    module_sha256=>sha256_hex(read_file($INC{'LinkedSpec/ActionIR/MethodLowering.pm'})),
    helper_sha256=>sha256_hex($helper)}), "\n";
