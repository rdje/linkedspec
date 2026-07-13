sexpr:: /\(/ /\)/  I { items = [] }
 -> sexpr     { push(items, call(sexpr)) }
 -> atom      { push(items, call(atom)) }
 -> sexpr[1]  { return(copy(items)) }
LX { return(copy(items)) }

atom: /[A-Za-z0-9]+/   I.return(entry_text())
