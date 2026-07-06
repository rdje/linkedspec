top::            I {blocks = []; retv = undef}

 -> comments
 -> begin_end_blocks          {
	                       retv = call(begin_end_blocks);
	                       if(retv);
	                         push(array(blocks), retv);
	                       endif()
		              }

LX {
     if(is_nonempty(array(blocks)));
       return(copy(array(blocks)));
     else();
       return_undef();
     endif()
   }


begin_end_blocks: /\bBEGIN\s+\w+/ /\bEND\s+\w+/  I {block_namei = entry_text(); retv = undef; assigns = []; keyval_pairs = []; print("begin_end_blocks: BEGIN   (", entry_text(), "\n"); substr(block_namei, /^.*\s+/, "", o)}

 -> comments
 -> anyvariable                       {
                                       if(is_nonempty(array(keyval_pairs)));
                                         push(array(assigns), copy(array(keyval_pairs)));
                                       endif();
	                                       retv = call(anyvariable);
                                       set(array(keyval_pairs), [retv])
                                      }

 -> multiline_value                   {push(array(keyval_pairs), call(multiline_value))}
 -> singleline_value                  {push(array(keyval_pairs), call(singleline_value))}
 -> begin_end_blocks[1]               {
                                       block_namee = match_text();
	                                       substr(block_namee, /^.*\s+/, "", o);

                                       if(str_ne(block_namee, block_namei));
                                         print("(simenv) -E- BEGIN Block Name '", block_namei, "' and END Block name '", block_namee, "' do not match.\n");
                                         print("             BEGIN statement is on line ", cursor_line(), " while END statement is on line ", match_line(), "\n");
	                                         exit_now();
                                       endif();

                                       if(is_nonempty(array(keyval_pairs)));
                                         push(array(assigns), copy(array(keyval_pairs)));
                                       endif();
                                       print("begin_end_blocks: END    (", match_text(), "\n");
                                       if(is_nonempty(array(assigns)));
	                                         return(hash("name", block_namei, "content", copy(array(assigns))));
                                       else();
                                         return_undef();
                                       endif()
			              }

 LX {print("(simenv) -E- END Block statement not found for *begin_end_blocks* starting on line ", cursor_line(), "\n");
     exit_now()}

      
anyvariable: /\S+\s*(?==)/ I {
	                                       variable_name = entry_text();
	                                       substr(variable_name, /\s+$/, "", o);
	                                       print("anyvariable: VARIABLE NAME (", variable_name, ")\n");
		                                       return(hash("type", "anyvariable", "content", variable_name))
			                      }

multiline_value: /=\s*\{/    /\}/ I {print("multiline_value: START\n")}
 -> curlybrace
 -> multiline_value[1]	     {
	                      print("multiline_value: CLOSING curly brace\n"); 
			      print("<", capture_slice(), ">\n");
			      return(hash("type", "multiline_value", "content", capture_slice()))
		             }

 LX {print("(simenv) -E- Closing parenthesis not found for *multiline_value* starting on line ", capture_slice_line(), "\n");
     exit_now()}


singleline_value:    /=/ /(?<!\\)\n|\b(?=END\s+\w+)/ I {matches = []; last_pos = capture_slice_pos(); shift = undef}
 -> perl_command_substitution          {push(array(matches), call(perl_command_substitution));   last_pos = cursor_pos()}
 -> command_substitution               {push(array(matches), call(command_substitution));        last_pos = cursor_pos()}
 -> bvariable_substitution             {push(array(matches), call(bvariable_substitution));      last_pos = cursor_pos()}
 -> variable_substitution              {push(array(matches), call(variable_substitution));       last_pos = cursor_pos()}
 -> squotes                            {push(array(matches), call(squotes));                     last_pos = cursor_pos()}
 -> dquotes                            {push(array(matches), call(dquotes));                     last_pos = cursor_pos()}
 -> perl_squotes                       {push(array(matches), call(perl_squotes));                last_pos = cursor_pos()}
 -> perl_dquotes                       {push(array(matches), call(perl_dquotes));                last_pos = cursor_pos()}
 -> bs_nl                              {push(array(matches), call(bs_nl));                       last_pos = cursor_pos()}
 -> singleline_value[1]     {print("singleline_value: END\n");  print("<", capture_slice(), ">\n");
	 print_each(array(matches), "singleline_value:<<", ">>\n");
	 if(is_nonempty(array(matches)));
	   return(hash("type", "singleline_value", "content", copy(array(matches))));
	 else();
	   return(hash("type", "singleline_value", "content", undef));
	 endif()
   }

 LS {shift = num_sub(match_start_pos(), last_pos); if(num_gt(shift, 0)); push(array(matches), hash("type", "verbatim", "content", input_slice(last_pos, shift))); endif()}
 LX {print("(simenv) -E- End of Line not found for *singleline_value* starting on line ", capture_slice_line(), "\n");
     exit_now()}


bs_nl: /\\\n\s*/                            I {print("bs_nl: SEEN\n"); return("**BS_NL**")}
squotes: /'/ /(?<!\\)'/                     I {print("squotes: START\n")}
 -> squotes[1]                                {
	                                       print("squotes: END\n");  
					       print("<", capture_slice(), ">\n");
					       return(hash("type", "squotes", "content", capture_slice()))
				              }

 LX {print("(simenv) -E- Closing tick not found for *$squotes* starting on line ", capture_slice_line(), "\n");
     exit_now()}

dquotes: /"/ /(?<!\\)"/                     I {print("dquotes: START\n"); matches = []; last_pos = capture_slice_pos(); shift = undef}
 -> bvariable_substitution                    {push(array(matches), call(bvariable_substitution));   last_pos = cursor_pos()}
 -> variable_substitution                     {push(array(matches), call(bvariable_substitution));   last_pos = cursor_pos()}
 -> dquotes[1]                                {print("dquotes: END\n");  print("<", capture_slice(), ">\n");
	 print_each(array(matches), "perl_dquotes:<<", ">>\n");
         if(is_nonempty(array(matches)));
           return(hash("type", "dquotes", "content", copy(array(matches))));
         else();
           return(hash("type", "dquotes", "content", undef));
         endif()}

 LS {shift = num_sub(match_start_pos(), last_pos); if(num_gt(shift, 0)); push(array(matches), input_slice(last_pos, shift)); endif()}
 LX {print("(simenv) -E- Closing parenthesis not found for *dquotes* starting on line ", capture_slice_line(), "\n");
     exit_now()}


perl_squotes: /q\(/  /\)/                   I {print("perl_squotes: START\n")}
 -> parenthesis
 -> perl_squotes[1]                           {
	                                       print("perl_squotes: END\n"); 
					       print("<", capture_slice(), ">\n");
					       return(hash("type", "squotes", "content", capture_slice()))
				              }

 LX {print("(simenv) -E- Closing Parenthesis not found for *$perl_squotes* starting on line ", capture_slice_line(), "\n");
     exit_now()}

perl_dquotes: /qq\(/  /\)/                  I {print("perl_dquotes: START\n"); matches = []; last_pos = capture_slice_pos(); shift = undef}
 -> parenthesis
 -> bvariable_substitution                    {push(array(matches), call(bvariable_substitution));   last_pos = cursor_pos()}
 -> variable_substitution                     {push(array(matches), call(bvariable_substitution));   last_pos = cursor_pos()}
 -> perl_dquotes[1]                           {print("perl_dquotes: END\n"); print("<", capture_slice(), ">\n");
	 print_each(array(matches), "perl_dquotes:<<", ">>\n");
         if(is_nonempty(array(matches)));
           return(hash("type", "dquotes", "content", copy(array(matches))));
         else();
           return(hash("type", "dquotes", "content", undef));
         endif()}

 LS {shift = num_sub(match_start_pos(), last_pos); if(num_gt(shift, 0)); push(array(matches), input_slice(last_pos, shift)); endif()}
 LX {print("(simenv) -E- Closing parenthesis not found for *perl_dquotes* starting on line ", capture_slice_line(), "\n");
     exit_now()}


command_substitution: /`/  /(?<!\\)`/       I {print("command_substitution: START\n"); matches = []; last_pos = capture_slice_pos(); shift = undef}
 -> bvariable_substitution                    {push(array(matches), call(bvariable_substitution));   last_pos = cursor_pos()}
 -> variable_substitution                     {push(array(matches), call(bvariable_substitution));   last_pos = cursor_pos()}
 -> command_substitution[1]                   {
	                                       print("command_substitution: END\n"); print("<", capture_slice(), ">\n");
	                                       print_each(array(matches), "command_substitution:<<", ">>\n");
                                               if(is_nonempty(array(matches)));
                                                 return(hash("type", "command_substitution", "content", copy(array(matches))));
                                               else();
                                                 return(hash("type", "command_substitution", "content", undef));
                                               endif()
				              }

 LS {shift = num_sub(match_start_pos(), last_pos); if(num_gt(shift, 0)); push(array(matches), input_slice(last_pos, shift)); endif()}
 LX {print("(simenv) -E- Unmatched back-tick for *command_substitution* starting on line ", capture_slice_line(), "\n");
     exit_now()}


perl_command_substitution: /qx\(/  /\)/     I {print("perl_command_substitution: START\n"); matches = []; last_pos = capture_slice_pos(); shift = undef}
 -> bvariable_substitution		      {push(array(matches), call(bvariable_substitution));   last_pos = cursor_pos()}
 -> variable_substitution                     {push(array(matches), call(variable_substitution));    last_pos = cursor_pos()}
 -> perl_command_substitution[1]              {print("perl_command_substitution: END\n"); print("<", capture_slice(), ">\n");
	 print_each(array(matches), "perl_command_substitution:<<", ">>\n");
	 if(is_nonempty(array(matches)));
	   return(hash("type", "command_substitution", "content", copy(array(matches))));
	 else();
	   return(hash("type", "command_substitution", "content", undef));
	 endif()}

 LS {shift = num_sub(match_start_pos(), last_pos); if(num_gt(shift, 0)); push(array(matches), input_slice(last_pos, shift)); endif()}
 LX {print("(simenv) -E- Closing parenthesis not found for *perl_command_substitution* starting on line ", capture_slice_line(), "\n");
     exit_now()}
 

bvariable_substitution: /(?<!\\)\$\{/ /\}/  I {print("bvariable_substitution: START\n")}
 -> curlybrace
 -> bvariable_substitution[1]                 {
	                                       print("bvariable_substitution: END\n"); 
					       print("<", capture_slice(), ">\n");
					       return(hash("type", "bvariable_substitution", "content", capture_slice()))
				              }

 LX {print("(simenv) -E- Closing Curly Brace not found for *bvariable_substitution* starting on line ", capture_slice_line(), "\n");
     exit_now()}
 

variable_substitution: /(?<!\\)\$\w+/       I {
	                                       variable_name = entry_text();
	                                       substr(variable_name, /^\$/, "", o);
	                                       print("variable_substitution: (", variable_name, ")\n");
					       return(hash("type", "variable_substitution", "content", variable_name))
				              }

curlybrace: /\{/   /\}/                     I {print("curlybrace: OPENING Brace\n")}
 -> curlybrace
 -> curlybrace[1]                             {print("curlybrace: CLOSING Brace\n");  print("<", capture_slice(), ">\n"); return_undef()}

 LX {print("(simenv) -E- Closing Curly Brace not found for *curlybrace* starting on line ", capture_slice_line(), "\n");
     exit_now()}


parenthesis: /\(/   /\)/                    I {print("parenthesis: OPENING Parenthesis\n")}
 -> parenthesis
 -> parenthesis[1]                            {print("parenthesis: CLOSING Parenthesis\n");  print("<", capture_slice(), ">\n"); return_undef()}

 LX {print("(simenv) -E- Closing Parenthesis not found for *parenthesis* starting on line ", capture_slice_line(), "\n");
     exit_now()}


comments: /#.*\n/                           I {comment_text = entry_text(); substr(comment_text, /\n$/, "", o); print("comments: <", comment_text, ">\n")}
