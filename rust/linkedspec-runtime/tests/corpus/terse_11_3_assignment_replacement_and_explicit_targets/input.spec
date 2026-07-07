Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); thing = "text"; first = thing; thing = [value]; second = array(thing); thing = { key : value }; third = hash(thing); thing = "done"; set(array(items_mut), [value]); items_mut += "tail"; set(hash(meta_mut), { key : value }); meta_mut["extra"] = "yes"; return(array(first, second, third, thing, array(items_mut), hash(meta_mut))) }

Done::
 /[a-z]+/
