Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); set(items, [value]); meta = { key => value }; set(:payload, [value]); return(array(copy(array(items)), copy(hash(meta)), :payload, copy(array(payload)))) }

Done::
 /[a-z]+/
