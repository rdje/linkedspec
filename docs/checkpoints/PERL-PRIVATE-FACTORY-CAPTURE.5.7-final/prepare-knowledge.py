"""Prepare bounded current cards; preflight the entire fixed byte budget first."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = 'ce9eaf32e19002c5fe11e22e5de3c3094270843d'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/'
target = ROOT / (PREFIX + 'knowledge-preparation.json')
assert not target.exists()
sha = lambda value: hashlib.sha256(value).hexdigest()
paths = json.loads((ROOT / 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/knowledge.json').read_bytes())['changed_cards']
original = {p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT) for p in paths}
initial = json.loads((ROOT / 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-object/preservation.json').read_bytes())
assert all(sha((ROOT / p).read_bytes()) == initial['inputs'][p]['sha256'] for p in paths)
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
# Reconstruct the initial card overlay exactly before the separately executed repair.
assert all(value.encode() == (ROOT / path).read_bytes() for path, value in edits.items())
for path in edits:
    edits[path] = edits[path].replace('PERL-PRIVATE-FACTORY-CAPTURE.5.7/publish.py', 'PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/publish.py')
p = 'docs/knowledge/perl-factory-capture-framework.md'
s = edits[p]
s = s.replace('  - "how does ControlFlow select mixed-provider default callback references"', '  - "how does ControlFlow select mixed-provider default callback references"\n  - "how do default factories preserve package object overload effects"')
s = section(s, 'The Contracts draft repeated', 'Required FlowExpr .4.0', 'Contracts construction and MethodLowering family proofs have their individual\nknowledge cards and task owners. Their initial closure-identity premise failures\nand scope corrections remain in accepted Git. MEMORY.md owns current selection;\nolder named boundaries and complete original prose remain recoverable.\n\n')
s = section(s, 'Branch expansion .5.1.0', 'If/while .5.2',
    'Branch expansion .5.1.0 binds eager scalar trim/split; text becomes one element,\nbraces retain the splitter array and non-ARRAY/blessed results decline. The match\nbody rejects writes despite a clear readonly flag; see perl-match-alias-writability.\nAttached parsing .5.1.1 binds both parser calls and head trim. Its native LVALUE\nsubstring is writable shared storage; mutation changes the first call scalar.\nTruthy parser results forward unchanged; false results continue the block scan.\nSingle statements .5.1.2 bind scalar trim to a writable local slot, leaving the\ncaller intact. Candidates copy stack-entry hashes/counters, share nested refs\nand commit nonempty changed results, including0. Source_method reconstruction\nand ordinary reference values alone grant no authority. Exact proofs remain in\ntheir owners; earlier full prose is retained in Git and the initial draft archive.\n\n')
s = section(s, 'Direct/rule .5.6', 'Mixed defaults .5.7',
    'Direct/rule .5.6 isolates selected CODE in native tail contexts; list/void\ndisable publication. Rules fetch apply once after candidate construction and\ninvoke scalar. Other callables use opaque native thunks at the original line.\nRejected scalar mutation reaches the next rule; nested candidate refs stay shared.\nNo name installs registration; exact original bodies remain in accepted Git.\n\n')
s = s.replace('actual facade references; custom facade aliases remain opaque.', 'actual facade references; custom targets add no facade registration.')
s += '\nPackage-object repair .5.7 preserves native OwnerDispatch lookup and overload\neffects in ControlFlow, FlowExpr and MethodLowering. Test !ref($pkg) before\ncomparing a built-in package name: object equality/string conversion must not\nrun merely to choose private authority. Inherited native references or a forged\nequality result grant no new facade registration. Fixed ValueExpr extraction\nremains independent. Existing actual registrations survive custom-target reuse;\nno-new-grant does not mean revoking a reference already authorized in that scope.\nThe published-builder oracle retains each owner\'s original construction context;\nMethodLowering builds scalar, while the other two forward. Original uncommitted\n546-input evidence is byte/mode preserved and fully replayed before repair.\n'
edits[p] = s
p = 'docs/knowledge/perl-emitcontext-callback-capture.md'
s = edits[p].replace('Custom targets cannot select facade\naliases but keep that fixed native provider.', 'Custom targets add no facade registration but keep that fixed native provider.')
s += '\nOnly plain built-in package-name strings select facade defaults. Package objects\nkeep native can/overload behavior without a new equality/string coercion. Native\nreferences already selected in the same source/producer scope retain authority;\na custom target does not revoke them. Fresh-scope and carryover observations are\ndistinct. The package-object repair has its own retained native/source controls.\n'
edits[p] = s
p = 'docs/knowledge/perl-method-default-capture.md'
s = edits[p].replace('date: 2026-10-10', 'date: 2026-10-18')
s += '\nThe .5.7 object-target repair checks plain package-name strings before comparing\nthe built-in target. Accepted package objects retain native lookup, returns,\nerrors and overload effects; inherited definitions or forged equality add no\nfacade grant. MethodLowering retains its existing scalar build under scalar,\nlist and void owners. Already-authorized actual references keep their scoped\nidentity. All original observations remain historical; current object proof is\nseparately captured and source-falsified.\n'
edits[p] = s

current = sum(p.stat().st_size for p in (ROOT / 'docs/knowledge').rglob('*.md') if p.is_file())
size = current + sum(len(value.encode()) - (ROOT / p).stat().st_size for p, value in edits.items())
assert len(edits) == 13 and size <= 8388608, (size, 'no writes before full preflight')
for path, value in edits.items():
    (ROOT / path).write_text(value)
report = dict(base=BASE, producer_sha256=sha(Path(__file__).read_bytes()), knowledge_bytes=size,
    cards={p: dict(original_sha256=sha(original[p]), current_sha256=sha(value.encode())) for p, value in edits.items()},
    scope='Fixed13-card overlays, no new card or budget increase. Four bodies change; nine route-only bodies stay exact. Prior framework prose is condensed without changing its causal conclusions with complete original bodies retained in accepted Git and the whole prior publication. Every new causal fact has its actual runtime/source/predicate controls in this leaf. The earlier oversized draft failed preflight before any card write; it is not passing evidence.')
with target.open('x') as output:
    output.write(json.dumps(report, indent=2) + '\n')
print('Knowledge preparation PASS:', size, 'bytes;13 overlays; fixed8MiB limit')
