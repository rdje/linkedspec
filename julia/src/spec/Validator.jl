struct SpecValidationException <: Exception
    message::String
end

Base.showerror(io::IO, error::SpecValidationException) = print(io, error.message)

function validate_spec(
    spec::SpecFile;
    strict_syntax::Bool = false,
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    if trace === nothing
        return _validate_spec(spec, strict_syntax)
    end

    scope = enter_trace_scope!(
        trace,
        "julia_frontend:validate_spec",
        "rules=$(length(spec.rules)) functions=$(length(spec.functions)) strict_syntax=$(strict_syntax ? 1 : 0)",
        LinkedSpecTraceLow,
    )
    exit_details = "status=error error=unknown"
    try
        _trace_validation_check!(trace, "top_rule_exists") do
            _check_top_rule_exists(spec)
        end
        _trace_validation_check!(trace, "duplicate_rule_labels") do
            _check_duplicate_rule_labels(spec)
        end
        _trace_validation_check!(trace, "duplicate_function_names") do
            _check_duplicate_function_names(spec)
        end
        _trace_validation_check!(trace, "function_registry") do
            _check_function_registry(spec)
        end
        _trace_validation_check!(trace, "malformed_raw_body_lines") do
            _check_malformed_raw_body_lines(spec)
        end
        _trace_validation_check!(trace, "mixed_edges") do
            _check_mixed_edges(spec)
        end
        _trace_validation_check!(trace, "grouped_action_edges") do
            _check_grouped_action_edges(spec)
        end
        _trace_validation_check!(trace, "edge_targets") do
            _check_edge_targets(spec)
        end
        _trace_validation_check!(trace, "regex_syntax") do
            _check_regex_syntax(spec)
        end
        if strict_syntax
            _trace_validation_check!(trace, "unused_rules") do
                _check_unused_rules(spec)
            end
        else
            trace_decision!(
                trace,
                "julia_frontend:validate_spec:unused_rules",
                false,
                "strict_syntax=0 skipped",
                LinkedSpecTraceMedium,
            )
        end
        exit_details = "status=ok"
        return nothing
    catch error
        exit_details = "status=error error=$(sprint(showerror, error))"
        rethrow()
    finally
        exit_trace_scope!(trace, scope, exit_details)
    end
end

function _validate_spec(spec::SpecFile, strict_syntax::Bool)
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

function _trace_validation_check!(operation::Function, trace::LinkedSpecTraceEmitter, name::String)
    try
        operation()
        trace_decision!(
            trace,
            "julia_frontend:validate_spec:$name",
            true,
            "pass",
            LinkedSpecTraceMedium,
        )
        return nothing
    catch error
        trace_decision!(
            trace,
            "julia_frontend:validate_spec:$name",
            false,
            "error=$(sprint(showerror, error))",
            LinkedSpecTraceMedium,
        )
        rethrow()
    end
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
    return is_known_action_ir_call_name(name)
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
