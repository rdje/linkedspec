use strict;
use warnings;

use File::Temp qw(tempdir tempfile);
use FindBin qw($Bin);
use JSON::PP ();
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec;

my $contract_path = "$Bin/../capability_conformance/rule_local_cursor_contract.json";
open my $contract_fh, '<', $contract_path or die "cannot open $contract_path: $!";
my $contract = JSON::PP->new->decode(do { local $/; <$contract_fh> });
close $contract_fh or die "cannot close $contract_path: $!";

sub run_live {
 my ($source, $input, %option) = @_;
 my %runtime_ctx;
 my $parser_source = '';
 my $parser = LinkedSpec::Get(
  \$source,
  runtime_ctx_ref => \%runtime_ctx,
  dump_parser_source => 1,
  parser_source_ref => \$parser_source,
  %option,
 );
 return ($parser, undef, \%runtime_ctx, $parser_source) unless ref($parser) eq 'CODE';
 my $result = $parser->(\$input);
 return ($parser, $result, \%runtime_ctx, $parser_source)
}

sub assert_live_case {
 my ($case) = @_;
 my ($parser, $result, $ctx) = run_live(
  $case->{source},
  $case->{input},
 );
 ok(ref($parser) eq 'CODE', "$case->{id} compiles")
  or diag(JSON::PP->new->canonical->encode($ctx->{last_error} // {}));
 if ($case->{expected_defined}) {
  is_deeply($result, $case->{expected}, "$case->{id} spends parent and child policies independently");
 } else {
  ok(!defined($result), "$case->{id} rejects when the child-owned consume boundary is not contiguous");
 }
 my %descriptor_ctx;
 my $descriptor_source = $case->{source};
 my $descriptor = LinkedSpec::Get(\$descriptor_source, return_descriptor => 1, runtime_ctx_ref => \%descriptor_ctx);
 ok(ref($descriptor) eq 'HASH', "$case->{id} descriptor compiles beside live execution")
  or diag(JSON::PP->new->canonical->encode($descriptor_ctx{last_error} // {}));
 return unless ref($descriptor) eq 'HASH';
 is(
  $descriptor->{meta}{cursor_contract},
  $contract->{descriptor_contract}{meta}{cursor_contract},
  "$case->{id} descriptor identifies the rule-local cursor contract",
 );
 is(
  $descriptor->{spec}{Top}{meta}{cursor_policy},
  $case->{descriptor_parent_cursor},
  "$case->{id} descriptor agrees with the live parent policy",
 );
 for my $child_label (@{$case->{descriptor_child_labels} || ['Child']}) {
  is(
   $descriptor->{spec}{$child_label}{meta}{cursor_policy},
   $case->{descriptor_child_cursor},
   "$case->{id} descriptor agrees with the live $child_label policy",
  );
 }
}

my %parent_child_case = (
 and_to_or_blind => {
  input => 'prefix x',
  expected_defined => 1,
  expected => ['hit'],
  source => <<'SPEC',
Top::AND
 => Child
Child:
 /x/
 -> Child { return("hit") }
SPEC
 },
 or_to_and_blind => {
  input => 'prefix x',
  expected_defined => 0,
  source => <<'SPEC',
Top::|
 => Child
Child:AND
 /x/
 -> Child { return("hit") }
SPEC
 },
 and_to_or_action => {
  input => 'x junk x',
  expected_defined => 1,
  expected => 'hit',
  source => <<'SPEC',
Top::AND
 -> Child { return(call(Child)) }
Child:
 /x/
 -> Child { return("hit") }
SPEC
 },
 or_to_and_action => {
  input => 'prefix x junk x',
  expected_defined => 0,
  source => <<'SPEC',
Top::|
 -> Child { return(call(Child)) }
Child:AND
 /x/
 -> Child { return("hit") }
SPEC
 },
 and_to_or_call => {
  input => 'p junk x',
  expected_defined => 1,
  expected => 'hit',
  source => <<'SPEC',
Top::AND
 /p/
 -> Top { return(call(Child)) }
Child:
 /x/
 -> Child { return("hit") }
SPEC
 },
 or_to_and_call => {
  input => 'prefix p junk x',
  expected_defined => 0,
  source => <<'SPEC',
Top::|
 /p/
 -> Top { return(call(Child)) }
Child:AND
 /x/
 -> Child { return("hit") }
SPEC
 },
 and_to_or_recursion => {
  input => 'p junk xp junk z',
  expected_defined => 1,
  expected => [['done']],
  source => <<'SPEC',
Top::AND
 /p/
 -> Top { return(call(Child)) }
Child:OR
 /x/ -> Child[0] { return(call(Top)) }
 /z/ -> Child[1] { return("done") }
SPEC
 },
 or_to_and_recursion => {
  input => 'junk p junk x z',
  expected_defined => 0,
  source => <<'SPEC',
Top::|
 /p/ -> Top[0] { return(call(Child)) }
 /z/ -> Top[1] { return("done") }
Child:AND
 /x/ -> Child { return(call(Top)) }
SPEC
 },
);

is_deeply(
 [sort keys %parent_child_case],
 [sort map { $_->{id} } @{$contract->{parent_child_cases}}],
 'focused live cases cover every neutral parent/child mechanism row',
);
for my $contract_case (@{$contract->{parent_child_cases}}) {
 my $case = $parent_child_case{$contract_case->{id}};
 $case->{id} = $contract_case->{id};
 $case->{descriptor_parent_cursor} = $contract_case->{expected}{parent_cursor};
 $case->{descriptor_child_cursor} = $contract_case->{expected}{child_cursor};
 assert_live_case($case);
}

my $and_source = <<'SPEC';
Top::AND
 /x/
 -> Top { return("hit") }
SPEC
my ($and_parser, $and_result, $and_ctx, $and_parser_source) = run_live(
 $and_source,
 'prefix x',
);
ok(ref($and_parser) eq 'CODE', 'AND top rule compiles without a global cursor option')
 or diag(JSON::PP->new->canonical->encode($and_ctx->{last_error} // {}));
ok(!defined($and_result), 'AND top rule consumes at the current cursor from its family');
like(
 $and_parser_source,
 qr/LinkedRE::or\(\$STRING, \$\$descr\{dependency_regex_map\}\{Top\}, 'consume', \$info\)/,
 'captured generated-source v2 derives the same consume policy as live AND execution',
);

my $or_source = <<'SPEC';
Top::
 /x/
 -> Top { return("hit") }
SPEC
my ($or_parser, $or_result, $or_ctx, $or_parser_source) = run_live(
 $or_source,
 'prefix x',
);
ok(ref($or_parser) eq 'CODE', 'default/OR top rule compiles without a global cursor option')
 or diag(JSON::PP->new->canonical->encode($or_ctx->{last_error} // {}));
is($or_result, 'hit', 'default/OR top rule seeks from its family');
unlike(
 $or_parser_source,
 qr/LinkedRE::or\(\$STRING, \$\$descr\{dependency_regex_map\}\{Top\}, 'consume', \$info\)/,
 'captured generated-source v2 derives the same seek policy as live default/OR execution',
);

my %structural_case = (
 ordered_landmarks => {
  input => 'junk h junk b',
  expected_defined => 1,
  expected => ['header', 'body'],
  source => <<'SPEC',
Top::AND
 => Header
 => Body
Header:
 /h/
 -> Header { return("header") }
Body:
 /b/
 -> Body { return("body") }
SPEC
 },
 anchored_choice => {
  input => 'prefix x',
  expected_defined => 0,
  source => <<'SPEC',
Top::|
 => X
 => Y
X:AND
 /x/
 -> X { return("x") }
Y:AND
 /y/
 -> Y { return("y") }
SPEC
 },
);
is_deeply(
 [sort keys %structural_case],
 [sort map { $_->{id} } @{$contract->{structural_replacements}}],
 'focused live cases cover both neutral structural replacements',
);
for my $contract_case (@{$contract->{structural_replacements}}) {
 my $case = $structural_case{$contract_case->{id}};
 $case->{id} = $contract_case->{id};
 $case->{descriptor_parent_cursor} = $contract_case->{expected_parent_cursor};
 $case->{descriptor_child_cursor} = $contract_case->{expected_child_cursor};
 $case->{descriptor_child_labels} = $contract_case->{id} eq 'ordered_landmarks'
  ? ['Header', 'Body']
  : ['X', 'Y'];
 assert_live_case($case);
}

my ($loaded_fh, $loaded_path) = tempfile(SUFFIX => '.spec');
print {$loaded_fh} $and_source or die "cannot write $loaded_path: $!";
close $loaded_fh or die "cannot close $loaded_path: $!";
my $loaded_parser = LinkedSpec::get_parser($loaded_path);
ok(ref($loaded_parser) eq 'CODE', 'file-oriented parser factory compiles a rule-local cursor spec');
my $loaded_leading = 'prefix x';
ok(!defined($loaded_parser->(\$loaded_leading)), 'loaded AND rule rejects leading junk with its own consume policy');
my $loaded_exact = 'x';
is($loaded_parser->(\$loaded_exact), 'hit', 'loaded AND rule still accepts a contiguous match');

my %removed_factory_ctx;
my $removed_factory_parser = LinkedSpec::get_parser(
 $loaded_path,
 parse_mode => 'seek',
 runtime_ctx_ref => \%removed_factory_ctx,
);
ok(!defined($removed_factory_parser), 'file-oriented parser factory rejects the removed cursor override');
is($removed_factory_ctx{last_error}{stage}, 'prepare_options', 'parser factory rejection reaches option preparation');
is($removed_factory_ctx{last_error}{code}, 'parse_mode_override_removed', 'parser factory exposes the portable removal code');
is($removed_factory_ctx{last_error}{option_name}, 'parse_mode', 'parser factory exposes the normalized option name');

my $trace_dir = tempdir(CLEANUP => 1);
my $trace_path = "$trace_dir/rule-local-cursor.log";
LinkedSpec::configure_trace(
 trace_level => 'debug',
 trace_log_file => $trace_path,
 trace_log_mode => 'route',
 trace_reset_log => 1,
 trace_topic_spacing => 0,
);
my $trace_source = $parent_child_case{and_to_or_call}{source};
my ($trace_parser, $trace_result) = run_live($trace_source, 'p junk x');
is($trace_result, 'hit', 'traced mixed-family execution preserves the live result');
open my $trace_fh, '<', $trace_path or die "cannot open $trace_path: $!";
my $trace = do { local $/; <$trace_fh> };
close $trace_fh or die "cannot close $trace_path: $!";
like($trace, qr/generated_handler_branch:and_single_acode:Top:/, 'trace attributes the consuming parent handler');
like($trace, qr/generated_handler_branch:default:Child:/, 'trace attributes the seeking child handler');
like(
 $trace,
 qr/ENTER LinkedSpec::rule_handler:Top.*?Context: \{[^\n]*'cursor_policy' => 'consume'/s,
 'trace records the parent rule-owned consume policy',
);
like(
 $trace,
 qr/ENTER LinkedSpec::rule_handler:Child.*?Context: \{[^\n]*'cursor_policy' => 'seek'/s,
 'trace records the child rule-owned seek policy',
);
LinkedSpec::configure_trace(trace_level => 'none', trace_log_file => '', trace_log_mode => 'stdout');

my $generated_v2 = LinkedSpec::emit_generated_source(
 \$or_source,
 source_identity => 'rule-local-cursor-v2-boundary.spec',
);
unlike(
 $generated_v2,
 qr/LinkedRE::or\(\$STRING, \$\$descr\{dependency_regex_map\}\{Top\}, 'consume', \$info\)/,
 'generated-source v2 does not serialize the transitional caller-global mode',
);
like($generated_v2, qr/linkedspec-generated-source-v2/, 'generated-source contract identity advances to v2');
unlike($generated_v2, qr/linkedspec-generated-source-v1/, 'fresh generated source does not retain the v1 identity');

done_testing;
