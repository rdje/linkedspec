Top::
 -> Done { set(flag, "go"); return(array(if(is_nonempty(flag), cat("y", "es"), else("no")), if(false, "bad", "fallback"), if(true, { set(block, "branch"); return(block) }, else("bad")))) }

Done::
 /[a-z]+/
