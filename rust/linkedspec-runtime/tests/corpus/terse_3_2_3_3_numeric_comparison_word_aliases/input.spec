Top::
 /x/ -> Done { set(out, ""); if(eq("2", "2")) { set(out, cat(scalar(out), "E")) }; if(ne("2", "3")) { set(out, cat(scalar(out), "N")) }; if(gt("10", "2")) { set(out, cat(scalar(out), "G")) }; if(ge("2", "2")) { set(out, cat(scalar(out), "H")) }; if(lt("2", "10")) { set(out, cat(scalar(out), "L")) }; if(le("2", "2")) { set(out, cat(scalar(out), "M")) }; if(gt("2", "10")) { set(out, cat(scalar(out), "X")) }; if(str_gt("2", "10")) { set(out, cat(scalar(out), "S")) }; return(out) }

Done::
 /[a-z]+/
