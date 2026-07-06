Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); items = [value]; meta = { key => value }; return(array(items, array(items), copy(items), items.count(), items.first(), meta, hash(meta), copy(meta), meta.count_keys(), meta.pick_keys(key).sorted_values().first())) }

Done::
 /[a-z]+/
