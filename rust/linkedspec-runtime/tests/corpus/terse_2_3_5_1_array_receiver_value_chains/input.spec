Top::
 /x/ -> Done { items += "b"; items += "a"; items += "c"; items += "a"; phrases += "aa-b"; phrases += "c-aa"; return(array(items.sorted().drop_front(2).first(), array(items).reversed().take(2).last(), items.sorted().index_of("c"), items.drop_back().join_values("|"), items.uniq().join_values(","), items.filter_match(/^a$/).count(), phrases.split_each("-").filter_match(/^aa$/).count())) }

Done::
 /[a-z]+/
