using LinkedSpecJulia, JSON3
cases=JSON3.read(read(ARGS[1],String),Any)
grammar=read("specs/user_function_definition.spec",String)
println("HASH_VALUE_JULIA_DIAG_GRAMMAR ",JSON3.write(Dict("path"=>"specs/user_function_definition.spec","source"=>grammar)))
for row in cases
    row["id"] in ("merge_later_with","set_copy_later_with","rename_logical_later_with") || continue
    compiled=compile_spec(parse_spec_with_staged_user_function_definitions(row["source"];parser_spec_source=grammar))
    for payload in action_payloads(compiled.rules_by_label["Value"])
        println("HASH_VALUE_JULIA_COMPILED_ACTION ",row["id"]," ",JSON3.write(to_json(payload.action_ast)))
    end
end
