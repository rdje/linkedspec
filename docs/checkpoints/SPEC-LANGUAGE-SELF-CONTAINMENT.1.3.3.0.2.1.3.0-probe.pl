use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use File::Path qw(make_path);
use LinkedSpec::ActionIR::StatementSplit ();
use LinkedSpec::ActionIR::StatementSplit::Mode ();

# Run from the repository root through tools/project_data_run.sh.
# Inputs and complete observations are retained by this leaf's capture JSON.
my $out = '.linkedspec-data/scratch/selfcontain13302130';
make_path($out);
my @rows;
my @mode_events;
my $original_pipe_mode = \&LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_pipe_quote;
my $bypass = 0;
my $bypass_hits = 0;
no warnings 'redefine';
local *LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_pipe_quote = sub {
    my ($state, $char) = @_;
    my $before = $state->{statement};
    # A diagnostic intervention only: restore the original callback below.
    # Intervene solely at the exact signature closer of the failing control.
    if ($bypass && $char eq '|' && $before =~ /\{\|x,y\z/) {
        ++$bypass_hits;
        return 0;
    }
    my $result = $original_pipe_mode->(@_);
    if ($char eq '|' && $before =~ /\{\|[^|]*\z/) {
        push @mode_events, { prefix => $before, returned => $result,
            in_pipe_quote => $state->{in_pipe_quote},
            segments => $state->{pipe_quote_segments_remaining} };
    }
    return $result;
};
for my $pair (
    ['xy', '{|x,y| return(x) }'],
    ['left-right', '{|left,right| return(left) }'],
    ['xz', '{|x,z| return(x) }'],
    ['y-first', '{|y,x| return(y) }'],
    ['rest-y', '{|x,...y| return(x) }'],
    ['ending-q', '{|x,q| return(x) }'],
    ['xy-intervention', '{|x,y| return(x) }'],
    ['xy-restored', '{|x,y| return(x) }'],
) {
    my ($id, $literal) = @$pair;
    my $action = 'finishBlock=' . $literal . '; return(finishBlock("ok","unused"))';
    my $source = 'Top:: I { ' . $action . ' }';
    $bypass = $id eq 'xy-intervention';
    @mode_events = ();
    $bypass_hits = 0;
    my $split = LinkedSpec::ActionIR::StatementSplit::_split_action_ir_statements(
        $action, { trim_action_ir_value => sub { my $s = shift; $s =~ s/^\s+|\s+$//g; $s } });
    my $ast = LinkedSpec::ActionIR::AST::parse_action_expr($literal);
    my $block_ast = LinkedSpec::ActionIR::AST::parse_action_block($action);
    my $substitution = LinkedSpec::call_spec_handler_subst('Top', $action);
    my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
    my ($dump, %ctx);
    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx,
        dump_parser_source => 1, parser_source_ref => \$dump);
    my $input = 'x';
    my ($value, $exception);
    my $ran = eval { $value = $parser->(\$input); 1 };
    $exception = "$@" unless $ran;
    my $emitted = LinkedSpec::emit_generated_source(\$source,
        source_identity => "literal-$id.spec");
    for my $file (['spec', $source], ['dump.pl', $dump // ''], ['pl', $emitted]) {
        open my $fh, '>', "$out/$id.$file->[0]" or die $!;
        print {$fh} $file->[1];
        close $fh or die $!;
    }
    push @rows, {
        id => $id, source => $source, literal => $literal, action => $action,
        source_sha256 => sha256_hex($source), ast => $ast,
        block_ast => $block_ast, statement_split => $split,
        pipe_mode_events => [@mode_events], diagnostic_bypass_hits => $bypass_hits,
        substitution => $substitution,
        metadata => $descriptor->{spec}{Top}{meta}{action_rewriter},
        native => { value => $value, error => $ctx{last_error}, exception => $exception },
        dump => $dump, emitted => $emitted,
        dump_sha256 => sha256_hex($dump // ''), emitted_sha256 => sha256_hex($emitted),
    };
}
open my $fh, '>', "$out/native.json" or die $!;
print {$fh} JSON::PP->new->canonical->pretty->encode(\@rows);
close $fh or die $!;
system($^X, '-Iperl',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.0-fresh.pl');
die "fresh child failed: $?" if $?;
print "literal controls captured with fresh emitted child\n";
