"""Freeze independent Perl profiles from qualified full-source intake."""
import json
from pathlib import Path
b=Path(__file__).resolve().parent
rows={}
for line in (b/'intake-qualified/stdout.log').read_text().splitlines():
 if line.startswith('CALLABLE_KEY_COUNT_PERL '):
  _,i,body=line.split(' ',2);rows[i]=json.loads(body)
assert len(rows)==15
profiles={}
for i in ['boolean_receiver_profile','malformed_receiver_profile','needed_argument_error']:
 r=rows[i]
 assert r['native_callable'] and r['loaded'] and r['warnings']==[]
 assert not any(r[k] for k in ['descriptor_error','emission_error','build_error','load_error'])
 assert r['native_cursor']==r['fresh_cursor']==0
 assert r['metadata']['raw_perl_dependency_count']==r['metadata']['canonical_action_ir_fallback_count']==0
 profiles[i]={k:r[k] for k in ['native','fresh','native_error','fresh_error','metadata']}
p=Path('tests/fixtures/key_count_callable_perl_profiles.json')
with p.open('x') as f:f.write(json.dumps(profiles,indent=2,sort_keys=True)+'\n')
print('Three actual Perl source/error profiles frozen; no peer import.')
