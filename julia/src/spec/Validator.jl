struct SpecPortableDiagnostic
    code::String
    stage::String
    message::String
    fields::Dict{String,Any}
end

function SpecPortableDiagnostic(; code, stage, message, fields = Dict{String,Any}())
    return SpecPortableDiagnostic(
        String(code),
        String(stage),
        String(message),
        Dict{String,Any}(String(key) => value for (key, value) in fields),
    )
end

struct SpecValidationException <: Exception
    message::String
    diagnostic::Union{Nothing,SpecPortableDiagnostic}
end

SpecValidationException(message::AbstractString; diagnostic = nothing) =
    SpecValidationException(String(message), diagnostic)

Base.showerror(io::IO, error::SpecValidationException) = print(io, error.message)

to_json(diagnostic::SpecPortableDiagnostic) = Dict{String,Any}(
    "code" => diagnostic.code,
    "stage" => diagnostic.stage,
    "message" => diagnostic.message,
    "fields" => diagnostic.fields,
)

function from_json(::Type{SpecPortableDiagnostic}, json)
    object = _ast_object(json, "portable spec diagnostic")
    raw_fields = _ast_object(get(object, "fields", nothing), "fields")
    return SpecPortableDiagnostic(
        code = _ast_string(object, "code"),
        stage = _ast_string(object, "stage"),
        message = _ast_string(object, "message"),
        fields = Dict{String,Any}(
            String(key) => _plain_json(value) for (key, value) in raw_fields
        ),
    )
end

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
        _trace_validation_check!(trace, "at_least_one_rule") do
            _check_at_least_one_rule(spec)
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
        _trace_validation_check!(trace, "edge_structure") do
            _check_edge_structure(spec)
        end
        _trace_validation_check!(trace, "mixed_edges") do
            _check_mixed_edges(spec)
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
    _check_at_least_one_rule(spec)
    _check_duplicate_rule_labels(spec)
    _check_duplicate_function_names(spec)
    _check_function_registry(spec)
    _check_malformed_raw_body_lines(spec)
    _check_edge_structure(spec)
    _check_mixed_edges(spec)
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

function _check_at_least_one_rule(spec::SpecFile)
    if !isempty(spec.rules)
        return nothing
    end
    diagnostic = SpecPortableDiagnostic(
        code = "no_rules_defined",
        stage = "validate_spec",
        message = "spec does not define any rules",
    )
    throw(SpecValidationException(diagnostic.message; diagnostic = diagnostic))
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

        signature = function_definition.signature
        if signature !== nothing
            if signature.kind != "callable_signature" || signature.version != 1
                throw(SpecValidationException("user function '$name' has unsupported callable signature"))
            end
            if signature.positional_params != function_definition.params ||
                    signature.min_arity != function_definition.arity || signature.max_arity !== nothing
                throw(SpecValidationException("user function '$name' has inconsistent callable signature"))
            end
            if !_is_identifier(signature.rest_param)
                throw(SpecValidationException("user function '$name' has invalid rest parameter '$(signature.rest_param)'"))
            end
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
        if signature !== nothing
            rest_param = signature.rest_param
            if rest_param in seen_params
                throw(SpecValidationException("duplicate parameter '$rest_param' in function '$name'"))
            end
            if _is_reserved_runtime_symbol(rest_param) || _is_lifecycle_marker_name(rest_param) || _is_function_keyword(rest_param)
                throw(SpecValidationException("user function '$name' parameter '$rest_param' is reserved"))
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

function _portable_validation_exception(; code, stage, message, fields)
    diagnostic = SpecPortableDiagnostic(
        code = code,
        stage = stage,
        message = message,
        fields = fields,
    )
    return SpecValidationException(diagnostic.message; diagnostic = diagnostic)
end

function _grouped_action_exception(rule::Rule, targets)
    labels = [target.label for target in targets]
    return _portable_validation_exception(
        code = "grouped_action_shared_block_required",
        stage = "validate_rule",
        message = "rule '$(rule.header.label)': grouped action-edge targets require a shared code block",
        fields = Dict{String,Any}(
            "rule_label" => rule.header.label,
            "targets" => labels,
        ),
    )
end

function _check_edge_structure(spec::SpecFile)
    declared_labels = Set(rule.header.label for rule in spec.rules)

    for rule in spec.rules
        for element in rule.body
            kind = element.kind
            if kind isa BareEdgeBodyElementKind
                for target in kind.targets
                    if !(target.label in declared_labels)
                        throw(_portable_validation_exception(
                            code = "bare_edge_target_undefined",
                            stage = "normalize_edges",
                            message = "bare edge in rule '$(rule.header.label)' targets undefined rule '$(target.label)'",
                            fields = Dict{String,Any}(
                                "rule_label" => rule.header.label,
                                "target" => target.label,
                            ),
                        ))
                    end
                end

                if is_and(rule.header.mode)
                    indexed = findfirst(target -> target.index !== nothing, kind.targets)
                    if indexed !== nothing
                        target = kind.targets[indexed]
                        throw(_portable_validation_exception(
                            code = "bare_edge_index_requires_action",
                            stage = "normalize_edges",
                            message = "indexed bare edge in AND rule '$(rule.header.label)' requires explicit action ownership",
                            fields = Dict{String,Any}(
                                "rule_label" => rule.header.label,
                                "target" => target.label,
                                "regex_index" => target.index,
                            ),
                        ))
                    end
                    if length(kind.targets) > 1
                        throw(_portable_validation_exception(
                            code = "bare_edge_group_requires_action",
                            stage = "normalize_edges",
                            message = "grouped bare edge in AND rule '$(rule.header.label)' requires explicit action ownership",
                            fields = Dict{String,Any}(
                                "rule_label" => rule.header.label,
                                "targets" => [target.label for target in kind.targets],
                            ),
                        ))
                    end
                elseif length(kind.targets) > 1 && kind.code === nothing
                    throw(_grouped_action_exception(rule, kind.targets))
                end
            elseif kind isa ActionEdgeBodyElementKind
                if length(kind.targets) > 1 && kind.code === nothing
                    throw(_grouped_action_exception(rule, kind.targets))
                end
            elseif kind isa BlindEdgeBodyElementKind && kind.index !== nothing
                throw(_portable_validation_exception(
                    code = "blind_call_index_forbidden",
                    stage = "validate_rule",
                    message = "blind-call target '$(kind.target)' in rule '$(rule.header.label)' cannot select a regex index",
                    fields = Dict{String,Any}(
                        "rule_label" => rule.header.label,
                        "target" => kind.target,
                        "regex_index" => kind.index,
                    ),
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
            elseif kind isa BareEdgeBodyElementKind
                if is_and(rule.header.mode)
                    has_blind = true
                else
                    has_action = true
                end
            end
        end
        if has_action && has_blind
            throw(_portable_validation_exception(
                code = "mixed_edge_ownership",
                stage = "validate_rule",
                message = "rule '$(rule.header.label)' mixes action and blind edge ownership",
                fields = Dict{String,Any}(
                    "rule_label" => rule.header.label,
                    "ownerships" => ["action", "blind"],
                ),
            ))
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
                    _check_target(
                        rule,
                        rules_by_label,
                        target.label,
                        target.index;
                        structural_action = true,
                    )
                end
            elseif kind isa BlindEdgeBodyElementKind
                _check_target(rule, rules_by_label, kind.target, 0)
            elseif kind isa BareEdgeBodyElementKind
                for target in kind.targets
                    _check_target(
                        rule,
                        rules_by_label,
                        target.label,
                        something(target.index, 0);
                        structural_action = !is_and(rule.header.mode),
                    )
                end
            end
        end
    end
    return nothing
end

function _check_target(
    owner::Rule,
    rules_by_label::Dict{String,Rule},
    target::String,
    index::Int;
    structural_action::Bool = false,
)
    target_rule = get(rules_by_label, target, nothing)
    if target_rule === nothing
        if structural_action
            throw(_portable_validation_exception(
                code = "regex_slot_identity_invalid",
                stage = "validate_compiled_rule",
                message = "rule '$(owner.header.label)' references undefined rule '$target' for regex slot $index; that structural slot does not exist",
                fields = Dict{String,Any}(
                    "rule_label" => owner.header.label,
                    "target_rule" => target,
                    "regex_index" => index,
                ),
            ))
        end
        throw(SpecValidationException("rule '$(owner.header.label)' references undefined rule '$target'"))
    end

    regex_count = _regex_count(target_rule)
    if index < 0 || index >= regex_count
        if structural_action
            throw(_portable_validation_exception(
                code = "regex_slot_identity_invalid",
                stage = "validate_compiled_rule",
                message = "rule '$(owner.header.label)' references rule '$target' regex slot $index, but that structural slot does not exist",
                fields = Dict{String,Any}(
                    "rule_label" => owner.header.label,
                    "target_rule" => target,
                    "regex_index" => index,
                ),
            ))
        end
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
            elseif kind isa BareEdgeBodyElementKind
                for target in kind.targets
                    push!(used, target.label)
                end
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
