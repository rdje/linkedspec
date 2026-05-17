# spec.spec — Self-hosted LinkedSpec grammar
#
# This grammar parses .spec files into their structural elements: rule labels,
# modes, regex anchors, action edges, blind-call edges, code blocks, and split
# markers.
#
# It is the required change surface for .spec language evolution.
# Touching the bootstrap grammar for .spec changes is exception-only.

spec_file::AND+
 -> rule_paragraph

I {declare(array, rules)}
LS {declare(scalar, retv)}
LE {
 if(scalar(retv));
  push_value(array(rules), scalar(retv));
 endif()
}
LX {return(hash("rules", array(rules)))}


rule_paragraph:AND /(\w+)[ \t]*(::|:)[ \t]*(\S*)[ \t]*(.*)/
I {
 declare(scalar, label=entry_group(1));
 declare(scalar, colon=entry_group(2));
 declare(scalar, is_top=0);
 if(matches(scalar(colon), /^::$/o));
  declare(scalar, is_top=1);
 endif();
 declare(scalar, mode_raw=entry_group(3));
 declare(scalar, rest=entry_group(4));
 declare(scalar, mode='');
 if(matches(scalar(mode_raw), /^$/o));
  declare(scalar, mode='');
 else();
  if(matches(scalar(mode_raw), /^(?:AND|OR)(?:\+|\{\d+(?:,\d+)?\})?$/o));
   declare(scalar, mode=scalar(mode_raw));
  else();
   if(matches(scalar(mode_raw), /^[&|+*?]$/o));
    declare(scalar, mode=scalar(mode_raw));
   else();
    declare(scalar, mode='');
    if(length(scalar(rest)));
     declare(scalar, rest=concat(scalar(mode_raw), ' ', scalar(rest)));
    else();
     declare(scalar, rest=scalar(mode_raw));
    endif();
   endif();
  endif();
 endif();
 return(hash(
  "type", "rule_header",
  "label", scalar(label),
  "is_top", scalar(is_top),
  "mode", scalar(mode),
  "rest", scalar(rest),
  "body", array()
 ))
}
 -> body_element


# body_element uses regex-anchored alternatives so every referenced rule has a
# regex list. Each alternative matches the start pattern of one element type and
# returns the element AST directly.
body_element:*
 /(?<!\\)\/(?:\\.|[^\/\\])*?(?<!\\)\//
  I { return(hash("type", "regex", "value", match_text())) }
 /->[ \t]*\w+(?:\[\d+\])?/
  I { return(body_edge_ast(match_text())) }
 /=>[ \t]*\w+/
  I { return(body_blind_edge_ast(match_text())) }
 /(?<!\\)\{/
  I { return(hash("type", "code_block")) }
 /@[ \t]*(?:capture_slice|capture_from_here|move_pos|mark[ \t]*\([ \t]*\w+[ \t]*\))/
  I { return(hash("type", "split_marker", "marker", match_text())) }

# Helper: parse action-edge text into target/index AST.
body_edge_ast {
 declare(scalar, text=scalar(edge_text));
 if(matches(scalar(text), /->[ \t]*(\w+)(?:\[(\d+)\])?/o));
  declare(scalar, target=entry_group(1));
  declare(scalar, idx=0);
  if(entry_group(2));
   declare(scalar, idx=entry_group(2));
  endif();
  return(hash("type", "edge", "target", scalar(target), "index", scalar(idx)));
 else();
  return_undef();
 endif()
}

body_blind_edge_ast {
 declare(scalar, text=scalar(blind_text));
 if(matches(scalar(text), /=>[ \t]*(\w+)/o));
  return(hash("type", "blind_edge", "target", entry_group(1)));
 else();
  return_undef();
 endif()
}
