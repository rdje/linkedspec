regdef_top::
-> reg_def  {push(reg_def)}
-> comment

LX {return(array("?regdef_top:", copy(array(regdef_top))))}

reg_def: /(?is)\breg_def\s+(\w+).+?(?<!\\)\{/  /(?<!\\)\}/
-> reg_fld         {push(reg_fld)}
-> comment
-> ml_dquotes
-> ob_cb
-> reg_def[1]      {return(array("?reg_def:", flat_array(entry_groups()), copy(array(reg_def))))}

reg_fld: /(?is)\breg_fld\s+(\w+).+?:\s*(\w+)\s*:.+?;/  I.return(array("?reg_fld:", flat_array(entry_groups())))

ob_cb:    /(?<!\\)\{/   /(?<!\\)\}/     
-> ob_cb  
-> comment
-> ml_dquotes
-> ob_cb[1]    {return(1)}

comment: /(?:\/\/|--).*/
ml_dquotes: /(?s)(?<!\\)".*?(?<!\\)"/
