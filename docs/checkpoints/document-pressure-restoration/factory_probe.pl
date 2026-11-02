use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::MethodLowering ();

my $json = JSON::PP->new->canonical->allow_nonref;
my @public;
my $serial = 0;
for my $case (
    ['number', q{score=3; trace=""; out=score.abs().add({trace=cat(trace,"V"); return(2)}); return([out,trace])}, [5, 'V']],
    ['number_invalid_value', q{score="bad"; trace=""; out=score.abs().add({trace=cat(trace,"V"); return(2)}); return([out,trace])}, [undef, 'V']],
    ['number_container_reject', q{score=3; trace=""; out=score.abs().take({trace=cat(trace,"V"); return(1)}); return([out,trace])}, [undef, '']],
    ['string', q{raw=" A "; return(raw.trim().lowercase())}, 'a'],
    ['string_number', q{raw=7; trace=""; out=raw.trim().cat({trace=cat(trace,"V"); return("!")}); return([out,trace])}, ['7!', 'V']],
    ['string_container_reject', q{raw=" A "; trace=""; out=raw.trim().take({trace=cat(trace,"V"); return(1)}); return([out,trace])}, [undef, '']],
    ['condition', q{touched="no"; out=if({touched="yes";false},"bad",elseif(is_defined(false),"defined"),else("bad")); return([out,touched])}, ['defined', 'yes']],
    ['branch_once', q{trace=""; out=if({trace=cat(trace,"C");true},{trace=cat(trace,"T");return("yes")},{trace=cat(trace,"F");return("no")}); return([out,trace])}, ['yes', 'CT']],
    ['key_snapshot', q{meta={}; key="first"; trace=""; set_key(meta,key,{trace=cat(trace,"V"); key="later"; return("payload")}); return([meta,key,trace])}, [{first => 'payload'}, 'later', 'V']],
) {
    my $source = "Top:: I { $case->[1] }\n";
    my (%context, $native, $output, $native_exception);
    {
        open my $capture, '>', \$output or die $!;
        local *STDOUT = $capture;
        eval {my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
            my $input = 'x'; $native = $parser->(\$input); 1} or $native_exception = "$@";
    }
    my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'factory-calibration.spec');
    my $package = 'FactoryCalibration' . $serial++;
    my $loaded = eval "package $package; $emitted; 1";
    my $error = "$@";
    my $fresh;
    if ($loaded) {
        eval {no strict 'refs'; my $input = 'x'; $fresh = &{$package . '::Execute'}(\$input); 1}
            or $error = "$@";
    }
    push @public, {id => $case->[0], source => $source, expected => $case->[2],
        emitted => $emitted, native => $native, native_error => $context{last_error},
        native_exception => $native_exception, output => $output, loaded => $loaded ? 1 : 0,
        fresh => $fresh, error => $error};
}

{
    package FactoryCalibrationMap;
    sub TIEHASH {bless {values => $_[1], fetches => $_[2]}, $_[0]}
    sub FETCH {push @{$_[0]{fetches}}, $_[1]; return $_[0]{values}{$_[1]}}
    sub FIRSTKEY {$_[0]{iteration} = [sort keys %{$_[0]{values}}]; shift @{$_[0]{iteration}}}
    sub NEXTKEY {shift @{$_[0]{iteration}}}
}
my @scope;
for my $active (0, 1) {
    for my $fault (0, 1) {
        my (@fetches, $calls, $value, $error);
        $calls = 0;
        my %storage;
        $storage{__user_function_call_stack} = ['fn'] if $active;
        tie my %deps, 'FactoryCalibrationMap', \%storage, \@fetches;
        my $node = {kind => 'call', name => 'entry_text', args => [], source => 'entry_text()'};
        my $run = sub {
            no warnings 'redefine';
            local *LinkedSpec::ActionIR::MethodLowering::_lower_block_value_component_expr = sub {++$calls; return 'FALLBACK'};
            LinkedSpec::ActionIR::MethodLowering::_lower_ast_block_side_effect_statement($node, \%deps)
        };
        if ($fault) {
            no warnings 'redefine';
            local *LinkedSpec::ActionIR::MethodLowering::_parser_state_helper_is_forbidden_in_function = sub {0};
            eval {$value = $run->(); 1} or $error = "$@";
        } else {
            eval {$value = $run->(); 1} or $error = "$@";
        }
        push @scope, {active => $active, fault => $fault, fetches => \@fetches,
            calls => $calls, value => $value, error => $error};
    }
}
print $json->encode({public => \@public, scope => \@scope}), "\n";
