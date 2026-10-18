"""Prepare bounded current cards; preflight the entire fixed byte budget first."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = 'ce9eaf32e19002c5fe11e22e5de3c3094270843d'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/'
target = ROOT / (PREFIX + 'knowledge-preparation.json')
assert not target.exists()
sha = lambda value: hashlib.sha256(value).hexdigest()
paths = json.loads((ROOT / 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/knowledge.json').read_bytes())['changed_cards']
original = {p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT) for p in paths}
assert all((ROOT / p).read_bytes() == value for p, value in original.items())
edits = {p: value.decode().replace('PERL-PRIVATE-FACTORY-CAPTURE.5.6/publish.py. Prior inputs:2b35b77ea.',
    'PERL-PRIVATE-FACTORY-CAPTURE.5.7/publish.py. Prior inputs:ce9eaf32e.') for p, value in original.items()}

def section(text, start, end, replacement):
    a, b = text.index(start), text.index(end)
    assert a < b
    return text[:a] + replacement + text[b:]

p = 'docs/knowledge/perl-factory-capture-framework.md'
s = edits[p].replace('  - "how do direct ControlFlow and rule apply calls preserve context and lookup order"',
    '  - "how do direct ControlFlow and rule apply calls preserve context and lookup order"\n  - "how does ControlFlow select mixed-provider default callback references"')
s = s.replace('optional kind and direct/rule boundaries verified; default/pipeline owners open',
    'optional/direct/rule and mixed-provider defaults verified; pipeline owners open')
s = section(s, 'The initial framework fixture assumed', 'Contracts, MethodLowering,',
    'The initial no-lexical-state factory calls shared a native CODE reference;\nlexical-state closures supply distinct test identities. Original four failed\nchecks and the corrected fixture remain with .1; this is not a cross-version rule.\n\n')
s = section(s, 'Required FlowExpr .4.0', 'Historical header archive:',
    'Required FlowExpr .4.0 binds five validators, preserving eager selection,\nscalar context, public maps and diagnostic lines. Trim writes remain local;\nnormalizer writes reach the shared parser array. Opaque children cannot donate\nparent packets; registered matching children keep their own. Exact proof and\nseparate optional/default admissions remain in their task owners.\n\n')
s = section(s, 'Optional FlowExpr kind .4.2', 'ControlFlow foundation .5.0',
    'Optional FlowExpr .4.2 keeps guarded two-read selection, scalar calls, match\naliases and opaque native non-CODE dispatch. Its completed lexical declaration\noccupies the original condition line; failed scope/location candidates remain\nretained beside native/source-control proof.\n\nFlowExpr defaults .4.1 selects its exact nine-reference EmitContext catalogue\nthrough built-in target, returned map and actual reference. Equal names, custom\ntarget aliases and other catalogues grant no authority. Retained definitions\nsurvive replacement. Nested scopes cannot borrow selection; normal/fatal exits\nrestore and completed registries release. Module-owned native references remain\nretained. Native factory contexts, errors, fatal objects and actual maps stay\nunchanged; list selects returned maps, void selects none. Cold calls load neither\nprivate channel nor Trace. Registration is an unordered identity set, with raw\norders retained separately; it does not produce or compose output.\n\n')
s = section(s, 'ControlFlow foundation .5.0', 'Branch expansion .5.1.0',
    'ControlFlow foundation .5.0 binds three validators/seven roles. Switch-tag\nnormalization stays in native list context with parent publication disabled;\ntrim/method/composite calls stay scalar. Eager selected references survive map\nreplacement. Empty brace-method output falls back to the original expression;\nswitch regex bypasses composite, and bare tags normalize after successful\ncomposite. Marker aliases remain. Exact proof stays with .5.0.\n\n')
s = section(s, 'If/while .5.2', 'Switch .5.3',
    'If/while .5.2 binds six validators/seven roles. Scalar calls, parser references\nand shared normalizer arrays stay native; hash/array returns cannot retain scalar\npackets. Inline-if normalizes the original array and reparses its aliased element;\ninline-action bypass shallow-copies it. Else failure keeps else_seen; empty-split\nwhile advances its guard. Original overwritten-case observations and corrected\ncomplete inventory remain retained. These probes do not establish facade execution.\n\n')
s += '''
Mixed defaults .5.7 has two definition-owned providers: seven target EmitContext
facades and ValueExpr's fixed native extractor. The built-in target selects its
actual facade references; custom facade aliases remain opaque. The fixed extractor
keeps its native provider for custom targets too. Same-name replacements remain
opaque; retained definitions survive replacement. Each provider rejects its other
definitions; there is no FlowExpr catalogue union. Factory contexts and actual
returned maps remain native. List selects each map, scalar selects its actual
result, and void selects none. Selection stays source/producer-local and lazy,
restores after fatal exits and does not compose output. Original401/44 proof is
frozen; extended445/53 adds fresh-void and disjoint multi-map controls. Complete
three-owner source inverses and native ledgers remain with .5.7.
'''
edits[p] = s
p = 'docs/knowledge/perl-emitcontext-callback-capture.md'
s = edits[p].replace('  - "can a resolved EmitContext owner or default factory donate nested publication"',
    '  - "can a resolved EmitContext owner or default factory donate nested publication"\n  - "does a custom ControlFlow target change its fixed ValueExpr provider"')
s = s.replace('date: 2026-10-12', 'date: 2026-10-18').replace('exact FlowExpr default selection verified',
    'exact FlowExpr/ControlFlow default selection verified')
s += '''
ControlFlow .5.7 retains seven facade definitions independently; its eighth default
is ValueExpr's definition-owned extractor. Custom targets cannot select facade
aliases but keep that fixed native provider. Each selector rejects other owner
definitions and same-name replacements. Public maps/references stay exact; fresh
void calls select none and list calls select both actual maps. Scope restoration
and ordinary behavior stay native. The new private selector adds one exact foreign
definition assertion to the dynamic FlowExpr fixture without enlarging its selected set.
'''
edits[p] = s
p = 'docs/knowledge/project-root-evidence-filesystem-modes.md'
s = edits[p].replace('  - "why can Git archive permissions differ from checkout permissions"',
    '  - "why can Git archive permissions differ from checkout permissions"\n  - "why do raw Perl INC module names fail repository input membership"')
s = s.replace('date: 2026-10-06', 'date: 2026-10-18')
s += '''
The .5.7 native writer reports raw %INC keys such as LinkedSpec/OwnerDispatch.pm,
while supplied manifests name perl/LinkedSpec/OwnerDispatch.pm. Its post-capture
membership check fails across those namespaces despite complete supplied sources
and successful commands. Preserve that writer/data; normalize the repository
prefix before comparison. Exact original predicate RED, normalized PASS and an
unsupplied-module RED remain in .5.7/native-review.py. Original observations and
failed review/builder sources retain their own identities and are not refreshed.
'''
edits[p] = s
current = sum(p.stat().st_size for p in (ROOT / 'docs/knowledge').rglob('*.md') if p.is_file())
size = current + sum(len(value.encode()) - len(original[p]) for p, value in edits.items())
assert len(edits) == 13 and size <= 8388608, (size, 'no writes before full preflight')
for path, value in edits.items():
    (ROOT / path).write_text(value)
report = dict(base=BASE, producer_sha256=sha(Path(__file__).read_bytes()), knowledge_bytes=size,
    cards={p: dict(original_sha256=sha(original[p]), current_sha256=sha(value.encode())) for p, value in edits.items()},
    scope='Fixed13-card overlays, no new card or budget increase. Three bodies change; ten route-only bodies stay exact. Statistical chronology is condensed with complete original bodies retained in accepted Git and the whole prior publication. Every new causal fact has its actual runtime/source/predicate controls in this leaf. The earlier oversized draft failed preflight before any card write; it is not passing evidence.')
with target.open('x') as output:
    output.write(json.dumps(report, indent=2) + '\n')
print('Knowledge preparation PASS:', size, 'bytes;13 overlays; fixed8MiB limit')
