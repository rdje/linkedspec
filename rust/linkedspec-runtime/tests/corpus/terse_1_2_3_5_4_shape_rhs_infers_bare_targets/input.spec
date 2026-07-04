Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); items = [value]; items += "tail"; meta = { key => value }; meta["fixed"] = "yes"; return(array(copy(array(items)), copy(hash(meta)), :items, :meta)) }

Done::
 /[a-z]+/
