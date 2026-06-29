Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); items = [value]; items += "tail"; meta = { key => value }; meta["fixed"] = "yes"; return(array(array_copy(array(items)), hash_copy(hash(meta)), scalar(items), scalar(meta))) }

Done::
 /[a-z]+/
