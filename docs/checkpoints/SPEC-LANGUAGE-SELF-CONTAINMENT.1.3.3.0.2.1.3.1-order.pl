use strict;
use warnings;
use LinkedSpec ();
use JSON::PP ();
use Digest::SHA qw(sha256_hex);

my $id = shift // die "case required";
my %sources = (
    nested => 'Top:: I { cb={|x,y| nested={|s,q| return(s) }; return(nested(x,y)) }; return(cb("ok","unused")) }',
    body => 'Top:: I { cb={|x,y| if(matches(x, /ok/)) { return(x) }; return("miss") }; return(cb("ok","unused")) }',
);
my $source = $sources{$id} // die "unknown case";
my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
my $substitution = LinkedSpec::call_spec_handler_subst('Top',
    $id eq 'nested'
        ? 'cb={|x,y| nested={|s,q| return(s) }; return(nested(x,y)) }; return(cb("ok","unused"))'
        : 'cb={|x,y| if(matches(x, /ok/)) { return(x) }; return("miss") }; return(cb("ok","unused"))');
print JSON::PP->new->canonical->encode({id => $id,
    seed => $ENV{PERL_HASH_SEED}, perturb => $ENV{PERL_PERTURB_KEYS},
    source => $source, metadata => $descriptor->{spec}{Top}{meta}{action_rewriter},
    substitution => $substitution, substitution_sha256 => sha256_hex($substitution)}), "\n";
