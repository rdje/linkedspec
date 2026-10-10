---
id: perl-contract-dependency-capture
title: Contracts retain actual injected dependencies in private native-context bindings
answers:
  - "how does Contracts isolate required optional and bare dependencies"
  - "can an input_slice opaque dependency donate nested publication"
  - "does Contracts private capture replace public dependency maps or callback fields"
  - "can custom default targets register aliased EmitContext callbacks"
  - "why does the Contracts callback lifetime fixture require lexical state"
date: 2026-10-10
status: private dependency/default integration verified; actual lower construction and pipeline activation open
tags: [perl, actionir, contracts, dependencies, callbacks, identity]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.2.1.0 retains312 main/six cold assertions,15 exact native/current ledgers,16 effective syntax-valid semantic source faults and21 supplied suites in140 files. Four actual reviewer corruptions and one original-binding corruption reject then restore PASS; complete57-source book/two controls pass. All235 original EmitContext bindings are historical. One failed draft lifetime check and its consumer run are retained with exact original/current and lexical-state probe channels; only the lifetime fixture changed."
reverify: "Historical commands below require the card's recorded accepted Git inputs; they do not run against later source/book edits. Original .2.1.0 reviewers require exactbe7d70719 historical inputs. Current block-component integration and all242 original inline bindings are reviewed by docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1-review.py under tools/run_python_project_data.sh. One-shot writers are not resume commands. Current local-return integration, complete book and original399 preservation: docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0-final-review.py under tools/run_python_project_data.sh; use only readonly defaults. MEMORY.md owns the current frontier."
---

Contracts::_require_lowering_deps creates private lexical bindings for its actual
required and optional dropped-value callbacks. Each binding retains and invokes
the actual callback through the native-context dependency helper when loaded;
otherwise it calls the callback directly. The call forwards the original argument
aliases, native context, once-only effects, ordinary results, successful error
effects and fatal exception identity. Caller maps, default map results and public
returned lower fields remain unchanged. Private bindings release retained actual
callbacks when released and introduce no global callback cache.

The dropped-value fallback calls the same privately bound method dependency.
The call/dispatch factory privately binds the optional bare-type callback too;
both indexed and unindexed child-call push paths use that binding. An actual
opaque input_slice dependency can call a producer and return the equal literal
same without donating nested publication to an enclosing eligible contract.
Ordinary text, effects and scalar context remain native. These boundaries are
independent of later actual lower-callback construction registration.

The default factory selects native references only for the built-in EmitContext
target, and its selector also checks actual retained definition identity. A
same-name replacement remains unselected. A custom target does not register
defaults even when it aliases native references; callbacks already registered
elsewhere still retain their own actual identity within their existing scope.
No private channel or Trace is autoloaded for cold map/binding consumers.

The initial final lifetime check used an anonymous callback with no lexical
state. Its exact block fails on original and current Contracts; adding actual
lexical state passes both. This reverifies the native shared-closure fixture issue
already retained in perl-factory-capture-framework.md. The production source is
identical before and after that fixture correction. The original failed312 TAP,
failed21-suite channels, actual instrument/source/fixture and four probe modes
remain retained; they are not classified as a production retention defect.

Actual local and delegated lower construction registration is now verified under
.2.1.1 in docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md. Other dependency owners,
pipeline/output integration, complete private Phase0, mapped replacement and
independent canonical admission remain open.

Actual local/delegated construction .2.1.1 is now verified; see
docs/knowledge/perl-contract-constructor-capture.md. Other dependency owners and
pipeline activation remain subsequent work.

MethodLowering defaults .3.0, required trim .3.1.0 and required inference
.3.1.1 are accepted; inline .3.1.2.0 and block component .3.1.2.1 are accepted; local-return/value .3.1.2.2 and remaining required/optional families are next. Current rules/evidence live in
docs/knowledge/perl-method-default-capture.md. Original owner reviews retain
their recorded accepted input boundaries.

Required inference .3.1.1 is accepted; current native/caller/isolation rules
live in docs/knowledge/perl-method-inference-capture.md. Inline .3.1.2.0 and block component .3.1.2.1 are accepted; local-return/value .3.1.2.2
is next; remaining required/optional and pipeline owners stay open.
