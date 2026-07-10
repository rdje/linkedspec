struct SpecValidationException <: Exception
    message::String
end

Base.showerror(io::IO, error::SpecValidationException) = print(io, error.message)

function validate_spec(spec::SpecFile; strict_syntax::Bool = false)
    _check_top_rule_exists(spec)
    _check_duplicate_rule_labels(spec)
    _check_duplicate_function_names(spec)
    _check_function_registry(spec)
    _check_malformed_raw_body_lines(spec)
    _check_mixed_edges(spec)
    _check_grouped_action_edges(spec)
    _check_edge_targets(spec)
    _check_regex_syntax(spec)
    if strict_syntax
        _check_unused_rules(spec)
    end
    return nothing
end

function _check_top_rule_exists(spec::SpecFile)
    if any(rule -> rule.header.is_top, spec.rules)
        return nothing
    end
    throw(SpecValidationException("no top rule found: at least one rule must use '::' (double colon)"))
end

function _check_duplicate_rule_labels(spec::SpecFile)
    seen = Set{String}()
    for rule in spec.rules
        label = rule.header.label
        if label in seen
            throw(SpecValidationException("duplicate rule label '$label'"))
        end
        push!(seen, label)
    end
    return nothing
end

function _check_duplicate_function_names(spec::SpecFile)
    seen = Set{String}()
    for function_definition in spec.functions
        name = function_definition.name
        if name in seen
            throw(SpecValidationException("duplicate user function definition '$name'"))
        end
        push!(seen, name)
    end
    return nothing
end

function _check_function_registry(spec::SpecFile)
    rule_labels = Set(rule.header.label for rule in spec.rules)

    for function_definition in spec.functions
        name = function_definition.name
        if !_is_identifier(name)
            throw(SpecValidationException("invalid user function name '$name'"))
        end
        if name in rule_labels
            throw(SpecValidationException("user function '$name' collides with rule label '$name'"))
        end
        if _is_reserved_runtime_symbol(name)
            throw(SpecValidationException("user function '$name' uses a reserved runtime symbol"))
        end
        if _is_lifecycle_marker_name(name)
            throw(SpecValidationException("user function '$name' collides with lifecycle marker '$name'"))
        end
        if _is_function_keyword(name) || _is_known_action_ir_call_name(name)
            throw(SpecValidationException("user function '$name' collides with built-in helper/control name '$name'"))
        end
        if function_definition.arity != length(function_definition.params)
            throw(SpecValidationException("user function '$name' arity does not match parameter count"))
        end

        seen_params = Set{String}()
        for param in function_definition.params
            if !_is_identifier(param)
                throw(SpecValidationException("user function '$name' has invalid parameter '$param'"))
            end
            if param in seen_params
                throw(SpecValidationException("duplicate parameter '$param' in function '$name'"))
            end
            push!(seen_params, param)
            if _is_reserved_runtime_symbol(param) || _is_lifecycle_marker_name(param) || _is_function_keyword(param)
                throw(SpecValidationException("user function '$name' parameter '$param' is reserved"))
            end
        end
    end
    return nothing
end

function _check_malformed_raw_body_lines(spec::SpecFile)
    for rule in spec.rules
        for element in rule.body
            kind = element.kind
            if kind isa RawBodyElementKind
                throw(SpecValidationException(
                    "rule '$(rule.header.label)': unrecognized body syntax at line $(element.line): $(kind.text)",
                ))
            end
        end
    end
    return nothing
end

function _check_mixed_edges(spec::SpecFile)
    for rule in spec.rules
        has_action = false
        has_blind = false
        for element in rule.body
            kind = element.kind
            if kind isa ActionEdgeBodyElementKind
                has_action = true
            elseif kind isa BlindEdgeBodyElementKind
                has_blind = true
            end
        end
        if has_action && has_blind
            throw(SpecValidationException(
                "rule '$(rule.header.label)' mixes action (->) and blind-call (=>) edges",
            ))
        end
    end
    return nothing
end

function _check_grouped_action_edges(spec::SpecFile)
    for rule in spec.rules
        for element in rule.body
            kind = element.kind
            if kind isa ActionEdgeBodyElementKind && length(kind.targets) > 1 && kind.code === nothing
                throw(SpecValidationException(
                    "rule '$(rule.header.label)': grouped action-edge targets require a shared code block",
                ))
            end
        end
    end
    return nothing
end

function _check_edge_targets(spec::SpecFile)
    rules_by_label = Dict(rule.header.label => rule for rule in spec.rules)
    for rule in spec.rules
        for element in rule.body
            kind = element.kind
            if kind isa ActionEdgeBodyElementKind
                for target in kind.targets
                    _check_target(rule, rules_by_label, target.label, target.index)
                end
            elseif kind isa BlindEdgeBodyElementKind
                _check_target(rule, rules_by_label, kind.target, 0)
            end
        end
    end
    return nothing
end

function _check_target(owner::Rule, rules_by_label::Dict{String,Rule}, target::String, index::Int)
    target_rule = get(rules_by_label, target, nothing)
    if target_rule === nothing
        throw(SpecValidationException("rule '$(owner.header.label)' references undefined rule '$target'"))
    end

    regex_count = _regex_count(target_rule)
    if index < 0 || index >= regex_count
        throw(SpecValidationException(
            "rule '$(owner.header.label)' references rule '$target' regex slot $index, but that rule has $regex_count regex slot(s)",
        ))
    end
    return nothing
end

function _regex_count(rule::Rule)
    count = 0
    for element in rule.body
        if element.kind isa RegexBodyElementKind
            count += 1
        end
    end
    return count
end

function _check_regex_syntax(spec::SpecFile)
    for rule in spec.rules
        for element in rule.body
            kind = element.kind
            if !(kind isa RegexBodyElementKind)
                continue
            end
            problem = _regex_structural_problem(kind.pattern)
            if problem !== nothing
                throw(SpecValidationException(
                    "rule '$(rule.header.label)': invalid regex pattern '/$(kind.pattern)/': $problem",
                ))
            end
        end
    end
    return nothing
end

function _regex_structural_problem(pattern::AbstractString)
    escaped = false
    in_class = false
    paren_depth = 0

    for char in pattern
        if escaped
            escaped = false
            continue
        end
        if char == '\\'
            escaped = true
            continue
        end

        if in_class
            if char == ']'
                in_class = false
            end
            continue
        end

        if char == '['
            in_class = true
        elseif char == '('
            paren_depth += 1
        elseif char == ')'
            paren_depth -= 1
            if paren_depth < 0
                return "unmatched closing parenthesis"
            end
        end
    end

    if escaped
        return "dangling escape"
    elseif in_class
        return "unclosed character class"
    elseif paren_depth != 0
        return "unbalanced parentheses"
    end
    return nothing
end

function _check_unused_rules(spec::SpecFile)
    used = Set{String}()
    for rule in spec.rules
        for element in rule.body
            kind = element.kind
            if kind isa ActionEdgeBodyElementKind
                for target in kind.targets
                    push!(used, target.label)
                end
            elseif kind isa BlindEdgeBodyElementKind
                push!(used, kind.target)
            end
        end
    end

    unused = [rule.header.label for rule in spec.rules if !(rule.header.label in used)]
    if !isempty(unused)
        throw(SpecValidationException("unused rule(s) in strict mode: $(join(unused, ", "))"))
    end
    return nothing
end

function _is_identifier(value::AbstractString)
    return occursin(r"^[A-Za-z_][A-Za-z0-9_]*$", value)
end

_is_function_keyword(name::AbstractString) = name == "fn" || name == "return"

function _is_lifecycle_marker_name(name::AbstractString)
    return name in _LIFECYCLE_MARKER_NAMES
end

function _is_reserved_runtime_symbol(name::AbstractString)
    return name in _RESERVED_RUNTIME_SYMBOLS
end

function _is_known_action_ir_call_name(name::AbstractString)
    return name in _KNOWN_ACTION_IR_CALL_NAMES
end

const _LIFECYCLE_MARKER_NAMES = Set{String}([
    "I",
    "LS",
    "LE",
    "E",
    "EX",
    "IT",
    "LX",
])

const _RESERVED_RUNTIME_SYMBOLS = Set{String}([
    "STRING",
    "descr",
    "minfo",
    "LSPOS",
    "LEPOS",
    "LMATCH",
    "LSMATCH",
    "IMATCH",
    "IMATCH_LIST",
    "LMATCH_LIST",
    "IMATCH_HASH",
    "LMATCH_HASH",
    "SELF",
    "this",
    "ctx",
    "runtime_ctx",
])

const _KNOWN_ACTION_IR_CALL_NAMES = Set{String}([
    "+",
    "-",
    "*",
    "/",
    "%",
    "==",
    "!=",
    ">",
    ">=",
    "<",
    "<=",
    "=",
    "abs",
    "add",
    "and",
    "array",
    "avg",
    "call",
    "capture_between",
    "capture_from",
    "capture_len_between",
    "capture_len_from",
    "capture_rest",
    "capture_rest_from",
    "capture_rest_len",
    "capture_rest_len_from",
    "capture_slice",
    "capture_slice_col",
    "capture_slice_len",
    "capture_slice_line",
    "capture_slice_pos",
    "capture_slice_until_cursor",
    "capture_slice_until_cursor_len",
    "capture_take",
    "capture_take_between",
    "capture_take_between_len",
    "capture_take_len",
    "capture_take_len_from",
    "capture_take_rest",
    "capture_take_rest_from",
    "capture_take_rest_len",
    "capture_take_rest_len_from",
    "capture_take_until_cursor",
    "capture_take_until_cursor_from",
    "capture_take_until_cursor_len",
    "capture_take_until_cursor_len_from",
    "capture_until_boundary",
    "capture_until_cursor_from",
    "capture_until_cursor_len_from",
    "case",
    "cat",
    "ceil",
    "clamp",
    "coalesce",
    "coalesce_nonempty",
    "concat_arrays",
    "contains",
    "contains_substr",
    "copy",
    "count",
    "count_keys",
    "cursor_col",
    "cursor_line",
    "cursor_pos",
    "cursor_rest",
    "cursor_rest_len",
    "default",
    "div",
    "drop_back",
    "drop_front",
    "drop_keys",
    "elif",
    "else",
    "elseif",
    "endcase",
    "endif",
    "ends_with",
    "endswitch",
    "entry_col",
    "entry_end_col",
    "entry_end_line",
    "entry_end_pos",
    "entry_group",
    "entry_groups",
    "entry_has",
    "entry_len",
    "entry_line",
    "entry_map",
    "entry_named",
    "entry_start_col",
    "entry_start_line",
    "entry_start_pos",
    "entry_text",
    "eq",
    "exit_now",
    "filter_match",
    "filter_nonempty",
    "first",
    "flat",
    "flat_array",
    "flat_hash",
    "floor",
    "ge",
    "gt",
    "has_key",
    "hash",
    "i",
    "if",
    "index_of",
    "input_end_col",
    "input_end_line",
    "input_end_pos",
    "input_len",
    "input_slice",
    "input_text",
    "is_defined",
    "is_empty",
    "is_nonempty",
    "is_undefined",
    "join_values",
    "last",
    "le",
    "length",
    "lowercase",
    "lowercase_each",
    "lt",
    "map_leaves",
    "mark_copy",
    "mark_exists",
    "mark_here",
    "mark_input_end",
    "mark_input_start",
    "mark_pos",
    "match_col",
    "match_end_col",
    "match_end_line",
    "match_end_pos",
    "match_group",
    "match_groups",
    "match_has",
    "match_len",
    "match_line",
    "match_map",
    "match_named",
    "match_start_col",
    "match_start_line",
    "match_start_pos",
    "match_text",
    "matches",
    "max",
    "median",
    "merge_hash",
    "min",
    "mod",
    "mul",
    "ne",
    "next",
    "not",
    "num_abs",
    "num_add",
    "num_avg",
    "num_ceil",
    "num_clamp",
    "num_div",
    "num_eq",
    "num_floor",
    "num_ge",
    "num_gt",
    "num_le",
    "num_lt",
    "num_max",
    "num_median",
    "num_min",
    "num_mod",
    "num_mul",
    "num_ne",
    "num_range",
    "num_round",
    "num_sub",
    "num_sum",
    "or",
    "otherwise",
    "pick_keys",
    "pop_back",
    "pop_front",
    "print",
    "print_each",
    "push",
    "push_back",
    "push_front",
    "range",
    "reduce_leaves",
    "rename_key",
    "replace_substr",
    "return",
    "return_undef",
    "restore_cursor",
    "rewind_entry_start",
    "rewind_match_start",
    "round",
    "rm_prefix",
    "rm_suffix",
    "save_cursor",
    "say",
    "set",
    "set_key",
    "slice",
    "sorted",
    "sorted_keys",
    "sorted_values",
    "split",
    "split_each",
    "split_tagged_records",
    "start_capture_slice",
    "starts_with",
    "str_eq",
    "str_ge",
    "str_gt",
    "str_le",
    "str_lt",
    "str_ne",
    "sub",
    "substr",
    "sum",
    "switch",
    "take",
    "take_last",
    "trim",
    "trim_each",
    "uniq",
    "uppercase",
    "uppercase_each",
    "walk_leaves",
    "when",
    "while",
    "with",
])
