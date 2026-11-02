"""Retain the exact new storage source stage for historical byte reconciliation."""
from capture_storage_intake import ROOT, HERE, packet
import base64
import gzip
import json


def capture():
    destination = ROOT / 'tests/language-readiness/perl-storage-inventory-evolution.json.gz'
    assert not destination.exists(), 'never replace an admitted source epoch'
    intake = json.loads(gzip.decompress((HERE / 'storage-intake.json.gz').read_bytes()))
    source = 'tools/test_perl_project_data_storage.sh'
    before = intake['current'][source]
    assert base64.b64decode(before['base64']) != (ROOT / source).read_bytes()
    record = dict(schema_version=1, owner=intake['owner'], path=source,
                  before=before, after=packet((ROOT / source).read_bytes()),
                  support={name: packet((ROOT / name).read_bytes()) for name in (
                      'tools/check_project_storage_inventory.pl',
                      'doctrine/project_data_storage/perl_temporary_owners.json')},
                  capture_producer=packet(Path(__file__).read_bytes()),
                  limits='Exact source/data identity reconciliation to the prior 29-owner stage; older 27-to-29 inverse and falsifiers remain independent. No runtime admission.')
    destination.write_bytes(gzip.compress(json.dumps(record, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
    print(packet(destination.read_bytes())['sha256'])


from pathlib import Path
if __name__ == '__main__':
    capture()
