fn normalize(value) { return(trim(value)) }
fn words(value) { set(scratch, trim(value)); return([scratch, uppercase(scratch)]) }
Top::
 -> Done { normalize(" drop "); return(array(normalize(" x "), words(" go ").join_values("|"), words(" a ").count(), scratch)) }

Done::
 /[a-z]+/
