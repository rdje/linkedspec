"""Fixed public drop key cardinalities and independent value/copy/effect controls."""
import json
import common as c


def main():
    cases=[]
    base={'kind':'node','debug':1,'stage':'parse'}
    kept={'kind':'node','stage':'parse'}
    def add(name,body,value=None,role='value',has_value=True):
        row=dict(id=name,body=body,role=role)
        if has_value:row['expected']=value
        cases.append(row)
    for style in ('call','receiver'):
        def expression(keys,source='meta'):
            return 'drop_keys('+source+(','+keys if keys else '')+')' if style=='call' else source+'.drop_keys('+keys+')'
        prefix='meta = {"kind":"node","debug":1,"stage":"parse"}; '
        shapes=[('one','"debug"',kept),('two','"debug","stage"',{'kind':'node'}),
                ('missing','"missing"',base),('duplicate','"debug","debug"',kept),
                ('flat-zero','flat_array([])',base),('flat-one','flat_array(["debug"])',kept),
                ('flat-two','flat_array(["debug","stage"])',{'kind':'node'}),
                ('mixed-flat','"debug",flat_array(["stage"])',{'kind':'node'})]
        for name,keys,value in shapes:
            add(style+'/'+name,prefix+'return('+expression(keys)+')',value)
        add(style+'/binding-key',prefix+'drop_key = "debug"; return('+expression('drop_key')+')',kept)
        add(style+'/empty-key','meta = {"":3,"keep":7}; return('+expression('""')+')',{'keep':7})
        for name,key in (('number-key','1'),('numeric-string-key','"1"')):
            add(style+'/'+name,'meta = {"1":"one","keep":7}; return('+expression(key)+')',{'keep':7})
        body=prefix+'calls = 0; read_drop_key = {|| calls = num_add(calls,1); return("debug") }; '
        add(style+'/computed-once',body+'out = '+expression('read_drop_key()')+'; return([out,calls])',[kept,1])
        body=prefix+'drop_key = "debug"; read_other_drop_key = {|| drop_key = "stage"; return("debug") }; '
        add(style+'/key-value-snapshot',body+'out = '+expression('drop_key,read_other_drop_key()')+'; return([out,drop_key])',[kept,'stage'])
        add(style+'/copy-result',prefix+'original = meta; out = '+expression('"debug"')+'; out = set_key(out,"extra",9); return([original,meta,out])',
            [base,base,{'kind':'node','stage':'parse','extra':9}])
        add(style+'/saved-copy',prefix+'out = '+expression('"debug"')+'; meta = set_key(meta,"stage","changed"); return([out,meta])',
            [kept,{'kind':'node','debug':1,'stage':'changed'}])
        add(style+'/continuation',prefix+'return('+expression('"debug"')+'.count_keys())',2)
        for name,keys in (('no-keys',''),('null-key','null'),('boolean-key','true'),('array-key','["debug"]'),('hash-key','{"key":"debug"}')):
            add('diagnostic/'+style+'/'+name,prefix+'return('+expression(keys)+')',role='diagnostic-control',has_value=False)
    for name,body in (
        ('no-arguments','return(drop_keys())'),
        ('scalar-source','return(drop_keys(7,"debug"))'),
        ('array-source','return(drop_keys([1,2],"debug"))'),
        ('null-source','return(drop_keys(null,"debug"))'),
    ):
        add('diagnostic/'+name,body,role='diagnostic-control',has_value=False)
    assert len(cases)==len({row['id'] for row in cases})
    data=dict(owner=c.OWNER,cases=cases,
        scope='Independent desired values for published call/receiver forms, explicit key-list cardinalities and '
              'copy/effect controls. Diagnostic controls retain actual accepted behavior without inventing a new key/arity contract.')
    path=c.ROOT/'tests/drop-generated/cases.json'
    with path.open('x') as out:json.dump(data,out,sort_keys=True,separators=(',',':'));out.write('\n')
    print('Fixed drop population:',len(cases),'; independent value cases',sum('expected' in row for row in cases))


if __name__=='__main__':
    main()
