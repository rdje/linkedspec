use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::ActionIR::RewritePipeline ();
use LinkedSpec::ActionIR::ScannerCore ();
use LinkedSpec::ActionIR::SourceMembership ();
use LinkedSpec::ActionIR::Diagnostics ();
use LinkedSpec::ActionIR::CanonicalEvents::Core ();
use LinkedSpec::RuleIR::EmitContext ();
use JSON::PP ();
use Scalar::Util qw(blessed reftype refaddr);
use Encode qw(encode);
use Digest::SHA qw(sha256_hex);
use IPC::Open2 qw(open2);

my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0-';
my $fresh_path = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-fresh.pl';
my $json = JSON::PP->new->canonical->utf8;
sub project {
    my ($value) = @_;
    return [map { project($_) } @$value] if (reftype($value) // '') eq 'ARRAY';
    return {map(($_ => project($value->{$_})), keys %$value),
            blessed($value) ? (observed_class => blessed($value)) : ()}
        if (reftype($value) // '') eq 'HASH';
    return "$value" if ref($value);
    return $value;
}
sub digest { return sha256_hex(encode('UTF-8', $_[0])) }
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$file> }); close $file or die $!;
my $id = shift // die 'case required';
my @cases = grep { $_->{id} eq $id } @$cases; die 'one exact case required' unless @cases == 1;
my $case = $cases[0]; my ($source, $action) = @{$case}{qw(source action)};
my (@lookups, @scans, @canonicalization, $collection);
my (%identities, @retained);
sub identity {
    my ($value) = @_;
    return undef unless ref($value);
    my $address = refaddr($value);
    unless (exists $identities{$address}) {
        push @retained, $value;
        $identities{$address} = scalar @retained;
    }
    return $identities{$address};
}
my ($substitution, $diagnostics, $ast, $dump, $emitted, $descriptor);
my ($native_value, $native_failure, $compile_failure, %context, $stdout, $stderr);
$stdout = $stderr = '';
{
    open my $out, '>', \$stdout or die $!; open my $err, '>', \$stderr or die $!;
    local *STDOUT = $out; local *STDERR = $err;
    my $ok = eval {
        $ast = LinkedSpec::ActionIR::AST::parse_action_block($action);
        {
            my $find = \&LinkedSpec::ActionIR::RewritePipeline::_find_source_stmt_span;
            my $select = \&LinkedSpec::ActionIR::SourceMembership::_select_executable_source_events;
            my $collect = \&LinkedSpec::ActionIR::Diagnostics::_collect_action_helper_ir_nodes;
            my $canonical = \&LinkedSpec::ActionIR::CanonicalEvents::Core::canonicalize_helper_action_ir_event;
            no warnings 'redefine';
            local *LinkedSpec::ActionIR::RewritePipeline::_find_source_stmt_span = sub {
                my @args = @_; my @result = $find->(@args); my @caller = caller;
                push @lookups, {text => $args[0], raw => $args[1], start_pos => $args[2],
                    position => $result[0], length => $result[1], caller => $caller[1], line => $caller[2],
                    matched => $result[0] >= 0 ? substr($args[0], $result[0], $result[1]) : undef};
                return @result;
            };
            local *LinkedSpec::ActionIR::SourceMembership::_select_executable_source_events = sub {
                my ($text, $scan) = @_; my $result = $select->(@_);
                if (ref($result->{events}) eq 'ARRAY' && @{$result->{events}}) {
                    my %selected = map { refaddr($_) => 1 } @{$result->{events}};
                    push @scans, {source => $text,
                        events => [map { +{event_id => identity($_), args_id => identity($_->{args}),
                                            selected => $selected{refaddr($_)} ? 1 : 0, event => project($_)} }
                                        @{$scan->{events}}],
                        origins => [map { +{event_id => identity($_->{event}), source => $_->{source},
                                             source_span => project($_->{source_span})} }
                                         @{$scan->{source_origins}}]};
                }
                return $result;
            };
            local *LinkedSpec::ActionIR::Diagnostics::_collect_action_helper_ir_nodes = sub {
                my $result = $collect->(@_);
                $collection = {source => $_[0], events => [map { +{event_id => identity($_),
                    args_id => identity($_->{args}), event => project($_)} } @{$result->{helper_action_ir_events}}]};
                return $result;
            };
            local *LinkedSpec::ActionIR::CanonicalEvents::Core::canonicalize_helper_action_ir_event = sub {
                my $result = $canonical->(@_);
                push @canonicalization, {helper_id => identity($_[1]), helper_args_id => identity($_[1]{args}),
                    canonical_id => identity($result), canonical_args_id => identity($result->{args}),
                    helper => project($_[1]), canonical => project($result)};
                return $result;
            };
            $substitution = LinkedSpec::call_spec_handler_subst('Top', $action);
        }
        my $plain;
        ($plain, $diagnostics) = LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics('Top', $action, undef);
        die 'observer changed actual substitution' unless $plain eq $substitution;
        my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context,
            dump_parser_source => 1, parser_source_ref => \$dump,
            generated_source_identity => $id.'.spec');
        $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
        my $input = $case->{input};
        my $ran = eval { $native_value = $parser->(\$input); 1 };
        $native_failure = $@ unless $ran;
        $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => $id.'.spec');
        1;
    };
    $compile_failure = $@ unless $ok;
}
my $fresh;
if (defined $emitted) {
    my $pid = open2(my $child_out, my $child_in, $^X, '-Iperl', $fresh_path);
    binmode $child_in, ':raw'; binmode $child_out, ':raw';
    print {$child_in} $json->encode({emitted => $emitted, input => $case->{input}});
    close $child_in or die $!; my $reply = do { local $/; <$child_out> };
    close $child_out or die $!; waitpid($pid, 0); die 'fresh observer failed' if $?;
    $fresh = $json->decode($reply);
}
print $json->pretty->encode({id => $id, seed => $ENV{PERL_HASH_SEED}, source => $source,
    source_sha256 => digest($source), action => $action, ast => project($ast),
    substitution => $substitution, diagnostics => project($diagnostics),
    scans => \@scans, collection => $collection, canonicalization => \@canonicalization,
    lookups => \@lookups, dump => $dump, emitted => $emitted,
    metadata => $descriptor ? project($descriptor->{spec}{Top}{meta}{action_rewriter}) : undef,
    native => {value => project($native_value), exception => project($native_failure),
        compile_exception => project($compile_failure), context_error => project($context{last_error}),
        stdout => $stdout, stderr => $stderr}, fresh => $fresh});
