use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::RuleIR::EmitContext ();

my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1-';
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = JSON::PP->new->utf8->decode(do { local $/; <$file> });
close $file or die $!;
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');

for my $case (@$cases) {
    subtest $case->{id} => sub {
        my $events = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
            {id => 'capture_until_boundary'}, $case->{action}, $deps);
        if (!defined $case->{labels}) {
            is_deeply($events, [], 'unsupported forms stay outside the existing helper grammar');
            return;
        }
        is_deeply($events, [map { {raw => $case->{raw}, args => {boundaries => $case->{labels}}} }
            @{$case->{intervals}}], 'quoted commas and escapes retain whole decoded labels and original repeated raw calls');
        for my $interval (@{$case->{intervals}}) {
            is(substr($case->{action}, $interval->[0], $interval->[1]-$interval->[0]),
                $case->{raw}, 'independent scalar interval selects the original Unicode/CRLF occurrence');
        }
        my @quoted = map { my $label = $_; $label =~ s/\\/\\\\/g; $label =~ s/'/\\'/g; "'$label'" } @{$case->{labels}};
        my $lowered = LinkedSpec::call_spec_handler_subst('Top', $case->{raw});
        my $assignment = 'my @__ls_boundary_labels = ('.join(', ', @quoted).');';
        like($lowered, qr/\Q$assignment\E/,
            'public lowering emits exactly the whole boundary labels');
        my $spec = "Top::\n I { body = $case->{raw}; return(hash(\"body\", body, \"cursor\", cursor_pos(), \"rest\", cursor_rest())) }\n\na: /a/\nb: /b/\nc: /c/\nend: /END/\n";
        my %runtime_ctx;
        my $parser = LinkedSpec::Get(\$spec, runtime_ctx_ref => \%runtime_ctx);
        ok(ref($parser) eq 'CODE', 'public parser builds with existing rule definitions');
        my $input = $case->{input};
        is_deeply($parser->(\$input), $case->{expected}, 'whole labels preserve boundary selection, EOF/no-usable behavior and cursor');
        ok(!defined($runtime_ctx{last_error}), 'runtime has no error');
    };
}

done_testing;
