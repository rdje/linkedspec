"""Use the actual definition AST and public emitter for four function controls."""
import json
import common as c
import emit_source as p

root=p.workspace('numeric55-function-emission-producer')
name='linkedspec-numeric-function-emission'
p.manifest(root,name,core=True)
source=p.MAIN.replace('tests/numeric-conversion/programs.json','tests/numeric-conversion/functions.json')
source=source.replace('        assert!(authored.starts_with("Top:"));\n','')
(root/'src/main.rs').write_text(source)
path,artifact,supplied=p.build(root,name,'function-emission-producer')
run=p.execute(path,artifact,supplied,'function-emission-producer')
result=json.loads(c.decode(run['stdout_base64']))
assert len(result['entries'])==4
c.save('function-emission-result.json.gz',result)
print('Four real function-definition sources merged, compiled and emitted.',flush=True)
