# Same extraction as lossless-segments, with source-bound staged item payloads.
Item:
 token=/\[([0-9]+)\]/
 I {
  child = parse_job(entry_group(0), hash(
   "node_kind", "integer", "payload_kind", "decimal_digits", "spec", "integer",
   "top", "Number", "result_policy", "sibling_field", "into", "parsed", "on_error", "fail"
  ))
  return(hash("kind", "item", "span", [entry_start_pos(), entry_end_pos()], "text", entry_text(), "slot", entry_slot(), "child", child))
 }

Segments::
 @capture_gaps
 I {
  parts = []
  if(num_ne(cursor_pos(), 0));
   push(parts, hash("kind", "entry_prefix", "span", [0, cursor_pos()], "text", input_slice(0, cursor_pos())))
  endif();
 }
 -> Item[token] {
  push(parts, hash("kind", gap_kind(), "span", gap_span(), "text", gap_text()))
  push(parts, call(Item))
 }
 LX {
  push(parts, hash("kind", gap_kind(), "span", gap_span(), "text", gap_text()))
  return(copy(parts))
 }
