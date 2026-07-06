sexpr:: /\(/ /\)/  I { declare(array, items) }
 -> sexpr     { push(array(items), call(sexpr)) }
 -> atom      { push(array(items), call(atom)) }
 -> sexpr[1]  { return(copy(array(items))) }
LX { return(copy(array(items))) }

atom: /[A-Za-z0-9]+/   I.return(entry_text())
