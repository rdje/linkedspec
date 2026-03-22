#===================================================================
# Copyright (c) 2005-2008 Richard DJE. All rights reserved.
#
# This Perl module is free software, you may redistribute it and/or 
# modify it under the same terms as Perl itself.
#===================================================================
package LinkedRE;
use re 'eval';

sub _build_match_info {
 my ($pos, $parent_info) = @_;
 my $info = {
  index      => $pos,
  match      => ${^MATCH},
  match_list => [grep {defined} map {eval "\$$_"} 1 .. scalar @+],
  match_hash => {%+}
 };
 if (ref($parent_info) eq 'HASH' && ref($parent_info->{marks}) eq 'HASH') {
  $info->{marks} = $parent_info->{marks};
 }
 return $info
}

sub or {
my ($stref, $oredRE, $mode_or_parent, $parent_info) = @_;
 my $mode;
 if (ref($mode_or_parent) eq 'HASH' && !defined $parent_info) {
  $mode = 'seek';
  $parent_info = $mode_or_parent;
 } else {
  $mode = defined($mode_or_parent) && length($mode_or_parent) ? $mode_or_parent : 'seek';
 }

 if ($mode eq 'seek') {
  return undef unless $$stref =~ /(?{my $pos=0})$oredRE/gcp;
  return _build_match_info($pos, $parent_info);
 }

 if ($mode eq 'consume') {
  pos($$stref) = 0 unless defined(pos($$stref));
  return undef unless $$stref =~ /\G(?{my $pos=0})$oredRE/gcp;
  return _build_match_info($pos, $parent_info);
 }

 die "(LinkedRE::or) -E- unsupported parse mode '$mode'"
}

sub oredRE {
my $REs	        = [@_];
my $ored        = join '|', map {"$$REs[$_]\(?{\$pos=$_}\)"} 0 .. $#$REs;

 return qr/$ored/;
}


1;
