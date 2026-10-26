Top:: I {
 array_order="";
 bad_array=and({array_order=cat(array_order,"L");true},{array_order=cat(array_order,"R");false}).sorted();
 hash_order="";
 bad_hash=or({hash_order=cat(hash_order,"L");true},{hash_order=cat(hash_order,"R");false}).cat({hash_order=cat(hash_order,"C");"x"}).sorted_values();
 operand_order="";
 bad_operand=not({operand_order=cat(operand_order,"S");false}).take({operand_order=cat(operand_order,"A");1});
 return({"bad_array":bad_array,"array_order":array_order,"bad_hash":bad_hash,"hash_order":hash_order,"bad_operand":bad_operand,"operand_order":operand_order});
}
