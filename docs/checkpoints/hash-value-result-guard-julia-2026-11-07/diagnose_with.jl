using LinkedSpecJulia, JSON3
cases=JSON3.read(read(ARGS[1],String),Any)
for row in cases
    row["id"] in ("merge_later_with","set_copy_later_with","rename_logical_later_with") || continue
    println("HASH_VALUE_JULIA_ACTION ",row["id"]," ",JSON3.write(to_json(parse_action_block(row["body"]))))
end
