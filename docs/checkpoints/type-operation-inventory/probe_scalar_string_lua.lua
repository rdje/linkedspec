local l = require("linkedspec")
local json = l.json
local function observe(label, route, operation)
  local ok, value = pcall(operation)
  local row = json.harray({label=label,route=route})
  if ok then row.value=value;row.error=json.null else row.error=tostring(value) end
  io.stdout:write(json.encode(row), "\n")
end
local cases = {
  {"large_end", [=[Top:: I { return([substr("abc",0,9223372036854775807),substr("abc",1,9223372036854775807),"abc".substr(1,9223372036854775807)]) }]=]},
  {"basic", [=[Top:: I { source="a-b";order="";value=replace_substr({order=cat(order,"S");source},{order=cat(order,"O");source="changed";"-"},{order=cat(order,"N");"_"});return([[trim(" a "),lowercase("AB"),uppercase("ab"),replace_substr("a-b","-","_"),rm_prefix("pre_a","pre_"),rm_suffix("a_end","_end"),substr("abc",1),cat("a","b")],[lowercase("ΟΣ"),uppercase("Straße ﬃ"),substr("a🙂b",1,1)],cat(undef,"x"),value,order,source]); }]=]},
  {"identities", [=[Top:: I { return([replace_substr(0,"","X"),rm_prefix(0,"x"),rm_suffix(0,"x"),rm_prefix(false,"x"),rm_suffix(false,"x"),rm_prefix("0","x"),replace_substr("abc",undef,"x"),replace_substr("abc","a",undef),rm_prefix("abc",undef),rm_suffix("abc",undef)]); }]=]},
  {"producer", [=[Top:: I { raw=[trim(" a "),lowercase("AB"),uppercase("ab"),replace_substr("a-b","-","_"),rm_prefix("pre_a","pre_"),rm_suffix("a_end","_end"),substr("abc",1),cat("a","b")];identity=[replace_substr(0,"","X"),rm_prefix(0,"x"),rm_suffix(false,"x")];values=["zero","one"];values[rm_prefix(0,"x")]="prefix";values[rm_suffix(1,"x")]="suffix";unicode=[lowercase("ΟΣ"),uppercase("Straße ﬃ"),substr("a🙂b",1,1)];source="a-b";order="";replaced=replace_substr({order=cat(order,"S");source},{order=cat(order,"O");source="changed";"-"},{order=cat(order,"N");"_"});return([raw,identity,values,unicode,replaced,order,source,cat(undef,"x")]); }]=]},
  {"bounds", [=[Top:: I { order="";source=substr({order=cat(order,"S");undef},{order=cat(order,"I");0},{order=cat(order,"L");1});start=substr("abc",undef);return([source,start,undef.substr(0),"abc".substr(undef),substr("abc",0,undef),order,substr("abc",1.5),substr("abc",-1,1),substr("abc",0,1.5),substr("abc",0,-1),substr("abc",true)]); }]=]},
  {"mutation", [=[Top:: I { text="aba";substr(text,/a/,"x","g");other="aba";regex_subst(other,/a/,"y","");return([text,other]); }]=]},
  {"boundaries", [=[Top:: I { order="";value={order=cat(order,"S");" a "}.trim().cat({order=cat(order,"C");"!"}).take({order=cat(order,"A");1});bad_order="";bad={bad_order=cat(bad_order,"S");"a"}.replace_substr({bad_order=cat(bad_order,"A");"x"}).cat({bad_order=cat(bad_order,"C");"!"});return([value,order,bad,bad_order]); }]=]},
}
local file = assert(io.open("tests/fixtures/scalar_string_result_receiver_values.spec","r"))
cases[#cases+1] = {"shared",file:read("*a")};file:close()
local arguments_file = assert(io.open("tests/fixtures/substring_optional_argument_values.spec","r"))
cases[#cases+1] = {"arguments",arguments_file:read("*a")};arguments_file:close()
for _, row in ipairs(cases) do
  local selected = #arg == 0
  for _, name in ipairs(arg) do if name == row[1] then selected=true end end
  if selected then
    local compiled=l.compile_spec(l.parse_spec_with_staged_user_function_definitions(row[2]))
    observe(row[1],"native",function() return l.runtime_parse(l.runtime_engine(compiled),"x").value end)
    observe(row[1],"plan",function() return l.execute_generated_parser_v2(compiled,l.build_generated_rule_plan(compiled),"x","scalar-string-assessment.spec") end)
    local generated=assert((loadstring or load)(l.emit_lua_source_v2(compiled,"scalar-string-assessment.spec")))()
    observe(row[1],"fresh",function() return generated.execute("x") end)
  end
end
