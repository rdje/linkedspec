Top::
 /x/ -> Done { set_key(meta, "b", 2); set_key(meta, "a", 1); set_key(extra, "a", 9); set_key(extra, "c", 3); set(layered, merge_hash(meta, extra)); return(array(meta.set_key("c", 3).sorted_keys().join_values(","), layered.pick_keys("a").sorted_values().first(), meta.rename_key("a", "aa").drop_keys("b").set_key("z", 4).count_keys(), meta.pick_keys("missing").count_keys(), meta.sorted_values().drop_front(1).first(), meta.copy().flat_hash().count_keys(), missing.copy().count_keys())) }

Done::
 /[a-z]+/
