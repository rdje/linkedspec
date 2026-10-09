use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();
use LinkedSpec::ActionIR::AST::Parser ();
use LinkedSpec::ActionIR::MethodExpr ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::Diagnostics ();
use LinkedSpec::ActionIR::CanonicalEvents ();

# This acceptance oracle builds labelled source segments before invoking any
# parser. It never reads public AST spans or searches text for an occurrence.
sub marked {
 my ($label, @pieces) = @_;
 my ($text, %marks) = ('');
 for my $piece (@pieces) {
  if (ref($piece)) {
   my $base = length($text);
   $marks{$_} = [map { $_ + $base } @{$piece->{marks}{$_}}] for keys %{$piece->{marks}};
   $text .= $piece->{text};
  } else { $text .= $piece }
 }
 $marks{$label} = [0, length($text)];
 return {text => $text, marks => \%marks}
}

sub description { LinkedSpec::ActionIR::SourceEmissions::_input_description(@_) }
sub ast_grant { LinkedSpec::ActionIR::SourceEmissions::_ast_input_for(@_) }
sub argument_grant { LinkedSpec::ActionIR::SourceEmissions::_argument_input_for(@_) }
sub scope { LinkedSpec::ActionIR::SourceEmissions::_with_source_inputs(@_) }
my $ast = \&LinkedSpec::ActionIR::AST::Parser::parse_action_expr;
my $method = \&LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr;
my $csv = \&LinkedSpec::ActionIR::MethodExpr::_split_top_level_csv;
my $json = JSON::PP->new->canonical;

sub packet {
 my ($event, $operations, $consume) = @_;
 my $producer = sub {
  my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
  for my $operation (@$operations) {
   LinkedSpec::ActionIR::SourceEmissions::_append_input($builder, @$operation);
  }
  LinkedSpec::ActionIR::SourceEmissions::_consume_input($builder, $_) for @$consume;
  return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder)
 };
 return LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers([$producer], sub {
  my $capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($producer, $event);
  return LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture, $producer, $event)
 })
}

sub labelled_output {
 my ($packet) = @_;
 my (@labels, $next);
 $next = 0;
 for my $fragment (@{$packet->{fragments}}) {
  my ($start, $end) = @{$fragment->{output_span}}{qw(start end)};
  die 'noncontiguous output' unless $start == $next && $end > $start;
  for my $position ($start .. $end - 1) {
   push @labels, [substr($packet->{text}, $position, 1), $fragment->{kind} eq 'source'
    ? $fragment->{source_span}{start} + $position - $start : undef];
  }
  $next = $end;
 }
 die 'incomplete output' unless $next == length($packet->{text});
 return \@labels
}

my @cases = (
 ['number', '7', ', '],
 ['unicode-crlf', '"λ😀"', ",\r\n"],
 ['quoted-comma-empty-slots', '"a,b"', ',,'],
 ['escaped-quote', '"a\\"b"', ', '],
);
my $expired;
for my $case (@cases) {
 my ($name, $atom, $separator) = @$case;
 my $tree = marked('event', 'set(counter, ', marked('outer', 'cat(',
  marked('left', 'trim(', marked('L', $atom), ')'), $separator,
  marked('inner', 'cat(', marked('R0', $atom), $separator, marked('R1', $atom), ')'), ')'), ')');
 my $raw = $tree->{text};
 my $escaped = $raw; $escaped =~ s/([\\"])/\\$1/g;
 my $quoted = 'quoted="λ😀 ' . $escaped . '"';
 my $source = join '; ', $quoted, $raw, $raw;
 my @bases = (length($quoted) + 2, length($quoted) + length($raw) + 4);
 LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source, sub {
  my $scanner = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
  my $canonical = LinkedSpec::ActionIR::CanonicalEvents::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
  my $diagnostic = LinkedSpec::ActionIR::Diagnostics::_collect_action_helper_ir_nodes($source,
   [{id => 'set_value', ir_node => 'SET'}], {scan_contract_ir_events => sub {
    LinkedSpec::ActionIR::Scanner::_scan_executable_contract_ir_events(@_, $scanner)}});
  my $events = LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events(
   'Top', $source, $diagnostic->{helper_action_ir_events}, $canonical)->{canonical_action_ir_events};
  is_deeply([map { $_->{raw} } @$events], [$quoted, $raw, $raw], "$name actual event population excludes quoted executable twin");
  BAIL_OUT('unexpected actual event population') unless @$events == 3;
  scope(sub {
   for my $occurrence (0, 1) {
    my $event = $events->[$occurrence + 1];
    my $before = $json->encode($event);
    my $root = LinkedSpec::ActionIR::SourceEmissions::_event_input_for($event);
    my $a = LinkedSpec::ActionIR::SourceEmissions::_capture_ast_input($root, $ast, $raw, {base_start => 812});
    my $outer = ast_grant($a, $ast, $event, $a->{value}{args}[1]);
    my $outer_text = substr($raw, $tree->{marks}{outer}[0], $tree->{marks}{outer}[1] - $tree->{marks}{outer}[0]);
    my $m = LinkedSpec::ActionIR::SourceEmissions::_capture_method_input($outer, $method, $outer_text);
    my $arguments = $m->{value}{args};
    my $left = argument_grant($m, $method, $event, $arguments, 0);
    my $inner = argument_grant($m, $method, $event, $arguments, 1);
    my $c = LinkedSpec::ActionIR::SourceEmissions::_capture_csv_input($inner, $csv, $arguments->[1]);
    my $csv_inner = argument_grant($c, $csv, $event, $c->{value}, 0);
    my $b = LinkedSpec::ActionIR::SourceEmissions::_capture_ast_input($csv_inner, $ast, $c->{value}[0]);
    my $r0 = ast_grant($b, $ast, $event, $b->{value}{args}[0]);
    my $r1 = ast_grant($b, $ast, $event, $b->{value}{args}[1]);
    my $l = LinkedSpec::ActionIR::SourceEmissions::_capture_ast_input($left, $ast, $arguments->[0]);
    my $lg = ast_grant($l, $ast, $event, $l->{value}{args}[0]);
    my @selected = (['event', $root], ['outer', $outer], ['left', $left], ['inner', $inner],
                    ['inner', $csv_inner], ['L', $lg], ['R0', $r0], ['R1', $r1]);
    my @wanted = map {
     my ($start, $end) = @{$tree->{marks}{$_->[0]}};
     {source => $source, raw => substr($raw, $start, $end - $start),
      source_span => {start => $bases[$occurrence] + $start, end => $bases[$occurrence] + $end}}
    } @selected;
    is_deeply([map {description($_->[1])} @selected], \@wanted,
     "$name/$occurrence complete independently labelled cross-capture frame population");
    my $result = packet($event, [[$atom, $r1], [$atom, undef], [$atom, $lg], [$atom, $lg], ['!'.$atom, $r0]], [$r0]);
    my @wanted_output;
    for my $label ('R1', undef, 'L', 'L', 'transformed') {
     my $text = defined($label) && $label eq 'transformed' ? '!'.$atom : $atom;
     my $start = defined($label) && $label ne 'transformed' ? $bases[$occurrence] + $tree->{marks}{$label}[0] : undef;
     push @wanted_output, map {[substr($text, $_, 1), defined($start) ? $start + $_ : undef]} 0 .. length($text) - 1;
    }
    is_deeply(labelled_output($result), \@wanted_output, "$name/$occurrence independent output character and occurrence ledger");
    is_deeply($result->{consumed}, [{source_span => {
     start => $bases[$occurrence] + $tree->{marks}{R0}[0], end => $bases[$occurrence] + $tree->{marks}{R0}[1]}}],
     "$name/$occurrence exact deep child consumption ledger");
    my $copy = {%$event}; LinkedSpec::ActionIR::SourceOrigins::_copy_source_origin($event, $copy);
    ok(LinkedSpec::ActionIR::SourceEmissions::_event_input_for($copy), "$name/$occurrence actual event copy gets its own root");
    is(ast_grant($a, $ast, $copy, $a->{value}), undef, "$name/$occurrence copied event cannot select original capture");
    my $foreign = packet($copy, [[$atom, $r1]], [$r1]);
    is_deeply(labelled_output($foreign), [map {[substr($atom, $_, 1), undef]} 0 .. length($atom) - 1],
     "$name/$occurrence equal-coordinate foreign event remains generated");
    is_deeply($foreign->{consumed}, [], "$name/$occurrence foreign event consumes nothing");
    my $old = $arguments->[0]; $arguments->[0] = 'changed';
    is(description($lg), undef, "$name/$occurrence delayed ancestor mutation revokes descendant");
    is_deeply(description($r1), $wanted[-1], "$name/$occurrence unrelated occurrence stays valid");
    $arguments->[0] = $old;
    push @{$c->{value}}, 'extra';
    is(description($r1), undef, "$name/$occurrence delayed CSV shape mutation revokes deep descendant");
    pop @{$c->{value}};
    my $failure = bless {}, 'InputComposition::Failure';
    eval {scope(sub {is(description($r1), undef, "$name/$occurrence nested registry isolates retained input"); die $failure})};
    is(refaddr($@), refaddr($failure), "$name/$occurrence fatal nested scope preserves object");
    is_deeply(description($r1), $wanted[-1], "$name/$occurrence complete parent chain restored after nested failure");
    is($json->encode($event), $before, "$name/$occurrence actual public event unchanged");
    $expired = $r1;
   }
  });
 });
 is(description($expired), undef, "$name expired composed input loses authority");
}

# Compare observable callback behavior against the existing native captures,
# independently of any particular internal forwarding implementation.
my @drops;
{ package InputComposition::Opaque; sub DESTROY {push @drops, 'drop'} }
my $text = 'cat(same, same)';
LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($text, sub {
 my $event = {raw => $text};
 LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
  {event => $event, source => $text, source_span => {start => 0, end => length($text)}});
 scope(sub {
  my $root = LinkedSpec::ActionIR::SourceEmissions::_event_input_for($event);
  for my $mode ('ast', 'method', 'csv') {
   my $parser = $mode eq 'ast' ? $ast : $mode eq 'method' ? $method : $csv;
   my $native = $mode eq 'ast' ? \&LinkedSpec::ActionIR::AST::Parser::_capture_node_constructions
    : $mode eq 'method' ? \&LinkedSpec::ActionIR::MethodExpr::_capture_method_input
    : \&LinkedSpec::ActionIR::MethodExpr::_capture_csv_input;
   my $joined = $mode eq 'ast' ? \&LinkedSpec::ActionIR::SourceEmissions::_capture_ast_input
    : $mode eq 'method' ? \&LinkedSpec::ActionIR::SourceEmissions::_capture_method_input
    : \&LinkedSpec::ActionIR::SourceEmissions::_capture_csv_input;
   for my $fatal (0, 1) {
    my @observations;
    my $failure = bless {}, 'InputComposition::CallbackFailure';
    for my $which ('native', 'joined') {
     my (@trace, $returned, $value);
     my ($input, $tail, $reference) = ($text, 'before', {});
     my $callback = sub {
      push @trace, ['call', defined(wantarray) ? wantarray ? 'list' : 'scalar' : 'void', refaddr($_[1]) == refaddr($reference)];
      $_[2] = 'after';
      die $failure if $fatal;
      $returned = $parser->($_[0]);
      return $returned
     };
     $@ = 'caller';
     if ($fatal) {
      eval { $value = $which eq 'native' ? $native->($callback, $input, $reference, $tail)
                                       : $joined->($root, $callback, $input, $reference, $tail) };
     } else {
      $value = $which eq 'native' ? $native->($callback, $input, $reference, $tail)
                                : $joined->($root, $callback, $input, $reference, $tail);
     }
     my $error = $@;
     push @observations, {trace => \@trace, input => $input, tail => $tail,
      fatal => $fatal ? refaddr($error) == refaddr($failure) : $error,
      returned => $fatal ? undef : refaddr($value->{value}) == refaddr($returned)};
    }
    is_deeply($observations[1], $observations[0], "$mode/$fatal native and joined context aliases effects return and fatal identity agree");
    is_deeply($observations[1]{trace}, [['call', 'scalar', 1]], "$mode/$fatal actual joined callback executes once in scalar context");
    is($observations[1]{tail}, 'after', "$mode/$fatal actual joined caller alias is written");
   }
  }
  my @release;
  for my $which ('native', 'joined') {
   @drops = ();
   {
    my $callback = sub {push @drops, 'call'; return bless {}, 'InputComposition::Opaque'};
    my $capture = $which eq 'native'
     ? LinkedSpec::ActionIR::AST::Parser::_capture_node_constructions($callback, $text)
     : LinkedSpec::ActionIR::SourceEmissions::_capture_ast_input($root, $callback, $text);
   }
   push @release, [@drops];
  }
  is_deeply($release[1], $release[0], 'joined opaque destructor timing agrees with native inside active scope');
  is_deeply($release[1], ['call', 'drop'], 'opaque destructor has executed before scope exit');
 });
});

done_testing;
