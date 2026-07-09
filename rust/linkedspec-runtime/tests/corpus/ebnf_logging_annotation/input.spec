# Grammar parser for := style rules
# This spec will parse EBNF-style grammar definitions

grammar_file:: I {
  rules = [];
  rule = [];
  includes = [];
  semantic_annotations = [];
  rule_header = undef;
  on = undef
}

LX {
  if(rule_header);
    push(array(rules), array(rule_header, flat_array(rule)));
  endif();

  return(array(flat_array(includes), flat_array(rules)))
}

-> include_dir.push(includes)
-> include_file.push(includes)

-> grammar_rule   {
  if(rule_header);
    push(array(rules), array(rule_header, flat_array(rule)));
  endif();

  set(array(rule), array(flat_array(semantic_annotations)));
  set(array(semantic_annotations), array());

  rule_header = call(grammar_rule);
  on = 1
}

-> rule_name
  .if(on)
    .push(rule_name, rule)
  .else()
    .say("Error: Rule name '", entry_text(), "' reference with no container rule context")
    .return_undef()
  .endif()

-> quoted_string
  .if(on)
    .push(quoted_string, rule)
  .else()
    .say("Error: Quoted string <", entry_text(), "> occurrence with no container rule context")
    .return_undef()
  .endif()

-> number
  .if(on)
    .push(number, rule)
  .else()
    .say("Error: Number '", entry_text(), "' occurrence with no container rule context")
    .return_undef()
  .endif()

-> quantifier
  .if(on)
    .push(quantifier, rule)
  .else()
    .say("Error: Quantifier occurrence with no container rule context")
    .return_undef()
  .endif()

-> plus_operator
  .if(on)
    .push(plus_operator, rule)
  .else()
    .say("Error: '+' operator occurrence with no container rule context")
    .return_undef()
  .endif()

-> return_scalar_value
  .if(on)
    .push(return_scalar_value, rule)
  .else()
    .say("Error: Scalar return annotation occurrence with no container rule context")
    .return_undef()
  .endif()

-> return_array_value
  .if(on)
    .push(return_array_value, rule)
  .else()
    .say("Error: Array return annotation occurrence with no container rule context")
    .return_undef()
  .endif()

-> return_object
  .if(on)
    .push(return_object, rule)
  .else()
    .say("Error: Object return annotation occurrence with no container rule context")
    .return_undef()
  .endif()

-> star_operator
  .if(on)
    .push(star_operator, rule)
  .else()
    .say("Error: '*' operator occurrence with no container rule context")
    .return_undef()
  .endif()

-> question_operator
  .if(on)
    .push(question_operator, rule)
  .else()
    .say("Error: '?' operator occurrence with no container rule context")
    .return_undef()
  .endif()

-> pipe_operator
  .if(on)
    .push(pipe_operator, rule)
  .else()
    .say("Error: '|' operator occurrence with no container rule context")
    .return_undef()
  .endif()

-> open_paren
  .if(on)
    .push(open_paren, rule)
  .else()
    .say("Error: '(' occurrence with no container rule context")
    .return_undef()
  .endif()

-> close_paren
  .if(on)
    .push(close_paren, rule)
  .else()
    .say("Error: ')' occurrence with no container rule context")
    .return_undef()
  .endif()

-> probability
  .if(on)
    .push(probability, rule)
  .else()
    .say("Error: Probability occurrence with no container rule context")
    .return_undef()
  .endif()

-> regex
  .if(on)
    .push(regex, rule)
  .else()
    .say("Error: Regex occurrence with no container rule context")
    .return_undef()
  .endif()

-> semantic_annotation.push(semantic_annotations)
-> logging_annotation
  .if(on)
    .push(logging_annotation, rule)
  .else()
    .say("Error: Logging annotation occurrence with no container rule context")
    .return_undef()
  .endif()

-> whitespace
-> comment

grammar_rule: /(?m)^\s*([[:alpha:]_]\w*)\s*:{,2}=/  I.return(array("rule", entry_group(0)))
rule_name: /\b[[:alpha:]_]\w*/                      I.return(array("rule_reference", entry_text()))

quoted_string: /"[^"]*"|'[^']*'/  I {value = entry_text(); substr(value, "^(?:'|\")|(?:'|\")$", "", go); return(array("quoted_string", value))}
number: /\b\d+\b/                 I.return(array("number", entry_text()))
quantifier: /\{\s*(?:\d+(?:\s*,\s*\d*)?|,\s*\d+)\s*\}/  I {value = entry_text(); substr(value, "\\{|\\}", "", go); return(array("quantifier", value))}
pipe_operator: /\|/               I.return(array("operator", entry_text()))
plus_operator: /\+/               I.return(array("operator", entry_text()))
star_operator: /\*/               I.return(array("operator", entry_text()))
question_operator: /\?/           I.return(array("operator", entry_text()))
return_scalar_value: /->\s*\K(?:\$\d+|"[^"]*"|'[^']*')/  I.return(array("return_scalar_value", entry_text()))
return_array_value: /->\s*\K(?&array_structure)(?(DEFINE)(?<array_structure>\[(?&content)\])(?<object_structure>\{(?&content)\})(?<content>(?:[^{}\[\]]*|(?&array_structure)|(?&object_structure))*))/   I.return(array("return_array_value", entry_text()))
return_object: /->\s*\K(?&object_structure)(?(DEFINE)(?<array_structure>\[(?&content)\])(?<object_structure>\{(?&content)\})(?<content>(?:[^{}\[\]]*|(?&array_structure)|(?&object_structure))*))/ I.return(array("return_object", entry_text()))
open_paren: /\(/                  I.return(array("group_open", entry_text()))
close_paren: /\)/                 I.return(array("group_close", entry_text()))
probability: /@\d+%?/             I {value = entry_text(); substr(value, "@|%", "", go); return(array("probability", value))}
regex: /(?<!\\)\/.+?(?<!\\)\//    I {value = entry_text(); substr(value, "^/|/$", "", go); return(array("regex", value))}
whitespace: /\s+/
comment: /#.*/
include_dir: /\b(?:include_)?dir\(\s*[^)]*?\s*\)/ I {args = entry_text(); substr(args, "^\s*(?:include_)?dir\(\s*", "", g); substr(args, "\s*\)\s*$", "", g); parts = []; split(array(parts), args, /\s*,\s*/); trim_each(array(parts)); filter_nonempty(array(parts)); return(array("include_dir", copy(array(parts))))}
include_file: /\b(?:include(?:_file)?|file)\(\s*[^)]*?\s*\)/ I {args = entry_text(); substr(args, "^\s*(?:include(?:_file)?|file)\(\s*", "", g); substr(args, "\s*\)\s*$", "", g); parts = []; split(array(parts), args, /\s*,\s*/); trim_each(array(parts)); filter_nonempty(array(parts)); return(array("include_file", copy(array(parts))))}

semantic_annotation: /@(\w+)\s*:\s*/
I {c = capture_until_boundary(semantic_annotation, grammar_rule); substr(c, "\s*$", "", o); substr(c, "^\"|\"$", "", go); return(array("semantic_annotation", array(entry_group(0), c)))}

logging_annotation: /@((?:log|debug|trace|benchmark|profile|timing)_\w+)\s*\(\s*/ /\s*\)/ I {logging_name = entry_group(0); start_capture_slice()}

-> quoted_string {
  push(quoted_string, 1);
  start_capture_slice()
}
-> comma {
  logging_annotation_part = trim(capture_slice());
  if(is_nonempty(logging_annotation_part));
    push(array(logging_annotation), logging_annotation_part);
  endif();
  start_capture_slice()
}
-> logging_annotation[1] {
  logging_annotation_part = trim(capture_slice());
  if(is_nonempty(logging_annotation_part));
    push(array(logging_annotation), logging_annotation_part);
  endif();
  return(array("logging_annotation", array(logging_name, copy(array(logging_annotation)))))
}

comma: /\s*,\s*/
