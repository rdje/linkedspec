use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw(refaddr weaken);
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

my $package = 'LinkedSpec::ActionIR::SourceEmissions';
my @api = qw(_with_source_inputs _event_input_for _input_description
 _capture_ast_input _capture_method_input _capture_csv_input
 _ast_input_for _argument_input_for _append_input _consume_input);
ok(!grep(!$package->can($_), @api), 'original-event input grant interface available');
BAIL_OUT('original-event input grant interface unavailable') if grep !$package->can($_), @api;

sub scope { LinkedSpec::ActionIR::SourceEmissions::_with_source_inputs(@_) }
sub root { LinkedSpec::ActionIR::SourceEmissions::_event_input_for(@_) }
sub describe { LinkedSpec::ActionIR::SourceEmissions::_input_description(@_) }
sub ast_capture { LinkedSpec::ActionIR::SourceEmissions::_capture_ast_input(@_) }
sub method_capture { LinkedSpec::ActionIR::SourceEmissions::_capture_method_input(@_) }
sub csv_capture { LinkedSpec::ActionIR::SourceEmissions::_capture_csv_input(@_) }
sub ast_input { LinkedSpec::ActionIR::SourceEmissions::_ast_input_for(@_) }
sub argument { LinkedSpec::ActionIR::SourceEmissions::_argument_input_for(@_) }
my $parse = \&LinkedSpec::ActionIR::AST::Parser::parse_action_expr;
my $method = \&LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr;
my $csv = \&LinkedSpec::ActionIR::MethodExpr::_split_top_level_csv;

sub with_event {
 my ($raw, $work) = @_;
 my $prefix = "λ😀\r\n";
 my $source = $prefix . $raw . '終';
 LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source, sub {
  my $event = {raw => $raw};
  LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event, {
   event => $event, source => $source,
   source_span => {start => length($prefix), end => length($prefix) + length($raw)}});
  scope(sub { $work->($event, $source, length($prefix)) });
 });
}

sub expected {
 my ($source, $raw, $start) = @_;
 return {source => $source, raw => $raw, source_span => {start => $start, end => $start + length($raw)}}
}

# The authored segment boundaries choose occurrences; parser offsets/searches
# and descriptive metadata do not participate in the independent oracle.
my @cases = (
 ['twins', ['cat(', 'trim(capture_slice())', ', ', 'trim(capture_slice())', ')'], [1,3]],
 ['unicode', ['cat(', '"λ😀"', ', ', '"λ😀"', ')'], [1,3]],
 ['crlf', [" \r\n cat(\r\n", 'trim(capture_slice())', ",\r\n", 'trim(capture_slice())', "\r\n) \r\n"], [1,3]],
 ['empty-slots', ['cat(,', 'trim(capture_slice())', ',,', 'trim(capture_slice())', ',)'], [1,3]],
 ['array', ['[', '"λ😀"', ', ', 'trim(capture_slice())', ']'], [1,3]],
);
for my $case (@cases) {
 my ($name, $pieces, $indices) = @$case;
 my $raw = join '', @$pieces;
 my @bounds = (0);
 push @bounds, $bounds[-1] + length($_) for @$pieces;
 my $ordinary = $parse->($raw, {base_start => 900});
 with_event($raw, sub {
  my ($event, $source, $base) = @_;
  my $event_before = JSON::PP->new->canonical->encode($event);
  my $parent = root($event);
  is_deeply(describe($parent), expected($source, $raw, $base), "$name selected event root");
  my $capture = ast_capture($parent, $parse, $raw, {base_start => 900});
  my $node = $capture->{value};
  is_deeply($node, $ordinary, "$name public AST stays unchanged");
  my $nodes = $name eq 'array' ? $node->{items} : $node->{args};
  my @grants;
  for my $i (0,1) {
   my $piece = $indices->[$i];
   my $grant = ast_input($capture, $parse, $event, $nodes->[$i]);
   push @grants, $grant;
   is_deeply(describe($grant), expected($source, $pieces->[$piece], $base + $bounds[$piece]),
    "$name actual AST argument joins original event interval");
  }
  if ($name ne 'array') {
   my $captured = method_capture($parent, $method, $raw);
   my $arguments = $captured->{value}{args};
   for my $i (0,1) {
    my $piece = $indices->[$i];
    is_deeply(describe(argument($captured, $method, $event, $arguments, $i)),
     expected($source, $pieces->[$piece], $base + $bounds[$piece]),
     "$name actual MethodExpr occurrence joins original event interval");
   }
  }
  if ($name eq 'twins') {
   my $child = ast_capture($grants[0], $parse, $pieces->[$indices->[0]]);
   is_deeply(describe(ast_input($child, $parse, $event, $child->{value}{args}[0])),
    expected($source, 'capture_slice()', $base + $bounds[1] + length('trim(')),
    'actual child capture rebases through its explicit parent frame');
   my $captured = csv_capture($grants[1], $csv, $pieces->[$indices->[1]]);
   is_deeply(describe(argument($captured, $csv, $event, $captured->{value}, 0)),
    expected($source, $pieces->[3], $base + $bounds[3]), 'actual CSV capture uses selected child frame');
  }

  my $first = $pieces->[$indices->[0]];
  my $second = $pieces->[$indices->[1]];
  my $producer = sub {
   my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
   LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, $first);
   LinkedSpec::ActionIR::SourceEmissions::_append_input($builder, $second, $grants[1]);
   LinkedSpec::ActionIR::SourceEmissions::_append_input($builder, $first, $grants[0]) for 1..2;
   LinkedSpec::ActionIR::SourceEmissions::_append_input($builder, '!'.$first, $grants[0]);
   LinkedSpec::ActionIR::SourceEmissions::_consume_input($builder, $grants[0]);
   return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder)
  };
  LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers([$producer], sub {
   my $result = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($producer, $event);
   my $packet = LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $producer, $event);
   ok($packet, "$name actual known producer gets an input-bound packet");
   my (@wanted, @actual);
   for my $operation (['generated',$first], ['source',$second,$base+$bounds[$indices->[1]]],
                       ['source',$first,$base+$bounds[$indices->[0]]],
                       ['source',$first,$base+$bounds[$indices->[0]]], ['generated','!'.$first]) {
    my ($kind,$text,$start) = @$operation;
    push @wanted, map { [substr($text,$_,1), $kind eq 'source' ? $start+$_ : undef] } 0..length($text)-1;
   }
   my $next = 0;
   for my $fragment (@{$packet->{fragments}}) {
    my ($a,$z) = @{$fragment->{output_span}}{qw(start end)};
    is($a,$next,"$name fragment starts at actual append boundary");
    push @actual, map { [substr($packet->{text},$_,1), $fragment->{kind} eq 'source'
     ? $fragment->{source_span}{start}+$_-$a : undef] } $a..$z-1;
    $next = $z;
   }
   is($next,length($packet->{text}),"$name complete fragment coverage");
   is_deeply(\@actual,\@wanted,"$name independent per-character original occurrence oracle");
   is_deeply($packet->{consumed},[{source_span=>{start=>$base+$bounds[$indices->[0]],end=>$base+$bounds[$indices->[0]+1]}}],
    "$name only actual selected child consumed");
  });
  is(JSON::PP->new->canonical->encode($event),$event_before,"$name public event stays unchanged");
 });
}

with_event('cat("λ😀", "λ😀")', sub {
 my ($event,$source,$base)=@_;
 my $parent=root($event);
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::AST::Parser::_find_piece_offset = sub {0};
 my $capture=ast_capture($parent,$parse,$event->{raw});
 my ($first,$second)=@{$capture->{value}{args}};
 is($first->{source_span}{start},$second->{source_span}{start},'wrong public search collapses public twins');
 is_deeply(describe(ast_input($capture,$parse,$event,$first)),expected($source,'"λ😀"',$base+length('cat(')),
  'first grant ignores wrong public search');
 is_deeply(describe(ast_input($capture,$parse,$event,$second)),expected($source,'"λ😀"',$base+length('cat("λ😀", ')),
  'second grant follows actual CSV occurrence despite wrong public search');
});

my ($expired,$expired_capture,$expired_node,$expired_event);
with_event('cat("a", "a")',sub {
 my ($event,$source,$base)=@_;
 my $parent=root($event);
 my $capture=ast_capture($parent,$parse,$event->{raw});
 my $node=$capture->{value};
 my $grant=ast_input($capture,$parse,$event,$node->{args}[0]);
 my $wanted=expected($source,'"a"',$base+4);
 my $description=describe($grant); $description->{source_span}{start}=999;
 is_deeply(describe($grant),$wanted,'grant description is detached');
 is(describe($description),undef,'description cannot borrow actual grant identity');
 my $scalar=$$grant; my $copy=bless \$scalar,ref($grant);
 is(describe($copy),undef,'copied opaque grant denied');
 is(ast_input({%$capture},$parse,$event,$node),undef,'copied outer capture denied');
 is(ast_input($capture,sub {$parse->(@_)},$event,$node),undef,'foreign callback denied');
 is(ast_input($capture,$parse,$event,{%$node}),undef,'copied node denied');
 my $event_copy={%$event};
 LinkedSpec::ActionIR::SourceOrigins::_copy_source_origin($event,$event_copy);
 ok(root($event_copy),'a real origin transfer can establish its own distinct event root');
 is(ast_input($capture,$parse,$event_copy,$node),undef,'copied event cannot borrow another event capture');
 is(root({%$event}),undef,'equal event without origin transfer denied');
 my $saved=$capture->{value}; $capture->{value}={%$node};
 is(describe($grant),undef,'changed capture return revokes an already selected grant');
 $capture->{value}=$saved;
 $node->{args}[1]{value}='changed';
 is(describe($grant),undef,'changed AST ancestor revokes an already selected grant');
 $node->{args}[1]{value}='a';
 is_deeply(describe($grant),$wanted,'restored actual AST recovers its original interval');
 scope(sub {is(describe($grant),undef,'nested input scope cannot borrow outer grant')});
 is_deeply(describe($grant),$wanted,'outer grant restored after nested input scope');
 LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source,sub {
  is(describe($grant),undef,'equal-source nested invocation cannot borrow grant');
  is(root($event),undef,'old event unavailable in distinct source invocation');
 });
 is_deeply(describe($grant),$wanted,'outer grant restored after equal-source invocation');
 my $original=$event->{raw}; $event->{raw}.='!';
 is(describe($grant),undef,'changed selected event revokes grant'); $event->{raw}=$original;
 my $failure=bless {},'EventInput::Failure';
 eval {scope(sub {die $failure})};
 is(refaddr($@),refaddr($failure),'fatal nested input scope preserves exception identity');
 is_deeply(describe($grant),$wanted,'outer grant restored after fatal input scope');
 ($expired,$expired_capture,$expired_node,$expired_event)=($grant,$capture,$node,$event);
});
is(describe($expired),undef,'expired grant has no original authority');
is(ast_input($expired_capture,$parse,$expired_event,$expired_node),undef,'expired capture cannot mint grants');

with_event('call(same, same)',sub {
 my ($event,$source,$base)=@_;
 my $capture=method_capture(root($event),$method,$event->{raw});
 my $args=$capture->{value}{args};
 my $first=argument($capture,$method,$event,$args,0);
 my $second=argument($capture,$method,$event,$args,1);
 is(argument($capture,$method,$event,[@$args],0),undef,'copied argument array denied');
 for my $index (-1,2,'x','0.5',undef) {is(argument($capture,$method,$event,$args,$index),undef,'invalid occurrence index denied')}
 $args->[0]='changed';
 is(describe($first),undef,'changed indexed value revokes its existing grant');
 is_deeply(describe($second),expected($source,'same',$base+length('call(same, ')),
  'unchanged neighbor retains its existing actual occurrence');
 $args->[0]='same'; push @$args,'extra';
 is(describe($second),undef,'changed argument shape revokes grants'); pop @$args;
 my $saved=$capture->{value}{source_method}; $capture->{value}{source_method}='changed';
 is(describe($second),undef,'changed MethodExpr root revokes grants'); $capture->{value}{source_method}=$saved;
 my $child=ast_capture($first,$parse,$args->[0]);
 my $descendant=ast_input($child,$parse,$event,$child->{value});
 ok($descendant,'actual AST capture can descend from an actual MethodExpr argument grant');
 $args->[0]='changed';
 is(describe($descendant),undef,'changed retained parent revokes its descendant grant');
});

for my $raw ('', '  ', "\r\n", " \r\n\t\x{2003}") {
 with_event($raw,sub {
  my ($event,$source,$base)=@_;
  my $capture=ast_capture(root($event),$parse,$raw,{base_start=>7});
  is_deeply(describe(ast_input($capture,$parse,$event,$capture->{value})),
   expected($source,'',$base+length($raw)),'empty grant is ordered after original leading whitespace');
 });
}
with_event('items.count()',sub {
 my ($event)=@_; my $capture=ast_capture(root($event),$parse,$event->{raw});
 ok(ast_input($capture,$parse,$event,$capture->{value}),'unsupported descendant route retains explicit root');
 is(ast_input($capture,$parse,$event,$capture->{value}{receiver}),undef,'unsupported descendant route declines');
});

for my $mode ('ast','method','csv') {
 with_event('call(same, same)',sub {
  my ($event)=@_; my $parent=root($event); my ($calls,$context,$returned)=(0);
  my ($source,$tail)=($event->{raw},'tail'); my $reference={};
  my $producer=$mode eq 'ast' ? $parse : $mode eq 'method' ? $method : $csv;
  my $capture=$mode eq 'ast' ? \&ast_capture : $mode eq 'method' ? \&method_capture : \&csv_capture;
  my $callback=sub {
   ++$calls; $context=wantarray;
   is(refaddr($_[1]),refaddr($reference),'actual callback reference identity '.$mode);
   $_[2]='written'; $@='inner channel';
   $returned=$producer->($_[0]); return $returned
  };
  $@='caller channel';
  my $result=$capture->($parent,$callback,$source,$reference,$tail); my $error=$@;
  is($calls,1,'actual callback called once '.$mode);
  ok(defined($context) && !$context,'actual callback called in scalar context '.$mode);
  is(refaddr($result->{value}),refaddr($returned),'actual callback result reference unchanged '.$mode);
  is($tail,'written','extra scalar alias preserved '.$mode);
  is($error,'caller channel','existing native capture caller-error contract preserved '.$mode);
  my $failure=bless {},'EventInput::CallbackFailure';
  eval {$capture->($parent,sub {die $failure},$source)};
  is(refaddr($@),refaddr($failure),'actual callback fatal identity preserved '.$mode);
  my $opaque={opaque=>1}; my $plain=$capture->(undef,sub {$opaque},$source);
  is(refaddr($plain->{value}),refaddr($opaque),'opaque callback result preserved without parent '.$mode);
 });
}

my $weak_node;
with_event('cat("a", "a")',sub {
 my ($event)=@_; my $capture=ast_capture(root($event),$parse,$event->{raw});
 $weak_node=$capture->{value}; weaken($weak_node);
 ok($weak_node,'actual construction remains live within its owning scope');
});
ok(!$weak_node,'input registry releases constructed values after scope exit');
my @contexts;
scope(sub {push @contexts,defined(wantarray) ? wantarray ? 'list':'scalar':'void'});
my $scalar=scope(sub {push @contexts,defined(wantarray) ? wantarray ? 'list':'scalar':'void';7});
my @list=scope(sub {push @contexts,defined(wantarray) ? wantarray ? 'list':'scalar':'void';(7,8)});
is_deeply(\@contexts,['void','scalar','list'],'input scope preserves work context');
is($scalar,7,'input scope scalar value'); is_deeply(\@list,[7,8],'input scope list values');

# Exercise actual scanner/diagnostic/canonical copy seams in addition to authored
# origin controls. No copied public field is treated as original authority.
my @segments=('quoted="set(counter,2)"','set(counter,2)','set(counter,2)');
my $source=join('; ',@segments);
my @starts=(0,length($segments[0])+2,length($segments[0])+length($segments[1])+4);
LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source,sub {
 my $scanner=LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
 my $canonical=LinkedSpec::ActionIR::CanonicalEvents::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
 my $diag=LinkedSpec::ActionIR::Diagnostics::_collect_action_helper_ir_nodes($source,[{id=>'set_value',ir_node=>'SET'}],{
  scan_contract_ir_events=>sub {LinkedSpec::ActionIR::Scanner::_scan_executable_contract_ir_events(@_,$scanner)}});
 my $events=LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events('Top',$source,$diag->{helper_action_ir_events},$canonical)->{canonical_action_ir_events};
 is_deeply([map {$_->{raw}} @$events],\@segments,'actual canonical order and quoted/raw selection unchanged');
 scope(sub {
  for my $index (1,2) {
   my $event=$events->[$index]; my $capture=ast_capture(root($event),$parse,$event->{raw});
   is_deeply(describe(ast_input($capture,$parse,$event,$capture->{value}{args}[1])),
    expected($source,'2',$starts[$index]+length('set(counter,')),
    'actual selected canonical event joins its own repeated original occurrence');
  }
 });
});

done_testing;
