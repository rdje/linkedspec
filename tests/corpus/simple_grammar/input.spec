DemoParser::
I { results = [] }
 -> Child { push(results, call(Child)) }
LX { return(hash("?results:", copy(results))) }

Child:
 /pattern1[ \t]+hello[ \t]+(\w+)/
 I { name = entry_group(0) }
 E { return(name) }
