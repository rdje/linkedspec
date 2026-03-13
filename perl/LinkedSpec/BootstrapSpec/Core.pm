package LinkedSpec::BootstrapSpec::Core;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname(File::Basename::dirname($module_dir));
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub _require_pkg {
 my ($pkg) = @_;
 my $file = $pkg;
 $file =~ s{::}{/}go;
 $file .= '.pm';
 my $ok = eval { require $file; 1 };
 die "(LinkedSpec::BootstrapSpec::Core::_require_pkg) -E- unable to load '$pkg': $@" unless $ok;
 return 1
}

sub _require_linkedre_pkg {
 _require_pkg('LinkedRE');
 return 1
}

sub _call_preserving_err {
 my ($cb) = @_;
 my $saved_err = $@;
 my $wantarray = wantarray;
 if ($wantarray) {
  my @ret = $cb->();
  $@ = $saved_err;
  return @ret
 }
 if (defined $wantarray) {
  my $ret = $cb->();
  $@ = $saved_err;
  return $ret
 }
 $cb->();
 $@ = $saved_err;
 return
}

sub _linkedre_or {
 my (@args) = @_;
 return _call_preserving_err(sub {
  _require_linkedre_pkg();
  return LinkedRE::or(@args)
 })
}

sub _linkedre_ored_re {
 my (@args) = @_;
 return _call_preserving_err(sub {
  _require_linkedre_pkg();
  return LinkedRE::oredRE(@args)
 })
}

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
 while ($chain =~ /\G\s*\.\s*(?<method>\w+)(?<args>\s*(?<PAREN>\((?:[^\(\)\"']++|\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|(?&PAREN))*\)))?/gc) {
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
 return $trimmed =~ /^(?:\[|\{|\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|-?\d+(?:\.\d+)?|scalar\s*\(|array\s*\(|hash\s*\(|flat_array\s*\(|flat_hash\s*\(|flatten\s*\(|flat\s*\()/o ? 1 : 0
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

sub _build_bootstrap_node_type_map {
 return {
  '&' => 'AND',
  '|' => 'OR',
  '+' => 'REP_PLUS',
  '*' => 'REP_STAR',
  '?' => 'REP_OPT'
 }
}

sub _dispatch_curly_brace_handler {
 my ($ctx, $minfo, $descr, $string, $gdata) = @_;
 my $brace_rule_idx = $ctx->{bootstrap_rule_index}{CURLY_BRACE};
 return undef unless defined $brace_rule_idx;
 return undef unless ref($descr->[$brace_rule_idx]) eq 'HASH';
 return undef unless ref($descr->[$brace_rule_idx]{handler}) eq 'CODE';
 return &{$descr->[$brace_rule_idx]{handler}}($minfo, $descr, $string, $gdata)
}

sub _build_spec_root_rule {
 my ($ctx) = @_;
 return {
  id => 'SPEC_ROOT',
  tags => { root => 1 },
  handler => sub {
   my ($descr, $string, $gdata) = @_;
   my @specentry;
   my @specs;
   while (1) {
    my $minfo = _linkedre_or($string, $$gdata{startREs});
    unless($minfo) {
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
       push @specs, [@specentry];
       @specentry = $retv
      } else {
       push @specentry, $retv;
      }
     } else {
      push @specentry, $retv;
     }
    }

   }
  },
 }
}

sub _build_entry_label_rule {
 my ($ctx) = @_;
 return {
  id => 'ENTRY_LABEL',
  tags => { start_token => 1 },
  re=> [qr/\w+\s*::?(?:&|\||\+|\*|\?)?/o],
  handler=> sub {
   my ($info, undef, undef, $gdata) = @_;
   $$info{match} =~ s/\s*://o;

   my $target = $$info{match} =~ /:/ ? '_INITIAL' : '';
   $$info{match} =~ s/://o;

   $$info{match} =~ s/(\W)//o;
   $gdata->{_current_entry} = $$info{match};
   return ["ELABEL$target", $$info{match}, $1 ? $ctx->{node_type}{$1} : "default"]
  },
 }
}

sub _build_re_pattern_rule {
 return {
  id => 'RE_PATTERN',
  tags => { start_token => 1 },
  re=> [qr/(?<!\\)\/.+?(?<!\\)\//o],
  handler=> sub {
   my ($info) = @_;
   $$info{match} =~ s/^\/|\/$//g;
   return ['RE', $$info{match}]
  },
 }
}

sub _build_action_code_block_rule {
 my ($ctx) = @_;
 return {
  id => 'ACTION_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/->\s*\w+(?:\[\d+\])?\s*\{/o, qr/\}/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;

   my $ipos = pos($$string);
   my ($entry_label, $reidx) = $$info{match} =~ /(\w+)(?:\[(\d+)\])?/o;
   $reidx = $reidx || 0;

   while (1) {
    my $minfo = _linkedre_or($string, $$gdata{cbrace});
    return undef unless $minfo;

    if ($$minfo{index} == 1) {
     return ['ACODE', {relabel=>$entry_label, reidx=>$reidx, code=>substr($$string, $ipos, pos($$string) - $ipos - 1)}]
    } elsif ($$minfo{index} == 0) {
     _dispatch_curly_brace_handler($ctx, $minfo, $descr, $string, $gdata);
    } else {
    }
   }
  },
 }
}

sub _build_method_empty_action_code_block_rule {
 return {
  id => 'METHOD_EMPTY_ACTION_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/->\s*(?<ENTRY_LABEL>\w+)\s*(?:\[\s*(?<INDEX>\d+)\s*\]\s*)?(?<CHAIN>(?:\s*\.\s*\w+(?<PAREN>\s*\((?:[^\(\)\"']++|\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|(?&PAREN))*\))?)+)/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;
   my ($entry_label, $reidx, $chain) = @{$$info{match_hash}}{qw/ENTRY_LABEL INDEX CHAIN/};
   my $code = _render_method_call_chain($entry_label, $chain);
   return undef unless defined $code;
   return ['ACODE', {relabel=>$entry_label, reidx=> $reidx // 0, code=>$code}]
  },
 }
}

sub _build_empty_action_code_block_rule {
 return {
  id => 'EMPTY_ACTION_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/->\s*\w+(?:\[0\])?/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;

   my ($entry_label) = $$info{match} =~ /(\w+)/o;
   return ['ACODE', {relabel=>$entry_label, reidx=>0, code=>"call($entry_label)"}]
  },
 }
}

sub _build_non_action_code_block_rule {
 my ($ctx) = @_;
 return {
  id => 'NON_ACTION_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/\w+\s*\{/o, qr/\}/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;

   my $ipos = pos($$string);
   my ($type) = $$info{match} =~ /(\w+)/o;

   while (1) {
    my $minfo = _linkedre_or($string, $$gdata{cbrace});
    return undef unless $minfo;

    if ($$minfo{index} == 1) {
     return ["${type}CODE", substr($$string, $ipos, pos($$string) - $ipos - 1)]
    } elsif ($$minfo{index} == 0) {
     _dispatch_curly_brace_handler($ctx, $minfo, $descr, $string, $gdata);
    } else {
    }
   }
  },
 }
}

sub _build_comment_rule {
 return {
  id => 'COMMENT',
  tags => { start_token => 1 },
  re=> [qr/[ \t]*#.*/o],
  handler=> sub {return ['COMMENT']},
 }
}

sub _build_blind_call_code_block_rule {
 my ($ctx) = @_;
 return {
  id => 'BLIND_CALL_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/=>\s*\w+\s*\{/o, qr/\}/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;

   my $ipos = pos($$string);
   my ($call) = $$info{match} =~ /(\w+)/o;

   while (1) {
    my $minfo = _linkedre_or($string, $$gdata{cbrace});
    return undef unless $minfo;

    if ($$minfo{index} == 1) {
     return ['BCODE', {call=>$call, code=>"\$$gdata->{_current_entry} = call($call);\n".substr($$string, $ipos, pos($$string) - $ipos - 1)}]
    } elsif ($$minfo{index} == 0) {
     _dispatch_curly_brace_handler($ctx, $minfo, $descr, $string, $gdata);
    } else {
    }
   }
  },
 }
}

sub _build_split_like_code_rule {
 return {
  id => 'SPLIT_LIKE_CODE',
  tags => { start_token => 1 },
  re=> [qr/@\s*move_pos\b/o],
  handler=> sub {
   return ['MOVE_POS']
  },
 }
}

sub _build_empty_blind_code_block_rule {
 return {
  id => 'EMPTY_BLIND_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/=>\s*\w+/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;

   my ($call) = $$info{match} =~ /(\w+)/o;
   return ['BCODE', {call=>$call, code=>"\$$gdata->{_current_entry} = call($call)"}]
  },
 }
}

sub _build_method_empty_non_action_code_block_rule {
 return {
  id => 'METHOD_EMPTY_NON_ACTION_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/(?<TYPE>\w+)(?<CHAIN>(?:\s*\.\s*\w+(?<PAREN>\s*\((?:[^\(\)\"']++|\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|(?&PAREN))*\))?)+)/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;
   my ($type, $chain) = @{$$info{match_hash}}{qw/TYPE CHAIN/};
   my $code = _render_method_call_chain($gdata->{_current_entry}, $chain);
   return undef unless defined $code;
   return ["${type}CODE", $code]
  },
 }
}

sub _build_curly_brace_rule {
 my ($ctx) = @_;
 return {
  id => 'CURLY_BRACE',
  tags => { start_token => 1, brace_scanner => 1 },
  re=> [qr/(?<!\\)\{/o, qr/(?<!\\)\}/o, qr/(?<!\\)\".*?(?<!\\)\"/o, qr/(?<!\\)'.*?(?<!\\)'/o],
  handler=> sub {
   my ($info, $descr, $string, $gdata) = @_;

   my $ipos = pos($$string);

   while (1) {
    my $minfo = _linkedre_or($string, $$gdata{cbrace});
    return undef unless $minfo;

    if ($$minfo{index} == 1) {
     return 1
    } elsif ($$minfo{index} == 0)  {
     _dispatch_curly_brace_handler($ctx, $minfo, $descr, $string, $gdata);
    } else {
    }
   }
  },
 }
}

sub _build_bootstrap_rule_descriptors {
 my ($ctx) = @_;
 return [
  _build_spec_root_rule($ctx),
  _build_entry_label_rule($ctx),
  _build_re_pattern_rule(),
  _build_action_code_block_rule($ctx),
  _build_method_empty_action_code_block_rule(),
  _build_empty_action_code_block_rule(),
  _build_non_action_code_block_rule($ctx),
  _build_comment_rule(),
  _build_blind_call_code_block_rule($ctx),
  _build_split_like_code_rule(),
  _build_empty_blind_code_block_rule(),
  _build_method_empty_non_action_code_block_rule(),
  _build_curly_brace_rule($ctx),
 ]
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
  startREs       => _linkedre_ored_re(@bootstrap_start_res),
  start_dispatch => \@bootstrap_start_dispatch,
  cbrace         => _linkedre_ored_re(@bootstrap_cbrace_res)
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
 my $ctx = {
  bootstrap_rule_index => {},
  node_type => _build_bootstrap_node_type_map(),
 };

 my $spec_descr = _build_bootstrap_rule_descriptors($ctx);
 my ($bootstrap_rule_index_ref, $gdata) = _build_bootstrap_registry_gdata($spec_descr);
 %{$ctx->{bootstrap_rule_index}} = %$bootstrap_rule_index_ref;

 return ($spec_descr, $bootstrap_rule_index_ref, $gdata)
}

1;
