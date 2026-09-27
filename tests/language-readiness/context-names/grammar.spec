# Context probe only: ASCII tag names and literal Unicode text, not XML.
Top::
I {
 if(matches(input_slice(0, cursor_pos()), /[^ \t\r\n\f\x0B]/));
  exit_now(1);
 endif();
 forms = []
}
 -> Space
 -> Element { push(forms, call(Element)) }
 -> Invalid { exit_now(1) }
LX {
 if(num_ne(cursor_pos(), input_end_pos()));
  exit_now(1);
 endif();
 return(copy(forms))
}

Element: /<([A-Za-z][A-Za-z0-9_-]*)>/ /<\/([A-Za-z][A-Za-z0-9_-]*)>/
I { name = entry_group(0); children = []; start = entry_start_pos() }
 -> Element { push(children, call(Element)) }
 -> Text { push(children, call(Text)) }
 -> Element[1] {
  if(str_ne(match_group(0), name));
   exit_now(2);
  endif();
  return(hash("kind", "element", "name", name, "span", [start, cursor_pos()], "children", copy(children)))
 }
 -> Invalid { exit_now(1) }
LX { exit_now(3) }

Text: /[^<>]+/
I.return(hash("kind", "text", "span", [entry_start_pos(), entry_end_pos()], "text", entry_text()))

Space: /[ \t\r\n\f\x0B]+/

Invalid: /[\s\S]/
