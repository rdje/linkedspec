Top::
 /x/ -> Done { set(value, "outer"); return(array("inner".with() { return(cat(value, "!")) }, value, " x ".with() { return(cat(value, "!")) }.trim(), " a-b ".trim().with() { return(value.split("-")) }.count(), "ok".with() { return({ "stage" : value }) }.count_keys())) }

Done::
 /[a-z]+/
