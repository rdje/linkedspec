use strict;
use warnings;
use JSON::PP ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::CodeblockRuntime ();
use LinkedSpec::BindingRuntime ();
my $parse = sub { LinkedSpec::ActionIR::AST::parse_action_expr($_[0]) };
my $record = $parse->('{|| tree[key()] = rhs() }');
my $tree = {a => 'A'};
my $seen = '';
my $key = $parse->('{|| seen = cat(seen,"k"); return("z") }');
my $rhs = $parse->('{|| seen = cat(seen,"r"); return(2) }');
my $bindings = {tree => \$tree, seen => \$seen, key => \$key, rhs => \$rhs};
my $error;
eval {
 LinkedSpec::BindingRuntime::map_leaves_mutation(\$tree, 1, 'tree',
  {source_id => 'seam', start => 0, end => 4, unit => 'unicode_scalar', provenance => 'authored'},
  sub { LinkedSpec::CodeblockRuntime::invoke($record, [], $bindings, 'guarded-write') });
 1;
} or $error = $@;
my $guard = {class => ref($error), code => ref($error) ? $error->{code} : undef,
 seen => $seen, tree => $tree};
my $root = {};
my $value = $parse->('{|| root["x"] = [1] }');
my $result = LinkedSpec::CodeblockRuntime::invoke($value, [], {root => \$root}, 'detached-result');
$result->{x}[0] = 2;
print JSON::PP->new->canonical->encode({guard => $guard, committed => $root, result => $result}), "\n";
