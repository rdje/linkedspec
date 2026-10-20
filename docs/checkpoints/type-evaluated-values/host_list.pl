use strict;
use warnings;
use JSON::PP;
use Scalar::Util qw(refaddr);

my %values;
{
 my $marker = 'before';
 my $change = sub { $marker = 'inside'; return $marker };
 $values{materialized_operand} = [do { my @__ls_evaluated_values = ($marker); @__ls_evaluated_values }, $change->(), $marker];
}
{
 my @__ls_evaluated_values = ('before');
 my $change = sub { $__ls_evaluated_values[0] = 'inside'; return $__ls_evaluated_values[0] };
 $values{same_name_array_initializer} = [do { my @__ls_evaluated_values = (@__ls_evaluated_values); @__ls_evaluated_values }, $change->(), @__ls_evaluated_values];
}
{
 my @__ls_evaluated_values = ('before');
 my $change_reference = sub { $_[0][0] = 'inside'; return $_[0][0] };
 my @result = do { my @__ls_evaluated_values = ($change_reference->(\@__ls_evaluated_values)); @__ls_evaluated_values };
 $values{initializer_caller_reference} = [@result, @__ls_evaluated_values];
}
{
 my @items = ('a', 'b');
 $values{splice_shape} = ['tag', do { my @__ls_evaluated_values = (@items); @__ls_evaluated_values }, 'tail'];
}
{
 my $source = ['old'];
 my @result = do { my @__ls_evaluated_values = ($source); @__ls_evaluated_values };
 push @$source, 'changed';
 $values{reference_identity} = refaddr($source) == refaddr($result[0]) ? 1 : 0;
 $values{reference_contents} = $result[0];
}
{
 my @result = do { my @__ls_evaluated_values = (JSON::PP::false, undef, '007', 42, 3.5); @__ls_evaluated_values };
 $values{primitive_kinds} = \@result;
}
print JSON::PP->new->canonical->encode({values => \%values, perl => "$^V"}), "\n";
