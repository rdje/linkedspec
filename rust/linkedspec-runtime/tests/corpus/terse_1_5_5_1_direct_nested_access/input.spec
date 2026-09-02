Top::
 -> Done { set(foo, hash("a", array(hash("b", array("zero","one")))))
 set(z,1)
 return(foo["a"][0]["b"][z]) }

Done::
 /[a-z]+/
