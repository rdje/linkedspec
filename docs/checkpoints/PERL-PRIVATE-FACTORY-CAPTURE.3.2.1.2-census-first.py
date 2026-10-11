import json
from pathlib import Path
writes={'perl/LinkedSpec/ActionIR/MethodLowering.pm','docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md','docs/knowledge/perl-method-trim-capture.md','docs/knowledge/perl-legacy-hash-kind-callback.md','CHANGES.md','DEVELOPMENT_NOTES.md','KNOWLEDGE_MAP.md','LIVE_ACHIEVEMENT_STATUS.md','MEMORY.md','ROADMAP.md','ROADMAP_V2.md','docs/TASK_TREE.md','docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md'}
for p in sorted(Path('docs/claims').glob('*.json')):
 for c in json.loads(p.read_bytes())['claims']:
  d=c['durability'];common=writes&{x['path'] for x in d['inputs']}
  if d.get('mode')=='live' and common:print(json.dumps({'claim':p.as_posix(),'name':c['name'],'bindings':len(d['inputs']),'bytes':p.stat().st_size,'intersections':sorted(common)}))
