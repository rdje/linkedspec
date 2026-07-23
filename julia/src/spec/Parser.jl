struct SpecParseException <: Exception
    line::Int
    message::String
end

Base.showerror(io::IO, error::SpecParseException) = print(io, "SpecParseException(line ", error.line, "): ", error.message)

mutable struct _LineCursor
    index::Int
end

struct _ParsedHeader
    header::RuleHeader
    next_index::Int
end

struct _CollectedBody
    body::Vector{BodyElement}
    next_index::Int
end

struct _ParsedElement
    element::BodyElement
    remainder::String
    advanced::Bool
end

struct _ConsumedBlock
    code::String
    remainder::String
end

struct _AttachedCode
    code::String
    remainder::String
end

struct _LifecycleFluentCode
    code::String
    remainder::String
    advanced::Bool
end

struct _FluentParse
    calls::Vector{FluentCall}
    remainder::String
end

struct _ParenContent
    content::String
    close_index::Int
end

struct _BoundedMode
    base::String
    min::Int
    max::Union{Nothing,Int}
end

struct _ScanResult
    text::String
    depth::Int
end

const _REGEX_PATTERN = r"^/([^/\\]*(?:\\.[^/\\]*)*)/"
const _LIFECYCLE_PATTERN = r"^(I|LS|LE|LX|E|EX|IT)\b"
const _SPLIT_PATTERN = r"^@[ \t]*(capture_slice|capture_from_here|move_pos|mark[ \t]*\([ \t]*\w+[ \t]*\))"
const _CONDITIONAL_PATTERN = r"^-\?[ \t]+\w+"
const _FLUENT_PATTERN = r"^\.[ \t]*\w+"
const _BOUNDED_MODE_PATTERN = r"^(AND|OR)\{(\d*)(?:,(\d*))?\}$"

function _starts_with_at(text::String, prefix::AbstractString, offset::Int)
    return 1 <= offset <= ncodeunits(text) && startswith(SubString(text, offset), prefix)
end

function _skip_horizontal_space(text::String, offset::Int)
    cursor = offset
    while cursor <= ncodeunits(text)
        unit = codeunit(text, cursor)
        if unit != 0x20 && unit != 0x09
            break
        end
        cursor += 1
    end
    return cursor
end

function _substring_before(text::String, stop::Int)
    if stop <= firstindex(text)
        return ""
    end
    return String(SubString(text, firstindex(text), prevind(text, stop)))
end

function _substring_between(text::String, start::Int, stop::Int)
    if start >= stop
        return ""
    end
    return String(SubString(text, start, prevind(text, stop)))
end

function _substring_from(text::String, start::Int)
    return start > ncodeunits(text) ? "" : String(SubString(text, start))
end

function _take_rule_label_at(input::AbstractString, offset::Int)
    text = String(input)
    if offset < firstindex(text) || offset > ncodeunits(text)
        return nothing
    end
    scan = take_rule_label_prefix(SubString(text, offset))
    if scan === nothing
        return nothing
    end
    return (; label = scan.label, end_offset = offset + ncodeunits(scan.label))
end

function _parse_rule_header_fields(input::AbstractString)
    text = String(input)
    scan = take_rule_label_prefix(text)
    if scan === nothing
        return nothing
    end

    offset = _skip_horizontal_space(text, firstindex(text) + ncodeunits(scan.label))
    is_top = false
    if _starts_with_at(text, "::", offset)
        is_top = true
        offset += 2
    elseif _starts_with_at(text, ":", offset)
        offset += 1
    else
        return nothing
    end
    if _starts_with_at(text, ":", offset)
        return nothing
    end

    offset = _skip_horizontal_space(text, offset)
    mode_start = offset
    while offset <= ncodeunits(text)
        unit = codeunit(text, offset)
        if unit == 0x20 || unit == 0x09 || unit == 0x2F
            break
        end
        offset = nextind(text, offset)
    end
    mode_raw = _substring_between(text, mode_start, offset)
    offset = _skip_horizontal_space(text, offset)
    return (;
        label = scan.label,
        is_top,
        mode_raw,
        rest_raw = _substring_from(text, offset),
    )
end

function _parse_index_at(input::AbstractString, offset::Int; allow_space::Bool)
    text = String(input)
    cursor = allow_space ? _skip_horizontal_space(text, offset) : offset
    if !_starts_with_at(text, "[", cursor)
        return nothing
    end
    cursor += 1
    digits_start = cursor
    while cursor <= ncodeunits(text)
        unit = codeunit(text, cursor)
        if unit < 0x30 || unit > 0x39
            break
        end
        cursor += 1
    end
    if cursor == digits_start || !_starts_with_at(text, "]", cursor)
        return nothing
    end
    index = tryparse(Int, _substring_between(text, digits_start, cursor))
    if index === nothing
        return nothing
    end
    return (; index, end_offset = cursor + 1)
end

function _has_valid_edge_remainder(input::AbstractString, offset::Int)
    text = String(input)
    if offset > ncodeunits(text)
        return true
    end
    begins_with_space = codeunit(text, offset) in (0x20, 0x09)
    trimmed_offset = _skip_horizontal_space(text, offset)
    trimmed = _substring_from(text, trimmed_offset)
    if isempty(trimmed) || startswith(trimmed, "#")
        return true
    end
    if startswith(trimmed, "{") || startswith(trimmed, ".") ||
            startswith(trimmed, "->") || startswith(trimmed, "=>")
        return true
    end
    return begins_with_space && (
        startswith(trimmed, "/") ||
        match(_LIFECYCLE_PATTERN, trimmed) !== nothing ||
        match(_SPLIT_PATTERN, trimmed) !== nothing ||
        match(_CONDITIONAL_PATTERN, trimmed) !== nothing
    )
end

function _parse_action_edge_prefix(input::AbstractString)
    text = String(input)
    if !startswith(text, "->")
        return nothing
    end
    offset = _skip_horizontal_space(text, 3)
    labels = String[]
    while true
        target = _take_rule_label_at(text, offset)
        if target === nothing
            return nothing
        end
        push!(labels, target.label)
        offset = target.end_offset

        after_space = _skip_horizontal_space(text, offset)
        if !_starts_with_at(text, "|", after_space)
            break
        end
        offset = _skip_horizontal_space(text, after_space + 1)
        if _take_rule_label_at(text, offset) === nothing
            return nothing
        end
    end

    parsed_index = _parse_index_at(text, offset; allow_space = false)
    index = parsed_index === nothing ? 0 : parsed_index.index
    end_offset = parsed_index === nothing ? offset : parsed_index.end_offset
    if !_has_valid_edge_remainder(text, end_offset)
        return nothing
    end
    return (;
        targets = [EdgeTarget(label = label, index = index) for label in labels],
        end_offset,
    )
end

function _parse_blind_edge_prefix(input::AbstractString)
    text = String(input)
    if !startswith(text, "=>")
        return nothing
    end
    target = _take_rule_label_at(text, _skip_horizontal_space(text, 3))
    if target === nothing
        return nothing
    end
    parsed_index = _parse_index_at(text, target.end_offset; allow_space = true)
    end_offset = parsed_index === nothing ? target.end_offset : parsed_index.end_offset
    if !_has_valid_edge_remainder(text, end_offset)
        return nothing
    end
    return (;
        target = target.label,
        index = parsed_index === nothing ? nothing : parsed_index.index,
        end_offset,
    )
end

function _parse_bare_edge_prefix(input::AbstractString)
    text = String(input)
    offset = firstindex(text)
    labels = String[]
    while true
        target = _take_rule_label_at(text, offset)
        if target === nothing
            return nothing
        end
        push!(labels, target.label)
        offset = target.end_offset

        after_space = _skip_horizontal_space(text, offset)
        if !_starts_with_at(text, "|", after_space)
            break
        end
        offset = _skip_horizontal_space(text, after_space + 1)
        if _take_rule_label_at(text, offset) === nothing
            return nothing
        end
    end

    parsed_index = _parse_index_at(text, offset; allow_space = true)
    index = parsed_index === nothing ? nothing : parsed_index.index
    end_offset = parsed_index === nothing ? offset : parsed_index.end_offset
    return (;
        targets = [BareEdgeTarget(label = label, index = index) for label in labels],
        end_offset,
    )
end

_starts_with_edge_token(input::AbstractString) = startswith(input, "->") || startswith(input, "=>")

function parse_spec(
    source::AbstractString;
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    source_text = String(source)
    if trace === nothing
        return _parse_spec(source_text)
    end

    scope = enter_trace_scope!(
        trace,
        "julia_frontend:parse_spec",
        "bytes=$(ncodeunits(source_text)) lines=$(length(split(source_text, '\n'; keepempty = true)))",
        LinkedSpecTraceLow,
    )
    exit_details = "status=error error=unknown"
    try
        spec = _parse_spec(source_text)
        trace_decision!(
            trace,
            "julia_frontend:parse_spec:result",
            true,
            "rules=$(length(spec.rules)) functions=$(length(spec.functions))",
            LinkedSpecTraceMedium,
        )
        exit_details = "status=ok rules=$(length(spec.rules))"
        return spec
    catch error
        message = sprint(showerror, error)
        trace_decision!(
            trace,
            "julia_frontend:parse_spec:result",
            false,
            "error=$message",
            LinkedSpecTraceMedium,
        )
        exit_details = "status=error error=$message"
        rethrow()
    finally
        exit_trace_scope!(trace, scope, exit_details)
    end
end

function _parse_spec(source::String)
    lines = split(source, '\n'; keepempty = true)
    rules = Rule[]
    index = _skip_blanks_and_comments(lines, 1)

    while index <= length(lines)
        parsed_header = _parse_rule_header(lines, index)
        if parsed_header !== nothing
            header = parsed_header.header
            rest = strip(header.rest)
            body_start_index = parsed_header.next_index
            inline_elements = BodyElement[]

            if !isempty(rest)
                inline_cursor = _LineCursor(header.line)
                parsed_inline = _parse_inline_body(rest, header.line, lines, inline_cursor)
                if parsed_inline !== nothing
                    inline_elements = parsed_inline
                    if inline_cursor.index > body_start_index
                        body_start_index = inline_cursor.index
                    end
                end
            end

            collected = _collect_body(lines, body_start_index)
            push!(rules, Rule(header = header, body = vcat(inline_elements, collected.body)))
            index = collected.next_index
            continue
        end

        if isempty(rules)
            throw(SpecParseException(index, "expected rule definition to start with a rule label (Word: or Word::), got: $(strip(lines[index]))"))
        end
        index += 1
    end

    return SpecFile(rules = rules)
end

function _skip_blanks_and_comments(lines::Vector{SubString{String}}, index::Int)
    next = index
    while next <= length(lines)
        trimmed = strip(lines[next])
        if isempty(trimmed) || startswith(trimmed, "#")
            next += 1
        else
            break
        end
    end
    return next
end

function _parse_rule_header(lines, index::Int)
    if index > length(lines)
        return nothing
    end

    trimmed = strip(lines[index])
    fields = _parse_rule_header_fields(trimmed)
    if fields === nothing
        return nothing
    end

    label = fields.label
    mode_raw = fields.mode_raw
    rest_raw = fields.rest_raw
    parsed_mode = _parse_mode_suffix_strict(mode_raw)

    if parsed_mode === nothing
        rest = isempty(rest_raw) ? mode_raw : "$mode_raw $rest_raw"
        mode = default_rule_mode()
    else
        rest = rest_raw
        mode = parsed_mode
    end

    return _ParsedHeader(RuleHeader(label, fields.is_top, mode, rest, index), index + 1)
end

function _parse_mode_suffix_strict(raw::AbstractString)
    if isempty(raw)
        return default_rule_mode()
    end

    bounded = _parse_bounded(raw)
    if bounded !== nothing
        if bounded.base == "AND"
            return and_bounded_rule_mode(min = bounded.min, max = bounded.max)
        elseif bounded.base == "OR"
            return or_bounded_rule_mode(min = bounded.min, max = bounded.max)
        end
        return nothing
    end

    if raw == "AND"
        return RuleMode("And")
    elseif raw == "AND+"
        return RuleMode("AndPlus")
    elseif raw == "OR"
        return RuleMode("Or")
    elseif raw == "OR+"
        return RuleMode("OrPlus")
    elseif raw == "&"
        return RuleMode("Single")
    elseif raw == "|"
        return RuleMode("Pipe")
    elseif raw == "+"
        return RuleMode("Plus")
    elseif raw == "*"
        return RuleMode("Star")
    elseif raw == "?"
        return RuleMode("Optional")
    end
    return nothing
end

function _parse_bounded(raw::AbstractString)
    match_result = match(_BOUNDED_MODE_PATTERN, raw)
    if match_result === nothing
        return nothing
    end

    min_text = match_result.captures[2]
    max_text = match_result.captures[3]
    min_value = isempty(min_text) ? 0 : tryparse(Int, min_text)
    if min_value === nothing
        return nothing
    end

    max_value = nothing
    if max_text === nothing
        max_value = min_value
    elseif isempty(max_text)
        max_value = nothing
    else
        parsed_max = tryparse(Int, max_text)
        if parsed_max === nothing || parsed_max < min_value
            return nothing
        end
        max_value = parsed_max
    end

    return _BoundedMode(match_result.captures[1], min_value, max_value)
end

function _parse_inline_body(rest::AbstractString, line_number::Int, lines, cursor::_LineCursor)
    elements = BodyElement[]
    remaining = strip(rest)

    while !isempty(remaining)
        trimmed = strip(remaining)
        if isempty(trimmed) || startswith(trimmed, "#")
            break
        end

        before = trimmed
        parsed = _parse_single_element(
            trimmed,
            lines,
            cursor,
            line_number;
            allow_bare_edge = isempty(elements),
        )
        if parsed === nothing
            if isempty(elements) || _starts_with_edge_token(trimmed)
                push!(elements, BodyElement(RawBodyElementKind(trimmed), trimmed, line_number))
            end
            break
        end
        push!(elements, parsed.element)
        remaining = parsed.remainder
        if strip(remaining) == before
            break
        end
    end

    return isempty(elements) ? nothing : elements
end

function _collect_body(lines, start::Int)
    body = BodyElement[]
    cursor = _LineCursor(start)

    while cursor.index <= length(lines)
        trimmed = strip(lines[cursor.index])
        line_number = cursor.index

        if isempty(trimmed) || startswith(trimmed, "#")
            cursor.index += 1
            continue
        end

        if _parse_rule_header_fields(trimmed) !== nothing
            break
        end

        elements = _parse_body_elements(lines, cursor)
        _collect_action_edge_fluent_continuation_lines(lines, cursor, elements)
        if isempty(elements)
            push!(body, BodyElement(RawBodyElementKind(trimmed), trimmed, line_number))
            cursor.index += 1
        else
            append!(body, elements)
        end
    end

    return _CollectedBody(body, cursor.index)
end

function _collect_action_edge_fluent_continuation_lines(lines, cursor::_LineCursor, elements::Vector{BodyElement})
    if isempty(elements)
        return nothing
    end

    last_kind = elements[end].kind
    if !(last_kind isa ActionEdgeBodyElementKind)
        return nothing
    end

    while cursor.index <= length(lines)
        trimmed = strip(lines[cursor.index])
        if isempty(trimmed) || startswith(trimmed, "#") || !startswith(trimmed, ".")
            break
        end

        parsed = _parse_fluent_chain_with_remainder(trimmed)
        remainder = strip(parsed.remainder)
        if isempty(parsed.calls) || (!isempty(remainder) && !startswith(remainder, "#"))
            break
        end

        append!(last_kind.fluent_chain, parsed.calls)
        cursor.index += 1
    end
    return nothing
end

function _parse_body_elements(lines, cursor::_LineCursor)
    elements = BodyElement[]
    line = String(lines[cursor.index])
    line_number = cursor.index
    remaining = strip(line)
    advanced_past_current_line = false

    while true
        trimmed = strip(remaining)
        if isempty(trimmed) || startswith(trimmed, "#")
            break
        end

        parsed = _parse_single_element(
            trimmed,
            lines,
            cursor,
            line_number;
            allow_bare_edge = isempty(elements),
        )
        if parsed === nothing
            if isempty(elements) || _starts_with_edge_token(trimmed)
                push!(elements, BodyElement(RawBodyElementKind(trimmed), trimmed, line_number))
            end
            break
        end

        push!(elements, parsed.element)
        remaining = parsed.remainder
        if parsed.advanced
            advanced_past_current_line = true
        end
        if isempty(strip(remaining))
            break
        end
    end

    if !isempty(elements) && !advanced_past_current_line
        cursor.index += 1
    end

    return elements
end

function _parse_single_element(
    trimmed::AbstractString,
    lines,
    cursor::_LineCursor,
    line_number::Int;
    allow_bare_edge::Bool,
)
    regex_match = match(_REGEX_PATTERN, trimmed)
    if regex_match !== nothing
        full_match = regex_match.match
        return _ParsedElement(
            BodyElement(RegexBodyElementKind(regex_match.captures[1]), full_match, line_number),
            _drop_prefix(trimmed, full_match),
            false,
        )
    end

    action_prefix = _parse_action_edge_prefix(trimmed)
    if action_prefix !== nothing
        full_match = _substring_before(String(trimmed), action_prefix.end_offset)
        targets = action_prefix.targets
        rest = lstrip(_drop_prefix(trimmed, full_match))
        saved_index = cursor.index

        attached = _parse_attached_fluent_when_chain(lines, cursor, rest)
        if attached !== nothing
            return _ParsedElement(
                BodyElement(ActionEdgeBodyElementKind(targets = targets, code = attached.code), full_match, line_number),
                attached.remainder,
                cursor.index > saved_index,
            )
        end

        if startswith(rest, "{")
            block = _consume_block_from_rest(lines, cursor, rest)
            if block === nothing
                return nothing
            end
            return _ParsedElement(
                BodyElement(ActionEdgeBodyElementKind(targets = targets, code = block.code), full_match, line_number),
                block.remainder,
                cursor.index > saved_index,
            )
        end

        fluent = _parse_fluent_chain_with_remainder(rest)
        return _ParsedElement(
            BodyElement(ActionEdgeBodyElementKind(targets = targets, fluent_chain = fluent.calls), full_match, line_number),
            fluent.remainder,
            false,
        )
    end

    blind_prefix = _parse_blind_edge_prefix(trimmed)
    if blind_prefix !== nothing
        full_match = _substring_before(String(trimmed), blind_prefix.end_offset)
        target = blind_prefix.target
        index = blind_prefix.index
        rest = lstrip(_drop_prefix(trimmed, full_match))
        saved_index = cursor.index

        if startswith(rest, "{")
            block = _consume_block_from_rest(lines, cursor, rest)
            if block === nothing
                return nothing
            end
            code = block.code
            fluent_chain = FluentCall[]
            remainder = block.remainder
        else
            fluent = _parse_fluent_chain_with_remainder(rest)
            code = nothing
            fluent_chain = fluent.calls
            remainder = fluent.remainder
        end

        return _ParsedElement(
            BodyElement(
                BlindEdgeBodyElementKind(
                    target = target,
                    index = index,
                    code = code,
                    fluent_chain = fluent_chain,
                ),
                full_match,
                line_number,
            ),
            remainder,
            cursor.index > saved_index,
        )
    end

    lifecycle_match = match(_LIFECYCLE_PATTERN, trimmed)
    if lifecycle_match !== nothing
        full_match = lifecycle_match.match
        marker = lifecycle_match.captures[1]
        rest = lstrip(_drop_prefix(trimmed, full_match))
        saved_index = cursor.index

        attached = _parse_attached_fluent_when_chain(lines, cursor, rest)
        if attached !== nothing
            return _ParsedElement(
                BodyElement(CodeBlockBodyElementKind(marker, attached.code), full_match, line_number),
                attached.remainder,
                cursor.index > saved_index,
            )
        end

        if startswith(rest, "{")
            block = _consume_block_from_rest(lines, cursor, rest)
            if block === nothing
                return nothing
            end
            return _ParsedElement(
                BodyElement(CodeBlockBodyElementKind(marker, block.code), full_match, line_number),
                block.remainder,
                cursor.index > saved_index,
            )
        end

        fluent = _parse_lifecycle_fluent_chain_statement_code(lines, cursor, rest)
        if fluent !== nothing
            return _ParsedElement(
                BodyElement(CodeBlockBodyElementKind(marker, fluent.code), full_match, line_number),
                fluent.remainder,
                fluent.advanced,
            )
        end

        return _ParsedElement(BodyElement(LifecycleMarkerBodyElementKind(marker), full_match, line_number), rest, false)
    end

    split_match = match(_SPLIT_PATTERN, trimmed)
    if split_match !== nothing
        full_match = split_match.match
        return _ParsedElement(
            BodyElement(SplitMarkerBodyElementKind(full_match), full_match, line_number),
            _drop_prefix(trimmed, full_match),
            false,
        )
    end

    conditional_match = match(_CONDITIONAL_PATTERN, trimmed)
    if conditional_match !== nothing
        full_match = conditional_match.match
        return _ParsedElement(
            BodyElement(ConditionalBodyElementKind(strip(_drop_prefix(full_match, "-?"))), full_match, line_number),
            _drop_prefix(trimmed, full_match),
            false,
        )
    end

    fluent_match = match(_FLUENT_PATTERN, trimmed)
    if fluent_match !== nothing
        full_match = fluent_match.match
        return _ParsedElement(
            BodyElement(FluentChainBodyElementKind(calls = _parse_fluent_chain_with_remainder(trimmed).calls), full_match, line_number),
            "",
            false,
        )
    end

    if startswith(trimmed, "{")
        saved_index = cursor.index
        block = _consume_block_from_rest(lines, cursor, trimmed)
        if block === nothing
            return nothing
        end
        return _ParsedElement(
            BodyElement(PlainBlockBodyElementKind(block.code), String(trimmed), line_number),
            block.remainder,
            cursor.index > saved_index,
        )
    end

    if allow_bare_edge
        bare = _parse_bare_edge(trimmed, lines, cursor, line_number)
        if bare !== nothing
            return bare
        end
    end

    return nothing
end

function _parse_bare_edge(trimmed::AbstractString, lines, cursor::_LineCursor, line_number::Int)
    bare_prefix = _parse_bare_edge_prefix(trimmed)
    if bare_prefix === nothing
        return nothing
    end

    full_match = _substring_before(String(trimmed), bare_prefix.end_offset)
    targets = bare_prefix.targets
    rest = lstrip(_drop_prefix(trimmed, full_match))
    saved_index = cursor.index

    if isempty(rest) || startswith(rest, "#")
        return _ParsedElement(
            BodyElement(BareEdgeBodyElementKind(targets = targets), full_match, line_number),
            rest,
            false,
        )
    end

    if startswith(rest, "{")
        block = _consume_block_from_rest(lines, cursor, rest)
        if block === nothing
            return nothing
        end
        return _ParsedElement(
            BodyElement(
                BareEdgeBodyElementKind(targets = targets, code = block.code),
                full_match,
                line_number,
            ),
            block.remainder,
            cursor.index > saved_index,
        )
    end

    if startswith(rest, ".")
        fluent = _parse_fluent_chain_with_remainder(rest)
        remainder = strip(fluent.remainder)
        if isempty(fluent.calls) || (!isempty(remainder) && !startswith(remainder, "#"))
            return nothing
        end
        return _ParsedElement(
            BodyElement(
                BareEdgeBodyElementKind(targets = targets, fluent_chain = fluent.calls),
                full_match,
                line_number,
            ),
            fluent.remainder,
            false,
        )
    end

    return nothing
end

function _consume_block_from_rest(lines, cursor::_LineCursor, rest::AbstractString)
    start_brace = findfirst(==('{'), rest)
    if start_brace === nothing
        return nothing
    end

    remainder = _after_index(rest, start_brace)
    depth = 1
    content = ""
    first_scan = _scan_line_for_braces(remainder, depth)
    depth = first_scan.depth

    if depth == 0
        block_content = endswith(first_scan.text, "}") ? strip(_drop_last_char(first_scan.text)) : strip(first_scan.text)
        return _ConsumedBlock(block_content, strip(_drop_prefix(remainder, first_scan.text)))
    end

    if !isempty(strip(first_scan.text))
        content = strip(first_scan.text)
    end

    cursor.index += 1
    while cursor.index <= length(lines) && depth > 0
        line = String(lines[cursor.index])
        scanned = _scan_line_for_braces(line, depth)
        depth = scanned.depth

        if depth == 0
            without_close = endswith(scanned.text, "}") ? _drop_last_char(scanned.text) : scanned.text
            if !isempty(strip(without_close))
                if !isempty(content)
                    content *= "\n"
                end
                content *= strip(without_close)
            end
            cursor.index += 1
            return _ConsumedBlock(strip(content), strip(_drop_prefix(line, scanned.text)))
        end

        if !isempty(content)
            content *= "\n"
        end
        content *= strip(line)
        cursor.index += 1
    end

    return _ConsumedBlock(strip(content), "")
end

function _parse_attached_fluent_when_chain(lines, cursor::_LineCursor, rest::AbstractString)
    after_when = _strip_required_dot_keyword(rest, "when")
    if after_when === nothing
        return nothing
    end

    remaining = lstrip(after_when)
    if !startswith(remaining, "(")
        return nothing
    end

    condition = _extract_paren_content_with_end(remaining)
    if condition === nothing
        return nothing
    end
    remaining = lstrip(_after_index(remaining, condition.close_index))
    if !startswith(remaining, "{")
        return nothing
    end

    when_start_index = cursor.index
    when_body = _consume_block_from_rest(lines, cursor, remaining)
    if when_body === nothing
        return nothing
    end
    code = "when($(strip(condition.content))) { $(strip(when_body.code)) }"
    remaining = when_body.remainder
    remaining_origin_index = _block_remainder_origin(when_start_index, cursor.index, remaining)

    while true
        after_otherwise = _strip_optional_dot_keyword(remaining, "otherwise")
        if after_otherwise === nothing
            break
        end

        remainder_after_otherwise = lstrip(after_otherwise)
        if !startswith(remainder_after_otherwise, "{")
            break
        end

        block_origin_index = remaining_origin_index
        current_floor_index = cursor.index
        block_cursor = _LineCursor(block_origin_index)
        otherwise_body = _consume_block_from_rest(lines, block_cursor, remainder_after_otherwise)
        if otherwise_body === nothing
            break
        end
        code *= " otherwise { $(strip(otherwise_body.code)) }"
        remaining = otherwise_body.remainder
        cursor.index = block_cursor.index > current_floor_index ? block_cursor.index : current_floor_index
        remaining_origin_index = isempty(strip(remaining)) ? cursor.index : _block_remainder_origin(block_origin_index, block_cursor.index, remaining)
    end

    return _AttachedCode(code, lstrip(remaining))
end

function _block_remainder_origin(start_index::Int, end_index::Int, remainder::AbstractString)
    if !isempty(strip(remainder)) && end_index > start_index
        return end_index - 1
    end
    return end_index
end

function _strip_required_dot_keyword(text::AbstractString, keyword::AbstractString)
    trimmed = lstrip(text)
    if !startswith(trimmed, ".")
        return nothing
    end
    return _strip_keyword(lstrip(_drop_prefix(trimmed, ".")), keyword)
end

function _strip_optional_dot_keyword(text::AbstractString, keyword::AbstractString)
    trimmed = lstrip(text)
    candidate = startswith(trimmed, ".") ? lstrip(_drop_prefix(trimmed, ".")) : trimmed
    return _strip_keyword(candidate, keyword)
end

function _strip_keyword(text::AbstractString, keyword::AbstractString)
    trimmed = lstrip(text)
    if !startswith(trimmed, keyword)
        return nothing
    end
    after = _drop_prefix(trimmed, keyword)
    if !isempty(after)
        code = Int(first(after))
        if _is_ascii_alnum(code) || first(after) == '_'
            return nothing
        end
    end
    return after
end

function _parse_lifecycle_fluent_chain_statement_code(lines, cursor::_LineCursor, rest::AbstractString)
    start_index = cursor.index
    text = lstrip(rest)
    if !startswith(text, ".")
        return nothing
    end

    while !_compact_fluent_chain_parentheses_are_complete(text)
        if cursor.index + 1 > length(lines)
            return nothing
        end
        cursor.index += 1
        text = "$text\n$(strip(lines[cursor.index]))"
    end

    parsed = _parse_fluent_chain_with_remainder(text)
    code = _fluent_calls_to_statement_code(parsed.calls)
    if code === nothing
        return nothing
    end
    advanced = cursor.index > start_index
    if advanced
        cursor.index += 1
    end
    return _LifecycleFluentCode(code, parsed.remainder, advanced)
end

function _fluent_calls_to_statement_code(calls::Vector{FluentCall})
    if isempty(calls) || any(call -> isempty(strip(call.method)), calls)
        return nothing
    end
    return join(["$(strip(call.method))($(strip(call.args)))" for call in calls], "; ")
end

function _compact_fluent_chain_parentheses_are_complete(text::AbstractString)
    chars = collect(String(text))
    position = _skip_char_whitespace(chars, 1)
    if !_has_char_at(chars, position, '.')
        return true
    end

    while position <= length(chars)
        position = _skip_char_whitespace(chars, position)
        if !_has_char_at(chars, position, '.')
            return true
        end
        position += 1
        position = _skip_char_whitespace(chars, position)
        method_start = position
        while position <= length(chars)
            code = Int(chars[position])
            if !_is_ascii_alnum(code) && chars[position] != '_'
                break
            end
            position += 1
        end
        if position == method_start
            return true
        end

        position = _skip_char_whitespace(chars, position)
        if !_has_char_at(chars, position, '(')
            return true
        end
        position += 1
        depth = 1
        while position <= length(chars)
            char = chars[position]
            if char == '"' || char == '\''
                next_position = _skip_delimited_literal(chars, position, char)
                if next_position === nothing
                    return false
                end
                position = next_position
            elseif char == '/'
                next_position = _skip_regex_literal(chars, position)
                position = next_position === nothing ? position + 1 : next_position
            elseif char == '('
                depth += 1
                position += 1
            elseif char == ')'
                depth -= 1
                position += 1
                if depth == 0
                    break
                end
            else
                position += 1
            end
        end
        if depth != 0
            return false
        end

        position = _skip_char_whitespace(chars, position)
        if !_has_char_at(chars, position, '.')
            return true
        end
    end

    return true
end

function _scan_line_for_braces(text::AbstractString, initial_depth::Int)
    depth = initial_depth
    quote_char = nothing
    escaped = false

    for index in eachindex(text)
        char = text[index]
        if quote_char !== nothing
            if escaped
                escaped = false
                continue
            end
            if char == '\\'
                escaped = true
                continue
            end
            if char == quote_char
                quote_char = nothing
            end
            continue
        end

        if char == '"' || char == '\''
            quote_char = char
        elseif char == '{'
            depth += 1
        elseif char == '}'
            depth -= 1
            if depth == 0
                return _ScanResult(String(text[firstindex(text):index]), depth)
            end
        end
    end

    return _ScanResult(String(text), depth)
end

function _parse_fluent_chain_with_remainder(text::AbstractString)
    calls = FluentCall[]
    remaining = strip(text)

    while startswith(remaining, ".")
        remaining = _drop_prefix(remaining, ".")
        method, remaining = _take_method_name(remaining)

        if startswith(remaining, "(")
            paren = _extract_paren_content_with_end(remaining)
            if paren !== nothing
                remaining = lstrip(_after_index(remaining, paren.close_index))
                push!(calls, FluentCall(method, paren.content))
            else
                push!(calls, FluentCall(method, ""))
                remaining = ""
            end
        else
            push!(calls, FluentCall(method, ""))
        end
    end

    return _FluentParse(calls, remaining)
end

function _take_method_name(text::AbstractString)
    for index in eachindex(text)
        char = text[index]
        code = Int(char)
        if !_is_ascii_alnum(code) && char != '_'
            before = index == firstindex(text) ? "" : String(text[firstindex(text):prevind(text, index)])
            return before, String(text[index:end])
        end
    end
    return String(text), ""
end

function _extract_paren_content_with_end(text::AbstractString)
    if !startswith(text, "(")
        return nothing
    end

    depth = 0
    for index in eachindex(text)
        char = text[index]
        if char == '('
            depth += 1
        elseif char == ')'
            depth -= 1
            if depth == 0
                content_start = nextind(text, firstindex(text))
                content = content_start > prevind(text, index) ? "" : String(text[content_start:prevind(text, index)])
                return _ParenContent(content, index)
            end
        end
    end
    return nothing
end

function _skip_char_whitespace(chars::Vector{Char}, start::Int)
    position = start
    while position <= length(chars) && chars[position] in (' ', '\t', '\n', '\r')
        position += 1
    end
    return position
end

function _skip_delimited_literal(chars::Vector{Char}, start::Int, delimiter::Char)
    position = start + 1
    while position <= length(chars)
        if chars[position] == '\\'
            position += 2
            continue
        end
        if chars[position] == delimiter
            return position + 1
        end
        position += 1
    end
    return nothing
end

function _skip_regex_literal(chars::Vector{Char}, start::Int)
    position = start + 1
    while position <= length(chars)
        if chars[position] == '\\'
            position += 2
            continue
        end
        if chars[position] == '/'
            position += 1
            while position <= length(chars) && _is_ascii_alpha(Int(chars[position]))
                position += 1
            end
            return position
        end
        position += 1
    end
    return nothing
end

_has_char_at(chars::Vector{Char}, position::Int, expected::Char) = position <= length(chars) && chars[position] == expected

function _drop_prefix(text::AbstractString, prefix::AbstractString)
    if isempty(prefix)
        return String(text)
    end
    offset = ncodeunits(prefix) + 1
    return offset > ncodeunits(text) ? "" : String(SubString(String(text), offset))
end

function _drop_last_char(text::AbstractString)
    if isempty(text)
        return ""
    end
    if firstindex(text) == lastindex(text)
        return ""
    end
    return String(text[firstindex(text):prevind(text, lastindex(text))])
end

function _after_index(text::AbstractString, index::Int)
    next_index = nextind(text, index)
    return next_index > lastindex(text) ? "" : String(text[next_index:end])
end

_is_ascii_alnum(code::Int) = _is_ascii_alpha(code) || ('0' <= Char(code) <= '9')
_is_ascii_alpha(code::Int) = ('A' <= Char(code) <= 'Z') || ('a' <= Char(code) <= 'z')
