use strict;
use warnings;
use JSON::PP;
use Scalar::Util qw(refaddr);

my %values;
{
 my $marker = 'before';
 my $change = sub { $marker = 'inside'; return $marker };
 $values{direct_list} = [$marker, $change->(), $marker];
}
{
 my $marker = 'before';
 my $change = sub { $marker = 'inside'; return $marker };
 $values{isolated_scalar} = [do { my $__ls_list_value = $marker; $__ls_list_value }, $change->(), $marker];
}
{
 my $marker = 'before';
 my $change = sub { $marker = 'inside'; return $marker };
 $values{anonymous_box} = [[$marker]->[0], $change->(), $marker];
}
{
 my $__ls_list_value = 'before';
 my $change = sub { $__ls_list_value = 'inside'; return $__ls_list_value };
 $values{same_name_initializer} = [do { my $__ls_list_value = $__ls_list_value; $__ls_list_value }, $change->(), $__ls_list_value];
}
{
 my $__ls_list_value = 'before';
 my $change_reference = sub { ${$_[0]} = 'inside'; return ${$_[0]} };
 my $result = do { my $__ls_list_value = $change_reference->(\$__ls_list_value); $__ls_list_value };
 $values{initializer_caller_reference} = [$result, $__ls_list_value];
}
{
 my $source = ['old'];
 my $copied_scalar = do { my $__ls_list_value = $source; $__ls_list_value };
 push @$source, 'changed';
 $values{reference_identity} = refaddr($source) == refaddr($copied_scalar) ? 1 : 0;
 $values{reference_contents} = $copied_scalar;
}
print JSON::PP->new->canonical->encode(\%values), "\n";
