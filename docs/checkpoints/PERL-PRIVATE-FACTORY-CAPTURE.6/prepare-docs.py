"""Pure preflight then one-shot bounded Knowledge/book lockstep with whole originals."""
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '64b66167c2277533c2393899e3754e14a74f0b31'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
FRAMEWORK = 'docs/knowledge/perl-factory-capture-framework.md'
SELECTION = 'docs/knowledge/perl-receiver-copy-canonical-selection.md'
NATIVE = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
WORKFLOW = 'docs/linkedspec-book/src/development/documentation-workflow.md'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert sys.argv[1:] in ([], ['--preflight'])
target = ROOT / (PREFIX + 'documentation-preparation.json')
assert not target.exists()
review = json.loads((ROOT / (PREFIX + 'runtime-review-final.json')).read_bytes())
assert review['result'] == 'PASS'
population = review['population']
assert population['focused_assertions'] == 2065 and population['semantic_inverses'] == 13
assert population['direct_suites'] == 91 and population['direct_assertions'] == 32235
preservation = json.loads((ROOT / (PREFIX + 'preservation.json')).read_bytes())
cards = sorted(path for path in preservation['owned_bound_paths'] if path.startswith('docs/knowledge/'))
assert len(cards) == 15 and FRAMEWORK in cards and SELECTION in cards
originals = {path: old(path) for path in cards + [NATIVE, WORKFLOW]}
assert all((ROOT / path).read_bytes() == value for path, value in originals.items())
route = 'Readonly: bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py. Prior:64b66167c.'
values = {}
for path in cards:
    header, body = originals[path].split(b'\n---\n', 1)
    header, count = re.subn(rb'^reverify: .*$', ('reverify: ' + json.dumps(route)).encode(), header, flags=re.M)
    assert count == 1
    values[path] = header + b'\n---\n' + body

header, _ = values[FRAMEWORK].split(b'\n---\n', 1)
questions = [
    'when does RewritePipeline activate private producer and input scopes',
    'does canonical apply preserve symbolic and blessed callable dispatch',
    'can an opaque pipeline factory donate a nested publication',
    'why do native Perl diagnostic filenames differ under prove',
    'why can an oracle reader add a line suffix to native Perl errors',
]
assert header.count(b'\ndate:') == 1
header = header.replace(b'\ndate:', b'\n' + b'\n'.join(
    ('  - ' + json.dumps(question)).encode() for question in questions) + b'\ndate:')
header = re.sub(rb'^date: .*$', b'date: 2026-10-19', header, flags=re.M)
header = re.sub(rb'^status: .*$', b'status: bounded factory/dependency and pipeline invocation scopes verified; output/mapping/parent admissions open', header, flags=re.M)
evidence = ('Leaf .6 preserves whole603/full115985 at64b66167c, original native96 plus distinct9-row '
            'callable/load-context epochs and failed instruments. Supplied426 inputs verify2065 assertions, '
            '13 exact semantic source inverses and91 suites/32235 assertions. Actual public native '
            'return_general callback/origin/source/producer/input identities match. Output/mapping and '
            'complete private/parent admission remain separate.')
header = re.sub(rb'^evidence: .*$', ('evidence: ' + json.dumps(evidence)).encode(), header, flags=re.M)
body = '''
Actual callbacks, inputs and publications have separate private authority.
`_register_emission_producer` retains an actual CODE reference only in the current
SourceOrigins token and producer registry, and returns that same reference.
Names, copied metadata and equal strings grant nothing. Nested equal-source
invocations cannot borrow registrations; successful/fatal exits restore the
parent and release completed registries. Module-owned native definitions remain
retained by their modules independently of invocation authority.

`_invoke_emission_dependency` preserves original argument aliases. Scalar calls
have their own actual capture and return the ordinary value. List/void calls
keep native context with publication disabled. An opaque child that emits and
returns the equal literal cannot donate publication to its parent. Successful
error effects and fatal object identity stay native. A known child's actual
capture can retain its own packet; later trusted output builders must explicitly
compose it. Public callback fields and dependency/context maps stay unchanged.

Contracts, MethodLowering, FlowExpr and ControlFlow select their definition-owned
native references through their bounded factories and isolate required,
optional, direct and rule calls. Original detailed family observations and every
earlier failure remain whole at64b66167c and in their stable task/checkpoint
owners. In particular, native list switch-tag normalization, writable/local or
read-only aliases, shared parser arrays, two-read optional selection and native
diagnostic locations keep their independently observed contracts. Package
objects gain no extra equality/string conversion merely to choose a provider.
Each default catalogue remains disjoint; custom targets add no new facade grant.
Scalar/list factory results select their actual returned maps; void selects none.

Pipeline .6 now opens fresh producer and input scopes inside its existing
SourceOrigins invocation before contract construction. The four selected
dependencies (factory, helper collection, canonical-event construction and
unresolved scan) have separate scalar frames. Each canonical apply captures the
actual selected CODE; other native callable values use an opaque call at the
original diagnostic site. Apply is fetched once after installing the actual
event, and an opaque selected callback releases before the next pipeline phase.
Caller list/scalar/void results, ordinary values, aliases, callback/rule/event
references, order, errors and observed release effects match the native ledgers.

Same-token factory/apply controls demonstrate actual equal-publication isolation.
Nested equal-source success and each fatal seam restore the actual outer call,
producer/input registries and source token; an existing outer builder keeps its
authority. The public lowering facade independently selects its actual native
return_general lower callback in the current registry. Already supplied rules
keep their references but gain no authority from public IDs or an earlier scope.

Native diagnostics depend on their actual load/reader context. App::Prove converts
`-Iperl` to a derived absolute include before any LinkedSpec import; direct Perl
can retain a relative module filename. Raw original channels remain immutable.
The current fixture projects only the expected historical owned filename into
the actual current `%INC` module, guards physical membership, and preserves the
entire actual error and native line. It explicitly closes oracle readers before
the call so Perl does not append their last-read line context.

Original framework224 and native closure-reference failures remain historical.
Current .6 supplied proof has2065 assertions,13 syntax-valid exact source
inverses and91 direct suites/32235 assertions in426 complete inputs. The original
native96, standalone/preload/prove-context9 epochs and every failed instrument
remain separate. Current native lowerers still return ordinary text: no typed/raw
output construction, child-packet composition, interval translation, quoted-first
replacement fix or complete private/mapped/parent admission follows from scopes.
'''
values[FRAMEWORK] = header + b'\n---\n' + body.encode()
header, body = values[SELECTION].split(b'\n---\n', 1)
header = header.replace(b'\ndate:', b'\n  - "does canonical CI select the new pipeline scope fixture"\ndate:', 1)
header = re.sub(rb'^status: .*$', b'status: canonical .7 receipt retained; pipeline fixture extends the selected framework suite', header, flags=re.M)
body += (f'\nPipeline .6 extends the already selected t/actionir_factory_capture.t to2065 assertions. '
         f'The existing91-suite/46-helper selector stays unchanged. Its current focused supplied run '
         f'passes91 suites/32235 assertions with13 effective runtime-source inverses. The canonical '
         f'.7 receipt at64b66167c covers its dated30394-assertion population; .6 uses the focused tier. '
         f'Whole603/full115985 and actual readonly baseline are preserved before this later runtime/test '
         f'change. Broader private/mapped/parent admissions retain their owners.\n').encode()
values[SELECTION] = header + b'\n---\n' + body

native = originals[NATIVE]
replacements = [
    (b'described below; other dependency owners and pipeline activation remain open.',
     b'described below; pipeline invocation scopes have their own section below, while output composition and complete private admission remain separate.'),
    (b'packets. Other dependency owners and pipeline activation remain open.',
     b'packets. Pipeline invocation scopes are described below; output composition and complete private admission remain separate.'),
    (b'child captures. ControlFlow, pipeline activation and independent complete private,\nparent and canonical admissions remain separately owned.',
     b'child captures. ControlFlow and pipeline invocation scopes are described below; independent complete private,\nparent and canonical admissions remain separately owned.'),
    (b'own sections below. Pipeline activation remains separately owned.',
     b'own sections below. The pipeline scope has its own section below.'),
    (b'registration, pipeline activation and full private acceptance remain separate.',
     b'registration and pipeline invocation scopes have their own sections; full private acceptance remains separate.'),
]
for before, after in replacements:
    assert before in native, before
    native = native.replace(before, after)
anchor = b'At `debug` trace level, the Perl reference pipeline reports these stages with\n'
assert native.count(anchor) == 1
addition = '''#### Invocation scopes and canonical apply

Each rewrite now opens fresh private producer and input registries inside its
existing original-source invocation, before it builds contracts. The nesting is:

```text
original-source invocation
  producer registry
    input registry
      contracts -> helper events -> canonical events -> apply -> diagnostics
```

The actual source token identifies this invocation. Two invocations with equal
text have different authority. Nested success or failure restores the enclosing
registries and any existing outer builder; completed inner registries release.

| Pipeline seam | Native call context | Private boundary |
| --- | --- | --- |
| Contract factory | Scalar | Actual factory callback; returned lower references stay unchanged |
| Helper collection | Scalar | Its own actual callback capture |
| Canonical-event construction | Scalar | Its own actual callback capture |
| Canonical apply | Scalar | Actual selected CODE; other native callables remain opaque |
| Unresolved-helper scan | Scalar | Its own actual callback capture |

The caller still receives its existing list or scalar result, or only the normal
effects in void context. Callback arguments, aliases, actual event/context/rule
references, ordering, successful error effects and fatal objects keep their
native behavior. Apply is fetched once after the current event is installed;
native symbolic, blessed and overloaded callables retain their dispatch and
diagnostic site. An opaque temporary callback releases before the next phase.

Authority follows construction in the current registry. For example, a native
contract factory can register the exact callback it returns. A supplied rule
with the same ID and an equal-output callback still runs, but that description
does not register its callback. Keeping a reference from another invocation
cannot borrow the new invocation's authority. Likewise, an opaque child can
emit and return `same` without donating a packet to a known outer callback.

This wiring does not build mapped output. Native lowerers continue returning
ordinary strings; later output builders must explicitly retain and compose
actual child captures. The existing replacement algorithm and quoted-first
defect remain with their repair owners. Complete private Phase 0, interval
mapping and independent parent/canonical admission remain separate.

'''
values[NATIVE] = native.replace(anchor, addition.encode() + anchor)
workflow = originals[WORKFLOW]
old_summary = b'The complete selected run passes 30394 assertions.'
assert workflow.count(old_summary) == 1
workflow = workflow.replace(old_summary,
    b'The .7 canonical admission at64b66167c passes 30394 assertions; the later focused pipeline extension is described below.')
anchor = b'### Historical claim populations\n'
assert workflow.count(anchor) == 1
addition = '''### Pipeline scope proof

The pipeline extension uses the already selected factory-capture suite, so the
canonical selector remains91 suites and46 test helpers. Its focused proof keeps
the earlier canonical admission's original inputs/results at64b66167c and
preserves the whole603-input/115985-byte publication before changing shared files.

| Current focused observation | Retained population |
| --- | --- |
| Native context, aliases, ordering, values and errors | 96 original rows |
| Callable, tied lookup and release behavior | 9 rows in distinct original/load-context epochs |
| Positive pipeline fixture | 2065 assertions |
| Exact syntax-valid semantic source inverses | 13, each with the same2065-assertion plan |
| Complete supplied runtime inputs | 426 byte/mode-retained files |
| All previously selected direct suites | 91 suites,32235 assertions |

The source controls remove either scope, move it outside the original-source
invocation, remove each actual callback boundary, duplicate an apply lookup,
retain opaque callbacks, register supplied callbacks, move native non-CODE
diagnostics or coerce body context. Same-source opaque publication, actual
identities, independently authored Unicode argument intervals and complete
native ledgers distinguish these faults. The public lowering facade selects an
actual native callback with its source origin and matching invocation registries.

Retain failed instruments too. The initial fixture require lacked a runtime root
anchor; an initial assertion plan depended on observed captures. Separate native
diagnostic epochs exposed the actual `prove` include conversion before imports,
and a later oracle reader added its own line context until explicitly closed.
Whole used sources, inputs, raw channels and exact repairs remain distinct.
Portable comparison projects only the expected historical owned-module filename
to the current verified module; actual errors and native lines remain exact.

This is focused invocation/callback integration. Native output composition,
mapping, the quoted-first replacement fix and complete private/parent admission
keep their separate owners. No selector, public language or budget change follows.

'''
values[WORKFLOW] = workflow.replace(anchor, addition.encode() + anchor)
knowledge_paths = sorted((ROOT / 'docs/knowledge').glob('*.md'))
total = sum(len(values.get(path.relative_to(ROOT).as_posix(), path.read_bytes())) for path in knowledge_paths)
record = dict(result='PASS' if total <= 8388608 else 'OVER_CAP', base=BASE,
              producer_sha256=sha(Path(__file__).read_bytes()), route=route, knowledge_bytes=total,
              changed_cards=cards, changed_bodies=[FRAMEWORK, SELECTION],
              originals={path: dict(sha256=sha(value), mode=(ROOT / path).stat().st_mode & 0o7777,
                                   bytes_base64=encode(value)) for path, value in originals.items()},
              proposed={path: dict(sha256=sha(value), bytes=len(value), bytes_base64=encode(value))
                        for path, value in values.items()},
              scope='Pure preflight retains all15 whole cards and both whole book chapters before writes. '
                    'Fifteen routes/two condensed-or-extended bodies; thirteen bodies exact. Framework '
                    'condenses historical family details already retained at the accepted Git boundary; '
                    'new scope/diagnostic facts have measured owners. No card/fact/decision/budget is added.')
if sys.argv[1:]:
    print(json.dumps(record, indent=1))
    raise SystemExit(0 if record['result'] == 'PASS' else 1)
assert record['result'] == 'PASS', ('prewrite Knowledge budget', total)
with target.open('x') as output:
    output.write(json.dumps(record, indent=1) + '\n')
for path, value in values.items():
    (ROOT / path).write_bytes(value)
print('Bounded Knowledge/book preparation PASS:', total, 'Knowledge bytes;15 routes/2 bodies;2 book chapters')
