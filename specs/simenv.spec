top::            I {declare(array, blocks)}

 -> comments
 -> begin_end_blocks          {
	                       my $retv = call(begin_end_blocks);
	                       if(scalar(retv));
	                         push_value(array(blocks), scalar(retv));
	                       endif()
		              }

LX {
     if(is_nonempty(array(blocks)));
       return(array_copy(array(blocks)));
     else();
       return_undef();
     endif()
   }


begin_end_blocks: /\bBEGIN\s+\w+/ /\bEND\s+\w+/  I {declare(scalar, block_namei=entry_text(), retv); declare(array, assigns, keyval_pairs); print("begin_end_blocks: BEGIN   (", entry_text(), "\n"); substr(scalar(block_namei), "^.*\\s+", "", o)}

 -> comments
 -> anyvariable                       {
                                       if(is_nonempty(array(keyval_pairs)));
                                         push_value(array(assigns), array_copy(array(keyval_pairs)));
                                       endif();
                                       $retv = call(anyvariable);
                                       assign(array(keyval_pairs), array(scalar(retv)))
                                      }

 -> multiline_value                   {push @keyval_pairs, call(multiline_value)}
 -> singleline_value                  {push @keyval_pairs, call(singleline_value)}
 -> begin_end_blocks[1]               {
                                       declare(scalar, block_namee=match_text());
                                       substr(scalar(block_namee), "^.*\\s+", "", o);

                                       if(ne(scalar(block_namee), scalar(block_namei)));
                                         print("(simenv) -E- BEGIN Block Name '", scalar(block_namei), "' and END Block name '", scalar(block_namee), "' do not match.\n");
                                         print("             BEGIN statement is on line ", cursor_line(), " while END statement is on line ", match_line(), "\n");
                                         exit;
                                       endif();

                                       if(is_nonempty(array(keyval_pairs)));
                                         push_value(array(assigns), array_copy(array(keyval_pairs)));
                                       endif();
                                       print("begin_end_blocks: END    (", match_text(), "\n");
                                       if(is_nonempty(array(assigns)));
                                         return({name=>scalar(block_namei), content=>array_copy(array(assigns))});
                                       else();
                                         return_undef();
                                       endif()
			              }

 LX {print("(simenv) -E- END Block statement not found for *begin_end_blocks* starting on line ", cursor_line(), "\n");
     exit}

      
anyvariable: /\S+\s*(?==)/ I {
	                                       declare(scalar, variable_name=entry_text());
	                                       substr(scalar(variable_name), /\s+$/, "", o);
	                                       print("anyvariable: VARIABLE NAME (", scalar(variable_name), ")\n");
	                                       return({type=>'anyvariable', content=>scalar(variable_name)})
			                      }

multiline_value: /=\s*\{/    /\}/ I {print("multiline_value: START\n")}
 -> curlybrace
 -> multiline_value[1]	     {
	                      print("multiline_value: CLOSING curly brace\n"); 
			      print("<", capture_slice(), ">\n");
			      return {type=>'multiline_value', content=>capture_slice()}
		             }

 LX {print("(simenv) -E- Closing parenthesis not found for *multiline_value* starting on line ", capture_slice_line(), "\n");
     exit}


singleline_value:    /=/ /(?<!\\)\n|\b(?=END\s+\w+)/ I {my $last_pos=$IPOS; my @matches} 
 -> perl_command_substitution          {push @matches, call(perl_command_substitution);   $last_pos = pos($$STRING)}
 -> command_substitution               {push @matches, call(command_substitution);        $last_pos = pos($$STRING)}
 -> bvariable_substitution             {push @matches, call(bvariable_substitution);      $last_pos = pos($$STRING)}
 -> variable_substitution              {push @matches, call(variable_substitution);       $last_pos = pos($$STRING)}
 -> squotes                            {push @matches, call(squotes);                     $last_pos = pos($$STRING)}
 -> dquotes                            {push @matches, call(dquotes);                     $last_pos = pos($$STRING)}
 -> perl_squotes                       {push @matches, call(perl_squotes);                $last_pos = pos($$STRING)}
 -> perl_dquotes                       {push @matches, call(perl_dquotes);                $last_pos = pos($$STRING)}
 -> bs_nl                              {push @matches, call(bs_nl);                       $last_pos = pos($$STRING)}
 -> singleline_value[1]     {print("singleline_value: END\n");  print("<", capture_slice(), ">\n");
	 print "singleline_value:<<$_>>\n" foreach (@matches);
	 return {type=>'singleline_value', content=> @matches ? \@matches : undef}
   }

 LS {my $shift = $LSPOS - $last_pos - length($LMATCH); push @matches, {type=>'verbatim', content=>substr($$STRING, $last_pos, $shift)} if $shift}
 LX {print("(simenv) -E- End of Line not found for *singleline_value* starting on line ", capture_slice_line(), "\n");
     exit}


bs_nl: /\\\n\s*/                            I {print("bs_nl: SEEN\n"); return "**BS_NL**"}
squotes: /'/ /(?<!\\)'/                     I {print("squotes: START\n")}
 -> squotes[1]                                {
	                                       print("squotes: END\n");  
					       print("<", capture_slice(), ">\n");
					       return {type=>'squotes', content=>capture_slice()}
				              }

 LX {print("(simenv) -E- Closing tick not found for *$squotes* starting on line ", capture_slice_line(), "\n");
     exit}

dquotes: /"/ /(?<!\\)"/                     I {print("dquotes: START\n"); my @matches; my $last_pos=$IPOS}
 -> bvariable_substitution                    {push @matches, call(bvariable_substitution);   $last_pos = pos($$STRING)}
 -> variable_substitution                     {push @matches, call(bvariable_substitution);   $last_pos = pos($$STRING)}
 -> dquotes[1]                                {print("dquotes: END\n");  print("<", capture_slice(), ">\n");
	 print "perl_dquotes:<<$_>>\n" foreach (@matches);
         return {type=>'dquotes', content=> @matches ? \@matches : undef}}

 LS {my $shift = $LSPOS - $last_pos - length($LMATCH); push @matches, substr($$STRING, $last_pos, $shift) if $shift}
 LX {print("(simenv) -E- Closing parenthesis not found for *dquotes* starting on line ", capture_slice_line(), "\n");
     exit}


perl_squotes: /q\(/  /\)/                   I {print("perl_squotes: START\n")}
 -> parenthesis
 -> perl_squotes[1]                           {
	                                       print("perl_squotes: END\n"); 
					       print("<", capture_slice(), ">\n");
					       return {type=>'squotes', content=>capture_slice()}
				              }

 LX {print("(simenv) -E- Closing Parenthesis not found for *$perl_squotes* starting on line ", capture_slice_line(), "\n");
     exit}

perl_dquotes: /qq\(/  /\)/                  I {print("perl_dquotes: START\n"); my @matches; my $last_pos=$IPOS}
 -> parenthesis
 -> bvariable_substitution                    {push @matches, call(bvariable_substitution);   $last_pos = pos($$STRING)}
 -> variable_substitution                     {push @matches, call(bvariable_substitution);   $last_pos = pos($$STRING)}
 -> perl_dquotes[1]                           {print("perl_dquotes: END\n"); print("<", capture_slice(), ">\n");
	 print "perl_dquotes:<<$_>>\n" foreach (@matches);
         return {type=>'dquotes', content=> @matches ? \@matches : undef}}

 LS {my $shift = $LSPOS - $last_pos - length($LMATCH); push @matches, substr($$STRING, $last_pos, $shift) if $shift}
 LX {print("(simenv) -E- Closing parenthesis not found for *perl_dquotes* starting on line ", capture_slice_line(), "\n");
     exit}


command_substitution: /`/  /(?<!\\)`/       I {print("command_substitution: START\n"); my @matches; my $last_pos=$IPOS}
 -> bvariable_substitution                    {push @matches, call(bvariable_substitution);   $last_pos = pos($$STRING)}
 -> variable_substitution                     {push @matches, call(bvariable_substitution);   $last_pos = pos($$STRING)}
 -> command_substitution[1]                   {
	                                       print("command_substitution: END\n"); print("<", capture_slice(), ">\n");
	                                       print "command_substitution:<<$_>>\n" foreach (@matches);
                                               return {type=>'command_substitution', content=> @matches ? \@matches : undef}
				              }

 LS {my $shift = $LSPOS - $last_pos - length($LMATCH); push @matches, substr($$STRING, $last_pos, $shift) if $shift}
 LX {print("(simenv) -E- Unmatched back-tick for *command_substitution* starting on line ", capture_slice_line(), "\n");
     exit}


perl_command_substitution: /qx\(/  /\)/     I {print("perl_command_substitution: START\n"); my @matches; my $last_pos=$IPOS}
 -> bvariable_substitution		      {push @matches, call(bvariable_substitution);   $last_pos = pos($$STRING)}
 -> variable_substitution                     {push @matches, call(variable_substitution);    $last_pos = pos($$STRING)}
 -> perl_command_substitution[1]              {print("perl_command_substitution: END\n"); print("<", capture_slice(), ">\n");
	 print "perl_command_substitution:<<$_>>\n" foreach (@matches);
	 return {type=>'command_substitution', content=> @matches ? \@matches : undef}}

 LS {my $shift = $LSPOS - $last_pos - length($LMATCH); push @matches, substr($$STRING, $last_pos, $shift) if $shift}
 LX {print("(simenv) -E- Closing parenthesis not found for *perl_command_substitution* starting on line ", capture_slice_line(), "\n");
     exit}
 

bvariable_substitution: /(?<!\\)\$\{/ /\}/  I {print("bvariable_substitution: START\n")}
 -> curlybrace
 -> bvariable_substitution[1]                 {
	                                       print("bvariable_substitution: END\n"); 
					       print("<", capture_slice(), ">\n");
					       return {type=>'bvariable_substitution', content=>capture_slice()}
				              }

 LX {print("(simenv) -E- Closing Curly Brace not found for *bvariable_substitution* starting on line ", capture_slice_line(), "\n");
     exit}
 

variable_substitution: /(?<!\\)\$\w+/       I {
	                                       declare(scalar, variable_name=entry_text());
	                                       substr(scalar(variable_name), /^\$/, "", o);
	                                       print("variable_substitution: (", scalar(variable_name), ")\n");
					       return({type=>'variable_substitution', content=>scalar(variable_name)})
				              }

curlybrace: /\{/   /\}/                     I {print("curlybrace: OPENING Brace\n")}
 -> curlybrace
 -> curlybrace[1]                             {print("curlybrace: CLOSING Brace\n");  print("<", capture_slice(), ">\n"); return}

 LX {print("(simenv) -E- Closing Curly Brace not found for *curlybrace* starting on line ", capture_slice_line(), "\n");
     exit}


parenthesis: /\(/   /\)/                    I {print("parenthesis: OPENING Parenthesis\n")}
 -> parenthesis
 -> parenthesis[1]                            {print("parenthesis: CLOSING Parenthesis\n");  print("<", capture_slice(), ">\n"); return}

 LX {print("(simenv) -E- Closing Parenthesis not found for *parenthesis* starting on line ", capture_slice_line(), "\n");
     exit}


comments: /#.*\n/                           I {declare(scalar, comment_text=entry_text()); substr(scalar(comment_text), /\n$/, "", o); print("comments: <", scalar(comment_text), ">\n")}
