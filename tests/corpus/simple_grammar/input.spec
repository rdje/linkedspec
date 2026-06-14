DemoParser::
 /pattern1/ -> Child {
 I { declare(array, results) }
 LE { push_value(array(results), scalar(retv)) }
 E { return(array("?results:", array_copy(array(results)))) }
 }

Child::
 /hello[ \t]+(\w+)/
 I { declare(scalar, name=entry_group(1)) }
 E { return(scalar(name)) }
