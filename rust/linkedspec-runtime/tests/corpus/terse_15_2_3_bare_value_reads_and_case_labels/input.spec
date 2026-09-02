Top::
 -> Done { set(kind, "foo"); set(foo, "bar"); set(n, 10); set(c, 0); switch(kind) { case(foo) { attached = "literal" } case(cat(foo, "")) { attached = "dynamic" } default { attached = "default" } }; return(array(attached, switch(kind, case(foo, "literal"), case(cat(foo, ""), "dynamic"), default("default")), if(num_lt(n, 5), "yes", else("no")), if(c, "T", else("F")))) }

Done::
 /[a-z]+/
