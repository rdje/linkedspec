regdef_top::
-> reg_def  {push(reg_def)}
-> comment

LX {return(a("?regdef_top:", array_copy(a(regdef_top))))}

reg_def: /(?is)\breg_def\s+(\w+).+?(?<!\\)\{/  /(?<!\\)\}/
-> reg_fld         {push(reg_fld)}
-> comment
-> ml_dquotes
-> ob_cb
-> reg_def[1]      {return(a("?reg_def:", flat_array(entry_groups()), array_copy(a(reg_def))))}

reg_fld: /(?is)\breg_fld\s+(\w+).+?:\s*(\w+)\s*:.+?;/  I.return(a("?reg_fld:", flat_array(entry_groups())))

ob_cb:    /(?<!\\)\{/   /(?<!\\)\}/     
-> ob_cb  
-> comment
-> ml_dquotes
-> ob_cb[1]    {return(1)}

comment: /(?:\/\/|--).*/
ml_dquotes: /(?s)(?<!\\)".*?(?<!\\)"/
