sexpr:: /\(/ /\)/  I { declare(array, items) }
 -> sexpr     { push_value(array(items), call(sexpr)) }
 -> atom      { push_value(array(items), call(atom)) }
 -> sexpr[1]  { return(array_copy(array(items))) }
LX { return(array_copy(array(items))) }

atom: /[A-Za-z0-9]+/   I.return(entry_text())
