Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); set(items, [value]); meta = { key => value }; set(:payload, [value]); return(array(array_copy(array(items)), hash_copy(hash(meta)), :payload, array_copy(array(payload)))) }

Done::
 /[a-z]+/
