# =============================================================================
# user_function_definition.spec — top-level user-function definition parser
# =============================================================================
#
# This focused grammar owns the `fn name(params) { body }` definition shell used
# by the staged function-body prototype. It returns source-ordered
# `function_definition` records with exact body payload text and source
# provenance. It deliberately does not parse the body language; the returned
# `body_payload` is the text island consumed by later staged parsing.
# `body_parse_job` is the neutral parse-intent sidecar for that payload; it is
# metadata only in this prototype and does not execute the next parser inline.
# =============================================================================

user_function_definitions::
 -> codeblock_function_definition .push(definitions)
 -> variadic_function_definition .push(definitions)
 -> function_definition .push(definitions)
 -> malformed_function_definition .push(definitions)
 -> rule_paragraph { next() }
 LX { return(copy(definitions)) }

codeblock_function_definition: /(?m)^[ \t]*fn[ \t]+(?<name>[A-Za-z_]\w*)\s*\(\s*(?:(?<fixed_params>[A-Za-z_]\w*(?:\s*,\s*[A-Za-z_]\w*)*)\s*,\s*)?(?<codeblock_param>[A-Za-z_]\w*)\s*:\s*codeblock\s*\)\s*\{/ /\}/
 -> double_quoted_string
 -> single_quoted_string
 -> slash_line_comment
 -> hash_line_comment
 -> regex_literal
 -> body_brace
 -> codeblock_function_definition[1] {
 return({
  "type" : "function_definition",
  "kind" : "user_function_definition",
  "version" : 1,
  "name" : entry_named(name),
  "fixed_params" : entry_named(fixed_params).split(/\s*,\s*/).trim_each().filter_nonempty(),
  "codeblock_param" : entry_named(codeblock_param),
  "parameter_kinds" : { entry_named(codeblock_param) : "codeblock" },
  "source_text" : input_slice(entry_start_pos(), -(match_end_pos(), entry_start_pos())),
  "source_span" : {
   "start" : entry_start_pos(),
   "end" : match_end_pos(),
   "line_start" : entry_start_line(),
   "line_end" : match_end_line()
  },
  "body_source" : capture_slice(),
  "body_span" : {
   "start" : entry_end_pos(),
   "end" : match_start_pos(),
   "line_start" : entry_end_line(),
   "line_end" : match_start_line()
  },
  "body_payload" : {
   "kind" : "staged_payload",
   "version" : 1,
   "node_kind" : "function_definition",
   "payload_kind" : "function_body",
   "parent_ast_path" : ["functions", "__pending_source_order__", "body_source"],
   "function_name" : entry_named(name),
   "fixed_params" : entry_named(fixed_params).split(/\s*,\s*/).trim_each().filter_nonempty(),
   "codeblock_param" : entry_named(codeblock_param),
   "parameter_kinds" : { entry_named(codeblock_param) : "codeblock" },
   "text" : capture_slice(),
   "source_span" : {
    "start" : entry_end_pos(),
    "end" : match_start_pos(),
    "line_start" : entry_end_line(),
    "line_end" : match_start_line()
   },
   "provenance" : [
    {
     "kind" : "source_slice",
     "source_span" : {
      "start" : entry_end_pos(),
      "end" : match_start_pos(),
      "line_start" : entry_end_line(),
      "line_end" : match_start_line()
     }
    }
   ]
  },
  "body_parse_job" : {
   "kind" : "parse_job",
   "version" : 1,
   "job_id" : cat("parse_job:function_body:", entry_named(name), ":actionir-body.spec:action_block"),
   "parent_ast_path" : ["functions", "__pending_source_order__", "body_source"],
   "node_kind" : "function_definition",
   "payload_kind" : "function_body",
   "function_name" : entry_named(name),
   "fixed_params" : entry_named(fixed_params).split(/\s*,\s*/).trim_each().filter_nonempty(),
   "codeblock_param" : entry_named(codeblock_param),
   "parameter_kinds" : { entry_named(codeblock_param) : "codeblock" },
   "text" : capture_slice(),
   "source_span" : {
    "start" : entry_end_pos(),
    "end" : match_start_pos(),
    "line_start" : entry_end_line(),
    "line_end" : match_start_line()
   },
   "parser_spec_id" : "actionir-body.spec",
   "top_rule" : "action_block",
   "result_policy" : "replace_field",
   "result_field" : "body_ast",
   "failure_policy" : "fail",
   "diagnostic_owner" : "function_body"
  }
 })
}
 LX { return({
  "type" : "function_definition_error",
  "kind" : "user_function_definition_error",
  "message" : "invalid or unbalanced user function definition",
  "source_text" : input_slice(entry_start_pos(), -(cursor_pos(), entry_start_pos())),
  "source_span" : {
   "start" : entry_start_pos(),
   "end" : cursor_pos(),
   "line_start" : entry_start_line(),
   "line_end" : cursor_line()
  }
 }) }

function_definition: /(?m)^[ \t]*fn[ \t]+(?<name>[A-Za-z_]\w*)\s*\(\s*(?<params>[A-Za-z_]\w*(?:\s*,\s*[A-Za-z_]\w*)*)?\s*\)\s*\{/ /\}/
 -> double_quoted_string
 -> single_quoted_string
 -> slash_line_comment
 -> hash_line_comment
 -> regex_literal
 -> body_brace
 -> function_definition[1] {
 return({
  "type" : "function_definition",
  "kind" : "user_function_definition",
  "version" : 1,
  "name" : entry_named(name),
  "params" : entry_named(params).split(/\s*,\s*/).trim_each().filter_nonempty(),
  "arity" : count(entry_named(params).split(/\s*,\s*/).trim_each().filter_nonempty()),
  "source_text" : input_slice(entry_start_pos(), -(match_end_pos(), entry_start_pos())),
  "source_span" : {
   "start" : entry_start_pos(),
   "end" : match_end_pos(),
   "line_start" : entry_start_line(),
   "line_end" : match_end_line()
  },
  "body_source" : capture_slice(),
  "body_span" : {
   "start" : entry_end_pos(),
   "end" : match_start_pos(),
   "line_start" : entry_end_line(),
   "line_end" : match_start_line()
  },
  "body_payload" : {
   "kind" : "staged_payload",
   "version" : 1,
   "node_kind" : "function_definition",
   "payload_kind" : "function_body",
   "parent_ast_path" : ["functions", "__pending_source_order__", "body_source"],
   "function_name" : entry_named(name),
   "params" : entry_named(params).split(/\s*,\s*/).trim_each().filter_nonempty(),
   "arity" : count(entry_named(params).split(/\s*,\s*/).trim_each().filter_nonempty()),
   "text" : capture_slice(),
   "source_span" : {
    "start" : entry_end_pos(),
    "end" : match_start_pos(),
    "line_start" : entry_end_line(),
    "line_end" : match_start_line()
   },
   "provenance" : [
    {
     "kind" : "source_slice",
     "source_span" : {
      "start" : entry_end_pos(),
      "end" : match_start_pos(),
      "line_start" : entry_end_line(),
      "line_end" : match_start_line()
     }
    }
   ]
  },
  "body_parse_job" : {
   "kind" : "parse_job",
   "version" : 1,
   "job_id" : cat("parse_job:function_body:", entry_named(name), ":actionir-body.spec:action_block"),
   "parent_ast_path" : ["functions", "__pending_source_order__", "body_source"],
   "node_kind" : "function_definition",
   "payload_kind" : "function_body",
   "function_name" : entry_named(name),
   "params" : entry_named(params).split(/\s*,\s*/).trim_each().filter_nonempty(),
   "arity" : count(entry_named(params).split(/\s*,\s*/).trim_each().filter_nonempty()),
   "text" : capture_slice(),
   "source_span" : {
    "start" : entry_end_pos(),
    "end" : match_start_pos(),
    "line_start" : entry_end_line(),
    "line_end" : match_start_line()
   },
   "parser_spec_id" : "actionir-body.spec",
   "top_rule" : "action_block",
   "result_policy" : "replace_field",
   "result_field" : "body_ast",
   "failure_policy" : "fail",
   "diagnostic_owner" : "function_body"
  }
 })
}
 LX { return({
  "type" : "function_definition_error",
  "kind" : "user_function_definition_error",
  "message" : "invalid or unbalanced user function definition",
  "source_text" : input_slice(entry_start_pos(), -(cursor_pos(), entry_start_pos())),
  "source_span" : {
   "start" : entry_start_pos(),
   "end" : cursor_pos(),
   "line_start" : entry_start_line(),
   "line_end" : cursor_line()
  }
 }) }

variadic_function_definition: /(?m)^[ \t]*fn[ \t]+(?<name>[A-Za-z_]\w*)\s*\(\s*(?:(?<params>[A-Za-z_]\w*(?:\s*,\s*[A-Za-z_]\w*)*)\s*,\s*)?\.\.\.(?<rest_param>[A-Za-z_]\w*)\s*\)\s*\{/ /\}/
 -> double_quoted_string
 -> single_quoted_string
 -> slash_line_comment
 -> hash_line_comment
 -> regex_literal
 -> body_brace
 -> variadic_function_definition[1] {
 return({
  "type" : "function_definition",
  "kind" : "user_function_definition",
  "version" : 2,
  "name" : entry_named(name),
  "signature" : {
   "kind" : "callable_signature",
   "version" : 1,
   "positional_params" : entry_named(params).split(/\s*,\s*/).trim_each().filter_nonempty(),
   "rest_param" : entry_named(rest_param),
   "min_arity" : count(entry_named(params).split(/\s*,\s*/).trim_each().filter_nonempty()),
   "max_arity" : undef
  },
  "source_text" : input_slice(entry_start_pos(), -(match_end_pos(), entry_start_pos())),
  "source_span" : {
   "start" : entry_start_pos(),
   "end" : match_end_pos(),
   "line_start" : entry_start_line(),
   "line_end" : match_end_line()
  },
  "body_source" : capture_slice(),
  "body_span" : {
   "start" : entry_end_pos(),
   "end" : match_start_pos(),
   "line_start" : entry_end_line(),
   "line_end" : match_start_line()
  },
  "body_payload" : {
   "kind" : "staged_payload",
   "version" : 1,
   "node_kind" : "function_definition",
   "payload_kind" : "function_body",
   "parent_ast_path" : ["functions", "__pending_source_order__", "body_source"],
   "function_name" : entry_named(name),
   "signature" : {
    "kind" : "callable_signature",
    "version" : 1,
    "positional_params" : entry_named(params).split(/\s*,\s*/).trim_each().filter_nonempty(),
    "rest_param" : entry_named(rest_param),
    "min_arity" : count(entry_named(params).split(/\s*,\s*/).trim_each().filter_nonempty()),
    "max_arity" : undef
   },
   "text" : capture_slice(),
   "source_span" : {
    "start" : entry_end_pos(),
    "end" : match_start_pos(),
    "line_start" : entry_end_line(),
    "line_end" : match_start_line()
   },
   "provenance" : [
    {
     "kind" : "source_slice",
     "source_span" : {
      "start" : entry_end_pos(),
      "end" : match_start_pos(),
      "line_start" : entry_end_line(),
      "line_end" : match_start_line()
     }
    }
   ]
  },
  "body_parse_job" : {
   "kind" : "parse_job",
   "version" : 1,
   "job_id" : cat("parse_job:function_body:", entry_named(name), ":actionir-body.spec:action_block"),
   "parent_ast_path" : ["functions", "__pending_source_order__", "body_source"],
   "node_kind" : "function_definition",
   "payload_kind" : "function_body",
   "function_name" : entry_named(name),
   "signature" : {
    "kind" : "callable_signature",
    "version" : 1,
    "positional_params" : entry_named(params).split(/\s*,\s*/).trim_each().filter_nonempty(),
    "rest_param" : entry_named(rest_param),
    "min_arity" : count(entry_named(params).split(/\s*,\s*/).trim_each().filter_nonempty()),
    "max_arity" : undef
   },
   "text" : capture_slice(),
   "source_span" : {
    "start" : entry_end_pos(),
    "end" : match_start_pos(),
    "line_start" : entry_end_line(),
    "line_end" : match_start_line()
   },
   "parser_spec_id" : "actionir-body.spec",
   "top_rule" : "action_block",
   "result_policy" : "replace_field",
   "result_field" : "body_ast",
   "failure_policy" : "fail",
   "diagnostic_owner" : "function_body"
  }
 })
}
 LX { return({
  "type" : "function_definition_error",
  "kind" : "user_function_definition_error",
  "message" : "invalid or unbalanced user function definition",
  "source_text" : input_slice(entry_start_pos(), -(cursor_pos(), entry_start_pos())),
  "source_span" : {
   "start" : entry_start_pos(),
   "end" : cursor_pos(),
   "line_start" : entry_start_line(),
   "line_end" : cursor_line()
  }
 }) }

body_brace: /\{/ /\}/
 -> double_quoted_string
 -> single_quoted_string
 -> slash_line_comment
 -> hash_line_comment
 -> regex_literal
 -> body_brace
 -> body_brace[1] { return_undef() }

double_quoted_string: /"(?:\\.|[^"])*"/
 I.return_undef()

single_quoted_string: /'(?:\\.|[^'])*'/
 I.return_undef()

slash_line_comment: /\/\/[^\n]*/
 I.return_undef()

hash_line_comment: /#[^\n]*/
 I.return_undef()

regex_literal: /\/(?:\\.|[^\/\\\n])+\/[A-Za-z]*/
 I.return_undef()

malformed_function_definition: /(?m)^[ \t]*fn\b[^\n]*/
 I.return({
  "type" : "function_definition_error",
  "kind" : "user_function_definition_error",
  "message" : "invalid user function definition",
  "source_text" : entry_text(),
  "source_span" : {
   "start" : entry_start_pos(),
   "end" : entry_end_pos(),
   "line_start" : entry_start_line(),
   "line_end" : entry_end_line()
  }
 })

rule_paragraph: /(?ms)^[ \t]*[A-Za-z_]\w*[ \t]*(?:::|:).*?(?=^[ \t]*(?:fn\b|[A-Za-z_]\w*[ \t]*(?:::|:))|\z)/
 I.return_undef()
