Top::
 /x/ -> Done { set(out, ""); if(==("2", "2")) { set(out, cat(scalar(out), "E")) }; if(!=("2", "3")) { set(out, cat(scalar(out), "N")) }; if(>("10", "2")) { set(out, cat(scalar(out), "G")) }; if(>=("2", "2")) { set(out, cat(scalar(out), "H")) }; if(<("2", "10")) { set(out, cat(scalar(out), "L")) }; if(<=("2", "2")) { set(out, cat(scalar(out), "M")) }; if(>("2", "10")) { set(out, cat(scalar(out), "X")) }; if(str_gt("2", "10")) { set(out, cat(scalar(out), "S")) }; return(out) }

Done::
 /[a-z]+/
