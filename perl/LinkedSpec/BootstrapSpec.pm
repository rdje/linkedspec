package LinkedSpec::BootstrapSpec;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedRE ();

sub _trim_bootstrap_value {
 my ($value) = @_;
 return undef unless defined $value;
 $value =~ s/^\s*|\s*$//go;
 return $value
}

#------------------------------------------------------------------------------
# Function: _parse_method_call_chain
# Purpose : Parse `.method(args).method2(args2)` chains into ordered call
#           descriptors while preserving nested-parenthesis argument payloads.
# Args    : ($chain)
# Returns : arrayref of { method => ..., args => ... } or undef on parse error
#------------------------------------------------------------------------------
sub _parse_method_call_chain {
 my ($chain) = @_;
 return [] unless defined($chain) && length($chain);

 my @calls;
 pos($chain) = 0;
 while ($chain =~ /\G\s*\.\s*(?<method>\w+)(?<args>\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))?/gc) {
  my $args = $+{args};
  if (defined $args) {
   $args =~ s/^\s*\(//o;
   $args =~ s/\)\s*$//o;
  }
  push @calls, {
   method => $+{method},
   args   => $args,
  };
 }

 return \@calls if $chain =~ /\G\s*$/gc;
 return undef
}

#------------------------------------------------------------------------------
# Function: _method_chain_return_uses_general_payload
# Purpose : Detect method-chain `.return(...)` payloads that should be emitted
#           as `return(payload)` without implicit scope-label injection.
# Args    : ($args)
# Returns : boolean
#------------------------------------------------------------------------------
sub _method_chain_return_uses_general_payload {
 my ($args) = @_;
 return 0 unless defined $args;
 my $trimmed = _trim_bootstrap_value($args);
 return 0 unless defined($trimmed) && length($trimmed);
 return $trimmed =~ /^(?:\[|\{|"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|-?\d+(?:\.\d+)?|scalar\s*\(|array\s*\(|hash\s*\()/o ? 1 : 0
}

#------------------------------------------------------------------------------
# Function: _render_method_call_chain
# Purpose : Render parsed method-chain calls into semicolon-joined helper-style
#           calls with entry label injected as first argument.
# Args    : ($entry_label, $chain)
# Returns : rendered code string or undef
#------------------------------------------------------------------------------
sub _render_method_call_chain {
 my ($entry_label, $chain) = @_;
 my $calls = _parse_method_call_chain($chain);
 return undef unless $calls && @$calls;
 my @rendered = map {
  my $method = $_->{method};
  my $args = $_->{args};
  if ($method eq 'return' && _method_chain_return_uses_general_payload($args)) {
   return $method . '(' . $args . ')';
  }
  $method . "($entry_label" . ((defined($args) && length($args)) ? ",$args" : '') . ')'
 } @$calls;
 return join '; ', @rendered
}

sub _build_bootstrap_registry_gdata {
 my ($spec_descr) = @_;

 my %bootstrap_rule_index = map {
  my $id = $spec_descr->[$_]{id};
  defined $id ? ($id => $_) : ()
 } 0 .. $#$spec_descr;

 for my $required_rule_id (qw/SPEC_ROOT CURLY_BRACE/) {
  die "(LinkedSpec.pm) -E- Missing required bootstrap rule id '$required_rule_id'"
   unless defined $bootstrap_rule_index{$required_rule_id};
 }

 my @bootstrap_start_res;
 my @bootstrap_start_dispatch;
 for my $idx (0 .. $#$spec_descr) {
  my $rule = $spec_descr->[$idx];
  next unless ref($rule) eq 'HASH';
  next unless exists $rule->{tags} && ref($rule->{tags}) eq 'HASH' && $rule->{tags}{start_token};
  next unless exists $rule->{re} && ref($rule->{re}) eq 'ARRAY' && @{$rule->{re}};
  push @bootstrap_start_res, $rule->{re}[0];
  push @bootstrap_start_dispatch, $idx;
 }

 die "(LinkedSpec.pm) -E- Bootstrap start-token registry is empty"
  unless @bootstrap_start_res && @bootstrap_start_dispatch;

 my @bootstrap_cbrace_res = ();
 if (defined $bootstrap_rule_index{CURLY_BRACE}
     && exists $spec_descr->[$bootstrap_rule_index{CURLY_BRACE}]{re}
     && ref($spec_descr->[$bootstrap_rule_index{CURLY_BRACE}]{re}) eq 'ARRAY') {
  @bootstrap_cbrace_res = @{$spec_descr->[$bootstrap_rule_index{CURLY_BRACE}]{re}};
 }

 my $gdata = {
  startREs       => LinkedRE::oredRE(@bootstrap_start_res),
  start_dispatch => \@bootstrap_start_dispatch,
  cbrace         => LinkedRE::oredRE(@bootstrap_cbrace_res)
 };

 return (\%bootstrap_rule_index, $gdata);
}

#------------------------------------------------------------------------------
# Function: build_bootstrap_spec
# Purpose : Build and return the hardcoded bootstrap grammar descriptor and its
#           compiled dispatch metadata (registry + gdata).
# Args    : none
# Returns : ($spec_descr, $bootstrap_rule_index_ref, $gdata)
#------------------------------------------------------------------------------
sub build_bootstrap_spec {
 my %bootstrap_rule_index;
 my $node_type = {
  '&'       => 'AND',
  '|'       => 'OR',
  '+'       => 'REP_PLUS',
  '*'       => 'REP_STAR',
  '?'       => 'REP_OPT'
 };

 my $spec_descr = [
 {# Spec			-0-
  id => 'SPEC_ROOT',
  tags => { root => 1 },
  handler=> sub {
   my ($descr, $string, $gdata) = @_;
   my @specentry;
   my @specs;
   while (1) {
    my $minfo = LinkedRE::or($string, $$gdata{startREs});
    unless($minfo) {
	   # print "(Spec) Closing specentry DUE TO EOF\n" if @specentry;
     push @specs, [@specentry] if @specentry;
     return [@specs]
    }

    my $dispatch_idx = $$gdata{start_dispatch}[$$minfo{index}];
    return undef unless defined $dispatch_idx;

    my $retv = &{$$descr[$dispatch_idx]{handler}}($minfo, $descr, $string, $gdata);
    return undef unless $retv;

    unless ($$retv[0] eq 'COMMENT') {
     if ($$retv[0] =~ /ELABEL/o) {
      if (@specentry) {
       # say '(Spec) Closing specentry DUE TO NEW Entry';
       push @specs, [@specentry];
       # print "(Spec) Re-Initializing specentry (@{$retv})\n";
       @specentry = $retv
      } else {
      # say "(Spec) Initializing specentry @{$retv})";
      push @specentry, $retv;
       # Hack
       #$gdata->{_current_entry} = $retv->[1]
      }
     } else {
      # say "(Spec) Pushing in specentry (@{$retv})";
      push @specentry, $retv;
     }
    }

   }
  }

 },

 {# Entry Label
  id => 'ENTRY_LABEL',
  tags => { start_token => 1 },
  re=> [qr/\w+\s*::?(?:&|\||\+|\*|\?)?/o],
  handler=> sub {
   my ($info, undef, undef, $gdata) = @_;
   $$info{match} =~ s/\s*://o;

   #say "\n(Entry Label) ($$info{match})";
   my $target = $$info{match} =~ /:/ ? '_INITIAL' : '';
   $$info{match} =~ s/://o;
  
   $$info{match} =~ s/(\W)//o;
   $gdata->{_current_entry} = $$info{match};
   return ["ELABEL$target", $$info{match}, $1 ? $node_type->{$1} : "default"]
  }
 },

 {# RE pattern
  id => 'RE_PATTERN',
  tags => { start_token => 1 },
  re=> [qr/(?<!\\)\/.+?(?<!\\)\//o],
  handler=> sub {
   my ($info) = @_;
   $$info{match} =~ s/^\/|\/$//g;

   #say "(RE pattern) ($$info{match})";
   return ['RE', $$info{match}]
  }
 },

 {# Action code block
  id => 'ACTION_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/->\s*\w+(?:\[\d+\])?\s*\{/o, qr/\}/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;

   my $ipos = pos($$string);
   my ($entry_label, $reidx) = $$info{match} =~ /(\w+)(?:\[(\d+)\])?/o; 
   $reidx = $reidx || 0;

   #say "(Action code block)($$info{match})($entry_label, $reidx)";
   while (1) {
    my $minfo = LinkedRE::or($string, $$gdata{cbrace});
    return undef unless $minfo;

    if ($$minfo{index} == 1) {
     # Closing brace, recursion stops here
     #say "(Action code block) (${\(substr($$string, $ipos, pos($$string) - $ipos - 1))}) Closing";
     return ['ACODE', {relabel=>$entry_label, reidx=>$reidx, code=>substr($$string, $ipos, pos($$string) - $ipos - 1)}]
    } elsif ($$minfo{index} == 0) {
     # Opening brace found, triggering recursion
     # say '(Curly BRACE) Recursion';
     &{$$descr[$bootstrap_rule_index{CURLY_BRACE}]{handler}}($minfo, $descr, $string, $gdata);
     # say '(Curly BRACE) Back From Recursion';
    } else {
     #say "QUOTES <$$minfo{match}>"
    }
   }
  }
 },

 {# Method-like Empty Action code block
  id => 'METHOD_EMPTY_ACTION_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/->\s*(?<ENTRY_LABEL>\w+)\s*(?:\[\s*(?<INDEX>\d+)\s*\]\s*)?(?<CHAIN>(?:\s*\.\s*\w+(?<PAREN>\s*\((?:[^\(\)]++|(?&PAREN))*\))?)+)/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;
   my ($entry_label, $reidx, $chain) = @{$$info{match_hash}}{qw/ENTRY_LABEL INDEX CHAIN/};
   my $code = _render_method_call_chain($entry_label, $chain);
   return undef unless defined $code;
   return ['ACODE', {relabel=>$entry_label, reidx=> $reidx // 0, code=>$code}]
  }
 },

 {# Empty Action code block
  id => 'EMPTY_ACTION_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/->\s*\w+(?:\[0\])?/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;

   my ($entry_label) = $$info{match} =~ /(\w+)/o; 
   #print "(Empty Action code block) ($entry_label)\n";
   return ['ACODE', {relabel=>$entry_label, reidx=>0, code=>"call($entry_label)"}]
  }
 },


 {# Non-Action code block
  id => 'NON_ACTION_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/\w+\s*\{/o, qr/\}/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;

   my $ipos = pos($$string);
   my ($type) = $$info{match} =~ /(\w+)/o; 
   #print "(Non-Action code block) ($type) Opening\n";

   while (1) {
    my $minfo = LinkedRE::or($string, $$gdata{cbrace});
    return undef unless $minfo;

    if ($$minfo{index} == 1) {
     # Closing brace, recursion stops here
     # print "(Initial/Loop  ($type) code block) (${\(substr($$string, $ipos, pos($$string) - $ipos - 1))}) Closing\n";
     return ["${type}CODE", substr($$string, $ipos, pos($$string) - $ipos - 1)]
    } elsif ($$minfo{index} == 0) {
     # Opening brace found, triggering recursion
     # print "(Curly BRACE) Recursion\n";
     &{$$descr[$bootstrap_rule_index{CURLY_BRACE}]{handler}}($minfo, $descr, $string, $gdata);
     # print "(Curly BRACE) Back From Recursion\n";
    } else {
     #print "QUOTES <$$minfo{match}>\n"
    }
   }
  }
 },

 {# Comment
  id => 'COMMENT',
  tags => { start_token => 1 },
  #re=> [qr/(?:\r\n?)?[ \t]*#.*/o],
  re=> [qr/[ \t]*#.*/o],
  handler=> sub {return ['COMMENT']}
 },

 {# Blind call code block
  id => 'BLIND_CALL_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/=>\s*\w+\s*\{/o, qr/\}/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;

   my $ipos = pos($$string);
   my ($call) = $$info{match} =~ /(\w+)/o; 

   #print "(Blind call code block)($$info{match})($call, $reidx)\n";
   while (1) {
    my $minfo = LinkedRE::or($string, $$gdata{cbrace});
    return undef unless $minfo;

    if ($$minfo{index} == 1) {
     # Closing brace, recursion stops here
     #print "(Action code block) (${\(substr($$string, $ipos, pos($$string) - $ipos - 1))}) Closing\n";
     return ['BCODE', {call=>$call, code=>"\$$gdata->{_current_entry} = call($call);\n".substr($$string, $ipos, pos($$string) - $ipos - 1)}]
    } elsif ($$minfo{index} == 0) {
     # Opening brace found, triggering recursion
     # print "(Curly BRACE) Recursion\n";
     &{$$descr[$bootstrap_rule_index{CURLY_BRACE}]{handler}}($minfo, $descr, $string, $gdata);
     # print "(Curly BRACE) Back From Recursion\n";
    } else {
     #print "QUOTES <$$minfo{match}>\n"
    }
   }
  }
 },

 {# Split-Like Code
  id => 'SPLIT_LIKE_CODE',
  tags => { start_token => 1 },
  re=> [qr/@\s*move_pos\b/o],
  handler=> sub {
   # say '(Split-Like Code)';
   return ['MOVE_POS']
  }
 },


 {# Empty Blind code block
  id => 'EMPTY_BLIND_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/=>\s*\w+/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;

   my ($call) = $$info{match} =~ /(\w+)/o; 
   #print "(Empty Action code block) ($entry_label)\n";
   return ['BCODE', {call=>$call, code=>"\$$gdata->{_current_entry} = call($call)"}]
  }
 },


 {# Method-like Empty Non-Action code block
  id => 'METHOD_EMPTY_NON_ACTION_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/(?<TYPE>\w+)(?<CHAIN>(?:\s*\.\s*\w+(?<PAREN>\s*\((?:[^\(\)]++|(?&PAREN))*\))?)+)/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;
   my ($type, $chain) = @{$$info{match_hash}}{qw/TYPE CHAIN/};
   my $code = _render_method_call_chain($gdata->{_current_entry}, $chain);
   return undef unless defined $code;
   return ["${type}CODE", $code]
  }
 },


 {# Curly Brace			-7- + dquotes + squotes
  id => 'CURLY_BRACE',
  tags => { start_token => 1, brace_scanner => 1 },
  #re=> [qr/(?<!\\)\{/o, qr/(?<!\\)\}/o],
  re=> [qr/(?<!\\)\{/o, qr/(?<!\\)\}/o, qr/(?<!\\)".*?(?<!\\)"/o, qr/(?<!\\)'.*?(?<!\\)'/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;

   my $ipos = pos($$string);
   #print "(Curly BRACE) Opening\n";

   while (1) {
    my $minfo = LinkedRE::or($string, $$gdata{cbrace});
    return undef unless $minfo;

    if ($$minfo{index} == 1) {
     # Closing brace, recursion stops here
     #print "(Curly BRACE) Closing <".substr($$string, $ipos, pos($$string) - $ipos - 1).">\n";
     return 1
    } elsif ($$minfo{index} == 0)  {
     # Opening brace found, triggering recursion
     #print "(Curly BRACE) Recursion\n";
     &{$$descr[$bootstrap_rule_index{CURLY_BRACE}]{handler}}($minfo, $descr, $string, $gdata);
     # print "(Curly BRACE) Back From Recursion\n";
    } else {
     #print "QUOTES <$$minfo{match}>\n"
    }
   }
  }
 }
 ];

 my ($bootstrap_rule_index_ref, $gdata) = _build_bootstrap_registry_gdata($spec_descr);
 %bootstrap_rule_index = %$bootstrap_rule_index_ref;

 return ($spec_descr, $bootstrap_rule_index_ref, $gdata)
}

1;
