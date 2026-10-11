use strict;
use warnings;
use B ();
use B::Deparse ();
use JSON::PP ();
use LinkedSpec::ActionIR::MethodLowering ();
die 'usage: native method inventory observe' unless @ARGV==1 && $ARGV[0] eq 'observe';
my $deparser=B::Deparse->new();
my @rows;
{
 no strict 'refs';
 for my $name (sort keys %LinkedSpec::ActionIR::MethodLowering::) {
  my $callback=*{'LinkedSpec::ActionIR::MethodLowering::'.$name}{CODE};
  next unless defined($callback);
  my $cv=B::svref_2object($callback);
  my $file=$cv->FILE;
  next unless defined($file) && $file=~m{(?:^|/)LinkedSpec/ActionIR/MethodLowering\.pm\z};
  push @rows,{name=>$name,file=>'perl/LinkedSpec/ActionIR/MethodLowering.pm',
   compiled_source=>$deparser->coderef2text($callback)};
 }
}
print JSON::PP->new->canonical->encode({functions=>\@rows,
 source_emissions_loaded=>exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0,
 loaded_modules=>[sort keys %INC]}),"\n";
