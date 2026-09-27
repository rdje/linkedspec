# Readiness probe only: lists, bare atoms and ASCII whitespace; no string syntax.
Top::
I {
 if(matches(input_slice(0, cursor_pos()), /[^ \t\r\n\f\x0B]/));
  exit_now(1);
 endif();
 forms = []
}
 -> Space
 -> List { push(forms, call(List)) }
 -> Invalid { exit_now(1) }
LX {
 if(num_ne(cursor_pos(), input_end_pos()));
  exit_now(1);
 endif();
 return(copy(forms))
}

List: /\(/ /\)/
I { items = []; start = entry_start_pos() }
 -> Space
 -> List { push(items, call(List)) }
 -> Atom { push(items, call(Atom)) }
 -> List[1] { return(hash("kind", "list", "span", [start, cursor_pos()], "items", copy(items))) }
 -> Invalid { exit_now(1) }
LX { exit_now(1) }

Atom: /[^ \t\r\n\f\x0B()]+/
I.return(hash("kind", "atom", "span", [entry_start_pos(), entry_end_pos()], "text", entry_text()))

Space: /[ \t\r\n\f\x0B]+/

Invalid: /[\s\S]/
