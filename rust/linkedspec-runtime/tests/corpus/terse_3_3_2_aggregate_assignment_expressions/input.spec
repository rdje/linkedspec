Top::
 -> Done { set(value, "ok"); set(key, "stage"); return(array(items = [value], copy(items), set(meta, { key : value }), copy(meta), set(payload, [value]), payload, =(more, [value, "x"]).count())) }

Done::
 /[a-z]+/
