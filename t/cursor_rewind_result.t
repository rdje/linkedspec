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
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'cursor-rewind-result.spec') };
    $result{emission_error} = error_value($@);
    my $package = 'LinkedSpec::CursorRewindResult'.++$sequence;
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
        diag('CURSOR_REWIND_RESULT_ACTUAL '.$name.' '.$json->encode($actual));
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



# TYPE-REFERENCE-BOOK.1.2.23.3.56.1 — current rewind Numbers as ordinary sources.
sub carrier {
    my ($body,$definitions) = @_;
    $definitions //= '';
    return "$definitions\nTop::\n -> Value[entry] {return(call(Value))}\nValue:\n entry=/ab/\n colon=/:/\n -> Value[colon] {$body}\n";
}
check_source('frozen qualified rewind Number result target',
    read_file('tests/fixtures/cursor_rewind_result_values.spec'),'zzab:cd',
    $json->decode(read_file('tests/fixtures/cursor_rewind_result_values.json')),5,'Value');
check_source('bound rewind Numbers retain entry local anchors and arithmetic',carrier(
    'entry_value=rewind_entry_start();p1=cursor_pos();local_value=rewind_match_start();p2=cursor_pos();return([entry_value.add(1).cat("!"),local_value.add(1),p1,p2]);'),
    'zzab:cd',['3!',5,2,4],4,'Value');
check_source('direct numeric and text methods retain physical rewind effects',carrier(
    'return([rewind_entry_start().add(1).cat("!"),rewind_match_start().add(1),cursor_pos()]);'),
    'zzab:cd',['3!',5,4],4,'Value');
check_source('defined zero skips lazy default before arithmetic',carrier(
    'order="";a=rewind_entry_start().coalesce({order=cat(order,"F");99}).add(1);return([a,order,cursor_pos()]);'),
    'ab:cd',[1,'',0],0,'Value');
check_source('incompatible Number consumers skip operands after cursor effects',carrier(
    'order="";a=rewind_entry_start().take({order=cat(order,"A");1});b=rewind_match_start().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");7});return([a,b,order,cursor_pos()]);'),
    'zzab:cd',[undef,undef,'',4],4,'Value');
check_source('existing with Array result and signed String bridge remain healthy',carrier(
    'return([rewind_entry_start().with(){return([value,"tail"])}[-1].uppercase(),cursor_pos()]);'),
    'zzab:cd',['TAIL',2],2,'Value');
check_source('noncontainer read recovers an Array and signed String method',carrier(
    'return([rewind_match_start()[0].coalesce(["a","tail"])[-1].uppercase(),cursor_pos()]);'),
    'zzab:cd',['TAIL',4],4,'Value');
check_source('pure functions accept explicitly passed rewind Numbers',carrier(
    'position=rewind_entry_start();return([inc(position),cursor_pos()]);',
    'fn inc(value){return(value.add(1))}'),
    'zzab:cd',[3,2],2,'Value');
if (!@ARGV || grep {$_ eq 'pure function rewind state remains forbidden'} @ARGV) {
    subtest 'pure function rewind state remains forbidden' => sub {
        for my $helper (qw(rewind_entry_start rewind_match_start)) {
            # Descriptor-only: no forbidden parser-state action is executed.
            my $source=carrier('return(forbidden())','fn forbidden(){return('.$helper.'().coalesce(99).add(1))}');
            my $descriptor=LinkedSpec::Get(\$source,return_descriptor=>1);
            my $meta=$descriptor->{spec}{Value}{meta}{action_rewriter};
            my $summary={map {$_=>$meta->{$_}} qw(raw_perl_dependency_count language_agnostic_action_ir_ready unresolved_helpers)};
            diag('CURSOR_REWIND_RESULT_FENCE '.$helper.' '.$json->encode($summary));
            is($meta->{raw_perl_dependency_count},0,"$helper no raw dependency");
            ok(!$meta->{language_agnostic_action_ir_ready},"$helper remains unready in pure function");
            my %found=map {$_=>1} @{$meta->{unresolved_helpers} // []};
            ok($found{$helper},"$helper specific parser-state diagnostic retained");
        }
    };
}
done_testing;
