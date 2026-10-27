assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json

local function fixture(name, extension)
  local file = assert(io.open("tests/fixtures/" .. name .. "." .. extension, "r"))
  local source = file:read("*a")
  file:close()
  return source
end

local function check_consumers(source, expected_json)
  local compiled = l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
  local expected = json.encode(json.decode(expected_json))
  local function same(value, route)
    local actual = json.encode(value)
    assert(actual == expected, route .. ": expected " .. expected .. ", got " .. actual)
  end
  same(l.runtime_parse(l.runtime_engine(compiled), "x").value, "native")
  same(l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled),
    "x", "scalar-string-results.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "scalar-string-results.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end

check_consumers([=[Top:: I { source="a-b";order="";value=replace_substr({order=cat(order,"S");source},{order=cat(order,"O");source="changed";"-"},{order=cat(order,"N");"_"});return([[trim(" a "),lowercase("AB"),uppercase("ab"),replace_substr("a-b","-","_"),rm_prefix("pre_a","pre_"),rm_suffix("a_end","_end"),substr("abc",1),cat("a","b")],[lowercase("ΟΣ"),uppercase("Straße ﬃ"),substr("a🙂b",1,1)],cat(undef,"x"),value,order,source]); }]=], [=[[["a","ab","AB","a_b","a","a","bc","ab"],["ος","STRASSE FFI","🙂"],null,"a_b","SON","changed"]]=])
io.stdout:write("healthy scalar String producers passed\n")
check_consumers([=[Top:: I { return([substr("abc",0,9223372036854775807),substr("abc",1,9223372036854775807),"abc".substr(1,9223372036854775807)]) }]=], '["abc","bc","bc"]')
check_consumers([=[Top:: I { return([replace_substr(0,"","X"),rm_prefix(0,"x"),rm_suffix(0,"x"),rm_prefix(false,"x"),rm_suffix(false,"x"),rm_prefix("0","x"),replace_substr("abc",undef,"x"),replace_substr("abc","a",undef),rm_prefix("abc",undef),rm_suffix("abc",undef)]); }]=], '[0,0,0,false,false,"0",null,null,null,null]')
check_consumers([=[Top:: I { order="";value={order=cat(order,"S");" a "}.trim().cat({order=cat(order,"C");"!"}).take({order=cat(order,"A");1});bad_order="";bad={bad_order=cat(bad_order,"S");"a"}.replace_substr({bad_order=cat(bad_order,"A");"x"}).cat({bad_order=cat(bad_order,"C");"!"});return([value,order,bad,bad_order]); }]=], '[null,"SC",null,""]')
check_consumers([=[Top:: I { raw=[trim(" a "),lowercase("AB"),uppercase("ab"),replace_substr("a-b","-","_"),rm_prefix("pre_a","pre_"),rm_suffix("a_end","_end"),substr("abc",1),cat("a","b")];identity=[replace_substr(0,"","X"),rm_prefix(0,"x"),rm_suffix(false,"x")];values=["zero","one"];values[rm_prefix(0,"x")]="prefix";values[rm_suffix(1,"x")]="suffix";unicode=[lowercase("ΟΣ"),uppercase("Straße ﬃ"),substr("a🙂b",1,1)];source="a-b";order="";replaced=replace_substr({order=cat(order,"S");source},{order=cat(order,"O");source="changed";"-"},{order=cat(order,"N");"_"});return([raw,identity,values,unicode,replaced,order,source,cat(undef,"x")]); }]=], [=[[["a","ab","AB","a_b","a","a","bc","ab"],[0,0,false],["prefix","suffix"],["ος","STRASSE FFI","🙂"],"a_b","SON","changed",null]]=])
check_consumers(fixture("scalar_string_result_receiver_values","spec"),fixture("scalar_string_result_receiver_values","json"))
check_consumers([=[Top:: I { order="";source=substr({order=cat(order,"S");undef},{order=cat(order,"I");0},{order=cat(order,"L");1});start=substr("abc",undef);return([source,start,undef.substr(0),"abc".substr(undef),substr("abc",0,undef),order,substr("abc",1.5),substr("abc",-1,1),substr("abc",0,1.5),substr("abc",0,-1),substr("abc",true)]); }]=], '[null,null,null,null,"abc","SIL","abc","a","","","abc"]')
check_consumers([=[Top:: I { text="aba";substr(text,/a/,"x","g");other="aba";regex_subst(other,/a/,"y","");return([text,other]); }]=], '["xbx","yba"]')
io.stdout:write("scalar String identities results shapes slices and mutation checks passed\n")
