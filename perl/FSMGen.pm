#===================================================================
# Copyright (c) 2006-2008 Richard DJE. All rights reserved.
#
# This Perl module is free software, you may redistribute it and/or 
# modify it under the same terms as Perl itself.
#===================================================================
package FSMGen;


use 5.010;

use Storable;
use File::Path;

use HUtils;
use LinkedSpec;
use RTLUtils;
use Table;
use Lispish;
use Table2SS;

use Digest::MD5;
use Digest::file;


# $conf, *.fsm
sub start_from_file  {
 my ($fsm_file_list, %opt) = @_;

 my $conf  = HUtils::Merge (Storable::dclone(Global->set('fsmgen')), $opt{conf} // {});
 my $global = fsm_initialize ($conf, fsm_file_load(@$fsm_file_list));

 HUtils::Grep($global, qr/\btop\s/o, sub {top_exec ($global, $_[1])})
}

# $conf, atree
sub top_from_tree  {
 my ($atree, %opt) = @_;

 my $conf   = HUtils::Merge (Storable::dclone(Global->set('fsmgen')), \%opt);
 my $global = fsm_initialize ($conf, $atree);

 HUtils::Grep($global, qr/\btop\s/o, sub {top_exec ($global, $_[1])})
}

# $conf, atree string
sub top_from_string  {
 my ($string, %opt) = @_;

 my $conf   = HUtils::Merge (Storable::dclone(Global->set('fsmgen')), \%opt);
 my $global = fsm_initialize ($conf, Lispish::single (ref $string ? $string : \$string));
 HUtils::Grep($global, qr/\btop\s/o, sub {top_exec ($global, $_[1])})
}

# *.fsm -> ATree list
sub fsm_file_load  {map {Lispish::multi($_)}  @_};

# $conf, Atree list
sub fsm_initialize {
 my ($conf, @fsm_atrees) = @_;

 # The right block prefix
 $$conf{block_prefix}     = ($$conf{block_prefix} // '').($$conf{block_prefix} ? '_' : '');
 
 $conf->{_dp}           //= $conf->{_top}.'_dp';
 
 my $global               = {conf=>$conf};
 
 if ($conf->{corporate_file_header}) {
  unless (ref ($conf->{corporate_file_header}) eq 'SCALAR') {
   # Converting to its absolute counterpart
   $conf->{corporate_file_header} &&= File::Spec->rel2abs ($conf->{corporate_file_header});
  }
 }

 foreach (@fsm_atrees) {
  when ($_->[0] =~ /^\?define:(\w+)/o) {HUtils::avv_get ($global, 'define', $1) = $_->[1]}
  when ($_->[0] =~ /^\?fsm:(\w+)/o)    {HUtils::avv_get ($global, 'fsm',    $1) = $_     }
  when ($_->[0] =~ /^\?top:(\w+)/o)    {HUtils::avv_get ($global, 'top',    $1) = $_     }
 }

 return $global
}


sub fsm_handler {my ($cr, $embed_fsm, %opt) = @_;

 fsm_analyze ($cr, $embed_fsm);
 fsm_top_gen ($cr)
}

sub fsm_analyze {my ($cr, $dat) = @_;

 my @f = Lispish::grep ($dat, qr/^\?fsm:/o, sub {$_[0]});

 if (@f == 1) {
  $f[0][0] =~ /\?fsm:(?<fsmname>\w+)/o;

  HUtils::avv_get($cr, qw/conf _dp/) = (HUtils::avv_get($cr, qw/conf _top/) = $+{fsmname}).'_dp';
  $f[0][0] .= '_ctrl';
 }

 # Applying block_prefix also on _dp and _top
 HUtils::avv_get($cr, qw/conf _dp/)  = $$cr{conf}{block_prefix}.HUtils::avv_get($cr, qw/conf _dp/);
 HUtils::avv_get($cr, qw/conf _top/) = $$cr{conf}{block_prefix}.HUtils::avv_get($cr, qw/conf _top/);
 map {
   my $lcr = {conf=>$$cr{conf}}; 
   fsm_analyze_jo($lcr, $_); 

   HUtils::Merge($$cr{data_path_info} //= {}, $$lcr{data_path_info});
   HUtils::Merge($$cr{shared}         //= {}, $$lcr{shared});
 }  @f;
}

# jo = Just One
sub fsm_analyze_jo {my ($cr, $f) = @_;

 fsm_walk($cr, $f);

 $$cr{shared}{'+system'}{clock}   //= $$cr{conf}{default_clock_name};
 $$cr{shared}{'+system'}{asreset} //= $$cr{conf}{default_async_reset_name};

 fsm_drive_wen       ($cr);
 fsm_entity_gen      ($cr);
 fsm_architecture_gen($cr);
}

sub fsm_top_gen  {my ($cr) = @_;

 create_data_path ($cr);
 create_top       ($cr);
 drive_modules    ($cr);
}

# FSM description propagation
sub fsm_walk {
my ($cr, $fw) = @_;

 $$cr{fsm}  = $$cr{conf}{block_prefix}.($fw->[0] =~ /^\?fsm:(\w+)/o)[0];

 say "(fsmgen) -I- Processing FSM '$$cr{fsm}'..";

 foreach my $c_entry (@{$fw->[1]}) {
  # c_entry =       ST DT (STate Decision Tree description),       i.e, (\w+  ...)  ||
  #                 SA DT (Stand-Alone Decision Tree description), i.e, (-\w+ ...)  ||
  #                 Synchronous  reset information,                i.e, (:<   ...)  ||
  #                 Asynchronous reset information,                i.e, (:=   ...)  ||
  #                 OTHERS TBDs information types
  given ($$c_entry[0]) {
    when (/^\w+$/o)                  {st_decision_tree($cr, $c_entry    )}
    when (/^-\w+$/o)                 {sa_decision_tree($cr, $c_entry    )}
    when (/^:=$/o)                   {asyncreset      ($cr, $$c_entry[1])} 
    when (/^:<$/o)                   {syncreset       ($cr, $$c_entry[1])} 
    when (/$$cr{conf}{sharedinfo}/o) {sharedinfo      ($cr, $c_entry    )}  
  }
 }
}


# Stand Alone Decision Tree
# For 1-state state machine and
# combinatorial logic
# This corresponds to the general Decision Tree concept
#
# STate Decision Tree being just a specialization
sub sa_decision_tree {
my ($db, $dtop) = @_;

 # initializing the WEN_INDEX stack at the start of a new decision tree
 init_wenistack($db);
 ($$db{cdt})  = $$dtop[0] =~ /-(\w+)/o;

 # Initializing auto gen signal used by boolean operators
 $$db{autogen}{index} //= 0;

 push_cstack($db, "'1'");

 # PUSH Object Data Base
 push_odb_cstack($db, odb_add($db, 'constant', 1, 'b'));

 dtree_walk($db, $$dtop[1]);
 pop_cstack($db);

 # POP Object Data Base
 pop_odb_cstack($db);

 # removing the above condition from cstack
 pop_cstack($db);

}

# STate Decision Tree
sub st_decision_tree {
my ($db, $dtop) = @_;

 # Conceptually this top level is similar to a test in that the tested variable here 
 # is the state variable and the value to be tested the current state value ($$dtop[0]).
 # 
 # That means the behaviour will be the same as that of testnodes, that is, pushing the right condition
 # onto the condition's stack (cstack)

 # initializing the WEN_INDEX stack at the start of a new decision tree
 init_wenistack($db);
 $$db{cdt}  = $$dtop[0];

 # Initializing auto gen signal used by boolean operators
 $$db{autogen}{index} //= 0;

 # Initial State
 $$db{initial_state}  //= $$db{cdt};

 # To be used when defining the type for the state variable
 push @{$$db{state_enumtype}}, $$db{cdt};

###print "{DTREE_TOP: ($$dtop[0])\n";

# pushing state_variable eq current_dt onto cstack
push_cstack($db, "$$db{conf}{state_variable}_eq_$$dtop[0]");

# Adding the above EQ as a new local signal
$$db{signals}{eq}{"$$db{conf}{state_variable}_eq_$$dtop[0]"} = [$$db{conf}{state_variable}, $$dtop[0], "=", "b", 1];

add_signal2align($db, "$$db{conf}{state_variable}_eq_$$dtop[0]");

# Object Data Base
push_odb_cstack($db, odb_add($db, '=', $$db{conf}{state_variable}, $$dtop[0], "b", 1));

dtree_walk($db, $$dtop[1]);

# POP Object Data Base
pop_odb_cstack($db);

# removing the above condition from cstack
pop_cstack($db);

###print "}\n";

}

# Decision Tree propagation
sub dtree_walk {# $dw, i.e a DT, is a list/sequence of X-node
my ($db, $dw) = @_;

 # When entering a decision tree (top or low-level)
 # we have to deduce the current level WEN
 #
 # The precise algorithm will for sure be subject to various type of
 # optimization, so don't worry if the expressions of the generated WENs
 # are not optimized yet !!
 add_wen($db);

 ###print "{DT:\n"; 
 # Iteration over the sequence/list of X-node
 dtree_node_iterate (@_);
 ###print "}\n"; 
}

sub dtree_node_iterate {my ($db, $dni) = @_;
 foreach my $cnode (@$dni) {
  given ($cnode->[0]) {
    when (/^[a-zA-Z]\w*(?:'\d+)?(?:\[\d+(?::\d+)?\])?>?$/o)  {assignode          ($db, $cnode)}
    when (/^->$/o)                                           {transitionode      ($db, $cnode)}
    when (/^--|\+\+$/o)                                      {auto_decinc        ($db, $cnode)}
    when (/^(?:-|\+)=\d+$/o)                                 {general_decinc     ($db, $cnode)}
    when (/^\?[a-zA-Z]\w*(?:\[\d+(?::\d+)?\])?$/o)           {testnode           ($db, $cnode)}
    # (?BOOLEAN ...)
    when (/^\?$/o)                                           {testnode_bool      ($db, $cnode)}
    # (<SIGNAL  DT) or (<!SIGNAL  DT)
    # scv    = Short-Cut Variant
    when (/^<!?[a-zA-Z]\w*(?:\[\d+(?::\d+)?\])?$/o)          {testnode_scv       ($db, $cnode)}
    # (<SIGNAL=VALUE  DT) or (<!SIGNAL=VALUE  DT)
    # scv_wv = Short-Cut Variant with Value
    when (/$$db{conf}{testnode_scv_wv_re}/o)                 {testnode_scv_wv    ($db, $cnode)}
    # (<BOOLEAN   DT)
    when (/^<$/o)                                            {testnode_scv_bool  ($db, $cnode)}
    # (<!BOOLEAN  DT)
    when (/^<!$/o)                                           {testnode_scv_bool_n($db, $cnode)}
    # (?repeat:COUNT NODE)
    when (/^\?repeat:\d+/o)                                  {repeatnode         ($db, $cnode)}


    # Logical operators nodes
    # - AND  nodes (&  ARG1 ARG2 ... ARGN)
    # - OR   nodes (|  ARG1 ARG2 ... ARGN)
    # - NAND nodes (!& ARG1 ARG2 ... ARGN)
    # - NOR  nodes (!| ARG1 ARG2 ... ARGN)
    # - NOT  nodes (!  ARG1) or more simply !ARG1 
    #   with no space between the exclamation mark and ARG1 
    # - XOR  nodes (^  ARG1 ARG2 ... ARGN)
    # - XNOR nodes (!^ ARG1 ARG2 ... ARGN)
    #
    # ARGi may be either an identifier or another logical **operator**
    #
  }
 }
}

sub repeatnode {my ($cr, $rn) = @_;

 $rn->[0] =~ /:(?<itcount>\d+)/o;

 my @it   = map {
          my $c = {CI=>$_}; 
          Lispish::substitute($c, 
                              Storable::dclone($rn->[1][0]), 
                              sub {$_[1] =~ s{\\([A-Z]+)}{$_[0]{$1} // $1}oeg; $_[1]})
          } 0 .. $+{itcount}-1;

          dtree_node_iterate ($cr, \@it);
}


sub asyncreset {
my ($cr, $asr) = @_;

 foreach (@$asr) {
  unless (ref) {
   my @kv = split /=/;
   $$cr{shared}{asyncreset}{default}{$kv[0]} = literal_constant($kv[1]);
  } else {
   print "asyncreset: -W- References are not supported yet.\n";
  }
 }

}

sub syncreset {
my ($cr, $sr) = @_;
}

# The decision tree is comprised of, as of now, threee types of entries
# - signal assignments (sequential or combinatorial) --> assignodes
#   SEQUENTIAL:                 --> sassignodes
#   1.(A <- B)  type=r (A <-= B) r=Register
#   2.(A <= B)  type=m           m=register Mux output
#   3.(A <N B)  type=p
#   4.(A <-= B) type=rm          r foo as reference, Mux sent out as next_foo
#   5.(A <=+ B) type=mr          m foo as reference, Register sent out as foo_r
#
#   For 1) the output is taken from a register called A
#   For 2) the output is called A and taken from the input of the register with A_r <- B behaviour
#   For 3) the output is taken out from a register having pulse behaviour
#
#   This case is for pulse generation, N being the duration expressed in clock cycles
#   In this latter case B is either 1 or 0
#   
#   For 4) Both the register and its 'next_' counterpart are to be considered as output
#
#
#   COMBINATORIAL:
#   combinatorial signal assignments, this type will 
#   (A = B)                      --> cassignodes
#
# - State variable, which are also registers, assignments
#   (-> B)                       --> transitionodes
# - Test Nodes
#   (?signal_to_test ...)        --> testnodes (IFs or CASEs)
#
#   signal_to_test may be of the following forms
#   [a-zA-Z]\w*             ,e.g, foosignal, may be of any size
#   [a-zA-Z]\w*\[\d+\]      ,e.g, foosignal[1]
#   [a-zA-Z]\w*\[\d+:\d+\]  ,e.g, foosignal[12:10]
#
#   The inside is comprised of things of the form
#   (#op#VALUE  low-level-decision-tree)  --> eqnodes
#
#   VALUE may be of the following forms
#   0, 1  binary 
#   00101010    for multi-bit value expressed in binary
#   SIZE'X12AE  for multi-bit value expressed in hexadecimal
#   SIZE'12349  for multi-bit value expressed in decimal
#   s'ASTRING  when value are of enumerable types (VHDL) or `define macros (Verilog) !! Not supported yet

sub assignode {
my ($cr, $node) = @_; 

 $$node[0] =~ /^(?<signal_name>[a-zA-Z]\w*)(?:'(?<signal_size>\d+))?(?:\[\d+(?::\d+)?\])?(?<signal_as_output>>)?$/o;

 # We need this LHS to also be an output port of _top
 $$cr{shared}{exception}{output}{$1}    //= $+{signal_as_output};
 # Inline indication of a signal size
 $$cr{shared}{'+size'}{$+{signal_name}} //= $+{signal_size};

 $$node[0] =~ s/>//o;
 $$node[0] =~ s/'\d+//o;

 if (my @l = grep {defined} $$node[0] =~ /(\w+)\[(\d+)(?::(\d+))?\]/o) {
   # @l == 2 when x[i]
   # @l == 3 when x[i:j]
   # 

   # Statement like:  x[i:j] <- y
   #
   # should be considered as a short-hand for
   # x[i]   <- y[i-j]
   # x[i-1] <- y[i-j -1]
   # ...
   # x[j+1] <- y[1]
   # x[j]   <- y[0]
   #
   # That mean we should be generating (i-j+1) simple assignment(s)
   #
   # If x[i]  <- y then y is assumed to be a single bit signal.
   #
   # for each of the above single bit assignment (of the form x[i] <- y) we will do the following:
   # - marked bit (i) as explicitly assigned
   # - modify/change the LHS from x[i] to x_i
   # - modify the RHS from y to y[i-j] 
   # - send the modified assignment to (s/a)-assignode(...)
   # and repeat that from i to j
   # 
   # For the more general case
   #  x[i:j] <- y[m:n]  where (i-j) == (m-n)
   # The list of corresponding simple assignment is
   # x[i]   <- y[n + (i-j)] == y[m]
   # x[i-1] <- y[n + (i-1-j)] == y[m-1]
   # ...
   # x[j]   <- y[n + 0]
   #
   # Also  x[i] <- y[m] == x[i:i] <- y[m:m]
   
   my @r       = grep {defined} $$node[1][1] =~ /(\w+)(?:\[(\d+)(?::(\d+))?\])?/o;

   my $lbase   = $l[0];
   my $rbase   = $r[0];

   my @lbounds = @l == 2 ? @l[1,1] : @l[1,2];
   my @rbounds = @r == 2 ? @r[1,1] : (@r == 3 ? @r[1,2] : ($lbounds[0] - $lbounds[1], 0));

   # For automatic size calculation for the RHS, in case it is not subscripted or sliced
   $$cr{shared}{"+size"}{$rbase} //= ($lbounds[0] - $lbounds[1] + 1) if @r == 1;

   ##print "$$node[0] -> <@lbounds>\n";
   #  0 -> i-j
   #  i == $lbounds[0]
   #  j == $lbounds[1]
   #  n == $rbounds[1]
   my $maxindex  = $lbounds[0] - $lbounds[1];
   foreach my $v (0 .. $maxindex) {
    my $nnode = Storable::dclone($node);

    my $lcindex = $lbounds[1] + $v;
    my $rcindex = $rbounds[1] + $v;

    $$nnode[0]    = $lbase."_$lcindex";
    $$nnode[1][1] = $rbase."[$rcindex]" if $maxindex;

    # The new $$nnode[0] should be given 1 as size.
    $$cr{shared}{"+size"}{$$nnode[0]} //= 1;

    ##print "<$$nnode[0]> <- <$$nnode[1][1]>\n";
    # Marking the new LHS and RHS as internal signals of _DP
    $$cr{shared}{module}{$$cr{conf}{_dp}}{extra_info}{internal_signal}{$$nnode[0]}          //= 1;
    $$cr{shared}{module}{$$cr{conf}{_dp}}{extra_info}{internal_signal}{$rbase."_$rcindex"}  //= 1 if $maxindex;
    $$cr{shared}{module}{$$cr{conf}{_dp}}{extra_info}{sliced_output}{$lbase}{$lcindex}      //= 1;

    assignode($cr, $nnode);
   }

   return
 }

 $$node[1][0] =~ /</o ? sassignode(@_) : cassignode(@_)
}

# (a <- b) or (a <- b <c) or (a <- b <!c) where c matches '[a-zA-Z]\w*'
# (a <= b) or (a <= b <c) or (a <= b <!c) where c matches '[a-zA-Z]\w*'
# where c matches '[a-zA-Z]\w*(?:=VALUE)?'
# VALUE may be binary/decimal/hexadecimal
#
# or
# (a op b <BOOLEAN_EXP) where op= <-, <=, <-=, <N
# BOOLEAN_EXP is a parenthesized expression,, i.e, '(bool_op ...)'
sub sassignode {
my ($db, $node) = @_;


 if (@{$$node[1]} == 4) {
  # Should be of the form
  #
  # (a op b <BOOLEAN_EXP) 
  #

  my $signame = logical_dispatch($db, pop @{$node->[1]});
  $node->[1][-1] .= $signame;

  # Now calling 'sassignode' on this modified $node
  #
  # I could have called 'assignode' instead
  sassignode($db, $node)
   
 } elsif (@{$$node[1]} == 3 && $$node[1][2] =~ /$$db{conf}{_assign_firstre}/o) {
  #
  # Should be of the form
  #
  # (a op b <!?SIGNAL(?:SLICE)?(?:OP_n_VALUE)?)
  #
  my ($negated, $condvariable, $condvalue) = ($1, $2, $3);
  # removing this last element
  pop @{$$node[1]};

  # As You can see that's just a **rewrite** !!!
  my $actual_op_n_value;
  unless (defined $condvalue) {
   # Implicit single bit
   $actual_op_n_value = "=".($negated ? 0 : 1);
  } else {
   # Multi-bit or explicit single bit

   # operator retrieval
   my ($op, $value) = $condvalue =~ /^([=!<>]+)(\S+)/o;
   my $actual_op    = $negated ? $$db{conf}{_negated_op}{$op} : $op;

   # If single bit then special handling
   $actual_op_n_value = $value =~ /^[01]$/o ? "=".($negated ? ($value ? 0 : 1) : $value) : $actual_op.$value;
  }

  unless ($$db{shared}{"+size"}{$$node[0]}) {
   # When the size of the RHS is known then that of the LHS should match it
   if ($$db{shared}{"+size"}{$$node[1][1]}) {
     $$db{shared}{"+size"}{$$node[0]} = $$db{shared}{"+size"}{$$node[1][1]}
   }
  }

  #print "sassignode: testnode  $$node[0] /  $$node[1][1] <$condvariable # $actual_op_n_value>\n";
  testnode($db, ["?$condvariable", [[$actual_op_n_value, [$node]]]]);

 } else {
  my $actual_assignmant_rhs = $$node[1][1];

  if (ref $$node[1][2]) { # (A op B (+= N)) or (A op B (-= N))
   $actual_assignmant_rhs = $$node[1][1] .'_'. ($$node[1][2][0] =~ /\+/o ? 'inc' : 'dec').$$node[1][2][1][0];

   # That means the RHS is internally generated, so it should be marked as such
   # in order to prevent it to be declared as an input port.
   $$db{shared}{module}{$$db{conf}{_dp}}{extra_info}{internal_signal}{$actual_assignmant_rhs} //= 1;

   # It should also be linked to the LHS so that an appropriate assignment can be created
   $$db{shared}{lhs_local_assign}{$$node[0]}{$actual_assignmant_rhs} //= ["incdec", $$node[1][2][0].$$node[1][2][1][0], $$node[1][1]];
  }
         ###print " [SASSIGN: ($$node[0]) ($$node[1][0]) ($rhs_name)]\n";
  # pulses  (A <N B)
  my ($d)  = $$node[1][0] =~ /(\d+)/o;
  my $type = $$node[1][0] =~ /^<-$/o  ? 'r'   : (
             $$node[1][0] =~ /^<=$/o  ? 'm'   : (
             $$node[1][0] =~ /^<-=$/o ? 'rm'  : ( 
             $$node[1][0] =~ /^<=\+$/o ? 'mr' : "p$d")));
              
  # A small trick
  # $type == rm is equivalent to 'r', except it also tell us to also output the 'next_' signal too, the reggister output being the reference
  if ($type eq "rm") {
    $$db{shared}{lhs_next_as_output}{$$node[0]} = 1;
    $type = 'r';
  } 

  # A small trick
  # $type == mr is equivalent to 'm', except it also tell us to also output the 'i_' signal too, the register mux output being the reference
  if ($type eq "mr") {
    $$db{shared}{lhs_i_as_output}{$$node[0]}    = 1;
    $type = 'm';
  } 

  # Literal RHS handling & automatic size deduction
  if ($$node[1][1] =~ /^$$db{conf}{_literal_constant_re}$/o) {
   my ($sized) = $$node[1][1] =~ /(\d+)'/o;

   $$db{shared}{"+size"}{$$node[0]} = $sized || do {$$node[1][1] =~ /([01]+)/o; length $1};

   if ($sized) {
    $$db{shared}{rhs_literal}{index} //= -1;


     $actual_assignmant_rhs = "rhs_literal_". ($$db{shared}{rhs_literal}{index_once}{literal_constant($$node[1][1])} //= ++$$db{shared}{rhs_literal}{index}); 
     $$db{shared}{rhs_literal}{map}{$actual_assignmant_rhs} //= literal_constant($$node[1][1]); 
   }
  }

  # Adding support for Sliced RHS, that is, matching \w+\[\d+(?::\d+)?\]
  if (my @c = grep {defined} $$node[1][1] =~ /(\w+)\[(\d+)(?::(\d+))?\]/o) {
   my ($signame, $high_index, $low_index) = @c;

   # Additional signal name to be associated with this register
   my $addsigname = join("_", @c);

   $low_index //= $high_index;

   $$db{shared}{lhs_local_assign}{$$node[0]}{$addsigname}= ["slice", $signame, $high_index, $low_index];
   # Automatic size deduction for the LHS
   # and also setting the size for this implicitly generated $addsigname signal
   $$db{shared}{"+size"}{$addsigname} = $$db{shared}{"+size"}{$$node[0]} = $high_index - $low_index + 1;

   $actual_assignmant_rhs = $addsigname;
   # Should mark it  as internal to avoid declaring as a input port
   $$db{shared}{module}{$$db{conf}{_dp}}{extra_info}{internal_signal}{$addsigname} = 1;

   $$db{shared}{side_band_inputport}{$signame} = 1;

  } elsif (!$$db{shared}{"+size"}{$$node[0]}) {
   # When the size of the RHS is known then that of the LHS should match it
   if ($$db{shared}{"+size"}{$$node[1][1]}) {
     $$db{shared}{"+size"}{$$node[0]} = $$db{shared}{"+size"}{$$node[1][1]}
   }
  }

  #print "<$$node[0]> <$actual_assignmant_rhs>\n";
  add_dtowen_assign($db, $$node[0], $actual_assignmant_rhs, $type);
 }
}

# (a = b) or (a = b <c) or (a = b <!c) 
# where c matches '[a-zA-Z]\w*(?:=VALUE)?'
# VALUE may be binary/decimal/hexadecimal
#
# or
# (a = b <BOOLEAN_EXP)
# BOOLEAN_EXP is a parenthesized expression,, i.e, '(bool_op ...)'
sub cassignode {
my ($db, $node) = @_; 

 if (@{$$node[1]} == 4) {
  # Should be of the form
  #
  # (a = b <BOOLEAN_EXP) 
  #

  my $signame = logical_dispatch($db, pop @{$node->[1]});
  $node->[1][$#{$node->[1]}] .= $signame;

  # Now calling 'cassignode' on this modified $node
  #
  # I could have called 'assignode' instead
  cassignode($db, $node)
   
 } elsif (@{$$node[1]} == 3 && $$node[1][2] =~ /$$db{conf}{_assign_firstre}/o) {
  #
  # Should be of the form
  #
  # (a = b <!?SIGNAL(?:=VALUE)?)
  #
  my ($negated, $condvariable, $condvalue) = ($1, $2, $3);
  # removing this last element
  pop @{$$node[1]};

  # As You can see that's just a **rewrite** !!!
  my $actual_op_n_value;
  unless (defined $condvalue) {
   # Implicit single bit
   $actual_op_n_value = "=".($negated ? 0 : 1);
  } else {
   # Multi-bit or explicit single bit

   # operator retrieval
   my ($op, $value) = $condvalue =~ /^([=!<>]+)(\S+)/o;
   my $actual_op    = $negated ? $$db{conf}{_negated_op}{$op} : $op;

   # If single bit then special handling
   $actual_op_n_value = $value =~ /^[01]$/o ? "=".($negated ? ($value ? 0 : 1) : $value) : $actual_op.$value;
  }

  unless ($$db{shared}{"+size"}{$$node[0]}) {
   # When the size of the RHS is known then that of the LHS should match it
   if ($$db{shared}{"+size"}{$$node[1][1]}) {
     $$db{shared}{"+size"}{$$node[0]} = $$db{shared}{"+size"}{$$node[1][1]}
   }
  }

  ###print "<$condvariable-$actual_op_n_value>\n";
  testnode($db, ["?$condvariable", [[$actual_op_n_value, [$node]]]]);

 } else {

  my $actual_assignmant_rhs = $$node[1][1];

  if (ref $$node[1][2]) { # (A op B (+= N)) or (A op B (-= N))
   $actual_assignmant_rhs = $$node[1][1] .'_'. ($$node[1][2][0] =~ /\+/o ? 'inc' : 'dec').$$node[1][2][1][0];

   # That means the RHS is internally generated, so it should be marked as such
   # in order to prevent it to be declared as an input port.
   $$db{shared}{module}{$$db{conf}{_dp}}{extra_info}{internal_signal}{$actual_assignmant_rhs} //= 1;

   # It should also be linked to the LHS so that an appropriate assignment can be created
   $$db{shared}{lhs_local_assign}{$$node[0]}{$actual_assignmant_rhs} //= ["incdec", $$node[1][2][0].$$node[1][2][1][0], $$node[1][1]];
  }

  # Literal RHS handling & automatic size deduction
  if ($$node[1][1] =~ /^$$db{conf}{_literal_constant_re}$/o) {
   my ($sized) = $$node[1][1] =~ /(\d+)'/o;

   $$db{shared}{"+size"}{$$node[0]} = $sized || do {$$node[1][1] =~ /([01]+)/o; length $1};

   if ($sized) {
     $$db{shared}{rhs_literal}{index} //= -1;

     $actual_assignmant_rhs = "rhs_literal_". ($$db{shared}{rhs_literal}{index_once}{literal_constant($$node[1][1])} //= ++$$db{shared}{rhs_literal}{index}); 
     $$db{shared}{rhs_literal}{map}{$actual_assignmant_rhs} //= literal_constant($$node[1][1]); 
   }
  }

  # Adding support for Sliced RHS, that is, matching \w+\[\d+(?::\d+)?\]
  if (my @c = grep {defined} $$node[1][1] =~ /(\w+)\[(\d+)(?::(\d+))?\]/o) {
   my ($signame, $high_index, $low_index) = @c;

   # Additional signal name to be associated with this register
   my $addsigname = join("_", @c);

   $low_index = defined $low_index ? $low_index : $high_index;

   $$db{shared}{lhs_local_assign}{$$node[0]}{$addsigname}= ["slice", $signame, $high_index, $low_index];
   # Automatic size deduction for the LHS
   # and also settig the size for this implicitely generated $addsigname signal
   $$db{shared}{"+size"}{$addsigname} = $$db{shared}{"+size"}{$$node[0]} = $high_index - $low_index + 1;

   $actual_assignmant_rhs = $addsigname;
   # Should mark it  as internal to avoid declaring as a input port
   $$db{shared}{module}{$$db{conf}{_dp}}{extra_info}{internal_signal}{$addsigname} = 1;

   $$db{shared}{side_band_inputport}{$signame} = 1;

  } elsif (!$$db{shared}{"+size"}{$$node[0]}) {
   # When the size of the RHS is known then that of the LHS should match it
   if ($$db{shared}{"+size"}{$$node[1][1]}) {
     $$db{shared}{"+size"}{$$node[0]} = $$db{shared}{"+size"}{$$node[1][1]}
   }
  }

  add_dtowen_assign($db, $$node[0], $actual_assignmant_rhs, 'c');
 }
}

# (-> state) or (-> state <c) or (-> state <!c)
# where c matches '[a-zA-Z]\w*(?:SLICE)?(?:OP_n_VALUE)?'
# OP ~~ (?:!?=|>=?|<=?)
# VALUE may be binary/decimal/hexadecimal
#
# or
# (-> state <BOOLEAN_EXP)
# BOOLEAN_EXP is a parenthesized expression,, i.e, '(bool_op ...)'
sub transitionode {
my ($db, $node) = @_; 

 if (@{$$node[1]} == 3) {
  # Should be of the form
  #
  # (-> S <BOOLEAN_EXP) 
  #

  my $signame = logical_dispatch($db, pop @{$node->[1]});
  $node->[1][$#{$node->[1]}] .= $signame;

  # Now calling 'transitionode' on this modified $node
  transitionode($db, $node)
   
 } elsif (@{$$node[1]} == 2 && $$node[1][1] =~ /$$db{conf}{_assign_firstre}/o) {
  #
  # Should be of the form
  #
  # (-> S <!?SIGNAL(?:=VALUE)?)
  #
  my ($negated, $condvariable, $condvalue) = ($1, $2, $3);
  # removing this last element
  pop @{$$node[1]};

  # As You can see that's just a **rewrite** !!!
  my $actual_op_n_value;
  unless (defined $condvalue) {
   # Implicit single bit
   $actual_op_n_value = "=".($negated ? 0 : 1);
  } else {
   # Multi-bit or explicit single bit

   # operator retrieval
   my ($op, $value) = $condvalue =~ /^([=!<>]+)(\S+)/o;
   my $actual_op    = $negated ? $$db{conf}{_negated_op}{$op} : $op;

   # If single bit then special handling
   $actual_op_n_value = $value =~ /^[01]$/o ? "=".($negated ? ($value ? 0 : 1) : $value) : $actual_op.$value;
  }

  ###print "<$condvariable-$actual_op_n_value>\n";
  testnode($db, ["?$condvariable", [[$actual_op_n_value, [$node]]]]);

 } else {
  #
  # Should be of the form
  #
  # (-> S)
  #

  ###print " [TRANSITION: NEXT-IS($$node[1][0])]\n";
  add_dtowen_assign($db, $$db{conf}{state_variable}, $$node[1][0], "s")
 }
}

sub auto_decinc {
my ($db, $node) = @_; 

 my $is_dec = $$node[0] =~ /-/o;

 # Just a re-write
 my $new_str = [$$node[1][0], ["<-", $$node[1][0], [($is_dec ? "-" : "+")."=", [1]]]];

 assignode($db, $new_str)
}

sub general_decinc {
my ($db, $node) = @_; 

 my $is_dec = $$node[0] =~ /-/o;
 my ($step) = $$node[0] =~ /(\d+)/o;

 # Just a re-write
 my $new_str = [$$node[1][0], ['<-', $$node[1][0], [($is_dec ? '-' : '+').'=', [$step]]]];

 assignode($db, $new_str)
}

#(<c ..DT..) or (<!c ..DT..) where c matches '[a-zA-Z]\w*'
sub testnode_scv {
my ($db, $node) = @_; 

 if ($$node[0] =~ /<(!)?([a-z]\w*(?:\[\d+(?::\d+)?\])?)/o) {
  my ($negated, $condvariable) = ($1, $2);
  # As You can see that's just a **rewrite** !!!
  testnode($db, ["?$condvariable", [["=".($negated ? 0 : 1), $$node[1]]]]);
 }
}

#(<c#op#VALUE ..DT..) or (<!c#op#VALUE ..DT..) where c matches '[a-zA-Z]\w*'
sub testnode_scv_wv {
my ($db, $node) = @_; 

 if ($$node[0] =~ /$$db{conf}{testnode_scv_wv_re_cap}/o) {
  my ($negated, $condvariable, $testop, $value) = ($1, $2, $3, $4);
  # As You can see that's just a **rewrite** !!!
  testnode($db, ["?$condvariable", [[($negated ? $$db{conf}{_negated_op}{$testop} : $testop).$value, $$node[1]]]]);
 }
}

#(?c (<op1>VALUE1 ..DT1..) (<op2>VALUE2 ..DT2..) ... (<opn>VALUEN ..DTN..)) where c matches '[a-zA-Z]\w*'
sub testnode {
my ($db, $node) = @_; 

###print "{TEST: on ($node->[0])\n";
 
 my @sigbase_range_opt = grep {defined} $$node[0] =~ /([a-zA-Z]\w*)(?:\[(\d+)(?::(\d+))?\])?/o;

 # If either the first index or the second index or both are defined then a new input port should be created
 # It will then be the responsability of the _dp to extract the slice signal and send to this DT
 #
 # The above statement is not true anymore !
 #
 my $signalname = join('_', @sigbase_range_opt);
 # >>>> !!!! Other manipulation on signalname might be necessary !!!

 my $sig_component_cnt = @sigbase_range_opt;
 my $left_operand_size = $sig_component_cnt == 1 ? $$db{shared}{"+size"}{$sigbase_range_opt[0]} : ($sig_component_cnt == 2 ? 1 : abs($sigbase_range_opt[1] - $sigbase_range_opt[2] + 1));

 # Read the WEN_INDEX stack top value
 my $startindex = get_wenistack_top($db);
 my $iterindex = 1;
 foreach (@{$node->[1]}) {
  # pushing the right condition onto cstack
  # that is,
  # $node->[0] eq $_
  $$_[0] =~ /(?<TESTOP>!?=|>=?|<=?) (?: (?:(?<SIZE>\d+)'(?<BASE>x)?(?<TESTEDVALUE>[0-9a-f]+))          | 
                                        (?<TESTEDVALUE>[01]+)                                          |
                                        (?<ASIGNAL>[a-zA-Z]\w*) (?:\[(?<HIDX>\d+)(?::(?<LIDX>\d+))?\])?
                                    )
           /xio;
  ###print "($testop, $size, $base, $testedvalue)\n";

  my ($testop, $size, $base, $testedvalue, @another_signal_info) = @+{qw/TESTOP SIZE BASE TESTEDVALUE ASIGNAL HIDX LIDX/};

  die "(fsmgen) -E- Tested value '$testedvalue' <W> on signal '$signalname' is not supported !" unless defined $testedvalue || @another_signal_info;

  # Removing potential undefined value(s)
  @another_signal_info = grep {defined} @another_signal_info;

  unless (@another_signal_info) {

   if (!defined($size) && !defined($base)) {
    # When $size and $base are not defined then
    # $testedvalue should match a binary string
    die "(fsmgen) -E- Tested value '$testedvalue' <B> on signal '$signalname' is not supported !" unless $testedvalue =~ /^[01]+$/o;
    $base = "b";
   } elsif (defined($size) && !defined($base)) {
    # In this case $testedvalue should match a decimal string
    die "(fsmgen) -E- Tested value '$testedvalue' <D> on signal '$signalname' is not supported !" unless $testedvalue =~ /^[0-9]+$/o;
    $base = "d";
   } else {
    # $testedvalue is an Hexadecimal string
    $base = "h";
   }

   # In case signalname is part of a slice then
   if ($sig_component_cnt > 1) {
    $size = $left_operand_size
   } else {
    $size               ||= length $testedvalue;
    $left_operand_size  //= $size;
   }

  } else {
   my $othersignal_ifany_sz = @another_signal_info == 1 ? ($$db{shared}{'+size'}{$another_signal_info[0]} //= $left_operand_size)  :
                             (@another_signal_info == 2 ? 1                                                              : 
                                                          abs($another_signal_info[1] - $another_signal_info[2] + 1));

   $base          = '';
   $testedvalue   = join '_', grep {defined} @another_signal_info;

   # That's because an automatically generated signal has a bare name but should not be
   # declared as a interface port
   unless ($$db{autosig}{$another_signal_info[0]} || $$db{signals}{eq}{$another_signal_info[0]}) {   

    add_interface2align($db, $another_signal_info[0])  unless $$db{port}{list}{iports}{$another_signal_info[0]};
    $$db{port}{list}{iports}{$another_signal_info[0]}  //= $$db{shared}{'+size'}{$another_signal_info[0]} //= (@another_signal_info == 1 ? $left_operand_size : undef);
                                                                                        


    print "(fsmgen)($$db{fsm}) -W- Can't find any size information for *$another_signal_info[0]*\n" unless $$db{port}{list}{iports}{$another_signal_info[0]};
   }

   if (@another_signal_info > 1) {
    # Declaring a signal for this second bit/slice
    $$db{shared}{module}{$$db{fsm}}{architecture}{slice_decl}{$testedvalue} //= $othersignal_ifany_sz;
    # Assigning the right bit/slice for it
    add_assignment($db, $$db{fsm}, "SLICEs", [$testedvalue, ['slice', @another_signal_info[0,1,$#another_signal_info]]]);
    # Aligning w/ other signal
    add_signal2align($db, $testedvalue);
   }

   # Trying to assign something to $left_operand_size when the left operand is a bare name
   $left_operand_size //= $othersignal_ifany_sz if $sig_component_cnt == 1;
  }


  my $src_testedvalue = @another_signal_info ? $testedvalue : conv_testedvalue($testedvalue, $size, $base);

  my $value_prefix    = ($base ne 'b' ? $base : '');
  my $localsigname    = $signalname.$$db{conf}{_testop}{$testop}.$value_prefix.$testedvalue;

  # Adding the above EQ as a new local signal
  $$db{signals}{eq}{$localsigname} = [$signalname, 
                                      $src_testedvalue, 
                                      $testop, 
                                      $base, 
                                      $size];

  add_signal2align($db, $localsigname);


  # pushing the right condition onto cstack, that is, 
  push_cstack($db, $localsigname);

  # PUSH Object Data Base
  push_odb_cstack($db, odb_add($db, $testop, $signalname, $src_testedvalue, $base, $size));

  # push the new WEN index onto WEN_INDEX stack
  push_wenistack($db, $startindex + $iterindex);

  #eqnode($_, $db);  
  dtree_walk($db, $$_[1]);

  # POP Object Data Base
  pop_odb_cstack($db);

  # remove the previously push value from WEN_INDEX
  pop_wenistack($db);

  # removing the above condition from cstack
  pop_cstack($db);
  $iterindex++
 }


 # A bare name does not necessarily means that we have a interface input port
 # This might be an automatically generated name
 # In this latter case a input port should not be created
 unless ($$db{autosig}{$sigbase_range_opt[0]} || $$db{signals}{eq}{$sigbase_range_opt[0]}) {
  $$db{port}{list}{iports}{$sigbase_range_opt[0]} //= $$db{shared}{"+size"}{$sigbase_range_opt[0]} //= $left_operand_size;
  add_interface2align($db, $sigbase_range_opt[0]);

  print "(fsmgen)($$db{fsm}) -W- Can't find any size information for *$sigbase_range_opt[0]*\n" unless $$db{port}{list}{iports}{$sigbase_range_opt[0]};
  #add_input_port($db, $$db{fsm}, "1controls", $signalname, $left_operand_size);
 }

 # Bit or Slice are only taken on input port of the current FSM
 if ($sig_component_cnt > 1) {
  #$$db{port}{list}{iports}{$sigbase_range_opt[0]}                         //= $$db{shared}{"+size"}{$sigbase_range_opt[0]};
  # Declare a signal
  $$db{shared}{module}{$$db{fsm}}{architecture}{slice_decl}{$signalname} //= $left_operand_size;
  # Assign it a value
  add_assignment($db, $$db{fsm}, "SLICEs", [$signalname, ['slice', @sigbase_range_opt[0, 1, $#sigbase_range_opt]]]);
  # Align it with other signals
  add_signal2align($db, $signalname);
 }

 ###print "}\n";
}

#(<BOOLEAN_EXP ..DT..)
sub testnode_scv_bool {
my ($db, $node) = @_; 

 my $signame = logical_dispatch($db, shift @{$node->[1]});
 testnode_scv($db, ["<$signame", $node->[1]]);
}

#(<!BOOLEAN_EXP ..DT..)
sub testnode_scv_bool_n {
my ($db, $node) = @_; 

 my $signame = logical_dispatch($db, shift @{$node->[1]});
 testnode_scv($db, ["<!$signame", $node->[1]]);
}

#(?BOOLEAN_EXP (=A ...) ... (=Z ...))
sub testnode_bool {
my ($db, $node) = @_; 

 my $signame = logical_dispatch($db, shift @{$node->[1]});
 testnode($db, ["?$signame", $node->[1]]);
}

#sub eqnode {
#my ($node, $db) = @_; 
#  
# # $$node[0] is the VALUE to be tested 
# ##print "{EQ  ($$node[0])}: "; 
# # should pass a list of X-node, i.e, $$node[1], to dtree_walk
#}

sub logical_dispatch {
my ($db, $node) = @_;

  given ($node->[0]) {
    when (/^&$/o)   {return logicalnode ($db, $node,  "AND")}
    when (/^\|$/o)  {return logicalnode ($db, $node,   "OR")}
    when (/^!&$/o)  {return nandnode    ($db, $node        )}
    when (/^!\|$/o) {return nornode     ($db, $node        )}
    when (/^!$/o)   {return notnode     ($db, $node        )}
    when (/^\^$/o)  {return logicalnode ($db, $node,  "XOR")}
    when (/^!\^$/o) {return xnornode    ($db, $node        )}
  }
}

sub logicalnode {
my ($db, $node, $type) = @_;

 my $cindex = $$db{autogen}{index}++;
 my @args;
 foreach (@{$$node[1]}) {
  if (ref) {
   push @args, logical_dispatch($db, $_)
  } elsif (/$$db{conf}{_logicalnode_leaf_re}/o) {
   my @m = ($1, $2, $3, $4, @+{qw/TESTOP SIZE BASE TESTEDCONSTANT ASIGNAL HIDX LIDX/});
   # [0]  = negation
   # [1]  = signame base
   # [2]  = 1st index
   # [3]  = 2nd index
   # [4]  = test op
   # [5]  = size
   # [6]  = base
   # [7]  = tested constant value
   # [8]  = another signal as right operand
   # [9]  = another signal as right operand high index
   # [10] = another signal as right operand low index

   my @sig_filtered  = grep {defined} @m[1 .. 3];
   my $signalname    = join('_', @sig_filtered);
   my $sigbase       = $sig_filtered[0];
   my $sig_comp_cnt  = @sig_filtered;

   my @sig_2nd_filt  = grep {defined} @m[8 .. 10];
   my $sig_2nd_tstva = join '_', @sig_2nd_filt;
   my $sig_2nd_sz    = @sig_2nd_filt == 0 ? undef                                       : (
                       @sig_2nd_filt == 1 ? $$db{shared}{'+size'}{$sig_2nd_filt[0]}     : (
                       @sig_2nd_filt == 2 ? 1                                           :
                                             abs($sig_2nd_filt[1] - $sig_2nd_filt[2] +1)));

   my $base          = $m[8] ? '' : ($m[5] ? ($m[6] ? 'h' : 'd') : 'b'); 
   my $value_prefix  = $base ne 'b' ? $base : '';

   my $tst_op        = $m[4] || '=';
      # Check for negation
      $tst_op        = $m[0] ? $$db{conf}{_negated_op}{$tst_op} : $tst_op;

      $tst_op_str    = $$db{conf}{_testop}{$tst_op};
   my $tst_va        = @sig_2nd_filt ? $sig_2nd_tstva : ($m[4] ? $m[7] : ($m[0] ? 0 : 1));
   my $sigsize       = $sig_comp_cnt == 1 ? ($m[5] // ($m[8] ? $sig_2nd_sz : length $tst_va)) : ($sig_comp_cnt == 2 ? 1 : abs($m[2] - $m[3] + 1));
   my $tst_va_str    = @sig_2nd_filt ? $sig_2nd_tstva : conv_testedvalue($tst_va, $sigsize, $base);

   if (@sig_2nd_filt) {
    # Define an interface input port in case the base of name of the bit/slice was not automatically generated
    unless ($$db{autosig}{$sig_2nd_filt[0]} || $$db{signals}{eq}{$sig_2nd_filt[0]}) {   

     add_interface2align($db, $sig_2nd_filt[0]) unless $$db{port}{list}{iports}{$sig_2nd_filt[0]};
     $$db{port}{list}{iports}{$sig_2nd_filt[0]}  //=  $$db{shared}{'+size'}{$sig_2nd_filt[0]} //= (@sig_2nd_filt == 1 ? $sigsize : undef);

     print "(fsmgen)($$db{fsm}) -W- Can't find any size information for *$sig_2nd_filt[0]*\n" unless $$db{port}{list}{iports}{$sig_2nd_filt[0]};
    }

    if (@sig_2nd_filt > 1) {
     # Declaring a signal for this second bit/slice
     $$db{shared}{module}{$$db{fsm}}{architecture}{slice_decl}{$tst_va_str} //= $sig_2nd_sz;
     # Assigning the right bit/slice for it
     add_assignment($db, $$db{fsm}, "SLICEs", [$tst_va_str, ['slice', @sig_2nd_filt[0, 1, $#sig_2nd_filt]]]);
     # Aligning w/ other signal
     add_signal2align($db, $tst_va_str);
    }
   }

   my $localsigname  = $signalname.$tst_op_str.$value_prefix.$tst_va;
   push @args, $localsigname;
   unless ($$db{autosig}{$localsigname} || $$db{signals}{eq}{$localsigname}) {
    # Adding the above EQ as a new local signal
    $$db{signals}{eq}{$localsigname} = [$signalname, 
                                        $tst_va_str, 
                                        $tst_op, 
                                        $base, 
                                        $sigsize];

    add_signal2align($db, $localsigname);

    #odb_add($db, "=", $1, 0, "b", 1);
   }

   unless ($$db{autosig}{$sigbase} || $$db{signals}{eq}{$sigbase}) {   
    add_interface2align($db, $sigbase) unless $$db{port}{list}{iports}{$sigbase};
    $$db{port}{list}{iports}{$sigbase} //= ($$db{shared}{'+size'}{$sigbase} //= $sigsize);

    print "(fsmgen)($$db{fsm}) -W- Can't find any size information for *$sigbase*\n" unless $$db{shared}{'+size'}{$sigbase};

    #add_input_port($db, $$db{fsm}, "1controls", $1, 1);
   }

   # Sliced local signal
   if ($sig_comp_cnt > 1) {
    add_assignment($db, $$db{fsm}, 'SLICEs', [$signalname, ['slice', @sig_filtered[0, 1, $#sig_filtered]]]);
    $$db{shared}{module}{$$db{fsm}}{architecture}{slice_decl}{$signalname} = $sigsize;
    add_signal2align($db, $signalname);
   }
  }
 }

 my $autosig                    = "autosig_$cindex";
 $$db{autogen}{signal}[$cindex] = "(".join(" $type ", @args).")"; 
 $$db{autosig}{$autosig}        = 1;;  
 add_signal2align($db, $autosig);

 #add_signal($db, $$db{fsm}, "autosig", [$autosig, "STD_LOGIC"]);

 return $autosig
}

sub notnode  {
my ($db, $node) = @_;

 my $varname    = ref($node->[1][0]) ? logical_dispatch($db, $node->[1][0]) : $node->[1][0];

 my $notsigname = $varname."_eq_0";
 my $notbase    = $varname;
 unless (ref($node->[1][0]) || $$db{port}{list}{iports}{$varname}) {
  $$db{port}{list}{iports}{$varname} = 1;
  add_interface2align($db, $varname);

  #add_input_port($db, $$db{fsm}, "1controls", $varname, 1);

 } elsif (ref($node->[1][0])) {
	 #my $autosig              = $varname.$$db{autogen}{index}++;
  my $autosig              = $varname;
  $$db{autosig}{$autosig}  = 1; 
  add_signal2align($db, $autosig);
  
  $notsigname              = $autosig."_eq_0";
  $notbase                 = $autosig;
 }

 unless ($$db{signals}{eq}{$notsigname}) {
  # Adding the above EQ as a new local signal
  $$db{signals}{eq}{$notsigname} //= [$notbase, 0, "=", "b", 1];
  add_signal2align($db, $notsigname);
 }

 return $notsigname
}

sub nandnode {my ($db, $node) = @_; $$node[0] = "&"; notnode($db, ["!", [$node]])}
sub nornode  {my ($db, $node) = @_; $$node[0] = "|"; notnode($db, ["!", [$node]])} 
sub xnornode {my ($db, $node) = @_; $$node[0] = "^"; notnode($db, ["!", [$node]])}



sub push_cstack {my ($db, $pv) = @_; push @{$$db{cstack}}, $pv}
sub pop_cstack  {my ($db)      = @_; pop  @{$$db{cstack}}}

sub add_wen {
my ($db) = @_; 

 my $current_dtwen_ptr = get_wenistack_top($db); ###print "===================>(add_wen) : WENINDEX<$current_dtwen_ptr>\n";
 # Each such 'wen_exp' will be associated with a unique index, producing a signal of the form
 #
 #  <current_dt>_<wen_prefix>_<INDEX>
 #
 #  The <wen_prefix> part is configurable thru the 'wen_prefix' variable
 #
 # Every new DT will allocate a unique position/index for a given state so as to store its
 # corresponding boolean expression.
 # 
 # For ** a given ** state/DT it is VERY important **NOT** to allocate more than once the same position/index
 # otherwise previous boolean expression created at that position will be lost
 #

 # We also the '1' for SA DT when it is not the only condition in the CSTACK
 $$db{localwens}{$$db{cdt}}[$current_dtwen_ptr] = join(" AND ",  @{$$db{cstack}} == 1 ? $$db{cstack}[0] : grep {!/^'1'$/o} @{$$db{cstack}});

 $$db{odb}{fsm}{$$db{fsm}}{$$db{cdt}}{wen}[$current_dtwen_ptr] = uniquify_odb_exp($db, "AND", get_odb_cstack($db));
}

# AS = ASsign
sub add_dtowen_assign {
my ($db, $left_side, $right_side, $astype) = @_; 

 my $cdt_cwen = get_wenistack_top($db);
 # The behaviour of this routine may be a little bit more complicated if needed.

 # Here is the place were we accumulate DT LOCAL WENs that are specific to a given LHS/RHS pair
 # the $cdt_cwen is just an index in @{$$db{localwens}{$$db{cdt}}}. The corrresponding entry is its boolean expression.
 push @{$$db{dtowens}{$$db{cdt}}{$astype}{$left_side}{$right_side}}, $cdt_cwen;

 push @{$$db{odb}{fsm}{$$db{fsm}}{$$db{cdt}}{owen}{$astype}{$left_side}{$right_side}}, $cdt_cwen;

 # For every LHS/RHS pair we should note under which DT it is controlled.
 $$db{fsmowens}{$astype}{$left_side}{$right_side}{$$db{cdt}} = 1;

 # This information is needed when creating the data path in the early stage of it.
 $$db{shared}{lhs_atype}{$left_side} = $astype unless $left_side eq $$db{conf}{state_variable};

 # For every LHS/RHS pair we should note which FSM controls it.
 $$db{data_path_info}{$astype}{$left_side}{$right_side}{$$db{fsm}} = 1 unless $left_side eq $$db{conf}{state_variable};
 ###print "add_dtowen_assign: ($left_side, $right_side, $astype [$$db{cdt}][$cdt_cwen]) <$$db{localwens}{$$db{cdt}}[$cdt_cwen]>\n";
}

# At the start of a DT we Have to clear the memory for $wenidx stream, together with wenidx_max
sub init_wenistack    {my ($db)          = @_; @{$$db{wenistack}} = 0; $$db{wenidx_stream_check}={}; $$db{wenidx_max}=0}
sub get_wenistack_top {my ($db)          = @_; $$db{wenistack}[$#{$$db{wenistack}}]}

sub push_wenistack    {my ($db, $wenidx) = @_;
 # Each push will effectively allocate a new position/index into the CSTACK for the next boolean expression.
 # It is VERY important *not* to allocate twice the same location.
 #
 # This implies that for a given state, the $wenidx stream seen at here, should not exhibit twice the same value.
 # 
 # Let's say we are observing $wenidx stream for a given state, then after seeing/allocating a given $wenidx
 # we should remenmber that fact, and forbid any new allocation of an already seen value.
 
 # Before accepting the new incoming $wenidx we should check if it has already been used.
 if ($$db{wenidx_stream_check}{$wenidx}) {
  # Oh, Oh, looks like we have a duplicate value here, we should re-act and not let it pass !!
  #
  # A solution is to modify the incoming $wenidx and give it a value corresponding to the MAX plus 1
  $wenidx = $$db{wenidx_max} + 1
 } 

 push @{$$db{wenistack}}, $wenidx;
 # The current $wenidx is now marked as already used. It will never be pushed onto the wenistack.
 $$db{wenidx_stream_check}{$wenidx} = 1;

 # Keeping the maximum value up-to-date
 $$db{wenidx_max} = $wenidx if $$db{wenidx_max} < $wenidx;
}

sub pop_wenistack     {my ($db) = @_; pop @{$$db{wenistack}}}

sub odb_make_fsmwen {
my ($db) = @_; 


 HUtils::recurse($$db{odb}{fsm}{$$db{fsm}}, sub {my ($info, $wenlist) = @_;
 # For each DT of the current FSM

  # @$info:
  # [0] = CDT
  # [1] = constant field, not useful here

  my $cdt = $$info[0];

  my $index = 0;
  foreach (@$wenlist) {
   # We should iterate over all of its LOCAL WENs (c.f. add_wen())
   # For such WEN we should create an ASSIGNMENT STRUCT containing:
   # - (LHS) the name of this WEN
   # - (RHS) its value as a reference to its boolean expression

   # Giving a name to this WEN
   my $cwename = "$$info[0]_$$db{conf}{wen_prefix}_$index";

   # We should declare a signal for the WEN
   add_signal($db, $$db{fsm}, $cdt, my $signal = [$cwename, "STD_LOGIC"]);

   # The $signal argument will tell that the corresponding signal is already declared in shared/.../architecture/signal
   # for the current FSM and DT
   odb_add($db, "signal", $cwename, $signal);

   # And assign it its boolean expression as value
   add_assignment($db, $$db{fsm}, $cdt, [$cwename, $_]);

   $index++
  }


  # The next step is to create a WEN signal (OR) for all LHS/RHS pairs controlled by CDT 
  # Operand(s) of this OR'ed WEN will be the previously created CDT WENs, see above foreach.
  HUtils::recurse($$db{odb}{fsm}{$$db{fsm}}{$cdt}{owen}, sub {my ($info, $wenlist) = @_;
    # @$info:
    # [0] = Assignment type
    # [1] = LHS
    # [2] = RHS

    # Giving a name to this WEN
    my $cwename = "${cdt}_".join("_", @$info[1,2])."_wen";

    # We should declare a signal for this WEN
    add_signal($db, $$db{fsm}, $cdt, my $signal = [$cwename, "STD_LOGIC"]);

    # The $signal argument will tell that it the corresponding signal is already declared in shared/.../architecture/signal
    # for the current FSM and DT
    odb_add($db, "signal", $cwename, $signal);

    # And assign it its boolean expression as value
    add_assignment($db, $$db{fsm}, $cdt, [$cwename, uniquify_odb_exp($db, "OR", $wenlist)]);
  });
 });

 # The last step is to create a specific WEN for each LHS/RHS based on each LHS/RHS's WEN generated during the second step of
 # above recurse.
 # This is because more than one DT may be controlling a giving LHS/RHS pair. The contribution of all DTs should now be OR'ed
 # so as to produce the final WEN for the given LHS/RHS pair.
 #
 # If LHS is anything but the state variable then all of its corresponding LHS/RHS's WENs should be output ports
 # otherwise they will be local signals.

 # First for each LHS/RHS pair for the current FSM let's determine which DT controls it.
 HUtils::Grep($$db{odb}{fsm}{$$db{fsm}}, qr/owen/o, sub {my ($info) = @_;
   # @$info:
   # [0] = CDT
   # [1] = -
   # [2] = assignment type
   # [3] = LHS
   # [4] = RHS
   $$db{odb}{xhs2dt_map}{$info->[2]}{$info->[3]}{$info->[4]}{$info->[0]} = 1;
 });

 HUtils::KeyGrep($$db{odb}{xhs2dt_map}, sub {@{$_[0]} == 3}, sub {my ($info, $dth) = @_;
   # @$info:
   # [0] = assignment type
   # [1] = LHS
   # [2] = RHS

   # Giving a name to this WEN
   my $suffix = join("_", @$info[1,2]);
   my $cwename = "$$db{fsm}_${suffix}_wen$$db{conf}{output_port_suffix}";

   if ($$info[1] eq $$db{conf}{state_variable}) {
    # We should declare a signal for this WEN if LHS is the STATE variable
    add_signal($db, $$db{fsm}, "$$db{fsm} state WENs", [$cwename, 'STD_LOGIC']);

    add_constant($db, $$db{fsm}, "STATE constants", ["${suffix}_sel$$db{conf}{constant_suffix}", 'STD_LOGIC_VECTOR', , $$info[$#$info]]);

   } else {
    # We should declare an output port (pulse) if it is not the STATE variable
    add_output_port($db, $$db{fsm}, "2pulses", $cwename);
   }

   # And assign it its boolean expression as value
   add_assignment($db, $$db{fsm}, "$$db{fsm} output WENs", [$cwename, uniquify_odb_exp($db, "OR", [map {odb_get($db, "signal", $_."_${suffix}_wen")} keys %$dth])]);

 });

}

sub fsm_drive_wen {
my ($db) = @_; 

 # STEP 0
 foreach my $cdt (sort {$a cmp $b} keys %{$$db{dtowens}}) {
  #  For each DT of the current FSM

  ###print "Building DT<$cdt>..\n";
  my $index = 0;
  # We should iterate over all of its LOCAL WENs (c.f. add_wen())
  foreach (@{$$db{localwens}{$cdt}}) {
   # For such WEN:
   # [0] = create a specific signal name for it 
   # [1] = its boolean EXPRESSION
   #
   # These arrays are used when creating the architeture of the current FSM (c.f fsm_architecture_gen())
   $$db{wensection}{$cdt}{localwens}[$index] = ["${cdt}_$$db{conf}{wen_prefix}_$index", $_];

   # Adding this DT local wen as a new local signal
   $$db{signals}{local}{$cdt}{"${cdt}_$$db{conf}{wen_prefix}_$index"} = 1;
   add_signal2align($db, "${cdt}_$$db{conf}{wen_prefix}_$index");

   $index++
  }

  HUtils::recurse($$db{dtowens}{$cdt}, sub {my ($info, $wenlist) = @_;
   # @$info:
   # [0] = assignment type
   # [1] = LHS
   # [2] = RHS

   # Here is where we OR all DT ($cdt) LOCAL WENs for a specific LHS/RHS pair
   # [0] = Name given to this DT LHS/RHS OR'ed signal
   # [1] = associated boolean expression
   #
   # The OR operands (signals) were defined in the above nested foreach loops
   # 
   # These arrays are used when creating the architeture of the current FSM (c.f fsm_architecture_gen())
   push @{$$db{wensection}{$cdt}{dtowens}}, ["${cdt}_".join("_", @$info[1,2])."_wen", join(" OR ", map {"${cdt}_$$db{conf}{wen_prefix}_$_"} @$wenlist)];

   # Adding this FSM wen as a new local signal
   $$db{signals}{local}{$cdt}{"${cdt}_".join("_", @$info[1,2])."_wen"} = 1;
   add_signal2align($db, "${cdt}_".join("_", @$info[1,2])."_wen");
  });
 }

 # STEP 1
 HUtils::KeyGrep($$db{fsmowens}, sub {@{$_[0]} == 3 }, sub {my ($info, $stateh) = @_;
   #
   # @$info: 
   # [0] = assignment type (s=sequential, c=combinatorial, p=pulse, ...
   # [1] = LHS
   # [2] = RHS
   #
   ###print "[@$info] : <@{[keys %$stateh]}>\n";

   # Creating the WEN OR boolean expression for each LHS/RHS pair controlled by the current FSM
   # each item of this OR expression corresponding to the WEN (OR) boolean expression driven by at least
   # of DT of that FSM. Those item name were created in STEP 0, just above.
   my $suffix = join("_", @$info[1,2]);
   my $rhs = join(" OR ", map {$_."_${suffix}_wen"} keys %$stateh);
   #my $rhs = join(" OR ", map {$_."_${suffix}_wen"} @{[keys %$stateh]});

   # Here is where we give a name the WEN signal of the current LHS/RHS pair controlled by the current FSM
   my $fsmowename = "$$db{fsm}_${suffix}_wen$$db{conf}{output_port_suffix}";

   unless ($$info[1] eq $$db{conf}{state_variable}) {
    # WEN with LHS not corresponding to the STATE VARIABLE should be output port
    push @{$$db{lastwens}{fsmowen}}, [$fsmowename, $rhs];
    push @{$$db{lastwens_2align}}, $fsmowename;
   } else {
    # WEN with LHS corresponding to the STATE VARIABLE should be local signals 
    push @{$$db{lastwens}{statevwen}}, ["${suffix}_wen", $rhs];
    push @{$$db{lastwens_2align}}, "${suffix}_wen";

    # [0] = name of the current state selection constant 
    # [1] = associated state value, that's the next state when the state selection "..._sel" matches that 
    #       constant          
    push @{$$db{state_selection_constants}}, ["${suffix}_sel$$db{conf}{constant_suffix}", $$info[$#$info]];
   }

   # Adding this state variable wen as another local signal
   if ($$info[1] eq $$db{conf}{state_variable}) {
    $$db{signals}{local}{$$info[2]}{"${suffix}_wen"} = 1;
    add_signal2align($db, "${suffix}_wen");
   } else {
    # Adding this FSM output wen as a new output port
    push @{$$db{port}{list}{oports}}, $fsmowename;
    add_interface2align($db, $fsmowename);

    #add_output_port($db, $$db{fsm}, "2pulses", $fsmowename); 
   }
 });

 # Deducing the state selection signal size 
 $$db{state_selection_signal_size} = @{$$db{lastwens}{statevwen}} if $$db{lastwens}{statevwen}; 
}

sub signals_constants_gen {
my ($db, $arch_string) = @_;

 my @constant_lst      = map {$$_[0]} @{$$db{state_selection_constants}};

 if (@constant_lst) {
  add_signal2align($db, $$db{conf}{state_variable});
  add_signal2align($db, "next_$$db{conf}{state_variable}");
  add_signal2align($db, $$db{conf}{state_variable}."_sel");
 }

 # Aligning both signals and constants
 my $aligned = RTLUtils::string_align([@{$$db{signal2align}}, @constant_lst]);

 # For use in eq_assignment
 $$db{eq_assignment_align} = $aligned;

 # STATE value selection CONSTANTs' declarations
 if (@constant_lst) {
  my $constant_index = 0;
  my $sz             = $$db{state_selection_signal_size};    
  my $quote          = $sz == 1 ? q(') : q(");
  $$arch_string .= "-- state variable values' selection constants\n";
  $$arch_string .= join(";\n", map {"CONSTANT  $$aligned{$_}  :  STD_LOGIC".
                                    ($sz > 1 ? "_VECTOR(".($sz-1). " DOWNTO 0)" : "").
                                    " := $quote". get_onehot($$db{state_selection_signal_size}, $constant_index++) .$quote
                                   } @constant_lst).";\n\n";
  }

 # EQs
 $$arch_string .= "-- EQ signals' declaration\n";
 $$arch_string .= join("", map {"SIGNAL    $$aligned{$_}  :  STD_LOGIC;\n"} sort {$a cmp $b} keys %{$$db{signals}{eq}})."\n";
 

 if (@constant_lst) {
 # STATE variable
 $$arch_string .= "-- state variable's declarations\n";
 $$arch_string .= "SIGNAL    $$aligned{$$db{conf}{state_variable}}  :  $$db{conf}{state_type_name};\n"; 
 $$arch_string .= "SIGNAL    ".$$aligned{"next_$$db{conf}{state_variable}"}."  :  $$db{conf}{state_type_name};\n"; 
 $$arch_string .= "SIGNAL    ".$$aligned{$$db{conf}{state_variable}."_sel"}."  :  STD_LOGIC".
                                           ($$db{state_selection_signal_size} > 1 ? "_VECTOR(".($$db{state_selection_signal_size}-1)." DOWNTO 0)" : "").";\n\n"; 
 }

 # All other SIGNALs
 foreach my $cdt (sort {$a cmp $b} keys %{$$db{signals}{local}}) {
  $$arch_string .= "-- state <$cdt> specific signals' declarations\n";
  $$arch_string .= join("", map {"SIGNAL    $$aligned{$_}  :  STD_LOGIC;\n"} sort {$a cmp $b} keys %{$$db{signals}{local}{$cdt}})."\n";
 }

 # SLICEs
 $$arch_string .= "-- SLICE signals' declaration\n";
 $$arch_string .= join("", map {"SIGNAL    $$aligned{$_}  :  STD_LOGIC".
                                do {
                                 my $sz = $$db{shared}{module}{$$db{fsm}}{architecture}{slice_decl}{$_};
                                 ($sz == 1 ? "" : "_VECTOR(".--$sz." DOWNTO 0)")
                                } .";\n"
                               } sort {$a cmp $b} keys %{$$db{shared}{module}{$$db{fsm}}{architecture}{slice_decl}})."\n";

 if (keys %{$$db{autosig}}) {# This due to a small side-effect of the REALLY POWERFUL AutoViViCaTion feature
  # Auto generated
  $$arch_string .= "-- Additional signals' declaration\n";
  $$arch_string .= join("", map {"SIGNAL    $$aligned{$_}  :  STD_LOGIC;\n"} sort {$a cmp $b} keys %{$$db{autosig}})."\n";
 }
}

sub state_regen {
my ($db, $arch_string) = @_;

 $$arch_string .= "-- state variable selection signal assignment\n";
 $$arch_string .= $$db{conf}{state_variable}."_sel  <=  ".join(" & ", map {$$_[0]} reverse @{$$db{lastwens}{statevwen}}). ";\n";
 my $next_state_len = length("next_$$db{conf}{state_variable}") + 6;
 $$arch_string .= "next_$$db{conf}{state_variable}  <=  ".join("\n"." "x $next_state_len, 
                                                                   (map {
                                                                          "$$_[1]  WHEN ".$$db{conf}{state_variable}."_sel"." = $$_[0] ELSE"
                                                                        } @{$$db{state_selection_constants}}),  
                                                                  
                                                               $$db{conf}{state_variable}
                                                              ).";\n\n";

 $$arch_string .= register_process ($db,
                        comment     => "state variable $$db{conf}{state_variable}",
                        clock       => $$db{shared}{"+system"}{clock}             ,
                        asreset     => $$db{shared}{"+system"}{asreset}           ,
                        reset_value => $$db{initial_state}                        ,
                        register    => $$db{conf}{state_variable}                 ,
                        next_value  => 'next_'.$$db{conf}{state_variable}         ,
		        label       => $$db{conf}{state_variable}.'_reg'          );
}

sub fsm_entity_gen {
my ($db) = @_;

 add_interface2align($db, $$db{shared}{"+system"}{clock})   if $$db{shared}{"+system"}{clock};
 add_interface2align($db, $$db{shared}{"+system"}{asreset}) if $$db{shared}{"+system"}{asreset};

 my $interface2align = RTLUtils::string_align($$db{interface2align});

 my $ent_string  = "";
 $ent_string    .= add_header_n_context_clause($$db{conf}                                                    , 
                                               file_name      => get_entity_file_name($db, $$db{fsm})        ,
                                               author_signame => get_leaf ($db, 'author_signame')            , 
                                               author_name    => get_leaf ($db, 'author_name')               ,       
                                               description    => get_entity_file_description ($db, $$db{fsm})
                                              );

 $ent_string    .= "ENTITY  $$db{fsm}  IS\n";
 $ent_string    .= "  PORT (\n";
 $ent_string    .= qq(    $$interface2align{$$db{shared}{"+system"}{clock}}  :  IN  STD_LOGIC;\n)    if $$db{shared}{"+system"}{clock};
 $ent_string    .= qq(    $$interface2align{$$db{shared}{"+system"}{asreset}}  :  IN  STD_LOGIC;\n\n) if $$db{shared}{"+system"}{asreset};

 add_input_port($db, $$db{fsm}, "0system", $$db{shared}{"+system"}{clock})  if $$db{shared}{"+system"}{clock};
 add_input_port($db, $$db{fsm}, "0system", $$db{shared}{"+system"}{asreset}) if $$db{shared}{"+system"}{asreset};
 
 my @interface;
 HUtils::recurse($$db{port}{list}, sub {my ($info, $iodata) = @_;
  if ($$info[0] eq "iports") {
   push @interface, "$$interface2align{$$info[1]}  :  IN  STD_LOGIC".($iodata > 1 ? "_VECTOR(".($iodata-1)." DOWNTO "."0)" : "");

   add_input_port($db, $$db{fsm}, "1controls", $$info[1], $iodata);

  } else {
   push @interface, map {
                         add_output_port($db, $$db{fsm}, "2pulses", $_); 
                         "$$interface2align{$_}  :  OUT STD_LOGIC" 
                        } @$iodata;
  }
 });

 my $index = 0;
 foreach (@interface) {
  $ent_string .= "    $_";
  $ent_string .= ";" unless $index == $#interface;
  $ent_string .= "\n";
  $index++
 }

 $ent_string .= "  );\n";
 $ent_string .= "END ENTITY  $$db{fsm};\n\n";

 $$db{shared}{module}{$$db{fsm}}{string} = $ent_string;
}

sub fsm_architecture_gen {
my ($db) = @_;

 my $arch_string   .= "ARCHITECTURE  $$db{conf}{architecture_name}  OF  $$db{fsm} IS\n\n";

 if ($$db{state_enumtype}) {
  # state type
  $arch_string .= "-- state type definition\n";
  $arch_string .= "TYPE $$db{conf}{state_type_name} IS (".join(", ", @{$$db{state_enumtype}}).");\n\n"; 

  add_type($db, $$db{fsm}, "state type definition", [$$db{conf}{state_type_name}, @{$$db{state_enumtype}}]);
 }

 # SIGNALs & CONSTANTs
 signals_constants_gen($db, \$arch_string);

 $arch_string .= "BEGIN\n\n";
 
 eq_assignment($db, \$arch_string);

 # WENs section
 # state related wens
 foreach my $cdt (sort {$a cmp $b} keys %{$$db{wensection}}) {
  my $aligned = RTLUtils::string_align([map {map {$$_[0]} @{$$db{wensection}{$cdt}{$_}}} qw(localwens dtowens)]);
  $arch_string .= "-- BEGIN ===================== <$cdt> =========================\n";
  $arch_string .= "-- Local WENs - BEGIN\n";
  $arch_string .= join(";\n", map {"$$aligned{$$_[0]}  <=  $$_[1]"} @{$$db{wensection}{$cdt}{localwens}}).";\n";
  $arch_string .= "-- Local WENs - END\n\n";
  $arch_string .= "-- OWENs - BEGIN\n";
  $arch_string .= join(";\n", map {"$$aligned{$$_[0]}  <=  $$_[1]"} @{$$db{wensection}{$cdt}{dtowens}}).";\n";
  $arch_string .= "-- OWENs - END\n";
  $arch_string .= "-- END   ===================== <$cdt> =========================\n\n\n";
 }

 my %lh              = (fsmowen=>"FSM OWENs");
    $lh{statevwen}   = "State variable WENs" if $$db{state_enumtype};

 my $lastwen_aligned = RTLUtils::string_align($$db{lastwens_2align});
 foreach (qw(statevwen fsmowen)) {
  next unless $lh{$_};

  $arch_string .= "-- BEGIN ===================== $lh{$_} =====================\n";
  $arch_string .= join(";\n", map {"$$lastwen_aligned{$$_[0]}  <=  $$_[1]"} @{$$db{lastwens}{$_}}).";\n";
  $arch_string .= "-- END   ===================== $lh{$_} =====================\n\n\n";
 }

 if ($$db{autogen}{signal}) {
  $arch_string .= "-- Additional signal assignments\n" if $$db{autogen}{signal};
  $arch_string .= join(";\n", map {"autosig_$_  <=  $$db{autogen}{signal}[$_]"} 0 .. $#{$$db{autogen}{signal}}).";\n\n\n"; 
 }

 state_regen($db, \$arch_string) if $$db{state_enumtype};

 # Misc Assignments
 my $m_once;
 HUtils::recurse($$db{shared}{module}{$$db{fsm}}{architecture}{assignment}, sub {my ($info, $assignlist) = @_;
  $arch_string .= "-- SLICEs\n" unless $m_once++;
  my %seen;
  my $alignassign = RTLUtils::string_align([map {$$_[0]} @$assignlist]);
  foreach (@$assignlist) {
   $arch_string .= "$$alignassign{$$_[0]}  <=  ".specific_rhs({}, "", $$_[1]).";\n" unless $seen{$$_[0]};
   $seen{$$_[0]} = 1;
  }

  $arch_string .= "\n";
 });

 $arch_string .= "END ARCHITECTURE  $$db{conf}{architecture_name};\n";

 $$db{shared}{module}{$$db{fsm}}{architecture}{string} = $arch_string;
}

sub add_signal2align    {my ($db, $newsig) = @_; push @{$$db{signal2align}},    $newsig}
sub add_interface2align {my ($db, $newsig) = @_; push @{$$db{interface2align}}, $newsig}

sub eq_assignment {
my ($db, $arch_string) = @_;

 $$arch_string .= "-- EQ signals' assignments\n";
 my %state_at_end;
 foreach my $ceqv (sort {$a cmp $b} keys %{$$db{signals}{eq}}) {
  my $eqinfo = $$db{signals}{eq}{$ceqv};

  if ($$db{conf}{state_variable} eq $eqinfo->[0]) {
   push @{$state_at_end{state}}, "$$db{eq_assignment_align}{$ceqv}  <=  '1'  WHEN  $$db{conf}{state_variable} = $eqinfo->[1]  ELSE  '0';\n";
  } else {
   push @{$state_at_end{ports}}, "$$db{eq_assignment_align}{$ceqv}  <=  ".test_decod($eqinfo).";\n";
  }
 }

 my @joinarg;
 push @joinarg, @{$state_at_end{ports}}, "\n" if $state_at_end{ports};
 push @joinarg, @{$state_at_end{state}}       if $state_at_end{state};

 $$arch_string .= join('', @joinarg). "\n\n\n";
}

sub test_decod {
my ($testinfo) = @_;
# [0] = signal name
# [1] = tested value (binary string or hexadecimal string)
# [2] = test operator
# [3] = b, d or h
# [4] = size in bits, when d/h size > 1
my ($signame, $testv, $testop, $base, $size) = @$testinfo;

#print "($signame, $testv, $testop, $base, $size)\n";
 if ($base eq "b" && $size == 1) {
   return $testv ? $signame : "NOT($signame)"
   #if ($size == 1) {
   # return $testv ? $signame : "not($signame)"
   #} else {
   # my $reverse_index = $size;
   # map {$reverse_index--; $_ ? "$signame($reverse_index)" : "not($signame($reverse_index))"} split(//, $testv)
   #}
 } else {
  # d/h and b w/ M-bit
  $testop = $testop eq "!=" ? "/=" : $testop;
  "'1'  WHEN  $signame $testop $testv  ELSE  '0'"
 }

}

sub create_data_path {
my ($gdb) = @_;

 my $dp_string = "";
 my $dp_db = {};
 my @const_align;
 my @pulse_align;

 # ONLY used for signals' name assignment purposes
 my $derived_signals = {};


 # Before generating the interface signals more specifically outputs signal it is important to have the following in mind.
 # Signal appearing both as LHS and RHS are by default not declared as output of _DP unless
 # explicitely asked by means of '>'.
 #
 # Using '>' on a LHS makes it also an output of the TOP level ({shared}{exception}{output}) !!!
 #
 # In case the '>' is not used to explicitely request an output (_DP & _TOP) in such a situation, then we still need to
 # look for the case where a LHS/RHS signal ($dp_db->{rhs}) is read by a FSM as a control signal, and hence appear as an 
 # input of at least one FSM. If this happens then _DP should declare this signal as one of its output BUT NOT force it 
 # to also be output of _TOP
 #

 # Foreach module except _DP itself we should visit all of its input ports
 # and check whether or not it is an RHS/LHS signal of _DP
 # If that's the case we should ignore the default behaviour of _DP and declare
 # that signal as an output signal of _DP but not _TOP
 HUtils::Grep($$gdb{shared}{module}, qr/port\s+list/o, sub {my ($info, $plist) = @_;
   # [0] = module name
   return if $info->[0] eq $$gdb{conf}{_dp};
   
  foreach my $cport (@$plist) {
   # [0] = port name
   # [1] = direction
   if ($cport->[1] eq "IN") {
    # Is it a LHS ? (Because it does not matter if it's an RHS or not)
    # Once a LHS appear as a control signal of at least of FSM that signal should be
    # declared as an output of _DP only (not _TOP, unless explicitely requested using '>')
    if ($$gdb{shared}{lhs_atype}{$cport->[0]}) {
     $$gdb{shared}{module}{$$gdb{conf}{_dp}}{extra_info}{dp2fsm}{$cport->[0]} = 1;
    }
   } 
  }
 });

 my $add_clock_n_reset = 0;
 # Iteration over all types
 foreach my $ctype (sort {$a cmp $b} keys %{$$gdb{data_path_info}}) {
  HUtils::KeyGrep($$gdb{data_path_info}{$ctype}, sub {@{$_[0]} == 2}, sub {my ($info, $fsmh) = @_;
    # @$info:
    # [0] = assigned LHS's name with "r", "m", "p" or c"" as type
    # [1] = RHS Value

    # LHS's type
    #$dp_db->{lhs_type}{$info->[0]} = $ctype;

    ++$add_clock_n_reset  unless $ctype eq 'c';

    push @{$dp_db->{sel_signal_bits}{$ctype}{$info->[0]}}, [join ("_", @$info, ($ctype eq 'r' ? "w" : "")."en"), 
                                                            $info->[1], 
                                                            join(" OR ", map {
                                                                          my $pulsename = join("_", $_, @$info, "wen$$gdb{conf}{output_port_suffix}");
                                                                          push @{$dp_db->{input_pulse}{$ctype}}, $pulsename;

                                                                          $pulsename
                                                                         } sort {$a cmp $b} keys %$fsmh)
                                                           ];

    # All INPUT_PULSE will be converted into input port of one bit each
    
    # The following structure should help determining the size of all the RHS and also
    # identify potential problem regarding size information
    # The list will also help creating input port for each of these RHS value with, hopefully their
    # correct size.
    #
    # For a given RHS gives the list of associated LHSs
    #
    # ==> As a consequence one may use ** $dp_db->{rhs} ** HASH as a mean for checking whether or not
    # ==> a given LHS is also an RHS.
    push @{$dp_db->{rhs}{$info->[1]}}, $info->[0];

    # For names' alignment
    push @{$$gdb{a_sel_signal_bits}}, map {$$_[0]} @{$dp_db->{sel_signal_bits}{$ctype}{$info->[0]}};

    # --> Output of the data path should only be all of the RHS signals
  }); 

  push @pulse_align, @{$dp_db->{input_pulse}{$ctype}};
  
  # This HASH gives all the LHS of type $ctype (as key)
  my $lhs_h = $dp_db->{sel_signal_bits}{$ctype};

  # ctype_allhs contains all LHSs w/ type $ctype
  my @ctype_allhs = sort {$a cmp $b} keys %$lhs_h;

  # Pushing a LHS w/ $ctype as type into '$gdb{allhs}' array
  push @{$$gdb{allhs}}, @ctype_allhs;

  # Iterating over all LHS of $ctype
  foreach my $clhs (@ctype_allhs) {
   # Constants
   my $constsize = @{$lhs_h->{$clhs}};
   my $pos = 0;
   #=================================================================
   # Structure used to build the Multiplexer for each LHS
   #=================================================================
   push @{$dp_db->{constant}{$ctype}{$clhs}}, map {my $constname = join("_", "const", $clhs, $$_[1], 'c');
                                                   push @const_align, $constname;

                                                   # Change the name of the RHS in case it happen to also be a LHS with an assignment type different
                                                   # from combinational.
                                                   #
                                                   my $actual_rhs_name = do {
                                                                          my $os             = $$_[1];
                                                                          # 'if any' because the RHS might be an input port
                                                                          my $rhs_type_ifany = $$gdb{shared}{lhs_atype}{$os};
                                                                          if ($rhs_type_ifany && $rhs_type_ifany ne 'c') {
                                                                            # r/rm/m, p support not yet implemented
                                                                            # If $$_[1] is a LHS that's an output
                                                                            if ($$gdb{shared}{exception}{output}{$os}           || 
                                                                                $$gdb{shared}{module}{$$gdb{conf}{_dp}}{extra_info}{dp2fsm}{$os}) {

                                                                             $os = $rhs_type_ifany eq 'm' ? "next_$os" : "i_$os"
                                                                            }
                                                                          }

                                                                          $os
                                                                         };

                                                   [$constname, get_onehot($constsize, $pos++), $actual_rhs_name]
                                                  } @{$lhs_h->{$clhs}};

   # LHS selection's signal expression 
   $dp_db->{sel_signal}{$clhs}  = join(" & ", map {$$_[0]} reverse @{$lhs_h->{$clhs}});

   my @base_selection           = map {"$$_[2]  WHEN  $$_[0]"} @{$dp_db->{constant}{$ctype}{$clhs}};
   # Add the register output for 'r' and 'm'
   push @base_selection, "i_$clhs" unless $ctype eq 'c';
   #
   #
   # Please pay some attention
   #
   # If $$db{shared}{lhs_next_as_output}{$clhs} is defined
   # that means 'next_$clhs' should be driven out
   # That's mean we should modified the name of the signal that will feed the d-input of
   # $clhs register
   $dp_db->{next_name}{$clhs} = $$gdb{shared}{lhs_next_as_output}{$clhs} ? "next_bis_$clhs" : "next_$clhs";
   $dp_db->{next_signal}{$clhs} = join(" ,\n"." " x (length($dp_db->{next_name}{$clhs}) + 5), @base_selection);

   $dp_db->{signal_size}{$clhs}{"sel_$clhs"}   = $constsize; 
   unless ($ctype eq 'c') {
    $dp_db->{signal_size}{$clhs}{"i_$clhs"}    = $$gdb{shared}{"+size"}{$clhs}; 
    $dp_db->{signal_size}{$clhs}{$dp_db->{next_name}{$clhs}} = $$gdb{shared}{"+size"}{$clhs}; 

    push @{$derived_signals->{lhs}{$clhs}}, "i_$clhs", $dp_db->{next_name}{$clhs};
   }

   push @{$derived_signals->{lhs}{$clhs}}, "sel_$clhs";

   # 'alhs' is used for alignment
   push @{$derived_signals->{alhs}}, @{$derived_signals->{lhs}{$clhs}}, $clhs;
  }
 }

 #
 # Entity declaration
 #
 my @clocknreset;
 if ($add_clock_n_reset) {
  @clocknreset = ($$gdb{shared}{'+system'}{clock}, $$gdb{shared}{'+system'}{asreset});
  die '(fsmgen) -E- No system clock defined' unless $$gdb{shared}{'+system'}{clock};
 }

 # Input pulses' declaration
 my @arhs      = sort {$a cmp $b} keys %{$dp_db->{rhs}};
 my $port_decl = RTLUtils::string_align([@clocknreset, @pulse_align,
                                                       @arhs,
                                                       @{$$gdb{allhs}},
                                                       keys %{$$gdb{shared}{side_band_inputport}},
                                                       keys %{$$gdb{shared}{module}{$$gdb{conf}{_dp}}{extra_info}{sliced_output}},
                                                       keys %{$$gdb{shared}{module}{$$gdb{conf}{_dp}}{extra_info}{output}}]);

  $dp_string .= add_header_n_context_clause ($gdb                                                                  ,
                                             file_name      => get_entity_file_name ($gdb, $$gdb{conf}{_dp})       ,
                                             author_signame => get_leaf ($gdb, 'author_signame')                   ,
                                             author_name    => get_leaf ($gdb, 'author_name')                      ,
                                             description    => get_entity_file_description ($gdb, $$gdb{conf}{_dp})
                                            );

  $dp_string .= "ENTITY $$gdb{conf}{_dp} IS\n"; 
  $dp_string .= "  PORT (\n";
  if ($add_clock_n_reset) {
   $dp_string .= "    -- === system ===\n";
   $dp_string .= join(";\n", map {
                                 add_input_port($gdb, $$gdb{conf}{_dp}, '0system', $_); 
                                 "    $$port_decl{$_}  :  IN  STD_LOGIC"
                                } @clocknreset).";\n\n";
  }

 foreach my $ct (keys %{$dp_db->{input_pulse}}) {
  $dp_string .= "    -- === $ct ===\n";
  $dp_string .= join(";\n", map {
                                 add_input_port($gdb, $$gdb{conf}{_dp}, "1pulse in", $_); 
                                 "    $$port_decl{$_}  :  IN  STD_LOGIC"
                                } @{$dp_db->{input_pulse}{$ct}}).";\n"; 
                        
  $dp_string .= "\n";
 }

 # ===========================================================================
 #
 # There is one important thing here, signals appearing as both RHSs and LHSs
 #
 # like, p.e, in
 #
 # (A <- B)
 # (C <- A) or (C <- A[i]) or (C<- A[i:j]) or (C <- A (op= N)) and so on ...
 #
 # Should not be declared as neither an input nor as an output
 # but simply as an internal signal.
 #
 # All LHS are listed in "$$gdb{shared}{lhs_atype}{myLHS}"
 # All RHS are listed in "$dp_db->{rhs}{myRHS}"
 #
 # ===========================================================================


 # Input data declarations (RHSs)
 foreach my $crhs (@arhs, keys %{$$gdb{shared}{side_band_inputport}}) {
  # Should not declare literal constants as inputs
  next if $crhs =~ /^$$gdb{conf}{_literal_constant_re}$/o || $$gdb{shared}{rhs_literal}{map}{$crhs};
  # Is this RHS internally generated ?
  next if $$gdb{shared}{module}{$$gdb{conf}{_dp}}{extra_info}{internal_signal}{$crhs};

  # This RHS is also an LHS, as such should not be declared as an input of _DP
  next if $$gdb{shared}{lhs_atype}{$crhs};

  my $high_index = $$gdb{shared}{"+size"}{$crhs} ? $$gdb{shared}{"+size"}{$crhs} -1 : get_highest_index($dp_db->{rhs}{$crhs}, $gdb);
  $dp_string .= "-- !!!!!!!!!!!!!!!!!!!!!! Can't deduce the size of signal <$crhs> !!!!!!!!!!!!!!!!!!!!!!\n" if $high_index == -1;
  $dp_string .= "    $$port_decl{$crhs}  :  IN  STD_LOGIC".
                ($high_index > 0 ? "_VECTOR($high_index DOWNTO 0)" : ($high_index == 0 ? "" : "_VECTOR(0 DOWNTO 0)")).";\n";

  add_input_port($gdb, $$gdb{conf}{_dp}, "2data in", $crhs, $high_index+1);
 }

 $dp_string .= "\n";

 # Output data declarations (LHSs)
 my $seen_one = 0;
 foreach my $clhs (sort {$a cmp $b} @{$$gdb{allhs}}, keys %{$$gdb{shared}{module}{$$gdb{conf}{_dp}}{extra_info}{sliced_output}}, keys %{$$gdb{shared}{module}{$$gdb{conf}{_dp}}{extra_info}{output}}) {
  unless ($$gdb{shared}{"+size"}{$clhs}) {
   print "-- -W- No size information specified for *$clhs*\n";
   next
  }

  # This LHS is also an RHS or an internally generated signal like in (x[i] <- ...) or sliced as such should not be declared as an ouput of _DP
  unless ($$gdb{shared}{exception}{output}{$clhs} || $$gdb{shared}{module}{$$gdb{conf}{_dp}}{extra_info}{dp2fsm}{$clhs}) {
   next if $dp_db->{rhs}{$clhs} || $$gdb{shared}{side_band_inputport}{$clhs} || $$gdb{shared}{module}{$$gdb{conf}{_dp}}{extra_info}{internal_signal}{$clhs}
  }

  $dp_string .= ";\n" if $seen_one;

  my $max_index  = $$gdb{shared}{"+size"}{$clhs}-1;
  $dp_string .= "    $$port_decl{$clhs}  :  OUT STD_LOGIC".
         ($max_index > 0 ? "_VECTOR($max_index DOWNTO 0)" : ($max_index == 0 ? "" : "_VECTOR(0 DOWNTO 0)"));


  add_output_port($gdb, $$gdb{conf}{_dp}, "3data out", $clhs, $max_index+1);

  # For 'rm' We should also output its next_* as next_* signal too if requested
  if ($$gdb{shared}{lhs_atype}{$clhs} && $$gdb{shared}{lhs_atype}{$clhs} eq 'r' && $$gdb{shared}{lhs_next_as_output}{$clhs}) {
   my $nextname = "next_$clhs";
   my $localign = RTLUtils::string_align([$$port_decl{$clhs}, $nextname]);
   $dp_string .= ";\n    $$localign{$nextname}  :  OUT STD_LOGIC".
         ($max_index > 0 ? "_VECTOR($max_index DOWNTO 0)" : ($max_index == 0 ? "" : "_VECTOR(0 DOWNTO 0)"));

   add_output_port($gdb, $$gdb{conf}{_dp}, "3data out", $nextname, $max_index+1);
  }

  # For 'mr' We should also output its i_* as *_r  too if requested
  if ($$gdb{shared}{lhs_atype}{$clhs} && $$gdb{shared}{lhs_atype}{$clhs} eq 'm' && $$gdb{shared}{lhs_i_as_output}{$clhs}) {
   my $regname = $clhs.'_r';
   my $localign = RTLUtils::string_align([$$port_decl{$clhs}, $regname]);
   $dp_string .= ";\n    $$localign{$regname}  :  OUT STD_LOGIC".
         ($max_index > 0 ? "_VECTOR($max_index DOWNTO 0)" : ($max_index == 0 ? "" : "_VECTOR(0 DOWNTO 0)"));

   add_output_port($gdb, $$gdb{conf}{_dp}, "3data out", $regname, $max_index+1);
  }

  ++$seen_one;
 }

 $dp_string .= "\n  );\n";
 $dp_string .= "END ENTITY $$gdb{conf}{_dp};\n\n\n";

 $$gdb{shared}{module}{$$gdb{conf}{_dp}}{string} = $dp_string;

 my @specific_rhs; HUtils::recurse($$gdb{shared}{lhs_local_assign}, sub {push @specific_rhs, $_[0][-1] if $_[0][-1]});
 #
 # Architecture declaration
 #
 my $arch_decl = RTLUtils::string_align([@const_align, @{$derived_signals->{alhs}}, @{$$gdb{a_sel_signal_bits}}, @specific_rhs]);

 $dp_string = "ARCHITECTURE  $$gdb{conf}{architecture_name}  OF  $$gdb{conf}{_dp}  IS\n\n";

 # CONSTANTs' Declarations
 $dp_string .= "-- ===== constants'declarations =====\n";
 foreach my $ct (sort {$a cmp $b} keys %{$dp_db->{constant}}) {
  $dp_string .= "-- === $ct ===\n";

  foreach my $clhs (sort {$a cmp $b} keys %{$dp_db->{constant}{$ct}}) {
   # Constants should be created ONLY when the *number of alternative* RHS if greater than 1
   # and the type is not combinational
   # That is, there is no need to create a mux with 0s only when one RHS is to be assigned
   # to the current LHS for a combinational signal
   if (@{$dp_db->{constant}{$ct}{$clhs}} > 1 || $$gdb{shared}{lhs_atype}{$clhs} ne 'c') {
     $dp_string .= "-- = $clhs =\n";
     $dp_string .= join(";\n", map {my $quote = length($$_[1]) > 1 ? '"' : "'";
                            "CONSTANT  $$arch_decl{$$_[0]}  :  STD_LOGIC".
                                (length($$_[1]) > 1 ? "_VECTOR(".(length($$_[1])-1)." DOWNTO 0)" : "")." := $quote".$$_[1]."$quote"
                           } @{$dp_db->{constant}{$ct}{$clhs}}).";\n\n";
   }
  }

  $dp_string .= "\n";
 }

 # SIGNALs' Declarations
 $dp_string .= "-- ===== signals' declarations =====\n";
 foreach my $clhs (sort {$a cmp $b} keys %{$dp_db->{signal_size}}) {
   my $ctype  = $$gdb{shared}{lhs_atype}{$clhs};

   $dp_string .= "-- = $clhs =\n";

   # if the LHS appears to also be a RHS or is an explicit internal signal like in (x[i]) or a sliced then a local signal declaration should be done.
   # The UNLESS condition is only used to skip the declaration of the CLHS when needed.
   unless ($$gdb{shared}{exception}{output}{$clhs} || $$gdb{shared}{module}{$$gdb{conf}{_dp}}{extra_info}{dp2fsm}{$clhs}) {
    if ($dp_db->{rhs}{$clhs} || $$gdb{shared}{side_band_inputport}{$clhs} || $$gdb{shared}{module}{$$gdb{conf}{_dp}}{extra_info}{internal_signal}{$clhs}) {

      my $max_index  = $$gdb{shared}{"+size"}{$clhs}-1;
      $dp_string .= "SIGNAL    $$arch_decl{$clhs}  :  STD_LOGIC".
             ($max_index > 0 ? "_VECTOR($max_index DOWNTO 0)" : ($max_index == 0 ? "" : "_VECTOR(0 DOWNTO 0)")).";\n";
    }
   }


   if (@{$dp_db->{constant}{$ctype}{$clhs}} > 1 || $ctype ne 'c' || $dp_db->{constant}{$ctype}{$clhs}[0][2] =~ /^[01]$/o) {

    foreach my $csig (sort {$a cmp $b} keys %{$dp_db->{signal_size}{$clhs}}) {
     my $size = $dp_db->{signal_size}{$clhs}{$csig};
     $dp_string .= "SIGNAL    $$arch_decl{$csig}  :  STD_LOGIC".($size > 1 ? "_VECTOR(".($size-1)." DOWNTO 0)" : "").";\n";
    }
   }

   # The section declares the final WEN signal used to OR all the WENs generated by all the control block and
   # targeting this LHS.
   if (@{$dp_db->{constant}{$ctype}{$clhs}} > 1 || $ctype ne 'c' || $dp_db->{constant}{$ctype}{$clhs}[0][2] =~ /^[01]$/o) {

    foreach my $cselbit (@{$dp_db->{sel_signal_bits}{$$gdb{shared}{lhs_atype}{$clhs}}{$clhs}}) {
     $dp_string .= "SIGNAL    $$arch_decl{$cselbit->[0]}  :  STD_LOGIC;\n";
    }
   }

   # Are there LHS specfic RHS signal declaration ?
   if ($$gdb{shared}{lhs_local_assign}{$clhs}) {
    foreach my $crhs (sort {$a cmp $b} keys %{$$gdb{shared}{lhs_local_assign}{$clhs}}) {
     my $size = $$gdb{shared}{"+size"}{$clhs};
     $dp_string .= "SIGNAL    $$arch_decl{$crhs}  :  STD_LOGIC".($size > 1 ? "_VECTOR(".($size-1)." DOWNTO 0)" : "").";\n"
                    unless $$gdb{already_declared_local_signal}{$crhs};

     $$gdb{already_declared_local_signal}{$crhs} = 1;
    }
   }

   $dp_string .= "\n";
 }

 $dp_string .= "\nBEGIN\n\n";
 foreach my $clhs (sort {$a cmp $b} keys %{$$gdb{shared}{lhs_atype}}) {
  my $ctype  = $$gdb{shared}{lhs_atype}{$clhs};

  $dp_string .= "-- BEGIN =============== $clhs ===============\n";

  # Selection signal bits
  if (@{$dp_db->{constant}{$ctype}{$clhs}} > 1 || $ctype ne 'c' || $dp_db->{constant}{$ctype}{$clhs}[0][2] =~ /^[01]$/o) {
   $dp_string .= "-- sel bits\n";

   my @sel_signal_bits_info = @{$dp_db->{sel_signal_bits}{$ctype}{$clhs}};
   foreach my $cselbit (@sel_signal_bits_info) {
    $dp_string .= "$$arch_decl{$cselbit->[0]}  <=  $cselbit->[2];\n";
   }
  }

  if (@{$dp_db->{constant}{$ctype}{$clhs}} > 1 || $ctype ne 'c' || $dp_db->{constant}{$ctype}{$clhs}[0][2] =~ /^[01]$/o) {

   $dp_string .= "\n";
   $dp_string .= "-- sel\n";
   $dp_string .= $$arch_decl{"sel_$clhs"}."  <=  $dp_db->{sel_signal}{$clhs};\n";
  }

  # For alignment purposes
  my @localign_v     = ("i_$clhs", "(OTHERS => '0')", "'0'");
  my @localign_const = 'OTHERS';
  foreach (@{$dp_db->{constant}{$ctype}{$clhs}}) {
   push @localign_v, $$_[2]; 
   push @localign_v, $$gdb{shared}{rhs_literal}{map}{$$_[2]} if defined $$gdb{shared}{rhs_literal}{map}{$$_[2]}; 
   push @localign_v, literal_constant($$_[2])                if $$_[2] =~ /^$$gdb{conf}{_literal_constant_re}$/o;

   push @localign_const, $$_[0]; 
  }

  my $localign_v      = RTLUtils::string_align([@localign_v]);
  my $localign_const  = RTLUtils::string_align([@localign_const]);
  my @base_selection  = map {
                             $$localign_v{($$_[2] =~ /^$$gdb{conf}{_literal_constant_re}$/o  ? literal_constant($$_[2]) : ($$gdb{shared}{rhs_literal}{map}{$$_[2]} // $$_[2]))}.
                             "  WHEN  $$localign_const{$$_[0]}"

                            } @{$dp_db->{constant}{$ctype}{$clhs}};


  # Used for SLICEs, +=N (++,--)
  if ($$gdb{shared}{lhs_local_assign}{$clhs}) {
   # We have LHS specific RHS definition(s)
   # Like RHS SLICEs and/or INC/DEC of the current LHS
   foreach my $crhs (sort {$a cmp $b} keys %{$$gdb{shared}{lhs_local_assign}{$clhs}}) {
    $dp_string .= "$$arch_decl{$crhs}  <=  ".specific_rhs($$gdb{shared}{lhs_atype}, $clhs, $$gdb{shared}{lhs_local_assign}{$clhs}{$crhs}).";\n" 
                   unless $$gdb{already_assigned_signal}{$crhs};

    $$gdb{already_assigned_signal}{$crhs} = 1;
   }

   $dp_string .= "\n"
  }

  unless ($ctype eq 'c') {
   #============================================================
   #              ~ registered output   r/m/rm/mr/p 
   #              Currently p support is not implemented
   #============================================================

   # Add the register output 
   push @base_selection, $$localign_v{'i_'.$clhs}."  WHEN  $$localign_const{OTHERS}";

   $dp_db->{next_signal}{$clhs} = join(",\n"." " x (length($$arch_decl{$dp_db->{next_name}{$clhs}}) + 6), @base_selection);
   $dp_string .= "\n";
   $dp_string .= "-- next\n";
   $dp_string .= "WITH sel_$clhs SELECT\n";
   $dp_string .= " $$arch_decl{$dp_db->{next_name}{$clhs}} <=  $dp_db->{next_signal}{$clhs};\n";

   $dp_string .= "\n";
   $dp_string .= "-- output\n";
   $dp_string .= $$arch_decl{$clhs}."  <=  ".($ctype eq 'm' ? "next" : "i")."_$clhs;\n";
   #
   # What a trick ! damnnnnn.
   #
   if ($$gdb{shared}{lhs_next_as_output}{$clhs}) {
    my $nextname = "next_$clhs";
    my $localign = RTLUtils::string_align([$$arch_decl{$clhs}, $nextname]);

    $dp_string .= "\n";
    $dp_string .= "-- $nextname as output too\n";
    $dp_string .= $$localign{$nextname}."  <=  $dp_db->{next_name}{$clhs};\n\n";
   }


   if ($$gdb{shared}{lhs_i_as_output}{$clhs}) {
    my $regname = $clhs.'_r';
    my $localign = RTLUtils::string_align([$$arch_decl{$clhs}, $regname]);

    $dp_string .= "\n";
    $dp_string .= "-- i_$clhs as output too\n";
    $dp_string .= $$localign{$regname}."  <=  i_$clhs;\n\n";
   }

   my $default_reset_value =  $$gdb{shared}{asyncreset}{default}{$clhs} || ($$gdb{shared}{"+size"}{$clhs} > 1 ? "(OTHERS => '0')" : "'0'");

   $dp_string .= register_process ($gdb,
                          comment     => "<$clhs>"                       ,
                          clock       => $$gdb{shared}{"+system"}{clock} ,
                          asreset     => $$gdb{shared}{"+system"}{asreset},
                          reset_value => $default_reset_value            ,
                          register    => "i_$clhs"                       ,
                          next_value  => $dp_db->{next_name}{$clhs}      ,
		          label       => 'reg_'.$clhs                   );

  } else {
   #============================================================
   #              combinational output
   #============================================================
   $dp_db->{next_signal}{$clhs} = join(",\n"." " x (length($$arch_decl{$clhs}) + 6), @base_selection);
   # How many RHS do we have here ?
   if (@base_selection == 1) {
     # Are we dealing with a single bit signal ?
     if ($dp_db->{constant}{$ctype}{$clhs}[0][2] =~ /^([01])$/o) {
      # Use the direct or inverted version of the select signal in case
      # $clhs is a single bit signal
      $dp_db->{next_signal}{$clhs} = $1 ? "sel_$clhs" : "NOT(sel_$clhs)"

     } else {
      # Use the single RHS value, that is, it does not make sense to have a mux with 0s here.
      $dp_db->{next_signal}{$clhs} = $dp_db->{constant}{$ctype}{$clhs}[0][2]
     }

   } else { ### !!!!!!!!!!!!!!!!!!!!!!!!!! A TEMPORARY SOLUTION !!!!!!!!!!!!!!!!!!!!!!!!!
    $dp_db->{next_signal}{$clhs} .= ",\n"." " x (length($$arch_decl{$clhs}) + 6).
                                    $$localign_v{($$gdb{shared}{"+size"}{$clhs} > 1 ? "(OTHERS => '0')" : "'0'")}. "  WHEN  $$localign_const{OTHERS}";
   }

   $dp_string .= "\n";
   $dp_string .= "-- output\n" unless $$gdb{shared}{module}{$$gdb{conf}{_dp}}{extra_info}{internal_signal}{$clhs};
   $dp_string .= "WITH sel_$clhs SELECT\n " if @base_selection > 1;
   $dp_string .= "$$arch_decl{$clhs} ".(@base_selection > 1 ? '' : ' ')."<=  $dp_db->{next_signal}{$clhs};\n";
  }

  $dp_string .= "-- END   =============== $clhs ===============\n\n\n\n";
 }


 # Now adding concatenation assignment(s) for sliced output(s)
 my $once = 0;
 foreach my $so (keys %{$$gdb{shared}{module}{$$gdb{conf}{_dp}}{extra_info}{sliced_output}}) {
  $dp_string .= "-- sliced output(s)\n" unless $once++;

  $dp_string .= "-- == $so ==\n";
   
  my @index_list         = sort {$b <=> $a} keys %{$$gdb{shared}{module}{$$gdb{conf}{_dp}}{extra_info}{sliced_output}{$so}};
  my $assigned_slices    = join(" & ", map {$so."_$_"}  @index_list);
  my $fixed_part         = "";

  my $assigned_slicesize = $index_list[0]+1;
  if ($$gdb{shared}{"+size"}{$so}) {
    if ($$gdb{shared}{"+size"}{$so} > $assigned_slicesize + 1) {
      $fixed_part = "(".($$gdb{shared}{"+size"}{$so}-1)." DOWNTO $assigned_slicesize => '0')"; 
    } elsif ($$gdb{shared}{"+size"}{$so} == $assigned_slicesize + 1) {
      $fixed_part = "'0'"; 
    }
  } 

  $dp_string .= "$so  <= ".($fixed_part ? " $fixed_part &" : " ")." $assigned_slices;\n";
 }

 
 $dp_string .= "\nEND ARCHITECTURE  $$gdb{conf}{architecture_name};\n";

 $$gdb{shared}{module}{$$gdb{conf}{_dp}}{architecture}{string} = $dp_string;
}


sub sharedinfo  {my ($db, $node) = @_; HUtils::Merge($$db{shared} //={}, HUtils::Format($node))}
sub get_highest_index {
my ($ghi, $db) = @_;

 if (@$ghi == 1) {
  $$db{shared}{"+size"}{$ghi->[0]} ? $$db{shared}{"+size"}{$ghi->[0]}-1 : -1;
 } else {
  my @sizelist  = map {$$db{shared}{"+size"}{$_}} @$ghi;
  my $undefined = grep {!defined} @sizelist;
  my @defined   = grep {defined} @sizelist;
  my %defined   = map {$_=>1} @defined;;

  return -1 if $undefined || scalar(keys %defined) > 1;
  return  $defined[0]-1
 }
}

# Will be implemented as a dispatch table
sub specific_rhs {
my ($isit_lhs, $lhs, $action_args) = @_;

 # $action_args->[0]                   = action to be performed 
 # $action_args->[1 .. $#$action_args] = additional information, one per position 
 my $prefix = ($$isit_lhs{$action_args->[2]} && $$isit_lhs{$action_args->[2]} ne 'c' ? "i_" : "");
 if ($action_args->[0] eq "incdec") {
  if ($action_args->[1] =~ /\+=(\d+)/o) {
   # increment op
   return $prefix.$action_args->[2]." + $1" 
  }

  if ($action_args->[1] =~ /\-=(\d+)/o) {
   # decrement op
   return $prefix.$action_args->[2]." - $1" 
  }
 } elsif ($action_args->[0] eq "slice") {
  ($$isit_lhs{$action_args->[1]} && $$isit_lhs{$action_args->[1]} ne 'c' ? "i_" : "").
                       "$action_args->[1](".
                       do {
                           if ($action_args->[2] == $action_args->[3]) {
                             $action_args->[2]
                           } elsif ($action_args->[2] > $action_args->[3]) {
                             "$action_args->[2] DOWNTO $action_args->[3]"
                           } else {
                             "$action_args->[2] TO $action_args->[3]"
                          }}.
                    ")"
 } 
}


sub add_input_port {
my ($db, $mod, $grp, $portname, $size) = @_;

 $size ||= 1;
 add_port($db, $mod, $grp, $size > 1 ? [$portname, "IN", "STD_LOGIC_VECTOR", $size-1, 0] : [$portname, "IN", "STD_LOGIC"]);
}

sub add_output_port {
my ($db, $mod, $grp, $portname, $size) = @_;

 $size ||= 1;
 add_port($db, $mod, $grp, $size > 1 ? [$portname, "OUT", "STD_LOGIC_VECTOR", $size-1, 0] : [$portname, "OUT", "STD_LOGIC"]);
}

# signal definition entry info:
# - signal name
# - direction (in/out)
# - type  (std_logic/std_logic_vector/...)
# - highest index (only for multi-bit signals)
# - lowest index  (only for multi-bit signals)
sub add_port {my ($db, $mod, $grp) = splice @_, 0, 3; push @{$$db{shared}{module}{$mod}{port}{list}{$grp}}, @_}

# signal definition entry info:
# - signal name
# - type (std_logic/std_logic_vector/...)
# - highest index (only for multi-bit signals)
# - lowest index  (only for multi-bit signals)
sub add_signal               {my ($db, $mod, $grp) = splice @_, 0, 3; push @{$$db{shared}{module}{$mod}{architecture}{signal}{$grp}}, @_}

# signal assignment entry info:
# - LHS
# - RHS
sub add_assignment {my ($db, $mod, $grp) = splice @_, 0, 3; push @{$$db{shared}{module}{$mod}{architecture}{assignment}{$grp}}, @_}

# component instantiation entry info:
# - component name
# - label
sub add_instance {my ($db, $mod, $grp) = splice @_, 0, 2; push @{$$db{shared}{module}{$mod}{architecture}{instance}{$grp}}, @_}

# selected signal assignment entry info:
# - LHS
# - selection signal name
# - [selected_value0, selected_constant0]
# - [selected_value1, selected_constant1]
# - ...
# - [selected_valueI, selected_constantI]
# - ...
# - [selected_value(N-1), selected_constant(N-1)]
sub add_selected_assignment {my ($db, $mod, $grp) = splice @_, 0, 2; push @{$$db{shared}{module}{$mod}{architecture}{selected_assignment}{$grp}}, @_}

# register process entry info:
# - register name
# - next expression
# - register reset value (always a constant value as per the VHDl LRM)
# - label
# - clock name
# - clock active edge
# - reset name
# - reset type (synchronous/asynchronous)
# - reset active level (0/1)
sub add_register_process {my ($db, $mod, $grp) = splice @_, 0, 2; push @{$$db{shared}{module}{$mod}{architecture}{register_process}{$grp}}, @_}

# constant definition entry info:
# - constant name
# - type (std_logic/std_logic_vector)
# - value
# - associated info, if any, using a array ref [...]. Set it undef if no associated info
# - highest index (only for multi-bit signals)
# - lowest index  (only for multi-bit signals)
sub add_constant {my ($db, $mod, $grp) = splice @_, 0, 3; push @{$$db{shared}{module}{$mod}{architecture}{constant}{$grp}}, @_}

# type definition entry info:
#
#  for enumeration type:
#  - type name
#  - val0
#  - val1
#  - ...
#  - val(N-1)
sub add_type {my ($db, $mod, $grp) = splice @_, 0, 3;  push @{$$db{shared}{module}{$mod}{architecture}{type}{$grp}}, @_}

sub create_top {
my ($sdb) = @_;

 my $dpname = $sdb->{conf}{_dp};
 # Extracting $dpname output port names
 my @opset;
 HUtils::recurse($sdb->{shared}{module}{$dpname}{port}{list}, sub {my ($info, $portlst) = @_;
  push @opset, map {$$_[0] => $_} grep {$$_[1] eq "OUT"} @$portlst; 
 });

 my %opset = @opset;

 # By default, Any input port of modules (FSMs: controls) matching anyone of the above outputs will be excluded from the top level (_top) 
 # input port list.
 # 
 # While visiting all input ports of all others module, top level interface will be created on the fly
 #
 my @top_input;
 my %dp2fsm;
 # Excluding _DP from the loop
 foreach (grep {$_ ne $dpname} keys %{$sdb->{shared}{module}}) {
  HUtils::recurse($sdb->{shared}{module}{$_}{port}{list}, sub {my ($info, $portlst) = @_;
   foreach (@$portlst) {
    if ($$_[1] eq "IN") {
     unless ($opset{$$_[0]}) {
      push @top_input, $_ 
     } else {
      # Output port of _dp matching an input of at least one FSM
      $dp2fsm{$$_[0]} = 1;
     }
    }
   }
  });
 }


 # Now uniquifying this port list
 my %uniq_in;
 my @uniq_in;
 foreach (@top_input) {
  push @uniq_in, $_ unless $uniq_in{$$_[0]}; 
  $uniq_in{$$_[0]} = 1;
 }

 my @uniq_sort = sort {$a->[0] cmp $b->[0]} @uniq_in;

 # Retrieving the system's ports
 my %system;
 HUtils::recurse($$sdb{shared}{"+system"}, sub {$system{$_[1]} = 1});

 # Storing them
 my @system = grep {$system{$$_[0]}} @uniq_sort;
 add_port($sdb, $$sdb{conf}{_top}, "0system", @system) if @system;

 # What about the control inputs ? 
 # that is those not matching system port (clock, reset) but feeding FSM
 #
 # Not really useful FSM may not have external input control signals, so don't assume they have.
 # Check first
 my @controlist = grep {!$system{$$_[0]}} @uniq_sort;
 add_port($sdb, $$sdb{conf}{_top}, "1controls", @controlist) if @controlist;

 # Where are inputs data ports then ?
 # They correspond to "data in" ports of _dp ONLY IF THEY DO NOT APPEAR ALSO AS _DP OUTPUT,
 # THIS IS THE DEFAULT BEHAVIOUR.
 #
 # For some pathological and not really useful FSM, no input data "2data in" may be defined
 # 
 # The only work-around I found was the following
 #
 # We should also log _DP input signal that are fed by _DP output. By default these shoud not be
 # seen as _TOP outputs. This situation happen in situation like
 #
 # (A <- B) 
 # (C <- A)
 #
 # As you can see this is a very common idiom, so it should be correctly handled.
 #
 # "A" shouldn't be seen neither as a input nor as an ouput of _TOP, at least by default. 
 #
 # Well after more thought, I think that's not clean for _DP to fed back its outputs to its inputs
 # when wanting to do things like the above, it should be fixed in _DP generation, at least as a default behaviour.
 #
 # Also the set of signals declared in both "1controls" and "1data in" should be uniq
 my %controlsig = map {$$_[0]=> 1} @controlist;
 my %dp2dp;
 if ($sdb->{shared}{module}{$dpname}{port}{list}{"2data in"}) {
  add_port($sdb, $$sdb{conf}{_top}, "1data in", grep {!$controlsig{$$_[0]}} grep {
                                                                             !($dp2dp{$$_[0]} = $opset{$$_[0]})
                                                                            } @{$sdb->{shared}{module}{$dpname}{port}{list}{"2data in"}});
 }
 
 # Finally let's fight with output ports :)
 #
 # By default, output ports of the _dp that are read by at least one FSM OR _DP ITSELF are not ouput of the top.
 # This default may be overriden if needed by a directive set in at least one .fsm driving that _dp port
 # 
 # Output(s) of _DP may by read back in _DP also, like in
 #
 # (A <- B)
 # (C <- A)
 # 
 # !! In this kind of very common situation, A, by default SHOULD NOT BE CONSIDERED as an output of _TOP !!
 #
 #  The trick is to add a '>' symbol as a suffix of the given LHS in at least one of its assignments, like this
 #  (foo_LHS> <- foo_val) 
 #
 # But wait, we already have this set in dp2fsm
 #
 # That's means we just need to exclude them from _dp output port to get _top's output list.
 # But we should NOT exclude those of 'dp2fsm' explicitly marked as output of _top using '>'.
 #
 # The initial list of _top outputs are all outputs of _dp
 # from this set we will exclude 'dp2fsm' and 'dp2dp' signals not marked as explicit output of _top
 #
  
 # Data out
 add_port($sdb, $$sdb{conf}{_top}, "3data out", map {$opset{$_}} grep {
                                                                       !$dp2fsm{$_} && !$dp2dp{$_} ||
                                                                        $sdb->{shared}{exception}{output}{$_}
                                                                      } sort {$a cmp $b} keys %opset);


 # Let's visualize the whole interface now to check
 # my $cclass;
 # HUtils::recurse($sdb->{shared}{module}{$$sdb{conf}{_top}}{port}{list}, sub {my ($info, $portlist) = @_;
 #   print "\n" unless $cclass eq $info->[$#$info];

 #   print join("\n", map {"<@$_>"} @$portlist)."\n";
 #   $cclass = $info->[$#$info];
 # });
 
 # Now let's play with the architecture's content.
 # components to be instantiated in _top
 push @{$sdb->{shared}{module}{$$sdb{conf}{_top}}{architecture}{instance}}, 
        grep {$_ ne $$sdb{conf}{_top}} keys %{$sdb->{shared}{module}}; 

 # For connecting I will be following a simple, but yet effecient principle, which is that are connected
 # together any two ports having the same name. Starting from that we can carefully add exceptions. 
 # Each of these exceptions, if any, should be thought in a way that make them automatable.
 
 # Let's start by linking each entity port name to all entities where it appears.
 # By doing so, we are building a kinda net-list
 my %port2modules;
 my %signalist;
 HUtils::Grep($sdb->{shared}{module}, qr/\bport\s+list\b/o, sub {my ($info, $portlist) = @_;
   # [0] = entity/module name
   return if $info->[0] eq $$sdb{conf}{_top};

   foreach my $cp (@$portlist) {
    # [0] = port name
    # [1] = port direction on that entity/module
    push @{$port2modules{$cp->[0]}{$cp->[1]}}, $info->[0];
    # signalist will contain the list of all nets (IN/OUT/SIGNAL) in _top
    push @{$signalist{$cp->[0]}}, $cp;
   }
 });

 # Based on both port2modules and the above principle
 # I can say that an internal signal should be defined if it is both an input to some entity(ies)/module(s)
 # and also an output to some others
 foreach my $cs (keys %port2modules) {
   my $keycnt = keys %{$port2modules{$cs}};

   # keycnt = 1 -> the port is either and INPUT or an OUTPUT of _top
   # keycnt = 2 -> driven out by one FSM (OUT) and read by at least one other (IN)
   #               by default this will trigger a SIGNAL definition unless stated otherwise using '>'
   #               as indicated above
   if ($keycnt == 2) {
    # We have a true signal based on the above principle
    #
    # Delete the direction before storing the info, since signals' declarations have
    # no direction info.
    unless ($sdb->{shared}{exception}{output}{$signalist{$cs}[0][0]}) { # <== $signalist{$cs}[0][0] == $cs TBT
     # The default behaviour
     #
     # signal driven by one module and read by at least one of the others
     # should be declared as a SIGNAL of _top
     #
     push @{$sdb->{shared}{module}{$$sdb{conf}{_top}}{architecture}{signal}{_default}}, 
       # explicitly omit to include the direction info '[1]', so only keeping 0, 2, ... $#
           [$signalist{$cs}[0][0], @{$signalist{$cs}[0]}[2 .. $#{$signalist{$cs}[0]}]];
    } else {
     # We don't want the default for this signal. Instead of creating a SIGNAL with the actual signal
     # name, we will be creating a signal with a new name. The format of this new name is free.
     # Newname = "i_".OldName, OldName = Actual OUTPUT port name
     push @{$sdb->{shared}{module}{$$sdb{conf}{_top}}{architecture}{signal}{_default}}, 
           ["i_".$signalist{$cs}[0][0], @{$signalist{$cs}[0]}[2 .. $#{$signalist{$cs}[0]}]];

     # Storing the new name for later retrieval by linking it to the actual OUTPUT port name
     $sdb->{shared}{exception}{output}{$signalist{$cs}[0][0]} = "i_".$signalist{$cs}[0][0];
    }
   } elsif ($sdb->{shared}{exception}{output}{$cs}) {
       $sdb->{shared}{exception}{explicit_output_of_dp_not_read_at_top_level}{$cs} = 1;
   }

 }

 # At this stage we have defined the interface ports together with all of the signal declaration
 # So let's try to display them to check 
 #drive_entity_component($sdb,  $$sdb{conf}{_top}, 0);
 #drive_architecture($sdb,  $$sdb{conf}{_top});
} 

sub drive_signals {
my ($sdb, $mod) = @_;

  my @alignthem;
  HUtils::Grep($sdb->{shared}{module}{$mod}{architecture}, qr/signal/o, sub {my ($info, $siglist) = @_;
    foreach (@$siglist) {push @alignthem, $$_[0]}
  });

  my $alignthem = RTLUtils::string_align(\@alignthem);
  my $grp;
  HUtils::Grep($sdb->{shared}{module}{$mod}{architecture}, qr/signal/o, sub {my ($info, $siglist) = @_;
   print "\n"  if $grp && $grp ne $info->[$#$info];

   say join(";\n", map {
                        "SIGNAL    $$alignthem{$$_[0]}  :  ".
                        (@$_ == 2 ? "STD_LOGIC" :
                                    "STD_LOGIC_VECTOR($$_[2] DOWNTO $$_[3])")
                       } sort {$a->[0] cmp $b->[0]} @$siglist).";";

   $grp = $info->[$#$info];
  });

}

sub drive_architecture {
my ($sdb, $mod) = @_;

 say "ARCHITECTURE  $$sdb{conf}{architecture_name}  OF  $mod IS\n";

 RTLUtils::drive_component($$sdb{conf}           , 
                           $sdb->{shared}{module}, 
                           $_                    , 
                           template_info=>($$sdb{shared}{template_info} ||= {})
                          ) foreach (@{$sdb->{shared}{module}{$mod}{architecture}{instance}});

 drive_signals($sdb, $mod);

 say "\nBEGIN\n";
 
 # Specific signal assignment should added here in case we have an EXPLICIT output, that is those explicitly asked
 # by the user using '>' mecanism
 my @axo       = grep {!$sdb->{shared}{exception}{explicit_output_of_dp_not_read_at_top_level}{$_}} sort {$a cmp $b} keys %{$sdb->{shared}{exception}{output}};
 if (@axo) {
  say "-- output assignments";
  my $alignedco = RTLUtils::string_align([@axo]);
  say join(";\n", map  {"$$alignedco{$_}  <=  $sdb->{shared}{exception}{output}{$_}"} @axo).";\n";
 }

 drive_instance($sdb, $_) foreach (@{$sdb->{shared}{module}{$mod}{architecture}{instance}});
 say "END ARCHITECTURE  $$sdb{conf}{architecture_name};";
}

sub drive_instance {
my ($sdb, $mod) = @_;
 
 my $aligned = $sdb->{shared}{module}{$mod}{aligned_ports};
 my $grp;
 my @pm;
 print " $$sdb{conf}{instance_label_prefix}$mod  :  $mod\n   PORT MAP (\n";
 HUtils::recurse($sdb->{shared}{module}{$mod}{port}{list}, sub {my ($info, $portlst) = @_;
   push @pm, '' if $grp && $grp ne $info->[$#$info];
   push @pm,    map     {
                         # If we have an explicitly declared output that is read by other FSM(s) 
                         # then we should modify the actual part of the instantiation
                         my $actual_name = $sdb->{shared}{exception}{output}{$$_[0]} && 
                                           !$sdb->{shared}{exception}{explicit_output_of_dp_not_read_at_top_level}{$$_[0]} ? 
                                           $sdb->{shared}{exception}{output}{$$_[0]} : $$_[0];

                         my $aalign;
                         $aalign = RTLUtils::string_align([$$aligned{$$_[0]}, $actual_name]) if $actual_name ne $$_[0]; 

                         # Adding direction and size information
                         my $port_info = "$$_[1]".($$_[3] ? ('in' eq lc($$_[1]) ? '  ' : ' ')."[$$_[3]:$$_[4]]" : '');

                         # Usually the mofified actual name will be shorted than the aligned version of the
                         # non-modified
                         "     $$aligned{$$_[0]}  =>  " . ($actual_name ne $$_[0] ? $$aalign{$actual_name} : $$aligned{$$_[0]}) . ", -- $port_info"
                        } sort {$a->[0] cmp $b->[0]} @$portlst;

   

   $grp = $info->[$#$info];
 }); 

 $pm[-1] =~ s/,(?= --)/ /o;

 print join "\n", @pm;
 print "\n   );\n\n";
}

sub drive_modules {
my ($sdb) = @_;

 my $cwd  = Cwd::cwd;
 mkpath $sdb->{conf}{output_directory};
 chdir  $sdb->{conf}{output_directory};

 foreach my $cm (keys %{$sdb->{shared}{module}}) {
  mkpath $cm;

  my $entity_file_name = get_entity_file_name($$sdb{conf}, $cm);
  open(my $ch, ">", "$cm/$entity_file_name") || die $@;
  select($ch);

  unless ($cm eq $$sdb{conf}{_top}) {
   print $$sdb{shared}{module}{$cm}{string};
  } else {
   RTLUtils::drive_entity($$sdb{conf}                                               , 
                          $$sdb{shared}{module}                                     , 
                          $$sdb{conf}{_top}                                         , 
                          file_name      => $entity_file_name                       ,
                          author_signame => get_leaf($sdb, 'author_signame')        ,
                          author_name    => get_leaf($sdb, 'author_name')           ,
                          description    => get_entity_file_description ($sdb, $cm) 
                         );
  }

  my $architecture_file_name = get_architecture_file_name($$sdb{conf}, $cm);

  unless (get_leaf($sdb, '\bmerge$')) {
   open ($ch, ">$cm/$architecture_file_name");

   print '', add_header_n_context_clause ($$sdb{conf}                                                    , 
                                          file_name      => $architecture_file_name                      ,
                                          author_signame => get_leaf ($sdb, 'author_signame')            , 
                                          author_name    => get_leaf ($sdb, 'author_name')               ,
                                          description    => get_architecture_file_description ($sdb, $cm)
                                         );
  }

  unless ($cm eq $$sdb{conf}{_top}) {
   print $$sdb{shared}{module}{$cm}{architecture}{string};
  } else {
   drive_architecture($sdb,  $$sdb{conf}{_top});
  }
 }

 chdir  $cwd;
 select STDOUT;
}


sub literal_constant {
my ($const) = @_;

 my ($size, $value) = $const =~ /(\S+)'x?(\S+)/io;
 if ($size) {
  $value = uc $value;
  $const !~ /'x/io ? '"'.sprintf("%0${size}b", $value).'"' :  q(X").(length($value)*4 < $size ? '0' x ($size/4 - length($value)) : "").$value.q(")
 } else {
  $const =~ /([01]+)/o;

  length $1 == 1 ? qq('$1') : qq("$1") 
 }
}

sub get_onehot {
my ($size, $pos) = @_;

 my @onehot = (0) x $size;
 $onehot[$#onehot - $pos] = 1;

 join("", @onehot)
}


sub odb_add {
my @oa = @_;
my ($cr, $etype) = @oa;

 given ($etype) {
  # [2] = value for a constant or name of a signal/port
  when (/constant|signal|port/o)         {return $$cr{odb}{info}{$etype}{$oa[2]}         //= [$etype, @oa]}
  when (/$$cr{conf}{_relationalop_re}/o) {return $$cr{odb}{info}{$etype}{$oa[2]}{$oa[3]} //= [$etype, @oa]}
 }
}

# Use to retrieve a reference based on the name of the object which might be:
# - constant
# - signal
#
# In the current implementation it is assumed that the referenced object already exist
sub odb_get {my ($cr, $otype, $oname) = @_; $$cr{odb}{info}{$otype}{$oname}}

sub push_odb_cstack  {my ($cr, $obj) = @_; push @{$$cr{odb}{cstack}}, $obj}
sub pop_odb_cstack   {my ($cr)       = @_; pop  @{$$cr{odb}{cstack}}}
sub get_odb_cstack   {my ($cr)       = @_; [@{$$cr{odb}{cstack}}]}
sub uniquify_odb_exp {
my ($cr, $op, $opargs) = @_;

 # Retrieving the number of inputs of this boolean op
 my $argcnt = @$opargs;

 return $opargs->[0] unless @$opargs > 1 || $op eq "NOT";

 # Creating the new boolean op
 my $n_op = [$op, $opargs];

 unless ($$cr{odb}{info}{$op}{$argcnt}) {
  $$cr{odb}{info}{$op}{$argcnt} = [];
  # Keeping a reference to the containing array in position [2]
  # Its position in its containing array is remembered in   [3]
  push @$n_op, $$cr{odb}{info}{$op}{$argcnt}, 0;

  # Pushing this new BOOLEAN op into its containing array
  push @{$$cr{odb}{info}{$op}{$argcnt}}, $n_op;

  # Returning that newly created Boolean op
  return $n_op
 } 

 # Is $opargs already present ?
 foreach my $c_op_inst (@{$$cr{odb}{info}{$op}{$argcnt}}) {
  my $match_cnt = 0;
  foreach my $coparg (@$opargs) {
   foreach $carg (@{$c_op_inst->[1]}) {
    if ($coparg == $carg) {++$match_cnt; last}
   }
  }

  if ($match_cnt == $argcnt) {
   # Yes
   # Returning this already existing boolean op
   return $c_op_inst
  }
 }

 # No
 # Keeping a reference to the containing array in position [2]
 # together with its position in its containing array in   [3]
 push @$n_op, $$cr{odb}{info}{$op}{$argcnt}, $#{$$cr{odb}{info}{$op}{$argcnt}} + 1;

 # Pushing this new BOOLEAN op into its containing array
 push @{$$cr{odb}{info}{$op}{$argcnt}}, $n_op;

 # Returning that newly created Boolean op
 return $n_op
}

sub boolean_drive {my ($cr) = @_;

 HUtils::recurse($$cr{odb}{info}, sub {my ($info, $data) = @_;
  # [0] = Entry type
  #

  if ($$info[0] =~ /^NOT|AND|OR|NAND|NOR|XOR|XNOR$/o) {
   # [1] = argument count
   foreach my $c_op (@$data) {
     my @namelist = map {get_expression_name($cr, $_)} @{$c_op->[1]};

     if (@namelist > 1) {
       @namelist = grep {$_ ne "const_1"} @namelist;
     }

     print lc(join('', @$info))."_$c_op->[3]  <=  ", join(" $$info[0] ",@namelist ), "\n"
   }
  }
 });
}

sub get_expression_name {my ($cr, $expr) = @_;

 given ($expr->[0]) {
    when ('constant')                        {(my $value = $expr->[1]) =~ s/'/_/o; return "const_$value"} 
    when (/signal|port/o)                    {return $expr->[1]} 
    when (/$$cr{conf}{_relationalop_re}/o)   {return join('', $expr->[1], $$cr{conf}{_testop}{$expr->[0]}, map {s/"|'//go; $_} $expr->[2])} 
    when (/^NOT|AND|OR|NAND|NOR|XOR|XNOR$/o) {return $expr->[0].@{$expr->[1]}."_$expr->[3]"}
 }
}

sub conv_testedvalue {my ($tstv, $sz, $base) = @_; 

 if ($base eq 'b') {
   $sz > 1 ? q(").join('', (split(//, $tstv))[-$sz .. -1]).q(") : $tstv
 } elsif ($base eq 'd') {
  q(").join('', (split(//, sprintf("%0${sz}b", $tstv)))[-$sz .. -1]).q(");
 } else {
   q(X").$tstv.q(")
 }
}



sub top_exec  {my ($cr, $th, %opt) = @_; $|=1;

 # Entities' CR
 #my $ecr  = {};
 my @tops;
 my %submodules;
 my %plugins;
 Lispish::recurse ($th, postcheck=> sub {!ref($_[0][0]) && $_[0][0] ~~ qr/^\?\&?\w+(?::(\w+)?)?$/o}, post=>sub {my ($ar, $capt, $l) = @_;
		 #return undef unless $ar->[0]=~ /^\?(?<nodetype>&?\w+)(?::(?<nodename>\w+)?)?$/o;
   $ar->[0] ~~ /^\?(?<nodetype>&?\w+)(?::(?<nodename>\w+)?)?$/o;

   my $lcr      = Storable::dclone($cr);
   my $nodename = $+{nodename};
   given ($+{nodetype}) {
    when (/^&(?<macroname>\w+)/o) {# macro call
        my $mcd       = Storable::dclone(HUtils::avv_get($lcr, 'define', $+{macroname}));
        my $m_context = {map {split /=/o} @{$ar->[1]}};

        fsm_handler($lcr, define ($lcr, $mcd, $m_context, %opt), %opt);

        # Interface retrieval
        $$cr{module}{$$lcr{conf}{_top}}{port}{list}{default} //= do {
                       my @if_t;
                       HUtils::Grep ($lcr, qr/shared\smodule\s$$lcr{conf}{_top}\sport\slist/, sub {push @if_t, @{$_[1]}});
                       \@if_t
        };

        return $$lcr{conf}{_top}
    }
    
    # FSM Compile
    when (/^fsmc/o)  {
        # Options
        my %lopt                = map {$_ // 1} Lispish::flatten([grep {ref} @{$ar->[1]}]);
        map {$$lcr{conf}{"_$_"} = $lopt{$_}} keys %lopt;

        # Currently this is useful only when there are more than one fsm name provided
        $$lcr{conf}{_dp}        = ($$lcr{conf}{_top}   = $nodename).'_dp' if $nodename;

	say STDERR "(fsmgen) -I- Processing intermediate hierarchy '$$lcr{conf}{_top}'" if $nodename;
        fsm_analyze ($lcr, [map {$$lcr{fsm}{$_} //= Lispish::multi(PathSearch->go($_, 'fsm'))} grep {!ref && !/^(?:\/|=)/} @{$ar->[1]}]);
        fsm_top_gen ($lcr);

        # Interface retrieval
        my $t = $$cr{module}{$$lcr{conf}{_top}}{port}{list}{default} //= do {
                       my @if_t;
                       HUtils::Grep ($lcr, qr/shared\smodule\s$$lcr{conf}{_top}\sport\slist/, sub {push @if_t, @{$_[1]}});
                       \@if_t
        };

        return {module=>$$lcr{conf}{_top}, portmap=>portlist_2hash ($t, thrumap=>map_objects ($ar->[1]))}
    }

    when (/^rtl/o)      {say STDOUT "(fsmgen) -I- Processing RTL '$nodename'..";
                         my $t     = $$cr{module}{$nodename}{port}{list}{default} //= entity_loader($cr, $nodename);  # Was $lcr...
			 my $g     = generic_objects            ($ar->[1]);
			 my $ov    = override_interface_objects ($ar->[1]);
			 my $iname = get_instance_name          ($ar->[1]);

			 # FIXME Later, since that's really a quick and dirty hack, well I think :-|
			 # $$cr{VHDL_CONSTANTS_HASH} //= $$lcr{VHDL_CONSTANTS_HASH};


			 my @rtl_o = (module=>$nodename, portmap=>portlist_2hash ($t, thrumap=>map_objects ($ar->[1])));
			 push @rtl_o, genericmap      => $g     if %$g;
			 push @rtl_o, override        => $ov    if %$ov;
			 push @rtl_o, instance_name   => $iname if $iname;

                         return {@rtl_o};
    }

    when (/^ports/o)    {say STDOUT "(fsmgen) -I- Processing PORTS '$nodename'..";
                         my $t       = $$cr{module}{$nodename}{port}{list}{default} //= interface_objects ($ar->[1]);
			 my $g       = generic_objects   ($ar->[1]);
			 my $iname   = get_instance_name ($ar->[1]);

			 my @ports_o = (module=>$nodename, portmap=>portlist_2hash ($t, thrumap=>map_objects ($ar->[1])));
			 push @ports_o, genericmap    => $g     if %$g;
			 push @rtl_o,   instance_name => $iname if $iname;

                         return {@ports_o};
    }

    when (/^toplink$/o) {
            $$cr{module}{$nodename}{port}{list}{default} // top_exec ($cr, $$cr{top}{$nodename});  # Was $$lcr...      
	    my $g         = generic_objects   ($ar->[1]);
	    my $iname     = get_instance_name ($ar->[1]);

            my @toplink_o = (module=>$nodename, portmap=>portlist_2hash ($$cr{module}{$nodename}{port}{list}{default}, thrumap=>map_objects ($ar->[1])));

	    push @toplink_o, genericmap    => $g     if %$g;
	    push @toplink_o, instance_name => $iname if $iname;

            return {@toplink_o}
    }

    when (/^top$/o)      {#say "-----------($th->[0])-------- Call-Back for <TOP>($nodename) accessing \$capt to plug here ! ---";

     # This is to avoid RE-building the portmap at the end when visiting this top for the first time
     my $ostruct;
     unless ($$cr{module}{$nodename}{port}{list}{default}) {
      say STDOUT "(fsmgen) -I- Processing TOP '$nodename'..";

      # For each submodule, iterate over its ports, and build a port-to-direction map
      # After processing all submodules and all ports of such submodules, ports having both
      # IN and OUT direction should normally be declared as signals of the current TOP.
      # While IN only ports will be declared as INPUT of the current TOP
      # similarly for OUT only ports.
      #
      # This behavior is the default
      my %acneb_2modpin; # actual_or_embedbare/direction/module --> port hash
      my %signalist;

      #$submodules{$nodename} = [grep {defined} @$capt];
      $submodules{$nodename} = [@$capt];

      # Calling external plugin to modify the current state of both '$cr' and '$top_o' if necessary.
      # This is powerful but should be handled with care !
      if (my $plugins = getop_plugin_list ($ar->[1])) {
       $plugins{$nodename} = $plugins;
      }

      # Adding user-defined ports, if any
      push @{$$cr{module}{$nodename}{port}{list}{default}}, @{interface_objects ($ar->[1])};

      my $init_map  = portlist_2hash ($$cr{module}{$nodename}{port}{list}{default}); 

      my %uniq_decl;
      # Retrieving 'force' info, if any
      my $forceinfo = portlist_2force ($$cr{module}{$nodename}{port}{list}{default}, uniq=>\%uniq_decl); 

      # Creating the following hierarchy
      #
      # current_actual_or_embedbare_name/current_direction/current_module --> hash info of the current port on that module
      #
      my %bit_slice_concat_const;
      # Iterate on each submodule of the current TOP
      foreach my $cm (@{$submodules{$nodename}}) {
       my $cmap = $cm->{portmap};
       my $cmod = $cm->{module};

       # Then iterate on each port of the current submodule
       foreach my $cp (@{$$cr{module}{$cm->{module}}{port}{list}{default}}) {
        my $cpname = $cp->[0];
        my $caname = $$cmap{$cpname}{actual};

	# Adding *support* for the VHDL 'OPEN' keyword in order to leave output of instances unconnected/dandling/opened :)
	# That's simple, If we see the 'open' keyword as a BARE actual then we should NOT add it in $acneb_2modpin.
	if ($caname ~~ /^open$/io) {
         # Also taking the opportunity to make sure the 'open' keyword is upcased
         $$cmap{$cpname}{actual} = uc $$cmap{$cpname}{actual};

	 next
	}

        # 1. Building a Hash linking each ACTUAL and/or embeded BARE names to all of their connected FORMALs' ** directions **
        $acneb_2modpin{$caname}{$cp->[1]}{$cmod} = {%{$$cmap{$cpname}}, _generic_map=>$cm->{genericmap}, _override=>$cm->{override}}; 

        if ($$cmap{$cpname}{mapspec}{replace_atree}) {
         # Remembering info rearding ACTUALs corresponding to Bit/Slice/Concatenation ONLY ==> NOT Bare words
         # In fact I'm just keeping a link to the current port hash table
         push @{$bit_slice_concat_const{$caname}}, {module=>$cmod, porthash=>$$cmap{$cpname}} unless $$cmap{$cpname}{mapspec}{replace_atree}[0] =~ /\?bare:/o;
        
         # The following association is systematically done for all actuals and/or embeded BARE names
         #
         #  current_actual_or_embedbare_name/current_direction/current_module --> hash info of the current port
         #
         #  Also remark that actual with bare name implied by a mapspec will be associated *twice* with the same direction/module->port
         #  - The first time is above, just before this enclosing IF statement                                                         
         #  - And the second time is below in the FOREACH loop                                                                         
         #  
         #  But this does not hurt so.. NOOOOOOO IT HUUURRRRTTT !!!!!, so ANY CHANGE to be done to
	 #  the map info should be done HERE ALSO, IDENTICALLY !!!!.
         #
         $acneb_2modpin{$_}{$cp->[1]}{$cmod} = {%{$$cmap{$cpname}}, _generic_map=>$cm->{genericmap}, _override=>$cm->{override}}
                       foreach keys %{{map {$_=>1} grep {m/^[[:alpha:]]/o} Lispish::flatten($$cmap{$cpname}{mapspec}{replace_atree})}};
        }
       }
      }

      # --------------------------------------------------------------------------------
      # I should check for * bare * names' connexion consistency, I mean the IN and OUT
      # connexions for a given bare signal should make sense.
      #
      # A bare signal/port name may appear in port map
      # 1. directly as the actual and connected to either
      # 2. with one bit selected
      # 3. with a slice
      # 4. within a concatenation
      #
      #  The following IN/OUT configuration are though possible
      #
      #   IN  only  pin(s)   --> This bare name should be a IN interface port
      #   OUT only pin(s)    --> There should be just ONE pin here, in that case
      #                          the correspond bare name should be a OUT interface port
      #   IN and OUT port(s) --> There should be just ONE OUT pin, if that's the case
      #                          then the corresponding bare should be a local signal
      # --------------------------------------------------------------------------------
      foreach my $acebn (keys %acneb_2modpin) {
       #say "Actual Current or Embeded <$acebn>";  

       next if  $bit_slice_concat_const{$acebn};
       # We are ONLY considering BARE actuals ONLY not matching the VHDL OPEN keyword

       my $dircnt = keys %{$acneb_2modpin{$acebn}};
       my $n_ins  = keys %{$acneb_2modpin{$acebn}{IN}};
       my $m_outs = keys %{$acneb_2modpin{$acebn}{OUT}};

       if ($dircnt == 2) {
        # Potential internal signal

        # N-INs and M-OUTs

        # Looks like a correct internal/local signal

        # How to get the size information
        #
        # If it's an actual then that's easy

	# The UNLESS ...  thing has been added for the case where I make use of 'interface-object' together with +endtop/+declarch
	# for explicitely creating signals. The UNLESS condition will be true when this explicit signal **never appears** as 
	# a simple BARE NAME
        helper_find_signalport_size ($cr, \%acneb_2modpin, $nodename, $acebn, 'signal') unless $init_map->{$acebn};

       } else {
        # Potential input/output port

        # N-INs or M-OUTs
        unless ($init_map->{$acebn}) {
         # This potential interface port is not defined yet
         # OK, then let's try to simply deduce its size
         #
         # A way to do it, is to apply the same method as we did for internal signal
         # If $acebn directly appears to be an actual, that is, it is not part of any bit selection or
         # slice or concatenation expression then...
         helper_find_signalport_size ($cr, \%acneb_2modpin, $nodename, $acebn, 'port');
        }
       }
      }

      # At this point we have defined all the interface ports of the current TOP
      # So we can now create a local portmap to be used for this first full run 
      # on this TOP based on the user-specification

      my $portmap = portlist_2hash  ($$cr{module}{$nodename}{port}{list}{default}, thrumap=>map_objects ($ar->[1]));
      my $sighash = signalist_2hash ($$cr{module}{$nodename}{signal}{default});

      my $port_n_signal_ht = Storable::dclone ($portmap);
      HUtils::Merge($port_n_signal_ht, $sighash);


      # -----------------------------------------------------------------------------------------------------------
      #  Here I am dealing with ** auto-generated ** contant/signal/assignment names
      #  Signals' names created here WON'T BE PROPAGATED UP the hierarchy, that means they stay LOCAL
      # -----------------------------------------------------------------------------------------------------------
      # =!=!=!=!= Adding auto-generated Bit/Slice/Concatenation related signals and associated assignment =!=!=!=!=
      my %decl_obj;
      foreach my $bscn (sort {$a cmp $b} keys %bit_slice_concat_const) {
       # -------------------------------------------------------------------------------------------------
       # Will do more checks later, for now I just want to see if the basic functionality is there
       # -------------------------------------------------------------------------------------------------
       #
       # I should iterate, for a given $bscn, over all of its table indexes, AND NOT JUST [0]
       # To to do more Sanity Checks !!
       #
    
       #
       #
       # Very Important
       #
       # The case where a *bit_slice_concatenate_constant* signal is connected to both INs and OUTs is not considered
       # If issue(s) with this type occur then I will fix it
       #
       # For now I will consider only INs or OUTs directions type, not both.
       #
       my @direction = keys %{$acneb_2modpin{$bscn}};
       if (@direction == 1) {
        get_signal_n_assignment_objects ($nodename                                                          ,
		                         $bit_slice_concat_const{$bscn}[0]{porthash}{mapspec}{replace_atree},
					 \%uniq_decl                                                        ,
					 \%decl_obj                                                         ,
					 $port_n_signal_ht                                                  ,
					 $direction[0]);
       } else {
        die "(fsmgen) -E- ($nodename) Bit/Slice/Concatenate/Const signal '$bscn' connected to both INs and OUTs pins issue,"
       }
      }

      # Auto-generated constant definition(s)
      push @{$$cr{module}{$nodename}{constant}{default}},   @{$decl_obj{constant}}    if $decl_obj{constant};
      push @{$$cr{module}{$nodename}{constant}{default}},   @{$forceinfo->{constant}} if $forceinfo->{constant};

      # Auto-generated Bit/Slice/Concatenation signal definition(s)
      push @{$$cr{module}{$nodename}{signal}{default}},     @{$decl_obj{signal}}      if $decl_obj{signal};

      # Auto-generated Bit/Slice/Concatenation/Constant assignments definition(s)
      push @{$$cr{module}{$nodename}{assignment}{default}}, @{$decl_obj{assign}}      if $decl_obj{assign};
      push @{$$cr{module}{$nodename}{assignment}{default}}, @{$forceinfo->{assign}}   if $forceinfo->{assign};

      # Retrieving non-standard types
      my $non_standard   = [sort {$a->[1] cmp $b->[1]} 
                              grep {$$_[2] =~ /$$lcr{conf}{non_standard_type_re}/o} 
                                 @{$$cr{module}{$nodename}{port}{list}{default}}];

      # INPUTs first and filtering-out non-standard types
      $$cr{module}{$nodename}{port}{list}{default} = [sort {$a->[1] cmp $b->[1]} 
                                                       grep {$$_[2] !~ /$$lcr{conf}{non_standard_type_re}/o} 
                                                          @{$$cr{module}{$nodename}{port}{list}{default}}];

      # Moving non-standard types to the bottom
      push @{$$cr{module}{$nodename}{port}{list}{default}}, @$non_standard;

      # Sort signals by name
      $$cr{module}{$nodename}{signal}{default}  = [sort {$a->[0] cmp $b->[0]} 
                                                         @{$$cr{module}{$nodename}{signal}{default}}] if $$cr{module}{$nodename}{signal}{default};

      push @tops, $nodename;
      $ostruct = {module=>$nodename, portmap=>$portmap}
     } # unless

     my $top_o  = $ostruct // {module=>$nodename, portmap=>portlist_2hash ($$cr{module}{$nodename}{port}{list}{default}, thrumap=>map_objects ($ar->[1]))};

     my $iname              = get_instance_name ($ar->[1]);
     my $g                  = generic_objects   ($ar->[1]);
     $$top_o{genericmap}    = $g     if %$g;
     $$top_o{instance_name} = $iname if $iname;


     # [ENDTOP] Plugin call, if needed
     $$_{plugin}->($cr, top=>$nodename, submodules=>$submodules{$nodename}, topdata=>$top_o, _args=>$$_{args}) foreach @{$plugins{$nodename}{endtop} // []};

     return $top_o
    } # TOP when
   } # given

 }); # Lispish

 
 drive_tops ($cr, \@tops, \%submodules, \%plugins);
 #Table2SS::DriveTableTree('top.xls', 'Blocks', $ecr);
}

sub drive_tops {my ($cr, $tops, $submodules, $plugins) = @_;

 my $cwd  = Cwd::cwd;

 mkpath $cr->{conf}{output_directory};
 chdir  $cr->{conf}{output_directory};
 
 my %plugin_common_struct;

 $$cr{conf}{_user_defined_clause} = 1;
 foreach my $ct (@$tops) {
  mkpath $ct;

  my $entity_file_name = get_entity_file_name ($cr, $ct);
  open(my $ch, ">", "$ct/$entity_file_name") || die $@;
  select($ch);

  RTLUtils::drive_entity($$cr{conf}                                              , 
                         $$cr{module}                                            , 
                         $ct                                                     , 
                         file_name      => $entity_file_name                     ,
                         author_signame => get_leaf($cr, 'author_signame')       ,
                         author_name    => get_leaf($cr, 'author_name')          ,
                         description    => get_entity_file_description ($cr, $ct)
                 );


  my $architecture_file_name = get_architecture_file_name ($cr, $ct);
  open ($ch, ">$ct/$architecture_file_name") unless get_leaf($cr, '\bmerge$');

  # [CCLAUSEARCH] Plugin call, if needed
  my %cclausearch;
  do {$$_{plugin}->($cr, 
		    cclausearch => \%cclausearch          , 
		    _common     => \%plugin_common_struct , 
		    _args       => $$_{args})} foreach @{$plugins->{$ct}{cclausearch} // []};
  

  print '', add_header_n_context_clause ($cr                                                                        ,
                                         file_name       => $architecture_file_name                                 , 
                                         author_signame  => get_leaf($cr, 'author_signame')                         ,
                                         author_name     => get_leaf($cr, 'author_name')                            ,
                                         description     => get_architecture_file_description ($cr, $ct)            ,

				         ($cclausearch{pkg_list} ? (last_minute_pkg => $cclausearch{pkg_list}) : ())
                                        ) unless get_leaf($cr, '\bmerge$');

  say "ARCHITECTURE  $$cr{conf}{architecture_name}  OF  $ct IS\n";

  # Component declaration
  my %comp_inst_cnt;
  foreach (sort {$a->{module} cmp $b->{module}} @{$submodules->{$ct}}) {
   RTLUtils::drive_component ($$cr{conf}, $$cr{module}, $$_{module}, generic=>$$_{genericmap}) unless $comp_inst_cnt{$$_{module}};
   ++$comp_inst_cnt{$$_{module}};
  }


  my $al = RTLUtils::string_align ([map {$$_[0]} @{$$cr{module}{$ct}{signal}{default}}, @{$$cr{module}{$ct}{constant}{default}}]);

  # [DECLARCH] Plugin call, if needed
  $$_{plugin}->($cr                                                  , 
	        top          => $ct                                  , 
		submodules   => $submodules->{$ct}                   , 
		align_hash   => \$al                                 , 
		constant_tbl => $$cr{module}{$ct}{constant}{default} ,
		signal_tbl   => $$cr{module}{$ct}{signal}{default}   ,
		_common      => \%plugin_common_struct               ,
		_args        => $$_{args}) foreach @{$plugins->{$ct}{declarch} // []};


  my @consts = map {"CONSTANT  $$al{$$_[0]} : $$_[1]".(defined $$_[2] ? "($$_[2] DOWNTO $$_[3])" : "")." := $$_[4]"} @{$$cr{module}{$ct}{constant}{default}};
  say join (";\n", @consts), ";\n" if @consts;

  my @sigs   = map {"SIGNAL  ".(@consts ? "  " : "")."$$al{$$_[0]} : $$_[1]".(defined $$_[2] ? "($$_[2] DOWNTO $$_[3])" : "")} @{$$cr{module}{$ct}{signal}{default}};
  say join (";\n", @sigs), ";\n" if @sigs;

  say "\nBEGIN\n";


  # [BEGINARCH] Plugin call, if needed
  $$_{plugin}->($cr, 
	        top          => $ct                    , 
		submodules   => $submodules->{$ct}     , 
		_common      => \%plugin_common_struct ,              ,
		_args=>$$_{args}) foreach @{$plugins->{$ct}{beginarch} // []};


  my $actual = RTLUtils::string_align ([map {my $modref=$_; (map {$$modref{portmap}{$$_[0]}{actual}} 
                                                         @{$$cr{module}{$$modref{module}}{port}{list}{default}}), $$modref{genericmap} ? values %{$$modref{genericmap}}: ()} @{$submodules->{$ct}}]);

  my $cal    = RTLUtils::string_align ([map {(map {$$_[0]} @{$$cr{module}{$$_{module}}{port}{list}{default}}), $$_{genericmap} ? keys %{$$_{genericmap}}: ()} @{$submodules->{$ct}}]);

  my %all_assign;
  foreach my $ca (@{$$cr{module}{$ct}{assignment}{default}}) {
   given ($ca->[1]) {
    when ('bit') {
       if ($ca->[2] eq 'IN') {
        push @{$all_assign{IN}{bit}},  [$$ca[0], "$$ca[3][0]($$ca[3][1])"]
       } else {
        push @{$all_assign{OUT}{bit}}, ["$$ca[3][0]($$ca[3][1])", $$ca[0]]
       }
    }

    when ('slice') {
       if ($ca->[2] eq 'IN') {
        push @{$all_assign{IN}{slice}},  [$$ca[0], "$$ca[3][0]($$ca[3][1] DOWNTO $$ca[3][2])"]
       } else {
        push @{$all_assign{OUT}{slice}}, ["$$ca[3][0]($$ca[3][1] DOWNTO $$ca[3][2])", $$ca[0],]
       }
    }

    when ('concat') {
       if ($ca->[2] eq 'IN') {
	 # push @{$all_assign{IN}{concat}},   [$$ca[0], join ' & ', map {$$_[0]} @{$$ca[3]}]
        my $b_index = 0;
        foreach my $cel (reverse @{$$ca[3]}) {
         my $msi = $b_index + $$cel[1] - 1;
	 my $lsi = $b_index;
         push @{$all_assign{IN}{concat}}, ["$$ca[0](".($msi != $lsi ? "$msi DOWNTO $lsi" : $msi).")", $$cel[0]];

         $b_index += $$cel[1]
        }
       } else {
        my $b_index = 0;
        foreach my $cel (reverse @{$$ca[3]}) {
         my $msi = $b_index + $$cel[1] - 1;
	 my $lsi = $b_index;
         push @{$all_assign{OUT}{concat}}, [$$cel[0], "$$ca[0](".($msi != $lsi ? "$msi DOWNTO $lsi" : $msi).")"];

         $b_index += $$cel[1]
        }
       }
    }

    when ('constant') { # Same action for both IN and OUT
        push @{$all_assign{$ca->[2]}{const}},  [$$ca[0], $$ca[3][0]]
    }
   }
  }

  my @asal; hrecurse(\%all_assign, sub {push @asal, map {$$_[0]} @{$_[1]}});
  my $asal = RTLUtils::string_align ([@asal, map {$$_[0]} @{$plugin_common_struct{top}{$ct}{assignment_list} // []}]);


  if ($plugin_common_struct{top}{$ct}{assignment_list}) {
   say "$$asal{$$_[0]}  <=  $$_[1];" foreach @{$plugin_common_struct{top}{$ct}{assignment_list}};
   say "\n\n";
  }


  foreach my $t (qw/bit slice concat const/) {
   foreach my $d (qw/IN OUT/) {
    if ($all_assign{$d}{$t}) {
     say "\n-- $t $d";
     say "$$asal{$$_[0]}  <=  $$_[1];" foreach @{$all_assign{$d}{$t}};
    }
   }
  }


  say "\n\n";
  my %mod_inst_idx;
  foreach my $cm (sort {$a->{module} cmp $b->{module}} @{$submodules->{$ct}}) {
   ++$mod_inst_idx{$cm->{module}} unless $cm->{instance_name};
   my $instance_name = $$cr{conf}{instance_label_prefix}.($cm->{instance_name} // $cm->{module}.($comp_inst_cnt{$cm->{module}} > 1 ? "_$mod_inst_idx{$cm->{module}}" : ''));

   say "$instance_name  :  $cm->{module}";
   
   # Generic map
   if ($cm->{genericmap}) {
    say "  GENERIC MAP (";
    my @genericmap = map {"    $$cal{$_}  =>  $$actual{$cm->{genericmap}{$_}},"} keys %{$cm->{genericmap}};
    $genericmap[-1] =~ s/,$/ /o;
    say join ("\n", @genericmap);
    say "  )"
   }

   # Port map
   say "  PORT MAP (";
   my @pm  = map {"    $$cal{$$_[0]}  =>  $$actual{$cm->{portmap}{$$_[0]}{actual}}, -- ".$$_[1].(defined $$_[3] ? ('in' eq lc($$_[1]) ? '  ' : ' ')."[$$_[3]:$$_[4]]" : '')} 
               @{$$cr{module}{$cm->{module}}{port}{list}{default}};

   say  STDOUT  "   PM $instance_name  :  $cm->{module}" unless $pm[-1];

   $pm[-1] =~ s/,(?= --)/ /o;
   print join "\n", @pm;

   say "\n  );\n"
  }
  

  # [ENDARCH] Plugin call, if needed
  $$_{plugin}->($cr, 
	        top        => $ct                    , 
		submodules => $submodules->{$ct}     , 
		_common    => \%plugin_common_struct ,
		_args      => $$_{args}) foreach @{$plugins->{$ct}{endarch} // []};


  say "END ARCHITECTURE  $$cr{conf}{architecture_name};";
 }

 $$cr{conf}{_user_defined_clause} = 0;

 chdir  $cwd;
 select STDOUT;
}

# bn = Block Name
sub entity_loader {my ($cr, $bn) = @_;

 state $ea_2d = dunit_2data(retrieve_vhdlcompile_db($$cr{conf}{rtldb}));

 # Hash for VHDL constants with type (integer/natural/positive)
 $$cr{VHDL_CONSTANTS_HASH} //= {grep defined, map {
		                   say "(fsmgen) -I- Loading Package '$_' Numeric Constants's definition..";
                                   Lispish::grep (avv_get($ea_2d, 'package', $_, 'data'), qr/\?constant_declaration:/o, sub {
			            	                                                                # 1=name
			            									# 2=type
			            									# 3=expression
                                                                                                        $_[0][2] =~ /\b(?:integer|natural|positive)\b/io ? ($_[0][1] => $_[0][3]) : (undef, undef)
                                                                                                        }) 
			         } @{get_leaf($ea_2d, '\bpackage_list$')}
		                };

  [Lispish::grep(avv_get($ea_2d, 'entity', $bn, 'data'), qr/\?port_decl:/o, sub {$_[0][1]})];
}

sub define {my ($cr, $dh, $ctxt, %opt) = @_;
 Lispish::recurse ($dh, sub {$_[0] = join "", map {m/\[/o ? expand($ctxt, $_) : $_} split /(\[(?:[^\[\]]++|(?R))*\])/o, $_[0]});  
}

sub expand {my ($ctxt, $s) = @_;

  $s =~ s/\[/(/og;
  $s =~ s/\]/)/og;

  Lispish::recurse (Lispish::single(\$s), 
	            sub {my ($v, $ar, $i, $l) = @_;
                      return undef unless $v; say $v;

                      $v    =~ s{([a-zA-Z]\w*)}{$ctxt->{$1} || $1}oeg;
                      $_[0] = $v
                    }, 
                    postcheck => sub {!ref ($_[0][0])}, 
                    post      => sub {my ($ar, $capt, $ll) = @_;
                      my ($subname) = $ar->[0] =~ /\?(\w+):/o; 
                      my $func      = $subname && *$subname{CODE};

                      if ($func) {
                       $func->($capt)
                      } else {
                       my @m    = map {m/^[a-zA-Z]\w*$/o ? $_ : eval} grep {defined} Lispish::flatten($ar);
                       my $eval = grep !/^[a-zA-Z]\w*$/o, @m;
                       my $j    = join '', @m;

                       $eval ? eval $j : $j 
                      }
  });

}


sub size {my ($lst) = @_;
 my $log2_of = log(eval(join '', @$lst[1 .. $#$lst]))/log(2);
   ($log2_of =~ /\./o ? int($log2_of) : $log2_of) + 1 
}


sub AUTOLOAD {LinkedSpec::dispatch_plugin_autoload_name($AUTOLOAD, @_)}

1;
