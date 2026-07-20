struct RuntimeRegexException <: Exception
    message::String
end

Base.showerror(io::IO, error::RuntimeRegexException) = print(io, error.message)

@enum LinkedSpecParseMode begin
    SeekParseMode
    ConsumeParseMode
end

function parse_mode_from_name(name::AbstractString)
    value = String(name)
    if value == "seek"
        return SeekParseMode
    elseif value == "consume"
        return ConsumeParseMode
    end
    throw(RuntimeRegexException("unsupported parse mode '$value'"))
end

parse_mode_name(mode::LinkedSpecParseMode) = mode == SeekParseMode ? "seek" : "consume"

struct RuntimeRegexAlternative
    index::Int
    pattern::String
    regex::Regex
end

struct RuntimeRegexAlternation
    alternatives::Vector{RuntimeRegexAlternative}
end

function RuntimeRegexAlternation(patterns::AbstractVector{<:AbstractString})
    alternatives = RuntimeRegexAlternative[]
    for (one_based_index, raw_pattern) in enumerate(patterns)
        pattern = String(raw_pattern)
        regex = try
            Regex(pattern)
        catch error
            detail = sprint(showerror, error)
            throw(RuntimeRegexException(
                "regex compile error for alternative $(one_based_index - 1) '/$pattern/': $detail",
            ))
        end
        push!(alternatives, RuntimeRegexAlternative(one_based_index - 1, pattern, regex))
    end
    return RuntimeRegexAlternation(alternatives)
end

RuntimeRegexAlternation(rule::CompiledRule) = RuntimeRegexAlternation(rule.regex_patterns)
compile_runtime_regex_alternation(patterns) =
    RuntimeRegexAlternation(String[String(pattern) for pattern in patterns])

Base.isempty(alternation::RuntimeRegexAlternation) = isempty(alternation.alternatives)
Base.length(alternation::RuntimeRegexAlternation) = length(alternation.alternatives)

struct RuntimeRegexMatch
    input::String
    alternative_index::Int
    pattern::String
    codeunit_start::Int
    codeunit_end::Int
    groups::Vector{String}
    captures::Vector{String}
    named::Dict{String,String}
end

function reindex_runtime_regex_match(match::RuntimeRegexMatch, alternative_index::Int)
    return RuntimeRegexMatch(
        match.input,
        alternative_index,
        match.pattern,
        match.codeunit_start,
        match.codeunit_end,
        match.groups,
        match.captures,
        match.named,
    )
end

match_text(match::RuntimeRegexMatch) = isempty(match.groups) ? "" : first(match.groups)
codeunit_length(match::RuntimeRegexMatch) = match.codeunit_end - match.codeunit_start
char_start(match::RuntimeRegexMatch) = codeunit_offset_to_char_offset(match.input, match.codeunit_start)
char_end(match::RuntimeRegexMatch) = codeunit_offset_to_char_offset(match.input, match.codeunit_end)
char_length(match::RuntimeRegexMatch) = char_end(match) - char_start(match)
is_zero_width(match::RuntimeRegexMatch) = match.codeunit_start == match.codeunit_end
named_capture(match::RuntimeRegexMatch, name::AbstractString) = get(match.named, String(name), nothing)

function made_progress_from(match::RuntimeRegexMatch, codeunit_cursor::Int)
    return match.codeunit_end > _checked_codeunit_offset(match.input, codeunit_cursor)
end

function is_zero_progress_from(match::RuntimeRegexMatch, codeunit_cursor::Int)
    return match.codeunit_end == _checked_codeunit_offset(match.input, codeunit_cursor)
end

function runtime_match(
    alternation::RuntimeRegexAlternation,
    input::AbstractString,
    codeunit_cursor::Int = 0;
    parse_mode = SeekParseMode,
)
    mode = _normalize_parse_mode(parse_mode)
    if mode == SeekParseMode
        return seek_match(alternation, input, codeunit_cursor)
    end
    return consume_match(alternation, input, codeunit_cursor)
end

"""Match one authored alternative without changing its structural identity."""
function match_runtime_regex_slot(
    alternation::RuntimeRegexAlternation,
    zero_based_index::Int,
    input::AbstractString,
    codeunit_cursor::Int = 0;
    parse_mode = SeekParseMode,
)
    if zero_based_index < 0 || zero_based_index >= length(alternation.alternatives)
        throw(RuntimeRegexException(
            "regex alternative index $zero_based_index is outside 0:$(length(alternation.alternatives) - 1)",
        ))
    end

    input_text = String(input)
    cursor = _checked_codeunit_offset(input_text, codeunit_cursor)
    start_index = _codeunit_offset_to_string_index(input_text, cursor)
    alternative = alternation.alternatives[zero_based_index + 1]
    raw_match = match(alternative.regex, input_text, start_index)
    raw_match === nothing && return nothing

    mode = _normalize_parse_mode(parse_mode)
    if mode == ConsumeParseMode && raw_match.offset - 1 != cursor
        return nothing
    end
    return _runtime_regex_match(input_text, alternative, raw_match)
end

function seek_match(
    alternation::RuntimeRegexAlternation,
    input::AbstractString,
    codeunit_cursor::Int = 0,
)
    input_text = String(input)
    start_index = _codeunit_offset_to_string_index(input_text, codeunit_cursor)
    best = nothing

    for alternative in alternation.alternatives
        raw_match = match(alternative.regex, input_text, start_index)
        if raw_match === nothing
            continue
        end
        candidate = _runtime_regex_match(input_text, alternative, raw_match)
        if best === nothing ||
                candidate.codeunit_start < best.codeunit_start ||
                (
                    candidate.codeunit_start == best.codeunit_start &&
                    candidate.alternative_index < best.alternative_index
                )
            best = candidate
        end
    end

    return best
end

function consume_match(
    alternation::RuntimeRegexAlternation,
    input::AbstractString,
    codeunit_cursor::Int = 0,
)
    input_text = String(input)
    cursor = _checked_codeunit_offset(input_text, codeunit_cursor)
    start_index = _codeunit_offset_to_string_index(input_text, cursor)

    for alternative in alternation.alternatives
        raw_match = match(alternative.regex, input_text, start_index)
        if raw_match === nothing || raw_match.offset - 1 != cursor
            continue
        end
        return _runtime_regex_match(input_text, alternative, raw_match)
    end

    return nothing
end

struct RuntimeLineColumn
    line::Int
    column::Int
end

function codeunit_offset_to_char_offset(input::AbstractString, codeunit_offset::Int)
    input_text = String(input)
    offset = _checked_codeunit_offset(input_text, codeunit_offset)
    if offset == 0
        return 0
    end
    index = _codeunit_offset_to_string_index(input_text, offset)
    return length(SubString(input_text, firstindex(input_text), prevind(input_text, index)))
end

function char_offset_to_codeunit_offset(input::AbstractString, char_offset::Int)
    input_text = String(input)
    clamped = clamp(char_offset, 0, length(input_text))
    index = firstindex(input_text)
    for _ in 1:clamped
        index = nextind(input_text, index)
    end
    return index - 1
end

function line_column_at_codeunit_offset(input::AbstractString, codeunit_offset::Int)
    input_text = String(input)
    char_offset = codeunit_offset_to_char_offset(input_text, codeunit_offset)
    line = 1
    column = 1
    for char in Iterators.take(input_text, char_offset)
        if char == '\n'
            line += 1
            column = 1
        else
            column += 1
        end
    end
    return RuntimeLineColumn(line, column)
end

match_start_line_column(match::RuntimeRegexMatch) =
    line_column_at_codeunit_offset(match.input, match.codeunit_start)

struct RuntimeMatchRegisters
    input::String
    cursor_codeunit::Int
    entry_match::Union{Nothing,RuntimeRegexMatch}
    local_match::Union{Nothing,RuntimeRegexMatch}
    capture_start_codeunit::Union{Nothing,Int}
end

function RuntimeMatchRegisters(
    input::AbstractString;
    cursor_codeunit::Int = 0,
    entry_match = nothing,
    local_match = nothing,
    capture_start_codeunit = cursor_codeunit,
)
    input_text = String(input)
    cursor = _checked_codeunit_offset(input_text, cursor_codeunit)
    capture_start = capture_start_codeunit === nothing ? nothing :
        _checked_codeunit_offset(input_text, Int(capture_start_codeunit))
    _check_register_match_input(input_text, entry_match)
    _check_register_match_input(input_text, local_match)
    return RuntimeMatchRegisters(
        input_text,
        cursor,
        entry_match,
        local_match,
        capture_start,
    )
end

cursor_char_offset(registers::RuntimeMatchRegisters) =
    codeunit_offset_to_char_offset(registers.input, registers.cursor_codeunit)

cursor_line_column(registers::RuntimeMatchRegisters) =
    line_column_at_codeunit_offset(registers.input, registers.cursor_codeunit)

function enter_child(registers::RuntimeMatchRegisters)
    return RuntimeMatchRegisters(
        registers.input;
        cursor_codeunit = registers.cursor_codeunit,
        entry_match = registers.local_match,
        local_match = nothing,
        capture_start_codeunit = registers.local_match === nothing ?
            registers.cursor_codeunit : registers.local_match.codeunit_end,
    )
end

function with_local_match(registers::RuntimeMatchRegisters, match::RuntimeRegexMatch)
    _check_register_match_input(registers.input, match)
    return RuntimeMatchRegisters(
        registers.input;
        cursor_codeunit = match.codeunit_end,
        entry_match = registers.entry_match === nothing ? match : registers.entry_match,
        local_match = match,
        capture_start_codeunit = registers.capture_start_codeunit === nothing ?
            match.codeunit_end : registers.capture_start_codeunit,
    )
end

function with_cursor_codeunit(registers::RuntimeMatchRegisters, codeunit_cursor::Int)
    return RuntimeMatchRegisters(
        registers.input;
        cursor_codeunit = codeunit_cursor,
        entry_match = registers.entry_match,
        local_match = registers.local_match,
        capture_start_codeunit = registers.capture_start_codeunit,
    )
end

function with_capture_start_codeunit(registers::RuntimeMatchRegisters, codeunit_cursor::Int)
    return RuntimeMatchRegisters(
        registers.input;
        cursor_codeunit = registers.cursor_codeunit,
        entry_match = registers.entry_match,
        local_match = registers.local_match,
        capture_start_codeunit = codeunit_cursor,
    )
end

function zero_progress_since(registers::RuntimeMatchRegisters, previous_codeunit_cursor::Int)
    return registers.cursor_codeunit ==
        _checked_codeunit_offset(registers.input, previous_codeunit_cursor)
end

to_json(mode::LinkedSpecParseMode) = parse_mode_name(mode)

function to_json(alternation::RuntimeRegexAlternation)
    return Dict{String,Any}(
        "patterns" => [alternative.pattern for alternative in alternation.alternatives],
    )
end

function to_json(match::RuntimeRegexMatch)
    line_column = match_start_line_column(match)
    return Dict{String,Any}(
        "alternative_index" => match.alternative_index,
        "pattern" => match.pattern,
        "text" => match_text(match),
        "code_unit_start" => match.codeunit_start,
        "code_unit_end" => match.codeunit_end,
        "code_unit_length" => codeunit_length(match),
        "char_start" => char_start(match),
        "char_end" => char_end(match),
        "char_length" => char_length(match),
        "line" => line_column.line,
        "column" => line_column.column,
        "groups" => match.groups,
        "captures" => match.captures,
        "named" => match.named,
        "zero_width" => is_zero_width(match),
    )
end

to_json(line_column::RuntimeLineColumn) =
    Dict{String,Any}("line" => line_column.line, "column" => line_column.column)

function to_json(registers::RuntimeMatchRegisters)
    line_column = cursor_line_column(registers)
    result = Dict{String,Any}(
        "cursor_code_unit" => registers.cursor_codeunit,
        "cursor_char_offset" => cursor_char_offset(registers),
        "cursor_line" => line_column.line,
        "cursor_column" => line_column.column,
    )
    _put_if_present!(result, "capture_start_code_unit", registers.capture_start_codeunit)
    if registers.entry_match !== nothing
        result["entry_match"] = to_json(registers.entry_match)
    end
    if registers.local_match !== nothing
        result["local_match"] = to_json(registers.local_match)
    end
    return result
end

function _runtime_regex_match(
    input::String,
    alternative::RuntimeRegexAlternative,
    raw_match::RegexMatch,
)
    groups = String[String(raw_match.match)]
    captures = String[]
    for capture in raw_match.captures
        if capture === nothing
            push!(groups, "")
        else
            value = String(capture)
            push!(groups, value)
            push!(captures, value)
        end
    end

    named = Dict{String,String}()
    for key in keys(raw_match)
        if !(key isa AbstractString)
            continue
        end
        value = raw_match[key]
        if value !== nothing
            named[String(key)] = String(value)
        end
    end

    codeunit_start = raw_match.offset - 1
    codeunit_end = codeunit_start + ncodeunits(raw_match.match)
    return RuntimeRegexMatch(
        input,
        alternative.index,
        alternative.pattern,
        codeunit_start,
        codeunit_end,
        groups,
        captures,
        named,
    )
end

function _normalize_parse_mode(mode)
    if mode isa LinkedSpecParseMode
        return mode
    elseif mode isa AbstractString
        return parse_mode_from_name(mode)
    end
    throw(RuntimeRegexException("parse mode must be seek or consume"))
end

function _checked_codeunit_offset(input::String, codeunit_offset::Int)
    offset = clamp(codeunit_offset, 0, ncodeunits(input))
    if offset < ncodeunits(input) && !isvalid(input, offset + 1)
        throw(ArgumentError("code-unit offset $offset is not a character boundary"))
    end
    return offset
end

_codeunit_offset_to_string_index(input::String, codeunit_offset::Int) =
    _checked_codeunit_offset(input, codeunit_offset) + 1

function _check_register_match_input(input::String, match)
    if match !== nothing && match.input != input
        throw(ArgumentError("match input does not belong to this register input"))
    end
    return nothing
end
