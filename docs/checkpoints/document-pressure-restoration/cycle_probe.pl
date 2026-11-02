use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

my $json = JSON::PP->new->canonical->allow_nonref;
my @cases = (
    ['callback', 'fn apply(callback: codeblock) { return(callback()) }',
     'cb={|| return(apply(cb)) }; return(cb())'],
    ['copy', '', 'cb={|self| fresh=copy(self); return(fresh(fresh)) }; return(cb(cb))'],
    ['aggregate', '', 'cb={|self| items=[]; push(items,self); fresh=items[0]; return(fresh(fresh)) }; return(cb(cb))'],
    ['function_copy', 'fn duplicate(record) { return(copy(record)) }',
     'cb={|self| fresh=duplicate(self); return(fresh(fresh)) }; return(cb(cb))'],
);
my @rows;
my $serial = 0;
for my $case (@cases) {
    my $source = "$case->[1]\nTop:: I { $case->[2] }\n";
    my (%context, $native, $native_output);
    {
        open my $capture, '>', \$native_output or die $!;
        local *STDOUT = $capture;
        my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
        my $input = 'x';
        $native = $parser->(\$input);
    }
    my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => "$case->[0].spec");
    my $package = 'CycleProbe' . $serial++;
    my $loaded = eval "package $package; $emitted; 1";
    my $load_error = "$@";
    my ($value, $error);
    if ($loaded) {
        eval { no strict 'refs'; my $input = 'x'; $value = &{$package . '::Execute'}(\$input); 1 } or $error = $@;
    }
    my $detail = $error;
    while ((reftype($detail) // '') eq 'HASH' && ($detail->{type} // '') eq 'generated_source_error') {
        $detail = $detail->{detail};
    }
    my $native_detail = $context{last_error}{detail};
    push @rows, {id => $case->[0], source => $source, emitted => $emitted,
        native => $native, native_output => $native_output,
        native_error => {class => ref($native_detail), %$native_detail},
        loaded => $loaded ? 1 : 0, load_error => $load_error, fresh => $value,
        fresh_wrapper => {map {$_ => $error->{$_}} qw(type code stage source_identity)},
        fresh_error => {class => ref($detail), %$detail}};
}
print $json->encode(\@rows), "\n";
