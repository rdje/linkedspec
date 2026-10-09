use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodExpr ();

my $package = 'LinkedSpec::ActionIR::MethodExpr';
my $scope = $package->can('_with_input_captures');
my $csv = $package->can('_capture_csv_input');
my $method = $package->can('_capture_method_input');
my $frame = $package->can('_argument_input_for');
ok($scope && $csv && $method && $frame, 'actual MethodExpr input captures are available');
BAIL_OUT('private MethodExpr input capture unavailable') unless $scope && $csv && $method && $frame;
my $parse = \&LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr;
my $split = \&LinkedSpec::ActionIR::MethodExpr::_split_top_level_csv;

# Positions come from authored pieces and separators, not parser text searches.
my @cases = (
 ['method', ' cat( ', ['"λ"', '"λ"'], [', '], ' ) '],
 ['method', " \r\n cat( ", ['same', 'inner("😀")', 'same'], [', , ', ",\r\n "], ' ) '],
 ['method', 'array( ', ['[1, 2]', '"x,y"'], [', '], ' )'],
 ['csv', " \r\n ", ['"😀"', 'same', '"😀"'], [', , ', ",\r\n "], "\t "],
 ['csv', '', ['inner(1, 2)', '"x,y"'], [', '], ' '],
);
for my $case (@cases) {
 my ($mode, $prefix, $arguments, $separators, $suffix) = @$case;
 my $source = $prefix;
 my @expected;
 for my $index (0 .. $#$arguments) {
  $source .= $separators->[$index - 1] if $index;
  my $start = length($source);
  $source .= $arguments->[$index];
  push @expected, {raw => $arguments->[$index], source_span => {start => $start, end => length($source)}};
 }
 $source .= $suffix;
 $_->{source} = $source for @expected;
 my $producer = $mode eq 'method' ? $parse : $split;
 my $capture = $mode eq 'method' ? $method : $csv;
 my ($count, $returned, $context);
 my $callback = sub { ++$count; $context = wantarray; $returned = $producer->(@_); return $returned };
 $scope->(sub {
  my $result = $capture->($callback, $source);
  is($count, 1, 'actual input callback invoked once');
  ok(defined($context) && !$context, 'actual input callback scalar context');
  is(refaddr($result->{value}), refaddr($returned), 'actual input return reference preserved');
  my $args = $mode eq 'method' ? $returned->{args} : $returned;
  is_deeply($args, $arguments, 'actual original argument values');
  is_deeply([map { $frame->($result, $callback, $args, $_) } 0 .. $#$args], \@expected,
   'actual original input occurrence intervals');
  my $description = $frame->($result, $callback, $args, 0);
  $description->{source_span}{start} = 999;
  is_deeply($frame->($result, $callback, $args, 0), $expected[0], 'input description detached from authority');
 });
}

$scope->(sub {
 my $result = $csv->($split, ' same, same ');
 is($frame->($result, $split, [@{$result->{value}}], 0), undef, 'copied CSV input argument array denied');
});

my ($expired, $expired_args);
$scope->(sub {
 my $source = ' call( same, same ) ';
 my $result = $method->($parse, $source);
 my $value = $result->{value};
 my $args = $value->{args};
 my $wanted = {source => $source, raw => 'same', source_span => {start => 7, end => 11}};
 is_deeply($frame->($result, $parse, $args, 0), $wanted, 'actual input identity accepted');
 is($frame->({%$result}, $parse, $args, 0), undef, 'copied input capture denied');
 is($frame->($result, sub { $parse->(@_) }, $args, 0), undef, 'foreign input callback denied');
 is($frame->($result, $parse, [@$args], 0), undef, 'copied input argument array denied');
 for my $index (-1, 2, 'x', '0.5', undef) {
  is($frame->($result, $parse, $args, $index), undef, 'invalid input occurrence denied');
 }
 $result->{value} = {%$value};
 is($frame->($result, $parse, $args, 0), undef, 'changed capture result denied');
 $result->{value} = $value;
 for my $field (qw(method source_method source)) {
  my $saved = $value->{$field}; $value->{$field} = 'changed';
  is($frame->($result, $parse, $args, 0), undef, 'changed method input root denied');
  $value->{$field} = $saved;
 }
 $value->{args} = [@$args];
 is($frame->($result, $parse, $args, 0), undef, 'changed method argument reference denied');
 $value->{args} = $args;
 push @$args, 'extra';
 is($frame->($result, $parse, $args, 0), undef, 'changed input array shape denied');
 pop @$args;
 $args->[0] = 'changed';
 is($frame->($result, $parse, $args, 0), undef, 'changed input occurrence denied');
 is_deeply($frame->($result, $parse, $args, 1), {source => $source, raw => 'same', source_span => {start => 13, end => 17}},
  'unchanged input neighbor retains its occurrence');
 $args->[0] = 'same';
 $scope->(sub {
  is($frame->($result, $parse, $args, 0), undef, 'foreign nested input scope denied');
 });
 is_deeply($frame->($result, $parse, $args, 0), $wanted, 'input scope restored after nested success');
 ($expired, $expired_args) = ($result, $args);
});
is($frame->($expired, $parse, $expired_args, 0), undef, 'expired input capture denied');

for my $mode ('method', 'csv') {
 my $capture = $mode eq 'method' ? $method : $csv;
 my $producer = $mode eq 'method' ? $parse : $split;
 my $source = $mode eq 'method' ? ' call(same,same) ' : ' same,same ';
 for my $behavior ('copy', 'foreign', 'opaque') {
  my $callback = sub {
   return ['opaque'] if $behavior eq 'opaque';
   my $value = $producer->($behavior eq 'foreign' ? ($mode eq 'method' ? 'call(same,same)' : 'same,same') : @_);
   return $behavior eq 'copy' ? ($mode eq 'method' ? {%$value} : [@$value]) : $value;
  };
  $scope->(sub {
   my $result = $capture->($callback, $source);
   my $args = ref($result->{value}) eq 'HASH' ? $result->{value}{args} : $result->{value};
   is_deeply($args, $behavior eq 'opaque' ? ['opaque'] : ['same', 'same'], 'opaque copied foreign input preserves values');
   is($frame->($result, $callback, $args, 0), undef, 'opaque copied foreign input has no authority');
  });
 }
 my ($alias, $tail, $calls) = ($source, 'tail', 0);
 my $callback = sub { ++$calls; $_[1] = 'mutated'; $_[0] .= ' '; return $producer->($_[0]) };
 $scope->(sub {
  my $result = $capture->($callback, $alias, $tail);
  is($alias, $source.' ', 'direct input scalar alias preserved');
  is($tail, 'mutated', 'direct input extra alias preserved');
  is($calls, 1, 'alias callback once');
  my $args = $mode eq 'method' ? $result->{value}{args} : $result->{value};
  is($frame->($result, $callback, $args, 0), undef, 'mutated source declines initial input authority');
 });
 my $legacy_source = $source;
 my $legacy = $mode eq 'method' ? \&LinkedSpec::ActionIR::MethodExpr::_parse_method_with_source_frames
                                : \&LinkedSpec::ActionIR::MethodExpr::_split_csv_with_source_frames;
 $legacy->(sub { $_[0] .= ' '; return $producer->($_[0]) }, $legacy_source);
 is($legacy_source, $source, 'legacy wrapper copied scalar behavior preserved');
 my $saved;
 { local $@ = 'input caller sentinel'; $capture->($producer, $source); $saved = $@ }
 is($saved, 'input caller sentinel', 'input capture successful caller error preserved');
 my $fatal = bless {}, 'InputFatal';
 $scope->(sub {
  my $outer = $capture->($producer, $source);
  my $args = $mode eq 'method' ? $outer->{value}{args} : $outer->{value};
  my $wanted = $frame->($outer, $producer, $args, 0);
  my $ok = eval { $scope->(sub { $capture->(sub { die $fatal }, $source) }); 1 };
  ok(!$ok && refaddr($@) == refaddr($fatal), 'fatal input callback exception identity preserved');
  is_deeply($frame->($outer, $producer, $args, 0), $wanted, 'input scope restored after nested fatal');
  my $inner = $capture->($producer, $source);
  ok($frame->($inner, $producer, $mode eq 'method' ? $inner->{value}{args} : $inner->{value}, 0), 'input capture usable after fatal');
 });
}
# Nested collectors in the same scope must restore the outer recorder too.
for my $mode ('method', 'csv') {
 my $capture = $mode eq 'method' ? $method : $csv;
 my $producer = $mode eq 'method' ? $parse : $split;
 my $source = $mode eq 'method' ? 'call( same )' : ' same ';
 $scope->(sub {
  my $inner;
  my $callback = sub { $inner = $capture->($producer, $source); return $producer->(@_) };
  my $outer = $capture->($callback, $source);
  for my $row ([$inner, $producer], [$outer, $callback]) {
   my ($result, $cb) = @$row;
   my $args = $mode eq 'method' ? $result->{value}{args} : $result->{value};
   is_deeply($frame->($result, $cb, $args, 0), {source => $source, raw => 'same',
    source_span => {start => $mode eq 'method' ? 6 : 1, end => $mode eq 'method' ? 10 : 5}},
    'same-scope nested input retains exact own frame');
  }
  my ($saved, $result);
  { local $@ = 'scoped input sentinel'; $result = $capture->($producer, $source); $saved = $@ }
  is($saved, 'scoped input sentinel', 'registered input capture preserves caller error');
 });
 for my $value (undef, 'literal', {}, ['opaque']) {
  my $callback = sub { return $value };
  $scope->(sub {
   my $result = $capture->($callback, $source);
   ref($value) ? is(refaddr($result->{value}), refaddr($value), 'opaque input reference preserved')
               : is($result->{value}, $value, 'opaque input scalar preserved');
   is($frame->($result, $callback, ref($value) eq 'ARRAY' ? $value : [], 0), undef,
    'opaque input value has no frame');
  });
 }
}
for my $context ('void', 'scalar', 'list') {
 my $observed;
 my $work = sub { $observed = wantarray; return ('first', 'last') };
 if ($context eq 'void') { $scope->($work); ok(!defined($observed), 'input scope void work context') }
 elsif ($context eq 'scalar') { my $result = $scope->($work); ok(defined($observed) && !$observed && $result eq 'last', 'input scope scalar work context') }
 else { my @result = $scope->($work); ok($observed && @result == 2 && $result[0] eq 'first', 'input scope list work context') }
}
done_testing;
