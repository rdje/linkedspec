fn decorate(text, prefix) { return(cat(prefix, uppercase(text))) }

Top::
 -> Word {
   if(num_ne(match_start_pos(), 0)) { exit_now(1) }
   if(num_ne(match_end_pos(), input_end_pos())) { exit_now(1) }
   pieces = split(match_text(), "-")
   original = { "a": pieces[0], "b": { "c": pieces[1] } }
   tree = copy(original)
   seen = []
   prefix = "old:"
   text = "outside"
   transform = {|text| push(seen, text); return(decorate(text, prefix)) }
   prefix = "new:"
   result = tree.map_leaves!() { return(transform(value)) }
   i = 0
   visited = 0
   while(num_lt(i,count(pieces))) { visited = num_add(visited,1); i = num_add(i,1) }
   tree["meta"]["count"] = visited
   print_each(seen, "leaf:", "!")
   say("done:", visited)
   return({ "tree": copy(tree), "mapped": result, "original": original,
            "seen": seen, "text": text, "visits": visited })
 }
LX { exit_now(1) }

Word:
 /([A-Za-z]+-[A-Za-z]+)/
