Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); return(array(items += value, copy(items), meta[key] = value, copy(hash(meta)), (items += "x").count(), (meta["last"] = value).count_keys())) }

Done::
 /[a-z]+/
