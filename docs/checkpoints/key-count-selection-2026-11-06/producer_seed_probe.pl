use strict;
use warnings;
use JSON::PP ();
use IO::Compress::Gzip qw(gzip $GzipError);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
my $base = 'docs/checkpoints/key-count-selection-2026-11-06';
my $json = JSON::PP->new->canonical->ascii->allow_nonref;
open my $file, '<:raw', "$base/producer-seed-input.json" or die $!;
my $input = $json->decode(do { local $/; <$file> }); close $file or die $!;
my $namespace = $input->{namespace};
die 'invalid observed numeric namespace' unless $namespace =~ /\A[0-9]+\z/;
my $public_package = 'LinkedSpec::KeyCountProducerSeedPublic';
my $carrier = "package $public_package; no strict; sub Run { $input->{lowered} }";
gzip \$carrier => "$base/producer-seeds/public-carrier.pl.gz" or die $GzipError;
eval $carrier; die $@ if $@;
my $module;
gunzip $input->{module} => \$module or die $GunzipError;
my $module_package = 'LinkedSpec::KeyCountProducerSeedModule';
eval "package $module_package; $module; 1"; die $@ if $@;
my @rows;
for my $route ('public', 'module') {
 my $package = $route eq 'public' ? $public_package : $module_package;
 for my $seed ('empty', 'outer', 'main') {
  no strict 'refs';
  local %{$package.'::'.$namespace};
  local %{'main::'.$namespace};
  %{$package.'::'.$namespace} = (outer=>'OUTER') if $seed eq 'outer';
  %{'main::'.$namespace} = (main=>'MAIN') if $seed eq 'main';
  my $before = {outer=>{%{$package.'::'.$namespace}}, main=>{%{'main::'.$namespace}}};
  my @warnings;
  local $SIG{__WARN__} = sub { push @warnings, @_ };
  my $value = eval { if ($route eq 'public') { $package->can('Run')->() }
    else { my $text = 'x'; $package->can('Execute')->(\$text) } };
  my $error = "$@";
  my $after = {outer=>{%{$package.'::'.$namespace}}, main=>{%{'main::'.$namespace}}};
  push @rows, {route=>$route,seed=>$seed,value=>$value,error=>$error,warnings=>\@warnings,
    host_before=>$before,host_after=>$after};
 }
}
print $json->encode({namespace=>$namespace,rows=>\@rows}), "\n";
