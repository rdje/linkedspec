Top::
 /x/ -> Done { set(value, "payload"); set(key, "stage"); items += [value]; meta[key] = { key : value }; return(array(copy(array(items)), copy(hash(meta)))) }

Done::
 /[a-z]+/
