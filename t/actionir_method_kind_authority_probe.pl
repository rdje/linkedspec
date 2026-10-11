package MethodKindAuthorityProbe;
use strict;
use warnings;
use JSON::PP ();

# Reuse the first diagnostic producer intact. Its complete replay is retained
# separately from these additional tied-map authority observations.
my $replay = '';
{
 local @ARGV = ('observe');
 local *STDOUT;
 open STDOUT, '>', \$replay or die "capture original probe: $!";
 my $loaded = do './t/actionir_method_kind_probe.pl';
 die $@ if $@;
 die $! unless defined $loaded;
}
my @rows;
for my $owner (qw(outer inner)) {
 for my $variant (qw(code qualified unqualified blessed-code glob undefined array hash name-object)) {
  for my $known (0, 1) {
   my $state;
   no warnings qw(redefine once);
   local *LinkedSpec::ActionIR::MethodLowering::method_kind_authority_named;
   my $original_setup = \&MethodKindProbe::setup;
   local *MethodKindProbe::setup = sub {
    $state = $original_setup->(@_);
    *LinkedSpec::ActionIR::MethodLowering::method_kind_authority_named = $state->{actual};
    my $selected = $variant eq 'code' ? $state->{actual}
     : $variant eq 'qualified' ? 'LinkedSpec::ActionIR::MethodLowering::method_kind_authority_named'
     : $variant eq 'unqualified' ? 'method_kind_authority_named'
     : $variant eq 'blessed-code' ? bless(sub {return $state->{actual}->(@_)}, 'MethodKindAuthorityProbe::BlessedCode')
     : $variant eq 'glob' ? \*LinkedSpec::ActionIR::MethodLowering::method_kind_authority_named
     : $variant eq 'array' ? [] : $variant eq 'hash' ? {}
     : $variant eq 'name-object' ? bless({name => 'LinkedSpec::ActionIR::MethodLowering::method_kind_authority_named'}, 'MethodKindProbe::Name')
     : undef;
    my @sequence = ($state->{first}, $selected, $state->{first}, $selected);
    my %deps;
    tie %deps, 'MethodKindProbe::Map', $state->{storage}, \@sequence, $state->{fetches};
    $state->{deps} = \%deps;
    return $state;
   };
   push @rows, MethodKindProbe::observe($owner.'/'.$variant.'/known-'.$known, $owner, {}, $known);
  }
 }
}
print JSON::PP->new->canonical->encode({original_replay => $replay, rows => \@rows}), "\n";
