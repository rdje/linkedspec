#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use File::Spec ();
use FindBin qw($Bin);
use JSON::PP ();
use Scalar::Util qw(blessed reftype);
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec ();

# Admitted by INTER-MATCH-GAP-CAPTURE.2.4; the default executes every Perl role.
# prove -Iperl t/inter_match_gap_capture_perl_contract.t
my $CONTRACT_ID = 'linkedspec-inter-match-gap-capture-v1';
my $MODE = $ENV{LINKEDSPEC_PERL_INTER_MATCH_GAP_MODE} // 'all';
my $JSON = JSON::PP->new->allow_nonref(1)->canonical(1);
my $GENERATED_PACKAGE_COUNTER = 0;

sub slurp {
 my ($path) = @_;
 open my $fh, '<:raw', $path or die "cannot read $path: $!";
 local $/;
 my $bytes = <$fh>;
 close $fh or die "cannot close $path: $!";
 return $bytes
}

sub compile_descriptor {
 my ($source, $source_id) = @_;
 my %runtime_ctx;
 my $descriptor = LinkedSpec::Get(
  \$source,
  return_descriptor => 1,
  generated_source_identity => $source_id,
  runtime_ctx_ref => \%runtime_ctx,
 );
 return ($descriptor, \%runtime_ctx)
}

sub compile_rejection {
 my ($source, $source_id) = @_;
 my ($descriptor, $runtime_ctx) = compile_descriptor($source, $source_id);
 ok(!defined($descriptor), "$source_id rejects");
 return $runtime_ctx->{last_error} // {}
}

sub semantic_edge {
 my ($edge) = @_;
 return {
  selector_kind => $edge->{selector_kind},
  authored_selector => $edge->{authored_selector},
  target_rule => $edge->{target_rule},
  regex_index => $edge->{regex_index},
  target_slot_id => $edge->{target_slot_id},
 }
}

sub load_generated_source {
 my ($source, $identity) = @_;
 my $suffix = $identity;
 $suffix =~ s/[^A-Za-z0-9]+/_/g;
 my $package = 'LinkedSpec::InterMatchGapGenerated::'.$suffix.'_'.++$GENERATED_PACKAGE_COUNTER;
 my $loaded = eval "package $package;\n$source\n1;";
 my $error = $@;
 ok($loaded, "$identity emitted source loads in an isolated package") or diag($error);
 return undef unless $loaded;
 no strict 'refs';
 return {
  execute => *{"${package}::Execute"}{CODE},
  execute_with_trace => *{"${package}::ExecuteWithTrace"}{CODE},
  metadata => *{"${package}::LinkedSpecGeneratedMetadata"}{CODE},
  plan => *{"${package}::LinkedSpecGeneratedPlan"}{CODE},
 }
}

sub compile_execution_roles {
 my ($source, $identity) = @_;
 my %runtime_ctx;
 my $live = LinkedSpec::Get(
  \$source,
  generated_source_identity => $identity,
  runtime_ctx_ref => \%runtime_ctx,
 );
 ok(ref($live) eq 'CODE', "$identity compiles for live execution")
  or diag($JSON->encode($runtime_ctx{last_error} // {}));
 my $emitted = LinkedSpec::emit_generated_source(
  \$source,
  source_identity => $identity,
 );
 ok(defined($emitted) && length($emitted), "$identity emits standalone source");
 my $generated = load_generated_source($emitted, $identity);
 return ($live, $generated, $emitted)
}

sub capture_execution {
 my ($parser, $input_text, @args) = @_;
 my $input = $input_text;
 my $value;
 my $ok = eval {
  $value = $parser->(\$input, @args);
  1
 };
 my $error = $@;
 return {
  ok => $ok ? 1 : 0,
  value => $value,
  error => $error,
  position => pos($input),
 }
}

sub diagnostic_value {
 my ($value) = @_;
 return $value unless ref($value);
 my $type = reftype($value) // '';
 if ($type eq 'HASH') {
  my $fields = {map { $_ => diagnostic_value($value->{$_}) } sort keys %$value};
  return blessed($value)
   ? {class => blessed($value), text => "$value", fields => $fields}
   : $fields;
 }
 return [map { diagnostic_value($_) } @$value] if $type eq 'ARRAY';
 return "$value"
}

sub diagnostic_record {
 my ($error) = @_;
 return diagnostic_value($error)
}

sub assert_success_parity {
 my (%args) = @_;
 my $live_result = capture_execution($args{live}, $args{input});
 my $generated_result = capture_execution($args{generated}{execute}, $args{input});
 ok($live_result->{ok}, "$args{label} live role succeeds")
  or diag($JSON->encode(diagnostic_record($live_result->{error})));
 ok($generated_result->{ok}, "$args{label} generated role succeeds")
  or diag($JSON->encode(diagnostic_record($generated_result->{error})));
 is(
  $JSON->encode($generated_result->{value}),
  $JSON->encode($live_result->{value}),
  "$args{label} generated value is byte-identical to live",
 );
 is_deeply($generated_result->{value}, $args{expected}, "$args{label} returns the exact contract value");
 is($generated_result->{position}, $live_result->{position}, "$args{label} preserves the live cursor");
 return ($live_result, $generated_result)
}

sub run_metadata_contract {
 is($CONTRACT_ID, 'linkedspec-inter-match-gap-capture-v1', 'loads the frozen neutral contract identity');

 my $self_hosted_source = slurp(File::Spec->catfile($Bin, '..', 'specs', 'spec.spec'));
 my $self_hosted_parser = LinkedSpec::Get(\$self_hosted_source, top_rule => 'spec_file');
 ok(ref($self_hosted_parser) eq 'CODE', 'permanent self-hosted grammar compiles');
 my $self_hosted_input = <<'SPEC';
Top::
 @capture_gaps
 -> Part[head] { return("hit") }
Part:
 head = /H/
 /S/
SPEC
 my $self_hosted_ast = $self_hosted_parser->(\$self_hosted_input);
 is_deeply(
  $self_hosted_ast,
  [
   [
    { type => 'rule', label => 'Top', top => 1, mode => '' },
    { type => 'capture_gaps', directive => '' },
    { type => 'action_edge', targets => 'Part[head]', code => '{ return("hit") }' },
   ],
   [
    { type => 'rule', label => 'Part', top => 0, mode => '' },
    { type => 'regex', pattern => 'H', slot_name => 'head' },
    { type => 'regex', pattern => 'S' },
   ],
  ],
  'permanent grammar owns named declarations, named selectors, and capture-gaps syntax without widening anonymous nodes',
 );

 for my $spacing ('header=/H/', 'header =/H/', 'header= /H/', 'header = /H/') {
  my $source = "Top::\n -> Part[header] { return(\"hit\") }\nPart:\n $spacing\n";
  my ($descriptor, $runtime_ctx) = compile_descriptor($source, 'spacing.spec');
  ok(ref($descriptor) eq 'HASH', "named declaration spacing compiles: $spacing")
   or diag(JSON::PP->new->canonical(1)->encode($runtime_ctx->{last_error} // {}));
  next unless ref($descriptor) eq 'HASH';
  is_deeply(
   $descriptor->{spec}{Part}{meta}{regex_slots},
   [{ regex_index => 0, slot_id => 'header' }],
   "named declaration spacing preserves slot identity: $spacing",
  );
 }

 my $named_execution_source = <<'SPEC';
Top::
 -> Part[tail] { return(match_text()) }
Part:
 head=/H/
 tail=/T/
SPEC
 my $named_parser = LinkedSpec::Get(\$named_execution_source);
 ok(ref($named_parser) eq 'CODE', 'ordinary named-selector source builds without gap capture');
 my $named_input = 'T';
 is($named_parser->(\$named_input), 'T', 'ordinary named selector executes the resolved target slot');

 my $unicode_name = "\x{e9}\x{301}";
 my $authored = <<"SPEC";
Top::
 \@capture_gaps
 -> Part[$unicode_name] { return("unicode") }
 -> Part[0] { return("numeric") }
Part:
 head=/H/
 /S/
 foot=/F/
 $unicode_name=/U/
SPEC
 my ($descriptor, $runtime_ctx) = compile_descriptor($authored, 'metadata.spec');
 ok(ref($descriptor) eq 'HASH', 'mixed named/anonymous Unicode metadata source compiles')
  or diag(JSON::PP->new->canonical(1)->encode($runtime_ctx->{last_error} // {}));
 return unless ref($descriptor) eq 'HASH';

 is_deeply(
  $descriptor->{spec}{Part}{meta}{regex_slots},
  [
   { regex_index => 0, slot_id => 'head' },
   { regex_index => 1, slot_id => undef },
   { regex_index => 2, slot_id => 'foot' },
   { regex_index => 3, slot_id => $unicode_name },
  ],
  'descriptor preserves mixed declaration order and exact decoded Unicode identity',
 );
 is_deeply(
  [map { semantic_edge($_) } @{$descriptor->{spec}{Top}{meta}{resolved_slot_edges}}],
  [
   {
    selector_kind => 'named',
    authored_selector => $unicode_name,
    target_rule => 'Part',
    regex_index => 3,
    target_slot_id => $unicode_name,
   },
   {
    selector_kind => 'numeric',
    authored_selector => 0,
    target_rule => 'Part',
    regex_index => 0,
    target_slot_id => 'head',
   },
  ],
  'resolved edges carry exact selector and target-slot provenance',
 );
 is_deeply(
  $descriptor->{spec}{Top}{dependency_refs},
  [
   {
    label => 'Part', idx => 3, selector_kind => 'named',
    authored_selector => $unicode_name, target_slot_id => $unicode_name,
   },
   {
    label => 'Part', idx => 0, selector_kind => 'numeric',
    authored_selector => 0, target_slot_id => 'head',
   },
  ],
  'live dependency references retain resolved selector provenance',
 );
 is_deeply(
  $descriptor->{spec}{Top}{meta}{capture_gaps},
  { enabled => 1, directive => '@capture_gaps', line => 2 },
  'eligible default action rule exposes capture-gaps metadata',
 );

 my $same_regex_before = <<'SPEC';
Top::
 -> Part[head] { return("hit") }
Part:
 head=/X/
 other=/X/
SPEC
 my $same_regex_after = <<'SPEC';
Top::
 -> Part[head] { return("hit") }
Part:
 other=/X/
 head=/X/
SPEC
 my ($before) = compile_descriptor($same_regex_before, 'before.spec');
 my ($after) = compile_descriptor($same_regex_after, 'after.spec');
 is_deeply(
  semantic_edge($before->{spec}{Top}{meta}{resolved_slot_edges}[0]),
  {
   selector_kind => 'named', authored_selector => 'head', target_rule => 'Part',
   regex_index => 0, target_slot_id => 'head',
  },
  'named selector resolves the first duplicate-text slot before reorder',
 );
 is_deeply(
  semantic_edge($after->{spec}{Top}{meta}{resolved_slot_edges}[0]),
  {
   selector_kind => 'named', authored_selector => 'head', target_rule => 'Part',
   regex_index => 1, target_slot_id => 'head',
  },
  'named selector follows stable identity across duplicate-text reorder',
 );

 my $generated = LinkedSpec::emit_generated_source(
  \$authored,
  source_identity => 'metadata-generated.spec',
 );
 like($generated, qr/selector_kind => 'named'/, 'generated dependency slot carries named-selector provenance');
 like($generated, qr/authored_selector => '\Q$unicode_name\E'/, 'generated dependency slot carries exact authored selector');
 like($generated, qr/target_slot_id => '\Q$unicode_name\E'/, 'generated dependency slot carries exact target-slot identity');
 like($generated, qr/InterMatchGapRuntime::activate/, 'generated source stages the private live gap lifecycle');
 like($generated, qr/^use LinkedSpec::InterMatchGapRuntime \(\);/m, 'generated source imports the private gap runtime');

 my $self_target_source = <<'SPEC';
Top::
 /H/
 tail=/T/
 -> Top[tail] { return("tail") }
SPEC
 my $self_target_generated = LinkedSpec::emit_generated_source(
  \$self_target_source,
  source_identity => 'self-target-generated.spec',
 );
 like(
  $self_target_generated,
  qr/label => 'Top', idx => 1, selector_kind => 'named', authored_selector => 'tail', target_slot_id => 'tail'/,
  'generated local structural-slot expansion retains named-selector provenance',
 );

 my $unsupported_source = <<'SPEC';
Top::
 I { return(array(entry_slot(), gap_span(), gap_text(), gap_kind())) }
 /x/
SPEC
 my ($unsupported) = compile_descriptor($unsupported_source, 'unsupported-accessors.spec');
 my @unsupported_helpers = sort @{$unsupported->{spec}{Top}{meta}{action_rewriter}{unresolved_helpers} // []};
 is_deeply(
  \@unsupported_helpers,
  [],
  'private gap accessors leave no unsupported-helper residue',
 );
 is_deeply(
  $unsupported->{spec}{Top}{meta}{action_rewriter}{canonical_action_ir_nodes},
  [qw(ENTRY_SLOT_READ GAP_KIND_READ GAP_SPAN_READ GAP_TEXT_READ RETURN)],
  'private gap accessors retain their four dedicated ActionIR nodes',
 );

 my @negative = (
  {
   id => 'invalid-name', source => "Top::\n -bad=/H/\n", code => 'regex_slot_name_invalid',
   stage => 'parse_declaration', line => 2, fields => { slot_name => '-bad' },
  },
  {
   id => 'numeric-name', source => "Top::\n 123=/H/\n", code => 'regex_slot_name_invalid',
   stage => 'parse_declaration', line => 2, fields => { slot_name => '123' },
  },
  {
   id => 'duplicate-name', source => "Top::\n head=/H/\n head=/S/\n", code => 'regex_slot_duplicate_name',
   stage => 'resolve_declaration', line => 3, fields => { slot_name => 'head', first_line => 2 },
  },
  {
   id => 'unknown-name', source => "Top::\n -> Part[missing] { return(\"x\") }\nPart:\n head=/H/\n",
   code => 'regex_slot_unknown_name', stage => 'resolve_selector', line => 2,
   fields => { target_rule => 'Part', authored_selector => 'missing' },
  },
  {
   id => 'index-range', source => "Top::\n -> Part[2] { return(\"x\") }\nPart:\n /H/\n",
   code => 'regex_slot_index_out_of_range', stage => 'resolve_selector', line => 2,
   fields => { target_rule => 'Part', regex_index => 2, regex_count => 1 },
  },
  {
   id => 'selector-syntax', source => "Top::\n -> Part[head { return(\"x\") }\nPart:\n head=/H/\n",
   code => 'regex_slot_selector_invalid', stage => 'parse_selector', line => 2,
   fields => { target_rule => 'Part', authored_selector => 'head' },
  },
  {
   id => 'duplicate-directive', source => "Top::\n \@capture_gaps\n \@capture_gaps\n -> Part { return(\"x\") }\nPart: /H/\n",
   code => 'capture_gaps_duplicate_directive', stage => 'parse_directive', line => 3,
   fields => { first_line => 2 },
  },
  {
   id => 'and-ineligible', source => "Top::AND\n \@capture_gaps\n -> Part { return(\"x\") }\nPart: /H/\n",
   code => 'capture_gaps_rule_ineligible', stage => 'validate_directive', line => 2,
   fields => { family => 'and', cursor_policy => 'consume', edge_ownership => 'action', execution_shape => 'single_match' },
  },
  {
   id => 'blind-ineligible', source => "Top::\n \@capture_gaps\n => Part\nPart: /H/\n",
   code => 'capture_gaps_rule_ineligible', stage => 'validate_directive', line => 2,
   fields => { family => 'or_default', cursor_policy => 'seek', edge_ownership => 'blind', execution_shape => 'default_scan_loop' },
  },
  {
   id => 'legacy-conflict', source => "Top::\n \@capture_gaps\n \@move_pos\n -> Part { return(\"x\") }\nPart: /H/\n",
   code => 'capture_gaps_legacy_marker_conflict', stage => 'validate_directive', line => 2,
   fields => { marker => '@move_pos', marker_line => 3 },
  },
 );
 for my $case (@negative) {
  my $source_id = "$case->{id}.spec";
  my $error = compile_rejection($case->{source}, $source_id);
  is($error->{code}, $case->{code}, "$case->{id} reports the portable diagnostic code");
  is($error->{stage}, $case->{stage}, "$case->{id} reports the contract phase");
  is($error->{rule_label}, 'Top', "$case->{id} attributes the owning rule");
  is($error->{source_id}, $source_id, "$case->{id} retains typed source identity");
  is($error->{line}, $case->{line}, "$case->{id} retains authored line");
  for my $field (sort keys %{$case->{fields}}) {
   is_deeply($error->{$field}, $case->{fields}{$field}, "$case->{id} retains $field context");
  }
 }
}

sub run_live_contract {
 subtest 'dedicated live accessors lower without public or fallback residue' => sub {
  my $source = <<'SPEC';
Top::
 @capture_gaps
 -> Part[head] { return(array(gap_span(), gap_text(), gap_kind(), call(Part))) }
Part:
 head=/H/
 I { return(entry_slot()) }
SPEC
  my ($descriptor, $runtime_ctx) = compile_descriptor($source, 'live-lowering.spec');
  ok(ref($descriptor) eq 'HASH', 'live accessor source compiles')
   or diag(JSON::PP->new->canonical(1)->encode($runtime_ctx->{last_error} // {}));
  return unless ref($descriptor) eq 'HASH';
  my @nodes = sort @{$descriptor->{spec}{Top}{meta}{action_rewriter}{canonical_action_ir_nodes} // []};
  is_deeply(
   \@nodes,
   [qw(CALL GAP_KIND_READ GAP_SPAN_READ GAP_TEXT_READ RETURN)],
   'enclosing action carries the three dedicated gap-read nodes',
  );
  is_deeply(
   $descriptor->{spec}{Part}{meta}{action_rewriter}{canonical_action_ir_nodes},
   [qw(ENTRY_SLOT_READ RETURN)],
   'target entry carries the dedicated entry-slot read node',
  );
  is_deeply(
   $descriptor->{spec}{Top}{meta}{action_rewriter}{unresolved_helpers},
   [],
   'live gap accessors leave no unsupported helper',
  );
 };

 subtest 'unicode prefix interstitial tail and named entry slots are exact' => sub {
  my $source = <<'SPEC';
Top::
 I { segments = [] }
 @capture_gaps
 -> Part[header]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[section] { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[footer]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 LX { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span())); return(copy(segments)) }
Part:
 header=/H/
 section=/S/
 footer=/F/
 I { return(hash("slot", entry_slot(), "text", entry_text(), "falsey", 0)) }
SPEC
  my $parser = LinkedSpec::Get(\$source, generated_source_identity => 'unicode-live.spec');
  ok(ref($parser) eq 'CODE', 'unicode live parser compiles');
  my $input = "\x{03b1}H\x{03b2}\nS\x{1f642}F\x{03c9}";
  my $result = $parser->(\$input);
  my @expected_gap = (
   ['prefix', "\x{03b1}", 0, 1],
   ['interstitial', "\x{03b2}\n", 2, 4],
   ['interstitial', "\x{1f642}", 5, 6],
   ['tail', "\x{03c9}", 7, 8],
  );
  is(scalar(@$result), 4, 'three accepted edges plus one tail are returned');
  for my $index (0 .. $#expected_gap) {
   my ($kind, $text, $start, $end) = @{$expected_gap[$index]};
   is($result->[$index]{kind}, $kind, "gap $index has exact kind");
   is($result->[$index]{text}, $text, "gap $index materializes exact Unicode text");
   is_deeply(
    $result->[$index]{span},
    { source_id => 'input', start => $start, end => $end, provenance => 'gap' },
    "gap $index returns a detached typed span record",
   );
  }
  for my $index (0 .. 2) {
   my $slot_name = (qw(header section footer))[$index];
   is_deeply(
    $result->[$index]{child}{slot},
    {
     target_rule => 'Part', regex_index => $index, slot_id => $slot_name,
     selector_kind => 'named', authored_selector => $slot_name,
    },
    "target $slot_name receives exact detached entry-slot provenance",
   );
   is($result->[$index]{child}{falsey}, 0, "target $slot_name preserves a falsey payload member");
  }
  $result->[0]{span}{start} = 99;
  my $again = $parser->(\$input);
  is($again->[0]{span}{start}, 0, 'mutating a returned span cannot mutate invocation state');
 };

 subtest 'empty prefix interstitial and tail spans remain first class' => sub {
  my $source = <<'SPEC';
Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[s] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[f] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 LX { push(gaps, array(gap_kind(), gap_text(), gap_span())); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 f=/F/
 I.return(entry_text())
SPEC
  my $parser = LinkedSpec::Get(\$source);
  ok(ref($parser) eq 'CODE', 'empty-gap parser compiles');
  my $input = 'HSF';
  my $result = $parser->(\$input);
  is_deeply(
   [map { [$_->[0], $_->[1], $_->[2]{start}, $_->[2]{end}] } @$result],
   [
    ['prefix', '', 0, 0],
    ['interstitial', '', 1, 1],
    ['interstitial', '', 2, 2],
    ['tail', '', 3, 3],
   ],
   'all four empty gap records survive without trimming or suppression',
  );
 };

 subtest 'child-extended accepted cursor becomes the next committed boundary' => sub {
  my $source = <<'SPEC';
Top::
 I { gaps = [] }
 @capture_gaps
 -> Container[open] { push(gaps, array(gap_text(), call(Container))) }
 -> Bang { push(gaps, array(gap_text(), call(Bang))) }
 LX { push(gaps, array(gap_text(), gap_kind())); return(copy(gaps)) }
Container:
 open=/\{/
 -> Close { return(call(Close)) }
Close:
 /\}/
 I.return(entry_text())
Bang:
 /!/
 I.return(entry_text())
SPEC
  my $parser = LinkedSpec::Get(\$source);
  ok(ref($parser) eq 'CODE', 'child-extended cursor parser compiles');
  my $input = 'p{abc}gap!';
  is_deeply(
   $parser->(\$input),
   [['p', '}'], ['gap', '!'], ['', 'tail']],
   'post-child accepted cursor, not selected opening-match end, owns the next gap boundary',
  );
 };

 subtest 'parent candidate suspends while a nested gap owner uses isolated state' => sub {
  my $source = <<'SPEC';
Top::
 @capture_gaps
 -> Container[open] { return(array(gap_text(), call(Container), gap_text())) }
Container:
 open=/\{/
 I { inner = [] }
 @capture_gaps
 -> Atom { push(inner, gap_text()) }
 LX { push(inner, gap_text()); return(copy(inner)) }
Atom:
 /x/
 I.return(entry_text())
SPEC
  my $parser = LinkedSpec::Get(\$source);
  ok(ref($parser) eq 'CODE', 'nested gap-owner parser compiles');
  my $input = 'p{axtail';
  is_deeply(
   $parser->(\$input),
   ['p', ['a', 'tail'], 'p'],
   'nested invocation sees only its own gap state and parent resumes the same candidate',
  );
 };

 subtest 'recognition rollback restores the same invocation gap snapshot' => sub {
  my $source = <<'SPEC';
Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] {
   tx = recognition_checkpoint();
   matched = recognize_once(tx, call(Probe));
   recognition_rollback(tx);
   push(gaps, gap_text())
 }
 -> Part[s] { push(gaps, gap_text()) }
 LX { push(gaps, gap_text()); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 I.return(entry_text())
Probe:
 /X/
 I.return(0)
SPEC
  my $parser = LinkedSpec::Get(\$source);
  ok(ref($parser) eq 'CODE', 'same-guard rollback parser compiles');
  return unless ref($parser) eq 'CODE';
  my $input = 'aHXbS';
  is_deeply(
   $parser->(\$input),
   ['a', 'Xb', ''],
   'rollback restores cursor, committed boundary, accepted count, and current candidate together',
  );
 };

 subtest 'terminal LX EX and maximum E expose exact tails but failed minimum does not' => sub {
  my $default_source = <<'SPEC';
Top::
 @capture_gaps
 -> Part { return(gap_text()) }
 LX { return(array(gap_kind(), gap_text(), gap_span())) }
Part: /H/
SPEC
  my $default = LinkedSpec::Get(\$default_source);
  my $no_match = 'abc';
  is_deeply(
   $default->(\$no_match),
   ['tail', 'abc', { source_id => 'input', start => 0, end => 3, provenance => 'gap' }],
   'default miss installs a whole-input LX tail',
  );

  my $ex_source = <<'SPEC';
Top::OR{0,2}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 EX { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
SPEC
  my $ex = LinkedSpec::Get(\$ex_source);
  my $one = 'aHtail';
  is_deeply($ex->(\$one), ['a', 'tail'], 'satisfied repetition miss installs tail before EX');
  my $zero = 'whole';
  is_deeply($ex->(\$zero), ['whole'], 'zero-match zero-min repetition exposes the whole input as tail');

  my $e_source = <<'SPEC';
Top::OR{1}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 E { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
SPEC
  my $maximum = LinkedSpec::Get(\$e_source);
  my $bounded = 'aHtail';
  is_deeply($maximum->(\$bounded), ['a', 'tail'], 'maximum completion installs tail before E');

  my $failed_source = <<'SPEC';
Top::OR{2}
 @capture_gaps
 -> Part { return(gap_text()) }
 EX { return("unexpected-ex") }
 E { return("unexpected-e") }
Part: /H/
SPEC
  my $failed = LinkedSpec::Get(\$failed_source);
  my $too_short = 'H';
  is($failed->(\$too_short), undef, 'failed repetition minimum exposes no tail or terminal lifecycle hook');
 };

 subtest 'unavailable contexts are typed and IT observes post-commit clearing' => sub {
  my $direct_source = <<'SPEC';
Direct::
 /H/
 I { return(gap_text()) }
SPEC
  my $direct = LinkedSpec::Get(\$direct_source);
  my $input = 'H';
  my $ok = eval { $direct->(\$input); 1 };
  my $error = $@;
  ok(!$ok, 'gap accessor outside an active candidate throws');
  ok(LinkedSpec::InterMatchGapRuntime::is_error($error), 'outside-context failure is the private typed error');
  is($error->{code}, 'gap_capture_context_unavailable', 'outside-context error has the portable code');
  is($error->{accessor}, 'gap_text', 'outside-context error identifies the accessor');

  my $it_source = <<'SPEC';
Top::OR{1}
 @capture_gaps
 -> Part { return(0) }
 IT { return(gap_kind()) }
Part: /H/
SPEC
  my $it = LinkedSpec::Get(\$it_source);
  my $hit = 'H';
  $ok = eval { $it->(\$hit); 1 };
  $error = $@;
  ok(!$ok, 'IT cannot read the candidate after accepted commit');
  ok(LinkedSpec::InterMatchGapRuntime::is_error($error), 'post-commit IT failure is typed');
  is($error->{phase}, 'IT', 'post-commit IT failure identifies lifecycle phase');

  my $regression_source = <<'SPEC';
Top::OR{1}
 @capture_gaps
 -> Part { rewind_match_start() }
Part: /H/
SPEC
  my $regression = LinkedSpec::Get(\$regression_source);
  my $prefixed = 'aH';
  $ok = eval { $regression->(\$prefixed); 1 };
  $error = $@;
  ok(!$ok, 'accepted gap commit rejects cursor regression');
  isa_ok($error, 'LinkedSpec::SourceLocation::Error');
  is($error->{code}, 'source_location_cursor_regression', 'cursor regression preserves the source diagnostic');
  is($error->{originating_edge_or_job}, 'Top:capture_gaps_commit', 'cursor regression identifies gap commit ownership');
 };

 subtest 'direct entry slot is undef and legacy rolling remains independent' => sub {
  my $direct_source = <<'SPEC';
Part::
 /H/
 I { return(entry_slot()) }
SPEC
  my $direct = LinkedSpec::Get(\$direct_source);
  my $hit = 'H';
  is($direct->(\$hit), undef, 'direct target invocation has no entry-slot context');

  my $legacy_source = <<'SPEC';
Top::
 I { gaps = [] }
 @move_pos
 -> Part[h] { push(gaps, array(capture_slice(), call(Part))) }
 -> Part[s] { push(gaps, array(capture_slice(), call(Part))) }
 -> Part[f] { push(gaps, array(capture_slice(), call(Part))) }
 LX { return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 f=/F/
 I.return(entry_text())
SPEC
  my $legacy = LinkedSpec::Get(\$legacy_source);
  ok(ref($legacy) eq 'CODE', 'legacy marker parser still compiles independently');
  my $legacy_input = 'preHgapSmoreFtail';
  is_deeply(
   $legacy->(\$legacy_input),
   [['pre', 'H'], ['gap', 'S'], ['more', 'F']],
   'legacy marker keeps prefix/interstitial output and does not gain a synthetic tail',
  );
 };
}

sub run_generated_contract {
 subtest 'generated carrier preserves source identity selector provenance and exact values' => sub {
  my $source = <<'SPEC';
Top::
 I { segments = [] }
 @capture_gaps
 -> Part[header]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[section] { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[footer]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 LX { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span())); return(copy(segments)) }
Part:
 header=/H/
 section=/S/
 footer=/F/
 I { return(hash("slot", entry_slot(), "text", entry_text(), "falsey", 0)) }
SPEC
  my ($live, $generated, $emitted) = compile_execution_roles($source, 'generated-unicode.spec');
  return unless ref($live) eq 'CODE' && ref($generated) eq 'HASH';
  like(
   $emitted,
   qr/^use LinkedSpec::InterMatchGapRuntime \(\);/m,
   'standalone source imports the private gap runtime explicitly',
  );
  like(
   $emitted,
   qr/label => 'Part', idx => 0, selector_kind => 'named', authored_selector => 'header', target_slot_id => 'header'/,
   'generated dependency row retains exact five-field selector provenance',
  );
  unlike($emitted, qr/\{\s*label\s*=>[^}]*capture_gaps/s, 'generated plan v2 is not widened with gap policy');
  is_deeply(
   $generated->{plan}->(),
   [
    {label => 'Top', family => 'default'},
    {label => 'Part', family => 'default'},
   ],
   'generated plan remains exact label/family v2 rows',
  );
  is(
   $generated->{metadata}->()->{source_identity},
   'generated-unicode.spec',
   'generated metadata preserves exact source identity',
  );

  my $input = "\x{03b1}H\x{03b2}\nS\x{1f642}F\x{03c9}";
  my $expected = [
   {
    kind => 'prefix', text => "\x{03b1}",
    span => {source_id => 'input', start => 0, end => 1, provenance => 'gap'},
    child => {
     slot => {
      target_rule => 'Part', regex_index => 0, slot_id => 'header',
      selector_kind => 'named', authored_selector => 'header',
     },
     text => 'H', falsey => 0,
    },
   },
   {
    kind => 'interstitial', text => "\x{03b2}\n",
    span => {source_id => 'input', start => 2, end => 4, provenance => 'gap'},
    child => {
     slot => {
      target_rule => 'Part', regex_index => 1, slot_id => 'section',
      selector_kind => 'named', authored_selector => 'section',
     },
     text => 'S', falsey => 0,
    },
   },
   {
    kind => 'interstitial', text => "\x{1f642}",
    span => {source_id => 'input', start => 5, end => 6, provenance => 'gap'},
    child => {
     slot => {
      target_rule => 'Part', regex_index => 2, slot_id => 'footer',
      selector_kind => 'named', authored_selector => 'footer',
     },
     text => 'F', falsey => 0,
    },
   },
   {
    kind => 'tail', text => "\x{03c9}",
    span => {source_id => 'input', start => 7, end => 8, provenance => 'gap'},
   },
  ];
  my (undef, $generated_result) = assert_success_parity(
   live => $live,
   generated => $generated,
   input => $input,
   expected => $expected,
   label => 'Unicode prefix/interstitial/tail',
  );
  $generated_result->{value}[0]{span}{start} = 99;
  my $again = capture_execution($generated->{execute}, $input);
  ok($again->{ok}, 'generated source executes again after detached-value mutation');
  is($again->{value}[0]{span}{start}, 0, 'generated returned span is detached from invocation state');

  my $traced = capture_execution(
   $generated->{execute_with_trace},
   $input,
   {trace_level => 'none'},
  );
  ok($traced->{ok}, 'ExecuteWithTrace preserves successful generated gap execution');
  is(
   $JSON->encode($traced->{value}),
   $JSON->encode($expected),
   'ExecuteWithTrace returns byte-identical gap values',
  );
 };

 subtest 'generated lifecycle terminals preserve empty and child-extended boundaries' => sub {
  my @cases = (
   {
    id => 'empty-gaps', input => 'HSF', expected => [
     ['prefix', '', {source_id => 'input', start => 0, end => 0, provenance => 'gap'}],
     ['interstitial', '', {source_id => 'input', start => 1, end => 1, provenance => 'gap'}],
     ['interstitial', '', {source_id => 'input', start => 2, end => 2, provenance => 'gap'}],
     ['tail', '', {source_id => 'input', start => 3, end => 3, provenance => 'gap'}],
    ],
    source => <<'SPEC',
Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[s] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[f] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 LX { push(gaps, array(gap_kind(), gap_text(), gap_span())); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 f=/F/
 I.return(entry_text())
SPEC
   },
   {
    id => 'child-extended', input => 'p{abc}gap!',
    expected => [['p', '}'], ['gap', '!'], ['', 'tail']],
    source => <<'SPEC',
Top::
 I { gaps = [] }
 @capture_gaps
 -> Container[open] { push(gaps, array(gap_text(), call(Container))) }
 -> Bang { push(gaps, array(gap_text(), call(Bang))) }
 LX { push(gaps, array(gap_text(), gap_kind())); return(copy(gaps)) }
Container:
 open=/\{/
 -> Close { return(call(Close)) }
Close:
 /\}/
 I.return(entry_text())
Bang:
 /!/
 I.return(entry_text())
SPEC
   },
   {
    id => 'default-lx-tail', input => 'abc',
    expected => ['tail', 'abc', {source_id => 'input', start => 0, end => 3, provenance => 'gap'}],
    source => <<'SPEC',
Top::
 @capture_gaps
 -> Part { return(gap_text()) }
 LX { return(array(gap_kind(), gap_text(), gap_span())) }
Part: /H/
SPEC
   },
   {
    id => 'repeat-ex-tail', input => 'aHtail', expected => ['a', 'tail'],
    source => <<'SPEC',
Top::OR{0,2}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 EX { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
SPEC
   },
   {
    id => 'repeat-ex-zero-tail', input => 'whole', expected => ['whole'],
    source => <<'SPEC',
Top::OR{0,2}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 EX { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
SPEC
   },
   {
    id => 'maximum-e-tail', input => 'aHtail', expected => ['a', 'tail'],
    source => <<'SPEC',
Top::OR{1}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 E { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
SPEC
   },
   {
    id => 'failed-minimum-no-tail', input => 'H', expected => undef,
    source => <<'SPEC',
Top::OR{2}
 @capture_gaps
 -> Part { return(gap_text()) }
 EX { return("unexpected-ex") }
 E { return("unexpected-e") }
Part: /H/
SPEC
   },
  );
  for my $case (@cases) {
   my ($live, $generated) = compile_execution_roles($case->{source}, "$case->{id}.spec");
   next unless ref($live) eq 'CODE' && ref($generated) eq 'HASH';
   assert_success_parity(
    live => $live,
    generated => $generated,
    input => $case->{input},
    expected => $case->{expected},
    label => $case->{id},
   );
  }
 };

 subtest 'generated recursion and rollback preserve invocation-local state' => sub {
  my @cases = (
   {
    id => 'nested-owner-isolation', input => 'p{axtail', expected => ['p', ['a', 'tail'], 'p'],
    source => <<'SPEC',
Top::
 @capture_gaps
 -> Container[open] { return(array(gap_text(), call(Container), gap_text())) }
Container:
 open=/\{/
 I { inner = [] }
 @capture_gaps
 -> Atom { push(inner, gap_text()) }
 LX { push(inner, gap_text()); return(copy(inner)) }
Atom:
 /x/
 I.return(entry_text())
SPEC
   },
   {
    id => 'same-token-rollback', input => 'aHXbS', expected => ['a', 'Xb', ''],
    source => <<'SPEC',
Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] {
  tx = recognition_checkpoint();
  matched = recognize_once(tx, call(Probe));
  recognition_rollback(tx);
  push(gaps, gap_text())
 }
 -> Part[s] { push(gaps, gap_text()) }
 LX { push(gaps, gap_text()); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 I.return(entry_text())
Probe:
 /X/
 I.return(0)
SPEC
   },
  );
  for my $case (@cases) {
   my ($live, $generated) = compile_execution_roles($case->{source}, "$case->{id}.spec");
   next unless ref($live) eq 'CODE' && ref($generated) eq 'HASH';
   assert_success_parity(
    live => $live,
    generated => $generated,
    input => $case->{input},
    expected => $case->{expected},
    label => $case->{id},
   );
  }
 };

 subtest 'gap-owned diagnostics remain typed and byte-identical through generated entrypoints' => sub {
  my @cases = (
   {
    id => 'outside-context', input => 'H', class => 'LinkedSpec::InterMatchGapRuntime::Error',
    code => 'gap_capture_context_unavailable',
    source => <<'SPEC',
Direct::
 /H/
 I { return(gap_text()) }
SPEC
   },
   {
    id => 'post-commit-it', input => 'H', class => 'LinkedSpec::InterMatchGapRuntime::Error',
    code => 'gap_capture_context_unavailable',
    source => <<'SPEC',
Top::OR{1}
 @capture_gaps
 -> Part { return(0) }
 IT { return(gap_kind()) }
Part: /H/
SPEC
   },
   {
    id => 'gap-cursor-regression', input => 'aH', class => 'LinkedSpec::SourceLocation::Error',
    code => 'source_location_cursor_regression',
    source => <<'SPEC',
Top::OR{1}
 @capture_gaps
 -> Part { rewind_match_start() }
Part: /H/
SPEC
   },
  );
  for my $case (@cases) {
   my ($live, $generated) = compile_execution_roles($case->{source}, "$case->{id}.spec");
   next unless ref($live) eq 'CODE' && ref($generated) eq 'HASH';
   my $live_result = capture_execution($live, $case->{input});
   my $generated_result = capture_execution($generated->{execute}, $case->{input});
   ok(!$live_result->{ok}, "$case->{id} live role rejects");
   ok(!$generated_result->{ok}, "$case->{id} generated Execute rejects");
   is(ref($generated_result->{error}), $case->{class}, "$case->{id} preserves the typed error class");
   is($generated_result->{error}{code}, $case->{code}, "$case->{id} preserves the portable code");
   is(
    $JSON->encode(diagnostic_record($generated_result->{error})),
    $JSON->encode(diagnostic_record($live_result->{error})),
    "$case->{id} generated diagnostic is byte-identical to live",
   );
   ok(
    LinkedSpec::InterMatchGapRuntime::is_error($generated_result->{error}),
    "$case->{id} remains owned by the private gap error classifier",
   );

   my $traced = capture_execution(
    $generated->{execute_with_trace},
    $case->{input},
    {trace_level => 'none'},
   );
   ok(!$traced->{ok}, "$case->{id} generated ExecuteWithTrace rejects");
   is(
    $JSON->encode(diagnostic_record($traced->{error})),
    $JSON->encode(diagnostic_record($generated_result->{error})),
    "$case->{id} ExecuteWithTrace preserves the exact typed diagnostic",
   );
  }
 };

 subtest 'direct entry and legacy rolling remain independently compatible' => sub {
  my @cases = (
   {
    id => 'direct-entry-slot', input => 'H', expected => undef,
    source => <<'SPEC',
Part::
 /H/
 I { return(entry_slot()) }
SPEC
   },
   {
    id => 'legacy-move-pos', input => 'preHgapSmoreFtail',
    expected => [['pre', 'H'], ['gap', 'S'], ['more', 'F']],
    source => <<'SPEC',
Top::
 I { gaps = [] }
 @move_pos
 -> Part[h] { push(gaps, array(capture_slice(), call(Part))) }
 -> Part[s] { push(gaps, array(capture_slice(), call(Part))) }
 -> Part[f] { push(gaps, array(capture_slice(), call(Part))) }
 LX { return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 f=/F/
 I.return(entry_text())
SPEC
   },
  );
  for my $case (@cases) {
   my ($live, $generated) = compile_execution_roles($case->{source}, "$case->{id}.spec");
   next unless ref($live) eq 'CODE' && ref($generated) eq 'HASH';
   assert_success_parity(
    live => $live,
    generated => $generated,
    input => $case->{input},
    expected => $case->{expected},
    label => $case->{id},
   );
  }
 };
}

if ($MODE eq 'all') {
 run_metadata_contract();
 run_live_contract();
 run_generated_contract();
} elsif ($MODE eq 'metadata') {
 run_metadata_contract();
} elsif ($MODE eq 'live') {
 run_live_contract();
} elsif ($MODE eq 'generated') {
 run_generated_contract();
} else {
 BAIL_OUT("unknown inter-match gap Perl mode '$MODE'");
}

done_testing;
