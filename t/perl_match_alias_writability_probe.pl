use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
my @rows;
sub observe {
 my ($name,$invoke,$expected_slot)=@_;
 my $row={name=>$name};
 my $callback=sub {
  $row->{readonly_flag}=Internals::SvREADONLY($_[0]) ? 1 : 0;
  $row->{actual_slot}=$expected_slot && refaddr(\$_[0])==refaddr($expected_slot) ? 1 : 0;
  $row->{before}=$_[0];
  $_[0] .= '!';
  $row->{after}=$_[0];
  return 'completed';
 };
 eval {$row->{result}=$invoke->($callback);1} or $row->{error}=$@;
 push @rows,$row;
}
my $lexical='meta';
observe('lexical',sub {$_[0]->($lexical)},\$lexical);
observe('literal',sub {$_[0]->('meta')},undef);
my $source='meta';
$source =~ /(meta)/;
observe('match',sub {$_[0]->($1)},\$1);
my $copy=$1;
observe('copied-match',sub {$_[0]->($copy)},\$copy);
print JSON::PP->new->canonical->encode({perl_version=>"$^V",rows=>\@rows}),"\n";
