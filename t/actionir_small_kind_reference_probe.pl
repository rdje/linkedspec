package SmallKindReferenceProbe;
use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();
{
 package SmallKindReferenceProbe::Name;
 use overload '""' => sub { ++$_[0]{coercions}; return 'item' }, fallback => 1;
}
{
 package SmallKindReferenceProbe::Map;
 sub TIEHASH { bless {actual => $_[1], fetches => $_[2], count => 0}, $_[0] }
 sub FETCH {
  push @{$_[0]{fetches}}, $_[1];
  return undef unless $_[1] eq 'bare_symbol_kind';
  return ++$_[0]{count} == 1 ? $_[0]{actual} : 'LinkedSpec::ActionIR::MethodLowering::small_kind_reference';
 }
}
my @rows;
for my $outcome (qw(string effect undefined fatal symbolic)) {
 for my $known (0, 1) {
  LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', sub {
   my $event = {raw => 'same'};
   LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
    {event => $event, source => 'same', source_span => {start => 0, end => 4}});
   my $input = bless {coercions => 0, marker => 'original'}, 'SmallKindReferenceProbe::Name';
   my $fatal = bless {}, 'SmallKindReferenceFatal';
   my (@trace, @eligible, @fetches);
   my $actual = sub {
    push @trace, {type => ref($_[0]), actual_input => ref($_[0]) && refaddr($_[0]) == refaddr($input) ? 1 : 0,
     context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', incoming_error => $@};
    push @eligible, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    $_[0]{marker} = 'changed' if $outcome eq 'effect';
    $@ = 'successful reference kind';
    die $fatal if $outcome eq 'fatal';
    return undef if $outcome eq 'undefined';
    my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
    LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, '1');
    LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
    return 'scalar';
   };
   no warnings qw(redefine once);
   local *LinkedSpec::ActionIR::MethodLowering::small_kind_reference = $actual;
   my %deps = (bare_symbol_kind => $actual);
   tie %deps, 'SmallKindReferenceProbe::Map', $actual, \@fetches if $outcome eq 'symbolic';
   my $outer = sub { return LinkedSpec::ActionIR::MethodLowering::_codeblock_variable_call_candidate(\%deps, $input) };
   LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer, $actual] : [$outer], sub {
    my ($capture, $error, $success_error);
    eval { $@ = 'incoming reference kind'; $capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
     $success_error = $@; 1 } or $error = $@;
    push @rows, {outcome => $outcome, known => $known, value => $capture ? $capture->{value} : undef,
     error => ref($error) ? {type => ref($error), same_fatal => refaddr($error) == refaddr($fatal) ? 1 : 0} : $error,
     success_error => $success_error, input => {%$input}, trace => \@trace, eligible => \@eligible,
     fetches => \@fetches, parent_packet => $capture &&
      LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture, $outer, $event) ? 1 : 0};
   });
  });
 }
}
print JSON::PP->new->canonical->encode({rows => \@rows}), "\n";
