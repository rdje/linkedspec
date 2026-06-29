Top::
 /x/ -> Done { set(value, "b"); items.push_back("a"); items.push_back(value); items.push_front("z"); items.pop_back(); items.pop_front(); return(array_copy(items)) }

Done::
/[a-z]+/
