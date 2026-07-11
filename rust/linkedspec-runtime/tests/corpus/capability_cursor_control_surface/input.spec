Top::
 /ab/ -> Done {
  after_match = cursor_pos()
  save_cursor()
  rewind_match_start()
  match_start = cursor_pos()
  restore_cursor()
  restored_match = cursor_pos()
  save_cursor()
  rewind_entry_start()
  entry_start = cursor_pos()
  restore_cursor()
  restored_entry = cursor_pos()
  return(hash(
   "after_match", after_match,
   "match_start", match_start,
   "restored_match", restored_match,
   "entry_start", entry_start,
   "restored_entry", restored_entry
  ))
 }

Done:
 /ab/
