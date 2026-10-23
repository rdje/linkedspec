"""Own the compatibility facts and public limitation without growing live history."""
import common as c
paths=['docs/knowledge/perl-multiline-helper-pattern-validation.md',
 'docs/knowledge/write-vivification-perl-reference.md',
 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md']
before={path:c.read(path) for path in paths}
path=paths[0]
text=(c.ROOT/path).read_text()
head,_=text.split('\n---\n',1)
head=head.replace('date: 2026-09-24','date: 2026-10-23',1)
head=head.replace('status: measured helper chain and public recomposition verified; EOF and independent defects remain',
 'status: scoped helper/recomposition and presence compatibility verified; raw payload fidelity remains owned',1)
head=head.replace('answers:\n','answers:\n  - why does presence tracking break an escaped raw regex\n  - why does an assigned multiline raw regex gain a semicolon\n',1)
body='''
# Current helper and compatibility boundaries

Validation::_helper_pattern_validation_view masks complete multiline helper regexes and quoted tokens only
inside expression scopes. It preserves every character position and CR/LF; compilation uses the original
source. Structural-looking rule/directive payloads stay inside the operand. Real repeated malformed headers
retain cumulative physical-line attribution, including the measured line7 control. Bare/unclosed strings
and open blocks still reject.

StatementSplit::Mode recognizes naked helper patterns at parenthesized argument boundaries, using MethodExpr's
existing slash-call discriminator. This prevents a closing y/ from reopening translation state and swallowing
the following statement or endif. Assignment-position slash interpretation remains separate and line based.
Validation's full-source regex-first retry and final-block division precedence are governed by
[[perl-slash-call-outer-block-validation]], including the later .86.5 physical-line/same-line/slot repairs.
The shared closing-brace safeguard is unchanged.

The original multiline failures involved regex_subst, matches followed by note=7, and matches before endif.
Both lowered/raw helper contexts and whole-source validation must be checked: a valid isolated fragment does
not prove its surrounding spec. Source diagnostics use public Get/runtime_ctx_ref, call_spec_handler_subst,
return_descriptor and dump_parser_source. Use an explicit action edge for return evidence; legacy no-edge
I/regex/E values do not independently establish E execution.

## Presence compatibility (October23)

TYPE-REFERENCE-BOOK.1.2.12's broader caller-slot tracking exposed two regressions. A tracked statement assignment
ended in flag=1, replacing the assigned lifecycle value. MethodLowering::_tracked_scalar_assignment_expr now
returns the assigned value. The compatibility splitter can pass an incomplete naked regex before its next
physical source fragment supplies the closing slash. Inserting a flag wrapper there changed the pattern and
left unmatched braces. The emitter now leaves that incomplete fragment intact; complete canonical assignments
keep their presence updates. Tracked-assignment-trace2 and compatibility2 under
docs/checkpoints/type-deferred-indexed-writes/ retain the exact caller/RHS/source and native/fresh controls.

The legacy raw-regex probe supplies Perl's default subject explicitly. The first repaired probe instead
reported an uninitialized-$_ warning on fresh execution; accepted24e9 has the same warning and value7.
That rejected quietness check is an instrument limitation, not a remaining compilation failure. Its exact
source/channels remain retained. The first trace instrument's CODE serialization failure also receives no credit.

A separate P2 defect remains: joining incomplete raw-regex fragments inserts a semicolon into the pattern.
Two LF subjects distinguish the authored pattern from that altered pattern. Native/fresh execution on both
accepted24e9 and repaired12 agrees with the inserted-semicolon oracle and disagrees with the authored oracle.
compatibility2.json.gz and raw_regex_oracle.pl retain the complete source/subject/producer/rollback evidence.
TYPE-REFERENCE-BOOK.1.2.21 owns repair after grouped19, before policy20/inventory. Use documented matches helpers
for multiline patterns; no general raw-host regex fidelity or portable raw-host capability is admitted here.
Bootstrap .54.1 and attached-tail .9 retain their distinct unescaped-brace obligations.

## Historical verification

The complete pre-update card, original reproductions and detailed historical scopes remain recoverable with
git show 24e9c72a31b7eb31ce94b09beab9655ae85378cb:docs/knowledge/perl-multiline-helper-pattern-validation.md.
This contains the unchanged textual-backslash-n versus physical-LF finding owned by
SUPPORTING-SOURCE-READING.2.4; this regex work selects no new string escape semantics.

- .86.4.3: six groups, focused173, complete Phase01033/1033.
- .86.4.6: seven groups; clean d2af200325 fails5/7; four files/52 focused tests; both division controls return7;
  book11 and Phase01033/1033 in1545s. LF/CRLF, eight host-operator-like suffixes, punctuation, once-only mutation,
  nested numeric operands and following statements/terminators remain covered.
- .86.4.7: nine groups; clean36df52e46 fails8/9; eight files/198 focused tests; book16 and Phase01033/1033 in1276s.
  Both quote styles, leading/trailing LF/CRLF, returned literals, inline helpers and substitutions retain their
  values. Four independently emitted substitution parsers and all four escape-route records remain exact.
- .86.4.8.2: grouped-operand repair, focused187/book21/Phase01033. Final .86.4.4.2.2 recomposition has59 controls:
  helper13, grouped22, numeric12 and original12, with the full syntax-node record unchanged. The checkpoint is
  docs/checkpoints/SESSION-STARTUP-READING.86.4.4.2.2.pl. Its malformed quoted regex remains rule_handler_compile
  with Unmatched ); its dated EOF failures were followed by the separately verified .86.5 repairs.
- Fresh generated bootstrap tracing is covered by [[perl-generated-source-cold-trace-dependency]]. Four exact
  Markdown specs and production/tests match9f81d3162, with focused173/book66 and two documentation mutation
  controls. This closes the scoped recomposition, not every helper family or inherited repair owner.

Related: [[perl-grouped-regex-operand-boundaries]], [[single-quoted-action-strings-variant-contract]],
[[write-vivification-perl-reference]].
'''
(c.ROOT/path).write_text(head+'\n---\n'+body)
path=paths[1]
text=(c.ROOT/path).read_text()
text=text.replace('answers:\n','answers:\n  - "why does a tracked lifecycle assignment return one"\n',1)
needle='Only this bounded Perl extension is admitted.\n'
assert text.count(needle)==1
text=text.replace(needle,needle+'Complete tracked scalar statements still yield their assigned value; a presence flag must not replace it.\nIncomplete raw-regex fragments retain their compatibility source boundary; [[perl-multiline-helper-pattern-validation]] owns the precise limitations.\n')
(c.ROOT/path).write_text(text)
note='Use the documented `matches(subject, /pattern/)` helper for multiline patterns. Legacy raw Perl assignments such as `rx = /pattern/` can acquire a semicolon at a physical line break and match different text. This affects native and emitted Perl; repair is pending.\n\n'
note_path=c.PREFIX+'book-compatibility-note.txt'
with (c.ROOT/note_path).open('x') as stream:stream.write(note)
path=paths[2]
text=(c.ROOT/path).read_text();marker='### Deferred indexed writes in Perl\n'
assert text.count(marker)==1
(c.ROOT/path).write_text(text.replace(marker,note+marker,1))
c.save('compatibility-docs.json.gz',dict(before=before,after={path:c.read(path) for path in paths},
 note=c.read(note_path),producer=c.read(c.PREFIX+'update_compatibility_docs.py'),
 historical_fact_source=c.BASE+':'+paths[0]))
print('Canonical compatibility facts and precise public raw-pattern limitation updated.')
