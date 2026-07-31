# FUTURE-PARITY-BACKLOG.10.6.4.1-.2 — private typed calls and provenance.

struct _SemanticCallDefinition
    id::String
    start_byte::Int
    function_index::Union{Nothing,Int}
    rule_label::Union{Nothing,String}
end

struct _SemanticCallActionOwner
    owner_id::String
    block::ActionBlock
    source::_SemanticStaticSourceRange
end

struct _SemanticCallSite
    name::String
    range::_SemanticStaticSourceRange
end

mutable struct _SemanticCallCursor
    sites::Vector{_SemanticCallSite}
    next::Int
end

struct _SemanticCallHelperContract
    parameters::Tuple
    effects::Tuple
    return_kind::String
end

struct _SemanticCallEmitted
    id::String
    source::String
    range::_SemanticStaticSourceRange
end

mutable struct _SemanticCallBuilder
    source_text::String
    source_map::_SemanticSourceMap
    logical_name::String
    content_digest::String
    source_refs::Dict{String,Any}
    records::Vector{Dict{String,Any}}
    relations::Vector{Dict{String,Any}}
    function_registry::UserFunctionRegistry
    function_shapes::Dict{String,Dict{String,Any}}
    helper_ids::Dict{String,String}
    binding_by_owner_name::Dict{Tuple{String,String},String}
    binding_counts::Dict{Tuple{String,String},Int}
    edge_value_shapes::Dict{String,Dict{String,Any}}
    global_call_order::Int
end

const _SEMANTIC_CALL_HELPERS = Dict{String,_SemanticCallHelperContract}(
    "trim" => _SemanticCallHelperContract(
        ("value" => "value",),
        (),
        "string",
    ),
    "match_text" => _SemanticCallHelperContract(
        (),
        ("reads_runtime_match",),
        "string",
    ),
    "return" => _SemanticCallHelperContract(
        ("value" => "value",),
        ("returns_owner",),
        "unknown",
    ),
)

function _semantic_call_extend_core!(;
    source_text::String,
    source_map::_SemanticSourceMap,
    logical_name::String,
    content_digest::String,
    scans_by_label::Dict{String,_SemanticStaticScannedRule},
    compiled::CompiledSpec,
    entry_selection::Union{Nothing,SemanticEntrySelection},
    generated_plan::Union{Nothing,SemanticGeneratedPlanInput},
    source_refs::Dict{String,Any},
    records::Vector{Dict{String,Any}},
    relations::Vector{Dict{String,Any}},
)
    functions = compiled.function_registry.entries
    isempty(functions) && return nothing

    typed_blocks = Dict{String,ActionBlock}(
        entry.definition.name => _semantic_call_typed_function_body(
            entry,
            compiled.function_registry,
        ) for entry in functions
    )
    function_shapes = _semantic_call_infer_function_shapes(functions, typed_blocks)
    function_ranges = [
        _semantic_call_function_range(source_text, source_map, entry) for entry in functions
    ]
    definitions = _SemanticCallDefinition[]

    for (index, entry) in enumerate(functions)
        function_id = _semantic_call_function_id(entry.definition.name)
        range = function_ranges[index]
        push!(definitions, _SemanticCallDefinition(
            function_id,
            range.start,
            index,
            nothing,
        ))
        function_source = _semantic_call_add_function!(
            source_text = source_text,
            source_map = source_map,
            logical_name = logical_name,
            content_digest = content_digest,
            source_refs = source_refs,
            records = records,
            relations = relations,
            entry = entry,
            function_order = index - 1,
            declaration_order = length(compiled.compiled_rule_order) + index - 1,
            range = range,
            return_shape = function_shapes[entry.definition.name],
        )
        _semantic_call_add_staged_artifacts!(
            entry = entry,
            function_id = function_id,
            function_source = function_source,
            records = records,
            relations = relations,
        )
    end
    for label in compiled.compiled_rule_order
        rule_id = _semantic_static_rule_id(label)
        push!(definitions, _SemanticCallDefinition(
            rule_id,
            _semantic_call_source_start(source_refs, rule_id),
            nothing,
            String(label),
        ))
    end
    sort!(definitions; by = definition -> (definition.start_byte, definition.id))

    spec_record = only(record for record in records if record["id"] == _SEMANTIC_SPEC_ID)
    spec_record["facts"]["definition_order"] = [definition.id for definition in definitions]

    builder = _SemanticCallBuilder(
        source_text,
        source_map,
        logical_name,
        content_digest,
        source_refs,
        records,
        relations,
        compiled.function_registry,
        function_shapes,
        Dict{String,String}(),
        Dict{Tuple{String,String},String}(),
        Dict{Tuple{String,String},Int}(),
        Dict{String,Dict{String,Any}}(),
        0,
    )
    action_owners = _semantic_call_action_owners(scans_by_label, compiled)

    for definition in definitions
        function_index = definition.function_index
        if function_index !== nothing
            entry = functions[function_index]
            body_range = _semantic_call_function_body_range(source_text, source_map, entry)
            cursor = _SemanticCallCursor(
                _semantic_call_scan_sites(source_text, body_range),
                1,
            )
            local_order = Ref(0)
            variables = _semantic_call_function_variables(entry)
            function_id = _semantic_call_function_id(entry.definition.name)
            for statement in typed_blocks[entry.definition.name].statements
                expression = statement.expr
                if expression isa ActionCallExpr && expression.name == "return"
                    for argument in expression.args
                        _semantic_call_emit_expression!(
                            builder,
                            argument.value,
                            function_id,
                            cursor,
                            local_order,
                            variables,
                            true,
                        )
                    end
                else
                    _semantic_call_emit_statement!(
                        builder,
                        expression,
                        function_id,
                        cursor,
                        local_order,
                        variables,
                        true,
                    )
                end
            end
            continue
        end

        rule_id = _semantic_static_rule_id(something(definition.rule_label))
        prefix = "edge:$rule_id:"
        for owner in action_owners
            startswith(owner.owner_id, prefix) || continue
            cursor = _SemanticCallCursor(
                _semantic_call_scan_sites(source_text, owner.source),
                1,
            )
            local_order = Ref(0)
            variables = Dict{String,Dict{String,Any}}()
            for statement in owner.block.statements
                _semantic_call_emit_statement!(
                    builder,
                    statement.expr,
                    owner.owner_id,
                    cursor,
                    local_order,
                    variables,
                    false,
                )
            end
        end
    end
    _semantic_call_apply_edge_shapes!(builder)
    _semantic_call_add_generated_plan!(
        logical_name = logical_name,
        compiled = compiled,
        entry_selection = entry_selection,
        generated_plan = generated_plan,
        records = records,
        relations = relations,
    )
    return nothing
end

function _semantic_call_add_function!(;
    source_text,
    source_map,
    logical_name,
    content_digest,
    source_refs,
    records,
    relations,
    entry,
    function_order,
    declaration_order,
    range,
    return_shape,
)
    definition = entry.definition
    function_id = _semantic_call_function_id(definition.name)
    source = _semantic_static_register_source!(
        source_refs,
        function_id,
        range,
        source_text,
        source_map,
        logical_name,
        content_digest,
    )
    signature = _semantic_call_function_signature(definition)
    push!(records, _semantic_static_record(
        id = function_id,
        kind = "function",
        name = definition.name,
        owner_id = _SEMANTIC_SPEC_ID,
        order = function_order,
        source = source,
        facts = Dict{String,Any}(
            "signature" => signature,
            "parameter_kinds" => Any[
                parameter["kind"] for parameter in signature["parameters"]
            ],
            "return_shape" => return_shape,
        ),
    ))
    push!(relations, _semantic_static_relation(
        kind = "declares",
        from_id = _SEMANTIC_SPEC_ID,
        to_id = function_id,
        order = declaration_order,
        source = source,
    ))
    return source
end

function _semantic_call_add_staged_artifacts!(;
    entry::UserFunctionEntry,
    function_id::String,
    function_source::String,
    records::Vector{Dict{String,Any}},
    relations::Vector{Dict{String,Any}},
)
    _semantic_call_validate_staged_authority(entry)
    definition = entry.definition
    rows = (
        ("payload", "action_source", "string"),
        ("parse_job", "action_program", "unknown"),
        ("result", "action_program", "unknown"),
    )
    ids = Dict{String,String}()
    for (offset, row) in enumerate(rows)
        order = offset - 1
        artifact_kind, node_kind, shape_kind = row
        id = "staged:$artifact_kind:$function_id:$order"
        ids[artifact_kind] = id
        name_suffix = artifact_kind == "parse_job" ? "parse job" : artifact_kind
        push!(records, _semantic_static_record(
            id = id,
            kind = "staged_artifact",
            name = "$(definition.name) body $name_suffix",
            owner_id = function_id,
            order = order,
            source = function_source,
            facts = Dict{String,Any}(
                "artifact_kind" => artifact_kind,
                "payload_kind" => "function_body",
                "node_kind" => node_kind,
                "parent_path" => Any[function_id],
                "parser_spec_id" => "linkedspec-action-v1",
                "top_rule" => "FunctionBody",
                "result_policy" => "typed_action_program",
                "failure_policy" => "compile_diagnostic",
                "status" => "succeeded",
                "value_shape" => _semantic_static_value_shape(shape_kind),
            ),
        ))
        push!(relations, _semantic_static_relation(
            kind = "contains",
            from_id = function_id,
            to_id = id,
            order = order,
            source = function_source,
        ))
    end

    push!(relations, _semantic_static_relation(
        kind = "lowered_from",
        from_id = ids["payload"],
        to_id = _SEMANTIC_SOURCE_ID,
        order = 0,
        source = function_source,
    ))
    push!(relations, _semantic_static_relation(
        kind = "consumes",
        from_id = ids["parse_job"],
        to_id = ids["payload"],
        order = 0,
        source = function_source,
    ))
    push!(relations, _semantic_static_relation(
        kind = "produces",
        from_id = ids["parse_job"],
        to_id = ids["result"],
        order = 0,
        source = function_source,
    ))
    push!(relations, _semantic_static_relation(
        kind = "lowered_from",
        from_id = ids["result"],
        to_id = ids["payload"],
        order = 0,
        source = function_source,
    ))
    push!(relations, _semantic_static_relation(
        kind = "staged_by",
        from_id = ids["result"],
        to_id = ids["parse_job"],
        order = 0,
        source = function_source,
    ))
    return nothing
end

function _semantic_call_validate_staged_authority(entry::UserFunctionEntry)
    definition = entry.definition
    payload = definition.body_payload
    job = definition.body_parse_job
    expected_path = Any["functions", string(entry.index), "body_source"]
    if !(payload isa AbstractDict) || job === nothing
        throw(_semantic_call_correlation_error(
            "Compiled function has no staged payload/job authority",
            definition.name,
        ))
    end
    if get(payload, "kind", nothing) != "staged_payload" ||
       get(payload, "node_kind", nothing) != "function_definition" ||
       get(payload, "payload_kind", nothing) != "function_body" ||
       !_semantic_call_plain_equal(get(payload, "parent_ast_path", nothing), expected_path) ||
       get(payload, "function_name", nothing) != definition.name ||
       get(payload, "text", nothing) != definition.body_source ||
       !_semantic_call_plain_equal(get(payload, "source_span", nothing), to_json(job.source_span)) ||
       job.node_kind != "function_definition" ||
       job.payload_kind != "function_body" ||
       !_semantic_call_plain_equal(job.parent_ast_path, expected_path) ||
       isempty(job.job_id) ||
       job.function_name != definition.name ||
       job.text != definition.body_source ||
       job.parser_spec_id != "actionir-body.spec" ||
       job.top_rule != "action_block" ||
       job.result_policy != "replace_field" ||
       job.result_field != "body_ast" ||
       job.failure_policy != "fail" ||
       job.diagnostic_owner != "function_body" ||
       definition.body_ast === nothing
        throw(_semantic_call_correlation_error(
            "Native staged function metadata does not match its typed owner",
            definition.name,
        ))
    end

    signature = definition.signature
    signature_matches = if signature === nothing
        !haskey(payload, "signature") &&
        _semantic_call_plain_equal(get(payload, "params", nothing), definition.params) &&
        get(payload, "arity", nothing) == definition.arity &&
        job.signature === nothing &&
        job.params == definition.params &&
        job.arity == definition.arity
    else
        !haskey(payload, "params") &&
        !haskey(payload, "arity") &&
        _semantic_call_plain_equal(get(payload, "signature", nothing), to_json(signature)) &&
        job.signature == signature &&
        job.params === nothing &&
        job.arity === nothing
    end
    signature_matches || throw(_semantic_call_correlation_error(
        "Native staged function signature does not match its typed owner",
        definition.name,
    ))
    return nothing
end

function _semantic_call_add_generated_plan!(;
    logical_name::String,
    compiled::CompiledSpec,
    entry_selection::Union{Nothing,SemanticEntrySelection},
    generated_plan::Union{Nothing,SemanticGeneratedPlanInput},
    records::Vector{Dict{String,Any}},
    relations::Vector{Dict{String,Any}},
)
    if entry_selection === nothing || generated_plan === nothing
        throw(_semantic_call_correlation_error(
            "Compiled call projection has no entry/generated-plan authority",
            _SEMANTIC_SPEC_ID,
        ))
    end
    labels = String[row.label for row in generated_plan.rows]
    if generated_plan.contract_id != GENERATED_SOURCE_CONTRACT ||
       generated_plan.format_version != GENERATED_SOURCE_FORMAT ||
       generated_plan.source_identity != logical_name ||
       labels != compiled.compiled_rule_order
        throw(_semantic_call_correlation_error(
            "Retained generated plan does not match compiled semantic authority",
            _SEMANTIC_SPEC_ID,
        ))
    end
    selected = [row for row in generated_plan.rows if row.label == entry_selection.label]
    length(selected) == 1 || throw(_semantic_call_correlation_error(
        "Generated plan has no unique selected entry row",
        entry_selection.label;
        fields = Dict{String,Any}("selected_rows" => length(selected)),
    ))

    id = "generated:handler_plan:0"
    push!(records, _semantic_static_record(
        id = id,
        kind = "generated_artifact",
        name = "handler plan",
        owner_id = _SEMANTIC_SPEC_ID,
        order = 0,
        source = nothing,
        facts = Dict{String,Any}(
            "artifact_kind" => "handler_plan",
            "contract_id" => generated_plan.contract_id,
            "format_version" => generated_plan.format_version,
            "plan_family" => only(selected).family,
        ),
    ))
    push!(relations, _semantic_static_relation(
        kind = "generated_as",
        from_id = _SEMANTIC_SPEC_ID,
        to_id = id,
        order = 0,
        source = nothing,
    ))
    return nothing
end

function _semantic_call_emit_statement!(
    builder::_SemanticCallBuilder,
    expression::ActionExpr,
    owner_id::String,
    cursor::_SemanticCallCursor,
    local_order::Base.RefValue{Int},
    variables::Dict{String,Dict{String,Any}},
    function_surface::Bool,
)
    if expression isa ActionAssignScalarExpr
        shape = _semantic_call_expression_shape(
            expression.value,
            variables,
            builder.function_shapes,
        )
        emitted = _semantic_call_emit_expression!(
            builder,
            expression.value,
            owner_id,
            cursor,
            local_order,
            variables,
            function_surface,
        )
        variables[expression.name] = shape
        key = (owner_id, expression.name)
        binding_order = get(builder.binding_counts, key, 0)
        builder.binding_counts[key] = binding_order + 1
        binding_id = "binding:$owner_id:$(_semantic_static_escape_name(expression.name)):$binding_order"
        source = emitted === nothing ? nothing : _semantic_static_register_source!(
            builder.source_refs,
            binding_id,
            emitted.range,
            builder.source_text,
            builder.source_map,
            builder.logical_name,
            builder.content_digest,
        )
        push!(builder.records, _semantic_static_record(
            id = binding_id,
            kind = "binding",
            name = expression.name,
            owner_id = owner_id,
            order = binding_order,
            source = source,
            facts = Dict{String,Any}(
                "scope" => "action",
                "value_shape" => shape,
                "mutable" => true,
            ),
        ))
        builder.binding_by_owner_name[key] = binding_id
        if emitted !== nothing
            push!(builder.relations, _semantic_static_relation(
                kind = "writes",
                from_id = emitted.id,
                to_id = binding_id,
                order = 0,
                source = emitted.source,
            ))
        end
        return nothing
    end

    if !function_surface && expression isa ActionCallExpr && expression.name == "return"
        builder.edge_value_shapes[owner_id] = _semantic_call_expression_shape(
            expression,
            variables,
            builder.function_shapes,
        )
    end
    _semantic_call_emit_expression!(
        builder,
        expression,
        owner_id,
        cursor,
        local_order,
        variables,
        function_surface,
    )
    return nothing
end

function _semantic_call_emit_expression!(
    builder::_SemanticCallBuilder,
    expression::ActionExpr,
    owner_id::String,
    cursor::_SemanticCallCursor,
    local_order::Base.RefValue{Int},
    variables::Dict{String,Dict{String,Any}},
    function_surface::Bool,
)
    if expression isa ActionAssignScalarExpr
        return _semantic_call_emit_expression!(
            builder,
            expression.value,
            owner_id,
            cursor,
            local_order,
            variables,
            function_surface,
        )
    elseif expression isa ActionCallExpr
        return _semantic_call_emit_call!(
            builder,
            expression,
            owner_id,
            cursor,
            local_order,
            variables,
            function_surface,
        )
    end

    _semantic_call_visit_children!(
        builder,
        expression,
        owner_id,
        cursor,
        local_order,
        variables,
        function_surface,
    )
    return nothing
end

function _semantic_call_emit_call!(
    builder::_SemanticCallBuilder,
    expression::ActionCallExpr,
    owner_id::String,
    cursor::_SemanticCallCursor,
    local_order::Base.RefValue{Int},
    variables::Dict{String,Dict{String,Any}},
    function_surface::Bool,
)
    range = _semantic_call_take!(cursor, expression.name, owner_id)
    order = local_order[]
    local_order[] += 1
    call_id = "call:$owner_id:$order"
    source = _semantic_static_register_source!(
        builder.source_refs,
        call_id,
        range,
        builder.source_text,
        builder.source_map,
        builder.logical_name,
        builder.content_digest,
    )
    argument_shapes = Any[
        _semantic_call_expression_shape(
            argument.value,
            variables,
            builder.function_shapes,
        ) for argument in expression.args
    ]
    resolution = resolve_user_function_call(
        builder.function_registry,
        expression.name,
        length(expression.args),
    )
    function_entry = resolution.entry
    helper = get(_SEMANTIC_CALL_HELPERS, expression.name, nothing)
    resolution_kind = if function_entry !== nothing
        "user_function"
    elseif helper !== nothing
        "helper"
    else
        "unresolved"
    end
    return_shape = if function_entry !== nothing
        builder.function_shapes[expression.name]
    elseif expression.name == "return" && !isempty(argument_shapes)
        first(argument_shapes)
    elseif helper !== nothing
        _semantic_static_value_shape(helper.return_kind)
    else
        _semantic_static_value_shape("unknown")
    end
    push!(builder.records, _semantic_static_record(
        id = call_id,
        kind = "call",
        name = expression.name,
        owner_id = owner_id,
        order = builder.global_call_order,
        source = source,
        facts = Dict{String,Any}(
            "call_form" => "function",
            "resolution_kind" => resolution_kind,
            "argument_shapes" => argument_shapes,
            "return_shape" => return_shape,
            "target_shape" => _semantic_static_value_shape(
                resolution_kind == "unresolved" ? "unknown" : resolution_kind,
            ),
        ),
    ))
    builder.global_call_order += 1

    if function_entry !== nothing
        _semantic_call_add_function_resolution!(
            builder,
            call_id,
            source,
            function_entry,
            argument_shapes,
            return_shape,
        )
    elseif helper !== nothing
        helper_id = _semantic_call_ensure_helper!(builder, expression.name, helper)
        push!(builder.relations, _semantic_static_relation(
            kind = "resolves_to",
            from_id = call_id,
            to_id = helper_id,
            order = 0,
            source = source,
            evidence_ids = function_surface ? Any[owner_id] : Any[],
        ))
    end

    if expression.name == "return"
        for argument in expression.args
            value = argument.value
            value isa ActionVariableExpr || continue
            binding_id = get(
                builder.binding_by_owner_name,
                (owner_id, value.name),
                nothing,
            )
            binding_id === nothing && continue
            push!(builder.relations, _semantic_static_relation(
                kind = "reads",
                from_id = call_id,
                to_id = binding_id,
                order = 0,
                source = source,
            ))
        end
    end

    for argument in expression.args
        _semantic_call_emit_expression!(
            builder,
            argument.value,
            owner_id,
            cursor,
            local_order,
            variables,
            function_surface,
        )
    end
    return _SemanticCallEmitted(call_id, source, range)
end

function _semantic_call_visit_children!(
    builder,
    expression,
    owner_id,
    cursor,
    local_order,
    variables,
    function_surface,
)
    visit(value) = _semantic_call_emit_expression!(
        builder,
        value,
        owner_id,
        cursor,
        local_order,
        variables,
        function_surface,
    )
    visit_args(arguments) = foreach(argument -> visit(argument.value), arguments)
    visit_block(block) = block === nothing ? nothing :
                         foreach(statement -> visit(statement.expr), block.statements)

    if expression isa ActionArrayLiteralExpr
        foreach(visit, expression.items)
    elseif expression isa ActionHashLiteralExpr
        for entry in expression.entries
            visit(entry.key)
            visit(entry.value)
        end
    elseif expression isa ActionBlockValueExpr
        visit_block(expression.block)
    elseif expression isa ActionIndexedVarExpr
        visit(expression.index)
    elseif expression isa ActionAssignArrayAppendExpr
        visit(expression.value)
    elseif expression isa ActionAssignHashIndexExpr
        visit(expression.key)
        visit(expression.value)
    elseif expression isa ActionAssignNestedAccessExpr
        for segment in expression.segments
            segment isa ActionIndexAccessSegment && visit(segment.expr)
        end
        visit(expression.value)
    elseif expression isa ActionFluentChainExpr
        visit(expression.receiver)
        for call in expression.calls
            visit_args(call.args)
        end
    elseif expression isa ActionControlIfExpr
        visit(expression.condition)
        visit_args(expression.args)
        visit_block(expression.body)
    elseif expression isa ActionControlElseExpr
        visit_args(expression.args)
        visit_block(expression.body)
    elseif expression isa ActionControlMarkerExpr
        visit_args(expression.args)
    elseif expression isa ActionControlWhileExpr
        visit(expression.condition)
        visit_args(expression.args)
        visit_block(expression.body)
    elseif expression isa ActionControlSwitchExpr
        visit(expression.source_expr)
        visit_args(expression.args)
        visit_block(expression.body)
        foreach(visit, expression.cases)
        expression.default_case === nothing || visit(expression.default_case)
    elseif expression isa ActionControlCaseExpr
        visit(expression.match)
        visit_args(expression.args)
        visit_block(expression.body)
    elseif expression isa ActionControlDefaultExpr
        visit_args(expression.args)
        visit_block(expression.body)
    elseif expression isa ActionNestedAccessExpr
        for segment in expression.segments
            segment isa ActionIndexAccessSegment && visit(segment.expr)
        end
    elseif expression isa ActionValueAccessExpr
        visit(expression.receiver)
        for segment in expression.segments
            segment isa ActionIndexAccessSegment && visit(segment.expr)
        end
    end
    return nothing
end

function _semantic_call_ensure_helper!(
    builder::_SemanticCallBuilder,
    name::String,
    contract::_SemanticCallHelperContract,
)
    existing = get(builder.helper_ids, name, nothing)
    existing !== nothing && return existing
    helper_id = "helper:$(_semantic_static_escape_name(name))"
    order = length(builder.helper_ids)
    builder.helper_ids[name] = helper_id
    push!(builder.records, _semantic_static_record(
        id = helper_id,
        kind = "helper",
        name = name,
        owner_id = nothing,
        order = order,
        source = nothing,
        facts = Dict{String,Any}(
            "signature" => _semantic_call_signature(contract.parameters),
            "effects" => Any[contract.effects...],
            "return_shape" => _semantic_static_value_shape(contract.return_kind),
        ),
    ))
    return helper_id
end

function _semantic_call_add_function_resolution!(
    builder::_SemanticCallBuilder,
    call_id::String,
    source::String,
    entry::UserFunctionEntry,
    argument_shapes::Vector,
    return_shape::Dict{String,Any},
)
    definition = entry.definition
    target_id = _semantic_call_function_id(definition.name)
    decision_id = "decision:call:$call_id"
    exact_id = "explanation:$decision_id:0"
    signature_id = "explanation:$decision_id:1"
    push!(builder.records, _semantic_static_record(
        id = decision_id,
        kind = "decision",
        name = "$(definition.name) call resolution",
        owner_id = call_id,
        order = 0,
        source = source,
        facts = Dict{String,Any}(
            "decision_kind" => "call_resolution",
            "outcome" => target_id,
        ),
    ))
    push!(builder.records, _semantic_static_record(
        id = exact_id,
        kind = "explanation_step",
        name = nothing,
        owner_id = decision_id,
        order = 0,
        source = source,
        facts = Dict{String,Any}(
            "rule_code" => "call_exact_user_function",
            "summary" => "The exact user-function name $(definition.name) is registered.",
            "input_ids" => Any[call_id, target_id],
            "output_fact" => Dict{String,Any}(
                "record_id" => call_id,
                "path" => "/facts/resolution_kind",
                "value" => "user_function",
            ),
        ),
    ))
    count = length(argument_shapes)
    count_words = count == 1 ? "one" : string(count)
    shape_words = count == 1 ?
                  "$(_semantic_call_shape_kind(first(argument_shapes))) argument" :
                  "arguments"
    signature_text = join(_semantic_call_signature_names(definition), ", ")
    push!(builder.records, _semantic_static_record(
        id = signature_id,
        kind = "explanation_step",
        name = nothing,
        owner_id = decision_id,
        order = 1,
        source = source,
        facts = Dict{String,Any}(
            "rule_code" => "call_signature_accepts",
            "summary" => "The $count_words supplied $shape_words satisfies $(definition.name)($signature_text).",
            "input_ids" => Any[call_id, target_id],
            "output_fact" => Dict{String,Any}(
                "record_id" => call_id,
                "path" => "/facts/return_shape/kind",
                "value" => _semantic_call_shape_kind(return_shape),
            ),
        ),
    ))
    append!(builder.relations, [
        _semantic_static_relation(
            kind = "calls",
            from_id = call_id,
            to_id = target_id,
            order = 0,
            source = source,
        ),
        _semantic_static_relation(
            kind = "resolves_to",
            from_id = call_id,
            to_id = target_id,
            order = 0,
            source = source,
            evidence_ids = Any[decision_id],
        ),
        _semantic_static_relation(
            kind = "explained_by",
            from_id = decision_id,
            to_id = exact_id,
            order = 0,
            source = source,
            evidence_ids = Any[target_id],
        ),
        _semantic_static_relation(
            kind = "explained_by",
            from_id = decision_id,
            to_id = signature_id,
            order = 1,
            source = source,
            evidence_ids = Any[target_id],
        ),
    ])
    return nothing
end

function _semantic_call_apply_edge_shapes!(builder::_SemanticCallBuilder)
    rule_shapes = Dict{String,Dict{String,Any}}()
    for record in builder.records
        record["kind"] == "edge" || continue
        shape = get(builder.edge_value_shapes, record["id"], nothing)
        shape === nothing && continue
        record["facts"]["value_shape"] = shape
        if _semantic_call_shape_kind(shape) != "unknown"
            owner_id = record["owner_id"]
            owner_id === nothing || get!(rule_shapes, owner_id, shape)
        end
    end
    for record in builder.records
        record["kind"] == "rule" || continue
        shape = get(rule_shapes, record["id"], nothing)
        shape === nothing && continue
        record["facts"]["value_shape"] = record["facts"]["is_repetition"] === true ?
                                           _semantic_static_array_shape(shape) : shape
    end
    return nothing
end

function _semantic_call_action_owners(
    scans_by_label::Dict{String,_SemanticStaticScannedRule},
    compiled::CompiledSpec,
)
    owners = _SemanticCallActionOwner[]
    for label in compiled.compiled_rule_order
        rule = compiled.rules_by_label[label]
        scan = get(scans_by_label, label, nothing)
        scan === nothing && throw(_semantic_call_correlation_error(
            "Compiled action owner has no authored source scan",
            label,
        ))
        action_index = 1
        blind_index = 1
        edge_order = 0
        for member in scan.members
            for edge in member.edges
                payload = if edge.ownership == "action"
                    action_index <= length(rule.action_edges) || throw(
                        _semantic_call_correlation_error(
                            "Authored action owner has no compiled edge",
                            label,
                        ),
                    )
                    value = rule.action_edges[action_index].action_payload
                    action_index += 1
                    value
                else
                    blind_index <= length(rule.blind_edges) || throw(
                        _semantic_call_correlation_error(
                            "Authored blind owner has no compiled edge",
                            label,
                        ),
                    )
                    value = rule.blind_edges[blind_index].action_payload
                    blind_index += 1
                    value
                end
                owner_id = "edge:$(_semantic_static_rule_id(label)):$edge_order"
                edge_order += 1
                payload === nothing && continue
                payload.contracts.ok || throw(_semantic_call_correlation_error(
                    "Compiled action owner has unresolved typed contracts",
                    owner_id,
                ))
                push!(owners, _SemanticCallActionOwner(
                    owner_id,
                    payload.action_ast,
                    member.range,
                ))
            end
        end
        if action_index - 1 != length(rule.action_edges) ||
           blind_index - 1 != length(rule.blind_edges)
            throw(_semantic_call_correlation_error(
                "Authored and compiled action owner counts differ",
                label;
                fields = Dict{String,Any}(
                    "authored_action_edges" => action_index - 1,
                    "compiled_action_edges" => length(rule.action_edges),
                    "authored_blind_edges" => blind_index - 1,
                    "compiled_blind_edges" => length(rule.blind_edges),
                ),
            ))
        end
    end
    return owners
end

function _semantic_call_typed_function_body(
    entry::UserFunctionEntry,
    registry::UserFunctionRegistry,
)
    definition = entry.definition
    block = try
        parse_action_block(definition.body_source)
    catch error
        throw(_semantic_call_correlation_error(
            "Accepted function body cannot be reconstructed as typed ActionIR",
            definition.name;
            fields = Dict{String,Any}("error" => sprint(showerror, error)),
        ))
    end
    if definition.body_ast === nothing ||
       !_semantic_call_plain_equal(definition.body_ast, to_json(block))
        throw(_semantic_call_correlation_error(
            "Staged function body result differs from typed ActionIR",
            definition.name,
        ))
    end
    resolution = resolve_action_block_contracts(block; function_registry = registry)
    resolution.ok || throw(_semantic_call_correlation_error(
        "Typed function body has unresolved contracts",
        definition.name,
    ))
    return block
end

function _semantic_call_infer_function_shapes(functions, typed_blocks)
    shapes = Dict{String,Dict{String,Any}}(
        entry.definition.name => _semantic_static_value_shape("unknown") for
        entry in functions
    )
    for _ in 0:length(functions)
        changed = false
        for entry in functions
            definition = entry.definition
            variables = _semantic_call_function_variables(entry)
            shape = _semantic_static_value_shape("unknown")
            for statement in typed_blocks[definition.name].statements
                expression = statement.expr
                if expression isa ActionCallExpr && expression.name == "return"
                    if !isempty(expression.args)
                        shape = _semantic_call_expression_shape(
                            first(expression.args).value,
                            variables,
                            shapes,
                        )
                    end
                    break
                elseif expression isa ActionAssignScalarExpr
                    variables[expression.name] = _semantic_call_expression_shape(
                        expression.value,
                        variables,
                        shapes,
                    )
                end
            end
            if shapes[definition.name] != shape
                shapes[definition.name] = shape
                changed = true
            end
        end
        changed || break
    end
    return shapes
end

function _semantic_call_function_variables(entry::UserFunctionEntry)
    definition = entry.definition
    signature = definition.signature
    names = signature === nothing ? definition.params : signature.positional_params
    variables = Dict{String,Dict{String,Any}}(
        name => _semantic_static_value_shape("unknown") for name in names
    )
    if signature !== nothing && signature.rest_param !== nothing &&
       !isempty(signature.rest_param)
        variables[signature.rest_param] = _semantic_static_array_shape(
            _semantic_static_value_shape("unknown"),
        )
    end
    return variables
end

function _semantic_call_expression_shape(
    expression::ActionExpr,
    variables::Dict{String,Dict{String,Any}},
    function_shapes::Dict{String,Dict{String,Any}},
)
    if expression isa ActionStringLiteralExpr
        return _semantic_static_value_shape("string")
    elseif expression isa ActionNumberLiteralExpr
        return _semantic_static_value_shape("number")
    elseif expression isa ActionBooleanLiteralExpr
        return _semantic_static_value_shape("boolean")
    elseif expression isa ActionUndefExpr
        return _semantic_static_value_shape("null")
    elseif expression isa ActionCodeblockLiteralExpr
        return _semantic_static_codeblock_shape(expression.signature)
    elseif expression isa ActionVariableExpr
        return get(variables, expression.name, _semantic_static_value_shape("unknown"))
    elseif expression isa ActionAssignScalarExpr
        return _semantic_call_expression_shape(
            expression.value,
            variables,
            function_shapes,
        )
    elseif expression isa ActionArrayLiteralExpr
        return _semantic_static_array_shape(_semantic_static_common_shape([
            _semantic_call_expression_shape(item, variables, function_shapes) for
            item in expression.items
        ]))
    elseif expression isa ActionHashLiteralExpr
        return _semantic_static_harray_shape(
            _semantic_static_common_shape([
                _semantic_call_expression_shape(entry.key, variables, function_shapes) for
                entry in expression.entries
            ]),
            _semantic_static_common_shape([
                _semantic_call_expression_shape(entry.value, variables, function_shapes) for
                entry in expression.entries
            ]),
        )
    elseif expression isa ActionCallExpr
        function_shape = get(function_shapes, expression.name, nothing)
        function_shape !== nothing && return function_shape
        if expression.name == "return" && !isempty(expression.args)
            return _semantic_call_expression_shape(
                first(expression.args).value,
                variables,
                function_shapes,
            )
        end
        helper = get(_SEMANTIC_CALL_HELPERS, expression.name, nothing)
        return helper === nothing ?
               _semantic_static_value_shape("unknown") :
               _semantic_static_value_shape(helper.return_kind)
    end
    return _semantic_static_value_shape("unknown")
end

function _semantic_call_function_signature(definition::FunctionDefinition)
    signature = definition.signature
    parameters = signature === nothing ? definition.params : signature.positional_params
    return Dict{String,Any}(
        "parameters" => Any[
            Dict{String,Any}(
                "name" => name,
                "kind" => "value",
                "required" => true,
            ) for name in parameters
        ],
        "arity_min" => signature === nothing ? definition.arity : signature.min_arity,
        "arity_max" => signature === nothing ? definition.arity : signature.max_arity,
        "rest_parameter" => signature === nothing ? nothing : signature.rest_param,
        "final_codeblock" => false,
    )
end

function _semantic_call_signature(parameters::Tuple)
    return Dict{String,Any}(
        "parameters" => Any[
            Dict{String,Any}(
                "name" => first(parameter),
                "kind" => last(parameter),
                "required" => true,
            ) for parameter in parameters
        ],
        "arity_min" => length(parameters),
        "arity_max" => length(parameters),
        "rest_parameter" => nothing,
        "final_codeblock" => false,
    )
end

function _semantic_call_signature_names(definition::FunctionDefinition)
    signature = definition.signature
    signature === nothing && return definition.params
    names = String[signature.positional_params...]
    signature.rest_param === nothing || isempty(signature.rest_param) ||
        push!(names, "...$(signature.rest_param)")
    return names
end

function _semantic_call_function_body_range(
    source_text::String,
    source_map::_SemanticSourceMap,
    entry::UserFunctionEntry,
)
    definition = entry.definition
    job = definition.body_parse_job
    job === nothing && throw(_semantic_call_correlation_error(
        "Function has no staged body parse-job authority",
        definition.name,
    ))
    if job.text != definition.body_source || job.function_name != definition.name
        throw(_semantic_call_correlation_error(
            "Function staged body metadata does not match its typed owner",
            definition.name,
        ))
    end
    span = job.source_span
    _span_for_scalar_range(source_map, span.start, span.stop)
    start_byte = source_map.byte_at_scalar[span.start + 1]
    stop_byte = source_map.byte_at_scalar[span.stop + 1]
    range = _SemanticStaticSourceRange(start_byte, stop_byte)
    if _semantic_static_source_slice(source_text, range) != definition.body_source
        throw(_semantic_call_correlation_error(
            "Staged body span does not match function body source",
            definition.name,
        ))
    end
    return range
end

function _semantic_call_function_range(
    source_text::String,
    source_map::_SemanticSourceMap,
    entry::UserFunctionEntry,
)
    definition = entry.definition
    body = _semantic_call_function_body_range(source_text, source_map, entry)
    shell_bytes = Vector{UInt8}(codeunits(definition.source))
    isempty(shell_bytes) && throw(_semantic_call_correlation_error(
        "Function shell source is empty",
        definition.name,
    ))
    source_bytes = codeunits(source_text)
    candidates = _SemanticStaticSourceRange[]
    after = 0
    while after <= length(source_bytes)
        start = _find_semantic_bytes(source_bytes, shell_bytes, after)
        start === nothing && break
        range = _SemanticStaticSourceRange(start, start + length(shell_bytes))
        range.start <= body.start && body.stop <= range.stop && push!(candidates, range)
        after = start + 1
    end
    length(candidates) == 1 || throw(_semantic_call_correlation_error(
        "Function shell occurrence is not uniquely owned by its staged body",
        definition.name;
        fields = Dict{String,Any}("candidate_count" => length(candidates)),
    ))
    return only(candidates)
end

function _semantic_call_scan_sites(
    source_text::String,
    range::_SemanticStaticSourceRange,
)
    bytes = codeunits(source_text)
    sites = _SemanticCallSite[]
    index = range.start
    quote_byte = nothing
    in_regex = false
    escaped = false
    while index < range.stop
        byte = bytes[index + 1]
        if quote_byte !== nothing || in_regex
            if escaped
                escaped = false
            elseif byte == 0x5c
                escaped = true
            elseif quote_byte !== nothing && byte == quote_byte
                quote_byte = nothing
            elseif in_regex && byte == 0x2f
                in_regex = false
            end
            index += 1
            continue
        end
        if byte == 0x22 || byte == 0x27
            quote_byte = byte
            index += 1
            continue
        end
        if byte == 0x2f && _semantic_call_regex_start(bytes, index, range.start, range.stop)
            in_regex = true
            index += 1
            continue
        end
        if !_semantic_call_identifier_start(byte)
            index += 1
            continue
        end
        name_start = index
        index += 1
        while index < range.stop && _semantic_call_identifier_continue(bytes[index + 1])
            index += 1
        end
        name_stop = index
        while index < range.stop && _semantic_static_whitespace(bytes[index + 1])
            index += 1
        end
        if index >= range.stop || bytes[index + 1] != 0x28
            continue
        end
        stop = _semantic_call_matching_parenthesis(bytes, index, range.stop)
        stop === nothing && throw(_semantic_call_correlation_error(
            "Authored call has no balanced closing parenthesis",
            String(Vector{UInt8}(bytes[(name_start + 1):name_stop])),
        ))
        push!(sites, _SemanticCallSite(
            String(Vector{UInt8}(bytes[(name_start + 1):name_stop])),
            _SemanticStaticSourceRange(name_start, stop),
        ))
        index = name_stop
    end
    return sites
end

function _semantic_call_matching_parenthesis(bytes, open::Int, stop::Int)
    depth = 0
    quote_byte = nothing
    in_regex = false
    escaped = false
    for index in open:(stop - 1)
        byte = bytes[index + 1]
        if quote_byte !== nothing || in_regex
            if escaped
                escaped = false
            elseif byte == 0x5c
                escaped = true
            elseif quote_byte !== nothing && byte == quote_byte
                quote_byte = nothing
            elseif in_regex && byte == 0x2f
                in_regex = false
            end
            continue
        end
        if byte == 0x22 || byte == 0x27
            quote_byte = byte
        elseif byte == 0x2f && _semantic_call_regex_start(bytes, index, open, stop)
            in_regex = true
        elseif byte == 0x28
            depth += 1
        elseif byte == 0x29
            depth -= 1
            depth == 0 && return index + 1
            depth < 0 && return nothing
        end
    end
    return nothing
end

function _semantic_call_regex_start(bytes, index::Int, start::Int, stop::Int)
    next = index + 1
    if next >= stop || bytes[next + 1] in (0x28, 0x09, 0x0a, 0x0d, 0x20)
        return false
    end
    previous = index - 1
    while previous >= start && _semantic_static_whitespace(bytes[previous + 1])
        previous -= 1
    end
    previous < start && return true
    return bytes[previous + 1] in (0x28, 0x5b, 0x7b, 0x2c, 0x3d, 0x3a)
end

function _semantic_call_take!(
    cursor::_SemanticCallCursor,
    name::String,
    owner_id::String,
)
    for index in cursor.next:length(cursor.sites)
        site = cursor.sites[index]
        site.name == name || continue
        cursor.next = index + 1
        return site.range
    end
    throw(_semantic_call_correlation_error(
        "Typed call has no authored source occurrence",
        owner_id;
        fields = Dict{String,Any}("call_name" => name),
    ))
end

_semantic_call_identifier_start(byte::UInt8) =
    (0x41 <= byte <= 0x5a) || (0x61 <= byte <= 0x7a) || byte == 0x5f

_semantic_call_identifier_continue(byte::UInt8) =
    _semantic_call_identifier_start(byte) || (0x30 <= byte <= 0x39)

function _semantic_call_source_start(source_refs::Dict{String,Any}, record_id::String)
    source = get(source_refs, "source_ref:$record_id", nothing)
    source isa AbstractDict || throw(_semantic_call_correlation_error(
        "Static source reference is missing",
        record_id,
    ))
    span = get(source, "span", nothing)
    if !(span isa AbstractDict) || !(get(span, "start_byte", nothing) isa Integer)
        throw(_semantic_call_correlation_error(
            "Static source reference span is invalid",
            record_id,
        ))
    end
    return Int(span["start_byte"])
end

function _semantic_call_plain_equal(left, right)
    if left isa AbstractDict && right isa AbstractDict
        left_keys = Set(String(key) for key in keys(left))
        right_keys = Set(String(key) for key in keys(right))
        left_keys == right_keys || return false
        return all(
            _semantic_call_plain_equal(left[key], right[key]) for key in left_keys
        )
    elseif left isa AbstractVector && right isa AbstractVector
        length(left) == length(right) || return false
        return all(
            _semantic_call_plain_equal(left[index], right[index]) for
            index in eachindex(left)
        )
    end
    return left == right
end

_semantic_call_function_id(name::String) =
    "function:$(_semantic_static_escape_name(name))"

_semantic_call_shape_kind(shape::AbstractDict) =
    String(get(shape, "kind", "unknown"))

function _semantic_call_correlation_error(
    message::String,
    identity::String;
    fields = Dict{String,Any}(),
)
    merged = Dict{String,Any}("identity" => identity)
    merge!(merged, fields)
    return SemanticIndexError(
        stage = "project_call_semantics",
        code = "semantic_call_correlation_failed",
        message = message,
        fields = merged,
    )
end
