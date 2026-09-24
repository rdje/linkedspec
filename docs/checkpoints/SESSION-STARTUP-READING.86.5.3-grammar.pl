#!/usr/bin/env perl
# Reproduce the permanent/bootstrap slot-node boundary through project_data_run.sh.
use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::BootstrapSpec ();
use JSON::PP ();
my $json=JSON::PP->new->canonical;
my $grammar=LinkedSpec::get_parser('spec');
die 'cannot compile permanent grammar' unless $grammar;
for my $case (
 ['separate'," I { out=div(14,2) }\n slot=/x/\n"],
 ['after_init'," I { out=div(14,2) } slot=/x/\n"],
 ['before_exit'," slot=/x/ E { return(42) }\n"],
 ['between'," I { out=div(14,2) } slot=/x/ E { return(42) }\n"],
 ['anonymous'," I { out=div(14,2) } /x/ E { return(42) }\n"],
) {
 my($id,$body)=@$case;
 my $source="Done:\n$body";
 my $input=$source;
 my $permanent=$grammar->(\$input);
 my($ok,$ast,$error)=LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$source);
 print $json->encode({id=>$id,source=>$source,permanent=>$permanent,bootstrap_ok=>$ok?1:0,bootstrap=>$ast,error=>$error}),"\n";
}
