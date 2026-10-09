use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::SourceOrigins ();

my $loaded = eval { require LinkedSpec::ActionIR::SourceEmissions; 1 };
ok($loaded, 'private emission foundation is available');
if (!$loaded) { diag($@); done_testing; exit 1 }

sub origins (&) {
 $main::source = join '', ('λ😀', 'capture_slice()', ' / ', 'capture_slice()', "\r\n", 'entry_group(0)', '終');
 LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($main::source, $_[0])
}
sub producers { LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers(@_) }
sub capture { LinkedSpec::ActionIR::SourceEmissions::_capture_emission(@_) }
sub packet { LinkedSpec::ActionIR::SourceEmissions::_emission_for(@_) }
sub builder { LinkedSpec::ActionIR::SourceEmissions::_new_builder(@_) }
sub generated { LinkedSpec::ActionIR::SourceEmissions::_append_generated(@_) }
sub copied { LinkedSpec::ActionIR::SourceEmissions::_append_source(@_) }
sub consumed { LinkedSpec::ActionIR::SourceEmissions::_consume_source(@_) }
sub finish { LinkedSpec::ActionIR::SourceEmissions::_finish_emission(@_) }

# The authored pieces define occurrence coordinates by accumulation, never by
# searching equal source text. Each character has an independent source label.
our $source;
my (@pieces, @bounds, @events);
sub authored {
 @pieces = ('λ😀', 'capture_slice()', ' / ', 'capture_slice()', "\r\n", 'entry_group(0)', '終');
 $source = join '', @pieces;
 @bounds = (0);
 push @bounds, $bounds[-1] + length($_) for @pieces;
 @events = ({raw => $source});
 LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($events[0], {
  event => $events[0], source => $source, source_span => {start => 0, end => length($source)}});
 for my $i (0 .. $#pieces) {
  my $e = {raw => $pieces[$i]};
  LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($e, {
   event => $e, source => $source, source_span => {start => $bounds[$i], end => $bounds[$i+1]}});
  push @events, $e;
 }
 return $events[0]
}

sub construction {
 my ($e) = @_;
 my $b = builder($e);
 generated($b, 'capture_slice():'); # equal generated spelling has no origin
 copied($b, $pieces[1], $bounds[1], $bounds[2]);
 generated($b, '|');
 copied($b, $pieces[3], $bounds[3], $bounds[4]);
 copied($b, $pieces[4], $bounds[4], $bounds[5]);
 copied($b, $pieces[0], $bounds[0], $bounds[1]);
 consumed($b, $events[6]);
 return finish($b)
}

# Labelled-character oracle follows authored operations independently of packet
# construction. It compares every scalar and coordinate, including duplicate
# source copies, non-ASCII scalars and CRLF as two distinct characters.
sub oracle {
 my ($p) = @_;
 my (@expected, @actual);
 for my $op (['g', 'capture_slice():'], ['s', 1], ['g', '|'], ['s', 3], ['s', 4], ['s', 0]) {
  if ($op->[0] eq 'g') { push @expected, map { [$_, undef] } split //, $op->[1] }
  else {
   my $i = $op->[1];
   push @expected, map { [substr($source, $_, 1), $_] } $bounds[$i] .. $bounds[$i+1]-1;
  }
 }
 my $next = 0;
 for my $f (@{$p->{fragments}}) {
  my ($a, $z) = @{$f->{output_span}}{qw(start end)};
  is($a, $next, 'fragment starts at exact append boundary');
  for my $i ($a .. $z-1) {
   push @actual, [substr($p->{text}, $i, 1),
    $f->{kind} eq 'source' ? $f->{source_span}{start} + $i - $a : undef];
  }
  $next = $z;
 }
 is($next, length($p->{text}), 'complete output coverage');
 is_deeply(\@actual, \@expected, 'independent character/occurrence oracle');
 is_deeply($p->{consumed}, [{source_span => {start => $bounds[5], end => $bounds[6]}}],
  'only the independently authored consumed occurrence');
}

$source = '';
origins {
 my $root = authored();
 my $callback = \&construction;
 producers([$callback], sub {
  my $result = capture($callback, $root);
  my $p = packet($result, $callback, $root);
  ok($p, 'actual known producer publishes a packet');
  oracle($p);
  is($result->{value}, $p->{text}, 'ordinary scalar output preserved');
  is_deeply([sort keys %$root], ['raw'], 'public event shape unchanged');
  $p->{fragments}[0]{kind} = 'source';
  is(packet($result, $callback, $root)->{fragments}[0]{kind}, 'generated', 'retrieval is detached');
  $result->{emission}{text} = 'forged';
  is(packet($result, $callback, $root)->{text}, $result->{value}, 'descriptive packet is not authority');
  ok(!packet({%$result}, $callback, $root), 'copied capture cannot borrow identity');
  ok(!packet($result, sub { construction(@_) }, $root), 'foreign callback denied');
  my $copied_event = {%$root};
  LinkedSpec::ActionIR::SourceOrigins::_copy_source_origin($root, $copied_event);
  ok(!packet($result, $callback, $copied_event), 'copied event denied even with a valid original frame');
  my $saved = $result->{value};
  $result->{value} .= '!';
  ok(!packet($result, $callback, $root), 'changed result denied');
  $result->{value} = $saved;
  my $foreign = {raw => $source};
  ok(!capture($callback, $foreign)->{emission}, 'equal foreign event has no original frame');
  my $outer_token = LinkedSpec::ActionIR::SourceOrigins::_invocation_token();
  LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source, sub {
   isnt(refaddr(LinkedSpec::ActionIR::SourceOrigins::_invocation_token()), refaddr($outer_token),
    'equal source gets distinct invocation identity');
   ok(!packet($result, $callback, $root), 'nested source cannot borrow capture');
   my $inner = authored();
   ok(!capture($callback, $inner)->{emission}, 'nested source cannot borrow producer registration');
   producers([$callback], sub {
    ok(capture($callback, $inner)->{emission}, 'nested source can establish its own actual producer authority');
   });
  });
  ok(packet($result, $callback, $root), 'outer authority restored after nested source');
  producers([$callback], sub { ok(!packet($result, $callback, $root), 'nested producer scope cannot borrow capture') });
  ok(packet($result, $callback, $root), 'outer authority restored after nested producer scope');
 });
};

$source = '';
origins {
 my $root = authored();
 my $builtin = \&construction;
 my $custom = sub { construction(@_); return 'capture_slice():' . $pieces[1] . '|' . $pieces[3] . $pieces[4] . $pieces[0] };
 producers([$builtin], sub {
  my $opaque = capture($custom, $root);
  is($opaque->{value}, construction($root), 'custom equal output preserved');
  ok(!$opaque->{emission}, 'custom calling built-in cannot inherit equal-output packet');
 });
 my $silent = sub { return $source };
 producers([$silent], sub { ok(!capture($silent, $root)->{emission}, 'known opaque result denied without explicit publication') });
 for my $value (undef, {}, [], \$source) {
  my $opaque = sub { return $value };
  producers([$opaque], sub {
   my $r = capture($opaque, $root);
   defined($value) ? is(refaddr($r->{value}), refaddr($value), 'opaque reference identity preserved')
                   : is($r->{value}, undef, 'undefined return preserved');
   ok(!$r->{emission}, 'opaque object or undefined return carries no packet');
  });
 }
 my $multiple = sub { my $a=builder($_[0]); generated($a,'same'); finish($a); my $b=builder($_[0]); generated($b,'same'); return finish($b) };
 producers([$multiple], sub { ok(!capture($multiple,$root)->{emission}, 'multiple equal publications are ambiguous') });
 my $changed = sub { my $b=builder($_[0]); generated($b,'same'); finish($b); $$b='other'; return 'same' };
 producers([$changed], sub { ok(!capture($changed,$root)->{emission}, 'changed builder denied after publication') });
 my $transformed = sub { my $b=builder($_[0]); copied($b,uc($pieces[0]),$bounds[0],$bounds[1]); copied($b,$pieces[1],-1,$bounds[2]); return finish($b) };
 producers([$transformed], sub {
  my $p = capture($transformed,$root)->{emission};
  is_deeply([map { $_->{kind} } @{$p->{fragments}}], ['generated','generated'], 'transformed and out-of-frame pieces are generated');
 });
 my $duplicate = sub { my $b=builder($_[0]); copied($b,$pieces[1],$bounds[1],$bounds[2]) for 1..2; return finish($b) };
 producers([$duplicate], sub {
  my $p = capture($duplicate,$root)->{emission};
  is_deeply([map { $_->{source_span} } @{$p->{fragments}}],
   [{start=>$bounds[1],end=>$bounds[2]}, {start=>$bounds[1],end=>$bounds[2]}], 'duplicate copies remain explicit for later ambiguity rejection');
 });
 my $foreign_builder = builder($root);
 my $reuse = sub { generated($foreign_builder,'opaque'); return finish($foreign_builder) };
 producers([$reuse], sub { ok(!capture($reuse,$root)->{emission}, 'builder created outside capture cannot acquire authority') });
 my $copy_builder = sub { my $b=builder($_[0]); generated($b,'copy'); my $text=$$b; my $copy=bless \$text, ref($b); return finish($copy) };
 producers([$copy_builder], sub { ok(!capture($copy_builder,$root)->{emission}, 'copied builder denied') });
};

$source = '';
origins {
 my $root=authored();
 my ($calls,$context,$reference)=(0,undef,{});
 my $effect=sub { ++$calls; $context=wantarray; is(refaddr($_[1]),refaddr($reference),'reference argument identity'); $_[2]='written'; $@='callback channel'; return 'value' };
 producers([$effect],sub {
  my $alias='original';
  my $result=capture($effect,$root,$reference,$alias);
  is($@,'callback channel','callback error channel preserved');
  is($result->{value},'value','scalar return preserved');
  is($alias,'written','scalar argument alias preserved');
  ok(defined($context) && !$context,'callback called in scalar context');
  is($calls,1,'exactly one callback invocation');
 });
 my $error={tag=>'fatal'};
 my $fatal=sub { die $error };
 producers([$fatal,\&construction],sub {
  eval { capture($fatal,$root) };
  is(refaddr($@),refaddr($error),'fatal exception object unchanged');
  ok(capture(\&construction,$root)->{emission},'scope usable after callback exception');
  my $token = LinkedSpec::ActionIR::SourceOrigins::_invocation_token();
  eval { LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source, sub { die $error }) };
  is(refaddr($@),refaddr($error),'nested source exception object unchanged');
  is(refaddr(LinkedSpec::ActionIR::SourceOrigins::_invocation_token()),refaddr($token),
   'source invocation restored after fatal nested invocation');
 });
 my $nest=sub {
  my $b=builder($_[0]); generated($b,'outer');
  eval { producers([$fatal],sub { capture($fatal,$_[0]) }) };
  is(refaddr($@),refaddr($error),'nested fatal object unchanged');
  eval { capture($fatal,$_[0]) };
  is(refaddr($@),refaddr($error),'direct nested fatal object unchanged');
  return finish($b)
 };
 producers([$nest],sub { is(capture($nest,$root)->{emission}{text},'outer','outer builder restored after nested fatal scope') });
};

my $plain=builder({}); generated($plain,'plain'); copied($plain,' text',0,5);
is(finish($plain),'plain text','builders preserve ordinary output without source collector');
is(LinkedSpec::ActionIR::SourceOrigins::_invocation_token(),undef,'invocation scope restored after all calls');
my @contexts;
producers([], sub { push @contexts, defined(wantarray) ? wantarray ? 'list' : 'scalar' : 'void' });
my $scalar = producers([], sub { push @contexts, defined(wantarray) ? wantarray ? 'list' : 'scalar' : 'void'; return 7 });
my @list = producers([], sub { push @contexts, defined(wantarray) ? wantarray ? 'list' : 'scalar' : 'void'; return (7,8) });
is_deeply(\@contexts,['void','scalar','list'],'producer scope preserves surrounding context');
is($scalar,7,'scope scalar return');
is_deeply(\@list,[7,8],'scope list return');
done_testing;
