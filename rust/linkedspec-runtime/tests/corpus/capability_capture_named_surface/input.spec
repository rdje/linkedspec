Top::AND
 => Value

Value:AND
 /A/
 /xxB/
 /C/
 -> Value[0] {
  mark_here(origin)
  mark_input_start(input_start)
  mark_input_end(input_end)
  mark_copy(copied, origin)
 }
 -> Value[2] {
  mark_here(cursor_end)
  from = capture_from(origin)
  from_len = capture_len_from(origin)
  until_cursor = capture_until_cursor_from(origin)
  until_cursor_len = capture_until_cursor_len_from(origin)
  rest = capture_rest_from(origin)
  rest_len = capture_rest_len_from(origin)
  between = capture_between(origin, cursor_end)
  between_len = capture_len_between(origin, cursor_end)

  mark_copy(work, origin)
  take_len = capture_take_len_from(work)
  mark_copy(work, origin)
  take_until_cursor = capture_take_until_cursor_from(work)
  mark_copy(work, origin)
  take_until_cursor_len = capture_take_until_cursor_len_from(work)
  mark_copy(work, origin)
  take_rest = capture_take_rest_from(work)
  mark_copy(work, origin)
  take_rest_len = capture_take_rest_len_from(work)
  mark_copy(work, origin)
  take_between = capture_take_between(work, cursor_end)
  mark_copy(work, origin)
  take_between_len = capture_take_between_len(work, cursor_end)

  return(hash(
   "origin_exists", mark_exists(origin),
   "origin_pos", mark_pos(origin),
   "copied_pos", mark_pos(copied),
   "whole_input", capture_between(input_start, input_end),
   "from", from,
   "from_len", from_len,
   "until_cursor", until_cursor,
   "until_cursor_len", until_cursor_len,
   "rest", rest,
   "rest_len", rest_len,
   "between", between,
   "between_len", between_len,
   "take_len", take_len,
   "take_until_cursor", take_until_cursor,
   "take_until_cursor_len", take_until_cursor_len,
   "take_rest", take_rest,
   "take_rest_len", take_rest_len,
   "take_between", take_between,
   "take_between_len", take_between_len
  ))
 }
