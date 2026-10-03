package DeferredControl::Observe;
use strict;
use warnings;
use Scalar::Util qw(blessed reftype refaddr);
use LinkedSpec::CodeblockRuntime ();

sub project {
    my ($value) = @_;
    return [map { project($_) } @$value] if (reftype($value) // '') eq 'ARRAY';
    return {map(($_ => project($value->{$_})), keys %$value),
        blessed($value) ? (observed_class => blessed($value)) : ()}
        if (reftype($value) // '') eq 'HASH';
    return $value;
}

sub binding_value {
    my ($bindings, $name) = @_;
    my $slot = $bindings->{$name};
    return undef unless ref($slot) && (reftype($slot) eq 'SCALAR' || reftype($slot) eq 'REF');
    return $$slot;
}

sub same_slot {
    my ($before, $after) = @_;
    return ref($before) && ref($after) && refaddr($before) == refaddr($after) ? 1 : 0;
}

sub execute {
    my ($action) = @_;
    my (@observations, $caught);
    my $invoke = \&LinkedSpec::CodeblockRuntime::invoke;
    no warnings 'redefine';
    local *LinkedSpec::CodeblockRuntime::invoke = sub {
        my $bindings = $_[2];
        my $slot = $bindings->{x};
        my $before = project(binding_value($bindings, 'x'));
        my $effects_before = project(binding_value($bindings, 'effects'));
        my ($value, $failure);
        my $ok = eval { $value = $invoke->(@_); 1 };
        $failure = $@ unless $ok;
        my $after = binding_value($bindings, 'x');
        my $equal_value_copy = $after;
        push @observations, {identity => $_[3], x_before => $before, x_after => project($after),
            x_same_actual_slot => same_slot($slot, $bindings->{x}),
            equal_value_distinct_slot_rejected => ref($slot) ? !same_slot($slot, \$equal_value_copy) : undef,
            effects_before => $effects_before, effects_after => project(binding_value($bindings, 'effects')),
            error_class => ref($failure) || undef};
        $caught = $failure if ref($failure);
        die $failure unless $ok;
        return $value;
    };
    $action->();
    return (\@observations, $caught);
}
1;
