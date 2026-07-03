Top::
 /x/ -> Done { set(value, "ok"); set(:payload, [value]); set(snapshot, :payload); return(array(:value, :payload, copy(array(payload)), :snapshot)) }

Done::
 /[a-z]+/
