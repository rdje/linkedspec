Top::
 /x/ -> Done { items = ["a", ["b", "c"], { "h" : "H" }]; scalar = "x"; nonarray = scalar.map_leaves() { seen += "bad" }; return(array(items.map_leaves() { return(cat(join_values("/", array(path)), "=", if(count(hash(value).sorted_keys()), cat("{", hash(value).sorted_keys().join_values(","), "}"), else(value)))) }, items.reduce_leaves("") { return(cat(acc, join_values("/", array(path)), ":", if(count(hash(value).sorted_keys()), cat("{", hash(value).sorted_keys().join_values(","), "}"), else(value)), ";")) }, items.walk_leaves() { seen += join_values("/", array(path)); return(value) }.count(), array(seen), if(is_undefined(nonarray), "undef", else("bad")))) }

Done::
 /[a-z]+/
