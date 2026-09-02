Top::
 -> Done { set(kind, "b"); set(out, switch(kind, case("a", "bad"), case("b", cat("y", "es")), default("no"))); return(out) }

Done::
 /[a-z]+/
