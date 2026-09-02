Top::
 -> Done { return(array({ set(x, "a"); x }, { set(y, "b"); return(y) }, { set(key, "stage"); set(value, "ok"); { key : value } })) }

Done::
 /[a-z]+/
