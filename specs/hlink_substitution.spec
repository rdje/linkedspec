substitute_top::   I        {declare(scalar, retv); declare(array, word_items)}
# -> substitute_statement1   {$retv = call(substitute_statement1)}
 -> substitute_statement2   {assign(scalar(retv), call(substitute_statement2))}
 -> curlyb                  {assign(scalar(retv), call(curlyb))}
 -> raw_string              {assign(scalar(retv), call(raw_string))}
# -> substitute_statement1[1] {print "(HLinkSubst) -E- Dangling closing brace\n"; exit 1}
 -> substitute_statement2[1] {print("(HLinkSubst) -E- Dangling closing bracket\n"); exit 1}

 LE {push_value(array(word_items), scalar(retv))}
 LX {
     if(is_nonempty(array(word_items)));
       return(array_values(array(word_items)));
     else();
       return_undef();
     endif()
   }


#substitute_statement1: /#\{/ /\}/ 
# -> substitute_statement1 
# -> substitute_statement2 
# -> curlyb
# -> substitute_statement1[1] {return \substr($$STRING, $IPOS, $LSPOS - $IPOS - 1)}
#
# LX {print "(HLinkSubst) -E- Unmatched closing brace\n"; exit 2}

substitute_statement2: /(?<!\\)\[/ /(?<!\\)\]/ 
 -> substitute_statement2 
# -> substitute_statement1 
 -> curlyb
 -> substitute_statement2[1] {return \(my $capt = substr($$STRING, $IPOS, $LSPOS - $IPOS - 1))}

 LX {print("(HLinkSubst) -E- Unmatched closing bracket\n"); exit 2}

curlyb: /\{/ /\}/
 -> curlyb
 -> curlyb[1]   {return substr($$STRING, $IPOS-1, $LSPOS - $IPOS + 1)}

 LX {print("(HLinkSubst) -E- Unmatched closing brace\n"); exit 2}

raw_string: /(\\(?:\[|\])|[^\{\}\[\]])+/   I {return $IMATCH}
