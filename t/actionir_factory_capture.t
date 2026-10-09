use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw(refaddr weaken);
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

sub producers { LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers(@_) }
sub register { LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer(@_) }
sub capture { LinkedSpec::ActionIR::SourceEmissions::_capture_emission(@_) }
sub packet { LinkedSpec::ActionIR::SourceEmissions::_emission_for(@_) }
sub dependency { goto &LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency }

# An authored original frame, independent of public AST/text-search offsets.
my $source = "λ😀same\r\nsame";
sub source_scope (&) {
 LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source, $_[0])
}
sub event {
 my $event = {raw => $source};
 LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event, {
  event => $event, source => $source, source_span => {start => 0, end => length($source)}});
 return $event
}
sub emit {
 my ($event) = @_;
 my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
 LinkedSpec::ActionIR::SourceEmissions::_append_source($builder, 'same', 2, 6);
 return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder)
}
sub factory {
 my $identity = {};
 return sub { ++$identity->{calls}; emit(@_) }
}

my $outside = factory();
is(refaddr(register($outside)), refaddr($outside), 'registration without a scope preserves the actual callback');
producers([], sub {
 register($outside);
 source_scope {
  ok(!capture($outside, event())->{emission}, 'source-less registration grants no later source authority');
 };
});
source_scope {
 my $event = event();
 register($outside);
 producers([], sub {
  ok(!capture($outside, $event)->{emission}, 'registration without a producer scope grants nothing');
  is(refaddr(register($outside)), refaddr($outside), 'actual factory registration preserves the public reference');
  my $selected = capture($outside, $event);
  my $published = packet($selected, $outside, $event);
  is_deeply($published, {text => 'same', fragments => [{kind => 'source',
   output_span => {start => 0, end => 4}, source_span => {start => 2, end => 6}}], consumed => []},
   'actual registered factory callback selects the authored original interval');
  my $fresh = factory();
  my $copy = {lower => $fresh, id => 'same-public-name'};
  ok(!capture($copy->{lower}, $event)->{emission}, 'equal fresh callback and copied metadata have no registration');
  my $retained = {lower => $outside, id => 'same-public-name'};
  ok(packet(capture($retained->{lower}, $event), $outside, $event),
   'retaining the already registered actual callback selects only that callback');
  producers([], sub {
   ok(!capture($outside, $event)->{emission}, 'nested producer scope cannot borrow outer registration');
   register($fresh);
   ok(capture($fresh, $event)->{emission}, 'nested producer scope can register its own actual callback');
  });
  ok(!capture($fresh, $event)->{emission}, 'nested producer registration does not leak into parent');
  ok(packet($selected, $outside, $event), 'outer capture authority restores after nested producer scope');
  my $wrong_source = factory();
  source_scope {
   my $inner = event();
   register($wrong_source);
   ok(!capture($wrong_source, $inner)->{emission}, 'nested source cannot register into an enclosing producer scope');
   producers([], sub {
    register($wrong_source);
    ok(capture($wrong_source, $inner)->{emission}, 'nested source and producer establish their own registration');
   });
  };
  ok(!capture($wrong_source, $event)->{emission}, 'foreign source registration cannot leak into restored outer scope');
  my $fatal = bless {}, 'FactoryCaptureFatal';
  my $nested = factory();
  my $caught;
  eval { producers([], sub { register($nested); die $fatal }); 1 } or $caught = $@;
  is(refaddr($caught), refaddr($fatal), 'fatal nested registration preserves the exact exception object');
  ok(!capture($nested, $event)->{emission}, 'fatal nested registration releases its own authority');
  ok(packet($selected, $outside, $event), 'outer capture authority restores after fatal nested scope');
 });
};
source_scope {
 my $event = event();
 producers([], sub {
  ok(!capture($outside, $event)->{emission}, 'finished invocation leaves no global registration cache');
 });
};

# A dependency may invoke an ordinary producer and return exactly its text.
# Isolation, rather than an output comparison, prevents inherited publication.
source_scope {
 my $event = event();
 for my $context (qw(scalar list void)) {
  my $calls = 0;
  my $opaque = sub { ++$calls; emit($event); return 'same' };
  my $public_dependencies = {lower => $opaque};
  my $public_context = {dependencies => $public_dependencies, event => $event};
  my $outer = sub {
   if ($context eq 'scalar') { my $value = dependency($public_dependencies->{lower}); return $value }
   if ($context eq 'list') { my @values = dependency($public_dependencies->{lower}); return $values[0] }
   dependency($public_dependencies->{lower});
   return 'same'
  };
  producers([], sub {
   register($outer);
   my $result = capture($outer, $event);
   is($result->{value}, 'same', "$context opaque dependency preserves the ordinary equal value");
   ok(!packet($result, $outer, $event), "$context opaque dependency cannot donate nested publication");
   is($calls, 1, "$context opaque dependency executes exactly once");
   is(refaddr($public_dependencies->{lower}), refaddr($opaque), "$context public dependency callback stays actual");
   is(refaddr($public_context->{dependencies}), refaddr($public_dependencies), "$context public context keeps its dependency map");
   is_deeply([sort keys %$public_dependencies], ['lower'], "$context dependency map shape stays unchanged");
  });
 }
 my $child = factory();
 my $child_capture;
 my $outer = sub { $child_capture = capture($child, $event); return $child_capture->{value} };
 producers([], sub {
  register($child); register($outer);
  my $parent_capture = capture($outer, $event);
  ok(packet($child_capture, $child, $event), 'explicit actual child capture retains its own packet');
  ok(!packet($parent_capture, $outer, $event), 'known child packet is not implicitly inherited by parent');
 });
};

# Compare actual guarded calls with the same native callback contract. The trace
# observes context, caller aliases, once-only effects and both error channels.
my $shared = {unchanged => 1};
my $fatal = bless {}, 'FactoryCaptureFatal';
sub exercise {
 my ($guarded, $known, $context, $outcome) = @_;
 my ($first, $last, @trace, @values, $value, $error, $success_error, $success);
 ($first, $last) = ('first', 'last');
 my $callback = sub {
  my $context = !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar';
  push @trace, [$context, $@, $_[0], refaddr($_[1]), $_[2]];
  $_[0] .= '!'; $_[2] .= '?';
  $@ = 'successful callback error';
  die $fatal if $outcome eq 'fatal';
  return $shared if $outcome eq 'reference';
  return undef if $outcome eq 'undefined';
  return ('left', $shared, 'right') if $outcome eq 'values';
  return 'same'
 };
 register($callback) if $known;
 eval {
  $@ = 'incoming callback error';
  if ($context eq 'void') {
   if ($guarded) { dependency($callback, $first, $shared, $last) }
   else { $callback->($first, $shared, $last) }
  } elsif ($context eq 'list') {
   @values = $guarded ? dependency($callback, $first, $shared, $last) : $callback->($first, $shared, $last);
  } else {
   $value = $guarded ? dependency($callback, $first, $shared, $last) : $callback->($first, $shared, $last);
  }
  $success_error = $@;
  $success = 1;
  1
 } or $error = $@;
 return {first => $first, last => $last, trace => \@trace, values => \@values, value => $value,
  success_error => $success_error, success => $success, error => $error}
}
source_scope {
 producers([], sub {
  for my $known (0, 1) {
   for my $context (qw(scalar list void)) {
    for my $outcome (qw(string reference undefined values fatal)) {
     my $label = "$known/$context/$outcome";
     my $native = exercise(0, $known, $context, $outcome);
     my $guarded = exercise(1, $known, $context, $outcome);
     is_deeply($guarded, $native, "$label native differential context aliases effects returns and errors");
     is_deeply([$guarded->{first}, $guarded->{last}], ['first!', 'last?'], "$label both original caller aliases are written");
     is(scalar @{$guarded->{trace}}, 1, "$label actual dependency executes once");
     is($guarded->{trace}[0][0], $context, "$label dependency retains native context");
     is($guarded->{trace}[0][1], 'incoming callback error', "$label callback observes the original error channel");
     if ($outcome eq 'fatal') {
      is(refaddr($guarded->{error}), refaddr($fatal), "$label fatal object identity survives");
     } else {
      is($guarded->{success_error}, 'successful callback error', "$label successful error effect survives");
     }
    }
   }
  }
 });
};

{
 package FactoryCaptureWatch;
 sub DESTROY { push @{$_[0]{log}}, 'released' }
}
my (@release, $weak);
source_scope {
 producers([], sub {
  my $watch = bless {log => \@release}, 'FactoryCaptureWatch';
  my $callback = sub { return $watch };
  $weak = $callback; weaken($weak);
  register($callback);
  undef $callback;
  ok(defined($weak), 'registered actual callback stays strongly retained until scope exit');
  is_deeply(\@release, [], 'registered callback capture has not been destroyed early');
 });
 ok(!defined($weak), 'registered callback releases at producer scope exit');
 is_deeply(\@release, ['released'], 'registered callback lexical state releases exactly once');
};
my (@outside_release, $outside_weak);
{
 my $watch = bless {log => \@outside_release}, 'FactoryCaptureWatch';
 my $callback = sub { return $watch };
 $outside_weak = $callback; weaken($outside_weak);
 register($callback);
 undef $callback;
}
ok(!defined($outside_weak), 'registration outside an eligible scope retains no callback');
is_deeply(\@outside_release, ['released'], 'unregistered callback follows its native lexical lifetime');

done_testing;
