"""Compare every historical predicate row before changing the consumer oracle."""
import copy,json,re
import common as c
PATTERN=re.compile(r'\Ado \{ \$([A-Za-z_][A-Za-z0-9_]*) = (.*); \$__ls_binding_presence\{"\1"\} = 1(; \$\1)? \}\Z',re.S)
def emission(value):
 if isinstance(value,str):
  match=PATTERN.fullmatch(value)
  if match:
   name,operand,old_result=match.groups()
   return 'do { $'+name+' = '+operand+'; $__ls_binding_presence{"'+name+'"} = 1; scalar($'+name+') }',0 if old_result else 1
  return value,0
 if isinstance(value,list):
  transformed=[emission(item) for item in value]
  return [item[0] for item in transformed],sum(item[1] for item in transformed)
 return copy.deepcopy(value),0
def project(row):
 result=copy.deepcopy(row)
 if result['owner']!='nested' or result['path']!='consumer':return result
 result['value'],_=emission(result['value'])
 result['values'],delta=emission(result['values'])
 if result['target_coercions']:result['target_coercions']+=delta
 return result
def differences(old,new,path=''):
 if isinstance(old,dict) and isinstance(new,dict):
  assert set(old)==set(new),(path,set(old)^set(new))
  return sum((differences(old[key],new[key],path+'/'+key) for key in old),[])
 if isinstance(old,list) and isinstance(new,list):
  assert len(old)==len(new),(path,len(old),len(new))
  return sum((differences(a,b,path+'/'+str(index)) for index,(a,b) in enumerate(zip(old,new))),[])
 return [] if type(old)==type(new) and old==new else [dict(path=path,before=old,after=new)]
def check():
 rejected=c.load('rejected-canonical2.json.gz')
 assert rejected['readonly']['returncode']==0 and rejected['canonical_result']['exit_code']==1
 for path,image in rejected['sources'].items():assert c.read(path)==image,path
 original=json.loads((c.ROOT/'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-before-native.json').read_bytes())
 all_rows=[];total=0
 for index,mode in enumerate(('observe','cold-observe')):
  native=json.loads(c.decode(original['rows'][index]['stdout_base64']))
  actual=json.loads(c.decode(rejected['observed'][mode]['stdout_base64']))
  assert actual['loaded_before']==0 and actual['loaded_after']==(0 if index else 1)
  for group in ('callbacks','branches','authority'):
   assert [row['id'] for row in native[group]]==[row['id'] for row in actual[group]]
   for before,observed in zip(native[group],actual[group]):
    expected=copy.deepcopy(before)
    if group=='authority':
     if expected['eligible']:expected['eligible']=[1 if expected['id'].endswith('/known-1') else 0]
     expected['parent_packet']=0
    delta=differences(expected,observed)
    projected=project(expected)
    assert projected==observed,(mode,group,expected['id'],differences(projected,observed))
    if delta:
     assert expected['owner']=='nested' and expected['path']=='consumer'
     assert all(row['path']=='/target_coercions' or row['path'].startswith('/value') for row in delta),delta
     for change in delta:
      if change['path']=='/target_coercions':
       assert mode=='observe' and group=='branches' and expected['id']=='nested/consumer/target-object'
       assert change['before']==4 and change['after']==5
     all_rows.append(dict(mode=mode,group=group,id=expected['id'],changes=delta))
    total+=1
 return dict(total_rows=total,changed_rows=all_rows)
if __name__=='__main__':
 result=check()
 c.save('tracking-full-row-comparison.json.gz',dict(result=result,producer=c.read(c.PREFIX+'compare_tracking.py')))
 print('Complete rows:',result['total_rows'],'changed consumer rows:',len(result['changed_rows']))
 print('All callback, alias, fetch, boolean/error and authority fields match; only exact consumer source and target4->5 change')
