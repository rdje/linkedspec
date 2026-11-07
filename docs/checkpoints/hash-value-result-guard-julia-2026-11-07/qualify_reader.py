"""Qualify one reader-only assumption against already captured host version bytes."""
import gzip,hashlib,json
from pathlib import Path
BASE=Path(__file__).resolve().parent
original=(BASE/'review.py').read_text()
needle="b'julia version 1.12.6' in raw(phase,tag='version')"
replacement="raw(phase,tag='version')==raw('intake',tag='version') and re.fullmatch(rb'julia version [0-9]+\\.[0-9]+\\.[0-9]+\\n',raw(phase,tag='version'))"
assert original.count(needle)==1
assert (BASE/'review-exit.txt').read_text()=='1\n'
error=gzip.decompress((BASE/'review-stderr.log.gz').read_bytes())
assert b'line 131' in error and b'julia version 1.12.6' in error
source=original.replace(needle,replacement)
tail="if __name__=='__main__':print(json.dumps(main(),indent=2,sort_keys=True))\n"
assert source.endswith(tail)
new_tail='''if __name__=='__main__':
    for path,row in json.loads((ROOT/BASE/'observed-version-identities.json').read_bytes()).items():
        relative=PurePosixPath(path);assert not relative.is_absolute() and '..' not in relative.parts
        body=(ROOT/relative).read_bytes();assert len(body)==row['bytes'] and digest(body)==row['sha256']
    assert (ROOT/BASE/'review-exit.txt').read_text()=='1\\n'
    assert b'julia version 1.12.6' in gzip.decompress((ROOT/BASE/'review-stderr.log.gz').read_bytes())
    result=main()
    result['observed_julia_version']=raw('intake',tag='version').decode().strip()
    result['reader_qualification']='original reader exit1 on manifest-derived1.12.6 assumption; separate reader derives actual captured host bytes; original proof/seal/reader/channels unchanged'
    print(json.dumps(result,indent=2,sort_keys=True))
'''
source=source[:-len(tail)]+new_tail
out=BASE/'review_observed_version.py';assert not out.exists();out.write_text(source)
record=dict(original_reader_sha256=hashlib.sha256(original.encode()).hexdigest(),qualified_reader_sha256=hashlib.sha256(source.encode()).hexdigest(),changed_assumption=needle,substitution=replacement,original_exit=1,actual_versions={phase:gzip.decompress((BASE/phase/'version-stdout.log.gz').read_bytes()).decode() for phase in ('intake','before','after','after-complete','direct')},scope='reader-only derivation of historical captured host version; no runtime/probe/normal/target/semantic observation edits')
(BASE/'reader-qualification.json').write_text(json.dumps(record,indent=2,sort_keys=True)+'\n')
print('separate observed-version reader authored; original failed reader and seal unchanged')
