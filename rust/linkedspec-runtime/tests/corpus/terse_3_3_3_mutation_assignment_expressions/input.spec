Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); return(array(items += value, array_copy(items), meta[key] = value, hash_copy(meta), (items += "x").count(), (meta["last"] = value).count_keys())) }

Done::
 /[a-z]+/
