use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

my $json = JSON::PP->new->canonical->ascii->allow_nonref;
my $sequence = 0;

sub read_file {
    my ($path) = @_;
    open my $fh, '<:encoding(UTF-8)', $path or die "cannot read $path: $!";
    local $/;
    my $text = <$fh>;
    close $fh or die $!;
    return $text;
}

sub error_value {
    my ($error) = @_;
    return undef unless defined($error) && (ref($error) || length($error));
    if ((reftype($error) // '') eq 'HASH') {
        my %result = map { $_ => ref($error->{$_}) ? error_value($error->{$_}) : $error->{$_} }
            grep { exists $error->{$_} } qw(type code stage detail summary helper_name name phase rule_label source_id invocation_id accessor);
        $result{class} = ref($error) if ref($error) ne 'HASH';
        return \%result;
    }
    return "$error";
}

sub observe_source {
    my ($source, $input, $rule) = @_;
    my (%context, @warnings, %result);
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    my $native = eval { LinkedSpec::Get(\$source, runtime_ctx_ref => \%context) };
    $result{build_error} = error_value($@);
    $result{native_callable} = ref($native) eq 'CODE' ? 1 : 0;
    if ($result{native_callable}) {
        my $text = $input;
        $result{native} = eval { $native->(\$text) };
        $result{native_error} = error_value($@ || $context{last_error});
        $result{native_cursor} = pos($text);
    }
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'cursor-statement-scope.spec') };
    $result{emission_error} = error_value($@);
    my $package = 'LinkedSpec::CursorStatementScope'.++$sequence;
    my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
    $result{loaded} = $loaded ? 1 : 0;
    $result{load_error} = error_value($@);
    if ($loaded) {
        my $text = $input;
        $result{fresh} = eval { $package->can('Execute')->(\$text) };
        $result{fresh_error} = error_value($@);
        $result{fresh_cursor} = pos($text);
    }
    my $descriptor = eval { LinkedSpec::Get(\$source, return_descriptor => 1) };
    $result{descriptor_error} = error_value($@);
    my $meta = $descriptor->{spec}{$rule}{meta}{action_rewriter};
    $result{metadata} = {map { $_ => $meta->{$_} } qw(canonical_action_ir_fallback_count raw_perl_dependency_count unresolved_helper_count unresolved_helpers language_agnostic_action_ir_ready)};
    $result{warnings} = \@warnings;
    return \%result;
}

sub check_source {
    my ($name, $source, $input, $expected, $cursor, $rule, $unsupported) = @_;
    return if @ARGV && !grep { $_ eq $name } @ARGV;
    $unsupported //= [];
    subtest $name => sub {
        my $actual = observe_source($source, $input, $rule);
        diag('CURSOR_STATEMENT_SCOPE_ACTUAL '.$name.' '.$json->encode($actual));
        ok($actual->{native_callable} && !$actual->{build_error} && !$actual->{native_error}, 'native executes without handler error');
        is($json->encode($actual->{native}), $json->encode($expected), 'native exact values and kinds');
        is($actual->{native_cursor}, $cursor, 'native cursor preserved');
        ok($actual->{loaded} && !$actual->{emission_error} && !$actual->{load_error}, 'fresh source loads');
        ok($actual->{loaded} && !$actual->{fresh_error}, 'fresh execution succeeds');
        is($json->encode($actual->{fresh}), $json->encode($expected), 'fresh exact values and kinds');
        is($actual->{fresh_cursor}, $cursor, 'fresh cursor preserved');
        ok(!$actual->{descriptor_error}, 'descriptor resolves');
        is_deeply($actual->{warnings}, [], 'build/load/run stay warning-free');
        my $meta = $actual->{metadata};
        is($meta->{raw_perl_dependency_count}, 0, 'no raw dependency');
        is($meta->{canonical_action_ir_fallback_count}, 0, 'no fallback executor');
        if (@$unsupported) {
            ok(!$meta->{language_agnostic_action_ir_ready}, 'pure-function state access remains unready');
            my %found = map { $_ => 1 } @{$meta->{unresolved_helpers} // []};
            ok($found{$_}, "specific forbidden helper $_ retained") for @$unsupported;
        } else {
            is($meta->{unresolved_helper_count}, 0, 'ordinary sources resolve');
            ok($meta->{language_agnostic_action_ir_ready}, 'readiness accompanies actual execution');
        }
    };
}


# TYPE-REFERENCE-BOOK.1.2.23.3.56.0 — ordinary eager statement/local-return scope.
sub carrier {
    my ($body) = @_;
    return "Top::\n -> Value[entry] {return(call(Value))}\nValue:\n entry=/ab/\n colon=/:/\n -> Value[colon] {$body}\n";
}
for my $case (['save_cursor',5],['restore_cursor',5],['rewind_entry_start',2],['rewind_match_start',4]) {
    my ($helper,$position)=@$case;
    my $body='save_cursor();order="";kept="kept".with(){'.$helper.'();order=cat(order,"W");return(value)}.uppercase().cat({order=cat(order,"C");cursor_pos()});restore_cursor();return([kept,order,cursor_pos()]);';
    check_source("with body $helper retains local return",carrier($body),'zzab:cd',
        ['KEPT'.$position,'WC',5],5,'Value');
}
check_source('eager restore scalar return stays local',carrier(
    'save_cursor();rewind_entry_start();order="";kept={restore_cursor();return("x")};order=cat(order,"C");return([kept.uppercase(),order,cursor_pos()]);'),
    'zzab:cd',['X','C',5],5,'Value');
check_source('eager rewind Array return retains kinds and continuation',carrier(
    'save_cursor();order="";kept={rewind_match_start();return([false,0,"tail"])};order=cat(order,"C");restore_cursor();return([kept[-1].uppercase(),kept[0],kept[1],order,cursor_pos()]);'),
    'zzab:cd',['TAIL',JSON::PP::false,0,'C',5],5,'Value');
check_source('nonfinal with return skips later statements but resumes outer chain',carrier(
    'save_cursor();order="";kept="kept".with(){rewind_entry_start();return(value);order=cat(order,"BAD")}.uppercase().cat({order=cat(order,"C");cursor_pos()});restore_cursor();return([kept,order,cursor_pos()]);'),
    'zzab:cd',['KEPT2','C',5],5,'Value');
check_source('primitive cursor bodies preserve return kinds anchors and restore',carrier(
    'save_cursor();p0=cursor_pos();v0=rewind_entry_start();p1=cursor_pos();v1=rewind_match_start();p2=cursor_pos();v2=restore_cursor();p3=cursor_pos();return([p0,v0,p1,v1,p2,v2,p3]);'),
    'zzab:cd',[5,2,2,4,4,undef,5],5,'Value');
check_source('existing pure with body and consumer order remain healthy',carrier(
    'order="";kept="x".with(){order=cat(order,"W");return(value.uppercase())}.cat({order=cat(order,"C");"!"});return([kept,order,cursor_pos()]);'),
    'zzab:cd',['X!','WC',5],5,'Value');
if (!@ARGV || grep {$_ eq 'pure function state fences remain first'} @ARGV) {
    subtest 'pure function state fences remain first' => sub {
        for my $helper (qw(save_cursor restore_cursor rewind_entry_start rewind_match_start)) {
            # Descriptor-only: no forbidden parser-state action is executed.
            my $source='fn forbidden(){return("kept".with(){'.$helper.'();return(value)})}' . "\n" . carrier('return(forbidden())');
            my $descriptor=LinkedSpec::Get(\$source,return_descriptor=>1);
            my $meta=$descriptor->{spec}{Value}{meta}{action_rewriter};
            my $summary={map {$_=>$meta->{$_}} qw(raw_perl_dependency_count language_agnostic_action_ir_ready unresolved_helpers)};
            diag('CURSOR_STATEMENT_SCOPE_FENCE '.$helper.' '.$json->encode($summary));
            is($meta->{raw_perl_dependency_count},0,"$helper no raw dependency");
            ok(!$meta->{language_agnostic_action_ir_ready},"$helper remains unready in pure function");
            my %found=map {$_=>1} @{$meta->{unresolved_helpers} // []};
            ok($found{$helper},"$helper specific parser-state diagnostic retained");
        }
    };
}
done_testing;
