fn pair(value) { return(array(value, value)) }
fn tagged(value) {
  local = trim(value)
  return(array("tag", local, pair(local)))
}
Top::
 -> Done { return(array(pair(7), tagged(" x "), pair(undef))) }
Done:
 /x/
