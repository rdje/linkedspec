local linkedspec = require("linkedspec")
local json = linkedspec.json

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local text = assert(handle:read("*a"))
  assert(handle:close())
  return text
end

local function render_node(node)
  if node.kind ~= "list" then return node.lexeme end
  local items = {}
  for index, item in ipairs(node.items) do items[index] = render_node(item) end
  return "(" .. table.concat(items, " ") .. ")"
end

local function same_json(actual, expected, label)
  local actual_json, expected_json = json.encode(actual), json.encode(expected)
  assert(actual_json == expected_json, label .. ": expected " .. expected_json .. ", got " .. actual_json)
end

local contract = json.decode(read_file("tests/sexpr-document-v1/contract.json"))
assert(#contract.cases == 37, "consume all authored cases")
local reuse
for _, row in ipairs(contract.cases) do
  if row.id == "reuse_after_rejection" then reuse = row end
end
assert(reuse, "authored reuse case exists")
local source = read_file("specs/SExprDocumentV1.spec")
local parsed = linkedspec.parse_spec_with_staged_user_function_definitions(source)
local engine = linkedspec.runtime_engine(linkedspec.compile_spec(parsed))

for _, row in ipairs(contract.cases) do
  if row.outcome == "accept" then
    same_json(linkedspec.runtime_parse(engine, row.input).value, row.expected, row.id .. ": authored tree")
    local forms = {}
    for index, form in ipairs(row.expected.forms) do forms[index] = render_node(form) end
    same_json(linkedspec.runtime_parse(engine, table.concat(forms, "\n")).value, row.expected, row.id .. ": token spelling round trip")
  else
    local ok, failure = pcall(linkedspec.runtime_parse, engine, row.input)
    assert(not ok and linkedspec.is_runtime_exit_now(failure), row.id .. ": atomic typed rejection")
    assert(failure.status == 1, row.id .. ": rejection status")
    same_json(linkedspec.runtime_parse(engine, reuse.input).value, reuse.expected, row.id .. ": independent input after rejection")
  end
end
print("SExprDocumentV1: 37 cases, 21 round trips and 16 post-rejection reuse checks PASS")
