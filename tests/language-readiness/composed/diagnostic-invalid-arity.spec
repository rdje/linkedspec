Top::
 -> Word {
   if(num_ne(match_start_pos(), 0)) { exit_now(1) }
   if(num_ne(match_end_pos(), input_end_pos())) { exit_now(1) }
   print_each(
     { say("arity:items"); return(["x"]) },
     { say("arity:prefix"); return("p:") },
     { say("arity:suffix"); return("!") },
     { say("arity:extra"); return("extra") }
   )
 }
LX { exit_now(1) }

Word:
 /([a-z]+)/
