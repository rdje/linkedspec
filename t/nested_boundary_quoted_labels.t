use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::MethodLowering ();

my $json = JSON::PP->new->utf8->canonical;
open my $file, '<:raw', 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1-cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
for my $case (@$cases) {
    subtest $case->{id} => sub {
        if ($case->{node}) {
            my $before = $json->encode($case->{node});
            is(LinkedSpec::ActionIR::MethodLowering::_actionir_ast_value_source_expr($case->{node}),
                $case->{expected_source}, 'only agreeing recognized boundary atoms preserve lexical spelling');
            is($json->encode($case->{node}), $before, 'serialization never mutates the AST');
            return;
        }
        my $spec = "Top::\n I { $case->{action} }\na: /a/\nb: /b/\nc: /c/\nend: /END/\n";
        my %ctx;
        my ($value, $error, $built);
        {
            my ($stdout, $stderr) = ('', '');
            open my $out, '>', \$stdout or die $!;
            open my $err, '>', \$stderr or die $!;
            local *STDOUT = $out;
            local *STDERR = $err;
            my $parser = LinkedSpec::Get(\$spec, runtime_ctx_ref => \%ctx);
            $built = ref($parser);
            my $input = $case->{input};
            $value = $parser->(\$input);
            $error = $ctx{last_error};
        }
        is($built, 'CODE', 'public parser builds');
        if ($case->{failure_stage}) {
            ok(!defined($value), 'excluded grammar or separately owned quoted-source defect has no successful value');
            is($error->{stage}, $case->{failure_stage}, 'retains explicit original failure stage');
            return;
        }
        is_deeply($value, $case->{expected}, 'nested boundary capture preserves body, cursor and literal labels');
        ok(!defined($error), 'accepted runtime clears errors');
    };
}
done_testing;
