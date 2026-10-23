"""Check producer syntax, every mutation anchor and selected IDs before mutation."""
import ast,json
import common as c
names=['faults8.py','attribute8.py','verify2.py','book8.py','check_search_native2.py']
for name in names:compile((c.ROOT/c.PREFIX/name).read_bytes(),c.PREFIX+name,'exec')
tree=ast.parse((c.ROOT/c.PREFIX/'faults8.py').read_text())
main=next(node for node in tree.body if isinstance(node,ast.FunctionDef) and node.name=='main')
environment=dict(runtime=c.SOURCES[0],emitter=c.SOURCES[1])
def literal(node):
 if isinstance(node,ast.Constant):return node.value
 if isinstance(node,ast.List):return [literal(item) for item in node.elts]
 if isinstance(node,ast.Tuple):return tuple(literal(item) for item in node.elts)
 if isinstance(node,ast.Name):return environment[node.id]
 if (isinstance(node,ast.Subscript) and isinstance(node.value,ast.Attribute)
     and isinstance(node.value.value,ast.Name) and node.value.value.id=='c'
     and node.value.attr=='SOURCES'):
  return c.SOURCES[literal(node.slice)]
 raise AssertionError(ast.dump(node))
tasks=literal(next(node.value for node in main.body if isinstance(node,ast.Assign)
 and any(isinstance(target,ast.Name) and target.id=='tasks' for target in node.targets)))
for node in main.body:
 if (isinstance(node,ast.Expr) and isinstance(node.value,ast.Call)
     and isinstance(node.value.func,ast.Attribute) and isinstance(node.value.func.value,ast.Name)
     and node.value.func.value.id=='tasks' and node.value.func.attr=='append'):
  tasks.append(literal(node.value.args[0]))
plan=json.loads((c.ROOT/'tests/numeric-codeblocks/indexed-writes.json').read_bytes())
ids={case['id'] for case in plan['cases']}
for name,path,needle,replacement,selected in tasks:
 assert c.decode(c.read(path)['base64']).decode().count(needle)==1,name
 assert set(selected)<=ids,name
marker=next(node.value.value for node in ast.walk(main) if isinstance(node,ast.Assign)
 and isinstance(node.value,ast.Constant) and isinstance(node.value.value,str)
 and any(isinstance(target,ast.Name) and target.id=='marker' for target in node.targets)
 and '$returns_value' in node.value.value)
assert c.decode(c.read(c.SOURCES[1])['base64']).decode().count(marker)==1
syntax={path:c.run(['bash','tools/project_data_run.sh','perl','-Iperl','-c',path])
 for path in c.SOURCES+['t/callable_codeblock_literal_contract.t','t/multiline_helper_pattern_validation.t']}
c.save('repair-proof-preflight.json.gz',dict(producers={name:c.read(c.PREFIX+name) for name in names},
 sources={path:c.read(path) for path in c.SOURCES},tasks=tasks,raw_marker=marker,syntax=syntax,
 producer=c.read(c.PREFIX+'preflight_repair_proof.py')))
assert all(run['returncode']==0 for run in syntax.values()),syntax
print('Producer syntax,',len(tasks),'public mutation anchors, raw-fragment anchor and Perl syntax PASS')
