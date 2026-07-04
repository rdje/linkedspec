DemoParser::
I { results = [] }
 -> Child { push(array(results), call(Child)) }
LX { return(hash("?results:", copy(array(results)))) }

Child:
 /pattern1[ \t]+hello[ \t]+(\w+)/
 I { name = entry_group(0) }
 E { return(:name) }
