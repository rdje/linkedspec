fn normalize(value) { return(trim(scalar(value))) }
fn words(value) { set(scratch, trim(scalar(value))); return([scalar(scratch), uppercase(scalar(scratch))]) }
Top::
 /x/ -> Done { normalize(" drop "); return(array(normalize(" x "), words(" go ").join_values("|"), words(" a ").count(), scalar(scratch))) }

Done::
 /[a-z]+/
