use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::CodeblockRuntime ();

my $body = <<'BODY';
 chosen = [[1]]; out = (( chosen[0][0] = 2 )); chosen[0][0] = 3;
 entries = [1]; appended = (entries += 2); entries[0] = 9;
 meta = {}; stored = (meta["key"] = 7); meta["key"] = 8;
 scalar = (created = 9);
 argument = count((chosen[0][0] = 4));
 receiver = (chosen[0][0] = 5).count();
 effects = ""; ordered = [[0]];
 ordered_value = (ordered[{ effects = cat(effects,"a"); 0 }][{ effects = cat(effects,"b"); 0 }] = { effects = cat(effects,"c"); 7 });
 return([out,chosen,appended,entries,stored,meta,scalar,created,argument,receiver,ordered_value,effects,grouped_case()]);
BODY
my $source = "fn grouped_case() { saved = (fresh[0][0] = 2); return([saved,fresh]) }\nTop:: I { $body }";
my $expected = [[[2]],[[5]],[1,2],[9,2],{key=>7},{key=>8},9,9,1,1,[[7]],'abc',[[[2]],[[2]]]];
my $json = JSON::PP->new->canonical;
my %context;
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
my $input = 'x';
my $actual = $parser->(\$input);
is($context{last_error}, undef, 'grouped assignment handler compiles and executes');
is($json->encode($actual), $json->encode($expected), 'stored, argument, receiver and function values keep effects and detached roots');

my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'grouped-assignment.spec');
my $loaded = eval "package LinkedSpec::GroupedAssignmentGenerated; $emitted; 1";
ok($loaded, 'fresh emitted grouped assignment parser compiles') or diag($@);
if ($loaded) {
    my $fresh_input = 'x';
    is($json->encode(LinkedSpec::GroupedAssignmentGenerated::Execute(\$fresh_input)),
        $json->encode($expected), 'fresh parser preserves grouped assignment values');
}

my $group = LinkedSpec::ActionIR::AST::parse_action_expr('(chosen[0][0]=2)');
is($group->{kind}, 'raw_perl', 'public AST grouping boundary is unchanged');
my $callback = LinkedSpec::ActionIR::AST::parse_action_expr('{|| chosen=[[1]]; return((chosen[0][0]=2)) }');
my $error;
eval { LinkedSpec::CodeblockRuntime::invoke($callback, [], {}, 'deferred-group', undef, {}, {}); 1 }
    or $error = $@;
like("$error", qr/LINKEDSPEC_CODEBLOCK_RUNTIME_ERROR:unsupported_codeblock_actionir/,
    'deferred raw grouped assignment retains its specific rejection');

done_testing() unless caller;
1;
