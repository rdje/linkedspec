use strict;use warnings;use LinkedSpec ();use JSON::PP ();
my $s='Value:: I {order="";out=length("tail").count().with(){order=cat(order,"W");return("ran")};return([out,order,count(4),4.count()])}';
my $d=LinkedSpec::Get(\$s,return_descriptor=>1);my$p=LinkedSpec::Get(\$s);my$i='x';print JSON::PP->new->canonical->encode({actual=>$p->(\$i),meta=>$d->{spec}{Value}{meta}{action_rewriter}}),"\n";
