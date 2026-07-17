use strict;
use warnings;

use File::Temp qw(tempfile);
use FindBin qw($Bin);
use JSON::PP ();
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec;

my $contract_path = "$Bin/../capability_conformance/rule_local_cursor_contract.json";
open my $contract_fh, '<', $contract_path or die "cannot open $contract_path: $!";
my $contract = JSON::PP->new->decode(do { local $/; <$contract_fh> });
close $contract_fh or die "cannot close $contract_path: $!";

sub compile_descriptor {
 my ($source, %option) = @_;
 my %runtime_ctx;
 my $descriptor = LinkedSpec::Get(
  \$source,
  return_descriptor => 1,
  runtime_ctx_ref => \%runtime_ctx,
  %option,
 );
 ok(ref($descriptor) eq 'HASH', 'descriptor source compiles')
  or diag(JSON::PP->new->canonical->encode($runtime_ctx{last_error} // {}));
 return $descriptor
}

sub resolved_edge {
 my (%args) = @_;
 return {
  ownership => $args{ownership},
  target => $args{target},
  regex_index => $args{regex_index},
  block => $args{block} ? 1 : 0,
  fluent => $args{fluent},
  source_form => $args{source_form},
 }
}

my $bare_source = <<'SPEC';
Top::AND
 Child
Child:
 /x/
SPEC
my $bare_descriptor = compile_descriptor($bare_source);

is(
 $bare_descriptor->{meta}{cursor_contract},
 $contract->{descriptor_contract}{meta}{cursor_contract},
 'outward metadata identifies the rule-local cursor descriptor contract',
);
my ($legacy_root_path) = @{$contract->{descriptor_contract}{removed_fields}};
$legacy_root_path =~ s/^meta\.//;
ok(!exists($bare_descriptor->{meta}{$legacy_root_path}), 'outward metadata removes the legacy global cursor field');
is($bare_descriptor->{spec}{Top}{meta}{cursor_policy}, 'consume', 'AND descriptor policy is family-derived consume');
is($bare_descriptor->{spec}{Child}{meta}{cursor_policy}, 'seek', 'default child descriptor policy is family-derived seek');
for my $label (qw(Top Child)) {
 ok(!exists($bare_descriptor->{spec}{$label}{meta}{$legacy_root_path}), "$label metadata has no legacy cursor field");
}
my $legacy_option_descriptor = compile_descriptor($bare_source, $legacy_root_path => 'consume');
is_deeply(
 [map { $legacy_option_descriptor->{spec}{$_}{meta}{cursor_policy} } qw(Top Child)],
 [map { $bare_descriptor->{spec}{$_}{meta}{cursor_policy} } qw(Top Child)],
 'accepted transitional option input cannot override descriptor rule policies',
);
is(
 $legacy_option_descriptor->{meta}{cursor_contract},
 $bare_descriptor->{meta}{cursor_contract},
 'accepted transitional option input cannot override descriptor identity',
);
ok(
 !exists($legacy_option_descriptor->{meta}{$legacy_root_path}),
 'accepted transitional option input is not projected back into descriptor metadata',
);
my $descriptor_handler_source = <<'SPEC';
Top::AND
 /x/
 -> Top { return("hit") }
SPEC
my $descriptor_handler = compile_descriptor(
 $descriptor_handler_source,
 $legacy_root_path => 'seek',
);
my $leading_input = 'prefix x';
pos($leading_input) = 0;
my $leading_result = $descriptor_handler->{spec}{Top}{handler}->(
 $descriptor_handler,
 \$leading_input,
 {},
);
ok(!defined($leading_result), 'descriptor handler consumes intrinsically despite transitional seek input');
my $exact_input = 'x';
pos($exact_input) = 0;
is(
 $descriptor_handler->{spec}{Top}{handler}->($descriptor_handler, \$exact_input, {}),
 'hit',
 'descriptor handler accepts the same contiguous input as live AND execution',
);
my ($loaded_fh, $loaded_path) = tempfile(SUFFIX => '.spec');
print {$loaded_fh} $descriptor_handler_source or die "cannot write $loaded_path: $!";
close $loaded_fh or die "cannot close $loaded_path: $!";
my $loaded_descriptor = LinkedSpec::get_parser(
 $loaded_path,
 return_descriptor => 1,
 $legacy_root_path => 'seek',
);
ok(ref($loaded_descriptor) eq 'HASH', 'file-oriented descriptor path returns descriptor v1');
is(
 $loaded_descriptor->{meta}{cursor_contract},
 $contract->{descriptor_contract}{meta}{cursor_contract},
 'file-oriented descriptor path preserves cursor contract identity',
);
is(
 $loaded_descriptor->{spec}{Top}{meta}{cursor_policy},
 'consume',
 'file-oriented descriptor path preserves family-derived policy',
);
is_deeply(
 $bare_descriptor->{spec}{Top}{meta}{resolved_edges},
 [resolved_edge(
  ownership => 'blind',
  target => 'Child',
  regex_index => undef,
  block => 0,
  fluent => undef,
  source_form => 'bare',
 )],
 'bare AND edge projects one normalized blind row',
);
my $explicit_equivalent_descriptor = compile_descriptor(<<'SPEC');
Top::AND
 => Child
Child:
 /x/
SPEC
my $bare_semantics = { %{$bare_descriptor->{spec}{Top}{meta}{resolved_edges}[0]} };
my $explicit_semantics = { %{$explicit_equivalent_descriptor->{spec}{Top}{meta}{resolved_edges}[0]} };
delete $bare_semantics->{source_form};
delete $explicit_semantics->{source_form};
is_deeply(
 $bare_semantics,
 $explicit_semantics,
 'bare and explicit equivalent edges have identical descriptor semantics',
);
isnt(
 $bare_descriptor->{spec}{Top}{meta}{resolved_edges}[0]{source_form},
 $explicit_equivalent_descriptor->{spec}{Top}{meta}{resolved_edges}[0]{source_form},
 'equivalent descriptor rows retain provenance without changing semantics',
);

my $explicit_action_descriptor = compile_descriptor(<<'SPEC');
Top::AND
 -> Child[1] { return("hit") }
Child:
 /a/
 /b/
SPEC
is_deeply(
 $explicit_action_descriptor->{spec}{Top}{meta}{resolved_edges},
 [resolved_edge(
  ownership => 'action',
  target => 'Child',
  regex_index => 1,
  block => 1,
  fluent => undef,
  source_form => 'explicit',
 )],
 'explicit indexed action projects resolved slot and block facts',
);

my $explicit_blind_descriptor = compile_descriptor(<<'SPEC');
Top::
 => Child.return("hello world")
Child:AND
 /x/
SPEC
is_deeply(
 $explicit_blind_descriptor->{spec}{Top}{meta}{resolved_edges},
 [resolved_edge(
  ownership => 'blind',
  target => 'Child',
  regex_index => undef,
  block => 0,
  fluent => 'return("hello world")',
  source_form => 'explicit',
 )],
 'explicit blind fluent projects normalized non-indexed facts',
);

my $group_descriptor = compile_descriptor(<<'SPEC');
Top::
 A | B { return("hit") }
A:
 /a/
B:
 /b/
SPEC
is_deeply(
 $group_descriptor->{spec}{Top}{meta}{resolved_edges},
 [
  resolved_edge(
   ownership => 'action',
   target => 'A',
   regex_index => 0,
   block => 1,
   fluent => undef,
   source_form => 'bare',
  ),
  resolved_edge(
   ownership => 'action',
   target => 'B',
   regex_index => 0,
   block => 1,
   fluent => undef,
   source_form => 'bare',
  ),
 ],
 'grouped bare action projects one deterministic resolved row per target',
);

my $resolved_rows = $group_descriptor->{spec}{Top}{meta}{resolved_edges};
my @semantic_fields = grep { $_ ne 'source_form' } sort keys %{$resolved_rows->[0]};
is_deeply(
 \@semantic_fields,
 [sort @{$contract->{descriptor_contract}{resolved_edge_fields}}],
 'resolved rows expose exactly the neutral semantic field set',
);
ok(
 !$contract->{descriptor_contract}{optional_provenance}{semantic},
 'source-form provenance is explicitly non-semantic in the neutral authority',
);

my $generated_source = <<'SPEC';
Top::
 /x/
SPEC
my $generated = LinkedSpec::emit_generated_source(
 \$generated_source,
 source_identity => 'descriptor-v1-generated-v2.spec',
);
like($generated, qr/linkedspec-generated-source-v2/, 'standalone generated source now carries the v2 identity');
unlike($generated, qr/linkedspec-generated-source-v1/, 'standalone generated source no longer emits the v1 identity');

done_testing;
