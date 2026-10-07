use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();

# These literal intervals/arguments were authored for the private selector
# before the compiler bridge existed. Do not derive expectations by selecting
# the compiler's own output.
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0-';
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = JSON::PP->new->utf8->decode(do { local $/; <$file> });
close $file or die $!;
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');

for my $case (@$cases) {
    subtest $case->{id} => sub {
        my $source = $case->{source};
        my $contract = {id => $case->{contract}};
        my $syntactic = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events($contract, $source, $deps);
        my $snapshot = JSON::PP->new->canonical->encode($syntactic);
        my ($produced, $selected);
        my $original = \&LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance;
        {
            no warnings 'redefine';
            local *LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance = sub {
                $produced = $original->(@_);
                return $produced;
            };
            $selected = LinkedSpec::RuleIR::EmitContext::_scan_contract_ir_events($contract, $source);
        }
        is_deeply([map { {raw => $_->{raw}, args => $_->{args}} } @$selected],
            [map { {raw => $_->{raw}, args => $_->{args}} } @{$case->{events}}],
            'compiler selects independently authored occurrences and original arguments in order');
        is($source, $case->{source}, 'source bytes remain unchanged');
        is(JSON::PP->new->canonical->encode($syntactic), $snapshot, 'syntactic scan remains untouched');
        ok($produced, 'compiler calls actual provenance producer');
        if ($produced) {
            is_deeply($produced->{events}, $syntactic, 'provenance receives original syntactic arguments');
            for my $event (@$selected) {
                ok(grep({ refaddr($_) == refaddr($event) } @{$produced->{events}}),
                    'selected event is original producer reference');
                ok(grep({ refaddr($_->{args}) == refaddr($event->{args}) } @{$produced->{events}}),
                    'selected argument object is original producer reference');
                ok(!exists($event->{source_span}) && !exists($event->{source_origins}),
                    'public event shape remains unchanged');
            }
        }
    };
}

subtest 'compiler bridge preserves callback and caller error contracts' => sub {
    my $source = '"set(counter,1)"; set(counter,2)';
    my $split = $deps->{split_action_ir_statements};
    my $calls = 0;
    my $custom = {%$deps, split_action_ir_statements => sub { ++$calls; return $split->(@_) }};
    if (LinkedSpec::ActionIR::Scanner->can('_scan_executable_contract_ir_events')) {
        $@ = 'outer caller error';
        my $events = LinkedSpec::ActionIR::Scanner::_scan_executable_contract_ir_events(
            {id => 'set_value'}, $source, $custom);
        my $error = $@;
        is($error, 'outer caller error', 'caller error survives successful compiler selection');
        is_deeply([map { $_->{raw} } @$events], ['set(counter,2)'], 'real dependency scan selects executable occurrence');
        my $ran = eval {
            LinkedSpec::ActionIR::Scanner::_scan_executable_contract_ir_events({id => 'set_value'}, $source, {});
            1;
        };
        ok(!$ran, 'missing real dependencies still fail');
        like($@, qr/missing dependency callback 'split_action_ir_statements'/, 'original missing dependency error');
        my $fatal = {%$deps, split_action_ir_statements => sub { die "authored split failure\n" }};
        $ran = eval {
            LinkedSpec::ActionIR::Scanner::_scan_executable_contract_ir_events({id => 'my_declare_bare'}, 'my counter', $fatal);
            1;
        };
        ok(!$ran, 'dependency exception propagates');
        is($@, "authored split failure\n", 'dependency failure retains its exact error');
    } else {
        fail('compiler executable scan entry exists');
    }
};

subtest 'native and independently loaded generated parsers preserve quoted data' => sub {
    my @examples = (
        ['return("set(counter, 2)")', 'set(counter, 2)'],
        ['return(cat("set(counter, 2)","; if(true); return(inner)"))', 'set(counter, 2); if(true); return(inner)'],
        ['return(matches("ifXtrue", /if(true)/))', 0],
        ['return(matches("if(true)", /if\\(true\\)/))', 1],
        [q{return(' 雪 '.trim())}, '雪'],
        ['return("return(inner); if(true)")', 'return(inner); if(true)'],
    );
    my $index = 0;
    for my $example (@examples) {
        my ($action, $expected) = @$example;
        ++$index;
        my $source = 'Top:: I { '.$action.' }';
        my (%context, $dump);
        my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context,
            dump_parser_source => 1, parser_source_ref => \$dump, generated_source_identity => 'membership.spec');
        my $input = '';
        my $value = eval { $parser->(\$input) };
        is_deeply($value, $expected, 'native literal value '.$index);
        ok(!$context{last_error}, 'native execution has no context error');
        my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'membership.spec');
        is($dump, $emitted, 'public dump and emitted source agree');
        my $package = 'CompilerMembership::Generated'.$index;
        my $loaded = eval "package $package; $emitted; 1";
        ok($loaded, 'standalone generated module loads') or diag($@);
        $input = '';
        my $execute = $package->can('Execute');
        my $fresh = eval { $execute->(\$input) };
        is_deeply($fresh, $expected, 'independently loaded emitted value');
    }
};

done_testing();
