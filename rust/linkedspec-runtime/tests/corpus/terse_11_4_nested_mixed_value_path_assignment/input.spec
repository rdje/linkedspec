Top::
 -> Done { set(value, "new"); payload = { "items" : [{ "name" : "old" }] }; payload["items"][0]["name"] = value; payload_result = payload["items"][1] = { "name" : "tail" }; root_array = [{ "name" : "old" }]; root_array[0]["name"] = value; root_result = root_array[1] = { "name" : "tail" }; return(array(payload, payload_result, root_array, root_result)) }

Done::
 /[a-z]+/
