"""Disclose operational sizing legs separately from the finite Dart controls."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
LEAF = 'TYPE-REFERENCE-BOOK.1.2.23.3.80.3'
RECORD = 'docs/claims/' + LEAF + '.json'
names = [RECORD, 'docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md', 'MEMORY.md',
    str(BASE.relative_to(ROOT) / 'REVIEW.md'), str(BASE.relative_to(ROOT) / 'disclose_push_claim.py')]
out = BASE / 'push-claim-disclosure'
out.mkdir()


def freeze(tag):
    rows = {}
    with tarfile.open(out / (tag + '.tar.gz'), 'x:gz') as packed:
        for name in names:
            path = ROOT / name; body = path.read_bytes()
            rows[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
            packed.add(path, arcname=name, recursive=False)
    with tarfile.open(out / (tag + '.tar.gz')) as packed:
        assert set(packed.getnames()) == rows.keys()
        for member in packed:
            body = packed.extractfile(member).read(); row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
    (out / (tag + '.json')).write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')


freeze('before')
record = json.loads((ROOT / RECORD).read_bytes())
assert record['owner'] == LEAF and record['claims'][0]['falsify']['status'] == record['claims'][0]['durability']['status'] == 'gap'
task = ROOT / names[1]; source = task.read_text(); start = source.index('- ID: `' + LEAF + '`'); end = source.index('\n- ID:', start + 1)
part = source[start:end]; old = '  Claim verification: none: Finite own authored deterministic feature/preservation controls, no performance/population/portable-completeness measurement.'
assert part.count(old) == 1
part = part.replace(old, '  Claim verification: `' + RECORD + '`', 1)
part += '\n  Measurement disclosure: Finite Dart controls remain non-statistical authored examples. New operational outgoing-pack telemetry instead has its own three-leg record: rederive checked; independent historical size falsification and complete physical producer/artifact durability are disclosed gaps owned/scheduled by23.4.30. Metadata and ignored raw packs do not imply those missing legs. No negotiated upload guarantee.\n'
task.write_text(source[:start] + part + source[end:])
review = ROOT / names[3]
review.write_text(review.read_text() + '\nOperational measurement declaration: ' + RECORD + ' records checked\nre-derivation and disclosed falsification/durability gaps with repair owner23.4.30.\nThe original publication input/output archive precedes this explicit qualification;\npush-claim-disclosure/ retains this actual supplement and its before/after inputs.\n')
memory = ROOT / 'MEMORY.md'; source = memory.read_text(); anchor = 'Formal measurement closure/guard/discovery/publication belongs23.4.30'
assert source.count(anchor) == 1
memory.write_text(source.replace(anchor, 'The operational claim record explicitly discloses falsification/durability gaps; formal measurement closure/guard/discovery/publication belongs23.4.30', 1))
freeze('after')
print('Operational estimate: rederive checked; independent falsification/artifact closure gaps explicitly owned by23.4.30')
