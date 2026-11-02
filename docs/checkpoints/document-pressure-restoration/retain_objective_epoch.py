"""Retain a completed recovery report and recover every declared producer/input byte."""
import argparse
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[3]
PREFIX=Path(__file__).parent
BASE='0db5e9e87b7c1cfaf09936b9629974787038f5e3'


def sha(raw):return hashlib.sha256(raw).hexdigest()


def packet(raw):return dict(base64=base64.b64encode(raw).decode(),sha256=sha(raw))


def retain(log,output):
    assert log.is_relative_to(ROOT/'.linkedspec-data') and output.parent==PREFIX and not output.exists()
    raw=log.read_bytes();report=json.loads(raw);overrides={}
    books=json.loads(gzip.decompress((PREFIX/'book-inputs.json.gz').read_bytes()))
    for name,row in books.get('books',{}).items():overrides[name]=base64.b64decode(row['after']['base64'])
    auditor='tests/language-readiness/verify_objectives.py';current=(ROOT/auditor).read_bytes()
    with_owner=b"    images = _IMAGE_MODULE.ImageAdmissions(read(CURRENT_IMAGE_TABLE), CURRENT_IMAGE_TABLE_SHA256, git)\n    require(images.data['owner'] == CURRENT_IMAGE_OWNER, 'current image admission owner mismatch')\n    return images"
    without_owner=b"    return _IMAGE_MODULE.ImageAdmissions(read(CURRENT_IMAGE_TABLE), CURRENT_IMAGE_TABLE_SHA256, git)"
    if with_owner in current:overrides[auditor]=current.replace(with_owner,without_owner,1)
    inputs={}
    for name,expected in sorted(report['tracked_inputs'].items()):
        path=Path(name);assert not path.is_absolute() and '..' not in path.parts
        present=(ROOT/name).read_bytes()
        if sha(present)!=expected:
            assert name in overrides and sha(overrides[name])==expected,'unrecovered producer epoch: '+name
            present=overrides[name]
        previous=subprocess.run(['git','show',BASE+':'+name],cwd=ROOT,capture_output=True)
        if previous.returncode==0 and previous.stdout==present:
            inputs[name]=dict(sha256=expected,revision=BASE)
        else:inputs[name]=packet(present)
    result=dict(report=packet(raw),inputs=inputs,capture_producer=packet(Path(__file__).read_bytes()),
                limits='Exact retained producer/input epoch and historical-integrity observations. Git-backed inputs are immutable ancestor bytes; other inputs are complete packets. Original runtime executions are not repeated.')
    output.write_bytes(gzip.compress(json.dumps(result,sort_keys=True,separators=(',',':')).encode(),mtime=0))
    print('retained recovery epoch with every declared input',output.relative_to(ROOT))

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--log',required=True);parser.add_argument('--output',required=True);args=parser.parse_args();retain((ROOT/args.log).resolve(),(ROOT/args.output).resolve())
