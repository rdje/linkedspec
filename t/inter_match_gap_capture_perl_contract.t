#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use File::Spec ();
use FindBin qw($Bin);
use JSON::PP ();
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec ();

# Dormant until INTER-MATCH-GAP-CAPTURE.2.4 admits the Perl runtime route.
# metadata: prove -Iperl t/inter_match_gap_capture_perl_contract.t
my $CONTRACT_ID = 'linkedspec-inter-match-gap-capture-v1';
my $MODE = $ENV{LINKEDSPEC_PERL_INTER_MATCH_GAP_RED_MODE} // 'metadata';

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
  'eligible default action rule exposes dormant capture-gaps metadata',
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
 unlike($generated, qr/InterMatchGapRuntime/, 'generated metadata introduces no live gap runtime');

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
  [qw(entry_slot gap_kind gap_span gap_text)],
  'metadata leaf keeps every future gap accessor unsupported',
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
 fail('live gap capture remains owned by INTER-MATCH-GAP-CAPTURE.2.2');
}

sub run_generated_contract {
 fail('independently loaded gap execution remains owned by INTER-MATCH-GAP-CAPTURE.2.3');
}

if ($MODE eq 'metadata') {
 run_metadata_contract();
} elsif ($MODE eq 'live') {
 run_live_contract();
} elsif ($MODE eq 'generated') {
 run_generated_contract();
} else {
 BAIL_OUT("unknown inter-match gap Perl RED mode '$MODE'");
}

done_testing;
