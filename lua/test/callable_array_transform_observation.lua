local M = {}

function M.observe(l, operation)
  local ok, value = pcall(operation)
  if ok then return l.json.harray({value=value}) end
  local runtime = l.is_runtime_interpreter_error(value)
  local generated = l.is_generated_source_error(value)
  local row = {
    error=tostring(value), runtime=runtime, generated=generated,
    helper_name=type(value)=="table" and value.helper_name or nil,
    diagnostic_code=type(value)=="table" and value.diagnostic and value.diagnostic.code or nil,
    diagnostic_stage=type(value)=="table" and value.diagnostic and value.diagnostic.stage or nil,
    code=type(value)=="table" and value.code or nil,
    actual_arity=type(value)=="table" and value.actual_arity or nil,
    expected_arity=type(value)=="table" and value.expected_arity or nil,
  }
  if runtime then
    row.error_json = l.interpreter.to_json(value)
  elseif generated then
    row.error_json = l.generated_source_error_to_json(value)
  end
  return l.json.harray(row)
end

return M
