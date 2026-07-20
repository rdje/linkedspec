#===================================================================
# Copyright (c) 2005-2008 Richard DJE. All rights reserved.
#
# This Perl module is free software, you may redistribute it and/or 
# modify it under the same terms as Perl itself.
#===================================================================
package LinkedRE;
use re 'eval';

sub _build_match_info {
 my ($pos, $parent_info, $match_snapshot) = @_;
 my $info = ref($match_snapshot) eq 'HASH'
  ? {
     index      => $pos,
     match      => $match_snapshot->{match},
     match_list => [@{$match_snapshot->{match_list} // []}],
     match_hash => {%{$match_snapshot->{match_hash} // {}}},
    }
  : {
     index      => $pos,
     match      => ${^MATCH},
     match_list => [grep {defined} map {eval "\$$_"} 1 .. scalar @+],
     match_hash => {%+},
    };
 if (ref($parent_info) eq 'HASH' && ref($parent_info->{marks}) eq 'HASH') {
  $info->{marks} = $parent_info->{marks};
 }
 return $info
}

sub _resolve_mode_and_parent {
 my ($mode_or_parent, $parent_info) = @_;
 return ('seek', $mode_or_parent)
  if ref($mode_or_parent) eq 'HASH' && !defined $parent_info;
 my $mode = defined($mode_or_parent) && length($mode_or_parent)
  ? $mode_or_parent
  : 'seek';
 return ($mode, $parent_info)
}

sub or {
my ($stref, $oredRE, $mode_or_parent, $parent_info) = @_;
 my ($mode, $resolved_parent_info) = _resolve_mode_and_parent($mode_or_parent, $parent_info);

 if ($mode eq 'seek') {
  return undef unless $$stref =~ /(?{my $pos=0})$oredRE/gcp;
  return _build_match_info($pos, $resolved_parent_info);
 }

 if ($mode eq 'consume') {
  pos($$stref) = 0 unless defined(pos($$stref));
  return undef unless $$stref =~ /\G(?{my $pos=0})$oredRE/gcp;
  return _build_match_info($pos, $resolved_parent_info);
 }

 die "(LinkedRE::or) -E- unsupported parse mode '$mode'"
}

sub match_slot {
 my ($stref, $slot_re, $dispatch_index, $rule_label, $target_rule, $regex_index,
     $mode_or_parent, $parent_info) = @_;
 die "regex_slot_identity_invalid stage=validate_compiled_rule rule_label="
  . (defined($rule_label) ? $rule_label : '<undefined>')
  . " target_rule=" . (defined($target_rule) ? $target_rule : '<undefined>')
  . " regex_index=" . (defined($regex_index) ? $regex_index : '<undefined>')
  unless ref($slot_re) eq 'Regexp'
   && defined($dispatch_index) && !ref($dispatch_index) && $dispatch_index =~ /\A\d+\z/
   && defined($rule_label) && !ref($rule_label) && length($rule_label)
   && defined($target_rule) && !ref($target_rule) && length($target_rule)
   && defined($regex_index) && !ref($regex_index) && $regex_index =~ /\A\d+\z/;

 my ($mode, $resolved_parent_info) = _resolve_mode_and_parent($mode_or_parent, $parent_info);
 my $match_snapshot;
 if ($mode eq 'seek') {
  return undef unless $$stref =~ /$slot_re/gcp;
  $match_snapshot = {
   match => ${^MATCH},
   match_list => [grep { defined } map { eval "\$$_" } 1 .. scalar @+],
   match_hash => {%+},
  };
 } elsif ($mode eq 'consume') {
  pos($$stref) = 0 unless defined(pos($$stref));
  return undef unless $$stref =~ /\G$slot_re/gcp;
  $match_snapshot = {
   match => ${^MATCH},
   match_list => [grep { defined } map { eval "\$$_" } 1 .. scalar @+],
   match_hash => {%+},
  };
 } else {
  die "(LinkedRE::match_slot) -E- unsupported parse mode '$mode'"
 }

 my $info = _build_match_info(
  0 + $dispatch_index,
  $resolved_parent_info,
  $match_snapshot,
 );
 $info->{selection_role} = 'ordered_required';
 $info->{target_rule} = $target_rule;
 $info->{regex_index} = 0 + $regex_index;
 return $info
}

sub assert_slot_identity {
 my ($info, $rule_label, $dispatch_index, $target_rule, $regex_index) = @_;
 my $matches = ref($info) eq 'HASH'
  && defined($info->{index}) && $info->{index} == $dispatch_index
  && defined($info->{target_rule}) && $info->{target_rule} eq $target_rule
  && defined($info->{regex_index}) && $info->{regex_index} == $regex_index;
 return 1 if $matches;
 die "ordered_regex_slot_identity_lost stage=execute_rule rule_label=$rule_label"
  . " target_rule=$target_rule expected_regex_index=$regex_index"
  . " actual_regex_index="
  . (ref($info) eq 'HASH' && defined($info->{regex_index})
     ? $info->{regex_index}
     : '<undefined>')
}

sub oredRE {
my $REs	        = [@_];
my $ored        = join '|', map {"$$REs[$_]\(?{\$pos=$_}\)"} 0 .. $#$REs;

 return qr/$ored/;
}


1;
