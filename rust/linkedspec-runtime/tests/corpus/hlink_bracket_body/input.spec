substitute_top::   I        {retv = undef; word_items = []}
 -> substitute_statement2   {retv = call(substitute_statement2)}
 -> curlyb                  {retv = call(curlyb)}
 -> raw_string              {retv = call(raw_string)}
 -> substitute_statement2[1] {print("(HLinkSubst) -E- Dangling closing bracket\n"); exit_now(1)}

 LE {push(word_items, retv)}
 LX {
     if(is_nonempty(word_items));
       return(copy(word_items));
     else();
       return_undef();
     endif()
   }

substitute_statement2: /(?<!\\)\[/ /(?<!\\)\]/ 
 -> substitute_statement2 
 -> curlyb
 -> substitute_statement2[1] {return(capture_slice())}

 LX {print("(HLinkSubst) -E- Unmatched closing bracket\n"); exit_now(2)}

curlyb: /\{/ /\}/
 -> curlyb
 -> curlyb[1]   {return(cat("{", capture_slice(), "}"))}

 LX {print("(HLinkSubst) -E- Unmatched closing brace\n"); exit_now(2)}

raw_string: /(\\(?:\[|\])|[^\{\}\[\]])+/   I.return(entry_text())
