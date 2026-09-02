Top::
 -> Done {
  branch = ""
  i(false)
  branch = "bad"
  elif(true)
  branch = "elif"
  else()
  branch = "bad-else"
  endif()
  selected = ""
  switch("b")
  case("a")
  selected = "bad-a"
  endcase()
  case("b")
  selected = "case-b"
  endcase()
  default()
  selected = "bad-default"
  endswitch()
  return([branch, selected])
 }

Done:
 /x/
