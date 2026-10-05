"""Read-only retained census review. --live adds current census/lstat and fixture proof."""
import argparse,copy,hashlib,importlib.util,json,stat
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/REPO-HYGIENE.10-'
def validate_counts(data):
 rows=data['rows']
 assert data['artifact_files']==len(rows)
 assert data['artifact_bytes']==sum(r['bytes'] for r in rows)
 for suffix,value in data['by_suffix'].items():
  assert value=={'files':sum(r['suffix']==suffix for r in rows),'bytes':sum(r['bytes'] for r in rows if r['suffix']==suffix)}
 for value in data['rust_log_bin'].values():
  assert value['files']==len(value['rows']) and value['bytes']==sum(r['bytes'] for r in value['rows'])
def validate_metadata(data):
 seen=set()
 for row in data['rows']+[r for v in data['rust_log_bin'].values() for r in v['rows']]:
  path=ROOT/row['path'];resolved=path.resolve()
  assert resolved.is_relative_to(ROOT) and row['path'] not in seen
  seen.add(row['path']);actual=path.lstat()
  assert stat.S_ISREG(actual.st_mode) and actual.st_dev==ROOT.stat().st_dev
  assert actual.st_size==row['bytes'] and path.name.endswith(row['suffix']),row['path']
def reject(callback):
 try:callback()
 except AssertionError:return True
 raise AssertionError('corruption accepted')
def main():
 args=argparse.ArgumentParser();args.add_argument('--live',action='store_true');options=args.parse_args()
 record=json.loads((ROOT/(PREFIX+'artifact-review.json')).read_bytes());validate_counts(record)
 bad=copy.deepcopy(record);bad['artifact_files']+=1;reject(lambda:validate_counts(bad))
 result={'owner':'REPO-HYGIENE.10','result':'PASS','at_utc':record['at_utc'],'artifact_files':record['artifact_files'],'artifact_bytes':record['artifact_bytes'],'removed_files':0,'removed_bytes':0,'aggregate_inflation_rejected':True,'live_metadata_checked':options.live}
 if options.live:
  spec=importlib.util.spec_from_file_location('census',ROOT/(PREFIX+'census.py'));module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
  fresh=module.census(ROOT)
  for key,value in fresh.items():assert record[key]==value,key
  validate_metadata(record)
  balanced=copy.deepcopy(record);logs=[r for r in balanced['rows'] if r['suffix']=='.log' and r['bytes']>0]
  assert len(logs)>=2;logs[0]['bytes']+=1;logs[1]['bytes']-=1
  validate_counts(balanced);reject(lambda:validate_metadata(balanced))
  fixture=ROOT/'.linkedspec-data/scratch/hygiene10/fixture';fixture.mkdir(parents=True,exist_ok=True)
  for name,data in [('kept.log',b'log'),('kept.bin',b'bin'),('.DS_Store',b'meta'),('ordinary.txt',b'text')]: (fixture/name).write_bytes(data)
  for directory in ('rgx','.git','.agents','nested'):
   p=fixture/directory;p.mkdir(exist_ok=True);(p/'excluded.log').write_text('excluded')
  (fixture/'nested/.git').mkdir(exist_ok=True)
  rows,nested,links,volumes=module.scan(fixture,fixture,{'.git','.agents'},{'rgx'})
  assert {(r['path'],r['bytes']) for r in rows}=={('kept.log',3),('kept.bin',3),('.DS_Store',4)} and nested==['nested']
  result.update(fresh_metadata_census_matches=True,per_file_os_metadata_oracle_matches=True,balanced_size_redistribution_rejected=True,included_fixture=['kept.log','kept.bin','.DS_Store'],excluded_fixture=['ordinary.txt','.git/excluded.log','.agents/excluded.log','rgx/excluded.log','nested/excluded.log'])
 result['inputs']={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in (PREFIX+'census.py',PREFIX+'review.py',PREFIX+'artifact-review.json','tools/run_python_project_data.sh','tools/project_data_env.sh','tools/project_data_run.sh')}
 result['limits']='Dated per-file metadata census, not content hash ownership or disposability proof. Retain all artifacts/caches; exclude submodules/nested repositories and managed runs; no deletion or liveness/purge guarantee.'
 print(json.dumps(result,indent=2,sort_keys=True))
if __name__=='__main__':main()
