Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); return(array(items = [value], copy(array(items)), set(meta, { key => value }), copy(hash(meta)), set(:payload, [value]), payload, =(more, [value, "x"]).count())) }

Done::
 /[a-z]+/
