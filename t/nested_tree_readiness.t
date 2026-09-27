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
            is($result->{status}, 1, 'grammar rejection status is exact');
            ok(!defined($result->{value}), 'no partial value escapes');
        } else {
            is($result->{error}, '', 'execution succeeds');
            if (($case->{mutation} // '') eq 'accepts_rejected') {
                is(ref($result->{value}), 'ARRAY', 'mutant wrongly accepts a document value');
                ok(@{$result->{value} || []} > 0, 'valid surrounding forms survive the wrong acceptance');
            } elsif (($case->{mutation} // '') eq 'changes_span') {
                is(ref($result->{value}), 'ARRAY', 'span mutant still returns a document');
                is_deeply($result->{value}[0]{span}, [9, 9],
                          'the controlled mutation replaces the original start with the end');
                isnt($json->encode($result->{value}), $json->encode($case->{expected}),
                     'unchanged authored oracle detects the span mutation');
            } else {
                is($json->encode($result->{value}), $json->encode($case->{expected}),
                   'exact independent typed AST and Unicode spans');
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
    }
    my $generated = LinkedSpec::emit_generated_source(
        \$variant->{source}, source_identity => "nested-tree/$variant->{id}");
    my $path = File::Spec->catfile($scratch, "$variant->{id}.pl");
    write_text($path, $generated);
    push @artifacts, {path => File::Spec->abs2rel($path, $root),
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
        is($row->{source_identity}, "nested-tree/$variant->{id}", "$variant->{id} identity is exact");
        is($row->{plan_valid}, 1, "$variant->{id} generated plan validates");
        is(scalar(@{$row->{observations}}), scalar(@{$variant->{inputs}}),
           "$variant->{id} emitted execution sequence is complete");
        for my $case_index (0..$#{$variant->{inputs}}) {
            check_observation($variant->{inputs}[$case_index], $row->{observations}[$case_index],
                              "$variant->{id} emitted");
        }
    }
} else {
    fail('fresh emitted subprocess wrote observations');
}
done_testing;
