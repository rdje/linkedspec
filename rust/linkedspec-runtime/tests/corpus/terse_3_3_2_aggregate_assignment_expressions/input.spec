Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); return(array(items = [value], array_copy(array(items)), set(meta, { key => value }), hash_copy(hash(meta)), set(scalar(payload), [value]), payload, =(more, [value, "x"]).count())) }

Done::
 /[a-z]+/
