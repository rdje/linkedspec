Top::AND
 => Value

Value:AND
 /A/
 /xxB/
 /C/
 -> Value[0] {
  start_capture_slice()
  mark_capture_slice(origin)
 }
 -> Value[2] {
  slice = capture_slice()
  slice_len = capture_slice_len()
  slice_pos = capture_slice_pos()
  slice_line = capture_slice_line()
  slice_col = capture_slice_col()
  until_cursor = capture_slice_until_cursor()
  until_cursor_len = capture_slice_until_cursor_len()
  rest = capture_rest()
  rest_len = capture_rest_len()
  start_capture_slice_from(origin)
  take = capture_take()
  start_capture_slice_from(origin)
  take_len = capture_take_len()
  start_capture_slice_from(origin)
  take_until_cursor = capture_take_until_cursor()
  start_capture_slice_from(origin)
  take_until_cursor_len = capture_take_until_cursor_len()
  start_capture_slice_from(origin)
  take_rest = capture_take_rest()
  start_capture_slice_from(origin)
  take_rest_len = capture_take_rest_len()
  return(hash(
   "slice", slice,
   "slice_len", slice_len,
   "slice_pos", slice_pos,
   "slice_line", slice_line,
   "slice_col", slice_col,
   "until_cursor", until_cursor,
   "until_cursor_len", until_cursor_len,
   "rest", rest,
   "rest_len", rest_len,
   "take", take,
   "take_len", take_len,
   "take_until_cursor", take_until_cursor,
   "take_until_cursor_len", take_until_cursor_len,
   "take_rest", take_rest,
   "take_rest_len", take_rest_len
  ))
 }
