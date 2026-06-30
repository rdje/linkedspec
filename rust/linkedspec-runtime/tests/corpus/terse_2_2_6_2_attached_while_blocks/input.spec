Top::
 /x/ -> Done { set(count, 0); while(num_lt(scalar(count), 3)) { set(count, num_add(scalar(count), 1)) }; return(count) }

Done::
 /[a-z]+/
