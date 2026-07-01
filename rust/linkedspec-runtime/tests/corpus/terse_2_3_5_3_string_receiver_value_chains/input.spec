Top::
 /x/ -> Done { set(raw, " Node-Name_end "); return(array(raw.trim().lowercase().replace_substr("-", "_").rm_prefix("node_").rm_suffix("_end").cat("!"), raw.trim().length(), raw.trim().split("-").trim_each().lowercase_each().join_values("|"), " a-b ".trim().split("-").count(), "abcdef".substr(1, 3).uppercase(), raw.coalesce_nonempty("fallback").trim())) }

Done::
 /[a-z]+/
