"""Author Lua source-only controls; no peer observations imported."""
import json
from pathlib import Path
BASE=Path(__file__).resolve().parent
profiles=[]
def add(identifier,body):
    profiles.append(dict(id=identifier,body=body,source='Value:: I {'+body+'}\n',input='x',rule='Value',profile_only=True))
def call(helper,source,receiver=False,extra=False):
    operands={'merge_hash':['{"b":2}'],'set_key':['"b"','2'],'rename_key':['"a"','"b"'],'drop_keys':['"a"'],'pick_keys':['"a"']}[helper]
    if extra: operands=operands+['{order=cat(order,"A");0}']
    return (source+'.'+helper+'('+','.join(operands)+')' if receiver else helper+'('+','.join([source]+operands)+')')
for helper in ('merge_hash','set_key','rename_key','drop_keys','pick_keys'):
    for kind,source in (('number','3'),('null','undef'),('array','[1]')):
        for receiver in (False,True):
            add('initial_'+kind+'_'+helper+('_receiver' if receiver else '_free'),'return('+call(helper,source,receiver)+')')
        add('initial_'+kind+'_'+helper+'_with','order="";out='+call(helper,source,True)+'.with(){order=cat(order,"W");return(value.count_keys())};return([out,order])')
for helper in ('merge_hash','set_key','rename_key'):
    for receiver in (False,True):
        add('extra_'+helper+('_receiver' if receiver else '_free'),'order="";out='+call(helper,'{order=cat(order,"S");{"a":1}}',receiver,True)+'.take({order=cat(order,"T");1}).with(){order=cat(order,"W");return("ran")};return([out,order])')
for helper in ('drop_keys','pick_keys'):
    for receiver in (False,True):
        value='{"a":1}.'+helper+'()' if receiver else helper+'({"a":1})'
        add(helper+('_receiver' if receiver else '_free')+'_zero_keys','order="";out='+value+'.take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])')
for identifier,source in (('prior_count','[1].count()'),('prior_key_count','{"a":1}.count_keys()'),('prior_length','"abc".length()'),('prior_view','sorted_keys({"a":1})'),('prior_copy','copy(3)'),('prior_array','array(1)')):
    add(identifier,'order="";out='+source+'.merge_hash({order=cat(order,"A");{"b":2}}).with(){order=cat(order,"W");return("ran")};return([out,order])')
assert len(profiles)==61
(BASE/'profile-sources.json').write_text(json.dumps(profiles,indent=2)+'\n')

shared=json.loads(Path('tests/fixtures/hash_value_result_guard_cases.json').read_bytes())
assert len(shared)==28
cases=shared+profiles
assert len(cases)==len({row['id'] for row in cases})==89
(BASE/'cases.json').write_text(json.dumps(cases,indent=2)+'\n')
fixture=Path('tests/fixtures/hash_value_result_guard_lua_cases.json')
assert not fixture.exists()
fixture.write_bytes((BASE/'cases.json').read_bytes())
old=Path('docs/checkpoints/hash-view-result-guard-lua-2026-11-07/observer.lua').read_text()
observer=old.replace('hash%-view%-result%-guard','hash%-value%-result%-guard').replace('hash-view-result-guard','hash-value-result-guard').replace('HASH_VIEW_LUA','HASH_VALUE_LUA')
observer=observer.replace('local json = l.json', 'local json = l.json\nio.stdout:write("HASH_VALUE_LUA_OWNER ", debug.getinfo(l.runtime_execute,"S").source, "\\n")',1)
needle='    local compiled = l.compile_spec(parsed)'
extra='\n    if identifier == "merge_later_with" or identifier == "set_copy_later_with" or identifier == "rename_logical_later_with" then\n      for _, payload in ipairs(l.compiled_spec.action_payloads(compiled.rules_by_label.Value)) do\n        io.stdout:write("HASH_VALUE_LUA_COMPILED_ACTION ", identifier, " ", json.encode(l.action_ast.to_json(payload.action_ast)), "\\n")\n      end\n    end'
assert observer.count(needle)==1
observer=observer.replace(needle,needle+extra)
(BASE/'observer.lua').write_text(observer)
normal=Path('lua/test/hash_view_result_guard_composition_test.lua').read_text()
normal=normal.replace('TYPE-REFERENCE-BOOK.1.2.23.3.76.5','TYPE-REFERENCE-BOOK.1.2.23.3.77.5').replace('Hash-view','pure Hash-helper').replace('hash%-view%-result%-guard','hash%-value%-result%-guard').replace('hash-view-result-guard','hash-value-result-guard').replace('HASH_VIEW_LUA','HASH_VALUE_LUA').replace('LINKEDSPEC_HASH_VIEW_CAPTURE','LINKEDSPEC_HASH_VALUE_CAPTURE').replace('hash_view_result_guard','hash_value_result_guard')
normal='local input_root = os.getenv("LINKEDSPEC_HASH_VALUE_INPUT_ROOT") or ""\n'+normal
normal=normal.replace('loadfile("lua/', 'loadfile(input_root .. "lua/').replace('io.open("specs/user_function_definition.spec",','io.open(input_root .. "specs/user_function_definition.spec",').replace('io.open("tests/fixtures/" .. name,','io.open(input_root .. "tests/fixtures/" .. name,')
normal=normal.replace('local json = l.json','local json = l.json\nio.stdout:write("HASH_VALUE_LUA_OWNER ", debug.getinfo(l.runtime_execute,"S").source, "\\n")',1)
out=Path('lua/test/hash_value_result_guard_composition_test.lua');assert not out.exists();out.write_text(normal)
print('89 source-only Lua programs, compiled-AST observer and ordinary normal authored; no imported observations')
