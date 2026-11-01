use strict;
use warnings;
use JSON::PP ();

# Read-only public lowering probe; optional retained owner permits historical replay.
if (@ARGV) {
    my $owner = shift @ARGV;
    die "owner must be repository-relative" if $owner =~ m{^/|(?:^|/)\.\.(?:/|$)};
    require "./$owner";
    $INC{'LinkedSpec/ActionIR/MethodLowering.pm'} = $owner;
}
require LinkedSpec;
open my $fh, '<', 'tests/fixtures/count_result_guard_cases.json' or die $!;
my $rows = JSON::PP->new->decode(do { local $/; <$fh> });
close $fh or die $!;
my @out;
for my $row (@$rows) {
    next unless $row->{id} =~ /\A(?:free_container_guards|free_guard_before_with|receiver_bridge_rejection)\z/;
    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    my $lowered = eval { LinkedSpec::call_spec_handler_subst($row->{rule}, $row->{body}) };
    push @out, {id => $row->{id}, body => $row->{body}, lowered => $lowered,
        error => "$@", warnings => \@warnings};
}
print JSON::PP->new->canonical->ascii->encode(\@out), "\n";
