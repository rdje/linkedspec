use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::ActionIR::Contracts ();
use LinkedSpec::ActionIR::MethodExpr ();
use LinkedSpec::ActionIR::Trace ();
use LinkedSpec::ActionIR::SourceOrigins ();
use JSON::PP ();
use Scalar::Util qw(refaddr reftype blessed);

my %helpers = (capture => 'capture_slice()', entry => 'entry_named(prefix)',
               mark => 'capture_from(body_start)');
my $case = shift // die 'case required';
die 'unknown case' unless exists $helpers{$case};
my $action = 'return(\(my $value = '.$helpers{$case}.'))';
my $json = JSON::PP->new->utf8->canonical;
my (@calls, @frames, @decisions, @retained, %ids);
sub identity {
    my ($value) = @_;
    return undef unless ref($value);
    my $address = refaddr($value);
    unless (exists $ids{$address}) {
        push @retained, $value;
        $ids{$address} = scalar @retained;
    }
    return $ids{$address};
}
sub project {
    my ($value) = @_;
    return [map { project($_) } @$value] if (reftype($value) // '') eq 'ARRAY';
    return {map(($_ => project($value->{$_})), keys %$value)} if (reftype($value) // '') eq 'HASH';
    return ref($value) if ref($value);
    return $value;
}
my ($observed, $plain, $ast);
{
    my $build = \&LinkedSpec::ActionIR::Contracts::build_action_lowering_contracts;
    my $decision = \&LinkedSpec::ActionIR::Trace::decision;
    no warnings 'redefine';
    local *LinkedSpec::ActionIR::Contracts::build_action_lowering_contracts = sub {
        my $contracts = $build->(@_);
        for my $contract (@$contracts) {
            my ($id, $callback) = @{$contract}{qw(id lower)};
            $contract->{lower} = sub {
                my @args = @_; my $context = wantarray;
                my $event = ref($args[1]) eq 'HASH' ? $args[1]{event} : undef;
                my $origin = LinkedSpec::ActionIR::SourceOrigins::_origin_for($event);
                my $result = $callback->(@args); my $error = $@;
                push @calls, {contract_id => $id, input => $args[0], output => $result,
                    context => defined($context) ? ($context ? 'list' : 'scalar') : 'void',
                    event_id => identity($event), event => project($event), origin => project($origin),
                    error => $error};
                $@ = $error;
                return $result;
            };
        }
        return $contracts;
    };
    local $LinkedSpec::ActionIR::MethodExpr::_source_method_recorder = sub {
        my ($batch) = @_; my $error = $@;
        push @frames, {call_id => identity($batch->{call}), args_id => identity($batch->{arguments}),
            source => $batch->{source}, call => project($batch->{call}), frames => project($batch->{source_frames})};
        $@ = $error;
        return;
    };
    local *LinkedSpec::ActionIR::Trace::decision = sub {
        my %args = @_; my $error = $@;
        push @decisions, project(\%args) if ($args{owner} // '') eq 'method_lowering';
        $@ = $error;
        return $decision->(@_);
    };
    $ast = LinkedSpec::ActionIR::AST::parse_action_block($action);
    $observed = LinkedSpec::call_spec_handler_subst('Top', $action);
}
$plain = LinkedSpec::call_spec_handler_subst('Top', $action);
die 'observer changed actual substitution' unless $observed eq $plain;
print $json->pretty->encode({case => $case, seed => $ENV{PERL_HASH_SEED}, action => $action,
    helper => $helpers{$case}, ast => project($ast), substitution => $observed,
    plain_substitution => $plain, calls => \@calls, method_frames => \@frames,
    decisions => \@decisions, scope => 'Raw compatibility lowering only; no reference-value runtime or full-suite claim.'});
