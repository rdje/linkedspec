const LINKED_SPEC_TRACE_DUMP_NONE = 0
const LINKED_SPEC_TRACE_DUMP_LOW = 100
const LINKED_SPEC_TRACE_DUMP_MEDIUM = 200
const LINKED_SPEC_TRACE_DUMP_HIGH = 300
const LINKED_SPEC_TRACE_DUMP_FULL = 400
const LINKED_SPEC_TRACE_DUMP_DEBUG = 500

struct LinkedSpecTraceException <: Exception
    message::String
end

Base.showerror(io::IO, error::LinkedSpecTraceException) = print(io, error.message)

struct LinkedSpecTraceLevel
    value::Int
end

const LinkedSpecTraceNone = LinkedSpecTraceLevel(LINKED_SPEC_TRACE_DUMP_NONE)
const LinkedSpecTraceLow = LinkedSpecTraceLevel(LINKED_SPEC_TRACE_DUMP_LOW)
const LinkedSpecTraceMedium = LinkedSpecTraceLevel(LINKED_SPEC_TRACE_DUMP_MEDIUM)
const LinkedSpecTraceHigh = LinkedSpecTraceLevel(LINKED_SPEC_TRACE_DUMP_HIGH)
const LinkedSpecTraceFull = LinkedSpecTraceLevel(LINKED_SPEC_TRACE_DUMP_FULL)
const LinkedSpecTraceDebug = LinkedSpecTraceLevel(LINKED_SPEC_TRACE_DUMP_DEBUG)

function parse_trace_level(input)
    if input isa LinkedSpecTraceLevel
        return input
    elseif input isa Integer
        return LinkedSpecTraceLevel(Int(input))
    end
    value = strip(String(input))
    if isempty(value)
        throw(LinkedSpecTraceException("empty trace level"))
    end
    numeric = tryparse(Int, value)
    if numeric !== nothing
        return LinkedSpecTraceLevel(numeric)
    end
    normalized = lowercase(value)
    if normalized in ("none", "quiet", "off")
        return LinkedSpecTraceNone
    elseif normalized == "low"
        return LinkedSpecTraceLow
    elseif normalized in ("medium", "med")
        return LinkedSpecTraceMedium
    elseif normalized == "high"
        return LinkedSpecTraceHigh
    elseif normalized == "full"
        return LinkedSpecTraceFull
    elseif normalized in ("debug", "verbose")
        return LinkedSpecTraceDebug
    end
    throw(LinkedSpecTraceException("unsupported trace level '$input'"))
end

trace_allows(configured::LinkedSpecTraceLevel, event::LinkedSpecTraceLevel) =
    configured.value > LINKED_SPEC_TRACE_DUMP_NONE &&
    event.value > LINKED_SPEC_TRACE_DUMP_NONE &&
    configured.value >= event.value

function trace_level_name(level::LinkedSpecTraceLevel)
    if level.value <= LINKED_SPEC_TRACE_DUMP_NONE
        return "none"
    elseif level.value <= LINKED_SPEC_TRACE_DUMP_LOW
        return "low"
    elseif level.value <= LINKED_SPEC_TRACE_DUMP_MEDIUM
        return "medium"
    elseif level.value <= LINKED_SPEC_TRACE_DUMP_HIGH
        return "high"
    elseif level.value <= LINKED_SPEC_TRACE_DUMP_FULL
        return "full"
    end
    return "debug"
end

@enum LinkedSpecTraceSinkMode begin
    LinkedSpecTraceStdout
    LinkedSpecTraceRoute
    LinkedSpecTraceMirror
end

function parse_trace_sink_mode(input)
    if input isa LinkedSpecTraceSinkMode
        return input
    end
    value = lowercase(strip(String(input)))
    if value in ("stdout", "console")
        return LinkedSpecTraceStdout
    elseif value in ("route", "routed", "file")
        return LinkedSpecTraceRoute
    elseif value in ("mirror", "both")
        return LinkedSpecTraceMirror
    end
    throw(LinkedSpecTraceException("unsupported trace sink mode '$input'"))
end

struct LinkedSpecTraceConfig
    level::LinkedSpecTraceLevel
    trace_file::Union{Nothing,String}
    sink_mode::LinkedSpecTraceSinkMode
    reset_file::Bool
    emoji::Bool
end

function LinkedSpecTraceConfig(;
    level = LinkedSpecTraceNone,
    trace_file = nothing,
    sink_mode = LinkedSpecTraceStdout,
    reset_file::Bool = false,
    emoji::Bool = false,
)
    return LinkedSpecTraceConfig(
        parse_trace_level(level),
        trace_file === nothing ? nothing : String(trace_file),
        parse_trace_sink_mode(sink_mode),
        reset_file,
        emoji,
    )
end

trace_config_disabled() = LinkedSpecTraceConfig()
trace_config_enabled(level) = LinkedSpecTraceConfig(level = level)

function with_trace_level(config::LinkedSpecTraceConfig, level)
    return LinkedSpecTraceConfig(
        level = level,
        trace_file = config.trace_file,
        sink_mode = config.sink_mode,
        reset_file = config.reset_file,
        emoji = config.emoji,
    )
end

function with_trace_file(config::LinkedSpecTraceConfig, path)
    sink_mode = config.sink_mode == LinkedSpecTraceStdout ?
        LinkedSpecTraceRoute : config.sink_mode
    return LinkedSpecTraceConfig(
        level = config.level,
        trace_file = String(path),
        sink_mode = sink_mode,
        reset_file = config.reset_file,
        emoji = config.emoji,
    )
end

function with_trace_sink_mode(config::LinkedSpecTraceConfig, sink_mode)
    return LinkedSpecTraceConfig(
        level = config.level,
        trace_file = config.trace_file,
        sink_mode = sink_mode,
        reset_file = config.reset_file,
        emoji = config.emoji,
    )
end

function with_trace_reset_file(config::LinkedSpecTraceConfig, reset_file::Bool = true)
    return LinkedSpecTraceConfig(
        level = config.level,
        trace_file = config.trace_file,
        sink_mode = config.sink_mode,
        reset_file = reset_file,
        emoji = config.emoji,
    )
end

function with_trace_emoji(config::LinkedSpecTraceConfig, emoji::Bool = true)
    return LinkedSpecTraceConfig(
        level = config.level,
        trace_file = config.trace_file,
        sink_mode = config.sink_mode,
        reset_file = config.reset_file,
        emoji = emoji,
    )
end

trace_should_emit(config::LinkedSpecTraceConfig, level::LinkedSpecTraceLevel) =
    trace_allows(config.level, level)

function trace_config_from_environment(environment::AbstractDict = ENV)
    config = trace_config_disabled()
    level = get(
        environment,
        "LINKEDSPEC_TRACE_LEVEL",
        get(environment, "LINKEDSPEC_DUMP_VERBOSITY", nothing),
    )
    if level !== nothing
        config = with_trace_level(config, level)
    end
    trace_file = get(environment, "LINKEDSPEC_TRACE_FILE", nothing)
    if trace_file !== nothing && !isempty(strip(String(trace_file)))
        config = with_trace_file(config, strip(String(trace_file)))
        if _trace_truthy(get(environment, "LINKEDSPEC_TRACE_MIRROR_STDOUT", nothing))
            config = with_trace_sink_mode(config, LinkedSpecTraceMirror)
        end
    end
    if _trace_truthy(get(environment, "LINKEDSPEC_TRACE_RESET_FILE", nothing))
        config = with_trace_reset_file(config)
    end
    if _trace_truthy(get(environment, "LINKEDSPEC_TRACE_EMOJI", nothing))
        config = with_trace_emoji(config)
    end
    return config
end

@enum LinkedSpecTraceEventKind begin
    LinkedSpecTraceEnter
    LinkedSpecTraceExit
    LinkedSpecTraceDecision
    LinkedSpecTraceMark
    LinkedSpecTraceDump
    LinkedSpecTraceLog
end

function trace_event_kind_name(kind::LinkedSpecTraceEventKind)
    if kind == LinkedSpecTraceEnter
        return "enter"
    elseif kind == LinkedSpecTraceExit
        return "exit"
    elseif kind == LinkedSpecTraceDecision
        return "decision"
    elseif kind == LinkedSpecTraceMark
        return "mark"
    elseif kind == LinkedSpecTraceDump
        return "dump"
    end
    return "log"
end

struct LinkedSpecTraceEvent
    kind::LinkedSpecTraceEventKind
    topic::String
    details::String
    level::LinkedSpecTraceLevel
end

to_json(event::LinkedSpecTraceEvent) = Dict{String,Any}(
    "kind" => trace_event_kind_name(event.kind),
    "topic" => event.topic,
    "details" => event.details,
    "level" => trace_level_name(event.level),
    "level_value" => event.level.value,
)

struct LinkedSpecTraceScope
    topic::String
    level::LinkedSpecTraceLevel
    emitted::Bool
end

mutable struct LinkedSpecTraceEmitter
    config::LinkedSpecTraceConfig
    stdout_io::IO
    events::Vector{LinkedSpecTraceEvent}
    lines::Vector{String}
    indent_level::Int
end

function LinkedSpecTraceEmitter(config::LinkedSpecTraceConfig; stdout_io::IO = stdout)
    emitter = LinkedSpecTraceEmitter(
        config,
        stdout_io,
        LinkedSpecTraceEvent[],
        String[],
        0,
    )
    if (_trace_uses_file_sink(config) || config.reset_file) &&
            _trace_file_path(config) !== nothing
        _prepare_trace_file(_trace_file_path(config), config.reset_file)
    end
    return emitter
end

trace_events(emitter::LinkedSpecTraceEmitter) = LinkedSpecTraceEvent[emitter.events...]
trace_lines(emitter::LinkedSpecTraceEmitter) = String[emitter.lines...]
trace_should_emit(emitter::LinkedSpecTraceEmitter, level::LinkedSpecTraceLevel) =
    trace_should_emit(emitter.config, level)

function emit_trace_line!(emitter::LinkedSpecTraceEmitter, level, line)
    event_level = parse_trace_level(level)
    if !trace_should_emit(emitter, event_level)
        return nothing
    end
    text = String(line)
    payload = endswith(text, '\n') ? text : text * "\n"
    push!(emitter.lines, payload)
    _write_trace_payload!(emitter, payload)
    return nothing
end

function emit_trace_event!(emitter::LinkedSpecTraceEmitter, kind, topic, details, level)
    event_level = parse_trace_level(level)
    if !trace_should_emit(emitter, event_level)
        return nothing
    end
    event = LinkedSpecTraceEvent(
        kind,
        String(topic),
        String(details),
        event_level,
    )
    push!(emitter.events, event)
    emit_trace_line!(emitter, event_level, _render_trace_event(emitter, event))
    return nothing
end

function enter_trace_scope!(emitter::LinkedSpecTraceEmitter, topic, details, level)
    event_level = parse_trace_level(level)
    emitted = trace_should_emit(emitter, event_level)
    if emitted
        emit_trace_event!(emitter, LinkedSpecTraceEnter, topic, details, event_level)
        emitter.indent_level += 1
    end
    return LinkedSpecTraceScope(String(topic), event_level, emitted)
end

function exit_trace_scope!(emitter::LinkedSpecTraceEmitter, scope::LinkedSpecTraceScope, details)
    if !scope.emitted
        return nothing
    end
    emitter.indent_level = max(0, emitter.indent_level - 1)
    emit_trace_event!(emitter, LinkedSpecTraceExit, scope.topic, details, scope.level)
    return nothing
end

function trace_decision!(emitter::LinkedSpecTraceEmitter, topic, taken::Bool, reason, level)
    emit_trace_event!(
        emitter,
        LinkedSpecTraceDecision,
        topic,
        "taken=$(taken ? 1 : 0) reason=$reason",
        level,
    )
    return taken
end

function log_trace_output!(emitter::LinkedSpecTraceEmitter, level, message, context = "")
    details = isempty(String(context)) ? String(message) : "$(String(message)) context=$context"
    emit_trace_event!(emitter, LinkedSpecTraceLog, "log_output", details, level)
    return nothing
end

function log_trace_dump!(emitter::LinkedSpecTraceEmitter, level, message)
    emit_trace_event!(emitter, LinkedSpecTraceDump, "log_dump", message, level)
    return nothing
end

function _render_trace_event(emitter::LinkedSpecTraceEmitter, event::LinkedSpecTraceEvent)
    indent = repeat("  ", emitter.indent_level)
    emoji = _trace_emoji_prefix(emitter.config, event.level)
    details = isempty(strip(event.details)) ? "" : " $(event.details)"
    level = uppercase(trace_level_name(event.level))
    kind = trace_event_kind_name(event.kind)
    if event.kind == LinkedSpecTraceEnter
        return "[$level][$kind] $indent$emoji-> $(event.topic)$details"
    elseif event.kind == LinkedSpecTraceExit
        return "[$level][$kind] $indent$emoji<- $(event.topic)$details"
    end
    return "[$level][$kind] $indent$emoji$(event.topic)$details"
end

function _trace_emoji_prefix(config::LinkedSpecTraceConfig, level::LinkedSpecTraceLevel)
    if !config.emoji
        return ""
    elseif level.value <= LINKED_SPEC_TRACE_DUMP_NONE
        return "🛑 "
    elseif level.value <= LINKED_SPEC_TRACE_DUMP_LOW
        return "ℹ️ "
    elseif level.value <= LINKED_SPEC_TRACE_DUMP_MEDIUM
        return "🔎 "
    elseif level.value <= LINKED_SPEC_TRACE_DUMP_HIGH
        return "🧭 "
    elseif level.value <= LINKED_SPEC_TRACE_DUMP_FULL
        return "🐞 "
    end
    return "🔥 "
end

_trace_uses_file_sink(config::LinkedSpecTraceConfig) =
    config.sink_mode in (LinkedSpecTraceRoute, LinkedSpecTraceMirror)

function _trace_file_path(config::LinkedSpecTraceConfig)
    if config.trace_file === nothing || isempty(strip(config.trace_file))
        return nothing
    end
    return config.trace_file
end

function _prepare_trace_file(path::String, reset_file::Bool)
    directory = dirname(path)
    if !isempty(directory) && directory != "."
        mkpath(directory)
    end
    if reset_file
        open(path, "w") do io
            flush(io)
        end
    elseif !isfile(path)
        open(path, "a") do io
            flush(io)
        end
    end
    return nothing
end

function _write_trace_payload!(emitter::LinkedSpecTraceEmitter, payload::String)
    if emitter.config.sink_mode != LinkedSpecTraceRoute
        print(emitter.stdout_io, payload)
    end
    trace_file = _trace_file_path(emitter.config)
    if _trace_uses_file_sink(emitter.config) && trace_file !== nothing
        open(trace_file, "a") do io
            print(io, payload)
        end
    end
    return nothing
end

function _trace_truthy(value)
    if value === nothing
        return false
    end
    text = lowercase(strip(String(value)))
    return !isempty(text) && !(text in ("0", "false", "no", "off"))
end
