"""Add explicit error-record shape checks for the actual corruption controls."""
import gzip,hashlib,json
from pathlib import Path
BASE=Path(__file__).resolve().parent
source=(BASE/'review_unloaded.py').read_text()
assert (BASE/'unloaded-review-exit.txt').read_text()=='1\n'
assert b"TypeError: 'NoneType' object is not subscriptable" in gzip.decompress((BASE/'unloaded-review-stderr.log.gz').read_bytes())
needle="        if key in RECEIVERS:\n"
addition="        if key in RED or case.get('expected_error'):\n            assert isinstance(row.get('native_error'),dict)\n            if key not in RECEIVERS:assert isinstance(row.get('fresh_error'),dict)\n"
assert source.count(needle)==1
qualified=source.replace(needle,addition+needle)
tail="if __name__=='__main__':\n";assert qualified.count(tail)==1
checks='''    for name,row in json.loads((ROOT/BASE/'typed-error-identities.json').read_bytes()).items():
        relative=PurePosixPath(name);assert not relative.is_absolute() and '..' not in relative.parts
        body=(ROOT/relative).read_bytes();assert len(body)==row['bytes'] and digest(body)==row['sha256']
    assert (ROOT/BASE/'unloaded-review-exit.txt').read_text()=='1\\n'
    assert b"TypeError: 'NoneType' object is not subscriptable" in gzip.decompress((ROOT/BASE/'unloaded-review-stderr.log.gz').read_bytes())
'''
qualified=qualified.replace(tail,tail+checks)
qualified=qualified.replace("    print(json.dumps(result,indent=2,sort_keys=True))\n","    result['error_shape_qualification']='second reader halted at first corrupted None error record; separate reader explicitly validates error-record shapes; all earlier failures/observations/seals remain unchanged'\n    print(json.dumps(result,indent=2,sort_keys=True))\n")
compile(qualified,str(BASE/'review_typed_errors.py'),'exec')
out=BASE/'review_typed_errors.py';assert not out.exists();out.write_text(qualified)
record=dict(prior_reader_sha256=hashlib.sha256(source.encode()).hexdigest(),qualified_reader_sha256=hashlib.sha256(qualified.encode()).hexdigest(),prior_exit=1,added_assertions=addition,scope='strict reader error-record shape checks for original RED/error rows and actual counterfactual controls; no SDK/observation/source/target/artifact edits')
(BASE/'typed-error-qualification.json').write_text(json.dumps(record,indent=2,sort_keys=True)+'\n')
print('separate typed-error reader authored; both earlier reader failures unchanged')
