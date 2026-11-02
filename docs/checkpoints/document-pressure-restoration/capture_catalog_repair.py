"""Retain the observed catalog metadata rejection/publication repair epoch."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[3]
PREFIX=Path(__file__).parent


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(),sha256=hashlib.sha256(raw).hexdigest())


def capture():
    destination=PREFIX/'catalog-metadata-repair.json.gz'
    assert not destination.exists(),'capture is one-shot'
    module='tools/lib/LinkedSpec/DocumentHistoryCatalog.pm'
    before=subprocess.check_output(['git','show',':'+module],cwd=ROOT)
    after=(ROOT/module).read_bytes()
    assert b'catalog producer metadata schema mismatch' not in before
    assert b'catalog producer metadata schema mismatch' in after
    red=(ROOT/'.linkedspec-data/normal-hook-restoration/catalog-metadata-red.log').read_bytes()
    green=(ROOT/'.linkedspec-data/normal-hook-restoration/catalog-metadata-green.log').read_bytes()
    assert b'Failed 4/45 subtests' in red and b'Result: FAIL' in red
    assert b'Tests=45' in green and b'Result: PASS' in green
    report=dict(before=packet(before),after=packet(after),consumer=packet((ROOT/'t/document_history_catalog.t').read_bytes()),
                red=packet(red),green=packet(green),command='bash tools/project_data_run.sh env PERL5LIB= prove t/document_history_catalog.t',
                scope='Extra/type-invalid producer metadata must reject before root replacement; unsupported input schema must not be silently coerced. The same permanent consumer observes baseline RED and repaired GREEN. No exhaustive malformed-payload claim.')
    destination.write_bytes(gzip.compress(json.dumps(report,sort_keys=True,separators=(',',':')).encode(),mtime=0))
    print('catalog repair: exact original/repaired producer, same consumer and observed RED/GREEN retained')

if __name__=='__main__':capture()
