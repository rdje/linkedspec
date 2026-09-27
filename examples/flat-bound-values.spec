fn padded(value) { return(array(0, flat(value), 3)) }

Top::
 -> Done {
  meta = {"existing":1}
  document = {"items":[1,2]}
  return({
   "fields":hash(flat(meta), "added", 7),
   "items":padded(document["items"]),
   "kept":[document["items"]],
   "empty":padded([])
  })
 }
Done: /x/
