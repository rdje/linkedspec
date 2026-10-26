use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

my $json = JSON::PP->new->canonical;
my $generation = 0;
my $check = sub {
    my ($label, $body, $expected) = @_;
    subtest $label => sub {
        my $source = "Top:: I { $body }";
        my %context;
        my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
        my $input = 'x';
        my $actual = $parser->(\$input);
        is($context{last_error}, undef, 'native execution has no error')
            or diag("$context{last_error}");
        is($json->encode($actual), $json->encode($expected), 'native values, kinds and effects');
        my $emitted = LinkedSpec::emit_generated_source(\$source,
            source_identity => 'coalesce-nonempty-exhaustion.spec');
        my $package = 'LinkedSpec::CoalesceNonemptyExhaustion::Generated'.++$generation;
        my $loaded = eval "package $package; $emitted; 1";
        ok($loaded, 'fresh parser compiles') or diag($@);
        if ($loaded) {
            my $fresh_input = 'x';
            my $fresh = eval { $package->can('Execute')->(\$fresh_input) };
            is("$@", '', 'fresh execution has no thrown error');
            is($json->encode($fresh), $json->encode($expected), 'fresh values, kinds and effects');
        }
    };
};

$check->('exhausted tails and lazy final operands', <<'BODY', $json->decode('[null,null,null,0,false,"first","chosen",null,"ABCDE"]'));
 order="";
 helper=coalesce_nonempty(undef,{order=cat(order,"A"); ""});
 receiver="".coalesce_nonempty({order=cat(order,"B"); ""});
 absent=coalesce_nonempty(undef,undef);
 zero=coalesce_nonempty("",{order=cat(order,"C"); 0});
 falsy=coalesce_nonempty(undef,{order=cat(order,"D"); false});
 first=coalesce_nonempty("first",{order=cat(order,"X"); ""});
 fallback=coalesce_nonempty("",{order=cat(order,"E"); "chosen"},{order=cat(order,"X"); ""});
 nested=coalesce_nonempty("",coalesce_nonempty(undef,""));
 return([helper,receiver,absent,zero,falsy,first,fallback,nested,order]);
BODY

$check->('selected zero remains a numeric array index', <<'BODY', [['first'],['tail'],['receiver'],1]);
 effects=0; first_values=["old"]; tail_values=["old"]; receiver_values=["old"];
 first_index=coalesce_nonempty(0,7); first_values[first_index]="first";
 tail_index=coalesce_nonempty(undef,{effects=num_add(effects,1); 0}); tail_values[tail_index]="tail";
 zero=0; receiver_index=zero.coalesce_nonempty(7); receiver_values[receiver_index]="receiver";
 return([first_values,tail_values,receiver_values,effects]);
BODY

done_testing() unless caller;
1;
