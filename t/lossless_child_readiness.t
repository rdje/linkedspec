use strict;
use warnings;
use utf8;
use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec ();
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use IPC::Open3 qw(open3);
use IO::Select ();
use Symbol qw(gensym);

my $ROOT = File::Spec->rel2abs("$Bin/..");
my $JSON = JSON::PP->new->canonical->ascii->allow_nonref;

sub read_text {
    open my $fh, '<:encoding(UTF-8)', $_[0] or die "read $_[0]: $!";
    local $/;
    return <$fh>;
}

sub clone_plain { return $JSON->decode($JSON->encode($_[0])); }

sub load_emitted {
    my ($source, $package) = @_;
    eval "package $package; $source; 1" or die $@;
    no strict 'refs';
    my $metadata = &{"${package}::LinkedSpecGeneratedMetadata"}();
    my $plan = &{"${package}::LinkedSpecGeneratedPlan"}();
    die 'wrong generated contract' unless $metadata->{contract_id} eq 'linkedspec-generated-source-v2';
    die 'invalid generated plan' unless &{"${package}::ValidateGeneratedPlan"}($plan);
    return *{"${package}::Execute"}{CODE};
}

# This adapter prepares authority and projects coordinates. The child parser alone
# recognizes the payload and constructs its semantic result.
sub make_options {
    my ($child, $child_digest, $calls, %change) = @_;
    my $caps = [qw(staged-parse-job-v2 typed-source-location-v1)];
    my $modes = [qw(fail sibling_field)];
    my $ceilings = {source_detail => 'span', max_steps => 100,
        max_result_nodes => 512, max_diagnostic_bytes => 4096};
    my $entry = {
        resolved_spec_id => 'registry:integer-v1',
        compiled_authority => sub {
            my ($request, $context) = @_;
            push @$calls, {text => $request->{text}, top => $request->{top_rule}};
            my $input = $request->{text};
            my $result = $child->(\$input);
            die 'child returned no AST' unless ref($result) eq 'HASH';
            $result->{source_span} = $context->rebase_span($result->{span});
            return $result;
        },
        content_digest => $child_digest,
        import_graph_fingerprint => 'sha256:'.sha256_hex(''),
        default_top_rule => 'Number', allowed_top_rules => ['Number'],
        spec_language_version => 2, helper_contract_version => 'actionir-v3',
        staged_contract_version => 2, capabilities => $caps,
        policy_modes => $modes, ceilings => $ceilings,
    };
    if ($change{forbidden_top}) {
        $entry->{default_top_rule} = 'Other';
        $entry->{allowed_top_rules} = ['Other'];
    }
    my $snapshot = {
        immutable => JSON::PP::true, prepared_before_authored_execution => JSON::PP::true,
        filesystem_access_during_dispatch => JSON::PP::false,
        aliases => $change{missing_identity} ? [] : [{
            declaring_spec_id => 'readiness/parent.spec', authored_id => 'integer',
            resolved_spec_id => 'registry:integer-v1',
        }],
        declaring_relative => [], search_roots => [], providers => [], entries => [$entry],
    };
    return {staged_ast_enrichment => {
        snapshot => $snapshot, declaring_spec_id => 'readiness/parent.spec',
        caller_capabilities => $caps, caller_policy_modes => $modes,
        caller_ceilings => $ceilings, required_source_detail => 'span',
        required_versions => {spec_language_version => 2,
            helper_contract_version => 'actionir-v3', staged_contract_version => 2},
        cancellation_token => 'lossless-child-readiness', cancelled => sub { 0 }, clock => sub { 0 },
        deadline => 100, remaining_steps => $change{no_budget} ? 0 : 100,
        required_steps => 1, max_depth => 4, max_calls => $change{one_call} ? 1 : 16,
    }};
}

sub observe {
    my ($parent, $text, $options, $calls) = @_;
    @$calls = ();
    my $input = $text;
    my $value;
    my $ok = eval { $value = $parent->(\$input, $options); 1 };
    my $error = $@;
    my $record = {ok => $ok ? 1 : 0, value => $value, calls => clone_plain($calls)};
    if (!$ok) {
        $record->{error} = LinkedSpec::StagedASTEnrichment::is_error($error)
            ? {type => ref($error), map { exists($error->{$_}) ? ($_ => $error->{$_}) : () }
                qw(code phase source_provenance)}
            : {type => ref($error), message => "$error"};
    }
    return $record;
}

sub run_routes {
    my ($parent, $child, $digest, $cases, $child_cases, $mutants) = @_;
    require LinkedSpec::Trace;
    LinkedSpec::Trace::configure_trace(trace_level => -1, trace_log_file => '', trace_log_mode => 'stdout');
    my @calls;
    my $options = make_options($child, $digest, \@calls);
    my @rows;
    for my $round (1, 2) {
        for my $case (@$cases) {
            push @rows, {id => $case->{id}, round => $round,
                observation => observe($parent, $case->{input}, $options, \@calls)};
        }
    }
    my %negative;
    $negative{child_reject} = observe($parent, '[12][00][7]', $options, \@calls);
    $negative{recovery} = observe($parent, '[8]', $options, \@calls);
    for my $kind (qw(missing_identity forbidden_top no_budget one_call)) {
        my $changed = make_options($child, $digest, \@calls, $kind => 1);
        $negative{$kind} = observe($parent, '[1][2]', $changed, \@calls);
    }
    my $detached = observe($parent, 'α[12]🙂', $options, \@calls);
    $detached->{value}{ast}[1]{parsed}{text} = 'changed returned child';
    $detached->{value}{ast}[1]{parsed}{source_span}{start} = 999;
    my $again = observe($parent, 'α[12]🙂', $options, \@calls);

    @calls = ();
    my $inert_input = 'α[12]🙂';
    my $inert = $parent->(\$inert_input);
    my $marker = $inert->[1]{child};
    my $inert_result = {
        calls => scalar(@calls), is_marker => LinkedSpec::StagedParseJob::is_marker($marker),
        marker => LinkedSpec::StagedParseJob::marker_record($marker),
        sidecar => LinkedSpec::StagedParseJob::sidecar_record($marker),
    };
    my @strict;
    for my $input ((map { $_->{input} } @{$child_cases->{accept}}), @{$child_cases->{reject}}) {
        my $value = eval { $child->(\$input) };
        my $error = $@;
        push @strict, {input => $input, value => $value, error => ref($error) || "$error",
            status => ref($error) eq 'LinkedSpec::RuntimeExitNow' ? $error->{status} : undef};
    }
    my %mutation;
    for my $id (sort keys %$mutants) {
        my $variant = $mutants->{$id};
        my $mutant_options = make_options($variant->{child} // $child,
            $variant->{digest} // $digest, \@calls);
        $mutation{$id} = observe($variant->{parent} // $parent,
            $id eq 'leading_zero' ? '[00]' : 'α[12]🙂', $mutant_options, \@calls);
    }
    return {rows => \@rows, negative => \%negative, detachment => $again,
        inert => $inert_result, strict => \@strict, mutations => \%mutation};
}

# The isolated process receives only already-emitted text. It cannot call Get or
# generate code; absence of the compiler is checked after all executions.
if (@ARGV && $ARGV[0] eq '--emitted-child') {
    local $/;
    my $request = $JSON->decode(<STDIN>);
    my $parent = load_emitted($request->{parent}, 'Readiness::FreshParent');
    my $child = load_emitted($request->{child}, 'Readiness::FreshChild');
    my %mutants;
    for my $id (sort keys %{$request->{mutants}}) {
        my $variant = $request->{mutants}{$id};
        $mutants{$id} = {%$variant,
            $variant->{role} => load_emitted($variant->{source}, "Readiness::Fresh_$id")};
    }
    my $result = run_routes($parent, $child, $request->{digest}, $request->{cases},
        $request->{child_cases}, \%mutants);
    $result->{compiler_loaded} = exists($INC{'LinkedSpec/Compiler.pm'}) ? 1 : 0;
    print $JSON->encode($result);
    exit 0;
}

require Test::More;
Test::More->import;
require LinkedSpec;
my $fixture = File::Spec->catdir($ROOT, qw(tests language-readiness lossless-child));
my $parent_source = read_text(File::Spec->catfile($fixture, 'parent.spec'));
my $child_source = read_text(File::Spec->catfile($fixture, 'child.spec'));
my $digest = 'sha256:'.sha256_hex($child_source);
my $child_cases = $JSON->decode(read_text(File::Spec->catfile($fixture, 'cases.json')));
my $cases = $JSON->decode(read_text(File::Spec->catfile($ROOT,
    qw(tests language-readiness lossless-segments cases.json))))->{accept};
my %by_id = map { $_->{id} => $_ } @$cases;
my $parent = LinkedSpec::Get(\$parent_source);
my $child = LinkedSpec::Get(\$child_source);
ok(ref($parent) eq 'CODE', 'staged parent compiles');
ok(ref($child) eq 'CODE', 'real child grammar compiles');
die 'cannot execute readiness matrix' unless ref($parent) eq 'CODE' && ref($child) eq 'CODE';
my $descriptor = LinkedSpec::Get(\$parent_source, return_descriptor => 1);
my $rewriter = $descriptor->{spec}{Item}{meta}{action_rewriter};
my @markers = grep { ($_->{kind} // '') eq 'STAGED_PARSE_JOB_MARKER' }
    @{$rewriter->{canonical_action_ir_events} // []};
is(scalar(@markers), 1, 'parent lowers exactly one dedicated staged declaration');
is_deeply($rewriter->{unresolved_helpers} // [], [], 'parent marker has no unresolved helper');
is($rewriter->{raw_perl_dependency_count} // 0, 0, 'parent marker has no raw host dependency');
ok($rewriter->{language_agnostic_action_ir_ready}, 'parent marker uses portable ActionIR');

my $parent_emitted = LinkedSpec::emit_generated_source(\$parent_source, source_identity => 'readiness/parent.spec');
my $child_emitted = LinkedSpec::emit_generated_source(\$child_source, source_identity => 'readiness/child.spec');
my $emitted_parent = load_emitted($parent_emitted, 'Readiness::MixedParent');
my $emitted_child = load_emitted($child_emitted, 'Readiness::MixedChild');
my ($leading_zero, $wrong_span, $whole_item) = ($child_source, $child_source, $parent_source);
is(($leading_zero =~ s/\Q(0|[1-9][0-9]*)\E/([0-9]+)/), 1, 'child mutation admits leading zeroes');
is(($wrong_span =~ s/"start", entry_start_pos\(\)/"start", num_add(entry_start_pos(), 1)/), 1,
   'child mutation shifts its local span');
is(($whole_item =~ s/parse_job\(entry_group\(0\)/parse_job(entry_text()/), 1,
   'parent mutation includes neighboring delimiters');
my (%native_mutants, %emitted_mutants, %serialized_mutants);
for my $variant (
    ['leading_zero', 'child', $leading_zero], ['wrong_span', 'child', $wrong_span],
    ['whole_item', 'parent', $whole_item],
) {
    my ($id, $role, $source) = @$variant;
    my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => "readiness/$id.spec");
    my $variant_digest = $role eq 'child' ? 'sha256:'.sha256_hex($source) : $digest;
    $native_mutants{$id} = {$role => LinkedSpec::Get(\$source), digest => $variant_digest};
    $emitted_mutants{$id} = {$role => load_emitted($emitted, "Readiness::Mutant_$id"), digest => $variant_digest};
    $serialized_mutants{$id} = {role => $role, source => $emitted, digest => $variant_digest};
}
my %routes = (
    native => run_routes($parent, $child, $digest, $cases, $child_cases, \%native_mutants),
    native_emitted_child => run_routes($parent, $emitted_child, $digest, $cases, $child_cases,
        {map { $_ => ($_ eq 'whole_item' ? $native_mutants{$_} : $emitted_mutants{$_}) } keys %native_mutants}),
    emitted_parent_native_child => run_routes($emitted_parent, $child, $digest, $cases, $child_cases,
        {map { $_ => ($_ eq 'whole_item' ? $emitted_mutants{$_} : $native_mutants{$_}) } keys %native_mutants}),
);

my ($writer, $reader, $errors) = (gensym, gensym, gensym);
my ($pid, $stdout, $stderr);
{
    local $ENV{PERL5LIB} = '';
    local $ENV{PERL5OPT} = '';
    $pid = open3($writer, $reader, $errors, $^X, '-I'.File::Spec->catdir($ROOT, 'perl'),
        File::Spec->catfile($ROOT, 't', 'lossless_child_readiness.t'), '--emitted-child');
}
print {$writer} $JSON->encode({parent => $parent_emitted, child => $child_emitted,
    digest => $digest, cases => $cases, child_cases => $child_cases,
    mutants => \%serialized_mutants}) or die "write child input: $!";
close $writer or die "close child input: $!";
($stdout, $stderr) = ('', '');
my $stdout_fd = fileno($reader);
my $selector = IO::Select->new($reader, $errors);
while ($selector->count) {
    for my $fh ($selector->can_read) {
        my $bytes = sysread($fh, my $chunk, 65536);
        die "read child output: $!" unless defined $bytes;
        if (!$bytes) { $selector->remove($fh); close $fh; next; }
        if (fileno($fh) == $stdout_fd) { $stdout .= $chunk; } else { $stderr .= $chunk; }
    }
}
waitpid($pid, 0);
is($?, 0, 'fresh emitted parent/child process exits successfully');
is($stderr, '', 'fresh emitted process has no unexpected diagnostics');
my $fresh = eval { $JSON->decode($stdout) };
ok(ref($fresh) eq 'HASH', 'fresh emitted process returns structured observations') or diag($@, $stdout);
if (ref($fresh) eq 'HASH') {
    is(delete($fresh->{compiler_loaded}), 0, 'fresh execution never loads the compiler');
    $routes{fresh_emitted} = $fresh;
}

sub assert_composition {
    my ($observed, $case, $label) = @_;
    subtest($label, sub {
        is($observed->{ok}, 1, 'composed parse succeeds');
        return unless $observed->{ok};
        my $value = $observed->{value};
        my $plain = clone_plain($value->{ast});
        my (@requests, @sidecar_paths, @provenance);
        for my $index (0..$#{$case->{expected}}) {
            my $original = $case->{expected}[$index];
            next unless $original->{kind} eq 'item';
            my $digits = substr($original->{text}, 1, length($original->{text}) - 2);
            my $span = {kind => 'direct_span', source_id => 'input',
                start => $original->{span}[0] + 1, end => $original->{span}[1] - 1,
                provenance => 'entry_group'};
            my $expected = {kind => 'integer', text => $digits,
                span => {start => 0, end => length($digits)}, source_span => $span};
            is($plain->[$index]{child}, $digits, 'stitch preserves the exact bounded child text');
            is($JSON->encode($plain->[$index]{parsed}), $JSON->encode($expected),
               'real child result and local/global scalar spans are exact');
            delete @{$plain->[$index]}{qw(child parsed)};
            push @requests, {text => $digits, top => 'Number'};
            push @sidecar_paths, [$index, 'child'];
            push @provenance, $span;
        }
        is($JSON->encode($plain), $JSON->encode($case->{expected}),
           'the entire original segmentation oracle survives enrichment');
        is(join('', map { $_->{text} } @$plain), $case->{input}, 'original input reconstructs after stitching');
        is_deeply($observed->{calls}, \@requests, 'only the exact authorized child inputs execute in order');
        is_deeply([map { $_->{parent_ast_path} } @{$value->{sidecars}}], \@sidecar_paths,
                  'sidecars name the exact item payloads');
        is_deeply([map { $_->{provenance} } @{$value->{sidecars}}], \@provenance,
                  'sidecar provenance agrees with independently authored item coordinates');
        for my $sidecar (@{$value->{sidecars}}) {
            is($sidecar->{resolved_spec_id}, 'registry:integer-v1', 'logical identity resolves to the frozen entry');
            is($sidecar->{top_rule}, 'Number', 'authorized child entry is selected');
            is($sidecar->{state}, 'succeeded', 'child execution completed');
        }
        is($value->{resources}{total_calls}, scalar(@requests), 'shared accounting counts only child calls');
        is($value->{cache}{misses}, @requests ? 1 : 0, 'each invocation starts with a fresh cache');
        is($value->{cache}{hits}, @requests ? @requests - 1 : 0, 'only sibling jobs reuse the prepared plan');
        is_deeply($value->{diagnostics}, [], 'successful composition has no retained diagnostic');
    });
}

my $recovery_case = {input => '[8]', expected => clone_plain($by_id{single_zero}{expected})};
$recovery_case->{expected}[1]{text} = '[8]';
for my $name (sort keys %routes) {
    my $route = $routes{$name};
    is(scalar(@{$route->{rows}}), 2 * @$cases, "$name executes both full original sequences");
    for my $row (@{$route->{rows}}) {
        assert_composition($row->{observation}, $by_id{$row->{id}}, "$name $row->{id} round $row->{round}");
    }
    assert_composition($route->{negative}{recovery}, $recovery_case, "$name recovers after child rejection");
    assert_composition($route->{detachment}, $by_id{unicode_edges}, "$name child result remains detached");
    for my $denial (
        ['child_reject', 'staged_child_failed', 2],
        ['missing_identity', 'staged_registry_missing', 0],
        ['forbidden_top', 'staged_top_rule_forbidden', 0],
        ['no_budget', 'staged_budget_exhausted', 0],
        ['one_call', 'staged_call_limit_exceeded', 1],
    ) {
        my ($id, $code, $count) = @$denial;
        my $observed = $route->{negative}{$id};
        is($observed->{ok}, 0, "$name $id rejects");
        is($observed->{error}{type}, 'LinkedSpec::StagedASTEnrichment::Error', "$name $id preserves typed failure");
        is($observed->{error}{code}, $code, "$name $id has the exact authority diagnostic");
        is(scalar(@{$observed->{calls}}), $count, "$name $id has the exact child execution count");
        ok(!defined($observed->{value}), "$name $id publishes no partial parent AST");
    }
    is($route->{inert}{is_marker}, 1, "$name without a seed returns an inert marker");
    is($route->{inert}{calls}, 0, "$name without a seed executes no child");
    is($route->{inert}{sidecar}{text}, '12', "$name inert declaration retains source-bound text");
    subtest("$name strict child grammar", sub {
        my @observed = @{$route->{strict}};
        for my $case (@{$child_cases->{accept}}) {
            my $row = shift @observed;
            is($row->{input}, $case->{input}, 'accepted child control executed');
            is($row->{error}, '', 'accepted child has no error');
            is_deeply($row->{value}, $case->{expected}, 'child itself constructs the exact AST');
        }
        for my $input (@{$child_cases->{reject}}) {
            my $row = shift @observed;
            is($row->{input}, $input, 'rejected child control executed');
            is($row->{error}, 'LinkedSpec::RuntimeExitNow', 'strict child rejects with typed error');
            is($row->{status}, 1, 'child rejection status is exact');
            ok(!defined($row->{value}), 'child publishes no partial AST');
        }
        is(scalar(@observed), 0, 'all strict controls consumed');
    });
    subtest("$name three falsification controls", sub {
        my $zero = $route->{mutations}{leading_zero};
        is($zero->{ok}, 1, 'permissive child wrongly accepts [00]');
        is_deeply($zero->{value}{ast}[1]{parsed}, {kind => 'integer', text => '00',
            span => {start => 0, end => 2}, source_span => {kind => 'direct_span', source_id => 'input',
                start => 1, end => 3, provenance => 'entry_group'}}, 'wrong child result is fully pinned');
        my $span = $route->{mutations}{wrong_span};
        is($span->{ok}, 1, 'wrong span does not alter recognition');
        is_deeply($span->{value}{ast}[1]{parsed}{span}, {start => 1, end => 2}, 'wrong local span pinned');
        is_deeply($span->{value}{ast}[1]{parsed}{source_span}, {kind => 'direct_span', source_id => 'input',
            start => 3, end => 4, provenance => 'entry_group'}, 'wrong rebased span pinned');
        isnt($JSON->encode($span->{value}{ast}[1]{parsed}),
            $JSON->encode($route->{detachment}{value}{ast}[1]{parsed}), 'original exact child oracle detects span drift');
        my $whole = $route->{mutations}{whole_item};
        is($whole->{ok}, 0, 'delimiter-inclusive operand fails the strict child');
        is($whole->{error}{code}, 'staged_child_failed', 'wrong source-bound operand has typed rejection');
        is_deeply($whole->{calls}, [{text => '[12]', top => 'Number'}], 'mutant exposes exact over-wide request');
        ok(!defined($whole->{value}), 'wrong operand publishes no parent value');
    });
}
for my $name (sort grep { $_ ne 'native' } keys %routes) {
    is($JSON->encode($routes{$name}), $JSON->encode($routes{native}),
       "$name preserves the complete native observations, sidecars and resource accounting");
}
done_testing();
