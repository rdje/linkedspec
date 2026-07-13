Top::
 /x/ -> Done { set(value, "payload"); set(key, "stage"); items += [value]; meta[key] = { key : value }; return(array(copy(items), copy(meta))) }

Done::
 /[a-z]+/
