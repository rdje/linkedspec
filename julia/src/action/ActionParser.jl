struct _ActionTextSpan
    text::String
    start::Int
    stop::Int
end

struct _ActionAttachedBlock
    head::String
    body::String
    open_index::Int
    close_index::Int
end

struct _ActionParsedCallee
    name::String
    source_method::String
    payload::String
    payload_start::Int
end

struct _ActionControlHead
    head::String
    keyword::String
end

struct _ActionSwitchBranches
    cases::Vector{ActionExpr}
    default_case::Union{Nothing,ActionExpr}
end

_ActionSwitchBranches() = _ActionSwitchBranches(ActionExpr[], nothing)

struct _ActionSeparator
    index::Int
    length::Int
    token::String
end

"""Typed authored-source failure produced while parsing ActionIR."""
struct ActionParseException <: Exception
    code::String
    stage::String
    source_span::ActionSourceSpan
    message::String
end

function ActionParseException(; code, source_span, message)
    return ActionParseException(
        String(code),
        "action_parse",
        source_span,
        String(message),
    )
end

Base.showerror(io::IO, error::ActionParseException) = print(io, error.message)

function to_json(error::ActionParseException)
    return Dict{String,Any}(
        "code" => error.code,
        "stage" => error.stage,
        "source_span" => Dict{String,Any}(
            "start" => error.source_span.start,
            "end" => error.source_span.stop,
            "unit" => "unicode_scalar",
            "provenance" => "authored",
        ),
        "message" => error.message,
    )
end

const _ACTION_NESTED_WRITE_RESERVED_ROOTS = Set([
    "CAPTURE",
    "IINDEX",
    "IMATCH",
    "IMATCH_HASH",
    "IMATCH_LIST",
    "IPOS",
    "LINDEX",
    "LMATCH",
    "LMATCH_HASH",
    "LMATCH_LIST",
    "LSPOS",
    "STRING",
    "descr",
    "false",
    "info",
    "minfo",
    "null",
    "retv",
    "true",
    "undef",
])

mutable struct _ActionScanState
    quote_char::Union{Nothing,Char}
    escaped::Bool
    in_regex::Bool
    paren_depth::Int
    bracket_depth::Int
    brace_depth::Int
end

_ActionScanState() = _ActionScanState(nothing, false, false, 0, 0, 0)
_action_is_top_level(state::_ActionScanState) = state.paren_depth == 0 && state.bracket_depth == 0 && state.brace_depth == 0

function parse_action_block(source::AbstractString)
    text = String(source)
    pieces = _action_split_top_level_statements(text, 0)
    return ActionBlock(
        source = text,
        source_span = ActionSourceSpan(0, _action_len(text)),
        statements = [
            parse_action_statement(piece.text, piece.start) for piece in pieces
        ],
    )
end

function parse_action_statement(source::AbstractString, base_start::Int = 0)
    text = String(source)
    trimmed = _action_trim_with_offsets(text, base_start)
    expr = if trimmed.text == "next"
        ActionCallExpr(
            source = trimmed.text,
            source_span = ActionSourceSpan(trimmed.start, trimmed.stop),
            name = "next",
            source_method = "next",
            args = ActionArgument[],
        )
    else
        parse_action_expression(trimmed.text, trimmed.start)
    end
    return ActionStatement(
        source = trimmed.text,
        source_span = ActionSourceSpan(trimmed.start, trimmed.stop),
        expr = expr,
    )
end

function parse_action_expression(source::AbstractString, base_start::Int = 0)
    text = String(source)
    trimmed = _action_trim_with_offsets(text, base_start)
    if isempty(trimmed.text)
        return ActionRawExpr(
            source = trimmed.text,
            source_span = ActionSourceSpan(trimmed.start, trimmed.stop),
            reason = "empty_expression",
        )
    end
    return _action_parse_expr(trimmed.text, trimmed.start)
end

function _action_parse_expr(text::String, start::Int)
    assignment = _action_parse_assignment(text, start)
    if assignment !== nothing
        return assignment
    end

    chain = _action_parse_fluent_chain(text, start)
    if chain !== nothing
        return chain
    end

    return _action_parse_expr_without_chain(text, start)
end

function _action_parse_expr_without_chain(text::String, start::Int)
    grouped = _action_parse_grouped(text, start)
    if grouped !== nothing
        return grouped
    end

    literal = _action_parse_literal(text, start)
    if literal !== nothing
        return literal
    end

    shape = _action_parse_shape_or_block(text, start)
    if shape !== nothing
        return shape
    end

    control = _action_parse_control_flow(text, start)
    if control !== nothing
        return control
    end

    value_access = _action_parse_call_result_access(text, start)
    if value_access !== nothing
        return value_access
    end

    call = _action_parse_call(text, start)
    if call !== nothing
        return call
    end

    access = _action_parse_variable_or_access(text, start)
    if access !== nothing
        return access
    end

    return ActionRawExpr(
        source = text,
        source_span = ActionSourceSpan(start, start + _action_len(text)),
        reason = "unsupported_expression",
    )
end

function _action_parse_call_result_access(text::String, start::Int)
    open = _action_find_top_level_open_paren(text)
    if open === nothing
        return nothing
    end
    close = _action_find_matching_delimiter(text, open, '(', ')')
    if close === nothing
        return nothing
    end
    chars = collect(text)
    access_start = close + 1
    while access_start < length(chars) && isspace(chars[access_start + 1])
        access_start += 1
    end
    if access_start == length(chars) || chars[access_start + 1] != '['
        return nothing
    end
    receiver_source = _action_slice(text, 0, close + 1)
    receiver = _action_parse_call(receiver_source, start)
    if receiver === nothing
        return nothing
    end
    segments = _action_parse_access_segments(text, access_start, start)
    if segments === nothing || isempty(segments)
        return nothing
    end
    return ActionValueAccessExpr(
        source = text,
        source_span = ActionSourceSpan(start, start + _action_len(text)),
        receiver = receiver,
        segments = segments,
    )
end

function _action_parse_grouped(text::String, start::Int)
    if !startswith(text, "(") || !endswith(text, ")")
        return nothing
    end
    close = _action_find_matching_delimiter(text, 0, '(', ')')
    if close != _action_len(text) - 1
        return nothing
    end
    inner = _action_slice(text, 1, _action_len(text) - 1)
    trimmed = _action_trim_with_offsets(inner, start + 1)
    return parse_action_expression(trimmed.text, trimmed.start)
end

function _action_parse_literal(text::String, start::Int)
    stop = start + _action_len(text)
    if occursin(r"^-?\d+(?:\.\d+)?$", text)
        value = occursin('.', text) ? parse(Float64, text) : parse(Int, text)
        return ActionNumberLiteralExpr(
            source = text,
            source_span = ActionSourceSpan(start, stop),
            value = value,
        )
    end
    if text == "undef"
        return ActionUndefExpr(source = text, source_span = ActionSourceSpan(start, stop))
    end
    if text == "true" || text == "false"
        return ActionBooleanLiteralExpr(
            source = text,
            source_span = ActionSourceSpan(start, stop),
            value = text == "true",
        )
    end
    if _action_len(text) >= 2
        chars = collect(text)
        first_char = chars[1]
        last_char = chars[end]
        if (first_char == '"' || first_char == '\'') && last_char == first_char
            payload = _action_slice(text, 1, _action_len(text) - 1)
            return ActionStringLiteralExpr(
                source = text,
                source_span = ActionSourceSpan(start, stop),
                value = _action_unescape_string(payload),
                quote_char = string(first_char),
            )
        end
    end
    regex = match(r"^/((?:\\.|[^/])*)/([A-Za-z]*)$", text)
    if regex !== nothing
        return ActionRegexLiteralExpr(
            source = text,
            source_span = ActionSourceSpan(start, stop),
            pattern = regex.captures[1],
            flags = regex.captures[2],
        )
    end
    return nothing
end

function _action_parse_shape_or_block(text::String, start::Int)
    if startswith(text, "[")
        return _action_parse_array_literal(text, start)
    end
    if startswith(text, "{")
        return _action_parse_brace_expr(text, start)
    end
    return nothing
end

function _action_parse_array_literal(text::String, start::Int)
    if !_action_outer_delimiter_is_balanced(text, '[', ']')
        return nothing
    end
    payload = _action_slice(text, 1, _action_len(text) - 1)
    return ActionArrayLiteralExpr(
        source = text,
        source_span = ActionSourceSpan(start, start + _action_len(text)),
        items = [
            parse_action_expression(part.text, part.start) for part in _action_split_top_level_csv(payload, start + 1)
        ],
    )
end

function _action_parse_brace_expr(text::String, start::Int)
    if !_action_outer_delimiter_is_balanced(text, '{', '}')
        return nothing
    end
    if startswith(text, "{|")
        return _action_parse_codeblock_literal(text, start)
    end
    payload = _action_slice(text, 1, _action_len(text) - 1)
    if occursin(r"^\s+\|", payload)
        return _action_codeblock_literal_error(text, start, "invalid_codeblock_opener")
    end
    if isempty(strip(payload)) || _action_has_top_level_hash_pair_separator(payload)
        return _action_parse_hash_literal(text, payload, start)
    end
    return ActionBlockValueExpr(
        source = text,
        source_span = ActionSourceSpan(start, start + _action_len(text)),
        block = _action_parse_block(payload, start + 1),
    )
end

function _action_parse_codeblock_literal(text::String, start::Int)
    signature_end = nothing
    chars = collect(text)
    for index in 2:(length(chars) - 2)
        if chars[index + 1] == '|'
            signature_end = index
            break
        end
    end
    if signature_end === nothing
        return _action_codeblock_literal_error(
            text,
            start,
            "missing_codeblock_signature_closer",
        )
    end

    parsed = _action_parse_codeblock_signature(_action_slice(text, 2, signature_end))
    if parsed.signature === nothing
        return _action_codeblock_literal_error(text, start, parsed.error_code)
    end

    body_start = start + signature_end + 1
    body_stop = start + _action_len(text) - 1
    body_source = _action_slice(text, signature_end + 1, _action_len(text) - 1)
    return ActionCodeblockLiteralExpr(
        source = text,
        source_span = ActionSourceSpan(start, start + _action_len(text)),
        signature = parsed.signature,
        body_source = body_source,
        body_ast = _action_parse_block(body_source, body_start),
        body_span = ActionSourceSpan(body_start, body_stop),
    )
end

function _action_codeblock_literal_error(source::String, start::Int, code::String)
    return ActionCodeblockLiteralErrorExpr(
        source = source,
        source_span = ActionSourceSpan(start, start + _action_len(source)),
        code = code,
    )
end

const _ACTION_CODEBLOCK_RESERVED_PARAMETERS = Set{String}([
    "fn",
    "return",
    "I",
    "LS",
    "LE",
    "E",
    "EX",
    "IT",
    "LX",
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

function _action_parse_codeblock_signature(source::String)
    parts = isempty(source) ?
            String[] :
            String[strip(part) for part in split(source, ','; keepempty = true)]
    if any(isempty, parts)
        return (signature = nothing, error_code = "invalid_parameter")
    end

    positional = String[]
    rest_param = nothing
    seen = Set{String}()
    for (index, part) in enumerate(parts)
        name = part
        if startswith(part, "...")
            if index != length(parts)
                return (signature = nothing, error_code = "rest_parameter_must_be_final")
            end
            matched = match(r"^\.\.\.([A-Za-z_][A-Za-z0-9_]*)$", part)
            if matched === nothing
                return (signature = nothing, error_code = "invalid_rest_parameter")
            end
            name = matched.captures[1]
            rest_param = name
        else
            if !_action_is_identifier(part)
                return (signature = nothing, error_code = "invalid_parameter")
            end
            push!(positional, name)
        end
        if name in seen
            return (signature = nothing, error_code = "duplicate_parameter")
        end
        push!(seen, name)
        if name in _ACTION_CODEBLOCK_RESERVED_PARAMETERS
            return (signature = nothing, error_code = "reserved_parameter")
        end
    end

    return (
        signature = CallableSignature(
            positional_params = positional,
            rest_param = rest_param,
            min_arity = length(positional),
            max_arity = rest_param === nothing ? length(positional) : nothing,
        ),
        error_code = nothing,
    )
end

function _action_parse_hash_literal(text::String, payload::String, start::Int)
    entries = ActionHashLiteralEntry[]
    for part in _action_split_top_level_csv(payload, start + 1)
        if isempty(strip(part.text))
            continue
        end
        separator = _action_find_top_level_hash_pair_separator(part.text)
        if separator === nothing
            return ActionRawExpr(
                source = text,
                source_span = ActionSourceSpan(start, start + _action_len(text)),
                reason = "invalid_hash_literal",
            )
        end
        if separator.token == "=>"
            return ActionRawExpr(
                source = text,
                source_span = ActionSourceSpan(start, start + _action_len(text)),
                reason = "hash_literal_use_colon",
            )
        end
        key_text = _action_slice(part.text, 0, separator.index)
        value_text = _action_slice(part.text, separator.index + separator.length, _action_len(part.text))
        key = _action_trim_with_offsets(key_text, part.start)
        value = _action_trim_with_offsets(value_text, part.start + separator.index + separator.length)
        push!(
            entries,
            ActionHashLiteralEntry(
                key = parse_action_expression(key.text, key.start),
                value = parse_action_expression(value.text, value.start),
            ),
        )
    end
    return ActionHashLiteralExpr(
        source = text,
        source_span = ActionSourceSpan(start, start + _action_len(text)),
        entries = entries,
    )
end

function _action_parse_control_flow(text::String, start::Int)
    attached = _action_split_attached_block(text)
    if attached !== nothing
        head = _action_trim_with_offsets(attached.head, start)
        if !isempty(head.text)
            return _action_parse_control_head(
                head.text,
                head.start,
                text,
                start,
                start + _action_len(text),
                attached,
            )
        end
    end
    return _action_parse_control_head(text, start, text, start, start + _action_len(text), nothing)
end

function _action_parse_control_head(
    head::String,
    head_start::Int,
    full_source::String,
    full_start::Int,
    full_stop::Int,
    attached,
)
    normalized = _action_normalize_control_head(head)
    if normalized === nothing
        return nothing
    end
    parsed = _action_parse_callee(normalized.head)
    if parsed === nothing
        return nothing
    end
    canonical = _action_canonical_control_keyword(parsed.name)
    if canonical === nothing
        return nothing
    end
    args = _action_parse_arguments(parsed.payload, head_start + parsed.payload_start)
    body = attached === nothing ? nothing : _action_parse_block(attached.body, full_start + attached.open_index + 1)
    body_span = attached === nothing ? nothing : ActionSourceSpan(
        full_start + attached.open_index,
        full_start + attached.close_index + 1,
    )
    first_arg = length(args) == 1 ? args[1].value : nothing

    if parsed.name in ("if", "i", "when", "elseif", "elif")
        if first_arg === nothing
            return nothing
        end
        return ActionControlIfExpr(
            source = full_source,
            source_span = ActionSourceSpan(full_start, full_stop),
            keyword = normalized.keyword,
            canonical_keyword = canonical,
            branch_role = parsed.name in ("elseif", "elif") ? "elseif" : "if",
            condition = first_arg,
            args = args,
            body = body,
            body_source_span = body_span,
        )
    elseif parsed.name in ("else", "otherwise")
        if !isempty(args)
            return nothing
        end
        return ActionControlElseExpr(
            source = full_source,
            source_span = ActionSourceSpan(full_start, full_stop),
            keyword = normalized.keyword,
            canonical_keyword = canonical,
            args = args,
            body = body,
            body_source_span = body_span,
        )
    elseif parsed.name == "endif"
        if !isempty(args) || attached !== nothing
            return nothing
        end
        return ActionControlMarkerExpr(
            kind = "control_endif",
            source = full_source,
            source_span = ActionSourceSpan(full_start, full_stop),
            keyword = normalized.keyword,
            canonical_keyword = canonical,
            args = args,
        )
    elseif parsed.name == "while"
        if first_arg === nothing
            return nothing
        end
        return ActionControlWhileExpr(
            source = full_source,
            source_span = ActionSourceSpan(full_start, full_stop),
            keyword = normalized.keyword,
            canonical_keyword = canonical,
            condition = first_arg,
            args = args,
            body = body,
            body_source_span = body_span,
        )
    elseif parsed.name == "switch"
        if first_arg === nothing
            return nothing
        end
        branches = attached === nothing ? _ActionSwitchBranches() : _action_parse_switch_branches(
            _action_slice(full_source, attached.open_index, attached.close_index + 1),
            full_start + attached.open_index,
        )
        return ActionControlSwitchExpr(
            source = full_source,
            source_span = ActionSourceSpan(full_start, full_stop),
            keyword = normalized.keyword,
            canonical_keyword = canonical,
            source_expr = first_arg,
            args = args,
            body = body,
            body_source_span = body_span,
            cases = branches.cases,
            default_case = branches.default_case,
        )
    elseif parsed.name == "case"
        if first_arg === nothing
            return nothing
        end
        return ActionControlCaseExpr(
            source = full_source,
            source_span = ActionSourceSpan(full_start, full_stop),
            keyword = normalized.keyword,
            canonical_keyword = canonical,
            match = first_arg,
            args = args,
            body = body,
            body_source_span = body_span,
        )
    elseif parsed.name == "default"
        if !isempty(args)
            return nothing
        end
        return ActionControlDefaultExpr(
            source = full_source,
            source_span = ActionSourceSpan(full_start, full_stop),
            keyword = normalized.keyword,
            canonical_keyword = canonical,
            args = args,
            body = body,
            body_source_span = body_span,
        )
    elseif parsed.name in ("endcase", "endswitch")
        if !isempty(args) || attached !== nothing
            return nothing
        end
        return ActionControlMarkerExpr(
            kind = parsed.name == "endcase" ? "control_endcase" : "control_endswitch",
            source = full_source,
            source_span = ActionSourceSpan(full_start, full_stop),
            keyword = normalized.keyword,
            canonical_keyword = canonical,
            args = args,
        )
    end

    return nothing
end

function _action_parse_switch_branches(source::String, start::Int)
    if !_action_outer_delimiter_is_balanced(source, '{', '}')
        return _ActionSwitchBranches()
    end
    payload = _action_slice(source, 1, _action_len(source) - 1)
    payload_start = start + 1
    cases = ActionExpr[]
    default_case = nothing
    index = 0
    while index < _action_len(payload)
        chars = collect(payload)
        while index < length(chars) && (isspace(chars[index + 1]) || chars[index + 1] == ';')
            index += 1
        end
        if index >= _action_len(payload)
            break
        end
        open = _action_find_top_level_open_brace(payload, index)
        if open === nothing
            break
        end
        close = _action_find_matching_delimiter(payload, open, '{', '}')
        if close === nothing
            break
        end
        expr_text = _action_slice(payload, index, close + 1)
        expr = parse_action_expression(expr_text, payload_start + index)
        if expr isa ActionControlCaseExpr
            push!(cases, expr)
        elseif expr isa ActionControlDefaultExpr
            default_case = expr
        end
        index = close + 1
    end
    return _ActionSwitchBranches(cases, default_case)
end

function _action_parse_call(text::String, start::Int)
    attached = _action_split_attached_block(text)
    if attached !== nothing
        head = _action_trim_with_offsets(attached.head, start)
        parsed = _action_parse_callee(head.text)
        if parsed === nothing
            return nothing
        end
        args = _action_parse_arguments(parsed.payload, head.start + parsed.payload_start)
        block_source = _action_slice(text, attached.open_index, attached.close_index + 1)
        block_span = ActionSourceSpan(start + attached.open_index, start + attached.close_index + 1)
        push!(
            args,
            ActionPositionalArgument(
                ActionBlockValueExpr(
                    source = block_source,
                    source_span = block_span,
                    block = _action_parse_block(attached.body, start + attached.open_index + 1),
                ),
            ),
        )
        return ActionCallExpr(
            source = text,
            source_span = ActionSourceSpan(start, start + _action_len(text)),
            name = parsed.name,
            source_method = parsed.source_method,
            args = args,
            trailing_block_arg = true,
            trailing_block_source_span = block_span,
        )
    end

    parsed = _action_parse_callee(text)
    if parsed === nothing
        return nothing
    end
    args = _action_parse_arguments(parsed.payload, start + parsed.payload_start)
    transaction = _action_recognition_transaction_expr(
        parsed.name,
        args,
        text,
        ActionSourceSpan(start, start + _action_len(text)),
    )
    if transaction !== nothing
        return transaction
    end
    return ActionCallExpr(
        source = text,
        source_span = ActionSourceSpan(start, start + _action_len(text)),
        name = parsed.name,
        source_method = parsed.source_method,
        args = args,
    )
end

function _action_recognition_bare_name(argument)
    if argument isa ActionPositionalArgument && argument.value isa ActionVariableExpr
        return argument.value.name
    end
    return nothing
end

function _action_recognition_transaction_expr(
    name::String,
    args::Vector{ActionArgument},
    source::String,
    source_span::ActionSourceSpan,
)
    function invalid()
        error(
            "LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:" *
            "recognition_static_form_required:$name",
        )
    end

    if name == "recognition_checkpoint"
        isempty(args) || invalid()
        return ActionRecognitionCheckpointExpr(
            source = source,
            source_span = source_span,
        )
    elseif name == "recognize_once"
        length(args) == 2 || invalid()
        token = _action_recognition_bare_name(first(args))
        operand = last(args)
        if token === nothing || !(operand isa ActionPositionalArgument) ||
                !(operand.value isa ActionCallExpr)
            invalid()
        end
        call = operand.value
        if call.name != "call" || call.source_method != "call" || length(call.args) != 1
            invalid()
        end
        rule = _action_recognition_bare_name(only(call.args))
        rule === nothing && invalid()
        return ActionRecognizeOnceExpr(
            source = source,
            source_span = source_span,
            token = token,
            rule = rule,
        )
    elseif name == "observe_recognition"
        length(args) == 2 || error(
            "LINKEDSPEC_SOURCE_LOCATION_ERROR:" *
            "source_location_recursive_observation_operand",
        )
        target = _action_recognition_bare_name(first(args))
        target === nothing && error(
            "LINKEDSPEC_SOURCE_LOCATION_ERROR:" *
            "source_location_recursive_observation_target",
        )
        operand = last(args)
        if !(operand isa ActionPositionalArgument) ||
                !(operand.value isa ActionCallExpr)
            error(
                "LINKEDSPEC_SOURCE_LOCATION_ERROR:" *
                "source_location_recursive_observation_operand",
            )
        end
        call = operand.value
        if call.name != "call" || call.source_method != "call" ||
                length(call.args) != 1
            error(
                "LINKEDSPEC_SOURCE_LOCATION_ERROR:" *
                "source_location_recursive_observation_operand",
            )
        end
        rule = _action_recognition_bare_name(only(call.args))
        rule === nothing && error(
            "LINKEDSPEC_SOURCE_LOCATION_ERROR:" *
            "source_location_recursive_observation_operand",
        )
        return ActionObserveRecognitionExpr(
            source = source,
            source_span = source_span,
            target = target,
            rule = rule,
        )
    elseif name == "recognition_commit" || name == "recognition_rollback"
        length(args) == 1 || invalid()
        token = _action_recognition_bare_name(only(args))
        token === nothing && invalid()
        if name == "recognition_commit"
            return ActionRecognitionCommitExpr(
                source = source,
                source_span = source_span,
                token = token,
            )
        end
        return ActionRecognitionRollbackExpr(
            source = source,
            source_span = source_span,
            token = token,
        )
    end
    return nothing
end

function _action_parse_variable_or_access(text::String, start::Int)
    match_result = match(r"^\$?([A-Za-z_]\w*)", text)
    if match_result === nothing
        return nothing
    end
    name = match_result.captures[1]
    pos = _action_len(match_result.match)
    chars = collect(text)
    while pos < length(chars) && isspace(chars[pos + 1])
        pos += 1
    end
    if pos == length(chars)
        return ActionVariableExpr(
            source = text,
            source_span = ActionSourceSpan(start, start + _action_len(text)),
            name = name,
        )
    end
    if chars[pos + 1] != '['
        return nothing
    end
    segments = _action_parse_access_segments(text, pos, start)
    if segments === nothing || isempty(segments)
        return nothing
    end
    if length(segments) == 1 && segments[1] isa ActionIndexAccessSegment
        return ActionIndexedVarExpr(
            source = text,
            source_span = ActionSourceSpan(start, start + _action_len(text)),
            name = name,
            index = segments[1].expr,
        )
    end
    return ActionNestedAccessExpr(
        source = text,
        source_span = ActionSourceSpan(start, start + _action_len(text)),
        base = name,
        segments = segments,
    )
end

function _action_parse_access_segments(text::String, pos::Int, start::Int)
    segments = ActionAccessSegment[]
    chars = collect(text)
    while pos < length(chars)
        while pos < length(chars) && isspace(chars[pos + 1])
            pos += 1
        end
        if pos == length(chars)
            return segments
        end
        if chars[pos + 1] != '['
            return nothing
        end
        close = _action_find_matching_delimiter(text, pos, '[', ']')
        if close === nothing
            return nothing
        end
        payload = _action_slice(text, pos + 1, close)
        trimmed = _action_trim_with_offsets(payload, start + pos + 1)
        expr = parse_action_expression(trimmed.text, trimmed.start)
        segment_source = _action_slice(text, pos, close + 1)
        segment_span = ActionSourceSpan(start + pos, start + close + 1)
        if expr isa ActionStringLiteralExpr
            push!(
                segments,
                ActionKeyAccessSegment(
                    value = expr.value,
                    source = segment_source,
                    source_span = segment_span,
                ),
            )
        else
            push!(
                segments,
                ActionIndexAccessSegment(
                    expr = expr,
                    source = segment_source,
                    source_span = segment_span,
                ),
            )
        end
        pos = close + 1
    end
    return segments
end

function _action_progressive_dispatch_assignment(
    text::String,
    start::Int,
    target::String,
    value::ActionExpr,
)
    value isa ActionCallExpr && value.name == "dispatch_span" || return nothing
    length(value.args) == 3 || throw(
        ArgumentError("progressive_span_binding_required"),
    )
    all(argument -> argument isa ActionPositionalArgument, value.args) || throw(
        ArgumentError("progressive_span_binding_required"),
    )
    parser_operand = value.args[1].value
    parser_operand isa ActionStringLiteralExpr || throw(
        ArgumentError("progressive_parser_identity_literal_required"),
    )
    parser_id = parser_operand.value
    occursin(r"^[a-z][a-z0-9]*(?:[._:-][a-z0-9]+)*$", parser_id) || throw(
        ArgumentError("progressive_parser_identity_invalid"),
    )
    top_operand = value.args[2].value
    top_operand isa ActionStringLiteralExpr || throw(
        ArgumentError("progressive_top_rule_literal_required"),
    )
    top_rule = top_operand.value
    occursin(r"^[A-Za-z_][A-Za-z0-9_]*$", top_rule) || throw(
        ArgumentError("progressive_top_rule_invalid"),
    )
    span_operand = value.args[3].value
    span_operand isa ActionVariableExpr || throw(
        ArgumentError("progressive_span_binding_required"),
    )
    return ActionProgressiveDispatchSpanExpr(
        source = text,
        source_span = ActionSourceSpan(start, start + _action_len(text)),
        target = target,
        parser_id = parser_id,
        top_rule = top_rule,
        span = span_operand.name,
    )
end

_action_staged_parse_job_invalid(code::AbstractString) = throw(
    ArgumentError("LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:$(String(code))"),
)

function _action_staged_literal_string(expr::ActionExpr)
    return expr isa ActionStringLiteralExpr ? expr.value : nothing
end

function _action_staged_parse_job_options(expr::ActionExpr)
    if !(expr isa ActionCallExpr) ||
            expr.name != "hash" ||
            isempty(expr.args) ||
            isodd(length(expr.args))
        _action_staged_parse_job_invalid("staged_parse_job_options_required")
    end

    allowed = Set([
        "node_kind",
        "payload_kind",
        "spec",
        "top",
        "result_policy",
        "into",
        "on_error",
        "required_capabilities",
    ])
    values = Dict{String,ActionExpr}()
    for index in 1:2:length(expr.args)
        key_argument = expr.args[index]
        value_argument = expr.args[index + 1]
        key = key_argument isa ActionPositionalArgument ?
            _action_staged_literal_string(key_argument.value) : nothing
        key === nothing && _action_staged_parse_job_invalid(
            "staged_parse_job_options_required",
        )
        key in allowed || _action_staged_parse_job_invalid(
            "staged_parse_job_option_unknown",
        )
        if !(value_argument isa ActionPositionalArgument) || haskey(values, key)
            _action_staged_parse_job_invalid("staged_parse_job_options_required")
        end
        values[key] = value_argument.value
    end

    function required_string(name::String)
        value = get(values, name, nothing)
        literal = value isa ActionExpr ? _action_staged_literal_string(value) : nothing
        literal === nothing && _action_staged_parse_job_invalid(
            "staged_parse_job_options_required",
        )
        return literal
    end

    function optional_string(name::String)
        value = get(values, name, nothing)
        value === nothing && return nothing
        literal = _action_staged_literal_string(value)
        literal === nothing && _action_staged_parse_job_invalid(
            "staged_parse_job_options_required",
        )
        return literal
    end

    node_kind = required_string("node_kind")
    payload_kind = required_string("payload_kind")
    spec = required_string("spec")
    top = optional_string("top")
    result_policy = required_string("result_policy")
    into = optional_string("into")
    on_error = required_string("on_error")
    identifier_pattern = r"^[a-z][a-z0-9_]*$"
    parser_identity_pattern = r"^[a-z][a-z0-9]*(?:[._:-][a-z0-9]+)*$"
    field_pattern = r"^[A-Za-z_][A-Za-z0-9_]*$"
    if !occursin(identifier_pattern, node_kind) ||
            !occursin(identifier_pattern, payload_kind)
        _action_staged_parse_job_invalid("staged_parse_job_options_required")
    end
    occursin(parser_identity_pattern, spec) || _action_staged_parse_job_invalid(
        "staged_parser_identity_invalid",
    )
    if top !== nothing && !occursin(field_pattern, top)
        _action_staged_parse_job_invalid("staged_top_rule_invalid")
    end
    result_policy in (
        "replace_marker",
        "replace_field",
        "sibling_field",
        "append_child",
    ) || _action_staged_parse_job_invalid("staged_result_policy_invalid")
    on_error in ("fail", "keep_text", "diagnostic_node") ||
        _action_staged_parse_job_invalid("staged_failure_policy_invalid")
    target_is_valid = into !== nothing && occursin(field_pattern, into)
    if (result_policy == "replace_marker" && into !== nothing) ||
            (result_policy != "replace_marker" && !target_is_valid)
        _action_staged_parse_job_invalid("staged_result_target_invalid")
    end

    required_capabilities = String[]
    capability_expr = get(values, "required_capabilities", nothing)
    if capability_expr !== nothing
        if !(capability_expr isa ActionCallExpr) || capability_expr.name != "array"
            _action_staged_parse_job_invalid("staged_parse_job_options_required")
        end
        seen = Set{String}()
        for argument in capability_expr.args
            capability = argument isa ActionPositionalArgument ?
                _action_staged_literal_string(argument.value) : nothing
            if capability === nothing ||
                    !occursin(parser_identity_pattern, capability) ||
                    capability in seen
                _action_staged_parse_job_invalid("staged_parse_job_options_required")
            end
            push!(seen, capability)
        end
        append!(required_capabilities, sort!(collect(seen)))
    end

    return ActionStagedParseJobOptions(
        node_kind = node_kind,
        payload_kind = payload_kind,
        spec = spec,
        top = top,
        result_policy = result_policy,
        into = into,
        on_error = on_error,
        required_capabilities = required_capabilities,
    )
end

function _action_staged_direct_text_plan(expr::ActionExpr)
    expr isa ActionCallExpr || return nothing
    if expr.name in ("entry_text", "match_text")
        isempty(expr.args) || _action_staged_parse_job_invalid(
            "staged_source_provenance_invalid",
        )
        return ActionStagedParseJobDirectTextPlan(source = expr.name)
    elseif expr.name in ("entry_group", "match_group")
        if length(expr.args) != 1 || !(only(expr.args) isa ActionPositionalArgument)
            _action_staged_parse_job_invalid("staged_source_provenance_invalid")
        end
        index_expr = only(expr.args).value
        if !(index_expr isa ActionNumberLiteralExpr) ||
                !isfinite(index_expr.value) ||
                index_expr.value < 0 ||
                index_expr.value != trunc(index_expr.value)
            _action_staged_parse_job_invalid("staged_source_provenance_invalid")
        end
        return ActionStagedParseJobDirectTextPlan(
            source = expr.name,
            index = Int(index_expr.value),
        )
    end
    return nothing
end

function _action_staged_parse_job_text_plan(expr::ActionExpr)
    direct = _action_staged_direct_text_plan(expr)
    if direct !== nothing
        return ActionStagedParseJobDirectSpanPlan(
            source = direct.source,
            index = direct.index,
        )
    end
    if !(expr isa ActionCallExpr) || expr.name != "cat" || isempty(expr.args)
        _action_staged_parse_job_invalid("staged_source_provenance_invalid")
    end
    segments = ActionStagedParseJobDirectTextPlan[]
    for argument in expr.args
        argument isa ActionPositionalArgument || _action_staged_parse_job_invalid(
            "staged_source_provenance_invalid",
        )
        nested = _action_staged_parse_job_text_plan(argument.value)
        if nested isa ActionStagedParseJobDirectSpanPlan
            push!(
                segments,
                ActionStagedParseJobDirectTextPlan(
                    source = nested.source,
                    index = nested.index,
                ),
            )
        else
            append!(segments, nested.segments)
        end
    end
    isempty(segments) && _action_staged_parse_job_invalid(
        "staged_source_provenance_invalid",
    )
    return ActionStagedParseJobDerivedTextPlan(segments = segments)
end

function _action_staged_parse_job_assignment(
    text::String,
    start::Int,
    target::String,
    value::ActionExpr,
)
    value isa ActionCallExpr && value.name == "parse_job" || return nothing
    if length(value.args) != 2 ||
            !all(argument -> argument isa ActionPositionalArgument, value.args)
        _action_staged_parse_job_invalid("staged_parse_job_options_required")
    end
    return ActionStagedParseJobExpr(
        source = text,
        source_span = ActionSourceSpan(start, start + _action_len(text)),
        target = target,
        text_plan = _action_staged_parse_job_text_plan(value.args[1].value),
        options = _action_staged_parse_job_options(value.args[2].value),
    )
end

function _action_parse_assignment(text::String, start::Int)
    append_index = _action_find_top_level_token(text, "+=")
    if append_index !== nothing
        left = strip(_action_slice(text, 0, append_index))
        if !_action_is_identifier(left)
            return nothing
        end
        value = _action_trim_with_offsets(
            _action_slice(text, append_index + 2, _action_len(text)),
            start + append_index + 2,
        )
        return ActionAssignArrayAppendExpr(
            source = text,
            source_span = ActionSourceSpan(start, start + _action_len(text)),
            name = left,
            value = parse_action_expression(value.text, value.start),
        )
    end

    eq_index = _action_find_top_level_assignment_equals(text)
    if eq_index === nothing
        eq_index = _action_find_unclosed_nested_write_assignment_equals(text)
    end
    if eq_index === nothing
        return nothing
    end
    left = _action_trim_with_offsets(_action_slice(text, 0, eq_index), start)
    if isempty(left.text)
        return nothing
    end
    right = _action_trim_with_offsets(
        _action_slice(text, eq_index + 1, _action_len(text)),
        start + eq_index + 1,
    )
    nested_target = _action_parse_nested_write_target(left)
    if nested_target !== nothing
        value = parse_action_expression(right.text, right.start)
        return ActionAssignNestedAccessExpr(
            source = text,
            source_span = ActionSourceSpan(start, start + _action_len(text)),
            base = nested_target.base,
            segments = nested_target.segments,
            value = value,
        )
    end

    value = parse_action_expression(right.text, right.start)
    if _action_is_identifier(left.text)
        staged = _action_staged_parse_job_assignment(
            text,
            start,
            left.text,
            value,
        )
        staged !== nothing && return staged
        progressive = _action_progressive_dispatch_assignment(
            text,
            start,
            left.text,
            value,
        )
        progressive !== nothing && return progressive
        return ActionAssignScalarExpr(
            source = text,
            source_span = ActionSourceSpan(start, start + _action_len(text)),
            name = left.text,
            value = value,
        )
    end

    target = _action_parse_variable_or_access(left.text, left.start)
    if target isa ActionIndexedVarExpr
        return ActionAssignHashIndexExpr(
            source = text,
            source_span = ActionSourceSpan(start, start + _action_len(text)),
            name = target.name,
            key = target.index,
            value = value,
        )
    end
    return nothing
end

function _action_parse_nested_write_target(left::_ActionTextSpan)
    chars = collect(left.text)
    open = findfirst(==('['), chars)
    open === nothing && return nothing
    open_index = open - 1
    root = _action_trim_with_offsets(
        _action_slice(left.text, 0, open_index),
        left.start,
    )
    if !_action_is_identifier(root.text)
        message = root.text == "{}" ?
                  "nested write root must be a bare identifier" :
                  "nested write root must remain a bare identifier"
        _action_nested_write_syntax_error(
            code = "nested_write_root_not_addressable",
            start = root.start,
            stop = root.stop,
            message = message,
        )
    end
    if root.text in _ACTION_NESTED_WRITE_RESERVED_ROOTS
        _action_nested_write_syntax_error(
            code = "nested_write_root_reserved",
            start = root.start,
            stop = root.stop,
            message = "nested write root '$(root.text)' is reserved",
        )
    end

    segments = ActionWritePathSegment[]
    position = open_index
    while position < length(chars)
        while position < length(chars) && isspace(chars[position + 1])
            position += 1
        end
        position == length(chars) && break
        if chars[position + 1] != '['
            _action_nested_write_syntax_error(
                code = "nested_write_root_not_addressable",
                start = left.start,
                stop = left.stop,
                message = "nested write root must remain a bare identifier",
            )
        end
        close = _action_find_matching_delimiter(left.text, position, '[', ']')
        if close === nothing
            _action_nested_write_syntax_error(
                code = "nested_write_segment_unclosed",
                start = left.start + position,
                stop = left.stop,
                message = "nested write segment is missing its closing bracket",
            )
        end
        payload = _action_slice(left.text, position + 1, close)
        segment = _action_trim_with_offsets(
            payload,
            left.start + position + 1,
        )
        if isempty(segment.text)
            _action_nested_write_syntax_error(
                code = "nested_write_segment_empty",
                start = left.start + position,
                stop = left.start + close + 1,
                message = "nested write segment may not be empty",
            )
        end
        expression = parse_action_expression(segment.text, segment.start)
        if expression isa ActionRawExpr
            _action_nested_write_syntax_error(
                code = "nested_write_segment_expression_invalid",
                start = segment.start,
                stop = segment.stop,
                message = "segment must be one balanced ActionIR value expression",
            )
        end
        push!(segments, ActionWritePathSegment(
            source = segment.text,
            source_span = ActionSourceSpan(segment.start, segment.stop),
            expression = expression,
        ))
        position = close + 1
    end
    return (base = root.text, segments = segments)
end

function _action_nested_write_syntax_error(; code, start, stop, message)
    throw(ActionParseException(
        code = code,
        source_span = ActionSourceSpan(start, stop),
        message = message,
    ))
end

function _action_parse_fluent_chain(text::String, start::Int)
    segments = _action_split_top_level_fluent_segments(text)
    if length(segments) <= 1
        return nothing
    end
    receiver_segment = first(segments)
    receiver = _action_parse_expr_without_chain(receiver_segment.text, start + receiver_segment.start)
    calls = ActionFluentCall[]
    for index in 2:length(segments)
        segment = segments[index]
        call = _action_parse_fluent_call_segment(
            segment.text,
            start + segment.start,
            start + segment.stop;
            allow_bare_identifier = index == length(segments),
        )
        if call === nothing
            return ActionRawExpr(
                source = text,
                source_span = ActionSourceSpan(start, start + _action_len(text)),
                reason = "invalid_fluent_chain",
            )
        end
        push!(calls, call)
    end
    return ActionFluentChainExpr(
        source = text,
        source_span = ActionSourceSpan(start, start + _action_len(text)),
        receiver = receiver,
        calls = calls,
    )
end

function _action_parse_fluent_call_segment(
    text::String,
    start::Int,
    stop::Int;
    allow_bare_identifier::Bool = false,
)
    parsed = _action_parse_callee(text)
    if parsed !== nothing
        return ActionFluentCall(
            method = parsed.name,
            source_method = parsed.source_method,
            args = _action_parse_arguments(parsed.payload, start + parsed.payload_start),
            source = text,
            source_span = ActionSourceSpan(start, stop),
        )
    end
    bare = strip(text)
    if allow_bare_identifier && _action_is_identifier(bare)
        return ActionFluentCall(
            method = bare,
            source_method = bare,
            args = ActionArgument[],
            source = text,
            source_span = ActionSourceSpan(start, stop),
        )
    end
    attached = _action_split_attached_block(text)
    if attached === nothing
        return nothing
    end
    head = _action_trim_with_offsets(attached.head, start)
    head_call = _action_parse_callee(head.text)
    if head_call === nothing
        return nothing
    end
    args = _action_parse_arguments(head_call.payload, head.start + head_call.payload_start)
    block_source = _action_slice(text, attached.open_index, attached.close_index + 1)
    block_span = ActionSourceSpan(start + attached.open_index, start + attached.close_index + 1)
    push!(
        args,
        ActionPositionalArgument(
            ActionBlockValueExpr(
                source = block_source,
                source_span = block_span,
                block = _action_parse_block(attached.body, start + attached.open_index + 1),
            ),
        ),
    )
    return ActionFluentCall(
        method = head_call.name,
        source_method = head_call.source_method,
        args = args,
        source = text,
        source_span = ActionSourceSpan(start, stop),
        trailing_block_arg = true,
        receiver_trailing_block_arg = true,
        trailing_block_source_span = block_span,
    )
end

function _action_parse_arguments(payload::String, start::Int)
    args = ActionArgument[]
    for part in _action_split_top_level_csv(payload, start)
        if isempty(strip(part.text))
            continue
        end
        separator = _action_find_top_level_hash_pair_separator(part.text)
        if separator !== nothing && separator.token == ":"
            name = strip(_action_slice(part.text, 0, separator.index))
            if _action_is_identifier(name)
                value = _action_trim_with_offsets(
                    _action_slice(
                        part.text,
                        separator.index + separator.length,
                        _action_len(part.text),
                    ),
                    part.start + separator.index + separator.length,
                )
                push!(
                    args,
                    ActionKeywordArgument(
                        name = name,
                        value = parse_action_expression(value.text, value.start),
                    ),
                )
                continue
            end
        end
        expression = parse_action_expression(part.text, part.start)
        keyword_index = _action_find_top_level_assignment_equals(part.text)
        if keyword_index !== nothing && !(expression isa ActionAssignScalarExpr)
            name = strip(_action_slice(part.text, 0, keyword_index))
            if _action_is_identifier(name)
                value = _action_trim_with_offsets(
                    _action_slice(part.text, keyword_index + 1, _action_len(part.text)),
                    part.start + keyword_index + 1,
                )
                push!(
                    args,
                    ActionKeywordArgument(
                        name = name,
                        value = parse_action_expression(value.text, value.start),
                    ),
                )
                continue
            end
        end
        push!(args, ActionPositionalArgument(expression))
    end
    return args
end

function _action_parse_block(source::AbstractString, base_start::Int)
    text = String(source)
    pieces = _action_split_top_level_statements(text, base_start)
    return ActionBlock(
        source = text,
        source_span = ActionSourceSpan(base_start, base_start + _action_len(text)),
        statements = [
            parse_action_statement(piece.text, piece.start) for piece in pieces
        ],
    )
end

function _action_split_top_level_statements(text::String, base_start::Int)
    pieces = _ActionTextSpan[]
    state = _ActionScanState()
    segment_start = 0
    chars = collect(text)
    index = 0
    while index < length(chars)
        ch = chars[index + 1]
        if _action_consume_scan_char!(state, text, index, ch)
            index += 1
            continue
        end
        if ch == '}' && _action_is_top_level(state)
            next = _action_next_non_whitespace_index(text, index + 1)
            if next !== nothing && _action_starts_attached_branch_continuation(text, next)
                piece = _action_trim_with_offsets(_action_slice(text, segment_start, index + 1), base_start + segment_start)
                if !isempty(piece.text)
                    push!(pieces, piece)
                end
                segment_start = next
                index = next
                continue
            end
        end
        separator = _action_is_top_level(state) && (ch == ';' || ch == '\n' || ch == '\r')
        if separator
            piece = _action_trim_with_offsets(_action_slice(text, segment_start, index), base_start + segment_start)
            if !isempty(piece.text)
                push!(pieces, piece)
            end
            segment_start = index + 1
        end
        index += 1
    end
    final_piece = _action_trim_with_offsets(_action_slice(text, segment_start, length(chars)), base_start + segment_start)
    if !isempty(final_piece.text)
        push!(pieces, final_piece)
    end
    return pieces
end

function _action_next_non_whitespace_index(text::String, start::Int)
    chars = collect(text)
    for index in start:(length(chars) - 1)
        if !isspace(chars[index + 1])
            return index
        end
    end
    return nothing
end

function _action_starts_attached_branch_continuation(text::String, index::Int)
    for keyword in ("elseif", "elif", "else", "otherwise")
        if !_action_startswith_at(text, keyword, index)
            continue
        end
        stop = index + _action_len(keyword)
        chars = collect(text)
        if stop >= length(chars)
            return true
        end
        next = chars[stop + 1]
        if isspace(next) || next == '(' || next == '{'
            return true
        end
    end
    return false
end

_action_split_top_level_csv(text::String, base_start::Int) = _action_split_top_level_on(text, base_start, ',')

function _action_split_top_level_on(text::String, base_start::Int, separator::Char)
    pieces = _ActionTextSpan[]
    state = _ActionScanState()
    segment_start = 0
    chars = collect(text)
    for index in 0:(length(chars) - 1)
        ch = chars[index + 1]
        if _action_consume_scan_char!(state, text, index, ch)
            continue
        end
        if _action_is_top_level(state) && ch == separator
            piece = _action_trim_with_offsets(_action_slice(text, segment_start, index), base_start + segment_start)
            if !isempty(piece.text)
                push!(pieces, piece)
            end
            segment_start = index + 1
        end
    end
    final_piece = _action_trim_with_offsets(_action_slice(text, segment_start, length(chars)), base_start + segment_start)
    if !isempty(final_piece.text)
        push!(pieces, final_piece)
    end
    return pieces
end

_action_has_top_level_hash_pair_separator(text::String) = _action_find_top_level_hash_pair_separator(text) !== nothing

function _action_find_top_level_hash_pair_separator(text::String)
    state = _ActionScanState()
    chars = collect(text)
    for index in 0:(length(chars) - 1)
        ch = chars[index + 1]
        if _action_consume_scan_char!(state, text, index, ch)
            continue
        end
        if !_action_is_top_level(state)
            continue
        end
        if ch == '=' && index + 1 < length(chars) && chars[index + 2] == '>'
            return _ActionSeparator(index, 2, "=>")
        end
        if ch == ':'
            prev = index > 0 ? chars[index] : '\0'
            next = index + 1 < length(chars) ? chars[index + 2] : '\0'
            if prev != ':' && next != ':'
                return _ActionSeparator(index, 1, ":")
            end
        end
    end
    return nothing
end

function _action_find_top_level_token(text::String, token::String)
    state = _ActionScanState()
    chars = collect(text)
    token_len = _action_len(token)
    if token_len == 0 || token_len > length(chars)
        return nothing
    end
    for index in 0:(length(chars) - token_len)
        ch = chars[index + 1]
        if _action_consume_scan_char!(state, text, index, ch)
            continue
        end
        if _action_is_top_level(state) && _action_startswith_at(text, token, index)
            return index
        end
    end
    return nothing
end

function _action_find_top_level_assignment_equals(text::String)
    state = _ActionScanState()
    chars = collect(text)
    for index in 0:(length(chars) - 1)
        ch = chars[index + 1]
        if _action_consume_scan_char!(state, text, index, ch)
            continue
        end
        if !_action_is_top_level(state) || ch != '='
            continue
        end
        prev = index > 0 ? chars[index] : '\0'
        next = index + 1 < length(chars) ? chars[index + 2] : '\0'
        if prev in ('!', '<', '>', ':', '=') || next == '=' || next == '>'
            continue
        end
        return index
    end
    return nothing
end

function _action_find_unclosed_nested_write_assignment_equals(text::String)
    chars = collect(text)
    open = findfirst(==('['), chars)
    open === nothing && return nothing
    root = strip(_action_slice(text, 0, open - 1))
    _action_is_identifier(root) || return nothing
    _action_find_matching_delimiter(text, open - 1, '[', ']') === nothing ||
        return nothing

    state = _ActionScanState()
    for index in open:(length(chars) - 1)
        ch = chars[index + 1]
        if _action_consume_quoted_or_regex!(state, text, index, ch)
            continue
        end
        if ch == '"' || ch == '\''
            state.quote_char = ch
            continue
        end
        ch == '=' || continue
        prev = index > 0 ? chars[index] : '\0'
        next = index + 1 < length(chars) ? chars[index + 2] : '\0'
        if !(prev in ('!', '<', '>', ':', '=')) && next != '=' && next != '>'
            return index
        end
    end
    return nothing
end

function _action_split_attached_block(text::String)
    open = _action_find_top_level_open_brace(text, 0)
    if open === nothing
        return nothing
    end
    close = _action_find_matching_delimiter(text, open, '{', '}')
    if close === nothing || !isempty(strip(_action_slice(text, close + 1, _action_len(text))))
        return nothing
    end
    return _ActionAttachedBlock(
        _action_slice(text, 0, open),
        _action_slice(text, open + 1, close),
        open,
        close,
    )
end

function _action_find_top_level_open_brace(text::String, start::Int)
    state = _ActionScanState()
    chars = collect(text)
    for index in start:(length(chars) - 1)
        ch = chars[index + 1]
        if state.quote_char === nothing && !state.in_regex && _action_is_top_level(state) && ch == '{'
            return index
        end
        if _action_consume_scan_char!(state, text, index, ch)
            continue
        end
    end
    return nothing
end

function _action_parse_callee(text::String)
    trimmed = String(strip(text))
    open = _action_find_top_level_open_paren(trimmed)
    if open === nothing
        return nothing
    end
    close = _action_find_matching_delimiter(trimmed, open, '(', ')')
    if close != _action_len(trimmed) - 1
        return nothing
    end
    raw_name = strip(_action_slice(trimmed, 0, open))
    if !_action_is_identifier(raw_name) && !_action_is_symbol_callee(raw_name)
        return nothing
    end
    return _ActionParsedCallee(
        raw_name,
        raw_name,
        _action_slice(trimmed, open + 1, close),
        open + 1,
    )
end

function _action_find_top_level_open_paren(text::String)
    state = _ActionScanState()
    chars = collect(text)
    for index in 0:(length(chars) - 1)
        ch = chars[index + 1]
        if state.quote_char === nothing && !state.in_regex && _action_is_top_level(state) && ch == '('
            return index
        end
        if _action_consume_scan_char!(state, text, index, ch)
            continue
        end
    end
    return nothing
end

function _action_normalize_control_head(head::String)
    trimmed = strip(head)
    if isempty(trimmed)
        return nothing
    end
    if trimmed == "otherwise"
        return _ActionControlHead("else()", "otherwise")
    end
    if trimmed in ("else", "endif", "default", "endcase", "endswitch")
        return _ActionControlHead("$trimmed()", trimmed)
    end
    match_result = match(r"^([A-Za-z_]\w*)", trimmed)
    if match_result === nothing || _action_canonical_control_keyword(match_result.captures[1]) === nothing
        return nothing
    end
    return _ActionControlHead(trimmed, match_result.captures[1])
end

function _action_canonical_control_keyword(method::AbstractString)
    method = String(method)
    if method in ("i", "when")
        return "if"
    elseif method == "elif"
        return "elseif"
    elseif method == "otherwise"
        return "else"
    elseif method in ("if", "elseif", "else", "endif", "while", "switch", "case", "default", "endcase", "endswitch")
        return method
    end
    return nothing
end

function _action_split_top_level_fluent_segments(text::String)
    segments = _ActionTextSpan[]
    state = _ActionScanState()
    segment_start = 0
    chars = collect(text)
    for index in 0:(length(chars) - 1)
        ch = chars[index + 1]
        if _action_consume_scan_char!(state, text, index, ch)
            continue
        end
        if !_action_is_top_level(state) || ch != '.'
            continue
        end
        prev = index > 0 ? chars[index] : '\0'
        next = index + 1 < length(chars) ? chars[index + 2] : '\0'
        if _action_is_digit(prev) && _action_is_digit(next)
            continue
        end
        push!(segments, _action_trim_with_offsets(_action_slice(text, segment_start, index), segment_start))
        segment_start = index + 1
    end
    if isempty(segments)
        return _ActionTextSpan[]
    end
    push!(segments, _action_trim_with_offsets(_action_slice(text, segment_start, length(chars)), segment_start))
    return segments
end

function _action_is_identifier(value::AbstractString)
    return occursin(r"^[A-Za-z_]\w*$", String(value))
end

function _action_is_symbol_callee(value::AbstractString)
    return String(value) in ("+", "-", "*", "/", "%", "=", "==", "!=", ">", ">=", "<", "<=")
end

_action_is_digit(ch::Char) = '0' <= ch <= '9'

function _action_find_matching_delimiter(text::String, open_index::Int, open::Char, close::Char)
    depth = 0
    state = _ActionScanState()
    chars = collect(text)
    for index in open_index:(length(chars) - 1)
        ch = chars[index + 1]
        if _action_consume_quoted_or_regex!(state, text, index, ch)
            continue
        end
        if ch == '"' || ch == '\''
            state.quote_char = ch
            continue
        end
        if ch == '/' && _action_looks_like_regex_start(text, index)
            state.in_regex = true
            continue
        end
        if ch == open
            depth += 1
        elseif ch == close
            depth -= 1
            if depth == 0
                return index
            end
        end
    end
    return nothing
end

function _action_consume_scan_char!(state::_ActionScanState, text::String, index::Int, ch::Char)
    if _action_consume_quoted_or_regex!(state, text, index, ch)
        return true
    end
    if ch == '"' || ch == '\''
        state.quote_char = ch
        return true
    end
    if ch == '/' && _action_looks_like_regex_start(text, index)
        state.in_regex = true
        return true
    end
    if ch == '('
        state.paren_depth += 1
    elseif ch == ')'
        if state.paren_depth > 0
            state.paren_depth -= 1
        end
    elseif ch == '['
        state.bracket_depth += 1
    elseif ch == ']'
        if state.bracket_depth > 0
            state.bracket_depth -= 1
        end
    elseif ch == '{'
        state.brace_depth += 1
    elseif ch == '}'
        if state.brace_depth > 0
            state.brace_depth -= 1
        end
    end
    return false
end

function _action_consume_quoted_or_regex!(state::_ActionScanState, text::String, index::Int, ch::Char)
    if state.quote_char !== nothing
        if state.escaped
            state.escaped = false
            return true
        end
        if ch == '\\'
            state.escaped = true
            return true
        end
        if ch == state.quote_char
            state.quote_char = nothing
        end
        return true
    end
    if state.in_regex
        if state.escaped
            state.escaped = false
            return true
        end
        if ch == '\\'
            state.escaped = true
            return true
        end
        if ch == '/'
            state.in_regex = false
        end
        return true
    end
    return false
end

function _action_looks_like_regex_start(text::String, index::Int)
    chars = collect(text)
    next = index + 1 < length(chars) ? chars[index + 2] : '\0'
    if next == '(' || next == '\0' || isspace(next)
        return false
    end
    prev_index = index - 1
    while prev_index >= 0 && isspace(chars[prev_index + 1])
        prev_index -= 1
    end
    if prev_index < 0
        return true
    end
    return chars[prev_index + 1] in "([{,=:"
end

function _action_outer_delimiter_is_balanced(text::String, open::Char, close::Char)
    chars = collect(text)
    if isempty(chars) || chars[1] != open || chars[end] != close
        return false
    end
    return _action_find_matching_delimiter(text, 0, open, close) == length(chars) - 1
end

function _action_trim_with_offsets(text::AbstractString, base_start::Int)
    chars = collect(String(text))
    leading = 0
    while leading < length(chars) && isspace(chars[leading + 1])
        leading += 1
    end
    trailing = length(chars)
    while trailing > leading && isspace(chars[trailing])
        trailing -= 1
    end
    return _ActionTextSpan(
        _action_slice(String(text), leading, trailing),
        base_start + leading,
        base_start + trailing,
    )
end

function _action_unescape_string(payload::String)
    result = IOBuffer()
    chars = collect(payload)
    index = 1
    while index <= length(chars)
        ch = chars[index]
        if ch == '\\' && index < length(chars) && chars[index + 1] in ('\\', '\'', '"')
            print(result, chars[index + 1])
            index += 2
        else
            print(result, ch)
            index += 1
        end
    end
    return String(take!(result))
end

_action_len(text::AbstractString) = length(collect(String(text)))

function _action_slice(text::AbstractString, start::Int, stop::Int)
    chars = collect(String(text))
    safe_start = max(0, start)
    safe_stop = min(stop, length(chars))
    if safe_stop <= safe_start
        return ""
    end
    return String(chars[(safe_start + 1):safe_stop])
end

function _action_startswith_at(text::String, token::String, index::Int)
    token_len = _action_len(token)
    if index < 0 || index + token_len > _action_len(text)
        return false
    end
    return _action_slice(text, index, index + token_len) == token
end
