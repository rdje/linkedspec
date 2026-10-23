use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::MethodLowering ();
my $expression=LinkedSpec::ActionIR::MethodLowering::_tracked_scalar_assignment_expr(
 'value','do { ++$effects; $input }',{nested_write_target=>sub {1}},0);
my $tail='; $value }';
die 'Expected one result tail' unless (()=$expression=~/\Q$tail\E/g)==1;
my %candidates=(current=>$expression,
 defined_or=>substr($expression,0,length($expression)-length($tail)).'; $value // undef }',
 scalar=>substr($expression,0,length($expression)-length($tail)).'; scalar($value) }',
 dereference=>substr($expression,0,length($expression)-length($tail)).'; ${\\$value} }');
my @rows;
for my $name (sort keys %candidates) {
 for my $context ('void','value','list') {
  my $operation=$context eq 'void' ? $candidates{$name}.'; my $result;'
   : $context eq 'value' ? 'my $result = '.$candidates{$name}.';'
   : 'my $result = ['.$candidates{$name}.'];';
  my $source='sub { my ($input)=@_; my ($value,$effects); $effects=0; my %__ls_binding_presence; '
   .$operation.' return {stored=>$value,result=>$result,flag=>$__ls_binding_presence{value},effects=>$effects} }';
  my (@warnings,$code,$error,@values);
  {
   local $SIG{__WARN__}=sub {push @warnings,@_};
   $code=eval $source;
   $error=$@;
   @values=map {$code->($_)} (0,'0','text',undef,[],{}) if $code;
  }
  push @rows,{name=>$name,context=>$context,expression=>$candidates{$name},source=>$source,
   warnings=>\@warnings,error=>$error,values=>\@values};
 }
}
print JSON::PP->new->canonical->allow_nonref->encode({rows=>\@rows}),"\n";
