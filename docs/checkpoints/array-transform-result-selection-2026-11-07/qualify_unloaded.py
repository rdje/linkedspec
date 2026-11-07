"""Qualify only the unloaded-module field assumption in the historical reader."""
import gzip,hashlib,json
from pathlib import Path
BASE=Path(__file__).resolve().parent
source=(BASE/'review.py').read_text();old="assert row['fresh_error'] is None and row['native'] is None"
new="assert 'fresh_error' not in row and 'fresh' not in row and row['native'] is None"
assert source.count(old)==1 and (BASE/'review-exit.txt').read_text()=='1\n'
error=gzip.decompress((BASE/'review-stderr.log.gz').read_bytes());assert b"KeyError: 'fresh_error'" in error
qualified=source.replace(old,new)
needle="    reject('receiver compilation failure normalized',lambda:mutate('take_receiver_hash_guard','loaded',1))\n"
assert qualified.count(needle)==1
qualified=qualified.replace(needle,needle+"    reject('invented fresh execution after failed load',lambda:mutate('take_receiver_hash_guard','fresh_error',None))\n")
tail="if __name__=='__main__':print(json.dumps(main(),indent=2,sort_keys=True))\n";assert qualified.endswith(tail)
new_tail='''if __name__=='__main__':
    for name,row in json.loads((ROOT/BASE/'unloaded-identities.json').read_bytes()).items():
        relative=PurePosixPath(name);assert not relative.is_absolute() and '..' not in relative.parts
        body=(ROOT/relative).read_bytes();assert len(body)==row['bytes'] and digest(body)==row['sha256']
    assert (ROOT/BASE/'review-exit.txt').read_text()=='1\\n'
    assert b"KeyError: 'fresh_error'" in gzip.decompress((ROOT/BASE/'review-stderr.log.gz').read_bytes())
    result=main();result['reader_qualification']='original first reader assumed a fresh-execution field for unloaded modules; separate reader requires actual field absence; original producer/observations/targets/reader/seal unchanged'
    print(json.dumps(result,indent=2,sort_keys=True))
'''
qualified=qualified[:-len(tail)]+new_tail
out=BASE/'review_unloaded.py';assert not out.exists();out.write_text(qualified)
record=dict(original_reader_sha256=hashlib.sha256(source.encode()).hexdigest(),qualified_reader_sha256=hashlib.sha256(qualified.encode()).hexdigest(),original_exit=1,old_assumption=old,new_assertion=new,additional_control='invented fresh execution after failed load',scope='reader-only protocol correction; no producer/source/target/artifact/observation edit')
(BASE/'unloaded-qualification.json').write_text(json.dumps(record,indent=2,sort_keys=True)+'\n')
print('separate unloaded-module reader authored; original first failure/seal unchanged')
