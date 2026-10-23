"""Declare independent public values/errors before modifying the runtime."""
import common as c

def main():
 cases=[]
 def pair(name,setup,body,expected=None,error=None,functions=''):
  for scope in ('ordinary','deferred'):
   case=dict(id=scope+'/'+name,body=setup+(body if scope=='ordinary' else 'cb = {|| '+body+' }; return(cb())'),functions=functions)
   case.update(error=error) if error else case.update(expected=expected)
   cases.append(case)
 pair('replace','items = [2,10,1]; ','items[0] = "changed"; return(items)',['changed',10,1])
 pair('absent','', 'document["sections"][0]["title"] = "Intro"; return(document)',{'sections':[{'title':'Intro'}]})
 pair('absent-array','', 'document[0]["name"] = "first"; return(document)',[{'name':'first'}])
 pair('string-key','key = "0"; ', 'document[key] = "zero"; return(document)',{'0':'zero'})
 pair('integer-key','key = 0; ', 'document[key] = "zero"; return(document)',['zero'])
 pair('append','items = ["a"]; ', 'items[1] = "b"; return(items)',['a','b'])
 pair('copy','original = [[1]]; chosen = original; ', 'out = (chosen[0][0] = 2); out[0][0] = 3; return([original,chosen,out])',[[[1]],[[2]],[[3]]])
 pair('rhs-copy','rhs = [1]; ', 'document["x"] = rhs; rhs[0] = 2; return([document,rhs])',[{'x':[1]},[2]])
 pair('caller-slot','items = [1]; cb = {|| items[0] = 2; return(items) }; ', 'out = cb(); return([items,out])',[[2],[2]])
 pair('call-rebind','items = [1]; cb = {|| items[0] = 2; return(items) }; ', 'items = [3,4]; out = cb(); return([items,out])',[[2,4],[2,4]])
 pair('parameter','items = [1]; cb = {|items| items[0] = 2; return(items) }; ', 'out = cb(items); return([items,out])',[[1],[2]])
 pair('rest','items = [1]; cb = {|...values| values[0] = 2; return(values) }; ', 'out = cb(1,3); return([items,out])',[[1],[2,3]])
 pair('registered','', 'return(build())',{'x':[2]},functions='fn build() { cb = {|| document["x"][0] = 2; return(document) }; return(cb()) }\n')
 pair('repeat','', 'a = build(); a["x"][0] = 3; return([a,build()])',[{'x':[3]},{'x':[2]}],functions='fn build() { cb = {|| document["x"][0] = 2; return(document) }; return(cb()) }\n')
 pair('nested-calls','', 'inner = {|| document["x"] = 2; return(document) }; outer = {|| return(inner()) }; out = outer(); return([document,out])',[{'x':2},{'x':2}])
 pair('null-caller','document = undef; ', 'document["x"] = 2; return(document)',error='nested_write_kind_conflict')
 pair('null-parameter','cb = {|document| document["x"] = 2; return(document) }; ', 'return(cb(undef))',error='nested_write_kind_conflict')
 pair('null-prior-call','setnull = {|| document = undef }; ', 'setnull(); document["x"] = 2; return(document)',error='nested_write_kind_conflict')
 pair('scalar-conflict','document = "text"; ', 'document["x"] = 2; return(document)',error='nested_write_kind_conflict')
 pair('gap','document = []; ', 'document[2]["x"] = 2; return(document)',error='nested_write_array_gap')
 for name,key in [('boolean','true'),('negative','-1'),('fraction','1.5'),('integral-float','0.0'),('null','undef'),('array','[]'),('harray','{}')]:
  pair('invalid/'+name,'', 'document['+key+'] = 2; return(document)',error='nested_write_segment_invalid')
 pair('effects','seen = ""; key = {|| seen = cat(seen,"k"); return("x") }; rhs = {|| seen = cat(seen,"r"); return(2) }; ', 'document[key()] = rhs(); return([document,seen])',[{'x':2},'kr'])
 pair('same-binding-rhs','document = {"audit":[]}; rhs = {|| document["audit"][0] = "rhs"; return("done") }; ', 'document["value"] = rhs(); return(document)',{'audit':['rhs'],'value':'done'})
 pair('same-binding-segment','key = {|| document = {"seed":1}; return("value") }; ', 'document[key()] = "done"; return(document)',{'seed':1,'value':'done'})
 pair('with-null','cb = {|| value["x"] = 2; return(value) }; ', 'return(with(undef) { return(cb()) })',error='nested_write_kind_conflict')
 plan=dict(cases=cases)
 c.save('cases.json',plan)
 supplied=c.epoch();run=c.observe(plan);failed=c.failures(run,plan)
 c.save('baseline.json.gz',dict(context=supplied,run=run,failures=failed))
 print('Declared',len(cases),'public cases;',len(failed),'baseline failures retained')
if __name__=='__main__':main()
