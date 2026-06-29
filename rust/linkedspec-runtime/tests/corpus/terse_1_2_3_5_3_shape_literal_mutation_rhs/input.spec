Top::
 /x/ -> Done { set(value, "payload"); set(key, "stage"); items += [value]; meta[key] = { key => value }; return(array(array_copy(array(items)), hash_copy(hash(meta)))) }

Done::
 /[a-z]+/
