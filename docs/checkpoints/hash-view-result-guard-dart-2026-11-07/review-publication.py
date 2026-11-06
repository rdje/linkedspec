"""Readonly publication transport for unchanged historical Dart recovery."""
import gzip,hashlib,json,runpy
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];BASE=Path('docs/checkpoints/hash-view-result-guard-dart-2026-11-07')
def digest(b):return hashlib.sha256(b).hexdigest()
def decode(packed,row):
 assert digest(packed)==row['capsule_sha256']
 body=gzip.decompress(packed);assert len(body)==row['raw_bytes'] and digest(body)==row['raw_sha256']
 return body

def main():
 for p,value in json.loads((ROOT/BASE/'publication-identities.json').read_bytes()).items():assert digest((ROOT/p).read_bytes())==value
 aliases=json.loads((ROOT/BASE/'reader-channel-aliases.json').read_bytes())
 assert set(aliases)=={str(BASE/'review-stderr.log'),str(BASE/'review-qualified-stderr.log')}
 original=Path.read_bytes;virtual={};rejected=[]
 final_identities=json.loads((ROOT/BASE/'final-identities.json').read_bytes())
 for p,row in aliases.items():
  assert row['capsule']==p+'.gz' and not (ROOT/p).exists()
  packed=original(ROOT/row['capsule']);body=decode(packed,row);assert digest(body)==final_identities[p]
  virtual[(ROOT/p).resolve()]=body
  try:decode(packed+b'corrupted',row)
  except AssertionError:rejected.append(p)
  else:raise AssertionError('ineffective capsule corruption')
 seen=set()
 def read_bytes(path):
  resolved=path.resolve()
  if resolved in virtual:seen.add(resolved);return virtual[resolved]
  return original(path)
 namespace=runpy.run_path(str(ROOT/BASE/'review-final.py'),run_name='historical_hash_view_dart_review')
 try:
  Path.read_bytes=read_bytes
  historical=namespace['main']()
 finally:Path.read_bytes=original
 assert seen==virtual.keys()
 assert historical==json.loads((ROOT/BASE/'review-final-result.json').read_bytes())
 return dict(historical=historical,lossless_failed_channel_aliases=len(aliases),transport_corruptions=rejected,scope='publication transport only; historical producer/reader versions and all raw byte identities unchanged')
if __name__=='__main__':print(json.dumps(main(),indent=2,sort_keys=True))
