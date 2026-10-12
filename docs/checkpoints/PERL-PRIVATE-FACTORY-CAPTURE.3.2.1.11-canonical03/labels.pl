use strict;
use warnings;
use JSON::PP;
use LinkedSpec::ActionIR::MethodLowering;

my ($first, $second) = @ARGV;
die "two private labels required\n" unless defined($second);
my @rows;
my @cases = (
 ['first', "$first(item)", $first, 'scalar'],
 ['second', "$second(item)", $second, 'scalar'],
 ['repeat', "$first(item)", $first, 'scalar'],
 ['mismatch', "$first(item)", $second, 'scalar'],
 ['empty', "$first(item)", '', 'scalar'],
 ['literal-dot', "$first.(item)", "$first.", 'scalar'],
 ['literal-dot-mismatch', "${first}X(item)", "$first.", 'scalar'],
 ['bare', 'item', $second, 'scalar'],
 ['spaced', "$second( item )", $second, 'scalar'],
 ['wrong-kind', "$second(item)", $second, 'hash'],
);
for my $case (@cases) {
 my ($name, $target, $container, $kind) = @$case;
 my @calls;
 my $value = LinkedSpec::ActionIR::MethodLowering::_uniform_binding_target_symbol(
  $target, $container, {bare_symbol_kind => sub {push @calls, [@_]; return $kind}});
 push @rows, {name => $name, target => $target, container => $container,
  kind => $kind, value => $value, calls => \@calls};
}
my %inputs;
for my $path (values %INC) {
 next unless defined($path) && -f $path;
 $inputs{$path} = 1;
}
print JSON::PP->new->canonical->encode({rows => \@rows, loaded_files => [sort keys %inputs]}), "\n";
