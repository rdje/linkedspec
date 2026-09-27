# Canonical unsigned decimal lexemes: zero or a nonzero digit followed by digits.
Number::
 I {
  if(num_ne(cursor_pos(), 0));
   exit_now(1);
  endif();
 }
 -> Digits { return(call(Digits)) }
 LX { exit_now(1) }

Digits:
 number=/(0|[1-9][0-9]*)/
 I {
  if(num_ne(entry_start_pos(), 0));
   exit_now(1);
  endif();
  if(num_ne(entry_end_pos(), input_end_pos()));
   exit_now(1);
  endif();
  return(hash("kind", "integer", "text", entry_text(), "span", hash("start", entry_start_pos(), "end", entry_end_pos())))
 }
