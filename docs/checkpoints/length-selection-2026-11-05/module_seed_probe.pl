use strict;
use warnings;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use JSON::PP ();
my $path='docs/checkpoints/length-selection-2026-11-05/supplement/modules/seeded_hash.pm.gz';
gunzip $path => \my $module or die $GunzipError;
my @rows;
for my $seed ('empty','outer','main') {
 my $package='LinkedSpec::LengthModuleSeed::'.$seed;
 eval "package $package; $module; 1" or die $@;
 { no strict 'refs'; %{'main::4'}=(); %{"${package}::4"}=();
   %{"${package}::4"}=(outer=>'OUTER') if $seed eq 'outer';
   %{'main::4'}=(main=>'MAIN') if $seed eq 'main'; }
 my @warnings; local $SIG{__WARN__}=sub {push @warnings,@_};
 my $input='x'; my $value=eval {$package->can('Execute')->(\$input)};
 my $error="$@";
 my $host; {no strict 'refs'; $host={%{'main::4'}};}
 push @rows,{seed=>$seed,value=>$value,error=>$error,warnings=>\@warnings,main_host=>$host};
}
print JSON::PP->new->canonical->encode(\@rows),"\n";
