Top::
 /x/ -> Done { items = ["a", ["b", "c"], { "h" : "H" }]; scalar = "x"; nonarray = scalar.map_leaves() { seen += "bad" }; return(array(items.map_leaves() { return(cat(join_values("/", path), "=", if(count(value.sorted_keys()), cat("{", value.sorted_keys().join_values(","), "}"), else(value)))) }, items.reduce_leaves("") { return(cat(acc, join_values("/", path), ":", if(count(value.sorted_keys()), cat("{", value.sorted_keys().join_values(","), "}"), else(value)), ";")) }, items.walk_leaves() { seen += join_values("/", path); return(value) }.count(), seen, if(is_undefined(nonarray), "undef", else("bad")))) }

Done::
 /[a-z]+/
