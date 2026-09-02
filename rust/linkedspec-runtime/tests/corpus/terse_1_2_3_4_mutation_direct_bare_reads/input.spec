Top::
 -> Done { set(value, "payload"); set(key, "stage"); set(idx, 1); set(foo, hash("a", array("zero", "one"))); items += value; set_key(meta, key, value); meta[key] = value; return(array(copy(items), copy(meta), foo["a"][idx])) }

Done::
 /[a-z]+/
