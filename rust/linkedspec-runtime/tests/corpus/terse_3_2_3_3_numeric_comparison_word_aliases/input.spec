Top::
 /x/ -> Done { set(out, ""); if(eq("2", "2")) { set(out, cat(:out, "E")) }; if(ne("2", "3")) { set(out, cat(:out, "N")) }; if(gt("10", "2")) { set(out, cat(:out, "G")) }; if(ge("2", "2")) { set(out, cat(:out, "H")) }; if(lt("2", "10")) { set(out, cat(:out, "L")) }; if(le("2", "2")) { set(out, cat(:out, "M")) }; if(gt("2", "10")) { set(out, cat(:out, "X")) }; if(str_gt("2", "10")) { set(out, cat(:out, "S")) }; return(out) }

Done::
 /[a-z]+/
