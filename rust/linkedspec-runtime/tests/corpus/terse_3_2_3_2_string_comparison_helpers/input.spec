Top::
 /x/ -> Done { set(out, ""); if(str_eq("node", "node")) { set(out, cat(out, "E")) }; if(str_ne("node", "edge")) { set(out, cat(out, "N")) }; if(str_gt("2", "10")) { set(out, cat(out, "G")) }; if(str_ge("2", "2")) { set(out, cat(out, "H")) }; if(str_lt("10", "2")) { set(out, cat(out, "L")) }; if(str_le("10", "10")) { set(out, cat(out, "M")) }; if(str_gt("10", "2")) { set(out, cat(out, "X")) }; return(out) }

Done::
 /[a-z]+/
