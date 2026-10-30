use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::AST::Parser ();

my $json = JSON::PP->new->canonical->ascii->allow_nonref;
my $sequence = 0;

subtest 'closed named read selector assignments keep typed read syntax and source' => sub {
    for my $source (
        q{items[{position=-1;position}]},
        q{items[{position=-1;position}].uppercase()},
        q{items[0][{position=-1;position}]},
        q{items[{noise="]=\"";-1}]},
    ) {
        my $node = eval { LinkedSpec::ActionIR::AST::Parser::parse_action_expr($source, {base_start => 11}) };
        my $error = $@;
        is("$error", '', "$source parses without a write diagnostic");
        ok(ref($node) eq 'HASH' && ($node->{kind} // '') =~ /\A(?:indexed_var|nested_access|fluent_chain)\z/, 'keeps the existing typed named read or fluent node');
        is_deeply($node && $node->{source_span}, {start=>11,end=>11+length($source)}, 'retains authored character span');
        is($node && $node->{source}, $source, 'retains exact authored source');
    }
};

sub check_runtime {
    my ($label, $source, $expected) = @_;
    subtest $label => sub {
        my (%context, @warnings);
        local $SIG{__WARN__} = sub {push @warnings, @_};
        my $native = eval {LinkedSpec::Get(\$source, runtime_ctx_ref=>\%context)};
        my $build_error = "$@";
        my ($value,$native_error,$cursor);
        if (ref($native) eq 'CODE') {
            my $input='x';$value=eval {$native->(\$input)};$native_error="$@";$cursor=pos($input);
        }
        my $emitted=eval {LinkedSpec::emit_generated_source(\$source,source_identity=>'closed-named-selector.spec')};
        my $emission_error="$@";my $package='LinkedSpec::ClosedNamedSelector'.++$sequence;
        my $loaded=defined($emitted) && eval "package $package; $emitted; 1";
        my $load_error="$@";my ($fresh,$fresh_error,$fresh_cursor);
        if ($loaded) {my $input='x';$fresh=eval {$package->can('Execute')->(\$input)};$fresh_error="$@";$fresh_cursor=pos($input)}
        diag('CLOSED_SELECTOR '.$label.' '.$json->encode({native=>$value,fresh=>$fresh,build_error=>$build_error,emission_error=>$emission_error,load_error=>$load_error}));
        ok(ref($native) eq 'CODE' && !$build_error && !$native_error && !$context{last_error}, 'native executes without error');
        is($json->encode($value),$json->encode($expected),'native values and kinds');
        is($cursor,0,'native cursor unchanged');
        ok($loaded && !$emission_error && !$load_error && !$fresh_error,'fresh emitted source loads and executes');
        is($json->encode($fresh),$json->encode($expected),'fresh values and kinds');
        is($fresh_cursor,0,'fresh cursor unchanged');
        is_deeply(\@warnings,[],'warning free');
    };
}

check_runtime('closed selectors preserve ordered effects missing paths and quoted brackets',q{Top:: I {
 items=["old","tail"];order="";
 out=items[{order=cat(order,"I");-1}].uppercase().cat({order=cat(order,"C");"!"});
 missing=items[99][{order=cat(order,"J");0}];
 tree=[["left","right"]];nested=tree[0][{order=cat(order,"K");-1}].uppercase();
 quoted=items[{noise="]=";-1}].uppercase();
 return([out,missing,nested,quoted,order,noise,items]);
}},['TAIL!',undef,'RIGHT','TAIL','ICJK',']=',['old','tail']]);

check_runtime('closed selector assignment remains function local',q{
 fn choose(values){return(values[{offset=-1;offset}].uppercase())}
 Top:: I {offset=9;return([choose(["a","b"]),offset])}
},['B',9]);

done_testing();
