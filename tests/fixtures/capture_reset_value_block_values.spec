Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");start_capture_slice();"!"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
