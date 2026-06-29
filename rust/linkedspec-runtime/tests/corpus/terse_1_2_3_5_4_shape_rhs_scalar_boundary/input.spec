Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); set(items, [value]); assign(meta, { key => value }); set(scalar(payload), [value]); return(array(array_copy(array(items)), hash_copy(hash(meta)), scalar(payload), array_copy(array(payload)))) }

Done::
 /[a-z]+/
