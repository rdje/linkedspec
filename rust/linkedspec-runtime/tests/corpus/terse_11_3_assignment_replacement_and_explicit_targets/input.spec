Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); thing = "text"; first = thing; thing = [value]; second = thing; thing = { key : value }; third = thing; thing = "done"; set(items_mut, [value]); items_mut += "tail"; set(meta_mut, { key : value }); meta_mut["extra"] = "yes"; return(array(first, second, third, thing, items_mut, meta_mut)) }

Done::
 /[a-z]+/
