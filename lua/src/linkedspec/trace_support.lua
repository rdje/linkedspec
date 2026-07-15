local trace = require("linkedspec.trace")

local M = {}

function M.run(emitter, topic, details, operation, success_details)
  if emitter == nil then return operation() end
  if not trace.is_trace_emitter(emitter) then
    error("TraceSupportException: emitter must be a LinkedSpecTraceEmitter", 0)
  end
  if type(topic) ~= "string" or type(details) ~= "string" then
    error("TraceSupportException: scope topic and details must be strings", 0)
  end
  if type(operation) ~= "function" then
    error("TraceSupportException: scope operation must be a function", 0)
  end
  if type(success_details) ~= "string" and type(success_details) ~= "function" then
    error("TraceSupportException: success details must be a string or function", 0)
  end

  local scope = trace.enter_trace_scope(emitter, topic, details, trace.TRACE_HIGH)
  local ok, result = pcall(operation)
  if not ok then
    trace.exit_trace_scope(emitter, scope, "error=" .. tostring(result))
    error(result, 0)
  end
  local exit_details = success_details
  if type(exit_details) == "function" then
    local details_ok, details_or_error = pcall(exit_details, result)
    if not details_ok then
      trace.exit_trace_scope(emitter, scope, "error=" .. tostring(details_or_error))
      error(details_or_error, 0)
    end
    exit_details = details_or_error
  end
  if type(exit_details) ~= "string" then
    error("TraceSupportException: computed success details must be a string", 0)
  end
  trace.exit_trace_scope(emitter, scope, exit_details)
  return result
end

function M.decision(emitter, topic, taken, reason)
  if emitter ~= nil then
    trace.trace_decision(emitter, topic, taken, reason, trace.TRACE_MEDIUM)
  end
  return taken
end

return M
