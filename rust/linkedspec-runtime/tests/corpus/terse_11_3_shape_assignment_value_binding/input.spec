Top::
 -> Done { set(value, "ok"); set(key, "stage"); items = [value]; meta = { key : value }; return(array(items, items, copy(items), items.count(), items.first(), meta, meta, copy(meta), meta.count_keys(), meta.pick_keys(key).sorted_values().first())) }

Done::
 /[a-z]+/
