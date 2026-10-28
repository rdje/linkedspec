Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos(finish).coalesce(0).sub(1),mark_line(finish).coalesce(0).add(1),mark_col(finish).coalesce(0).cat("!"),capture_len_from(begin).coalesce(0).cat(":tail").split(":")[-1].uppercase(),capture_rest_len_from(begin).coalesce(0).add(1),capture_until_cursor_len_from(begin).coalesce(0).sub(1),capture_len_between(begin,finish).coalesce(0).add(1)])}
