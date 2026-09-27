use strict;
use warnings;
use utf8;
use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec ();
use File::Temp qw(tempdir);
use JSON::PP ();
use Test::More;
use LinkedSpec ();

sub read_text {
    open my $fh, '<:encoding(UTF-8)', $_[0] or die "read $_[0]: $!";
    local $/;
    return <$fh>;
}

sub write_text {
    open my $fh, '>:encoding(UTF-8)', $_[0] or die "write $_[0]: $!";
    print {$fh} $_[1];
    close $fh or die "close $_[0]: $!";
}

my $root = File::Spec->rel2abs("$Bin/..");
my $fixture = File::Spec->catdir($root, qw(tests language-readiness nested-tree));
my $source = read_text(File::Spec->catfile($fixture, 'grammar.spec'));
my $json = JSON::PP->new->canonical->ascii->allow_nonref;
my $cases = $json->decode(read_text(File::Spec->catfile($fixture, 'cases.json')));
my %by_id = map { $_->{id} => $_ } (@{$cases->{accept}}, @{$cases->{reject}});
my $recovery = $by_id{nested_state};
my @sequence;
for my $round (1, 2) {
    push @sequence, map { +{%$_, label => "$_->{id} round $round"} } @{$cases->{accept}};
    for my $case (@{$cases->{reject}}) {
        push @sequence, {%$case, reject => 1, label => "$case->{id} round $round"};
        push @sequence, {%$recovery, label => "recovery after $case->{id} round $round"};
    }
}
is(scalar(@sequence), 40, 'two exact sequences include immediate recovery after each rejection');

my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
my $summary = $descriptor->{meta}{action_rewriter_migration};
is($summary->{language_agnostic_ready_ratio}, '1.0000', 'grammar is entirely ActionIR ready');
is($summary->{language_agnostic_ready_rule_count}, 5, 'all five rules are ready');
is($summary->{language_agnostic_blocked_rule_count}, 0, 'no blocked rule');
is($summary->{compatibility_surface_rule_count}, 0, 'no compatibility-only rule');

my @variants = ({id => 'original', source => $source, inputs => \@sequence});
my $prefix = $source;
my $guard = <<'GUARD';
 if(matches(input_slice(0, cursor_pos()), /[^ \t\r\n\f\x0B]/));
  exit_now(1);
 endif();
GUARD
is(($prefix =~ s/\Q$guard\E//), 1, 'prefix mutation removes only the entry guard');
push @variants, {id => 'prefix', source => $prefix, inputs => [
    {%{$by_id{hidden_prefix}}, label => 'skipped prefix must affect rejection', mutation => 'accepts_rejected'},
]};
my $gap = $source;
is(($gap =~ s/ -> Invalid \{ exit_now\(1\) \}\n//g), 2, 'gap mutation removes exactly two rejecting edges');
push @variants, {id => 'gap', source => $gap, inputs => [
    {%{$by_id{interstitial_junk}}, label => 'interstitial gap must affect rejection', mutation => 'accepts_rejected'},
]};
my $span = $source;
is(($span =~ s/\[start, cursor_pos\(\)\]/[cursor_pos(), cursor_pos()]/), 1,
   'span mutation changes only the list start coordinate');
push @variants, {id => 'span', source => $span, inputs => [
    {%$recovery, label => 'bound start must affect the authored span', mutation => 'changes_span'},
]};

my $context_fixture = File::Spec->catdir($root, qw(tests language-readiness context-names));
my $context_source = read_text(File::Spec->catfile($context_fixture, 'grammar.spec'));
my $context_cases = $json->decode(read_text(File::Spec->catfile($context_fixture, 'cases.json')));
my %context_by_id = map { $_->{id} => $_ }
    (@{$context_cases->{accept}}, @{$context_cases->{reject}});
my $context_recovery = $context_by_id{siblings_restore_parent};
my @context_sequence;
for my $round (1, 2) {
    push @context_sequence, map { +{%$_, label => "$_->{id} round $round"} }
        @{$context_cases->{accept}};
    for my $case (@{$context_cases->{reject}}) {
        push @context_sequence, {%$case, reject => 1, label => "$case->{id} round $round"};
        push @context_sequence, {%$context_recovery,
            label => "recovery after $case->{id} round $round"};
    }
}
is(scalar(@context_sequence), 90, 'context names: two sequences with 34 immediate recoveries');
my $context_descriptor = LinkedSpec::Get(\$context_source, return_descriptor => 1);
my $context_summary = $context_descriptor->{meta}{action_rewriter_migration};
is($context_summary->{language_agnostic_ready_ratio}, '1.0000', 'context names: entirely ActionIR ready');
is($context_summary->{language_agnostic_ready_rule_count}, 5, 'context names: all five rules ready');
is($context_summary->{language_agnostic_blocked_rule_count}, 0, 'context names: no blocked rules');
is($context_summary->{compatibility_surface_rule_count}, 0, 'context names: no compatibility-only rules');

my @context_variants = ({id => 'original', source => $context_source, inputs => \@context_sequence});
my $comparison = $context_source;
my $comparison_guard = <<'GUARD';
  if(str_ne(match_group(0), name));
   exit_now(2);
  endif();
GUARD
is(($comparison =~ s/\Q$comparison_guard\E//), 1,
   'context names: comparison mutation removes exactly the name guard');
push @context_variants, {id => 'comparison', source => $comparison, inputs => [
    {input => $context_by_id{mismatch}{input}, expected => $context_by_id{empty_element}{expected},
     label => 'missing comparison wrongly accepts a mismatched closing name'},
]};
my $state = $context_source;
my $recursive_edge = " -> Element { push(children, call(Element)) }\n";
my $corrupt_edge = " -> Element { push(children, call(Element)); name = \"lost\" }\n";
is(($state =~ s/\Q$recursive_edge\E/$corrupt_edge/), 1,
   'context names: state mutation corrupts the parent name after one recursive edge');
push @context_variants, {id => 'state', source => $state, inputs => [
    {%$context_recovery, reject => 1, status => 2,
     label => 'corrupted parent state wrongly rejects valid nested siblings'},
]};
my $context_span = $context_source;
is(($context_span =~ s/\[start, cursor_pos\(\)\]/[cursor_pos(), cursor_pos()]/), 1,
   'context names: span mutation changes only the element start expression');
push @context_variants, {id => 'span', source => $context_span, inputs => [
    {%{$context_by_id{nested_distinct}}, mutation => 'changes_span', mutant_span => [17, 17],
     label => 'saved element start must affect the independent span'},
]};
for my $variant (@context_variants) {
    $variant->{source_identity} = "context-names/$variant->{id}";
    $variant->{id} = "context_$variant->{id}";
    push @variants, $variant;
}

my $lossless_fixture = File::Spec->catdir($root, qw(tests language-readiness lossless-segments));
my $lossless_source = read_text(File::Spec->catfile($lossless_fixture, 'grammar.spec'));
my $lossless_cases = $json->decode(read_text(File::Spec->catfile($lossless_fixture, 'cases.json')));
my %lossless_by_id = map { $_->{id} => $_ } @{$lossless_cases->{accept}};
is(scalar(keys %lossless_by_id), scalar(@{$lossless_cases->{accept}}),
   'lossless fixture IDs are unique');
is_deeply([sort keys %lossless_by_id], [sort qw(
    empty no_match_unicode single_zero unicode_edges adjacent mixed_separators
    malformed_only malformed_prefix crlf leading_lf comment_prefix comment_eof blank_line
)], 'lossless corpus preserves every required case');
my $lossless_descriptor = LinkedSpec::Get(\$lossless_source, return_descriptor => 1);
my $lossless_summary = $lossless_descriptor->{meta}{action_rewriter_migration};
is($lossless_summary->{language_agnostic_ready_rule_count}, 2, 'lossless: both rules are ActionIR ready');
is($lossless_summary->{language_agnostic_blocked_rule_count}, 0, 'lossless: no blocked rules');
is($lossless_summary->{compatibility_surface_rule_count}, 0, 'lossless: no compatibility-only rules');
my @lossless_sequence;
for my $round (1, 2) {
    push @lossless_sequence, map {
        +{%$_, lossless => 1, label => "lossless $_->{id} round $round"}
    } @{$lossless_cases->{accept}};
}
push @variants, {
    id => 'lossless', source_identity => 'lossless-segments/original',
    source => $lossless_source, inputs => \@lossless_sequence,
    detachment => $lossless_by_id{unicode_edges},
};

my $selection_mutant = $lossless_source;
is(($selection_mutant =~ s/\[0-9\]/[1-9]/), 1, 'lossless selection mutation excludes zero');
push @variants, {id => 'lossless_selection', source => $selection_mutant, inputs => [
    {%{$lossless_by_id{single_zero}}, label => 'classification mutant still reconstructs all input',
     mutation => 'lossless_difference', mutant_expected => [
         {kind => 'tail', text => '[0]',
          span => {source_id => 'input', start => 0, end => 3, provenance => 'gap'}},
     ]},
]};
my $tail_mutant = $lossless_source;
my $tail_statement = <<'TAIL';
 LX {
  push(parts, hash("kind", gap_kind(), "span", gap_span(), "text", gap_text()))
TAIL
is(($tail_mutant =~ s/\Q$tail_statement\E/ LX {\n/), 1,
   'lossless tail mutation removes only terminal gap retention');
my $without_tail = $json->decode($json->encode($lossless_by_id{unicode_edges}{expected}));
pop @$without_tail;
push @variants, {id => 'lossless_tail', source => $tail_mutant, inputs => [
    {%{$lossless_by_id{unicode_edges}}, label => 'omitted tail loses the astral scalar',
     mutation => 'lossless_difference', mutant_expected => $without_tail},
]};
my $item_span_mutant = $lossless_source;
is(($item_span_mutant =~ s/\[entry_start_pos\(\), entry_end_pos\(\)\]/[entry_end_pos(), entry_end_pos()]/),
   1, 'lossless span mutation changes only item start');
my $wrong_span = $json->decode($json->encode($lossless_by_id{unicode_edges}{expected}));
$wrong_span->[1]{span} = [5, 5];
push @variants, {id => 'lossless_span', source => $item_span_mutant, inputs => [
    {%{$lossless_by_id{unicode_edges}}, label => 'wrong item span preserves text but loses provenance',
     mutation => 'lossless_difference', mutant_expected => $wrong_span},
]};
my $prefix_mutant = $lossless_source;
my $entry_prefix = <<'PREFIX';
  if(num_ne(cursor_pos(), 0));
   push(parts, hash("kind", "entry_prefix", "span", [0, cursor_pos()], "text", input_slice(0, cursor_pos())))
  endif();
PREFIX
is(($prefix_mutant =~ s/\Q$entry_prefix\E//), 1,
   'lossless prefix mutation removes only public-entry prefix retention');
my $without_prefix = $json->decode($json->encode($lossless_by_id{comment_prefix}{expected}));
shift @$without_prefix;
push @variants, {id => 'lossless_prefix', source => $prefix_mutant, inputs => [
    {%{$lossless_by_id{comment_prefix}}, label => 'omitted entry prefix loses original comment text',
     mutation => 'lossless_difference', mutant_expected => $without_prefix},
]};

my $gap_book = read_text(File::Spec->catfile($root,
    qw(docs linkedspec-book src dsl capture-marks-and-source-locations.md)));
my ($gap_book_source) = $gap_book =~ /### Current lossless-segmentation example.*?```text\n(.*?)```/s;
ok(defined($gap_book_source), 'exact published gap example is present');
if (defined($gap_book_source)) {
    my @expected;
    for my $row (
        ['prefix', 0, 1, 'α', 'alpha'],
        ['interstitial', 6, 8, ', ', 'beta'],
        ['interstitial', 12, 15, ' | ', 'gamma'],
        ['interstitial', 20, 23, "\n- ", 'delta'],
        ['tail', 28, 29, 'ω'],
    ) {
        my ($kind, $start, $end, $text, $item) = @$row;
        my $record = {kind => $kind, text => $text,
            span => {source_id => 'input', start => $start, end => $end, provenance => 'gap'}};
        $record->{item} = {text => $item, slot => {
            target_rule => 'Item', regex_index => 0, slot_id => 'word',
            selector_kind => 'named', authored_selector => 'word',
        }} if defined $item;
        push @expected, $record;
    }
    my $book_empty = {input => '', label => 'published gap example empty input', expected => [
        {kind => 'tail', text => '',
         span => {source_id => 'input', start => 0, end => 0, provenance => 'gap'}},
    ]};
    my $book_words = {input => "αalpha, beta | gamma\n- deltaω",
        label => 'exact published Unicode gap example', expected => \@expected};
    push @variants, {id => 'gap_book', source => $gap_book_source,
        inputs => [$book_empty, $book_words, $book_empty, $book_words]};
    my $wrong_mode = $gap_book_source;
    is(($wrong_mode =~ s/List::\n/List::OR\n/), 1,
       'book mutation restores the original incorrect OR/LX pairing');
    push @variants, {id => 'gap_book_wrong_mode', source => $wrong_mode, inputs => [
        {%$book_empty, mutation => 'lossless_difference', mutant_expected => undef},
        {%$book_words, mutation => 'lossless_difference', mutant_expected => [undef, undef, undef, undef]},
    ]};
}

my $entry_source = <<'SPEC';
Top::
I.return(hash("start", cursor_pos(), "end", input_end_pos(), "source", input_slice(0, input_end_pos())))
 -> Any
Any: /[\s\S]/
SPEC
my @entry_controls = (
    ['empty', '', 0], ['ordinary', 'word', 0],
    ['leading_lf', "\nword", 1], ['blank_line', " \t\nword", 3],
    ['comment_lf', "#comment\nword", 9], ['indented_comment', "\t#x\nword", 4],
    ['mixed_lines', "\n#x\n\nword", 5], ['comment_eof', '#comment', 8],
    ['unicode_comment', "#雪🙂\nword", 4], ['horizontal_space', " \tword", 0],
    ['crlf', "\r\nword", 0], ['indented_crlf', " \t\r\nword", 0],
    ['non_ascii_space', "\x{A0}\nword", 0], ['unicode_line_separator', "\x{2028}\nword", 0],
);
my @entry_cases = map {
    +{label => "entry $_->[0]", input => $_->[1],
      expected => {start => $_->[2], end => length($_->[1]), source => $_->[1]}}
} @entry_controls;
push @variants, {id => 'entry', source => $entry_source, inputs => [@entry_cases, @entry_cases]};
my $child_source = <<'SPEC';
Top::
 -> Open { return(call(Body)) }
Open: /\(/
Body::
I.return(cursor_pos())
 -> Any
Any: /[\s\S]/
SPEC
push @variants, {id => 'child', source => $child_source, inputs => [
    {label => 'child does not repeat public skip', input => "(#x\nq)", expected => 1},
    {label => 'child retains absolute coordinates after public skip', input => "#skip\n(#x\nq)", expected => 7},
]};

sub observe {
    my ($parser, $input) = @_;
    my $value = eval { $parser->(\$input) };
    my $error = $@;
    return {value => $value, error => ref($error) || "$error",
            status => ref($error) eq 'LinkedSpec::RuntimeExitNow' ? $error->{status} : undef};
}

sub check_observation {
    my ($case, $result, $route) = @_;
    subtest "$route $case->{label}" => sub {
        if ($case->{reject}) {
            is($result->{error}, 'LinkedSpec::RuntimeExitNow', 'typed rejection');
            is($result->{status}, $case->{status} // 1, 'grammar rejection status is exact');
            ok(!defined($result->{value}), 'no partial value escapes');
        } else {
            is($result->{error}, '', 'execution succeeds');
            if (($case->{mutation} // '') eq 'lossless_difference') {
                is($json->encode($result->{value}), $json->encode($case->{mutant_expected}),
                   'controlled mutation has exactly its intended effect');
                isnt($json->encode($result->{value}), $json->encode($case->{expected}),
                     'unchanged authored oracle rejects the mutation');
            } elsif (($case->{mutation} // '') eq 'accepts_rejected') {
                is(ref($result->{value}), 'ARRAY', 'mutant wrongly accepts a document value');
                ok(@{$result->{value} || []} > 0, 'valid surrounding forms survive the wrong acceptance');
            } elsif (($case->{mutation} // '') eq 'changes_span') {
                is(ref($result->{value}), 'ARRAY', 'span mutant still returns a document');
                is_deeply($result->{value}[0]{span}, $case->{mutant_span} // [9, 9],
                          'the controlled mutation replaces the original start with the end');
                isnt($json->encode($result->{value}), $json->encode($case->{expected}),
                     'unchanged authored oracle detects the span mutation');
            } else {
                is($json->encode($result->{value}), $json->encode($case->{expected}),
                   'exact independent typed AST and Unicode spans');
            }
            if ($case->{lossless} && ref($result->{value}) eq 'ARRAY') {
                my ($boundary, $reconstruction) = (0, '');
                for my $segment (@{$result->{value}}) {
                    my ($start, $end) = ref($segment->{span}) eq 'ARRAY'
                        ? @{$segment->{span}} : @{$segment->{span}}{qw(start end)};
                    is($start, $boundary, 'segment begins at the previous end');
                    cmp_ok($end, '>=', $start, 'segment extent is nonnegative');
                    is(substr($case->{input}, $start, $end - $start), $segment->{text},
                       'segment equals its independent decoded-scalar input slice');
                    $boundary = $end;
                    $reconstruction .= $segment->{text};
                }
                is($boundary, length($case->{input}), 'every decoded scalar is accounted for');
                is($reconstruction, $case->{input}, 'ordered segments reconstruct the exact input');
            }
        }
    };
}

my $scratch_root = $ENV{LINKEDSPEC_SCRATCH_ROOT}
    || File::Spec->catdir($root, '.linkedspec-data', 'scratch');
my $scratch = tempdir('nested-tree-perl-XXXXXX', DIR => $scratch_root, CLEANUP => 1);
my @artifacts;
for my $variant (@variants) {
    my $parser = LinkedSpec::Get(\$variant->{source});
    ok(ref($parser) eq 'CODE', "$variant->{id} native parser compiles");
    if (ref($parser) eq 'CODE') {
        check_observation($_, observe($parser, $_->{input}), "$variant->{id} native")
            for @{$variant->{inputs}};
        if (my $case = $variant->{detachment}) {
            my $input = $case->{input};
            my $value = $parser->(\$input);
            $value->[0]{text} = 'changed returned text';
            $value->[0]{span}{start} = 999;
            check_observation({%$case, lossless => 1, label => 'after mutating a returned gap'},
                observe($parser, $case->{input}), "$variant->{id} native detachment");
        }
    }
    my $generated = LinkedSpec::emit_generated_source(
        \$variant->{source},
        source_identity => $variant->{source_identity} // "nested-tree/$variant->{id}");
    my $path = File::Spec->catfile($scratch, "$variant->{id}.pl");
    write_text($path, $generated);
    push @artifacts, {path => File::Spec->abs2rel($path, $root),
                     detachment_input => $variant->{detachment} ? $variant->{detachment}{input} : undef,
                     inputs => [map { $_->{input} } @{$variant->{inputs}}]};
}
my $request = File::Spec->catfile($scratch, 'request.json');
write_text($request, $json->encode(\@artifacts));
my $runner = File::Spec->catfile($scratch, 'runner.pl');
write_text($runner, <<'RUNNER');
use strict;
use warnings;
use JSON::PP ();
use File::Spec ();
my ($root, $request, $output) = @ARGV;
sub read_text {
    open my $fh, '<:encoding(UTF-8)', $_[0] or die $!;
    local $/;
    return <$fh>;
}
my $artifacts = JSON::PP->new->decode(read_text($request));
my @rows;
for my $index (0..$#$artifacts) {
    my $artifact = $artifacts->[$index];
    my $source = read_text(File::Spec->catfile($root, $artifact->{path}));
    my $package = "LinkedSpec::NestingReadiness::Case$index";
    my $loaded = eval "package $package; $source; 1";
    my $row = {load_error => "$@", observations => []};
    if ($loaded) {
        no strict 'refs';
        my $metadata = &{"${package}::LinkedSpecGeneratedMetadata"}();
        my $plan = &{"${package}::LinkedSpecGeneratedPlan"}();
        $row->{contract_id} = $metadata->{contract_id};
        $row->{source_identity} = $metadata->{source_identity};
        $row->{plan_valid} = &{"${package}::ValidateGeneratedPlan"}($plan) ? 1 : 0;
        for my $input (@{$artifact->{inputs}}) {
            my $value = eval { &{"${package}::Execute"}(\$input) };
            my $error = $@;
            push @{$row->{observations}}, {
                value => $value, error => ref($error) || "$error",
                status => ref($error) eq 'LinkedSpec::RuntimeExitNow' ? $error->{status} : undef,
            };
        }
        if (defined $artifact->{detachment_input}) {
            my $input = $artifact->{detachment_input};
            my $value = &{"${package}::Execute"}(\$input);
            $value->[0]{text} = 'changed returned text';
            $value->[0]{span}{start} = 999;
            my $again = &{"${package}::Execute"}(\$input);
            $row->{detachment_result} = $again;
        }
    }
    push @rows, $row;
}
open my $fh, '>', $output or die $!;
print {$fh} JSON::PP->new->canonical->ascii->encode(\@rows);
close $fh or die $!;
RUNNER
my $output = File::Spec->catfile($scratch, 'observations.json');
{
    local $ENV{PERL5LIB} = '';
    local $ENV{PERL5OPT} = '';
    is(system($^X, '-I'.File::Spec->catdir($root, 'perl'), $runner, $root, $request, $output),
       0, 'fresh emitted subprocess exits successfully');
}
if (-f $output) {
    my $rows = $json->decode(read_text($output));
    is(scalar(@$rows), scalar(@variants), 'fresh child returns every original/mutant artifact');
    for my $index (0..$#variants) {
        my ($variant, $row) = ($variants[$index], $rows->[$index]);
        is($row->{load_error}, '', "$variant->{id} emitted source loads independently");
        is($row->{contract_id}, 'linkedspec-generated-source-v2', "$variant->{id} retains v2 contract");
        is($row->{source_identity}, $variant->{source_identity} // "nested-tree/$variant->{id}",
           "$variant->{id} identity is exact");
        is($row->{plan_valid}, 1, "$variant->{id} generated plan validates");
        is(scalar(@{$row->{observations}}), scalar(@{$variant->{inputs}}),
           "$variant->{id} emitted execution sequence is complete");
        for my $case_index (0..$#{$variant->{inputs}}) {
            check_observation($variant->{inputs}[$case_index], $row->{observations}[$case_index],
                              "$variant->{id} emitted");
        }
        if (my $case = $variant->{detachment}) {
            check_observation({%$case, lossless => 1, label => 'after mutating a returned gap'},
                {value => $row->{detachment_result}, error => ''},
                "$variant->{id} emitted detachment");
        }
    }
} else {
    fail('fresh emitted subprocess wrote observations');
}
done_testing;
