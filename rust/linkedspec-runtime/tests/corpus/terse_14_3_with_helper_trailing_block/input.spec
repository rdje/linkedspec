Top::
 /x/ -> Done { set(value, "outer"); return(array(with("inner") { return(cat(value, "!")) }, value, with() { return(if(is_undefined(value), "undef", else("bad"))) }, with("ok") { return({ "stage" : value }) })) }

Done::
 /[a-z]+/
