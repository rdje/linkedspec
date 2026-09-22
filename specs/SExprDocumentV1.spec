# ADR0124: complete documents with exact token kinds and source spelling.
# Select this grammar explicitly; Lispish retains its extraction contract.
Document::
I { forms = [] }
 -> Trivia
 -> List { push(forms, call(List)) }
 -> Invalid { exit_now(1) }
LX {
 if(num_ne(cursor_pos(), input_end_pos()));
  exit_now(1);
 endif();
 return(hash("format", "linkedspec-sexpr-v1", "forms", copy(forms)))
}

List: /\(/ /\)/
I { items = [] }
 -> Trivia
 -> List { push(items, call(List)) }
 -> String { push(items, call(String)) }
 -> Atom { push(items, call(Atom)) }
 -> List[1] { return(hash("kind", "list", "items", copy(items))) }
 -> Invalid { exit_now(1) }
LX { exit_now(1) }

# The comment body runs to a line ending or EOF without a backend-specific anchor.
Trivia: /[ \t\r\n\f\x0B]+|;[^\r\n]*(?:\r\n|\r|\n)?/

String: /"((?:[^"\\]|\\[\s\S])*)"/
I.return(hash("kind", "string", "lexeme", entry_text()))

Atom: /[^ \t\r\n\f\x0B()\[\]{}";]+/
I {
 spelling = entry_text();
 if(matches(spelling, /^[+-]?(?:0[xX][0-9a-fA-F](?:_?[0-9a-fA-F])*|(?:[0-9](?:_?[0-9])*(?:\.[0-9](?:_?[0-9])*)?|\.[0-9](?:_?[0-9])*)(?:[eE][+-]?[0-9](?:_?[0-9])*)?)$/));
  return(hash("kind", "number", "lexeme", spelling));
 else();
  return(hash("kind", "symbol", "lexeme", spelling));
 endif()
}

# These catch-all edges reject text that normal seek dispatch could skip.
Invalid: /[\s\S]/
