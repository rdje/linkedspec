use strict;
use warnings;
use B ();
use JSON::PP ();
use LinkedSpec::ActionIR::MethodLowering ();

die 'usage: native optree inventory observe' unless @ARGV == 1 && $ARGV[0] eq 'observe';
my (@rows, %seen_cv);

sub children {
    my ($op) = @_;
    return () unless $op->can('first');
    my @children;
    for (my $child = $op->first; $$child; $child = $child->sibling) {
        push @children, $child;
    }
    return @children;
}

sub describe {
    my ($op, $names, $values) = @_;
    my %row = (op => $op->name, targ => 0 + $op->targ);
    if ($op->name =~ /^pad(?:sv|av|hv)$/) {
        $row{pad_name} = $names->[$op->targ]{name};
    }
    if ($op->name eq 'gv' || $op->name eq 'const') {
        my $value = $op->can('padix') ? $values->[$op->padix]
            : $op->can('sv') ? $op->sv : undef;
        if (defined($value) && ref($value) eq 'B::GV') {
            $row{symbol} = $value->STASH->NAME . '::' . $value->NAME;
        } elsif (defined($value) && $value->can('PV')) {
            my $text = $value->PV;
            $row{string} = $text if defined($text);
        }
    }
    my @children = children($op);
    $row{children} = [map { describe($_, $names, $values) } @children] if @children;
    return \%row;
}

sub observe_cv {
    my ($cv, $id, $parent) = @_;
    return if $seen_cv{$$cv}++;
    my @pad = $cv->PADLIST->ARRAY;
    my @values = $pad[1]->ARRAY;
    my @names = map {
        my %row;
        if ($_->can('PV')) {
            my $name = $_->PV;
            $row{name} = $name if defined($name);
            $row{flags} = 0 + $_->FLAGS;
            $row{scope_low} = 0 + $_->COP_SEQ_RANGE_LOW;
            $row{scope_high} = 0 + $_->COP_SEQ_RANGE_HIGH;
            $row{parent_pad_index} = 0 + $_->PARENT_PAD_INDEX;
        }
        \%row;
    } $cv->PADLIST->NAMES->ARRAY;
    my $row = {id => $id, parent => $parent, pads => \@names, calls => [], introductions => []};
    push @rows, $row;
    my %seen_op;
    my $walk;
    $walk = sub {
        my ($op, $path, $line) = @_;
        return unless $$op;
        return if $seen_op{$$op}++;
        $line = 0 + $op->line if $op->isa('B::COP');
        if ($op->name eq 'entersub') {
            push @{$row->{calls}}, {path => $path, line => $line,
                tree => describe($op, \@names, \@values)};
        }
        if ($op->name =~ /^pad(?:sv|av|hv)$/ && ($op->private & B::OPpLVAL_INTRO())) {
            push @{$row->{introductions}}, {path => $path, line => $line,
                pad_index => 0 + $op->targ, name => $names[$op->targ]{name}};
        }
        if ($op->name eq 'anoncode') {
            my $inner = $values[$op->targ];
            die "anoncode without CV: $id/$path" unless ref($inner) eq 'B::CV';
            observe_cv($inner, "$id/anon:$path", $id);
        }
        my $ordinal = 0;
        for my $child (children($op)) {
            $line = 0 + $child->line if $child->isa('B::COP');
            $walk->($child, "$path." . $ordinal++, $line);
        }
    };
    $walk->($cv->ROOT, '0', 0);
}

{
    no strict 'refs';
    for my $name (sort keys %LinkedSpec::ActionIR::MethodLowering::) {
        my $callback = *{'LinkedSpec::ActionIR::MethodLowering::' . $name}{CODE};
        next unless defined($callback);
        my $cv = B::svref_2object($callback);
        next unless $cv->FILE =~ m{(?:^|/)LinkedSpec/ActionIR/MethodLowering\.pm\z};
        observe_cv($cv, $name, undef);
    }
}
print JSON::PP->new->canonical->encode({perl => "$^V", cvs => \@rows,
    source_emissions_loaded => exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0}), "\n";
