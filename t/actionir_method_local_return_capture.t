use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my @keys = qw(parse_method_function_expr normalize_method_args_with_optional_scope);
my $name = '_lower_block_local_return_payload_expr';
sub capture { LinkedSpec::ActionIR::SourceEmissions::_capture_emission(@_) }
sub producers { LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers(@_) }
sub scope { LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', $_[0]) }
sub event {
 my $event = {raw => 'same'};
 LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
  {event => $event, source => 'same', source_span => {start => 0, end => 4}});
 return $event
}
sub emit {
 my ($event) = @_;
 my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
 LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'VALUE');
 return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder)
}
sub setup {
 my ($target, $outcome, $event) = @_;
 my $state = {trace => [], eligible => [], calls => {}, args => ['payload'], payloads => []};
 my $call = {method => 'return', args => $state->{args}};
 my $fatal = bless {}, 'MethodLocalReturnFatal';
 my (%deps, %actual);
 for my $key (@keys) {
  my $callback = sub {
   ++$state->{calls}{$key};
   push @{$state->{trace}}, {key => $key,
    context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', error => $@,
    args => [map {ref($_) eq 'ARRAY' ? [@$_] : $_} @_],
    actual_args => ref($_[0]) eq 'ARRAY' ? (refaddr($_[0]) == refaddr($state->{args}) ? 1 : 0) : undef};
   if (ref($_[0]) eq 'ARRAY') { push @{$_[0]}, 'effect' }
   elsif (defined($_[0])) { $_[0] .= '!' }
   $@ = 'successful '.$key;
   if ($key eq $target) {
    push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    die $fatal if $outcome eq 'fatal';
    return undef if $outcome eq 'undefined';
    emit($event) if $event;
   }
   return $call if $key eq 'parse_method_function_expr';
   return $state->{args} if $key eq 'normalize_method_args_with_optional_scope';
   die 'unknown fixture callback'
  };
  $deps{$key} = $actual{$key} = $callback;
 }
 return (\%deps, \%actual, $state, $fatal)
}
sub owner {
 my ($input, $deps, $state, $payload) = @_;
 $payload = 'VALUE' if @_ < 4;
 no warnings 'redefine';
 # Only the actual required resolver/caller body is admitted. The secondary
 # payload lowerer has an explicit constant result, including guard controls.
 local *LinkedSpec::ActionIR::MethodLowering::_lower_return_payload_expr = sub {
  push @{$state->{payloads}}, {argument => $_[0], deps_identity => refaddr($_[1]) == refaddr($deps) ? 1 : 0};
  return $payload
 };
 return LinkedSpec::ActionIR::MethodLowering::_lower_block_local_return_payload_expr($input, $deps)
}
sub observations {
 my @rows;
 for my $key (@keys) {
  for my $outcome (qw(string undefined fatal)) {
   my ($deps, $actual, $state, $fatal) = setup($key, $outcome);
   my $input = 'return(payload)';
   my ($value, $error, $success_error);
   eval { $@ = 'incoming local return error'; $value = owner($input, $deps, $state); $success_error = $@; 1 }
    or $error = $@;
   push @rows, {key => $key, outcome => $outcome, input => $input,
    trace => $state->{trace}, calls => $state->{calls}, args => $state->{args},
    payloads => $state->{payloads}, success_error => $success_error, value => $value,
    error => ref($error) ? {type => ref($error), same_fatal => refaddr($error) == refaddr($fatal) ? 1 : 0} : $error,
    map_identity => [map {refaddr($deps->{$_}) == refaddr($actual->{$_}) ? 1 : 0} @keys]};
  }
 }
 return \@rows
}
if (@ARGV && $ARGV[0] eq 'observe') {
 print JSON::PP->new->canonical->encode(observations()), "\n"; exit 0
}
for my $row (@{observations()}) {
 my $label = join '/', $name, @{$row}{qw(key outcome)};
 is_deeply($row->{map_identity}, [1, 1], "$label actual public callback references stay exact");
 is($row->{input}, 'return(payload)', "$label top-level scalar input keeps existing copy behavior");
 ok(@{$row->{trace}} && !grep({$_->{context} ne 'scalar'} @{$row->{trace}}), "$label actual required calls retain scalar context");
 is($row->{trace}[0]{error}, 'incoming local return error', "$label native incoming error survives");
 is($row->{calls}{$row->{key}}, 1, "$label target callback keeps native invocation count");
 if ($row->{outcome} eq 'fatal') {
  is_deeply($row->{error}, {type => 'MethodLocalReturnFatal', same_fatal => 1}, "$label fatal object retains actual identity");
 } else {
  ok(defined($row->{success_error}) && $row->{success_error} =~ /^successful /, "$label native successful error effect survives");
 }
 is($row->{value}, $row->{outcome} eq 'string' ? 'VALUE' : undef, "$label actual caller ordinary result stays native");
 is_deeply($row->{payloads}, $row->{outcome} eq 'string' ? [{argument => 'payload', deps_identity => 1}] : [],
  "$label controlled payload helper receives the actual normalized value and dependency map only when valid");
 if ($row->{key} eq 'normalize_method_args_with_optional_scope') {
  my ($trace) = grep {$_->{key} eq $row->{key}} @{$row->{trace}};
  is($trace->{actual_args}, 1, "$label normalizer receives the actual parser-returned array");
  is_deeply($row->{args}, ['payload', 'effect'], "$label normalizer mutates the actual shared argument array");
  is_deeply([@{$trace->{args}}[1, 2]], [1, 1], "$label normalizer retains both count arguments");
 }
}
for my $key (@keys) {
 for my $known (0, 1) {
  scope(sub {
   my $event = event();
   my ($deps, $actual, $state) = setup($key, 'string', $event);
   my $outer = sub { return owner('return(payload)', $deps, $state) };
   producers($known ? [$outer, $actual->{$key}] : [$outer], sub {
    my $result = capture($outer);
    is($result->{value}, 'VALUE', "$name/$key/$known actual ordinary value survives");
    ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
     "$name/$key/$known required dependency cannot donate nested publication");
    is_deeply($state->{eligible}, [$known], "$name/$key/$known actual callback has its own identity boundary");
    is($state->{calls}{$key}, 1, "$name/$key/$known actual native effect count survives");
    is_deeply([map {refaddr($deps->{$_})} @keys], [map {refaddr($actual->{$_})} @keys],
     "$name/$key/$known original public map keeps all actual callbacks");
   });
  });
 }
}
for my $key (@keys) {
 for my $bad (undef, 'not code') {
  my ($deps, $actual, $state) = setup($key, 'string'); $deps->{$key} = $bad;
  my $error; eval { owner('return(payload)', $deps, $state); 1 } or $error = $@;
  like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$key\E'/,
   "$name/$key required dependency diagnostic remains exact");
 }
}
for my $case ([undef, undef], ['', undef], ['0', '0'],
 ['{ marker => 1 }', '+{ marker => 1 }'], ['  { marker => 1 }', '+  { marker => 1 }'], ['VALUE', 'VALUE']) {
 my ($payload, $expected) = @$case;
 my ($deps, $actual, $state) = setup($keys[0], 'string');
 my $label = defined($payload) ? "'$payload'" : 'undefined';
 is(owner('return(payload)', $deps, $state, $payload), $expected, "payload guard $label keeps native result");
 is($state->{payloads}[0]{argument}, 'payload', "payload guard $label keeps normalized first argument");
 is($state->{payloads}[0]{deps_identity}, 1, "payload guard $label keeps actual dependency map");
}
for my $call (undef, {}, {method => 'set', args => ['payload']}) {
 my $state = {calls => 0, payloads => []};
 my $deps = {parse_method_function_expr => sub { return $call },
  normalize_method_args_with_optional_scope => sub { ++$state->{calls}; die 'rejected method normalized' }};
 is(owner('source', $deps, $state), undef, 'undefined or non-return parser result is rejected');
 is($state->{calls}, 0, 'rejected parser result does not invoke normalization');
 is_deeply($state->{payloads}, [], 'rejected parser result does not invoke payload helper');
}
{
 my $state = {payloads => []};
 my ($array_kind, $counts);
 my $deps = {parse_method_function_expr => sub { return {method => 'return'} },
  normalize_method_args_with_optional_scope => sub {
   $array_kind = ref($_[0]); $counts = [@_[1, 2]]; $_[0][0] = 'fallback'; return $_[0]
  }};
 is(owner('return()', $deps, $state), 'VALUE', 'missing parser args retain empty-array fallback');
 is($array_kind, 'ARRAY', 'missing parser args supply a real argument array');
 is_deeply($counts, [1, 1], 'missing parser args retain normalizer count arguments');
 is($state->{payloads}[0]{argument}, 'fallback', 'fallback normalization supplies the payload helper argument');
}
for my $deps (undef, [], 'not hash') {
 my $error; eval { owner('source', $deps, {payloads => []}); 1 } or $error = $@;
 like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback 'parse_method_function_expr'/,
  'non-hash dependency map retains first required diagnostic');
}
done_testing;
