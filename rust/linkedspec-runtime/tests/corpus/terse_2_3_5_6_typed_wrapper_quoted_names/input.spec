Top::
 /x/ -> Done { items += "a"; items += "b"; set_key(meta, "a", 1); set_key(meta, "b", 2); return(array(count(array(items)), count(array("items")), count(array('items')), count(a(items)), count(a("items")), count(["items"]), count(array("literal", "value")), count_keys(hash(meta)), count_keys(hash("meta", 1)), count_keys(hash('meta', 1)), count_keys({ "meta" => 1 }), count_keys(h(meta)), count_keys(h("meta", 1)))) }

Done::
 /[a-z]+/
