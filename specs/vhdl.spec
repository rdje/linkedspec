vhdl_file::
-> comment                    .push
-> space                      .push
-> library_clause             .push
-> use_clause                 .push
-> entity_declaration         .push
-> architecture_body          .push
-> package_declaration        .push
-> package_body               .push
-> configuration_declaration  .push

LX {return(copy(array(vhdl_file)))}


comment:        /--.*/                         I {text = entry_text(); return(text)}
space:          /\s+/                          I {text = entry_text(); return(text)}
dquote_string:  /"(.+?)(?<!")"/                I.return(array("?dquote_string:", flat_array(entry_groups())))
library_clause: /(?is)\blibrary\s+(.+?)\s*;/   I.return(array("?library_clause:", flat_array(entry_groups())))
use_clause:     /(?is)\buse\s+(.+?)\s*;/       I.return(array("?use_clause:", flat_array(entry_groups())))

entity_declaration:    /(?i)\bentity\s+(\w+)\s+is\b/ /(?i)\bend\b(?:\s+entity\b)?(?:\s+\w+)?\s*;/
I {entity_header_parts = []}
-? push
-> comment               .push
-> dquote_string         .push
-> port_clause           .push
-> entity_declaration[1] {
   set(array(entity_header_parts), entry_groups());
   lowercase_each(array(entity_header_parts));
   return(array("?entity_declaration:", flat_array(entity_header_parts), copy(array(entity_declaration))))
}

architecture_body: /(?i)\barchitecture\s+(\w+)\s+of\s+(\w+)\s+is\b/ /(?i)\bbegin\b/ /(?i)\bend\b(?:\s+architecture\b)?(?:\s+\w+)?\s*;/
I {architecture_header_parts = []}
-> comment                              .push
-> dquote_string                        .push
-> space                                .push
-> subprogram_body                      .push
-> subprogram_declaration               .push
-> type_declaration                     .push
-> subtype_declaration                  .push
-> constant_declaration                 .push
-> signal_declaration                   .push
-> variable_declaration                 .push
-> file_declaration                     .push
-> alias_declaration                    .push
-> component_declaration                .push
-> attribute_declaration                .push
-> attribute_specification              .push
-> configuration_specification          .push
-> use_clause                           .push
-> group_template_declaration           .push
-> group_declaration                    .push
-> disconnection_specification          .push

-> architecture_body[1]                 {
   set(array(architecture_header_parts), entry_groups());
   lowercase_each(array(architecture_header_parts));
   return(array(flat_array(architecture_header_parts), copy(array(architecture_body)), call(architecture_statement_part)))
}

architecture_statement_part:
-? push
-> comment                                 .push
-> dquote_string                           .push
-> space                                   .push
-> block_statement                         .push
-> process_statement                       .push
#-> concurrent_procedure_call_statement    .push
#-> concurrent_assertion_statement         .push
-> generate_statement                      .push
-> component_instantiation_statement       .push
-> architecture_body[2]                    {return(copy(array(architecture_statement_part)))}
-> concurrent_signal_assignment_statement  .push


concurrent_signal_assignment_statement: /(?is)(?:\bwith\s+(.+?)\s+select\s+)?(\w+.*?)\s*<=\s*(.+?)\s*;/  I.return(array(entry_group(1), entry_group(2), entry_group(0)))
generate_statement: /(?is)(?:\w+\s*:\s*(?:(for|if)\s+(.+?))\s*)?\bgenerate\b/ /(?is)\bend\s+generate\b.*?;/
-? push
-> comment                                 .push
-> dquote_string                           .push
-> block_statement                        .push
-> process_statement                       .push
#-> concurrent_procedure_call_statement    .push
#-> concurrent_assertion_statement         .push
-> generate_statement                      .push
-> component_instantiation_statement       .push
-> generate_statement[1]                   .return(array("?generate_statement:", flat_array(entry_groups()), copy(array(generate_statement))))
-> concurrent_signal_assignment_statement  .push


# Just avoid having BLOCK_STATEMENT related issues
block_statement: /(?i)(?:(\w+)\s*:\s*)?\bblock\b/ /(?i)\bend\s+block\b.*?;/
-> block_statement
-> comment
-> dquote_string
-> block_statement[1]  .return(array("?block_statement:", flat_array(entry_groups())))

component_instantiation_statement: /(?i)(\w+)\s*:\s*(?:entity\s+(\S+)(?:\s+\(\s*(\S+)\s*\))?|configuration\s+(\w+)|(?:component\s+)?(\w+))/  /;/
I {instantiation_parts = []}
-> comment                                 .push
-> dquote_string                           .push
-> space                                   .push
-> generic_map_aspect                      .push
-> port_map_aspect                         .push
-> component_instantiation_statement[1]    {
   set(array(instantiation_parts), entry_groups());
   lowercase_each(array(instantiation_parts));
   return(array("?component_instantiation_statement:", flat_array(instantiation_parts), copy(array(component_instantiation_statement))))
}


generic_map_aspect: /(?i)generic\s+map\s*\(/  /\)/
-> comment                .push
-> dquote_string          .push
-> space                  .push
-> association_element    .push
-> generic_map_aspect[1]  .return(array("?generic_map_aspect:", copy(array(generic_map_aspect))))


port_map_aspect: /(?i)port\s+map\s*\(/  /\)/
-> comment                .push
-> dquote_string          .push
-> space                  .push
-> association_element    .push
-> port_map_aspect[1]     .return(array("?port_map_aspect:", copy(array(port_map_aspect))))

# The 'port' is to deal w/ generic_map_aspect's association_element's followed
# by a port_map_aspect. I know it is not ** elegant ** but...
association_element: /(?is)(\w+)\s*=>\s*(.+?)(?=\s*(?:,|\)\s*(?:;|port\b)))/  I.return(array("?association_element:", flat_array(entry_groups())))

process_statement: /(?i)(?:(\w+)\s*:\s*)?\bprocess\b/  /(?i)\bbegin\b/ /(?is)\bend(?:\s+postponed)?\s+process\b.*?;/  I {pos_begin = undef; process_statement_part = undef}
-> comment                              .push
-> dquote_string                        .push
-> subprogram_body                      .push
-> subprogram_declaration               .push
-> type_declaration                     .push
-> subtype_declaration                  .push
-> constant_declaration                 .push
-> variable_declaration                 .push
-> file_declaration                     .push
-> alias_declaration                    .push
-> attribute_declaration                .push
-> attribute_specification              .push
-> use_clause                           .push
-> group_template_declaration           .push
-> group_declaration                    .push
-> if_endif 
-> case_endcase 
-> loop_endloop
-> process_statement[1]                 {pos_begin = cursor_pos()}

-> process_statement[2]                 {
   process_statement_part = substr($$STRING, $pos_begin, $LSPOS - $pos_begin - length $LMATCH);
   return(array("?process_statement:", flat_array(entry_groups()), copy(array(process_statement)), process_statement_part))
}


component_declaration:    /(?i)\bcomponent\s+(\w+)\s+is\b/ /(?i)\bend\b(?:\s+component\b)?(?:\s+\w+)?\s*;/
-? push
-> comment                  .push
-> dquote_string            .push
-> port_clause              .push
-> component_declaration[1] .return(array("?component_declaration:", flat_array(entry_groups()), copy(array(component_declaration))))


package_declaration:    /(?i)\bpackage\s+(\w+)\s+is\b/ /(?i)\bend\b(?!\s+component\b)(?:\s+package\b)?(?:\s+\w+)?\s*;/ 
I {imatch_copy = []}

-> comment                    .push
-> dquote_string              .push
-> space                      .push
-> subprogram_declaration     .push
-> type_declaration           .push
-> subtype_declaration        .push
-> constant_declaration       .push
-> signal_declaration         .push
-> variable_declaration       .push
-> file_declaration           .push
-> alias_declaration          .push
-> component_declaration      .push
-> attribute_declaration      .push
-> attribute_specification    .push
-> disconnection_specification.push
-> use_clause                 .push
-> group_template_declaration .push
-> group_declaration          .push
-> package_declaration[1]        {
	set(array(imatch_copy), array(entry_group(0)));
	lowercase_each(array(imatch_copy));
	return(array("?package_declaration:", array(imatch_copy).first(), copy(array(package_declaration))))
}


package_body: /(?i)\bpackage\s+body\s+(\w+)\s+is\b/ /(?i)\bend(?:\s+package\s+body)?(?:\s+\w+)?\s*;/ 

-> comment                   .push                    
-> dquote_string             .push             
-> space                     .push                          
-> subprogram_declaration    .push      
-> subprogram_body           .push                
-> type_declaration          .push        
-> subtype_declaration       .push   
-> constant_declaration      .push   
-> variable_declaration      .push   
-> file_declaration          .push               
-> alias_declaration         .push              
-> use_clause                .push     
-> group_template_declaration.push     
-> group_declaration         .push              
-> package_body[1]                .return(array("?package_body:", entry_group(0), copy(array(package_body))))


configuration_declaration: /(?i)\bconfiguration\s+(\w+)\s+of\s+(\w+)\s+is\b/  /(?i)\bend\b(?:\s+configuration\b)?(?:\s+(\w+))?\s*;/
-> use_clause                    .push
-> attribute_specification       .push
-> group_declaration             .push
-> block_configuration           .push
-> configuration_declaration[1]  .return(array("?configuration_declaration:", flat_array(entry_groups()), copy(array(configuration_declaration))))

block_configuration: /(?i)\bfor\b(?!\s+generate)/  /(?i)end\s+for\s*;/
-> use_clause
-> block_configuration
-> block_configuration[1]        .return([])

subprogram_declaration:    /(?i)(?:\b(procedure)|(?:\b(?:pure|impure)\s+)?\b(?<ISFUNC>function))\s+(\w+)(\s*\((?:[^\(\)]++|(?-1))+\))?(?(<ISFUNC>)\s*return\s+(\w+))\s*;/ I.return(array("?subprogram_declaration:", flat_array(entry_groups())))

subprogram_body:           /(?i)(?:\b(procedure)|(?:\b(?:pure|impure)\s+)?\b(?<ISFUNC>function))\s+(\w+)(\s*\((?:[^\(\)]++|(?-1))+\))?(?(<ISFUNC>)\s*return\s+(\w+))\s+is\b/   /(?i)\bbegin\b/ /(?is)\bend\b.*?;/
I {pos_begin = undef; subprogram_statement_part = undef; subprogram_statement_tokens = []}


-> comment 
-> dquote_string

-> if_endif 
-> case_endcase 
-> loop_endloop

-> subprogram_body
-> subprogram_declaration
-> type_declaration
-> subtype_declaration
-> constant_declaration
-> variable_declaration
-> file_declaration
-> alias_declaration
-> attribute_declaration
-> attribute_specification
-> use_clause
-> group_template_declaration
-> group_declaration

-> subprogram_body[1] {pos_begin = cursor_pos()}

-> subprogram_body[2] {
   subprogram_statement_part = substr($$STRING, $pos_begin, $LSPOS - $pos_begin - length $LMATCH);
   split(array(subprogram_statement_tokens), subprogram_statement_part, /((?:\s*--.*\s*)+|\s*;\s*)/);
   split_each(array(subprogram_statement_tokens), /^(\s+)/);
   filter_nonempty(array(subprogram_statement_tokens));
   return(array("?subprogram_body:", flat_array(entry_groups()), copy(array(subprogram_statement_tokens))))
}


begin_end:    /(?i)\bbegin\b/ /(?is)\bend\b.*?;/                   -> comment  -> dquote_string -> begin_end     -> if_endif     -> case_endcase -> loop_endloop  -> begin_end[1]    .return([])
if_endif:     /(?i)\bif\b(?!\s+generate)/ /(?is)\bend\s+if\b.*?;/  -> comment  -> dquote_string -> if_endif      -> case_endcase -> loop_endloop                  -> if_endif[1]     .return([])
case_endcase: /(?i)\bcase\b/ /(?is)\bend\s+case\b.*?;/             -> comment  -> dquote_string -> case_endcase  -> if_endif     -> loop_endloop                  -> case_endcase[1] .return([])
loop_endloop: /(?i)\bloop\b/ /(?is)\bend\s+loop\b.*?;/             -> comment  -> dquote_string -> loop_endloop  -> if_endif     -> case_endcase                  -> loop_endloop[1] .return([])
opar_cpar:    /\(/            /\)/                                 -> comment  -> dquote_string -> opar_cpar                                                      -> opar_cpar[1]    .return([])


# interface_declaration:  I {my @idecl}
# -> interface_constant_declaration        {return call(interface_constant_declaration)}     
# -> interface_signal_declaration          {return call(interface_signal_declaration)}
# -> interface_variable_declaration        {return call(interface_variable_declaration)}
# -> interface_file_declaration            {return call(interface_file_declaration)}


generic_clause:   /(?i)\bgeneric\s*\(/ /\)\s*;/
-? push
-> comment                      .push
-> dquote_string                .push
-> interface_signal_declaration .push
-> generic_clause[1]            .return (@generic_clause ? \@generic_clause : undef)


port_clause:   /(?i)\bport\s*\(/ /\)\s*;/
-? push
-> comment                      .push
-> dquote_string                .push
-> interface_signal_declaration .push
-> port_clause[1]               .return (@port_clause ? \@port_clause : undef)


interface_signal_declaration: /(\w+)\s*:\s*(\w+)\s+(\w+)/ /\s*;|\s*(?=\)\s*;)/
I {port_decl_parts = []}
-> signal_decl_range                 {set(array(port_decl_parts), entry_groups()); push(array(port_decl_parts), call(signal_decl_range))}
-> interface_signal_declaration[1]   {set(array(port_decl_parts), entry_groups()); return(array("?port_decl:", copy(array(port_decl_parts))))}


signal_decl_range: /\(/ /\)/ I {capt = []; msi_lsi = []}
LS {push(array(capt), capture_slice())}
LE {start_capture_slice()}

-> opar_cpar              {
   pos1 = undef;
   pos2 = undef;
   pos1 = pos($$STRING)-1;
   call(opar_cpar);
   pos2 = cursor_pos();
   push(array(capt), substr($$STRING, $pos1, $pos2-$pos1))
}
-> downto_or_to           {
   msi_lsi = undef;
   msi_lsi = join_values("", array(capt));
   substr(msi_lsi, /^\s+|\n\s*|\s+$/, //, goi);
   push(array(msi_lsi), msi_lsi);
   set(array(capt), array())
} 
-> signal_decl_range[1]   {
   if(not(is_empty(array(capt))));
    msi_lsi = undef;
    msi_lsi = join_values("", array(capt));
    if(msi_lsi);
     substr(msi_lsi, /^\s+|\n\s*|\s+$/, //, goi);
     push(array(msi_lsi), msi_lsi);
    endif();
   endif();

   return(flat_array(array(msi_lsi)))
}


type_declaration:     /(?is)\btype\s+(\w+)\s+is\s+/ /\s*;/

-> record_endrecord
-> type_declaration[1]      {
	type_definition = undef;
	type_definition = CAPTURE;
	return(array("?type_declaration:", flat_array(entry_groups()), type_definition))}
record_endrecord:   /(?is)\brecord\s.+?\bend\s+record\s+/


subtype_declaration:  /(?is)\bsubtype\s+(\w+)\s+is\s+(.+?)\s*;/                     I.return(array("?subtype_declaration:", flat_array(entry_groups())))
constant_declaration: /(?is)\bconstant\s+(.+?)\s*:\s*(.+?)(?:\s*:=\s*(.+?))?\s*;/   I {
  identifier_list = entry_group(0);
  subtype_indication = entry_group(1);
  expression = entry_group(2);

  return(split_tagged_records(identifier_list, /\s*,\s*/o, "?constant_declaration:", subtype_indication, expression))
}

variable_declaration: /(?is)\b(?:shared\s+)?variable\s+(.+?)\s*:\s*(.+?)(?:\s*:=\s*(.+?))?\s*;/ I {
  identifier_list = entry_group(0);
  subtype_indication = entry_group(1);
  expression = entry_group(2);

  return(split_tagged_records(identifier_list, /\s*,\s*/o, "?variable_declaration:", subtype_indication, expression))
}

file_declaration: /(?is)\bfile\s+(.+?)\s*:\s*(.+?)\s*;/ I {
  identifier_list = entry_group(0);
  remainder_info = entry_group(1);

  return(split_tagged_records(identifier_list, /\s*,\s*/o, "?file_declaration:", remainder_info))
}

alias_declaration:          /(?is)\balias\s+(\S+)\s+(.+?)?\bis\s+(\w+)(?:.*?)\s*;/    I.return(array("?alias_declaration:", flat_array(entry_groups())))
attribute_declaration:      /(?is)\battribute\s+(\w+)\s*:\s*(.+?)\s*;/                I.return(array("?attribute_declaration:", flat_array(entry_groups())))
attribute_specification:    /(?is)\battribute\s+(\w+)\s+of\s+(.+?)\s+is\s+(.+?)\s*;/  I.return(array("?attribute_specification:", flat_array(entry_groups())))
group_template_declaration: /(?is)group\s+(\w+)\s+is\s+\(\s*(.+?)\s*\)\s*;/           I.return(array("?group_template_declaration:", flat_array(entry_groups())))
group_declaration:          /(?is)group\s+(\w+)\s*:\s*(\w+)\s*\(\s*(.+?)\s*\)\s*;/    I.return(array("?group_declaration:", flat_array(entry_groups())))

signal_declaration: /(?is)\bsignal\s+(.+?)\s*:\s*(.+?)(?:\s+(register|bus))?(?:\s*:=\s*(.+?))?\s*;/ I {
  identifier_list = entry_group(0);
  subtype_indication = entry_group(1);
  signal_kind = entry_group(2);
  expression = entry_group(3);

  return(split_tagged_records(identifier_list, /\s*,\s*/o, "?signal_declaration:", subtype_indication, signal_kind, expression))
}

configuration_specification: /(?is)\bfor\s+(.+?)\s*:\s*(\w+)\s+(.+?)\s*;/ I {
  instantiation_list = entry_group(0);
  component_name = entry_group(1);
  binding_indication = entry_group(2);

  return(split_tagged_records(instantiation_list, /\s*,\s*/o, "?configuration_specification:", component_name, binding_indication))
}

downto_or_to: /(?i)\b(?:downto|to)\b/
disconnection_specification: /(?is)disconnection_specification\s+(.+)\s*;/ I.return(array("?disconnection_specification:", flat_array(entry_groups())))
