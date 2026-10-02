Top::
 -> Word {
   if(num_ne(match_start_pos(), 0)) { exit_now(1) }
   if(num_ne(match_end_pos(), input_end_pos())) { exit_now(1) }
   effects = []
   print({ push(effects, "left"); return("begin:") },
         { push(effects, "right"); return(match_text()) })
   if(str_eq(match_text(), "stop")) { say("stop"); exit_now(7) }
   print_each(["α", undef, [], "🙂"], "part:", "!")
   say("done")
   return({ "word": match_text(), "effects": copy(effects), "payload": false })
 }
LX { exit_now(1) }

Word:
 /([a-z]+)/
