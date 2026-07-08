Top::
 /x/ -> Done { meta = { "b" : { "y" : "B" }, "a" : "A", "arr" : ["u", "v"] }; nonhash = "x".map_leaves() { seen += "bad" }; return(array(meta.map_leaves() { return(cat(join_values("/", array(path)), "=", if(count(array(value)), join_values("", array(value)), else(value)))) }, meta.reduce_leaves("") { return(cat(acc, key)) }, meta.walk_leaves() { seen += join_values("/", array(path)); return(value) }.count_keys(), array(seen), if(is_undefined(nonhash), "undef", else("bad")))) }

Done::
 /[a-z]+/
