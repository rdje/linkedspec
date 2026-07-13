Top::
 -> Value .push
 LX { return(copy(Top)) }

Value:
 /(?<word>ab)/
 I {
  return(hash(
   "entry_col", entry_col(),
   "entry_end_col", entry_end_col(),
   "entry_end_line", entry_end_line(),
   "entry_end_pos", entry_end_pos(),
   "entry_has", entry_has(word),
   "entry_len", entry_len(),
   "entry_line", entry_line(),
   "entry_map", entry_map(),
   "entry_start_col", entry_start_col(),
   "entry_start_line", entry_start_line(),
   "entry_start_pos", entry_start_pos(),
   "match_col", match_col(),
   "match_end_col", match_end_col(),
   "match_end_line", match_end_line(),
   "match_end_pos", match_end_pos(),
   "match_group", match_group(0),
   "match_groups", match_groups(),
   "match_has", match_has(word),
   "match_len", match_len(),
   "match_map", match_map(),
   "match_named", match_named(word),
   "match_start_col", match_start_col(),
   "match_start_line", match_start_line(),
   "input_end_col", input_end_col(),
   "input_end_line", input_end_line(),
   "input_end_pos", input_end_pos(),
   "input_len", input_len(),
   "input_text", input_text(),
   "cursor_col", cursor_col(),
   "cursor_rest", cursor_rest(),
   "cursor_rest_len", cursor_rest_len()
  ))
 }
