Top::
 /x/ -> Done { set(value, "new"); payload = { "items" : [{ "name" : "old" }] }; payload["items"][0]["name"] = value; payload["items"][1] = { "name" : "tail" }; missing_result = payload["missing"][0] = "bad"; wrong_result = payload["items"][0][0] = "bad"; root_array = [{ "name" : "old" }]; root_array[0]["name"] = value; root_array[1] = { "name" : "tail" }; return(array(payload, missing_result, wrong_result, root_array, (payload["items"][3] = "gap"))) }

Done::
 /[a-z]+/
