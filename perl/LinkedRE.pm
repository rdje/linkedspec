#===================================================================
# Copyright (c) 2005-2008 Richard DJE. All rights reserved.
#
# This Perl module is free software, you may redistribute it and/or 
# modify it under the same terms as Perl itself.
#===================================================================
package LinkedRE;
use re 'eval';

sub _build_match_info {
 my ($pos) = @_;
 return {
  index      => $pos,
  match      => ${^MATCH},
  match_list => [grep {defined} map {eval "\$$_"} 1 .. scalar @+],
  match_hash => {%+}
 }
}

sub or {
my ($stref, $oredRE, $mode) = @_;
 $mode = defined($mode) && length($mode) ? $mode : 'seek';

 if ($mode eq 'seek') {
  return undef unless $$stref =~ /(?{my $pos=0})$oredRE/gcp;
  return _build_match_info($pos);
 }

 if ($mode eq 'consume') {
  pos($$stref) = 0 unless defined(pos($$stref));
  return undef unless $$stref =~ /\G(?{my $pos=0})$oredRE/gcp;
  return _build_match_info($pos);
 }

 die "(LinkedRE::or) -E- unsupported parse mode '$mode'"
}

sub oredRE {
my $REs	        = [@_];
my $ored        = join '|', map {"$$REs[$_]\(?{\$pos=$_}\)"} 0 .. $#$REs;

 return qr/$ored/;
}


1;
