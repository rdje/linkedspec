"""Author normalized split-source metadata and exact scalar occurrence intervals."""
from pathlib import Path
import json
PREFIX=__file__.removesuffix('oracle.py')
def author():
    definitions=[
        ('bare',"split(items, input, ',')",'$input',None),
        ('literal',"split(items, ' 雪,β ', ',')","' 雪,β '",None),
        ('compound',"split(items, cat('雪', ',β'), ',')","cat('雪', ',β')",None),
        ('legacy',"split(items, input, ',')",'legacy',{'source_symbol':'legacy'}),
        ('canonical_precedence',"split(items, input, ',')","'canonical'",{'source_expr':"'canonical'",'source_symbol':'legacy'}),
        ('canonical_zero',"split(items, input, ',')",'0',{'source_expr':'0','source_symbol':'legacy'}),
        ('undefined_canonical',"split(items, input, ',')",'legacy',{'source_expr':None,'source_symbol':'legacy'}),
        ('missing_source',"split(items, input, ',')",None,{}),
    ]
    cases=[]
    for name,expr,source,custom in definitions:
        parts=['# 雪\r\nprint "quoted ',expr,'";\r\n',expr,';\r\n',expr]
        action='';spans=[]
        for index,part in enumerate(parts):
            start=len(action);action+=part
            if index in (1,3,5):spans.append({'start':start,'end':len(action)})
        plan={'target_symbol':'items','ops':[{'op':'split','delimiter_expr':'/\\,/',**({'source_expr':source} if custom is None else custom)}]}
        if custom is None:plan['binding_target']=1
        cases.append({'id':name,'expr':expr,'action':action,'spans':spans,'source_after':source,
                      'source_before':None if custom is None else custom.get('source_symbol'),'custom_plan':custom is not None,'plan':plan})
    return cases
if __name__=='__main__':
    Path(PREFIX+'cases.json').write_text(json.dumps(author(),ensure_ascii=False,indent=2)+'\n')
    print('Authored eight normalized/legacy metadata cases and24 scalar source intervals')
