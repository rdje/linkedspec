Top::
 /x/ -> Done { meta = { "b" : { "y" : "B" }, "a" : "A", "arr" : ["u", "v"] }; nonhash = "x".map_leaves() { seen += "bad" }; return(array(meta.map_leaves() { return(cat(join_values("/", path), "=", coalesce_nonempty(join_values("", value), value))) }, meta.reduce_leaves("") { return(cat(acc, key)) }, meta.walk_leaves() { seen += join_values("/", path); return(value) }.count_keys(), seen, if(is_undefined(nonhash), "undef", else("bad")))) }

Done::
 /[a-z]+/
