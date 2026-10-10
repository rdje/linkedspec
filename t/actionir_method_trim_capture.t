use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr weaken);
use JSON::PP ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

sub dependencies { return {trim_action_ir_value => $_[0]} }
sub binding {
 my ($callback) = @_;
 # The original native baseline invokes the actual callback directly. The
 # implementation uses its new private binding; no public map is rewritten.
 return defined(&LinkedSpec::ActionIR::MethodLowering::_bind_emission_dependency)
  ? LinkedSpec::ActionIR::MethodLowering::_bind_emission_dependency($callback) : $callback
}
sub capture { LinkedSpec::ActionIR::SourceEmissions::_capture_emission(@_) }
sub producers { LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers(@_) }
sub scope { LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', $_[0]) }
sub emit {
 my ($event, $text) = @_;
 my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
 LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, $text);
 return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder)
}
sub event {
 my $event = {raw => 'same'};
 LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
  {event => $event, source => 'same', source_span => {start => 0, end => 4}});
 return $event
}
my @owners = qw(_infer_direct_shape_literal_kind _normalize_method_tag_expr _lower_inline_switch_case_value_expr);
sub owner {
 my ($name, $input, $deps) = @_;
 no warnings 'redefine';
 # Shape classification delegates to the later large value owner. Hold that
 # secondary result constant while probing this owner's actual trim boundary.
 local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub { return '[]' };
 my $callback = LinkedSpec::ActionIR::MethodLowering->can($name);
 return $callback->($input, $deps)
}
sub caller_observations {
 my @rows;
 for my $name (@owners) {
  for my $outcome (qw(string undefined fatal)) {
   my $input = 'original';
   my (@trace, $value, $error, $success_error);
   my $fatal = bless {}, 'MethodTrimFatal';
   my $actual = sub {
    push @trace, {context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
     input => $_[0], error => $@};
    $_[0] .= '!'; $@ = 'successful caller dependency error';
    die $fatal if $outcome eq 'fatal';
    return undef if $outcome eq 'undefined';
    return $name eq '_infer_direct_shape_literal_kind' ? '[]'
     : $name eq '_normalize_method_tag_expr' ? '"tag"' : 'tag'
   };
   my $deps = dependencies($actual);
   eval { $@ = 'incoming caller error'; $value = owner($name, $input, $deps); $success_error = $@; 1 }
    or $error = $@;
   push @rows, {owner => $name, outcome => $outcome, input => $input, trace => \@trace,
    value => $value, success_error => $success_error,
    map_identity => refaddr($deps->{trim_action_ir_value}) == refaddr($actual) ? 1 : 0,
    error => ref($error) ? {reference => ref($error), same_fatal => refaddr($error) == refaddr($fatal) ? 1 : 0} : $error};
  }
 }
 return \@rows
}
sub dependency_observations {
 my @rows;
 for my $context (qw(scalar list void)) {
  for my $outcome (qw(string reference undefined values fatal)) {
   my ($first, $last) = ('first', 'last');
   my $shared = {calls => 0};
   my $fatal = bless {}, 'ContractDependencyFatal';
   my (@trace, @values, $value, $error, $success_error);
   my $actual = sub {
    push @trace, {context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
     error => $@, shared_identity => refaddr($_[1]) == refaddr($shared) ? 1 : 0};
    $_[0] .= '!'; $_[2] .= '?'; ++$_[1]{calls};
    $@ = 'successful dependency error';
    die $fatal if $outcome eq 'fatal';
    return $shared if $outcome eq 'reference';
    return undef if $outcome eq 'undefined';
    return ('left', $shared, 'right') if $outcome eq 'values';
    return 'same'
   };
   my $deps = dependencies($actual);
   my $bound = binding($actual);
   eval {
    $@ = 'incoming dependency error';
    if ($context eq 'void') { $bound->($first, $shared, $last) }
    elsif ($context eq 'list') { @values = $bound->($first, $shared, $last) }
    else { $value = $bound->($first, $shared, $last) }
    $success_error = $@;
    1
   } or $error = $@;
   my $normalize = sub {
    my ($item) = @_;
    return {reference => ref($item), same_shared => refaddr($item) == refaddr($shared) ? 1 : 0}
     if ref($item);
    return $item
   };
   push @rows, {context => $context, outcome => $outcome, first => $first, last => $last,
    shared => $shared, trace => \@trace, value => $normalize->($value),
    values => [map { $normalize->($_) } @values], success_error => $success_error,
    map_identity => refaddr($deps->{trim_action_ir_value}) == refaddr($actual) ? 1 : 0,
    error => ref($error) ? {reference => ref($error), same_fatal => refaddr($error) == refaddr($fatal) ? 1 : 0} : $error};
  }
 }
 return \@rows
}

if (@ARGV && $ARGV[0] eq 'observe') {
 print JSON::PP->new->canonical->encode({dependency => dependency_observations(), callers => caller_observations()}), "\n";
 exit 0
}
for my $row (@{dependency_observations()}) {
 my $label = join '/', @{$row}{qw(context outcome)};
 is(scalar @{$row->{trace}}, 1, "$label actual injected callback executes once");
 is($row->{trace}[0]{context}, $row->{context}, "$label native dependency context survives");
 is_deeply([$row->{first}, $row->{last}], ['first!', 'last?'], "$label first and extra caller aliases survive");
 is($row->{trace}[0]{shared_identity}, 1, "$label actual shared reference survives");
 is($row->{shared}{calls}, 1, "$label shared effect occurs once");
 is($row->{trace}[0]{error}, 'incoming dependency error', "$label native incoming error survives");
 is($row->{map_identity}, 1, "$label public map retains its actual callback");
 if ($row->{outcome} eq 'fatal') {
  is_deeply($row->{error}, {reference => 'ContractDependencyFatal', same_fatal => 1}, "$label fatal object identity survives");
 } else {
  is($row->{success_error}, 'successful dependency error', "$label native successful error effect survives");
 }
 my $ordinary = $row->{outcome} eq 'reference' ? {reference => 'HASH', same_shared => 1}
  : $row->{outcome} eq 'undefined' ? undef : $row->{outcome} eq 'values' ? 'right' : 'same';
 my $expected_value = $row->{context} eq 'scalar' && $row->{outcome} ne 'fatal' ? $ordinary : undef;
 my $expected_values = $row->{context} ne 'list' || $row->{outcome} eq 'fatal' ? []
  : $row->{outcome} eq 'values' ? ['left', {reference => 'HASH', same_shared => 1}, 'right'] : [$ordinary];
 is_deeply($row->{value}, $expected_value, "$label scalar return remains native");
 is_deeply($row->{values}, $expected_values, "$label list return remains native");
}

for my $row (@{caller_observations()}) {
 my $label = $row->{owner}.'/'.$row->{outcome};
 my $calls = $row->{outcome} eq 'string' && $row->{owner} eq '_lower_inline_switch_case_value_expr' ? 2 : 1;
 is(scalar @{$row->{trace}}, $calls, "$label actual trim effects keep native invocation count");
 is_deeply([map {$_->{context}} @{$row->{trace}}], [('scalar') x $calls], "$label actual trim calls keep scalar context");
 is($row->{input}, 'original', "$label existing top-level copied input remains unchanged");
 is($row->{trace}[0]{error}, 'incoming caller error', "$label native incoming caller error survives");
 is($row->{map_identity}, 1, "$label caller public dependency reference stays exact");
 if ($row->{outcome} eq 'fatal') {
  is_deeply($row->{error}, {reference => 'MethodTrimFatal', same_fatal => 1}, "$label fatal dependency object identity survives");
 } else {
  is($row->{success_error}, 'successful caller dependency error', "$label successful dependency error effect survives");
 }
 my $expected = $row->{outcome} eq 'string'
  ? $row->{owner} eq '_infer_direct_shape_literal_kind' ? 'array' : '"tag"' : undef;
 is($row->{value}, $expected, "$label actual caller ordinary result stays native");
}

for my $name (@owners) {
 for my $known (0, 1) {
  scope(sub {
   my $event = event(); my (@trace, $calls); $calls = 0;
   my $expected = $name eq '_infer_direct_shape_literal_kind' ? 'array' : '"tag"';
   my $actual = sub {
    ++$calls; push @trace, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    # Only the first switch-case trim publishes. Removing either caller's own
    # seam then exposes inheritance instead of an invalid duplicate publication.
    emit($event, $expected) if $calls == 1;
    return $name eq '_infer_direct_shape_literal_kind' ? '[]'
     : $name eq '_normalize_method_tag_expr' ? '"tag"' : 'tag'
   };
   my $deps = dependencies($actual);
   my $outer = sub { return owner($name, 'same', $deps) };
   producers($known ? [$outer, $actual] : [$outer], sub {
    my $result = capture($outer);
    is($result->{value}, $expected, "$name/$known actual caller value survives");
    ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
     "$name/$known injected trim cannot donate nested publication");
    is_deeply(\@trace, [($known) x $calls], "$name/$known trim has its own actual callback boundary");
    is($calls, $name eq '_lower_inline_switch_case_value_expr' ? 2 : 1,
     "$name/$known caller effects keep native order and count");
    is(refaddr($deps->{trim_action_ir_value}), refaddr($actual), "$name/$known public callback stays exact");
   });
  });
 }
 for my $bad (undef, 'not code') {
  my $error;
  eval { owner($name, 'same', {trim_action_ir_value => $bad}); 1 } or $error = $@;
  like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback 'trim_action_ir_value'/,
   "$name required callback diagnostic remains exact");
 }
}

scope(sub {
 my $event = event();
 my $child = sub { emit($event, 'same'); return 'same' };
 my $bound = binding($child);
 my ($child_capture, $nested);
 my $native_capture = \&LinkedSpec::ActionIR::SourceEmissions::_capture_emission;
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::SourceEmissions::_capture_emission = sub {
  my $callback = $_[0]; my $result = $native_capture->(@_);
  $child_capture = $result if refaddr($callback) == refaddr($child);
  return $result
 };
 my $outer = sub {
  $nested = scope(sub { return $bound->() });
  return $bound->()
 };
 producers([$child, $outer], sub {
  my $result = capture($outer);
  is($nested, 'same', 'nested equal-source dependency keeps ordinary value');
  is($result->{value}, 'same', 'known child ordinary value reaches parent');
  ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
   'known child packet never transfers implicitly to parent');
  ok(LinkedSpec::ActionIR::SourceEmissions::_emission_for($child_capture, $child, $event),
   'explicit actual known-child capture retains its own packet');
 });
});
{
 my $state = {};
 my $actual = sub { return $state ? 'same' : undef };
 my $weak = $actual; weaken($weak);
 my $bound = binding($actual); undef $actual;
 ok(defined($weak), 'private binding retains actual lexical callback while in use');
 undef $bound;
 ok(!defined($weak), 'private binding release leaves no global callback retention');
}
done_testing;
