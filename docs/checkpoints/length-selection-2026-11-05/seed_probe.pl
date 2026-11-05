use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
use IO::Compress::Gzip qw(gzip $GzipError);
my $dir = 'docs/checkpoints/length-selection-2026-11-05';
my $lowered = LinkedSpec::call_spec_handler_subst('Value', 'return(length("tail").set_key("k",1))');
# The exact public substitution is the carrier; persist it before evaluation.
my $carrier = "package LinkedSpec::LengthSeedPublic; no strict; sub Run { $lowered }";
gzip \$carrier => "$dir/seed-carrier.pl.gz" or die $GzipError;
eval $carrier; die $@ if $@;
my @rows;
for my $seed ('empty', 'outer', 'main') {
    { no strict 'refs'; %{'LinkedSpec::LengthSeedPublic::4'}=(); %{'main::4'}=();
      %{'LinkedSpec::LengthSeedPublic::4'}=(outer=>'OUTER') if $seed eq 'outer';
      %{'main::4'}=(main=>'MAIN') if $seed eq 'main'; }
    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    my $value = eval { LinkedSpec::LengthSeedPublic::Run() };
    push @rows, {seed=>$seed,value=>$value,error=>"$@",warnings=>\@warnings};
}
print JSON::PP->new->canonical->encode({lowered=>$lowered,rows=>\@rows}), "\n";
