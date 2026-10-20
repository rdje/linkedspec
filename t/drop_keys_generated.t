use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

my $json = JSON::PP->new->canonical;
my $base = {kind => 'node', debug => 1, stage => 'parse'};
my $kept = {kind => 'node', stage => 'parse'};
my $expected = [$kept, 'stage', $kept, $base, {kind => 'node'}, $base];
my $index = 0;
for my $style (qw(call receiver)) {
    my $drop = sub {
        my ($keys) = @_;
        return $style eq 'call' ? "drop_keys(meta,$keys)" : "meta.drop_keys($keys)";
    };
    my $body = 'meta = {"kind":"node","debug":1,"stage":"parse"}; '
        .'drop_key = "debug"; other = {|| drop_key = "stage"; return("debug") }; '
        .'out = '.$drop->('drop_key,other()').'; return([out,drop_key,'
        .$drop->('"debug"').','.$drop->('flat_array([])').','
        .$drop->('flat_array(["debug","stage"])').',meta])';
    my $spec = "Top: /x/\n I { $body }\n";
    for my $route (qw(native generated generated_fatal)) {
        my (@warnings, $value, $error);
        {
            local $SIG{__WARN__} = sub { push @warnings, @_ };
            my $ok = eval {
                my $input = 'x';
                if ($route eq 'native') {
                    my %context;
                    my $parser = LinkedSpec::Get(\$spec, runtime_ctx_ref => \%context);
                    die 'native parser missing' unless ref($parser) eq 'CODE';
                    $value = $parser->(\$input);
                    die $json->encode($context{last_error}) if $context{last_error};
                } else {
                    my $source = LinkedSpec::emit_generated_source(\$spec);
                    my $package = 'DropKeysRegression'.++$index;
                    my $profile = $route eq 'generated_fatal' ? "use warnings FATAL => 'syntax'; " : '';
                    eval "package $package; $profile $source; 1" or die $@;
                    no strict 'refs';
                    $value = &{$package.'::Execute'}(\$input);
                }
                1;
            };
            $error = $@ unless $ok;
        }
        is($error // '', '', "$style $route executes with the caller's warning profile");
        is($json->encode($value), $json->encode($expected),
            "$style $route captures keys, splices cardinalities and preserves the source");
        is_deeply(\@warnings, [], "$style $route is quiet");
    }
}
done_testing();
