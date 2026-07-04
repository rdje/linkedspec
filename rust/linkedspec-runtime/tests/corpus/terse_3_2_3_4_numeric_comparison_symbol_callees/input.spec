Top::
 /x/ -> Done { set(out, ""); if(==("2", "2")) { set(out, cat(:out, "E")) }; if(!=("2", "3")) { set(out, cat(:out, "N")) }; if(>("10", "2")) { set(out, cat(:out, "G")) }; if(>=("2", "2")) { set(out, cat(:out, "H")) }; if(<("2", "10")) { set(out, cat(:out, "L")) }; if(<=("2", "2")) { set(out, cat(:out, "M")) }; if(>("2", "10")) { set(out, cat(:out, "X")) }; if(str_gt("2", "10")) { set(out, cat(:out, "S")) }; return(out) }

Done::
 /[a-z]+/
