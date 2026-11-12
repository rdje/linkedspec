"""Preserve each original consumer's attribution before the observer's first SDK use."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
observer = BASE / 'observer.pl'
assert not (BASE / 'intake').exists() and not (BASE / 'observer-routing.json').exists()
before = observer.read_text()
old_identity = "source_identity=>'array-concat-open-arity-selection.spec'"
new_identity = "source_identity=>(($case->{origin}//'') eq 'legacy312' ? 'array-transform-callable-perl.spec' : 'array-concat-open-arity-selection.spec')"
old_package = "my $package='LinkedSpec::ArrayConcatOpenAritySelection::'.$id;"
new_package = "my $package=(($case->{origin}//'') eq 'legacy312' ? 'LinkedSpec::ArrayTransformCallablePerlIntakeProbe::' : 'LinkedSpec::ArrayConcatOpenAritySelection::').$id;"
assert before.count(old_identity) == before.count(old_package) == 1
after = before.replace(old_identity, new_identity).replace(old_package, new_package)
for phase, body in (('prepared', before), ('routed', after)):
    target = BASE / ('observer-' + phase + '.pl.gz')
    assert not target.exists()
    target.write_bytes(gzip.compress(body.encode(), mtime=0))
    assert gzip.decompress(target.read_bytes()) == body.encode()
observer.write_text(after)
(BASE / 'observer-routing.json').write_text(json.dumps(dict(
    before_sha256=hashlib.sha256(before.encode()).hexdigest(), after_sha256=hashlib.sha256(after.encode()).hexdigest(),
    scope='Before any SDK use, preserve original legacy312 source identity/package while shared84/own questions keep the selection identity/package. Source cases and SDK bytes unchanged; no acquired outcome or used observer is rewritten.'), indent=2) + '\n')
print('Prepared original-attribution routing before observer first SDK use; no acquired epoch replay')
