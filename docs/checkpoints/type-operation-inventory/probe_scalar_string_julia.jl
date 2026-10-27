using LinkedSpecJulia, JSON3

function observe_scalar_string(label, route, operation)
    try
        println(JSON3.write(Dict("label"=>label,"route"=>route,"value"=>operation(),"error"=>nothing)))
    catch error
        println(JSON3.write(Dict("label"=>label,"route"=>route,"error"=>sprint(showerror,error))))
    end
end

cases = [
    ("basic", raw"""Top:: I { source="a-b";order="";value=replace_substr({order=cat(order,"S");source},{order=cat(order,"O");source="changed";"-"},{order=cat(order,"N");"_"});return([[trim(" a "),lowercase("AB"),uppercase("ab"),replace_substr("a-b","-","_"),rm_prefix("pre_a","pre_"),rm_suffix("a_end","_end"),substr("abc",1),cat("a","b")],[lowercase("ΟΣ"),uppercase("Straße ﬃ"),substr("a🙂b",1,1)],cat(undef,"x"),value,order,source]); }"""),
    ("producer", raw"""Top:: I { raw=[trim(" a "),lowercase("AB"),uppercase("ab"),replace_substr("a-b","-","_"),rm_prefix("pre_a","pre_"),rm_suffix("a_end","_end"),substr("abc",1),cat("a","b")];identity=[replace_substr(0,"","X"),rm_prefix(0,"x"),rm_suffix(false,"x")];values=["zero","one"];values[rm_prefix(0,"x")]="prefix";values[rm_suffix(1,"x")]="suffix";unicode=[lowercase("ΟΣ"),uppercase("Straße ﬃ"),substr("a🙂b",1,1)];source="a-b";order="";replaced=replace_substr({order=cat(order,"S");source},{order=cat(order,"O");source="changed";"-"},{order=cat(order,"N");"_"});return([raw,identity,values,unicode,replaced,order,source,cat(undef,"x")]); }"""),
    ("identities", raw"""Top:: I { return([replace_substr(0,"","X"),rm_prefix(0,"x"),rm_suffix(0,"x"),rm_prefix(false,"x"),rm_suffix(false,"x"),rm_prefix("0","x"),replace_substr("abc",undef,"x"),replace_substr("abc","a",undef),rm_prefix("abc",undef),rm_suffix("abc",undef)]); }"""),
    ("bounds", raw"""Top:: I { order="";source=substr({order=cat(order,"S");undef},{order=cat(order,"I");0},{order=cat(order,"L");1});start=substr("abc",undef);return([source,start,undef.substr(0),"abc".substr(undef),substr("abc",0,undef),order,substr("abc",1.5),substr("abc",-1,1),substr("abc",0,1.5),substr("abc",0,-1),substr("abc",true)]); }"""),
    ("mutation", raw"""Top:: I { text="aba";substr(text,/a/,"x","g");other="aba";regex_subst(other,/a/,"y","");return([text,other]); }"""),
    ("boundaries", raw"""Top:: I { order="";value={order=cat(order,"S");" a "}.trim().cat({order=cat(order,"C");"!"}).take({order=cat(order,"A");1});bad_order="";bad={bad_order=cat(bad_order,"S");"a"}.replace_substr({bad_order=cat(bad_order,"A");"x"}).cat({bad_order=cat(bad_order,"C");"!"});return([value,order,bad,bad_order]); }"""),
]
root = normpath(joinpath(@__DIR__, "..", "..", ".."))
push!(cases, ("shared", read(joinpath(root, "tests", "fixtures", "scalar_string_result_receiver_values.spec"), String)))
for (label, source) in cases
    !isempty(ARGS) && !(label in ARGS) && continue
    compiled = compile_spec(parse_spec_with_staged_user_function_definitions(source))
    observe_scalar_string(label, "native", () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value)
    observe_scalar_string(label, "plan", () -> execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled), "x", "scalar-string-assessment.spec"))
    host = Module(gensym(:ScalarStringAssessment))
    Base.include_string(host, emit_julia_source_v2(compiled, "scalar-string-assessment.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    observe_scalar_string(label, "fresh", () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), "x"))
end
