Top::
 -> Done { set_key(base, "b", 2); set_key(base, "a", 1); set_key(overlay, "c", 3); return(count(drop_front(sorted_keys(merge_hash(base, overlay))))) }

Done::
 /[a-z]+/
