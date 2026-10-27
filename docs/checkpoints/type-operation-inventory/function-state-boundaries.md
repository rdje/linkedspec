# Pure-function parser-state boundaries

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.29.2; Perl child29.2.1 repaired/targeted-checked.

Accepted authority is SPEC-FORMAT-TERSE.4.2.3 and its existing Phase0 entry_text
negative: pure function bodies cannot implicitly read caller parser state. This
is a repair of that rule, not new parser-state permission or a new function format.

At clean24e943f, the seven-case readonly public intake observes entry_groups,
match_map and entry_group returning caller captures with raw0/unresolved0/ready1;
capture_slice/mark_pos/entry_text are already unready and uppercase returns OK.
The new native/fresh regression independently confirms all eight collection/group
spellings leak caller captures. A nested function plus discarded map call does so
too. Initial adjacent definitions on one line fail source validation; the refined
newline-separated source is run unchanged before production and fails three groups,
with the explicit-argument/pure-helper group healthy. Exact producers/channels and
instrument refinement are retained in function-state-perl-intake.json.gz.

Contracts now derives a cached predicate from its existing code-owned typed source
projection rows and seven explicit compatibility spellings. MethodLowering checks
that semantic name boundary only under an active function stack, at typed/legacy
value and AST statement entrypoints. Existing unsupported markers keep the caller
unready before parser primitives or operands are emitted. No runtime JSON file,
name-prefix inference, new helper/IR/compiled field or callback permission.

Four new groups pass, including native/fresh nulls and explicit forbidden names,
nested/discarded calls, descriptor-only capture/mark/cursor negatives, and ready
explicit caller arguments/local assignment/nested String helpers/prefix-named
functions/ordinary getter continuations. Existing named-capture five and source
location contract four pass. No state writes are executed in the descriptor-only
control. No full suite, complete function/context proof or cross-backend admission.

Next: Rust29.2.2 independently establishes its behavior before any implementation;
Dart/Julia/safe Lua have separate children. Rule-dispatch/private context helpers,
deferred callbacks and exhaustive admission remain separately assessed under29.2
and23.4; this catalog fence does not establish their behavior.
